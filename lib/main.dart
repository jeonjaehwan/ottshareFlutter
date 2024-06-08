import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:ott_share/screen/EditProfilePage.dart';
import 'package:ott_share/screen/FindIdAndPassword.dart';
import 'package:ott_share/screen/Login.dart';
import 'package:ott_share/screen/OTTInfoPage.dart';
import 'package:ott_share/screen/SignUp.dart';
import 'package:ott_share/screen/autoMatching.dart';
import 'package:ott_share/chatting/chatRoomPage.dart';
import 'package:ott_share/screen/ottRecommendation.dart';
import 'package:ott_share/models/loginStorage.dart';
import 'package:ott_share/screen/myPage.dart';

import 'package:http/http.dart' as http;

import 'api/google_signin_api.dart';
import 'chatting/chatRoom.dart';
import 'models/userInfo.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


// Future<void> backgroundHandler(RemoteMessage message) async {
//   debugPrint('fcm backgroundHandler, message');
//
//   debugPrint(message.notification?.title ?? '');
//   debugPrint(message.notification?.body ?? '');
// }

// Future<void> setFCM() async {
//
//   //백그라운드 메세지 핸들링(수신처리)
//   FirebaseMessaging.onBackgroundMessage(backgroundHandler);
// }
//
// void initializeNotification() async {
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // name
//     importance: Importance.high,
//     description: 'This channel is used for important notifications.',
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await flutterLocalNotificationsPlugin.initialize(
//     const InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     ),
//   );
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'b8d545024ec99b8ad44c04b522cab54f',
    javaScriptAppKey: 'a883fcabacb6ce410161d059b4dd1e75',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // initializeNotification();
  await LoginStorage.init();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OTT 공유 앱',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // 전체 앱의 배경색을 흰색으로 설정
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff1C1C1C)),
          ),

        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black54,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentTextStyle: TextStyle(
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
      ),
      routerConfig: GoRouter(initialLocation: "/", routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => HomePage(),
        ),
        GoRoute(path: "/signUp", builder: (context, state) => SignUpPage()),
        GoRoute(path: "/users/login", builder: (context, state) => LoginPage()),
        GoRoute(
            path: "/findIdAndPassword",
            builder: (context, state) {
              int index = state.extra as int;
              return FindIdAndPasswordPage(index: index);
            }),
        GoRoute(
            path: "/autoMatching",
            builder: (context, state) {
              return HomePage(selectedIndex: 0);
            }),
        GoRoute(
            path: "/home",
            builder: (context, state) {
              bool isLoggedIn =
                  bool.parse(state.uri.queryParameters['isLoggedIn']!);
              UserInfo userInfo = state.extra as UserInfo;
              return HomePage(isLoggedIn: isLoggedIn, userInfo: userInfo, selectedIndex: 2,);
            }),
        GoRoute(
            path: "/afterDeleteUser",
            builder: (context, state) {
              return HomePage(isLoggedIn: false, selectedIndex: 2, userInfo: null);
            }),
        GoRoute(
            path: "/ottInfo",
            builder: (context, state) {
              int selectedOttIndex =
                  int.parse(state.uri.queryParameters['selectedOttIndex']!);
              bool isLeader =
                  bool.parse(state.uri.queryParameters['isLeader']!);
              UserInfo userInfo = state.extra as UserInfo;
              return OTTInfoPage(
                  selectedOttIndex: selectedOttIndex,
                  isLeader: isLeader,
                  userInfo: userInfo);
            }),
        GoRoute(
            path: "/chatRoom",
            builder: (context, state) {
              ChatRoom chatRoom = state.extra as ChatRoom;
              return ChatRoomPage(chatRoom: chatRoom);
            }),
        GoRoute(
            path: "/editProfile",
            builder: (context, state) {
              UserInfo userInfo = state.extra as UserInfo;
              return EditProfilePage(userInfo: userInfo);
            }),
      ]),
    );
  }
}

