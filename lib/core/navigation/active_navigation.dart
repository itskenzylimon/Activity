import 'package:flutter/material.dart';

///[static] class that is responsible for holding navigation abstract widget functions
class Nav {
  ///[static] function for navigating to a given route
  static to(BuildContext context, Widget Function() page, [final Object? arguments]) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page(),
          settings: RouteSettings(
            arguments: arguments ?? {},
          ),
        ),
      );

  ///create predicate route
  static Route<dynamic> predicateRoute(BuildContext context, predicate) {
    return MaterialPageRoute(builder: (context) {
      return predicate();
    });
  }

  ///[static] pops routes until given route
  static pushUntil(BuildContext context, Widget Function() page, Widget Function() predicate,
          [final Object? arguments]) =>
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => page(),
            settings: RouteSettings(
              arguments: arguments ?? {},
            ),
          ), (Route<dynamic> route) {
        Route<dynamic> myRoute = predicateRoute(context, predicate());
        if (route == myRoute) {
          return true;
        }
        return false;
      });

  ///[static] function for replacing current route with the provided route
  ///final todo = ModalRoute.of(context)!.settings.arguments; -> to get arguments from previous screen
  static offAll(BuildContext context, Widget Function() page, [final Object? arguments]) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => page(),
          // Pass the arguments as part of the RouteSettings. The
          // DetailScreen reads the arguments from these settings.
          settings: RouteSettings(
            arguments: arguments ?? {},
          ),
        ),
      );

  ///[static] function for navigating off apage
  static off(BuildContext context,[final Object? backParams]) => Navigator.pop(context,backParams);

  ///[arguments] function to get arguments from previous screnn
  static getArguments(BuildContext context) => ModalRoute.of(context)!.settings.arguments;
}
