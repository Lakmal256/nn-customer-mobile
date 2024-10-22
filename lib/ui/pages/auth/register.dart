import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:nawa_niwasa/auth/apple.dart';
import '../../../auth/google.dart';
import '../../../auth/user_data.dart';
import '../../../auth/facebook.dart';
import '../../../l10n.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../../util/util.dart';
import '../../ui.dart';

class RegisterFormValue extends FormValue {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? location;
  String? locale;

  RegisterFormValue({this.firstName, this.lastName, this.email, this.mobile, this.locale, this.location});

  RegisterFormValue.empty()
      : firstName = "",
        lastName = "",
        email = "",
        mobile = "",
        locale = "",
        location = "";
}

class RegisterFormController extends FormController<RegisterFormValue> {
  RegisterFormController({required super.initialValue});

  validateFirstName() async {
    value.errors.remove("firstName");

    /// First Name Validations
    String? firstName = value.firstName;
    if (StringValidators.isEmpty(firstName)) {
      value.errors.addAll({"firstName": "First name is required"});
    } else {
      try {
        StringValidators.isPure(firstName!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"firstName": err.message});
      }
    }
  }

  validateLastName() async {
    value.errors.remove("lastName");

    /// Last Name Validations
    String? lastName = value.lastName;
    if (StringValidators.isEmpty(lastName)) {
      value.errors.addAll({"lastName": "Last name is required"});
    } else {
      try {
        StringValidators.isPure(lastName!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"lastName": err.message});
      }
    }
  }

  @override
  Future<bool> validate() async {
    value.errors.clear();

    await validateFirstName();

    await validateLastName();

    /// Email Validations
    String? email = value.email;
    if (StringValidators.isEmpty(email)) {
      value.errors.addAll({"email": "Email is required"});
    } else {
      try {
        StringValidators.email(email!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"email": err.message});
      }
    }

    /// Mobile Validations
    String? mobile = value.mobile;
    if (StringValidators.isEmpty(mobile)) {
      value.errors.addAll({"mobile": "Mobile number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile("+94${mobile!}");
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobile": err.message});
      }
    }

    /// Location Validations
    String? location = value.location;
    if (StringValidators.isEmpty(location)) {
      value.errors.addAll({"location": "Location is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class RegisterForm extends StatefulFormWidget<RegisterFormValue> {
  const RegisterForm({super.key, required super.controller, this.disabledFields = const []});

  final List<String> disabledFields;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with FormMixin {
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController mobileTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: firstNameTextEditingController,
              decoration: InputDecoration(
                // hintText: "First Name",
                hintText: AppLocalizations.of(context)!.nN_026,
                errorText: formValue.getError("firstName"),
              ),
              onChanged: (value) {
                widget.controller.setValue(
                  widget.controller.value..firstName = value,
                );
                (widget.controller as RegisterFormController).validateFirstName();
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: lastNameTextEditingController,
              decoration: InputDecoration(
                // hintText: "Last Name",
                hintText: AppLocalizations.of(context)!.nN_027,
                errorText: formValue.getError("lastName"),
              ),
              onChanged: (value) {
                widget.controller.setValue(
                  widget.controller.value..lastName = value,
                );
                (widget.controller as RegisterFormController).validateLastName();
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !widget.disabledFields.contains("email"),
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
            GooglePlacesAutoCompleteTextFormField(
              textEditingController: locationTextEditingController,
              googleAPIKey: locate<LocatorConfig>().googlePlacesApiKey,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.nN_028,
                suffixIcon: const Icon(Icons.location_on_outlined),
                errorText: formValue.getError("location"),
              ),
              overlayContainer: (child) => Material(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                  child: child,
                ),
              ),
              isLatLngRequired: true,
              itmClick: (prediction) {
                widget.controller.setValue(
                  widget.controller.value..location = prediction.description,
                );
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: widget.controller.value.locale,
              decoration: InputDecoration(
                hintText: formValue.locale,
                errorText: formValue.getError("locale"),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'sin', child: Text('සිංහල')),
                DropdownMenuItem(value: 'tam', child: Text('தமிழ்')),
              ],
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..locale = value,
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
            )
          ],
        );
      },
    );
  }

  @override
  void init() {
    handleFormControllerEvent();
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    try {
      final value = widget.controller.value;

      final firstName = value.firstName ?? "";
      firstNameTextEditingController.value = firstNameTextEditingController.value.copyWith(
        text: firstName,
      );

      final lastName = value.lastName ?? "";
      lastNameTextEditingController.value = lastNameTextEditingController.value.copyWith(
        text: lastName,
      );

      final email = value.email ?? "";
      emailTextEditingController.value = emailTextEditingController.value.copyWith(
        text: email,
      );

      final mobile = value.mobile ?? "";
      mobileTextEditingController.value = mobileTextEditingController.value.copyWith(
        text: mobile,
      );

      final location = value.location ?? "";
      locationTextEditingController.value = locationTextEditingController.value.copyWith(
        text: location,
      );
    } on Error catch (_) {}
  }
}

