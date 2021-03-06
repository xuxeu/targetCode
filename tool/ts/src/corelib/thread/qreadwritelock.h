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

#ifndef QREADWRITELOCK_H
#define QREADWRITELOCK_H

#include <QtCore/qglobal.h>
#include <limits.h>

QT_MODULE(Core)

struct QReadWriteLockPrivate;

class Q_CORE_EXPORT QReadWriteLock
{
public:
    QReadWriteLock();
    ~QReadWriteLock();

    void lockForRead();
    bool tryLockForRead();

    void lockForWrite();
    bool tryLockForWrite();

    void unlock();

private:
    Q_DISABLE_COPY(QReadWriteLock)
    QReadWriteLockPrivate *d;
};

class Q_CORE_EXPORT QReadLocker
{
public:
    inline QReadLocker(QReadWriteLock *readWriteLock);

    inline ~QReadLocker()
    { unlock(); }

    inline void unlock()
    { if (q_lock) q_lock->unlock(); }

    inline void relock()
    { if (q_lock) q_lock->lockForRead(); }

    inline QReadWriteLock *readWriteLock() const
    { return q_lock; }

private:
    Q_DISABLE_COPY(QReadLocker)
    QReadWriteLock *q_lock;
};

inline QReadLocker::QReadLocker(QReadWriteLock *areadWriteLock)
    : q_lock(areadWriteLock)
{ relock(); }

class Q_CORE_EXPORT QWriteLocker
{
public:
    inline QWriteLocker(QReadWriteLock *readWriteLock);

    inline ~QWriteLocker()
    { unlock(); }

    inline void unlock()
    { if (q_lock) q_lock->unlock(); }

    inline void relock()
    { if (q_lock) q_lock->lockForWrite(); }

    inline QReadWriteLock *readWriteLock() const
    { return q_lock; }

private:
    Q_DISABLE_COPY(QWriteLocker)
    QReadWriteLock *q_lock;
};

inline QWriteLocker::QWriteLocker(QReadWriteLock *areadWriteLock)
    : q_lock(areadWriteLock)
{ relock(); }

#endif // QREADWRITELOCK_H
