import 'package:flutter/material.dart';

///[static] class that is responsible for holding navigation abstract widget functions
class Nav {
  ///[static] function for navigating to a given route
   ///final args = getArguments(); -> to get arguments from previous screen
   ///arguments are of type Objects so any arguments of any type are accepted
  ///this represents push  with context, page -> class name of the
 /// page you want to navigate to and arguments as parameters
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
  //Push with a named route
  static pushNamed(BuildContext context, String routeName, [final Object? arguments]) =>
      Navigator.pushNamed(
        context,
       routeName,
        arguments: arguments ?? {},
      );

  ///create predicate route
  static Route<dynamic> predicateRoute(BuildContext context, predicate) {
    return MaterialPageRoute(builder: (context) {
      return predicate();
    });
  }

  ///[static] pops routes until given route
   ///final args = getArguments(); -> to get arguments from previous screen
 ///arguments are of type Objects so any arguments of any type are accepted
 ///this represents pushAndRemoveUntil  with context, page -> class name of the
 /// page you want to navigate to and arguments as parameters
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
   ///final args = getArguments(); -> to get arguments from previous screen
 ///arguments are of type Objects so any arguments of any type are accepted
 ///this represents pushReplacement  with context, page -> class name of the
 /// page you want to navigate to and arguments as parameters
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
  ///final args = getArguments(); -> to get arguments from previous screen
    ///arguments are of type Objects so any arguments of any type are accepted
    ///this represents pop off a screen or dialog with context and back params as arguments
  static off(BuildContext context, [final Object? backParams]) =>
      Navigator.pop(context, backParams);

  ///[arguments] function to get arguments from previous screnn
  static getArguments(BuildContext context) => ModalRoute.of(context)!.settings.arguments;
}
