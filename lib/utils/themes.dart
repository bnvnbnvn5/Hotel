import 'package:flutter/material.dart';
import 'package:myapp/utils/enum.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/motel_app.dart';
import 'package:provider/provider.dart';

class AppTheme {
static bool get isLightMode {
return applicationcontext == null
? true
    : applicationcontext!.read<ThemeProvider>().isLightMode;
}

static Color get primaryColor {
ColorType _colortypedata = applicationcontext == null
? ColorType.Verdigris
    : applicationcontext!.read<ThemeProvider>().colorType;

return getColor(_colortypedata);
}

static Color get scaffoldBackgroundColor =>
isLightMode ? Color(0xFFFFFFFF) : Color(0xFF2C2C2C); // Từ backgroundColor của bản cũ

static Color get redErrorColor =>
isLightMode ? Color(0xFFAC0000) : Color(0xFFAC0000); // Giữ nguyên từ bản cũ

static Color get primaryTextColor =>
isLightMode ? Color(0xFF262626) : Color(0xFFFFFFFF); // Giữ nguyên từ bản cũ

static Color get secondaryTextColor =>
isLightMode ? Color(0xFFADADAD) : Color(0xFF6D6D6D); // Giữ nguyên từ bản cũ

static Color get whiteColor => Color(0xFFFFFFFF); // Giữ nguyên từ bản cũ

static Color get backColor => Color(0xFF262626); // Giữ nguyên từ bản cũ

static Color get fontcolor =>
isLightMode ? Color(0xFF1A1A1A) : Color(0xFFF7F7F7); // Giữ nguyên từ bản cũ

static ThemeData get getThemeData =>
isLightMode ? _buildLightTheme() : _buildDarkTheme();

static TextTheme _buildTextTheme(TextTheme base) {
FontFamilyType _fontType = applicationcontext == null
? FontFamilyType.WorkSans
    : applicationcontext!.read<ThemeProvider>().fontType;

return base.copyWith(
displayLarge: getTextStyle(_fontType, base.displayLarge!),
displayMedium: getTextStyle(_fontType, base.displayMedium!),
displaySmall: getTextStyle(_fontType, base.displaySmall!),
headlineMedium: getTextStyle(_fontType, base.headlineMedium!),
headlineSmall: getTextStyle(_fontType, base.headlineSmall!),
titleLarge: getTextStyle(
_fontType,
base.titleLarge!.copyWith(fontWeight: FontWeight.bold),
),
titleMedium: getTextStyle(_fontType, base.titleMedium!),
titleSmall: getTextStyle(_fontType, base.titleSmall!),
bodyLarge: getTextStyle(_fontType, base.bodyLarge!),
bodyMedium: getTextStyle(_fontType, base.bodyMedium!),
bodySmall: getTextStyle(_fontType, base.bodySmall!),
labelLarge: getTextStyle(_fontType, base.labelLarge!),
labelSmall: getTextStyle(_fontType, base.labelSmall!),
);
}

static Color getColor(ColorType _colordata) {
switch (_colordata) {
case ColorType.Verdigris:
return Color(0xFF4FBE9F);
case ColorType.Malibu:
return Color(0xFF5DCAEC);
case ColorType.DarkSkyBlue:
return Color(0xFF458CEA);
case ColorType.BilobaFlower:
return Color(0xFFff5f5f); // Khớp với bản cũ
}
}

static TextStyle getTextStyle(
FontFamilyType _fontFamilyType, TextStyle textStyle) {
switch (_fontFamilyType) {
case FontFamilyType.Montserrat:
return GoogleFonts.montserrat(textStyle: textStyle);
case FontFamilyType.WorkSans:
return GoogleFonts.workSans(textStyle: textStyle);
case FontFamilyType.Varela:
return GoogleFonts.varela(textStyle: textStyle);
case FontFamilyType.Satisfy:
return GoogleFonts.satisfy(textStyle: textStyle);
case FontFamilyType.DancingScript:
return GoogleFonts.dancingScript(textStyle: textStyle);
case FontFamilyType.KaushanScript:
return GoogleFonts.kaushanScript(textStyle: textStyle);
default:
return GoogleFonts.roboto(textStyle: textStyle);
}
}

static ThemeData _buildLightTheme() {
final ColorScheme colorScheme = const ColorScheme.light().copyWith(
primary: primaryColor,
secondary: primaryColor,
);
final ThemeData base = ThemeData.light();

return base.copyWith(
colorScheme: colorScheme,
primaryColor: primaryColor,
scaffoldBackgroundColor: scaffoldBackgroundColor,
canvasColor: scaffoldBackgroundColor,
buttonTheme: _buttonThemeData(colorScheme),
dialogTheme: _dialogTheme(),
cardTheme: _cardTheme(),
textTheme: _buildTextTheme(base.textTheme),
primaryTextTheme: _buildTextTheme(base.textTheme),
platform: TargetPlatform.iOS,
visualDensity: VisualDensity.adaptivePlatformDensity,
useMaterial3: true,
);
}

static ThemeData _buildDarkTheme() {
final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
primary: primaryColor,
secondary: primaryColor,
);
final ThemeData base = ThemeData.dark();

return base.copyWith(
colorScheme: colorScheme,
primaryColor: primaryColor,
scaffoldBackgroundColor: scaffoldBackgroundColor,
canvasColor: scaffoldBackgroundColor,
buttonTheme: _buttonThemeData(colorScheme),
dialogTheme: _dialogTheme(),
cardTheme: _cardTheme(),
textTheme: _buildTextTheme(base.textTheme),
primaryTextTheme: _buildTextTheme(base.textTheme),
platform: TargetPlatform.iOS,
visualDensity: VisualDensity.adaptivePlatformDensity,
useMaterial3: true,
);
}

