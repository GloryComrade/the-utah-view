// The Google-rendered sign-in button, web only. On other platforms the stub
// returns an empty box (mobile uses AuthController.signIn instead).
export 'google_signin_button_stub.dart'
    if (dart.library.html) 'google_signin_button_web.dart';
