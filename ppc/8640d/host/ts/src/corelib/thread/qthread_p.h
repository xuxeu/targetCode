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

#ifndef QTHREAD_P_H
#define QTHREAD_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists for the convenience
// of QAbstractItemModel*.  This header file may change from version
// to version without notice, or even be removed.
//
// We mean it.
//
//

#include "qplatformdefs.h"
#include <private/qobject_p.h>
#include "qmutex.h"
#include "qstack.h"
#include "qthread.h"
#include "qwaitcondition.h"

class QAbstractEventDispatcher;
class QEventLoop;

class QPostEvent
{
public:
    QObject *receiver;
    QEvent *event;
    inline QPostEvent()
        : receiver(0), event(0)
    { }
    inline QPostEvent(QObject *r, QEvent *e)
        : receiver(r), event(e)
    { }
};

class QPostEventList : public QList<QPostEvent>
{
public:
    int recursion;
    QMutex mutex;

    inline QPostEventList()
        : QList<QPostEvent>(), recursion(0)
    { }
};

class Q_CORE_EXPORT QThreadData
{
public:
    QThreadData();
    ~QThreadData();

    static QThreadData *get(QThread *thread);
    
    int id;
    bool quitNow;
    QAbstractEventDispatcher *eventDispatcher;
    QStack<QEventLoop *> eventLoops;
    QPostEventList postEventList;
    bool canWait;
    void **tls;
};

#ifndef QT_NO_THREAD
class QThreadPrivate : public QObjectPrivate
{
    Q_DECLARE_PUBLIC(QThread)

public:
    QThreadPrivate();

    mutable QMutex mutex;

    bool running;
    bool finished;
    bool terminated;

    uint stackSize;

    static void setCurrentThread(QThread *thread);

    static QThread *threadForId(int id);

#ifdef Q_OS_UNIX
    pthread_t thread_id;
    QWaitCondition thread_done;

    static void *start(void *arg);
    static void finish(void *arg);
#endif

#ifdef Q_OS_WIN32
    HANDLE handle;
    unsigned int id;
    int waiters;
    bool terminationEnabled, terminatePending;

    static unsigned int __stdcall start(void *);
    static void finish(void *, bool lockAnyway=true);
#endif // Q_OS_WIN32

    QThreadData data;
};

#else // QT_NO_THREAD

class QThreadPrivate : public QObjectPrivate
{
public:
    QThreadPrivate(QThread *threadInstance)
    { Q_ASSERT(!QThread::instance); QThread::instance = threadInstance; }
    QThreadData data;
    static void setCurrentThread(QThread*) {}
    static QThread *threadForId(int) { return QThread::currentThread(); }

    Q_DECLARE_PUBLIC(QThread)
};
#endif // QT_NO_THREAD

#endif // QTHREAD_P_H
