import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:labour_party/routes/app_router.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:labour_party/core/database/hive_setup.dart';
import 'package:labour_party/config/di/injection_container.dart' as di;
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveSetup.init();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [BlocProvider(create: (_) => di.sl<WorkBloc>())],
          child: MaterialApp.router(
            title: 'Labour Party',
            theme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
