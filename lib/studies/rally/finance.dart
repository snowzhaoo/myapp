// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:animations/animations.dart';
import 'package:myapp/data/gallery_options.dart';
import 'package:myapp/l10n/gallery_localizations.dart';
import 'package:myapp/layout/adaptive.dart';
import 'package:myapp/layout/text_scale.dart';
import 'package:myapp/studies/rally/charts/line_chart.dart';
import 'package:myapp/studies/rally/charts/pie_chart.dart';
import 'package:myapp/studies/rally/charts/vertical_fraction_bar.dart';
import 'package:myapp/studies/rally/colors.dart';
import 'package:myapp/studies/rally/data.dart';
import 'package:myapp/studies/rally/formatters.dart';
import 'package:web3dart/web3dart.dart';
// import 'package:qrscan/qrscan.dart' as scanner;
import 'package:barcode_scan/barcode_scan.dart';
class FinancialEntityView extends StatelessWidget {
  const FinancialEntityView({
    this.heroLabel,
    this.heroAmount,
    this.wholeAmount,
    this.segments,
    this.financialEntityCards,
  }) : assert(segments.length == financialEntityCards.length);

  /// The amounts to assign each item.
  final List<RallyPieChartSegment> segments;
  final String heroLabel;
  final double heroAmount;
  final double wholeAmount;
  final List<FinancialEntityCategoryView> financialEntityCards;

  @override
  Widget build(BuildContext context) {
    final maxWidth = pieChartMaxSize + (cappedTextScale(context) - 1.0) * 100.0;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              // We decrease the max height to ensure the [RallyPieChart] does
              // not take up the full height when it is smaller than
              // [kPieChartMaxSize].
              maxHeight: math.min(
                constraints.biggest.shortestSide * 0.9,
                maxWidth,
              ),
            ),
            child: RallyPieChart(
              heroLabel: heroLabel,
              heroAmount: heroAmount,
              wholeAmount: wholeAmount,
              segments: segments,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            constraints: BoxConstraints(maxWidth: maxWidth),
            color: RallyColors.inputBackground,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            color: RallyColors.cardBackground,
            child: Column(
              children: financialEntityCards,
            ),
          ),
        ],
      );
    });
  }
}

/// A reusable widget to show balance information of a single entity as a card.
class FinancialEntityCategoryView extends StatelessWidget {
  const FinancialEntityCategoryView({
    @required this.indicatorColor,
    @required this.indicatorFraction,
    @required this.title,
    @required this.subtitle,
    @required this.semanticsLabel,
    @required this.amount,
    @required this.suffix,
  });

