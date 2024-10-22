import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n.dart';
import '../../ui.dart';
import '../../../util/util.dart';

class NewPasswordFormValue extends FormValue {
  String? password;
  String? confirmation;

  NewPasswordFormValue({this.password, this.confirmation});
}

class NewPasswordFormController extends FormController<NewPasswordFormValue> {
  NewPasswordFormController() : super(initialValue: NewPasswordFormValue());

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? password = value.password;
    String? cPassword = value.confirmation;

    if (StringValidators.isEmpty(password)) {
      value.errors.addAll({"password": "Password is required"});
    } else {
      try {
        StringValidators.password(password!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"password": err.message});
      }

      if (password != cPassword) {
        value.errors.addAll({"cPassword": "Confirmation do not match"});
      }
    }

    if (StringValidators.isEmpty(cPassword)) {
      value.errors.addAll({"cPassword": "Password confirmation is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class NewPasswordForm extends StatefulFormWidget<NewPasswordFormValue> {
  const NewPasswordForm({super.key, required super.controller});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> with FormMixin {
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmationTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: passwordTextEditingController,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                // hintText: "Create a new password",
                hintText: AppLocalizations.of(context)!.nN_019,
                errorText: formValue.getError("password"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..password = value,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmationTextEditingController,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                // hintText: "Re - enter the new password",
                hintText: AppLocalizations.of(context)!.nN_020,
                errorText: formValue.getError("cPassword"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..confirmation = value,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum PasswordResetMethod { std, withAuthorizationCode }

class NewPasswordFormView extends StatefulWidget {
  const NewPasswordFormView({
    Key? key,
    required this.onDone,
    this.authorizationCode,
    this.method = PasswordResetMethod.std,
    required this.onCancel,
  }) : super(key: key);

  final PasswordResetMethod method;
  final String? authorizationCode;

  final Function(NewPasswordFormValue value) onDone;
  final Function() onCancel;

  @override
  State<NewPasswordFormView> createState() => _NewPasswordFormViewState();
}

class _NewPasswordFormViewState extends State<NewPasswordFormView> {
  NewPasswordFormController controller = NewPasswordFormController();

  handleConfirmation() async {
    if (await controller.validate()) {
      widget.onDone(controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AspectRatio(aspectRatio: 5),
          AspectRatio(
            aspectRatio: 4.5,
            child: Image.asset(
              "assets/images/tm_001.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              // "CREATE A NEW PASSWORD",
              AppLocalizations.of(context)!.nN_1005.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: NewPasswordForm(
              controller: controller,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FilledButton(
              onPressed: handleConfirmation,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // child: const Text("Confirm"),
              child: Text(AppLocalizations.of(context)!.nN_160),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FilledButton(
              onPressed: widget.onCancel,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // child: const Text("Cancel"),
              child: Text(AppLocalizations.of(context)!.nN_161),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

showPasswordConfirmationDialog(BuildContext context) => showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    child: NewPasswordFormView(
                      onCancel: Navigator.of(context).pop,
                      onDone: (value) => Navigator.of(context).pop(value.password!),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: BackButton(
                  //     onPressed: () => Navigator.of(context).pop(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
