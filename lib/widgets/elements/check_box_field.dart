import 'package:fluent_ui/fluent_ui.dart';

class CheckBoxWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  CheckBoxWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  @override
  Widget build(BuildContext context) {
    List choices = [];
    var selectedCheck = false;
    callbackElement = valueFormResults[elementName]!;
    for (var i = 0; i < callbackElement['choices'].length; i++) {
      choices.add(callbackElement['choices'][i]);
    }
    if (callbackElement['value'] != '') {
      selectedCheck = callbackElement['value'] ?? false;

    }

    return Visibility(
      visible:  true,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              callbackElement['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              children: choices.map((choice) {
                return Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 10,
                    ),
                    /** Checkbox Widget **/
                    Checkbox(
                      checked: selectedCheck,
                      onChanged: (value) {
                        selectedCheck = value!;
                        callbackElement['value'] = value;
                        onElementCallback(callbackElement);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$choice',
                        style: const TextStyle(fontSize: 16),
                        softWrap: false,
                        maxLines: 2,
                      ),
                    ), //Text

                  ], //<Widget>[]
                ); //Row
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}