  final Color indicatorColor;
  final double indicatorFraction;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final String amount;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        button: true,
        enabled: true,
        label: semanticsLabel,
      ),
      excludeSemantics: true,
      child: OpenContainer(
        transitionDuration: const Duration(milliseconds: 800),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, openContainer) =>
            FinancialEntityCategoryDetailsPage(title: title),
        openColor: RallyColors.primaryBackground,
        closedColor: Colors.transparent,
        closedElevation: 0,
        closedBuilder: (context, openContainer) {
          return FlatButton(
            onPressed: openContainer,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 32 + 60 * (cappedTextScale(context) - 1),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: VerticalFractionBar(
                          color: indicatorColor,
                          fraction: indicatorFraction,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: textTheme.bodyText2
                                      .copyWith(fontSize: 16),
                                ),
                                Text(
                                  subtitle,
                                  style: textTheme.bodyText2
                                      .copyWith(color: RallyColors.gray60),
                                ),
                              ],
                            ),
                            Text(
                              amount,
                              style: textTheme.bodyText1.copyWith(
                                fontSize: 20,
                                color: RallyColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: suffix,
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: RallyColors.dividerColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Data model for [FinancialEntityCategoryView].
class FinancialEntityCategoryModel {
  const FinancialEntityCategoryModel(
    this.indicatorColor,
    this.indicatorFraction,
    this.title,
    this.subtitle,
    this.usdAmount,
    this.suffix,
  );

  final Color indicatorColor;
  final double indicatorFraction;
  final String title;
  final String subtitle;
  final double usdAmount;
  final Widget suffix;
}

FinancialEntityCategoryView buildFinancialEntityFromAccountData(
  AccountData model,
  int accountDataIndex,
  BuildContext context,
) {
  // final amount = usdWithSignFormat(context).format(model.primaryAmount);
  final amount = tokenWithSignFormat(context).format(model.primaryAmount);
  final shortAccountNumber = model.accountNumber.substring(6);
  return FinancialEntityCategoryView(
    suffix: const Icon(Icons.chevron_right, color: Colors.grey),
    title: model.name,
    subtitle: '• • • • • • $shortAccountNumber',
    semanticsLabel: GalleryLocalizations.of(context).rallyAccountAmount(
      model.name,
      shortAccountNumber,
      amount,
    ),
    indicatorColor: RallyColors.accountColor(accountDataIndex),
    indicatorFraction: 1,
    amount: amount,
  );
}

FinancialEntityCategoryView buildFinancialEntityFromLayer1Data(
  AccountData model,
  int layer1DataIndex,
  BuildContext context,
) {
  // final amount = usdWithSignFormat(context).format(model.primaryAmount);
  final amount = tokenWithSignFormat(context).format(model.primaryAmount);
  final shortAccountNumber = model.accountNumber.substring(6);
  return FinancialEntityCategoryView(
    suffix: const Icon(Icons.chevron_right, color: Colors.grey),
    title: model.name,
    subtitle: '• • • • • • $shortAccountNumber',
    semanticsLabel: GalleryLocalizations.of(context).rallyAccountAmount(
      model.name,
      shortAccountNumber,
      amount,
    ),
    indicatorColor: RallyColors.layer1Color(layer1DataIndex),
    indicatorFraction: 1,
    amount: amount,
  );
}
FinancialEntityCategoryView buildFinancialEntityFromLayer2Data(
  AccountData model,
  int layer2DataIndex,
  BuildContext context,
) {
  final amount = usdWithSignFormat(context).format(model.primaryAmount);
  final shortAccountNumber = model.accountNumber.substring(6);
  return FinancialEntityCategoryView(
    suffix: const Icon(Icons.chevron_right, color: Colors.grey),
    title: model.name,
    subtitle: '• • • • • • $shortAccountNumber',
    semanticsLabel: GalleryLocalizations.of(context).rallyAccountAmount(
      model.name,
      shortAccountNumber,
      amount,
    ),
    indicatorColor: RallyColors.layer2Color(layer2DataIndex),
    indicatorFraction: 1,
    amount: amount,
  );
}
FinancialEntityCategoryView buildFinancialEntityFromBillData(
  BillData model,
  int billDataIndex,
  BuildContext context,
) {
  final amount = usdWithSignFormat(context).format(model.primaryAmount);
  return FinancialEntityCategoryView(
    suffix: const Icon(Icons.chevron_right, color: Colors.grey),
    title: model.name,
    subtitle: model.dueDate,
    semanticsLabel: GalleryLocalizations.of(context).rallyBillAmount(
      model.name,
      model.dueDate,
      amount,
    ),
    indicatorColor: RallyColors.billColor(billDataIndex),
    indicatorFraction: 1,
    amount: amount,
  );
}

FinancialEntityCategoryView buildFinancialEntityFromBudgetData(
  BudgetData model,
  int budgetDataIndex,
  BuildContext context,
) {
  final amountUsed = usdWithSignFormat(context).format(model.amountUsed);
  final primaryAmount = usdWithSignFormat(context).format(model.primaryAmount);
  final amount =
      usdWithSignFormat(context).format(model.primaryAmount - model.amountUsed);

  return FinancialEntityCategoryView(
    suffix: Text(
      GalleryLocalizations.of(context).rallyFinanceLeft,
      style: Theme.of(context)
          .textTheme
          .bodyText2
          .copyWith(color: RallyColors.gray60, fontSize: 10),
    ),
    title: model.name,
    subtitle: amountUsed + ' / ' + primaryAmount,
    semanticsLabel: GalleryLocalizations.of(context).rallyBudgetAmount(
      model.name,
      model.amountUsed,
      model.primaryAmount,
      amount,
    ),
    indicatorColor: RallyColors.budgetColor(budgetDataIndex),
    indicatorFraction: model.amountUsed / model.primaryAmount,
    amount: amount,
  );
}

List<FinancialEntityCategoryView> buildAccountDataListViews(
  List<AccountData> items,
  BuildContext context,
) {
  return List<FinancialEntityCategoryView>.generate(
    items.length,
    (i) => buildFinancialEntityFromAccountData(items[i], i, context),
  );
}

// List<FinancialEntityCategoryView> buildLayer1DataListViews(
//   List<AccountData> items,
//   BuildContext context,
// ) {
//   return List<FinancialEntityCategoryView>.generate(
//     items.length,
//     (i) => buildFinancialEntityFromAccountData(items[i], i, context),
//   );
// }
// List<FinancialEntityCategoryView> buildLayer2DataListViews(
//   List<AccountData> items,
//   BuildContext context,
// ) {
//   return List<FinancialEntityCategoryView>.generate(
//     items.length,
//     (i) => buildFinancialEntityFromLayer2Data(items[i], i, context),
//   );
// }

List<FinancialEntityCategoryView> buildBillDataListViews(
  List<BillData> items,
  BuildContext context,
) {
  return List<FinancialEntityCategoryView>.generate(
    items.length,
    (i) => buildFinancialEntityFromBillData(items[i], i, context),
  );
}

List<FinancialEntityCategoryView> buildBudgetDataListViews(
  List<BudgetData> items,
  BuildContext context,
) {
  return <FinancialEntityCategoryView>[
    for (int i = 0; i < items.length; i++)
      buildFinancialEntityFromBudgetData(items[i], i, context)
  ];
}

class FinancialEntityCategoryDetailsPage extends StatelessWidget {
  FinancialEntityCategoryDetailsPage({this.title});
  String title;
  final List<DetailedEventData> items =
      DummyDataService.getDetailedEventItems();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    List<Widget> listViewChildren = [
      _Console(
        addressController: _addressController,
        amountController: _amountController,
        passwordController: _passwordController,
      ),
    ];
    return ApplyTextOptions(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            // GalleryLocalizations.of(context).rallyAccountDataChecking,
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity, 
                    child: Column(
                      children: [
                        Expanded(
                          child: Align (
                            alignment: Alignment.topCenter,
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              children: listViewChildren,
                            ),
                          )
                        )]
                    ),


                  )         

                  // child: RallyLineChart(events: items),
                ),
                Expanded(
                  child: Padding(
                    padding: isDesktop ? const EdgeInsets.all(40) : EdgeInsets.zero,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (DetailedEventData detailedEventData in items)
                          _DetailedEventCard(
                            title: detailedEventData.title,
                            date: detailedEventData.date,
                            amount: detailedEventData.amount,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),)
      ),
    );
  }
}

