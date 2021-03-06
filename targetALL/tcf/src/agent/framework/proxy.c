/*******************************************************************************
 * Copyright (c) 2007, 2010 Wind River Systems, Inc. and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 * The Eclipse Public License is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 * http://www.eclipse.org/org/documents/edl-v10.php.
 * You may elect to redistribute this code under either of these licenses.
 *
 * Contributors:
 *     Wind River Systems - initial API and implementation
 *******************************************************************************/

/*
 * This module implements tunneling of TCF messages to another target on behalf of a client
 * This service intended to be used when a client has no direct access to a target.
 */

#include <tcf_config.h>
#include <assert.h>
#include <string.h>
#include <framework/proxy.h>
#include <framework/protocol.h>
#include <framework/trace.h>
#include <framework/errors.h>
#include <framework/exceptions.h>
#include <framework/myalloc.h>

typedef struct Proxy {
    Channel * c;
    Protocol * proto;
    int other;
    int instance;
} Proxy;

static ChannelRedirectionListener redirection_listeners[16];
static int redirection_listeners_cnt = 0;

static void proxy_connecting(Channel * c) {
    int i;
    Proxy * target = (Proxy *)c->client_data;
    Proxy * host = target + target->other;

    assert(c == target->c);
    assert(target->other == -1);
    assert(c->state == ChannelStateStarted);
    assert(host->c->state == ChannelStateHelloReceived);

    for (i = 0; i < redirection_listeners_cnt; i++) {
        redirection_listeners[i](host->c, target->c);
    }

    target->c->disable_zero_copy = !host->c->out.supports_zero_copy;
    send_hello_message(target->c);

    trace(LOG_PROXY, "Proxy waiting Hello from target");
}

static void proxy_connected(Channel * c) {
    int i;
    Proxy * target = (Proxy *)c->client_data;
    Proxy * host = target + target->other;

    assert(target->c == c);
    if (target->other == 1) {
        /* We get here after sending hello to host */
        return;
    }
    assert(c->state == ChannelStateConnected);
    assert(host->c->state == ChannelStateHelloReceived);

    host->c->disable_zero_copy = !target->c->out.supports_zero_copy;

    trace(LOG_PROXY, "Proxy connected, target services:");
    for (i = 0; i < target->c->peer_service_cnt; i++) {
        char * nm = target->c->peer_service_list[i];
        trace(LOG_PROXY, "    %s", nm);
        if (strcmp(nm, "ZeroCopy") == 0) continue;
        protocol_get_service(host->proto, nm);
    }

    for (i = 0; i < redirection_listeners_cnt; i++) {
        redirection_listeners[i](host->c, target->c);
    }

    send_hello_message(host->c);
}

static void proxy_disconnected(Channel * c) {
    Proxy * proxy = (Proxy *)c->client_data;

    assert(c == proxy->c);
    if (proxy[proxy->other].c->state == ChannelStateDisconnected) {
        trace(LOG_PROXY, "Proxy disconnected");
        if (proxy->other == -1) proxy--;
        broadcast_group_free(c->bcg);
        assert(proxy[0].c->bcg == NULL);
        assert(proxy[1].c->bcg == NULL);
        proxy[0].c->client_data = NULL;
        proxy[1].c->client_data = NULL;
        protocol_release(proxy[0].proto);
        protocol_release(proxy[1].proto);
        channel_unlock(proxy[0].c);
        channel_unlock(proxy[1].c);
        loc_free(proxy);
    }
    else {
        channel_close(proxy[proxy->other].c);
    }
}

#if ENABLE_Trace

static char log_buf[1024];
static size_t log_pos = 0;

static void log_chr(int c) {
    if (log_pos + 2 < sizeof log_buf) log_buf[log_pos++] = (char)c;
}

static void log_str(const char * s) {
    char c;
    while ((c = *s++) != '\0') {
        if (log_pos + 2 < sizeof log_buf) log_buf[log_pos++] = c;
    }
}

static void log_byte_func(int i) {
    if (i > ' ' && i < 127) {
        /* Printable ASCII  */
        log_chr(i);
    }
    else if (i == 0) {
        log_chr(' ');
    }
    else if (i > 0) {
        char buf[16];
        snprintf(buf, sizeof buf, "\\x%02x", i);
        log_str(buf);
    }
    else if (i == MARKER_EOM) {
        log_str("<eom>");
    }
    else if (i == MARKER_EOS) {
        log_str("<eom>");
    }
    else {
        log_str("<?>");
    }
}

#define log_byte(b) { if (log_mode & LOG_TCFLOG) log_byte_func(b); }

