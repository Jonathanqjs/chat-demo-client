import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class Request {
  late Dio dio;
  late PersistCookieJar cookieJar;
  static final Request _instance = Request._internal();
  factory Request() {
    return _instance;
  }
  final String baseUrl = 'http://localhost:3000';

  Request._internal();

  Future<void> initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiePath = '${appDocDir.path}/.cookies/';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 1),
      headers: {
        'api': '1.0.0',
      },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
    cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  getCookies() async {
    return await cookieJar.loadForRequest(Uri.parse(baseUrl));
  }

  // 获取特定 Cookie 的值
  Future<String?> getToken() async {
    var cookies = await getCookies();
    for (var cookie in cookies) {
      if (cookie.name == 'token') {
        return cookie.value;
      }
    }
    return null;
  }

  login({username, password}) async {
    var res = await dio.post('/user/login',
        data: {'userName': username, 'password': password});
    return res;
  }

  isLogin() async {
    var res = await dio.post('/user/isLogin');
    return res;
  }

  logout() async {
    var res = await dio.post('/user/logout');
    return res;
  }

  fetchFriendList() async {
    var res = await dio.post('/friends/fetch');
    return res;
  }

  addFriend({friendName}) async {
    var res = await dio.post('/friends/add', data: {friendName});
    return res;
  }
}

// final Request = _Request();
