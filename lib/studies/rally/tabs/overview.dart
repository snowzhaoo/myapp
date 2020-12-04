// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myapp/data/gallery_options.dart';

import 'package:myapp/l10n/gallery_localizations.dart';
import 'package:myapp/layout/adaptive.dart';
import 'package:myapp/layout/text_scale.dart';
import 'package:myapp/studies/rally/colors.dart';
import 'package:myapp/studies/rally/data.dart';
import 'package:myapp/studies/rally/finance.dart';
import 'package:myapp/studies/rally/formatters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
var apiUrl = "https://kovan.infura.io/v3/75dc3f9d1177434f8aa08cd5fa70919e";
var httpClient = new Client();
var ethClient = new Web3Client(apiUrl, httpClient);
/// A page that shows a status overview.
class OverviewView extends StatefulWidget {

  @override
  _OverviewViewState createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  String address = '0x0000000000000000000000000000000000000000'; 
  List<AccountData> layer1AccountDataList = List<AccountData>();
  List<AccountData> arbAccountDataList = List<AccountData>();

  void initState() {
    SharedPreferences.getInstance().then((prefs) => {
      setState(() {
        address = prefs.getString('address');
        DataService().getLayer1AccountDataList(context, address).then((dataList) => {
          setState(() {
              layer1AccountDataList = dataList;
          })
        });
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
    final alerts = DummyDataService.getAlerts(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            _AlertsView(address: this.address, alerts: alerts.sublist(0, 1)),
            const SizedBox(height: 12),
            _OverviewGrid(spacing: 12, layer1AccountDataList: this.layer1AccountDataList, arbAccountDataList: this.arbAccountDataList),
            // _OverviewGrid(spacing: 12, layer1AccountDataList: layer1AccountDataList),
          ],
        ),
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({Key key, @required this.spacing, this.layer1AccountDataList, this.arbAccountDataList}) : super(key: key);

  final double spacing;
  final List<AccountData> layer1AccountDataList;
  final List<AccountData> arbAccountDataList;

  @override
  Widget build(BuildContext context) {
    // final accountDataList = DummyDataService.getAccountDataList(context);
    // final layer1AccountDataList = DummyDataService.getLayer1AccountDataList(context);
    // final layer2AccountDataList = DummyDataService.getLayer2AccountDataList(context);
    // final billDataList = DummyDataService.getBillDataList(context);
    // final budgetDataList = DummyDataService.getBudgetDataList(context);

    return LayoutBuilder(builder: (context, constraints) {
      final textScaleFactor =
          GalleryOptions.of(context).textScaleFactor(context);

      // Only display multiple columns when the constraints allow it and we
      // have a regular text scale factor.
      final minWidthForTwoColumns = 600;
      final hasMultipleColumns = isDisplayDesktop(context) &&
          constraints.maxWidth > minWidthForTwoColumns &&
          textScaleFactor <= 2;
      final boxWidth = hasMultipleColumns
          ? constraints.maxWidth / 2 - spacing / 2
          : double.infinity;

      return Wrap(
        runSpacing: spacing,
        children: [
          // Container(
          //   width: boxWidth,
          //   child: _FinancialView(
          //     title: GalleryLocalizations.of(context).rallyAccounts,
          //     total: sumAccountDataPrimaryAmount(accountDataList),
          //     financialItemViews:
          //         buildAccountDataListViews(accountDataList, context),
          //     buttonSemanticsLabel:
          //         GalleryLocalizations.of(context).rallySeeAllAccounts,
          //     order: 1,
          //   ),
          // ),
          // if (hasMultipleColumns) SizedBox(width: spacing),
          Container(
            width: boxWidth,
            child: _FinancialView(
              // title: GalleryLocalizations.of(context).rallyBills,
              title: 'ethereum L1',
              // total: sumBillDataPrimaryAmount(billDataList),
              total: sumAccountDataPrimaryAmount(layer1AccountDataList),
              // financialItemViews: buildAccountDataListViews(billDataList, context),
              financialItemViews: buildAccountDataListViews(layer1AccountDataList, context),
              buttonSemanticsLabel:
                  GalleryLocalizations.of(context).rallySeeAllBills,
              order: 2,
            ),
          ),
          _FinancialView(
            // title: GalleryLocalizations.of(context).rallyBudgets,
            title: 'Arbitrum L2',
            // total: sumBudgetDataPrimaryAmount(budgetDataList),
            total: sumAccountDataPrimaryAmount(arbAccountDataList),
            financialItemViews:
                // buildBudgetDataListViews(budgetDataList, context),
                buildAccountDataListViews(arbAccountDataList, context),
            buttonSemanticsLabel:
                GalleryLocalizations.of(context).rallySeeAllBudgets,
            order: 3,
          ),
        ],
      );
    });
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView({Key key, this.address ,this.alerts}) : super(key: key);

  final List<AlertData> alerts;
  final String address;
  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final shourAddress = this.address.substring(0,6) + '...' + this.address.substring(38);
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 4, bottom: 4),
      color: RallyColors.cardBackground,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                isDesktop ? const EdgeInsets.symmetric(vertical: 16) : null,
            child: MergeSemantics(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Text(GalleryLocalizations.of(context).rallyAlerts),
                  Text(shourAddress),
                  if (!isDesktop)
                    FlatButton(
                      onPressed: () {print("see all");},
                      // child: Text(GalleryLocalizations.of(context).rallySeeAll),
                      child: Text('Account01'),
                      textColor: Colors.white,
                    ),
                ],
              ),
            ),
          ),
          // for (AlertData alert in alerts) ...[
          //   Container(color: RallyColors.primaryBackground, height: 1),
          //   _Alert(alert: alert),
          // ]
        ],
      ),
    );
  }
}

class _Alert extends StatelessWidget {
  const _Alert({
    Key key,
    @required this.alert,
  }) : super(key: key);

  final AlertData alert;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: isDisplayDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 8)
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(alert.message),
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(alert.iconData, color: RallyColors.white60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialView extends StatelessWidget {
  const _FinancialView({
    this.title,
    this.total,
    this.financialItemViews,
    this.buttonSemanticsLabel,
    this.order,
  });

  final String title;
  final String buttonSemanticsLabel;
  final double total;
  final List<FinancialEntityCategoryView> financialItemViews;
  final double order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: Container(
        color: RallyColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(title),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      usdWithSignFormat(context).format(total),
                      style: theme.textTheme.bodyText1.copyWith(
                        fontSize: 44 / reducedTextScale(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...financialItemViews.sublist(
                0, math.min(financialItemViews.length, 3)),
            FlatButton(
              child: Text(
                GalleryLocalizations.of(context).rallySeeAll,
                semanticsLabel: buttonSemanticsLabel,
              ),
              textColor: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
