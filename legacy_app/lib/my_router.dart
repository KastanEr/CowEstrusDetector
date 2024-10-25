import 'package:estrus_detector/alarm_page.dart';
import 'package:estrus_detector/history_detail_page.dart';
import 'package:estrus_detector/history_page.dart';
import 'package:estrus_detector/register_page.dart';
import 'package:estrus_detector/statistics_page.dart';
import 'package:go_router/go_router.dart';
import 'home_page.dart';
import 'login_page.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => MyLoginPage(),
    routes: [
      GoRoute(
        path: 'register',
        builder: (context, state) => MyRegisterPage(),
      ),
    ],
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => MyHomePage(),
  ),
  GoRoute(
    path: '/alarm',
    builder: (context, state) => MyAlarmPage(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => const MyHistoryPage(),
    routes: [
      GoRoute(
        path: 'history_detail',
        builder: (context, state) => MyHistoryDetailPage(detail: state.extra as Map),
      ),
    ],
  ),
  GoRoute(
    path: '/statistics',
    builder: (context, state) => const MyStatisticsPage(),
  ),
]);