static ButtonThemeData _buttonThemeData(ColorScheme colorScheme) {
return ButtonThemeData(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8.0),
),
colorScheme: colorScheme,
textTheme: ButtonTextTheme.primary,
);
}

static DialogThemeData _dialogTheme() {
return DialogThemeData(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8.0),
),
elevation: 0,
);
}

static CardThemeData _cardTheme() {
return CardThemeData(
clipBehavior: Clip.antiAlias,
color: scaffoldBackgroundColor,
shadowColor: secondaryTextColor.withOpacity(0.2),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8.0),
),
elevation: 8,
margin: const EdgeInsets.all(0),
);
}

static get mapCardDecoration => BoxDecoration(
color: AppTheme.scaffoldBackgroundColor,
borderRadius: BorderRadius.all(Radius.circular(24.0)),
boxShadow: <BoxShadow>[
BoxShadow(
color: Theme.of(applicationcontext!).dividerColor,
offset: Offset(4, 4),
blurRadius: 8.0),
],
);

static get buttonDecoration => BoxDecoration(
color: AppTheme.primaryColor,
borderRadius: BorderRadius.all(Radius.circular(24.0)),
boxShadow: <BoxShadow>[
BoxShadow(
color: Theme.of(applicationcontext!).dividerColor,
blurRadius: 8,
offset: Offset(4, 4),
),
],
);

static get searchBarDecoration => BoxDecoration(
color: AppTheme.scaffoldBackgroundColor,
borderRadius: BorderRadius.all(Radius.circular(38)),
boxShadow: <BoxShadow>[
BoxShadow(
color: Theme.of(applicationcontext!).dividerColor,
blurRadius: 8,
),
],
);

static get boxDecoration => BoxDecoration(
color: AppTheme.scaffoldBackgroundColor,
borderRadius: BorderRadius.all(Radius.circular(16.0)),
boxShadow: <BoxShadow>[
BoxShadow(
color: Theme.of(applicationcontext!).dividerColor,
blurRadius: 8,
),
],
);
}

enum ThemeModeType {
system,
dark,
light,
}