class RegisterFormView extends StatelessWidget {
  const RegisterFormView({
    Key? key,
    required this.onDone,
    required this.controller,
    required this.canGoBack,
    this.onFacebookOptionSelect,
    this.onGoogleOptionSelect,
    this.onAppleOptionSelect,
    this.disabledFields = const [],
  }) : super(key: key);

  final bool canGoBack;
  final RegisterFormController controller;
  final FutureOr Function(RegisterFormValue) onDone;
  final FutureOr Function()? onFacebookOptionSelect;
  final FutureOr Function()? onGoogleOptionSelect;
  final FutureOr Function()? onAppleOptionSelect;
  final List<String> disabledFields;

  handleRegister() async {
    if (await controller.validate()) {
      onDone(controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
              // "REGISTER WITH NAWA NIWASA",
              AppLocalizations.of(context)!.nN_025.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RegisterForm(controller: controller, disabledFields: disabledFields),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FilledButton(
              onPressed: handleRegister,
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
              // child: const Text("Register"),
              child: Text(AppLocalizations.of(context)!.nN_032),
            ),
          ),

          /// Check if there are more options
          if (onFacebookOptionSelect != null || onGoogleOptionSelect != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Text(
                "OR",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
              ),
            ),
          if (onFacebookOptionSelect != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GoogleSignOnButton(
                onPressed: onGoogleOptionSelect!,
              ),
            ),
          const SizedBox(height: 20),
          if (onGoogleOptionSelect != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FacebookSignOnButton(
                onPressed: onFacebookOptionSelect!,
              ),
            ),
          const SizedBox(height: 20),
          if (onAppleOptionSelect != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AppleSignOnButton(
                onPressed: onAppleOptionSelect!,
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

showRegistrationFormDialog(BuildContext context, {required RegisterFormController controller}) => showDialog(
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
                  child: RegisterFormView(
                    controller: controller,
                    disabledFields: const ["email"],
                    canGoBack: true,
                    onDone: (value) => Navigator.of(context).pop(value),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: BackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

showRegistrationDialog(
  BuildContext context, {
  required Future Function(RegisterFormValue value) onDone,
}) =>
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) {
        RegisterFormController controller = RegisterFormController(
          initialValue: RegisterFormValue.empty()
            ..locale = "en"
            ..location = "",
        );

        RegistrationViewService service = RegistrationViewService();
        service.context = context;

        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    child: RegisterFormView(
                      controller: controller,
                      canGoBack: true,
                      onDone: (value) async {
                        await service.register(value);
                      },
                      onGoogleOptionSelect: () async {
                        await service.registerWithGoogle();
                      },
                      onFacebookOptionSelect: () async {
                        await service.registerWithFacebook();
                      },
                      onAppleOptionSelect: () async {
                        await service.registerWithApple();
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

class RegistrationViewService {
  late BuildContext context;

  register(RegisterFormValue value) async {
    try {
      RestService restService = locate<RestService>();

      final mobile = "+94${value.mobile}";
      await restService.applyRegistration(
        firstName: value.firstName,
        lastName: value.lastName,
        email: value.email,
        mobileNo: mobile,
        geoLocation: value.location,
        language: value.locale,
        socialUser: false,
      );

      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "OTP has been sent",
          subtitle: "Please check your messages",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );

      if (context.mounted) {
        final authorizationCode = await showOtpDialog(
          context,
          email: value.email!,
          mobile: mobile,
        );

        if (authorizationCode == null) return;

        if (context.mounted) {
          final password = await showPasswordConfirmationDialog(context);

          await restService.completeRegistration(
            authorizationCode: authorizationCode,
            password: password,
          );
        }
      }

      if (context.mounted) Navigator.of(context).pop();
    } on ConflictedUserException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Account already exists",
          subtitle: "Account already exists",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }

  registerWithApple() async {
    RestService restService = locate<RestService>();
    final authResult = await AppleAuthService.getUserData();

    if (context.mounted) {
      final names = UserData.splitName(authResult?.data.name ?? "");
      RegisterFormValue? registrationData = await showRegistrationFormDialog(
        context,
        controller: RegisterFormController(
          initialValue: RegisterFormValue.empty()
            ..email = authResult?.data.email
            ..firstName = names.first
            ..lastName = names[1]
            ..locale = "en"
            ..location = "",
        ),
      );

      if (registrationData == null) return;

      final mobile = "+94${registrationData.mobile}";
      await restService.applyRegistration(
        firstName: registrationData.firstName,
        lastName: registrationData.lastName,
        email: registrationData.email,
        mobileNo: mobile,
        geoLocation: registrationData.location,
        language: registrationData.locale,
        socialUser: true,
        socialLogin: "apple",
        socialToken: authResult?.tokens.accessToken,
      );

      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "OTP has been sent",
          subtitle: "Please check your messages",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );

      if (context.mounted) {
        final authorizationCode = await showOtpDialog(
          context,
          email: registrationData.email!,
          mobile: mobile,
        );

        if (authorizationCode == null) return;

        if (context.mounted) {
          await restService.completeRegistration(
            authorizationCode: authorizationCode,
          );
        }
      }

      if (context.mounted) Navigator.of(context).pop();
    }
  }

  registerWithFacebook() async {
    try {
      RestService restService = locate<RestService>();

      final authResult = await FacebookAuthService.getUserData();

      if (context.mounted) {
        final names = UserData.splitName(authResult?.data.name ?? "");
        RegisterFormValue? registrationData = await showRegistrationFormDialog(
          context,
          controller: RegisterFormController(
            initialValue: RegisterFormValue.empty()
              ..email = authResult?.data.email
              ..firstName = names.first
              ..lastName = names[1]
              ..locale = "en"
              ..location = "",
          ),
        );

        if (registrationData == null) return;

        final mobile = "+94${registrationData.mobile}";
        await restService.applyRegistration(
          firstName: registrationData.firstName,
          lastName: registrationData.lastName,
          email: registrationData.email,
          mobileNo: mobile,
          geoLocation: registrationData.location,
          language: registrationData.locale,
          socialUser: true,
          socialLogin: "facebook",
          socialToken: authResult?.tokens.accessToken,
        );

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "OTP has been sent",
            subtitle: "Please check your messages",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );

        if (context.mounted) {
          final authorizationCode = await showOtpDialog(
            context,
            email: registrationData.email!,
            mobile: mobile,
          );

          if (authorizationCode == null) return;

          if (context.mounted) {
            await restService.completeRegistration(
              authorizationCode: authorizationCode,
            );
          }
        }

        if (context.mounted) Navigator.of(context).pop();
      }
    } on ConflictedUserException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Account already exists",
          subtitle: "Account already exists",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }

  registerWithGoogle() async {
    try {
      RestService restService = locate<RestService>();

      final authResult = await GoogleAuthService.getUserData();

      if (context.mounted) {
        final names = UserData.splitName(authResult?.data.name ?? "");
        RegisterFormValue registrationData = await showRegistrationFormDialog(
          context,
          controller: RegisterFormController(
            initialValue: RegisterFormValue.empty()
              ..email = authResult?.data.email
              ..firstName = names.first
              ..lastName = names[1]
              ..locale = "en"
              ..location = "",
          ),
        );

        final mobile = "+94${registrationData.mobile}";
        await restService.applyRegistration(
          firstName: registrationData.firstName,
          lastName: registrationData.lastName,
          email: registrationData.email,
          mobileNo: mobile,
          geoLocation: registrationData.location,
          language: registrationData.locale,
          socialUser: true,
          socialLogin: "google",
          socialToken: authResult?.tokens.idToken,
        );

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "OTP has been sent",
            subtitle: "Please check your messages",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );

        if (context.mounted) {
          final authorizationCode = await showOtpDialog(
            context,
            email: registrationData.email!,
            mobile: mobile,
          );

          if (authorizationCode == null) return;

          if (context.mounted) {
            await restService.completeRegistration(
              authorizationCode: authorizationCode,
            );
          }
        }

        if (context.mounted) Navigator.of(context).pop();
      }
    } on ConflictedUserException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Account already exists",
          subtitle: "Account already exists",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }
}