class HomePage extends StatefulWidget {
  final UserInfo? userInfo;
  final int? selectedIndex;
  final bool? isLoggedIn; // 로그인 상태

  HomePage({Key? key, this.userInfo, this.selectedIndex, this.isLoggedIn})
      : super(key: key);

  @override
  State<HomePage> createState() =>
      _HomePageState(userInfo: userInfo, isLoggedIn: isLoggedIn, selectedIndex: selectedIndex);
}

class _HomePageState extends State<HomePage> {
  late UserInfo? userInfo;
  late bool? isLoggedIn;
  late int _selectedIndex;

  _HomePageState({this.userInfo, this.isLoggedIn, int? selectedIndex})
      : _selectedIndex = selectedIndex ?? 0;


  // var messageString = "";
  // void getMyDeviceToken() async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   print("내 디바이스 토큰: $token");
  // }


  @override
  void initState() {
    // getMyDeviceToken();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   RemoteNotification? notification = message.notification;
    //
    //   if (notification != null) {
    //     FlutterLocalNotificationsPlugin().show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       const NotificationDetails(
    //
    //         android: AndroidNotificationDetails(
    //           'high_importance_channel',
    //           'high_importance_notification',
    //           importance: Importance.max,
    //         ),
    //       ),
    //     );
    //     setState(() {
    //       messageString = message.notification!.body!;
    //       print("Foreground 메시지 수신: $messageString");
    //     });
    //   }
    // });
    super.initState();
    userInfo = widget.userInfo; // null일 수 있음
    isLoggedIn = widget.isLoggedIn ?? false;
    _selectedIndex = widget.selectedIndex ?? 0;


  }


  void _onItemTapped(int index) async {
    // '로그인/로그아웃' 버튼을 탭했을 때의 로직
    if (index == 2) {
      // 로그인/로그아웃 탭 인덱스, 필요에 따라 조정하세요.
      if (isLoggedIn == false) {
        // 로그인 페이지로 이동하고 결과를 기다립니다.
        context.push('/users/login').then((result) {
          // 로그인 페이지에서 반환된 결과를 기반으로 상태를 업데이트합니다.
          setState(() {
            // _selectedIndex = 0;
            context.pushReplacement("/autoMatching?selectedIndex=0");
          });
          // if (result is Map<String, dynamic>) {
          //   setState(() {
          //     isLoggedIn = bool.parse(result['isLoggedIn']) ?? false;
          //     userInfo = result['userInfo'] as UserInfo?;
          //   });
          // }
        });
      } else {
        // 마이페이지 이동 로직
        setState(() {
          _selectedIndex = index;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }


  // 메인 위젯
  @override
  Widget build(BuildContext context) {
    String titleText = '';

    switch (_selectedIndex) {
      case 0:
        titleText = 'OTT 공유';
      case 1:
        titleText = 'OTT 추천';
      case 2:
        titleText = '마이페이지';
    }

    List<BottomNavigationBarItem> bottomItems = [
      BottomNavigationBarItem(icon: Icon(Icons.share), label: '자동매칭'),
      BottomNavigationBarItem(icon: Icon(Icons.movie_filter), label: 'OTT 추천'),
      BottomNavigationBarItem(
          icon: isLoggedIn == true ? Icon(Icons.person) : Icon(Icons.login),
          label: isLoggedIn == true ? '마이페이지' : '로그인'),
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(titleText),
          backgroundColor: Color(0xffffdf24),
          elevation: 0,
          shadowColor: Color(0xffffdf24),
          surfaceTintColor: Color(0xffffdf24),
          centerTitle: true,
        ),
        body: SafeArea(
          child: <Widget>[
            AutoMatchingPage(userInfo: widget.userInfo),
            OttRecommendationPage(),
            MyPage(userInfo: widget.userInfo, selectedIndex: 2),
          ].elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            canvasColor: Colors.white
          ),
          child: BottomNavigationBar(
            items: bottomItems,
            // elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xffffdf24),
            unselectedItemColor: Colors.black26,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: _onItemTapped,
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
