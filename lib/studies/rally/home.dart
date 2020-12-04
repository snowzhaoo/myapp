// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:myapp/data/gallery_options.dart';
import 'package:myapp/l10n/gallery_localizations.dart';
import 'package:myapp/layout/adaptive.dart';
import 'package:myapp/layout/text_scale.dart';
import 'package:myapp/studies/rally/tabs/accounts.dart';
import 'package:myapp/studies/rally/tabs/layer1.dart';
import 'package:myapp/studies/rally/tabs/layer2.dart';
import 'package:myapp/studies/rally/tabs/bills.dart';
import 'package:myapp/studies/rally/tabs/budgets.dart';
import 'package:myapp/pages/settings.dart';
import 'package:myapp/studies/rally/tabs/overview.dart';
import 'package:myapp/studies/rally/tabs/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
const int tabCount = 4;
const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

class HomePage extends StatefulWidget {
  const HomePage();
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
  with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabCount, vsync: this)
      ..addListener(() {
        // print("slide");
        setState(() {});
        // Set state to make sure that the [_RallyTab] widgets get updated when changing tabs.
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = isDisplayDesktop(context);
    Widget tabBarView;

    tabBarView = Column(
      children: [
        _RallyTabBar(
          tabs: _buildTabs(context: context, theme: theme),
          tabController: _tabController,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ],
    );
    
    return ApplyTextOptions(
      child: Scaffold(
        body: SafeArea(
          // For desktop layout we do not want to have SafeArea at the top and
          // bottom to display 100% height content on the accounts view.
          top: !isDesktop,
          bottom: !isDesktop,
          child: Theme(
            // This theme effectively removes the default visual touch
            // feedback for tapping a tab, which is replaced with a custom
            // animation.
            data: theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: tabBarView,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs(
      {BuildContext context, ThemeData theme, bool isVertical = false}) {
    return [
      _RallyTab(
        theme: theme,
        iconData: Icons.pie_chart,
        title: GalleryLocalizations.of(context).rallyTitleOverview,
        tabIndex: 0,
        tabController: _tabController,
        isVertical: isVertical,
      ),
      // _RallyTab(
      //   theme: theme,
      //   iconData: Icons.attach_money,
      //   title: GalleryLocalizations.of(context).rallyTitleAccounts,
      //   tabIndex: 1,
      //   tabController: _tabController,
      //   isVertical: isVertical,
      // ),
      _RallyTab(
        theme: theme,
        iconData: Icons.attach_money,
        // iconData: Icons.linear_scale,
        // iconData: Icons.money_off,
        // title: GalleryLocalizations.of(context).rallyTitleBills,
        title: 'Ethereum',
        tabIndex: 1,
        tabController: _tabController,
        isVertical: isVertical,
      ),
      _RallyTab(
        theme: theme,
        // iconData: Icons.table_chart,
        // title: GalleryLocalizations.of(context).rallyTitleBudgets,
        iconData: Icons.call_merge,
        title: 'Arbitrum',
        tabIndex: 2,
        tabController: _tabController,
        isVertical: isVertical,
      ),
      _RallyTab(
        theme: theme,
        iconData: Icons.settings,
        title: GalleryLocalizations.of(context).rallyTitleSettings,
        tabIndex: 3,
        tabController: _tabController,
        isVertical: isVertical,
      ),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      OverviewView(),
      // AccountsView(),
      Layer1View(),
      // BillsView(),
      // BudgetsView(),
      Layer2View(),
      SettingsView(),
    ];
  }
}

class _RallyTabBar extends StatelessWidget {
  const _RallyTabBar({Key key, this.tabs, this.tabController})
      : super(key: key);

  final List<Widget> tabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: TabBar(
        // Setting isScrollable to true prevents the tabs from being
        // wrapped in [Expanded] widgets, which allows for more
        // flexible sizes and size animations among tabs.
        isScrollable: true,
        labelPadding: EdgeInsets.zero,
        tabs: tabs,
        controller: tabController,
        // This hides the tab indicator.
        indicatorColor: Colors.transparent,
      ),
    );
  }
}

class _RallyTab extends StatefulWidget {
  _RallyTab({
    ThemeData theme,
    IconData iconData,
    String title,
    int tabIndex,
    TabController tabController,
    this.isVertical,
  })  : titleText = Text(title, style: theme.textTheme.button),
        isExpanded = tabController.index == tabIndex,
        icon = Icon(iconData, semanticLabel: title);

  final Text titleText;
  final Icon icon;
  final bool isExpanded;
  final bool isVertical;

  @override
  _RallyTabState createState() => _RallyTabState();
}

class _RallyTabState extends State<_RallyTab>
    with SingleTickerProviderStateMixin {
  Animation<double> _titleSizeAnimation;
  Animation<double> _titleFadeAnimation;
  Animation<double> _iconFadeAnimation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _titleSizeAnimation = _controller.view;
    _titleFadeAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _iconFadeAnimation = _controller.drive(Tween<double>(begin: 0.6, end: 1));
    if (widget.isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_RallyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        children: [
          const SizedBox(height: 18),
          FadeTransition(
            child: widget.icon,
            opacity: _iconFadeAnimation,
          ),
          const SizedBox(height: 12),
          FadeTransition(
            child: SizeTransition(
              child: Center(child: ExcludeSemantics(child: widget.titleText)),
              axis: Axis.vertical,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Calculate the width of each unexpanded tab by counting the number of
    // units and dividing it into the screen width. Each unexpanded tab is 1
    // unit, and there is always 1 expanded tab which is 1 unit + any extra
    // space determined by the multiplier.
    final width = MediaQuery.of(context).size.width;
    const expandedTitleWidthMultiplier = 2;
    final unitWidth = width / (tabCount + expandedTitleWidthMultiplier);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          FadeTransition(
            child: SizedBox(
              width: unitWidth,
              child: widget.icon,
            ),
            opacity: _iconFadeAnimation,
          ),
          FadeTransition(
            child: SizeTransition(
              child: SizedBox(
                width: unitWidth * expandedTitleWidthMultiplier,
                child: Center(
                  child: ExcludeSemantics(child: widget.titleText),
                ),
              ),
              axis: Axis.horizontal,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
