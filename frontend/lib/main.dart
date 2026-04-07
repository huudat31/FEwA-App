import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/data/api/auth_api.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthApi(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthApi>()),
        child: MaterialApp(
          title: 'Fewa Mobile App',
          theme: AppTheme.lightTheme,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
