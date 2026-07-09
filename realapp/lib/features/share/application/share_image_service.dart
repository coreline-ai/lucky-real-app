export 'share_image_service_io.dart'
    if (dart.library.html) 'share_image_service_web.dart'
    if (dart.library.js_interop) 'share_image_service_web.dart';