class _DetailedEventCard extends StatelessWidget {
  const _DetailedEventCard({
    @required this.title,
    @required this.date,
    @required this.amount,
  });

  final String title;
  final DateTime date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    return FlatButton(
      onPressed: () {},
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _EventTitle(title: title),
                      ),
                      _EventDate(date: date),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _EventAmount(amount: amount),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EventTitle(title: title),
                          _EventDate(date: date),
                        ],
                      ),
                      _EventAmount(amount: amount),
                    ],
                  ),
          ),
          SizedBox(
            height: 1,
            child: Container(
              color: RallyColors.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventAmount extends StatelessWidget {
  const _EventAmount({Key key, @required this.amount}) : super(key: key);

  final double amount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      usdWithSignFormat(context).format(amount),
      style: textTheme.bodyText1.copyWith(
        fontSize: 20,
        color: RallyColors.gray,
      ),
    );
  }
}

class _EventDate extends StatelessWidget {
  const _EventDate({Key key, @required this.date}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      shortDateFormat(context).format(date),
      semanticsLabel: longDateFormat(context).format(date),
      style: textTheme.bodyText2.copyWith(color: RallyColors.gray60),
    );
  }
}

class _EventTitle extends StatelessWidget {
  const _EventTitle({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.bodyText2.copyWith(fontSize: 16),
    );
  }
}

