import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/main.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectDialog extends StatefulWidget {
  const SelectDialog({Key key}) : super(key: key);

  @override
  _SelectDialogState createState() => _SelectDialogState();
}

class _SelectDialogState extends State<SelectDialog> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Center(child: Text(
          AppLocalizations.of(context).addPosition,
          textAlign: TextAlign.center,
          textScaleFactor: 1.5,
        )),
      ) ,
      onTap: (){
        AddPositionDialog(context);
      },
    );
  }

  void AddPositionDialog(context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('選択してください'),
        // message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).top + AppLocalizations.of(context).changeTo),
            onPressed: () {
              SharedPrefs.setAdPositionTop(true);
              Navigator.pop(context);
              RestartWidget.restartApp(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).bottom + AppLocalizations.of(context).changeTo),
            onPressed: () {
              SharedPrefs.setAdPositionTop(false);
              Navigator.pop(context);
              RestartWidget.restartApp(context);
            },
          )
        ],
      ),
    );
  }
}
