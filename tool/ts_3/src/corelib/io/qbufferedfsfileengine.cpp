/****************************************************************************
**
** Copyright (C) 1992-2005 Trolltech AS. All rights reserved.
**
** This file is part of the QtCore module of the Qt Toolkit.
**
** Licensees holding a valid Qt License Agreement may use this file in
** accordance with the rights, responsibilities and obligations
** contained therein.  Please consult your licensing agreement or
** contact sales@trolltech.com if any conditions of this licensing
** agreement are not clear to you.
**
** Further information about Qt licensing is available at:
** http://www.trolltech.com/products/qt/licensing.html or by
** contacting info@trolltech.com.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#include <errno.h>
#include <stdio.h>

#include "qdatetime.h"
#include "qdebug.h"
#include "qfileengine.h"
#include "qbufferedfsfileengine_p.h"

// Required to build with msvc.net 2002
#ifndef S_ISREG
#define S_ISREG(x)   (((x) & S_IFMT) == S_IFREG)
#endif

#ifdef Q_OS_WIN
#  ifndef S_ISCHR
#    define S_ISCHR(x)   (((x) & S_IFMT) == S_IFCHR)
#  endif
#  ifndef S_ISFIFO
#    define S_ISFIFO(x) false
#  endif
#  ifndef S_ISSOCK
#    define S_ISSOCK(x) false
#  endif
#endif

QBufferedFSFileEngine::QBufferedFSFileEngine(const QString &fileName)
    : QFSFileEngine(*new QBufferedFSFileEnginePrivate)
{
    Q_D(QBufferedFSFileEngine);
    d->file = QFSFileEnginePrivate::fixToQtSlashes(fileName);
}

QBufferedFSFileEngine::~QBufferedFSFileEngine()
{
    Q_D(QBufferedFSFileEngine);
    if (d->fh && d->closeFileHandle)
        fclose(d->fh);
}

QFileEngine::Type QBufferedFSFileEngine::type() const
{
    return BufferedFile;
}

bool QBufferedFSFileEngine::open(int flags)
{
    Q_D(QBufferedFSFileEngine);
    if (d->file.isEmpty()) {
        qWarning("QBufferedFSFileEngine::open: No file name specified");
        d->setError(QFile::OpenError, QT_TRANSLATE_NOOP(QBufferedFSFileEngine, "No file name specified"));
        return false;
    }

    QByteArray mode;
    if ((flags & QIODevice::ReadOnly) && !(flags & QIODevice::Truncate)) {
        mode = "rb";
        if (flags & QIODevice::WriteOnly) {
            if (QFile::exists(d->file))
                mode = "rb+";
            else
                mode = "wb+";
        }
    } else if (flags & QIODevice::WriteOnly) {
        mode = "wb";
        if (flags & QIODevice::ReadOnly)
            mode += "+";
    }
    if (flags & QIODevice::Append) {
        mode = "ab";
        if (flags & QIODevice::ReadOnly)
            mode += "+";
    }


#if defined(_MSC_VER) && _MSC_VER >= 1400
	if (fopen_s(&(d->fh), QFile::encodeName(d->file).constData(), mode.constData())) {
		d->fh = 0;
#else
	d->fh = QT_FOPEN(QFile::encodeName(d->file).constData(), mode.constData());    
	if (!d->fh) {
#endif
        QString errString = QT_TRANSLATE_NOOP(QBufferedFSFileEngine, "Unknown error");
        d->setError(errno == EMFILE ? QFile::ResourceError : QFile::OpenError,
                    qt_error_string(int(errno)));
        return false;
    }
    if (flags & QIODevice::Append)
        QT_FSEEK(d->fh, 0, SEEK_END);

    d->closeFileHandle = true;
    d->fd = QT_FILENO(d->fh);

    QT_STATBUF st;
    if (QT_FSTAT(QT_FILENO(d->fh), &st) != 0)
	return false;
    d->sequential = S_ISCHR(st.st_mode) || S_ISFIFO(st.st_mode) || S_ISSOCK(st.st_mode);

    return true;
}

bool QBufferedFSFileEngine::open(int /* flags */, FILE *fh)
{
    Q_D(QBufferedFSFileEngine);
    d->fh = fh;
    d->fd = QT_FILENO(fh);
    QT_STATBUF st;
    if (QT_FSTAT(QT_FILENO(fh), &st) != 0)
	return false;
    d->sequential = S_ISCHR(st.st_mode) || S_ISFIFO(st.st_mode) || S_ISSOCK(st.st_mode);
    d->closeFileHandle = false;
    return true;
}

bool QBufferedFSFileEngine::close()
{
    Q_D(QBufferedFSFileEngine);
    flush();
    if (d->fh && d->closeFileHandle)
        fclose(d->fh);
    d->fh = 0;
    d->fd = -1;
    return true;
}

