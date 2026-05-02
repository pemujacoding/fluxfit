import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/game_page.dart';
import 'pages/kesan_pesan_page.dart';
import 'pages/profile_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/game', builder: (_, __) => const GamePage()),
        GoRoute(path: '/kesan', builder: (_, __) => const KesanPesanPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
  ],
);
