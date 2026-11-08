import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The native configuration files hold the project, so no options are passed:
  // android/app/google-services.json and ios/Runner/GoogleService-Info.plist.
  await Firebase.initializeApp();
  await configureDependencies();
  runApp(const DaliAlshamApp());
}
