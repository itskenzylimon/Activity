import 'package:flutter/material.dart';


class CustomTabBar extends StatefulWidget {
  ///[tabs] list of tabs 
  final List<TabData> tabs;

  ///
  final Widget child;

  const CustomTabBar({super.key, required this.tabs, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        ///
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black,
          tabs: _generateTabs(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.content).toList(),
          ),
        )
      ],
    );
  }
  

  List<Widget> _generateTabs() {
    return widget.tabs
        .map((tab) => Tab(
              icon: Icon(tab.icon),
              text: tab.title,
            ))
        .toList();
  }
}

class TabData {

  ///[title] the title of the tab
  final String title;

  ///[icon] this the tab's icon data.
  final IconData icon;

  ///[content]this the content under each tab
  final Widget content;

  TabData({required this.title, required this.icon, required this.content});
}
