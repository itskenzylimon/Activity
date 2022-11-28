extension SuperString on String {
  /// Returns `true` if all characters in the string are in upperCase.
  ///
  /// ```
  /// print('activity'.isUpperCase); // false
  ///
  /// print('ACTIVITY'.isUpperCase); // true
  /// ```
  bool get isUpperCase => this == toUpperCase();

  /// Returns `true` if all characters in the string are in lowerCase.
  ///
  /// ```
  /// print('activity'.isLowerCase); // true
  /// print('ACTIVITY'.isLowerCase); // false
  /// ```
  bool get isLowerCase => this == toLowerCase();

  /// Returns `true` if all the characters are alphanumeric
  /// (alphabet letter (a-z) and numbers (0-9)).
  ///
  /// ```
  /// print('111Activity'.isAlNum); // true
  /// print('123'.isAlNum); // true
  /// print('This@123'.isAlNum); // false
  /// ```
  bool get isNumber => RegExp(r'^[\p{L}\p{N}]+$', unicode: true).hasMatch(this);

  /// Returns `true` if all the characters are alphabets letter (a-z).
  ///
  /// ```
  /// print('Activity'.isAlpha); // true
  /// print('Activity111'.isAlpha); // false
  /// ```
  bool get isAlpha => RegExp(r'^\p{L}+$', unicode: true).hasMatch(this);

  /// Returns `true` if all the characters are [int] (0-9).
  ///
  /// ```
  /// print('Activity111'.isAlNum); // false
  /// print('111'.isAlNum); // true
  /// ```
  bool get isInteger => RegExp(r'^\p{N}+$', unicode: true).hasMatch(this);

  /// Returns a [Iterable] containing all the characters of the string.
  ///
  /// If `this` is empty, its returns a empty [Iterable]
  ///
  /// ```
  /// print('Activity world'.iterable); // ['H','e','l','l','o',]
  /// print('Activity.iterable); // ['A', ' ', 'B']
  /// ```
  ///
  Iterable<String> get iterable =>
      runes.map((int rune) => String.fromCharCode(rune));

  /// Returns the first charcter of a string
  ///
  /// Throws a [StateError] if `this` is empty.
  ///
  String get first => String.fromCharCode(runes.first);

  /// Returns the last charcter of a string
  ///
  /// Throws a [StateError] if `this` is empty.
  ///
  String get last => String.fromCharCode(runes.last);

  /// Returns a `String` where first character of every words is converted to upperCase.
  /// ```
  /// print('this123'.title()); // 'This123'
  /// print('This is title'.title()); // 'This Is Title'
  /// print('tHiS iS tiTle'.title()); // 'This Is Title'
  /// ```
  ///
  String title() {
    final List<String> words = split(' ');

    if (contains(' ')) {
      words.setAll(0, words.map((element) => element.capitalize()));
      return words.join(' ');
    } else {
      return capitalize();
    }
  }

  /// Returns the character at the specified `index` in a string.
  ///
  /// ```
  /// print('This'.charAt(0)); // 'T'
  /// print('This'.charAt(3)); // 's'
  /// ```
  ///
  /// Throws an [RangeError] if `index` is negative or greater than String's length.
  ///
  String charAt(int index) => iterable.elementAt(index);

  /// Return a `String` with its first character UpperCase and the rest LowerCase.
  ///
  /// ```
  /// print('this'.capitalize()); // 'This'
  /// print('THIS'.capitalize()); // 'This'
  /// ```
  ///
  String capitalize() =>
      isNotEmpty ? first.toUpperCase() + substring(1).toLowerCase() : this;

  /// Return the number of times a specified `value` appears in the string.
  ///
  /// The default value of `start` is 0 if the optional arguments `start` is not assigned.
  /// The default value of `end` is the end of the string if the optional arguments `end` is `null`.
  ///
  /// ```
  /// print('this'.count('t')); // 1
  /// print('hello'.count('l')); // 2
  /// print('hello'.count('l',0,2)); // 2
  /// ```
  ///
  int count(String value, [int start = 0, int? end]) =>
      value.allMatches(substring(start, end)).length;

  /// Convert the given string to camelCase.
  ///
  /// By default `isLowerCamelCase` is set as `false` and the given string is
  /// converted into UpperCamelCase. That means the first letter of String is converted into upperCase.
  ///
  /// If the `isLowerCamelCase` is set to `true` then camelCase produces lowerCamelCase.
  /// That means the first letter of String is converted into lowerCase.
  ///
  /// If the String is empty, this method returns `this`.
  ///
  /// ```
  /// print('hello World'.toCamelCase()); // HelloWorld
  /// print('hello_World'.toCamelCase()); // HelloWorld
  /// print('hello World'.toCamelCase(isLowerCamelCase: true)); // helloWorld
  /// ```
  ///
  String toCamelCase({bool isLowerCamelCase = false}) {
    final Pattern pattern = RegExp(r'[ _]');

    Iterable<String> itrStr = split(pattern);
    final List<String> answer = [];

    final String first = itrStr.first;
    answer.add(isLowerCamelCase ? first.toLowerCase() : first.capitalize());

    itrStr = itrStr.skip(1);

    if (contains(pattern)) {
      for (var string in itrStr) {
        answer.add(string.capitalize());
      }
    } else {
      return isLowerCamelCase ? toLowerCase() : capitalize();
    }

    return answer.join();
  }

  /// check if `this` contains all the value from `list`
  ///
  /// return false if one of value in `list` are not in `this`
  ///
  /// Example:
  ///
  /// ```
  /// print('This is my code'.containsAll(['This','code'])); // => true
  /// print('This is my code'.containsAll(['code','hello'])); // => false
  /// ```
  ///
  bool containsAll(Iterable<String> values) => values.every(contains);

  /// check if `this` contains any one of the value from `list`
  ///
  /// Example:
  ///
  /// ```
  /// print('This is my code'.containsAny(['code','hello'])); // => true
  /// print('This is my code'.containsAny(['hello','world'])); // => false
  /// ```
  ///
  bool containsAny(Iterable<String> values) => values.any(contains);
}