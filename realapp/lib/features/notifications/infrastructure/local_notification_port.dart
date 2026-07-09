export 'local_notification_port_io.dart'
    if (dart.library.html) 'local_notification_port_web.dart'
    if (dart.library.js_interop) 'local_notification_port_web.dart';
