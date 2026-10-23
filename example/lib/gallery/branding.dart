import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The supplied artwork is the source of the gallery's blue palette.
const activitySky = Color(0xFF4BABDC);
const activityBlue = Color(0xFF1888B0);
const activityDeep = Color(0xFF287491);

class ActivityLogo extends StatelessWidget {
  const ActivityLogo({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/branding/activity.svg',
    width: size,
    height: size,
    semanticsLabel: 'Activity logo',
  );
}
