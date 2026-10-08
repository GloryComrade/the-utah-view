import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:material_ui/material_ui.dart';

/// The official Google button (GIS). Requires GoogleSignIn.initialize to have
/// run first (AuthController does this). [compact] renders a small icon button
/// for tight spots like the masthead corner.
Widget googleSignInButton({bool compact = false}) => web.renderButton(
  configuration: compact
      ? web.GSIButtonConfiguration(
          type: web.GSIButtonType.icon,
          shape: web.GSIButtonShape.pill,
          size: web.GSIButtonSize.large,
        )
      : null,
);