class _Console extends StatelessWidget {
  _Console({this.addressController, this.amountController, this.passwordController});
  final TextEditingController addressController;
  final TextEditingController amountController;
  final TextEditingController passwordController;
  double gasPrice = 25;

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void> (
      isScrollControlled: true, 
      context: context,
      builder: (context) {
        // return _BottomSheetContent();
        return SingleChildScrollView(  // !important
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom), 
          child: _BottomSheetContent(passwordController:passwordController),
        );

      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        _AddressInput(
          addressController: addressController,
        ), 
        _AmountInput(
          amountController: amountController,
        ), 
        _Sliders(gasPrice: gasPrice),
        FlatButton(
          onPressed: () {
            print("address"+ this.addressController.text);
            print("amount"+ this.amountController.text);
            print(this.gasPrice);
            FocusScope.of(context).requestFocus(FocusNode());
            _showModalBottomSheet(context);
          },
          // child: Text(GalleryLocalizations.of(context).rallySeeAll),
          child: Text('SEND'),
          textColor: Colors.white,
        ),
      ]
    );
    
  }
}


class _BottomSheetContent extends StatelessWidget {
  _BottomSheetContent({this.passwordController});
  final TextEditingController passwordController;
      FocusNode _commentFocus = FocusNode();
      
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            height: 50,
            child: Center(
              child: Text(
                'Unlock wallet',
                // GalleryLocalizations.of(context).demoBottomSheetHeader,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // const Divider(thickness: 1),
          Expanded(
            // child: TextField(
            //   keyboardType: TextInputType.text,
            //   autofocus: true,
            // ),
            child:         _PasswordInput(
              passwordController: passwordController,
            ), 
            // child: ListView.builder(
            //   itemCount: 21,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       title: Text(GalleryLocalizations.of(context)
            //           .demoBottomSheetItem(index)),
            //     );
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}
class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    Key key,
    this.maxWidth,
    this.passwordController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: GalleryLocalizations.of(context).rallyLoginPassword,
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (value) {
            print(value);
            // _commentFocus.unfocus();
            // FocusScope.of(context).requestFocus(FocusNode());

          }
        ),
      ),
    );
  }
}

class _AddressInput extends StatelessWidget {
  const _AddressInput({
    Key key,
    this.maxWidth,
    this.addressController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController addressController;
  @override
  Widget build(BuildContext context) {
    //TODO remove
  this.addressController.text = '0xA33B10B5f35061aedD6B2e624D7A822a633d57A9';
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsetsDirectional.only(top: 8, bottom: 4),
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                // obscureText: true,
              ),
              IconButton(
                icon: Icon(Icons.camera_alt,color: Colors.white),
                onPressed: () async {
                    String barcode = await BarcodeScanner.scan();
                    this.addressController.text = barcode;
                    RegExp exp = new RegExp(r"0x[0-9a-fA-F]{40}$");
                    this.addressController.text = exp.firstMatch(barcode).group(0);
                },
              ),
            ],
          )
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    Key key,
    this.maxWidth,
    this.amountController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController amountController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsetsDirectional.only(top: 4, bottom: 8),
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: amountController,
          decoration: InputDecoration(
            // labelText: GalleryLocalizations.of(context).rallyLoginPassword,
            labelText: 'Amount',
          ),
          // obscureText: true,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }
}

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


class _Sliders extends StatefulWidget {
  _Sliders({this.gasPrice});
  double gasPrice = 25;
  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<_Sliders> {

  @override
  void initState() {

    DataService().gasPrice(context).then((_gasPrice) => {
      setState(() {
        widget.gasPrice = _gasPrice.getValueInUnit(EtherUnit.gwei);
      })
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,      
            children: [
              Slider(
                value: widget.gasPrice,
                activeColor: Colors.white,
                inactiveColor: Colors.grey[30],
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    widget.gasPrice = value;
                  });
                },
              ),
              Semantics(
                label: 'gasPrice',
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  
                    child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          final newValue = double.tryParse(value);
                          if (newValue != null && newValue != widget.gasPrice) {
                            setState(() {
                              widget.gasPrice = newValue.clamp(0, 100) as double;
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: widget.gasPrice.toStringAsFixed(0),
                        ),
                      ),
                  )
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

