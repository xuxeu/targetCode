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

#ifndef QNUMERIC_P_H
#define QNUMERIC_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include <qglobal.h>

static const unsigned char qt_be_inf_bytes[] = { 0x7f, 0xf0, 0, 0, 0, 0, 0, 0 };
static const unsigned char qt_le_inf_bytes[] = { 0, 0, 0, 0, 0, 0, 0xf0, 0x7f };
static inline double qtInf()
{
    return *reinterpret_cast<const double *>(QSysInfo::ByteOrder == QSysInfo::BigEndian ? qt_be_inf_bytes : qt_le_inf_bytes);
}
#define Q_INFINITY (::qtInf())

// Signaling NAN
static const unsigned char qt_be_snan_bytes[] = { 0x7f, 0xf8, 0, 0, 0, 0, 0, 0 };
static const unsigned char qt_le_snan_bytes[] = { 0, 0, 0, 0, 0, 0, 0xf8, 0x7f };
static inline double qtSnan()
{
    return *reinterpret_cast<const double *>(QSysInfo::ByteOrder == QSysInfo::BigEndian ? qt_be_snan_bytes : qt_le_snan_bytes);
}
#define Q_SNAN (::qtSnan())

// Quiet NAN
static const unsigned char qt_be_qnan_bytes[] = { 0xff, 0xf8, 0, 0, 0, 0, 0, 0 };
static const unsigned char qt_le_qnan_bytes[] = { 0, 0, 0, 0, 0, 0, 0xf8, 0xff };
static inline double qtQnan()
{
    return *reinterpret_cast<const double *>(QSysInfo::ByteOrder == QSysInfo::BigEndian ? qt_be_qnan_bytes : qt_le_qnan_bytes);
}
#define Q_QNAN (::qtQnan())

static inline bool qIsInf(double d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) == 0x7f && ch[1] == 0xf0;
    } else {
        return (ch[7] & 0x7f) == 0x7f && ch[6] == 0xf0;
    }
}

static inline bool qIsNan(double d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) == 0x7f && ch[1] > 0xf0;
    } else {
        return (ch[7] & 0x7f) == 0x7f && ch[6] > 0xf0;
    }
}

static inline bool qIsFinite(double d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) != 0x7f || (ch[1] & 0xf0) != 0xf0;
    } else {
        return (ch[7] & 0x7f) != 0x7f || (ch[6] & 0xf0) != 0xf0;
    }
}

static inline bool qIsInf(float d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) == 0x7f && ch[1] == 0x80;
    } else {
        return (ch[3] & 0x7f) == 0x7f && ch[2] == 0x80;
    }
}

static inline bool qIsNan(float d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) == 0x7f && ch[1] > 0x80;
    } else {
        return (ch[3] & 0x7f) == 0x7f && ch[2] > 0x80;
    }
}

static inline bool qIsFinite(float d)
{
    uchar *ch = (uchar *)&d;
    if (QSysInfo::ByteOrder == QSysInfo::BigEndian) {
        return (ch[0] & 0x7f) != 0x7f || (ch[1] & 0x80) != 0x80;
    } else {
        return (ch[3] & 0x7f) != 0x7f || (ch[2] & 0x80) != 0x80;
    }
}

static inline bool qFuzzyCompare(double p1, double p2)
{
    return qAbs(p1 - p2) < 0.00000000001;
}

static inline bool qFuzzyCompare(float p1, float p2)
{
    return qAbs(p1 - p2) < 0.000001;
}

#endif // QNUMERIC_P_H
