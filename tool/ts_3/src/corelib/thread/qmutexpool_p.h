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

#ifndef QMUTEXPOOL_P_H
#define QMUTEXPOOL_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists for the convenience
// of QSettings. This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include "qmutex.h"

#ifndef QT_NO_THREAD

class Q_CORE_EXPORT QMutexPool
{
public:
    explicit QMutexPool(bool recursive = false, int size = 128);
    ~QMutexPool();

    QMutex *get(const void *address);

private:
    QMutex mutex;
    QMutex **mutexes;
    int count;
    bool recurs;
};

extern Q_CORE_EXPORT QMutexPool *qt_global_mutexpool;

#endif // QT_NO_THREAD

#endif // QMUTEXPOOL_P_H
