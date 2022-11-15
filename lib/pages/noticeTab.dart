import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';



void requestUpdate() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print("当前版本值:$version");
    var response = await Dio()
        .get('curl -X GET "http://octdice.hachimen.info:80/dev-api/charsys/client_update/$version');
    print('打印结果:$response');
  } catch (e) {
    print('异常信息:$e');
  }
}