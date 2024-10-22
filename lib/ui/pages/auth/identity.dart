import 'package:flutter/material.dart';

import '../../../l10n.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../../util/util.dart';
import '../../ui.dart';

class UserIdentityFormValue extends FormValue {
  String? email;
  String? mobile;
  String? countryCode = "+94";
  String? mobilePrefix = "0";

  UserIdentityFormValue({this.email, this.mobile});

  UserIdentityFormValue.empty()
      : email = "",
        mobile = "";

  get fullMobile => "$mobilePrefix$mobile";
}

class UserIdentityFormController extends FormController<UserIdentityFormValue> {
  UserIdentityFormController() : super(initialValue: UserIdentityFormValue.empty());

  @override
  Future<bool> validate() async {
    value.errors.clear();

    validateEmail() {
      try {
        StringValidators.email(value.email!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"email": err.message});
      }
    }

    validateMobile() {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile("+94${value.mobile!}");
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobile": err.message});
      }
    }

    if (StringValidators.isEmpty(value.email) && StringValidators.isEmpty(value.mobile)) {
      value.errors.addAll({"form": "Email or mobile number is required"});
    } else if (StringValidators.isEmpty(value.email)) {
      validateMobile();
    } else if (StringValidators.isEmpty(value.mobile)) {
      validateEmail();
    } else {
      value.errors.addAll({"form": "Only one field is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class UserIdentityForm extends StatefulFormWidget<UserIdentityFormValue> {
  const UserIdentityForm({
    Key? key,
    required UserIdentityFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<UserIdentityForm> createState() => _UserIdentityFormState();
}

class _UserIdentityFormState extends State<UserIdentityForm> with FormMixin {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController mobileTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                // hintText: "Email Address",
                hintText: AppLocalizations.of(context)!.nN_003,
                errorText: formValue.getError("email"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..email = value,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("+94"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: mobileTextEditingController,
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    maxLength: 9,
                    decoration: InputDecoration(
                      // hintText: "Mobile No",
                      hintText: AppLocalizations.of(context)!.nN_015,
                      errorText: formValue.getError("mobile"),
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..mobile = value,
                    ),
                  ),
                ),
              ],
            ),
            InputDecorator(
              decoration: InputDecoration(
                border: InputBorder.none,
                errorText: formValue.getError("form"),
              ),
              // child: Placeholder(),
            ),
          ],
        );
      },
    );
  }
}

class UserIdentityFormView extends StatefulWidget {
  const UserIdentityFormView({
    Key? key,
    required this.onDone,
    required this.onCancel,
  }) : super(key: key);

  final Function(UserIdentityFormValue) onDone;
  final Function() onCancel;

  @override
  State<UserIdentityFormView> createState() => _UserIdentityFormViewState();
}

class _UserIdentityFormViewState extends State<UserIdentityFormView> {
  UserIdentityFormController controller = UserIdentityFormController();

  handleSendOtp() async {
    if (await controller.validate()) {
      widget.onDone(controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Column(
            children: [
              Text(
                // "FORGOT YOUR PASSWORD?",
                AppLocalizations.of(context)!.nN_010,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              Text(
                // "Enter your registered mobile number or email ID and we will get OTP to reset your password",
                AppLocalizations.of(context)!.nN_014,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: UserIdentityForm(
            controller: controller,
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FilledButton(
            onPressed: handleSendOtp,
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
            // child: const Text("Send OTP"),
            child: Text(AppLocalizations.of(context)!.nN_016),
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
    );
  }
}

Future<UserIdentityFormValue?> showIdentityDialog(BuildContext context) => showDialog<UserIdentityFormValue>(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) => Material(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: UserIdentityFormView(
                onCancel: Navigator.of(context).pop,
                onDone: (value) => Navigator.of(context).pop(value),
              ),
            ),
          ),
        ),
      ),
    );
