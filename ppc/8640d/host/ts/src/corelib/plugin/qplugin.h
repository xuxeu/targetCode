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

#ifndef QPLUGIN_H
#define QPLUGIN_H

#include <QtCore/qobject.h>
#include <QtCore/qpointer.h>

QT_MODULE(Core)

#ifndef Q_EXTERN_C
#  ifdef __cplusplus
#    define Q_EXTERN_C extern "C"
#  else
#    define Q_EXTERN_C extern
#  endif
#endif

typedef QObject *(*QtPluginInstanceFunction)();

#define Q_IMPORT_PLUGIN(PLUGIN) \
        class Static##PLUGIN##PluginInstance{ \
        public: \
                Static##PLUGIN##PluginInstance() {                      \
                extern void qRegisterStaticPluginInstanceFunction(QtPluginInstanceFunction); \
                extern QObject *qt_plugin_instance_##PLUGIN(); \
                qRegisterStaticPluginInstanceFunction(qt_plugin_instance_##PLUGIN); \
                } \
        }; \
       static Static##PLUGIN##PluginInstance static##PLUGIN##Instance;

#define Q_PLUGIN_INSTANCE(IMPLEMENTATION) \
        { \
            static QPointer<IMPLEMENTATION> _instance; \
            if (!_instance)      \
                _instance = new IMPLEMENTATION; \
            return _instance; \
        }

#if defined(QT_STATICPLUGIN)
#  define Q_EXPORT_PLUGIN(PLUGIN) \
            Q_DECL_EXPORT QObject *qt_plugin_instance_##PLUGIN() \
            Q_PLUGIN_INSTANCE(PLUGIN)

#  define Q_EXPORT_STATIC_PLUGIN(PLUGIN) \
            Q_EXPORT_PLUGIN(PLUGIN)

#else
// NOTE: if you change pattern, you MUST change the pattern in
// qlibrary.cpp as well.  changing the pattern will break all
// backwards compatibility as well (no old plugins will be loaded).
#  ifdef QPLUGIN_DEBUG_STR
#    undef QPLUGIN_DEBUG_STR
#  endif
#  ifdef QT_NO_DEBUG
#    define QPLUGIN_DEBUG_STR "false"
#  else
#    define QPLUGIN_DEBUG_STR "true"
#  endif
#  define Q_PLUGIN_VERIFICATION_DATA \
    static const char *qt_plugin_verification_data = \
      "pattern=""QT_PLUGIN_VERIFICATION_DATA""\n" \
      "version="QT_VERSION_STR"\n" \
      "debug="QPLUGIN_DEBUG_STR"\n" \
      "buildkey="QT_BUILD_KEY"\0";

#  if defined (Q_OS_WIN32) && defined(Q_CC_BOR)
#     define Q_STANDARD_CALL __stdcall
#  else
#     define Q_STANDARD_CALL
#  endif

#  define Q_EXPORT_PLUGIN(PLUGIN)      \
            Q_PLUGIN_VERIFICATION_DATA \
            Q_EXTERN_C Q_DECL_EXPORT \
            const char * Q_STANDARD_CALL qt_plugin_query_verification_data() \
            { return qt_plugin_verification_data; } \
            Q_EXTERN_C Q_DECL_EXPORT QObject * Q_STANDARD_CALL qt_plugin_instance() \
            Q_PLUGIN_INSTANCE(PLUGIN)

#  define Q_EXPORT_STATIC_PLUGIN(PLUGIN) \
            Q_DECL_EXPORT QObject *qt_plugin_instance_##PLUGIN() \
            Q_PLUGIN_INSTANCE(PLUGIN)

#endif

#endif // Q_PLUGIN_H
