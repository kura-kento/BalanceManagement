import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob.dart';

class BannerBody extends StatefulWidget {
  BannerBody({Key? key, required Widget this.child}) : super(key: key);
  Widget child;
  @override
  State<BannerBody> createState() => _BannerBodyState();
}

class _BannerBodyState extends State<BannerBody> {
  final BannerAd myBanner = AdMob.admobBanner();

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdMob.isNoAds() == false) {
      myBanner.load();
    }
    List<Widget> _list = <Widget>[AdMob.adContainer(myBanner), Expanded(child: widget.child)];

    return Column(
        children:
        SharedPrefs.getAdPositionTop()
            ?
        _list
            :
        List.from(_list.reversed)
    );
  }
}
