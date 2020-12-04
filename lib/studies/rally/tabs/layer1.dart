// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';

import 'package:myapp/l10n/gallery_localizations.dart';
import 'package:myapp/studies/rally/charts/pie_chart.dart';
import 'package:myapp/studies/rally/data.dart';
import 'package:myapp/studies/rally/finance.dart';
import 'package:myapp/studies/rally/tabs/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Layer1View extends StatefulWidget {

  @override
  _Layer1ViewState createState() => _Layer1ViewState();
}
/// A page that shows a summary of accounts.
class _Layer1ViewState extends State<Layer1View> {
  String address = '0x0000000000000000000000000000000000000000'; 
  List<AccountData> layer1AccountDataList = List<AccountData>();

  void initState() {
    SharedPreferences.getInstance().then((prefs) => {
      setState(() {
        address = prefs.getString('address');
        DataService().getLayer1AccountDataList(context, address).then((dataList) => {
          setState(() {
              layer1AccountDataList = dataList;
          })
        });
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final items = DummyDataService.getAccountDataList(context);
    // final items = DummyDataService.getLayer1AccountDataList(context);
    final detailItems = DummyDataService.getAccountDetailList(context);
    final balanceTotal = sumAccountDataPrimaryAmount(layer1AccountDataList);

    return TabWithSidebar(
      mainView: FinancialEntityView(
        heroLabel: GalleryLocalizations.of(context).rallyAccountTotal,
        heroAmount: balanceTotal,
        segments: buildSegmentsFromLayer1Items(layer1AccountDataList),
        wholeAmount: balanceTotal,
        financialEntityCards: buildAccountDataListViews(layer1AccountDataList, context),
      ),
      sidebarItems: [
        for (UserDetailData item in detailItems)
          SidebarItem(title: item.title, value: item.value)
      ],
    );
  }
}
