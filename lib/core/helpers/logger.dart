import 'package:flutter/foundation.dart';

///------------------------------------
/// Print to console in red
///------------------------------------
printError(text, {name = '📕: error'}) =>
    _log('\x1B[31m --- $text --- \x1B[0m', name);

///------------------------------------
/// Print to console in green
///------------------------------------
printSuccess(text, {name = '📙: success'}) =>
    _log('\x1B[32m --- $text --- \x1B[0m', name);

///------------------------------------
/// Print to console in yellow
///------------------------------------
printWarning(text, {name = '📗: warning'}) =>
    _log('\x1B[33m --- $text --- \x1B[0m', name);

///------------------------------------
/// Print to console in blue
///------------------------------------
printInfo(text, {name = '📘: info'}) =>
    _log('\x1B[34m --- $text --- \x1B[0m', name);

///------------------------------------
/// Print to console in white
///------------------------------------
printNormal(text, {name = '📓: normal'}) =>
    _log('\x1B[37m --- $text --- \x1B[0m', name);

_log(body, name) {
  return debugPrint('\x1B[31m$body\x1B[0m');
}