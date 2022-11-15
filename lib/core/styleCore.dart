part of neko;


TextStyle nekoFontContentBold = const TextStyle(
    fontFamily: "思源黑体",
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 2);
TextStyle nekoFontContent =
    const TextStyle(fontFamily: "思源黑体", fontSize: 12, letterSpacing: 2);



TextStyle button =
    const TextStyle(fontFamily: '思源黑体', fontSize: 20.0, letterSpacing: 3);

TextStyle brief =
    const TextStyle(fontFamily: '思源黑体', fontSize: 16.0, letterSpacing: 1);

ButtonStyle tranStyle = ButtonStyle(
    elevation: ButtonState.all(0),
    shadowColor: ButtonState.all(Colors.transparent),
    foregroundColor: ButtonState.resolveWith((states) {
      return Colors.black;
    }),
    backgroundColor: ButtonState.all(Colors.transparent),
    border:
        ButtonState.all(const BorderSide(color: Colors.transparent, width: 0)),
    shape: ButtonState.all(const RoundedRectangleBorder(side: BorderSide.none)),
    padding: ButtonState.all(const EdgeInsets.all(0)));

ButtonStyle floatStyle = ButtonStyle(
    padding: ButtonState.all(const EdgeInsets.only(bottom: 5)),
    //圆角
    shape: ButtonState.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    //边框
    border: ButtonState.all(
      const BorderSide(color: Colors.grey, width: 1),
    ),
    //背景
    backgroundColor: ButtonState.all(Colors.white));

ButtonStyle tranStyle1 = ButtonStyle(
    elevation: ButtonState.all(0),
    shadowColor: ButtonState.all(Colors.transparent),
    border: ButtonState.all(BorderSide.none),
    foregroundColor: ButtonState.resolveWith((states) {
      return Colors.black;
    }),
    backgroundColor: ButtonState.all(Colors.transparent),
    shape: ButtonState.all(const RoundedRectangleBorder(side: BorderSide.none)),
    padding: ButtonState.all(const EdgeInsets.all(0)));

class NekoText {
  static TextStyle nromalContent = const TextStyle(
      fontFamily: "思源黑体", fontSize: 12, letterSpacing: 1, height: 1.5,fontWeight:FontWeight.w400);
  static TextStyle topContent = const TextStyle(
      fontFamily: "思源黑体", fontSize: 12, fontWeight: FontWeight.bold,letterSpacing: 1.5);
  static TextStyle  nromalTitle = const TextStyle(
      fontFamily: '思源黑体',
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 5);
  static TextStyle topTitle = const TextStyle(
      fontFamily: "思源黑体",
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 2);

}