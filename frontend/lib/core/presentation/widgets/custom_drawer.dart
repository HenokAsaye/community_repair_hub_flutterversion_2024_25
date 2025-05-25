import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? drawerHeader;
  final List<Widget>? children;

  const CustomDrawer({
    Key? key,
    this.backgroundColor,
    this.drawerHeader,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (drawerHeader != null) drawerHeader!,
          ...?children,
        ],
      ),
    );
  }
}