static void log_start(Proxy * proxy, char ** argv, int argc) {
    int i;
    log_pos = 0;
    if (log_mode & LOG_TCFLOG) {
        log_str(proxy->other > 0 ? "---> " : "<--- ");
        for (i = 0; i < argc; i++) {
            log_str(argv[i]);
            log_chr(' ');
        }
    }
}

static void log_flush(Proxy * proxy) {
    if (log_mode & LOG_TCFLOG) {
        log_chr(0);
        trace(LOG_TCFLOG, "%d: %s", proxy->instance, log_buf);
    }
}

#else

#define log_start(a, b, c) 0
#define log_byte(a) 0
#define log_flush(a) 0

#endif

static void proxy_default_message_handler(Channel * c, char ** argv, int argc) {
    /* TODO: if proxy is connected to itself, it can deadlock when retransmitting a long message */
    Proxy * proxy = (Proxy *)c->client_data;
    Channel * otherc = proxy[proxy->other].c;
    InputStream * inp = &c->inp;
    OutputStream * out = &otherc->out;
    int i = 0;

    assert(c == proxy->c);
    assert(argc > 0 && strlen(argv[0]) == 1);
    if (proxy[proxy->other].c->state == ChannelStateDisconnected) return;

    if (argv[0][0] == 'C') {
        write_stringz(out, argv[0]);
        /* Prefix token with 'R'emote to distinguish from locally generated commands */
        write_stream(out, 'R');
        i = 1;
    }
    else if (argv[0][0] == 'R' || argv[0][0] == 'P' || argv[0][0] == 'N') {
        if (argv[1][0] != 'R') {
            trace(LOG_ALWAYS, "Reply with unexpected token: %s", argv[1]);
            exception(ERR_PROTOCOL);
        }
        argv[1]++;
    }

    while (i < argc) write_stringz(out, argv[i++]);

    log_start(proxy, argv, argc);

    /* Copy body of message */
    do {
        if (out->supports_zero_copy &&
#if ENABLE_Trace
               (log_mode & LOG_TCFLOG) == 0 &&
#endif
                inp->end - inp->cur >= 0x100) {
            write_block_stream(out, (char *)inp->cur, inp->end - inp->cur);
            inp->cur = inp->end;
        }
        else {
            i = read_stream(inp);
            log_byte(i);
            write_stream(out, i);
        }
    }
    while (i != MARKER_EOM && i != MARKER_EOS);
    log_flush(proxy);
}

void proxy_create(Channel * c1, Channel * c2) {
    TCFBroadcastGroup * bcg = broadcast_group_alloc();
    Proxy * proxy = (Proxy *)loc_alloc_zero(2 * sizeof *proxy);
    int i;

    static int instance;

    assert(c1->state == ChannelStateRedirectReceived);
    assert(c2->state == ChannelStateStartWait);

    /* Host */
    channel_lock(c1);
    proxy[0].c = c1;
    proxy[0].proto = protocol_alloc();
    proxy[0].other = 1;
    proxy[0].instance = instance;

    /* Target */
    channel_lock(c2);
    proxy[1].c = c2;
    proxy[1].proto = protocol_alloc();
    proxy[1].other = -1;
    proxy[1].instance = instance++;

    trace(LOG_PROXY, "Proxy created, host services:");
    for (i = 0; i < c1->peer_service_cnt; i++) {
        char * nm = c1->peer_service_list[i];
        trace(LOG_PROXY, "    %s", nm);
        if (strcmp(nm, "ZeroCopy") == 0) continue;
        protocol_get_service(proxy[1].proto, nm);
    }
    c1->state = ChannelStateHelloReceived;
    notify_channel_closed(c1);
    protocol_release(c1->protocol);
    c1->client_data = NULL;
    assert(c2->protocol == NULL);

    c1->connecting = proxy_connecting;
    c1->connected = proxy_connected;
    c1->disconnected = proxy_disconnected;
    c1->client_data = proxy;
    c1->protocol = proxy[0].proto;
    set_default_message_handler(proxy[0].proto, proxy_default_message_handler);

    c2->connecting = proxy_connecting;
    c2->connected = proxy_connected;
    c2->disconnected = proxy_disconnected;
    c2->client_data = proxy + 1;
    c2->protocol = proxy[1].proto;
    set_default_message_handler(proxy[1].proto, proxy_default_message_handler);

    channel_set_broadcast_group(c1, bcg);
    channel_set_broadcast_group(c2, bcg);
    channel_start(c2);
}

void add_channel_redirection_listener(ChannelRedirectionListener listener) {
    assert(redirection_listeners_cnt < (int)(sizeof(redirection_listeners) / sizeof(ChannelRedirectionListener)));
    redirection_listeners[redirection_listeners_cnt++] = listener;
}
