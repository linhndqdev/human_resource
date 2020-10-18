import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';

final maxHeightTitlePopup = 50.0;

TextStyle textStyle = const TextStyle(
  color: const Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);
TextStyle textStyle16Normal = const TextStyle(
  color: const Color(0XFF000000),
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
);
TextStyle textStyleWhite = const TextStyle(
  color: const Color(0XFFFFFFFF),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);
TextStyle text16Black = TextStyle(
  color: blackColor,
  fontSize: 16.0,
);
TextStyle textBoldBlack = const TextStyle(
  color: const Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
);

TextStyle textBoldWhite = const TextStyle(
  color: const Color(0XFFFFFFFF),
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
);

TextStyle textBlackItalic = const TextStyle(
  color: const Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);
TextStyle textBlack15Italic = const TextStyle(
  color: const Color(0XFF000000),
  fontSize: 15.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);
TextStyle textAccent16Italic = const TextStyle(
  fontFamily: "Roboto",
  color: accentColor,
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);
TextStyle textGrey = const TextStyle(
  fontFamily: "Roboto",
  color: Colors.grey,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

TextStyle textGreyBold = const TextStyle(
  color: Colors.grey,
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
);

TextStyle textStyleBlue = const TextStyle(
  color: primaryColor,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

TextStyle textStyleActive = const TextStyle(
  color: const Color(0xFFF44336),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

TextStyle textStyleValidate = const TextStyle(
  color: const Color(0xFFF44336),
  fontSize: 11.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    title: base.title.copyWith(),
  );
}

TextStyle textGreen = const TextStyle(
  color: const Color(0xFF00c497),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

final ThemeData base = ThemeData.light();

ThemeData appTheme = new ThemeData(
  fontFamily: "Roboto",
  primaryColor: primaryColor,
  buttonColor: primaryColor,
  indicatorColor: Colors.white,
  splashColor: Colors.white24,
  splashFactory: InkRipple.splashFactory,
  accentColor: const Color(0xFF13B9FD),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  backgroundColor: Colors.white,
  errorColor: const Color(0xFFB00020),
  highlightColor: activeColor,
  iconTheme: new IconThemeData(color: primaryColor),
  buttonTheme: const ButtonThemeData(
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: _buildTextTheme(base.textTheme),
  primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
  accentTextTheme: _buildTextTheme(base.accentTextTheme),
);

Color textFieldColor = const Color.fromRGBO(168, 160, 149, 0.6);
const fontName = 'Roboto';
// ASG
const Color asgTextColorBlue = Color(0xFF006C99);
const Color asgTextColorYellow = Color(0xFFE4A025);
const Color asgBackgroundColorBlue = Color(0xFF006C99);
const Color asgBackgroundColorWhite = Color(0xFFFFFFFF);
const Color asgAlmostBlack = Color(0xFF0D0E10);
const Color accentColor = Color(0xFF005a88);
const Color blackColor = Color(0xFF333333);
const Color redColor = Color(0xFFe50000);
const Color whiteColor = Color(0xFFffffff);
const Color greyColor = Color(0xFFb1afaf);
const Color color3baae2 = Color(0xFF3baae2);

const Color nearlyDarkBlue = Color(0xFF006C99);
const Color nearlyBlue = Color(0xFF00B6F0);
const Color nearlyBlack = Color(0xFF213333);
const Color grey = Color(0xFF3A5160);
const Color dark_grey = Color(0xFF313A44);
const Color dark_green = Color(0xFF55701A);
const Color darkText = Color(0xFF4E9CCC);
const Color darkerText = Color(0xFF102395);
const Color lightText = Color(0xFF4A6572);
const Color nearlyWhite = Color(0xFFFAFAFA);
const Color white = Color(0xFFFFFFFF);
const Color background = Color(0xFFF2F3F8);
const Color backgroundColor = const Color(0xFFF2F3F8);
const Color greyColor2 = Colors.grey;
const Color activeColor = const Color(0xFFF44336);
const Color buttonStop = const Color(0xFFF44336);
const Color primaryColor = const Color(0xFF236C99);
const Color secondary = const Color(0xFFFF8900);
const Color facebook = const Color(0xFF4267b2);
const Color googlePlus = const Color(0xFFdb4437);
const Color greynew = const Color(0xFFf2f1f1);
const Color yellow = Colors.pinkAccent;
const Color green1 = Colors.lightGreen;
const Color green2 = Colors.green;
const Color blue1 = Colors.lightBlue;
const Color blue2 = Colors.blue;
const Color tim = Colors.deepPurple;
const Color tim2 = Colors.deepPurpleAccent;
const Color blackColor333 = Color(0xFF333333);
const Color colorBD = Color(0xFFbdbdbd);
const Color greenColor = const Color(0xFF00c497);
const Color rgb51 = const Color.fromRGBO(51, 51, 51, 1.0);
const Color rgb97 = const Color.fromRGBO(97, 97, 97, 1.0);
const Color rgb248 = const Color.fromRGBO(248, 249, 249, 1.0);
const Color grey1Color = Color(0xffe8e8e8);
const Color greyDarkColor = Color(0xFF616161);
const Color color959ca7 = Color(0xFF959ca7);
const Color colore10606 = Color(0xFFe10606);
TextStyle textStyleSchedule(BuildContext context) {
  return TextStyle(
      color: Color(0xFF959ca7),
      fontSize: ScreenUtil().setSp(50.0,allowFontScalingSelf: false),
      fontFamily: 'Roboto-Regular');
}

TextStyle text16WhiteBold =
    TextStyle(fontWeight: FontWeight.bold, color: whiteColor, fontSize: 16.0);
TextStyle text14BlackBold =
    TextStyle(fontWeight: FontWeight.bold, color: blackColor, fontSize: 14.0);
TextStyle text12GreyDarkNormal = TextStyle(
  color: greyDarkColor,
  fontSize: 12.0,
);
TextStyle textStyleSmall = const TextStyle(
    color: const Color.fromRGBO(255, 255, 255, 0.8),
    fontSize: 12.0,
    fontWeight: FontWeight.bold);

TextStyle textStyle11Black = new TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 11.0,
);

TextStyle textStyle13AlmostBlack = new TextStyle(
  fontFamily: "Roboto",
  color: asgAlmostBlack,
  fontSize: 13.0,
);

TextStyle textStyle13Grey = new TextStyle(
  fontFamily: "Roboto",
  color: greyColor,
  fontSize: 13.0,
);

TextStyle textStyle13Black = new TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 13.0,
);
TextStyle textStyle14Blue900 = new TextStyle(
  fontFamily: "Roboto",
  color: accentColor,
  fontSize: 14.0,
);
TextStyle textStyle16BlackBold = TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);
TextStyle textStyle18BlackBold = TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);
TextStyle textStyle12Black = TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 12.0,
);
TextStyle textStyle14Black = TextStyle(
  fontFamily: "Roboto",
  color: blackColor,
  fontSize: 14.0,
);
TextStyle text16WhiteNormal = TextStyle(
  fontFamily: "Roboto",
  color: white,
  fontSize: 16.0,
);
//Image miniLogo = new Image(
//    image: new ExactAssetImage("assets/header-logo.png"),
//    height: 28.0,
//    width: 20.0,
//    alignment: FractionalOffset.center);

