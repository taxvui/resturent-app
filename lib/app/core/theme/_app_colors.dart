import 'dart:ui';

abstract class DAppColors {
  static const kPrimary = Color(0xffFC8019);
  static const kOnPrimary = Color(0xffFFFFFF);

  static const kSecondary = Color(0xff7B787B);
  static const kOnSecondary = Color(0xffFFFFFF);

  static const kSurfaceLight = Color(0xffF8F8F8);
  static const kOnSurfaceLight = Color(0xff1F1F1F);

  static const kPrimaryContainerLight = Color(0xffFFFFFF);
  static const kOnPrimaryContainerLight = Color(0xff1F1F1F);

  static const kBorder = Color(0xff7E7E7E);

  static const kWarning = Color(0xffFF900C);
  static const kInfo = Color(0xff2400FF);
  static const kSuccess = Color(0xff00B243);
  static const kError = Color(0xffF23B3D);

  static const kExtraColors = (
    paragraphLight: Color(0xff5B5B5B),
    paragraphDark: Color(0xffFFFFFF),
  );
}
