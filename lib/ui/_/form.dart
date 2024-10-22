import 'package:flutter/material.dart';

import '../ui.dart';

class TestFormPage extends StatelessWidget {
  TestFormPage({Key? key}) : super(key: key);

  final TestFormController controller = TestFormController(
      initialValue: TestFormValue("Hello World")
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, data, _) {
            return Text(data?.text ?? "");
          },
        ),
        TestForm(controller: controller),
        TextButton(
          onPressed: () => controller.reset(),
          child: const Text("Reset"),
        ),
      ],
    );
  }
}

class TestFormValue extends FormValue{
  String text;
  TestFormValue(this.text);
}

class TestFormController extends FormController<TestFormValue> {
  TestFormController({required super.initialValue}): _initialValue = initialValue?.text;

  final String? _initialValue;

  reset() {
    setValue(value!..text = _initialValue ?? "");
  }
}

class TestForm extends StatefulFormWidget<TestFormValue> {
  const TestForm({Key? key, required TestFormController controller}) : super(key: key, controller: controller);

  @override
  State<TestForm> createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> with FormMixin {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      onChanged: (value) => widget.controller.setValue(widget.controller.value?..text = value),
    );
  }

  @override
  void handleFormControllerEvent() {
    final value = widget.controller.value?.text;
    textEditingController.value = textEditingController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value?.length ?? 0),
    );
    super.handleFormControllerEvent();
  }
}