TextStyle headingWhite = new TextStyle(
  color: Colors.white,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

TextStyle headingWhite18 = new TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
);
TextStyle headingWhite16 = new TextStyle(
  color: Colors.white,
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
);
TextStyle headingWhite14 = new TextStyle(
  color: Colors.white,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);
TextStyle headingRed = new TextStyle(
  color: redColor,
  fontSize: 22.0,
  fontWeight: FontWeight.normal,
);

TextStyle headingGrey = new TextStyle(
  color: Colors.grey,
  fontSize: 22.0,
  fontWeight: FontWeight.normal,
);

TextStyle heading18 = new TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading18Black = new TextStyle(
  color: blackColor,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading18White = new TextStyle(
  color: whiteColor,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading16Black = new TextStyle(
  color: blackColor,
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading10Black = new TextStyle(
  color: blackColor,
  fontSize: 10.0,
  fontWeight: FontWeight.normal,
);

TextStyle heading10Blue = new TextStyle(
  color: asgBackgroundColorBlue,
  fontSize: 10.0,
  fontWeight: FontWeight.w300,
);

TextStyle heading20Black = new TextStyle(
  color: blackColor,
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
);

TextStyle headingBlack = new TextStyle(
  color: blackColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

TextStyle headingPrimaryColor = new TextStyle(
  color: primaryColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

TextStyle headingLogo = new TextStyle(
  color: blackColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading35 = new TextStyle(
  color: Colors.white,
  fontSize: 35.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading35Black = new TextStyle(
    color: blackColor, fontSize: 35.0, fontWeight: FontWeight.bold);

TextStyle heading35Blue = new TextStyle(
    color: nearlyDarkBlue, fontSize: 35.0, fontWeight: FontWeight.bold);

TextStyle heading35Primary = new TextStyle(
  color: primaryColor,
  fontSize: 35.0,
  fontWeight: FontWeight.bold,
);

TextStyle heading35BlackNormal = new TextStyle(
  color: blackColor,
  fontSize: 35.0,
  fontWeight: FontWeight.normal,
);

TextStyle heading18BlackNormal = new TextStyle(
  color: blackColor,
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
);

TextStyle heading18YellowNormal = new TextStyle(
  color: asgTextColorYellow,
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
);
TextStyle textDashboardH1 = const TextStyle(
  color: Color(0xFF3333333),
  fontSize: 25.0,
  fontWeight: FontWeight.w600,
);
TextStyle textDashboardH4 = const TextStyle(
  color: accentColor,
  fontSize: 14.0,
);
TextStyle textDashboardH5 = const TextStyle(
  color: accentColor,
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);
TextStyle text14BlackNormal = TextStyle(
  color: blackColor,
  fontSize: 14.0,
);
TextStyle text14WhiteNormal = TextStyle(
  color: whiteColor,
  fontSize: 14.0,
);
TextStyle text11ColorBDRoboto = TextStyle(
    color: colorBD, fontSize: 11.0, fontFamily: "Roboto-Regular");

ButtonTheme buttonThemeWith(
    {double btnMinWith,
    VoidCallback onClickButton,
    String title,
    Color borderColor,
    Color textColor,
    Color backgroundColor}) {
  return ButtonTheme(
      minWidth: btnMinWith,
      height: 56.0,
      child: RaisedButton(
          onPressed: () {
            onClickButton();
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                  color: borderColor ?? Colors.transparent,
                  width: borderColor != null ? 1.5 : 0.0)),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? blackColor,
                fontSize: 16,
              )),
          color: backgroundColor ?? white));
}

ButtonTheme buttonThemeWithPopup(
    {double btnMinWith,
    VoidCallback onClickButton,
    String title,
    Color borderColor,
    Color textColor,
    Color backgroundColor}) {
  return ButtonTheme(
      minWidth: btnMinWith,
      height: 50.0,
      child: RaisedButton(
          onPressed: () {
            onClickButton();
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
              side: BorderSide(
                  color: borderColor ?? Colors.transparent,
                  width: borderColor != null ? 1.5 : 0.0)),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor ?? blackColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400)),
          color: backgroundColor ?? white));
}

const Color transparentColor = const Color.fromRGBO(0, 0, 0, 0.2);
const Color activeButtonColor = const Color.fromRGBO(43, 194, 137, 50.0);
const Color dangerButtonColor = const Color(0XFFf53a4d);
const Color color75 = Color(0xFF757575);
const Color orangeColor = Color(0xFFee7f2d);

int getColorHexFromStr(String colorStr) {
  colorStr = "FF" + colorStr;
  colorStr = colorStr.replaceAll("#", "");
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("An error occurred when converting a color");
    }
  }
  return val;
}