void QBufferedFSFileEngine::flush()
{
    Q_D(QBufferedFSFileEngine);
    if (!d->fh)
        return;
#ifdef Q_OS_WIN
    QT_FPOS_T pos;
    int gotPos = QT_FGETPOS(d->fh, &pos);
#endif
    fflush(d->fh);
#ifdef Q_OS_WIN
    if (gotPos == 0)
        QT_FSETPOS(d->fh, &pos);
#endif
    d->lastIOCommand = QBufferedFSFileEnginePrivate::IOFlushCommand;
}

qint64 QBufferedFSFileEngine::at() const
{
    Q_D(const QBufferedFSFileEngine);
    if (!d->fh)
        return -1;
    return qint64(QT_FTELL(d->fh));
}

bool QBufferedFSFileEngine::seek(qint64 offset)
{
    Q_D(QBufferedFSFileEngine);
    if (!d->fh)
        return false;
    if (QT_FSEEK(d->fh, QT_OFF_T(offset), SEEK_SET) == -1) {
        d->setError(QFile::ReadError, qt_error_string(int(errno)));
        return false;
    }
    return true;
}

qint64 QBufferedFSFileEngine::read(char *data, qint64 maxlen)
{
    Q_D(QBufferedFSFileEngine);
    if (d->lastIOCommand != QBufferedFSFileEnginePrivate::IOReadCommand) {
        flush();
        d->lastIOCommand = QBufferedFSFileEnginePrivate::IOReadCommand;
    }
    if (!d->fh)
        return -1;

    if (feof(d->fh))
        return 0;

    size_t readBytes = 0;
#ifdef Q_OS_UNIX
    if (d->sequential) {
        int oldFlags = fcntl(fileno(d->fh), F_GETFL);

        for (int i = 0; i < 2; ++i) {
            // Make the underlying file descriptor non-blocking
            int v = 1;
            if ((oldFlags & O_NONBLOCK) == 0)
                fcntl(fileno(d->fh), F_SETFL, oldFlags | O_NONBLOCK, &v, sizeof(v));

            size_t read = fread(data + readBytes, 1, size_t(maxlen - readBytes), d->fh);
            if (read > 0) {
                readBytes += read;
                break;
            } else {
                if (readBytes)
                    break;
                readBytes = read;
            }

            // Restore the blocking state of the underlying socket
            if ((oldFlags & O_NONBLOCK) == 0) {
                int v = 1;
                fcntl(fileno(d->fh), F_SETFL, oldFlags, &v, sizeof(v));
                if (readBytes == 0) {
                    int readByte = fgetc(d->fh);
                    if (readByte != -1) {
                        *data = uchar(readByte);
                        readBytes += 1;
                    }
                }
            }
        }
        if ((oldFlags & O_NONBLOCK) == 0) {
            int v = 1;
            fcntl(fileno(d->fh), F_SETFL, oldFlags, &v, sizeof(v));
        }
    } else
#endif
    {
        readBytes = fread(data, 1, size_t(maxlen), d->fh);
    }
    if (readBytes == 0)
        d->setError(QFile::ReadError, qt_error_string(int(errno)));
    return readBytes;
}

qint64 QBufferedFSFileEngine::readLine(char *data, qint64 maxlen)
{
    Q_D(QBufferedFSFileEngine);
    if (!d->fh)
        return -1;
    if (d->lastIOCommand != QBufferedFSFileEnginePrivate::IOReadCommand) {
        flush();
        d->lastIOCommand = QBufferedFSFileEnginePrivate::IOReadCommand;
    }
    if (feof(d->fh))
        return 0;

    // QIODevice::readLine() passes maxlen - 1 to QFile::readLineData()
    // because it has made space for the '\0' at the end of data.  But fgets
    // does the same, so we'd get two '\0' at the end - passing maxlen + 1
    // solves this.
    if (!fgets(data, int(maxlen + 1), d->fh)) {
        d->setError(QFile::ReadError, qt_error_string(int(errno)));
	return -1;
    }
    return qstrlen(data);
}

qint64 QBufferedFSFileEngine::write(const char *data, qint64 len)
{
    Q_D(QBufferedFSFileEngine);
    if (!d->fh)
        return -1;
    if (d->lastIOCommand != QBufferedFSFileEnginePrivate::IOWriteCommand) {
        flush();
        d->lastIOCommand = QBufferedFSFileEnginePrivate::IOWriteCommand;
    }
    qint64 result = qint64(fwrite(data, 1, size_t(len), d->fh));
    if (result > 0)
        return result;
    d->setError(QFile::ReadError, qt_error_string(int(errno)));
    return result;
}

