import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart' show App;

class PreviewDialog {
  static Future<void> _show({
    required BuildContext context,
    String? title,
    String? content,
    required List<Widget> actions,
    Color? backgroundColor,
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: backgroundColor ?? Colors.white,
          title: title == null
            ?
          null
            :
          Text(
            title,
            style: TextStyle(
              fontSize: App.sizeConvert(context,20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: content == null
            ?
          null
            :
          Text(
            content,
            style: TextStyle(
              fontSize: App.sizeConvert(context,20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          actions: actions,
        );
      },
    );
  }

  static Future<void> reviewCount(BuildContext context) async {
    SharedPrefs.setLoginCount(SharedPrefs.getLoginCount() + 1);
    final InAppReview inAppReview = InAppReview.instance;

    // スキップ後の冷却期間（例：30日）
    final skipDays = 15;
    final lastSkipStr = SharedPrefs.getReviewSkipTime();
    if (lastSkipStr.isNotEmpty) {
      final lastSkip = DateTime.parse(lastSkipStr);
      if (DateTime.now().difference(lastSkip).inDays < skipDays) return;
    }

    if (SharedPrefs.getLoginCount() % 10 == 0) {
      // レビューができない状態なら何もしない
      if (!(await inAppReview.isAvailable())) return;

      TextStyle btnTextStyle = TextStyle(fontSize: App.sizeConvert(context,24), color: Colors.black);

      ButtonStyle buttonStyle = ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
        ),
      );

      await _show(
        context: context,
        content: "このアプリは満足していますか？",
        actions: <Widget>[
          ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              SharedPrefs.setReviewSkipTime(DateTime.now().toIso8601String());
              Navigator.pop(context);
              _show(
                context: context,
                title: 'フィードバック',
                content: "お問い合わせフォームは外部ページの下部にあります。\nこのまま移動してもよろしいですか？",
                actions: [
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () => Navigator.pop(context),
                    child: Text("いいえ", style: btnTextStyle,),
                  ),
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      Navigator.pop(context);
                      _openContactForm();
                    },
                    child: Text("はい", style: btnTextStyle,),
                  ),
                ],
              );
            },
            child: Text("いいえ", style: btnTextStyle,),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              Navigator.pop(context);
              inAppReview.requestReview();
            },
            child: Text("はい", style: btnTextStyle,),
          ),
        ],
      );
    }
  }

  static void _openContactForm() async {
    final Uri url = Uri.parse('https://peraichi.com/landing_pages/view/k-kura'); // ← ここに自前のURLを指定

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // エラー処理
      print('Webフォームを開けませんでした');
    }
  }
}