AppBar customAppbar(
    {@required Color backgroundColor,
    @required String title,
    double elevation = 0.0,
    @required dynamic titleFontSize,
    TextStyle customTextStyle,
    Widget customLeading}) {
  Widget _leading = customLeading != null ? customLeading : Container();
  TextStyle _titleStyle = customTextStyle != null
      ? customTextStyle
      : TextStyle(
          fontFamily: "Roboto-Bold",
          color: Color(0xff3333333),
          fontSize: titleFontSize);
  return AppBar(
    leading: _leading,
    elevation: elevation,
    centerTitle: true,
    title: Text(title, style: _titleStyle),
    backgroundColor: backgroundColor,
  );
}

const SystemUiOverlayStyle statusBarDark = SystemUiOverlayStyle(
    statusBarColor: white,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark);
const SystemUiOverlayStyle statusBarAccent = SystemUiOverlayStyle(
    statusBarColor: accentColor,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light);
const SystemUiOverlayStyle statusBarTransparent = SystemUiOverlayStyle(
    statusBarColor: transparentColor,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light);
const SystemUiOverlayStyle statusLight = SystemUiOverlayStyle(
    statusBarColor: blackColor333,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light);
const MaterialColor whiteMaterialColor = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);
TextStyle text24Black = TextStyle(
  color: blackColor,
  fontSize: 24.0,
);
TextStyle text18Black = TextStyle(
  color: blackColor,
  fontSize: 18.0,
);
TextStyle text24Accent = TextStyle(
  color: accentColor,
  fontSize: 24.0,
);
TextStyle text16Accent = TextStyle(
  color: accentColor,
  fontSize: 16.0,
);

