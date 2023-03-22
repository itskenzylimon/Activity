import 'package:fluent_ui/fluent_ui.dart';
import '../../core/forms/form_controller.dart';

class AgeCalculatorWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  AgeCalculatorWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};
  TextEditingController agecalcEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    callbackElement = valueFormResults[elementName]!;
    String labelText = valueFormResults[elementName]!['title'];
    if(valueFormResults[elementName]!['value'].isNotEmpty) {
      agecalcEditingController.text =
      agecalcEditingController.text == ""?
      "": calculateAge(valueFormResults[elementName]!['value']).toString();
    }

    // Return an empty Container widget (or any other widget)
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      const SizedBox(
        height: 20,
      ),
      Text(
        labelText,
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormBox(
        controller: agecalcEditingController,
        keyboardType: FormController().
        checkInputType(valueFormResults[elementName]!),
        readOnly: true,
        placeholder: valueFormResults[elementName]!['placeholder'] ?? '',
        validator: (value) {},
        onChanged: (value) {

          callbackElement['value'] = value;
          onElementCallback(callbackElement);

        },
      ),
    ]);
  }

  calculateAge(birthDate) {
    // 9/30/1993
    birthDate = birthDate.split(" ").first;
    birthDate = birthDate.split("/");
    DateTime currentDate = DateTime.now();
    num age = currentDate.year - num.parse(birthDate[2]);
    int month1 = currentDate.month;
    int month2 = int.parse(birthDate[0]);
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = int.parse(birthDate[1]);
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}