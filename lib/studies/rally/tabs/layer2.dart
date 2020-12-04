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

class Layer2View extends StatefulWidget {

  @override
  _Layer2ViewState createState() => _Layer2ViewState();
}
/// A page that shows a summary of accounts.
class _Layer2ViewState extends State<Layer2View> {
  String address = '0x0000000000000000000000000000000000000000'; 
  List<AccountData> arbAccountDataList = List<AccountData>();

  void initState() {
    SharedPreferences.getInstance().then((prefs) => {
      setState(() {
        address = prefs.getString('address');
        DataService().getArbAccountDataList(context, address).then((dataList) => {
          setState(() {
              arbAccountDataList = dataList;
          })
        });
      })
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // final items = DummyDataService.getAccountDataList(context);
    // final items = DummyDataService.getLayer2AccountDataList(context);
    final detailItems = DummyDataService.getAccountDetailList(context);
    final balanceTotal = sumAccountDataPrimaryAmount(arbAccountDataList);

    return TabWithSidebar(
      mainView: FinancialEntityView(
        heroLabel: GalleryLocalizations.of(context).rallyAccountTotal,
        heroAmount: balanceTotal,
        segments: buildSegmentsFromLayer1Items(arbAccountDataList),
        wholeAmount: balanceTotal,
        financialEntityCards: buildAccountDataListViews(arbAccountDataList, context),
      ),
      sidebarItems: [
        for (UserDetailData item in detailItems)
          SidebarItem(title: item.title, value: item.value)
      ],
    );
  }
}
