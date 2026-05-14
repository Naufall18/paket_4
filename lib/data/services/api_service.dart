import 'package:flutter/foundation.dart';

class ApiService {
  static const _host = '10.117.90.12'; // Laptop/HP IP for LAN connection

  static String get baseUrl {
    if (kIsWeb) {
      // For Chrome Web on the same machine, use 127.0.0.1
      return 'http://127.0.0.1:8000/api';
    } else {
      // For mobile devices, use the LAN IP
      return 'http://$_host:8000/api';
    }
  }

  static String get storageUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/storage';
    } else {
      return 'http://$_host:8000/storage';
    }
  }
}
