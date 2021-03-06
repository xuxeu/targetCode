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

#ifndef QSHAREDMEMORY_P_H
#define QSHAREDMEMORY_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists for the convenience
// of qapplication_qws.cpp and qgfxvnc_qws.cpp.  This header file may
// change from version to version without notice, or even be removed.
//
// We mean it.
//

#if !defined (QT_QWS_NO_SHM)

#include "qplatformdefs.h"
#include "qstring.h"

class QSharedMemory {
public:
        QSharedMemory() {};
        QSharedMemory(int, const QString &, char c = 'Q');
        ~QSharedMemory() {};

        bool create();
        void destroy();

        bool attach();
        void detach();

        void setPermissions(mode_t mode);
        int size();
        void * base() { return shmBase; };

private:
        void *shmBase;
        int shmSize;
        QString shmFile;
        char character;
#if defined(QT_POSIX_QSHM)
        int shmFD;
#else
        int shmId;
        key_t key;
        int idInitted;
#endif
};

#endif

#endif // QSHAREDMEMORY_P_H