TextStyle textWhiteNormal = TextStyle(color: whiteColor, fontFamily: 'Roboto');
TextStyle text16BlackBold = TextStyle(
    fontWeight: FontWeight.bold,
    color: blackColor,
    fontSize: 16.0,
    fontFamily: "Roboto-Bold");
TextStyle text16BlackMedium = TextStyle(
    fontWeight: FontWeight.bold,
    color: blackColor,
    fontSize: 16.0,
    fontFamily: "Roboto-Regular");
TextStyle text18BlackBold =
    TextStyle(fontWeight: FontWeight.bold, color: blackColor, fontSize: 18.0);
TextStyle text18WhiteBold =
    TextStyle(fontWeight: FontWeight.bold, color: whiteColor, fontSize: 18.0);
TextStyle text13Color75 = TextStyle(color: color75, fontSize: 13.0);
TextStyle text12Color75 = TextStyle(color: color75, fontSize: 12.0);
TextStyle text14BlueBold =
    TextStyle(fontWeight: FontWeight.bold, color: blue2, fontSize: 14.0);
TextStyle text14GreyNormal =
    TextStyle(fontWeight: FontWeight.normal, color: greyColor, fontSize: 14.0);
TextStyle text14ColorBD = TextStyle(color: colorBD, fontSize: 14.0);
TextStyle text14ColorAvenirBook =
    TextStyle(color: colorBD, fontSize: 14.0, fontFamily: "Avenir-Book");
TextStyle text14AvenirBookBold = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
    fontFamily: "Avenir-Book");
TextStyle text13ColorBD = TextStyle(color: colorBD, fontSize: 13.0);

TextStyle textStyle1TroChuyen_Focus = new TextStyle(
  color: Color(0xffffffff),
  fontSize: ScreenUtil().setSp(50.0),
  fontFamily: "Roboto-Bold",
  fontWeight: FontWeight.bold,
);
TextStyle textStyle1TroChuyen_UnFocus = new TextStyle(
  color: Color(0xffe8e8e8),
  fontSize: ScreenUtil().setSp(50.0),
  fontFamily: "Roboto-Regular",
  fontWeight: FontWeight.normal,
);
BoxDecoration boxDecorationTrochuyen_Focus =
    new BoxDecoration(shape: BoxShape.circle, color: Color(0xffe18c12));
BoxDecoration boxDecorationTrochuyen_UnFocus =
    new BoxDecoration(shape: BoxShape.circle, color: Color(0xff005a88));

TextStyle textStyleNewMsg = TextStyle(
    color: Color(0xff005a88),
    fontSize: ScreenUtil().setSp(48),
    fontFamily: "Roboto-Bold");
TextStyle textStyleOldMsg = TextStyle(
    color: Color(0xff333333),
    fontSize: ScreenUtil().setSp(48),
    fontFamily: "Roboto-Regular");
