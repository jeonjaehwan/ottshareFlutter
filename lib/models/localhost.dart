import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Localhost {

  static final info = NetworkInfo();

  static Future<String?> getIp() async {
    if (kIsWeb) {
      return '127.0.0.1'; // 웹 환경에서는 localhost IP를 반환
    } else if (Platform.isAndroid || Platform.isIOS) {
      dynamic wifiInfo = await info.getWifiIP();
      return wifiInfo?.toString();
    } else {
      // 다른 플랫폼에 대한 처리가 필요할 수 있습니다.
      return null;
    }
  }

}