import 'package:activity/activity.dart';
import 'package:flutter/widgets.dart';

class Fragment extends ActiveView<ActiveController> {
  final Function viewContext;
  const Fragment({
    super.key,
    required super.activeController,
    required this.viewContext
  });

  @override
  ActiveState<ActiveView<ActiveController>, ActiveController> createActivity() =>
      _ActView(activeController, viewContext);
}

class _ActView extends ActiveState<Fragment, ActiveController> {
  _ActView(super.activeController, this.viewContext);
  /// [viewContext] : is the function that returns the widget to be rendered and
  /// expects a [BuildContext] as a parameter
  final Function viewContext;

  @override
  Widget build(BuildContext context) {
    Widget newChild = viewContext.call(context);
    return newChild;
  }

}