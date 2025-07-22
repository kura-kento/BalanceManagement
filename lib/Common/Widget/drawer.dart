import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../shared_prefs.dart';


class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  TextEditingController controller = TextEditingController(text: SharedPrefs.getMemo());

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Drawer(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: App.isSmall(context) ? 46 : 55,
              child: DrawerHeader(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor,),
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(0.0),
                  child: const Center(
                    child: Text('メモ',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
              ),
            ),
            SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomSpace),
                child: Container(
                  margin: EdgeInsets.all(4),
                  height: MediaQuery.of(context).size.height - 100,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                    // borderRadius: BorderRadius.only(bottomRight: Radius.circular(100),)
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(fontSize: 18),
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'メモ',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    ),
                    onChanged: (string) {
                      SharedPrefs.setMemo(string);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
