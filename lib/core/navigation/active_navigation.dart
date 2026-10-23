import 'package:flutter/material.dart';

/// Typed imperative navigation, interoperable with Flutter's Navigator.
class Nav {
  static Future<T?> to<T>(
    BuildContext context,
    Widget Function() page, [
    Object? arguments,
  ]) => Navigator.push<T>(
    context,
    MaterialPageRoute<T>(
      builder: (_) => page(),
      settings: RouteSettings(arguments: arguments),
    ),
  );

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, [
    Object? arguments,
  ]) => Navigator.pushNamed<T>(context, routeName, arguments: arguments);

  static Future<T?> pushUntil<T>(
    BuildContext context,
    Widget Function() page,
    RoutePredicate predicate, [
    Object? arguments,
  ]) => Navigator.pushAndRemoveUntil<T>(
    context,
    MaterialPageRoute<T>(
      builder: (_) => page(),
      settings: RouteSettings(arguments: arguments),
    ),
    predicate,
  );

  /// Clears the complete previous stack.
  static Future<T?> offAll<T>(
    BuildContext context,
    Widget Function() page, [
    Object? arguments,
  ]) => pushUntil<T>(context, page, (_) => false, arguments);

  static Future<T?> replace<T, TO>(
    BuildContext context,
    Widget Function() page, {
    Object? arguments,
    TO? result,
  }) => Navigator.pushReplacement<T, TO>(
    context,
    MaterialPageRoute<T>(
      builder: (_) => page(),
      settings: RouteSettings(arguments: arguments),
    ),
    result: result,
  );

  static void off<T>(BuildContext context, [T? backParams]) =>
      Navigator.pop<T>(context, backParams);
  static Future<bool> maybePop<T>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);
  static Object? getArguments(BuildContext context) =>
      ModalRoute.of(context)?.settings.arguments;
  static T? argumentsOf<T>(BuildContext context) => getArguments(context) as T?;
}
