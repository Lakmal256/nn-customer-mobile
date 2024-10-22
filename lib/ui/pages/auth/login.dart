import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/auth/apple.dart';
import 'package:nawa_niwasa/router.dart';

import '../../../auth/facebook.dart';
import '../../../auth/google.dart';
import '../../../l10n.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../../util/util.dart';
import '../../ui.dart';

class LoginFormValue extends FormValue {
  String? userName;
  String? password;

  LoginFormValue({this.userName, this.password});
}

class LoginFormController extends FormController<LoginFormValue> {
  LoginFormController() : super(initialValue: LoginFormValue(password: "", userName: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    /// Uname | Email Validations
    String? email = value.userName;
    if (StringValidators.isEmpty(email)) {
      value.errors.addAll({"uName": "Email is required"});
    } else {
      try {
        StringValidators.email(email!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"uName": err.message});
      }
    }

    String? password = value.password;
    if (StringValidators.isEmpty(password)) {
      value.errors.addAll({"pwd": "Password is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class LoginForm extends StatefulFormWidget<LoginFormValue> {
  const LoginForm({
    Key? key,
    required LoginFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with FormMixin {
  TextEditingController uNameTextEditingController = TextEditingController();
  TextEditingController pWDTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: uNameTextEditingController,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                // hintText: "Email",
                hintText: AppLocalizations.of(context)!.nN_003,
                errorText: formValue.getError("uName"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..userName = value,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pWDTextEditingController,
              obscureText: true,
              decoration: InputDecoration(
                // hintText: "Password",
                hintText: AppLocalizations.of(context)!.nN_004,
                errorText: formValue.getError("pwd"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..password = value,
              ),
            )
          ],
        );
      },
    );
  }
}

class LoginFormView extends StatelessWidget {
  LoginFormView({
    Key? key,
    required this.onRegularLogin,
    this.onRegisterSelect,
    this.onFacebookLogin,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.onContinueAsGuest,
    this.onResetPasswordPress,
  }) : super(key: key);

  final LoginFormController controller = LoginFormController();
  final Function(LoginFormValue value) onRegularLogin;
  final Function()? onFacebookLogin;
  final Function()? onGoogleLogin;
  final Function()? onAppleLogin;
  final Function()? onRegisterSelect;
  final Function()? onContinueAsGuest;
  final Function()? onResetPasswordPress;

  handleLogin() async {
    if (await controller.validate()) {
      onRegularLogin(controller.value);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // "Welcome!",
                AppLocalizations.of(context)!.nN_001,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                // "Please login or sign up to continue our app",
                AppLocalizations.of(context)!.nN_002,
                style: Theme.of(context).textTheme.labelLarge,
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: LoginForm(controller: controller),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FilledButton(
            onPressed: handleLogin,
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
            // child: const Text("Login"),
            child: Text(AppLocalizations.of(context)!.nN_005),
          ),
        ),
        const SizedBox(height: 30),
        if (onGoogleLogin != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: GoogleSignOnButton(
              onPressed: onGoogleLogin!,
            ),
          ),
        const SizedBox(height: 20),
        if (onFacebookLogin != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FacebookSignOnButton(
              onPressed: onFacebookLogin!,
            ),
          ),
        const SizedBox(height: 20),
        if (onAppleLogin != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AppleSignOnButton(
              onPressed: onAppleLogin!,
            ),
          ),
        const SizedBox(height: 30),
        Text(
          // "Don’t have an account?",
          AppLocalizations.of(context)!.nN_008,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              onTap: onContinueAsGuest,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: AppColors.blue.withOpacity(0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  // "Continue as Guest",
                  AppLocalizations.of(context)!.nN_1055,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // const Text('or'),
            Text(AppLocalizations.of(context)!.nN_1056),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onRegisterSelect,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: AppColors.blue.withOpacity(0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  // "Register",
                  AppLocalizations.of(context)!.nN_009,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (onResetPasswordPress != null)
          Visibility(
            visible: onResetPasswordPress != null,
            child: GestureDetector(
              onTap: onResetPasswordPress,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: AppColors.blue.withOpacity(0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  // "Forgot password?",
                  AppLocalizations.of(context)!.nN_010,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.blue),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

UserType _getUserType(TokenResponse? response) {
  if (response != null) {
    return response.user!.email == 'guestuser@mailinator.com' ? UserType.guest : UserType.normal;
  }

  return UserType.guest;
}

class LoginFormStandaloneView extends StatelessWidget {
  const LoginFormStandaloneView({super.key});

  handleTokenResponse(BuildContext context, TokenResponse? response) async {
    final user = User(sessionId: response!.identityId!, data: response.user!, type: _getUserType(response));
    locate<UserService>().setValue(user);

    locate<PermissionService>().permits = switch (user.type) {
      UserType.guest => ["toUseAuthService", "toViewShop"],
      UserType.normal => [r'.*'], // Wild card permission
    };

    if (locate<ListenablePermissionService>().request(['toUseAuthService'])) {
      locate<RestAuthService>().setData(
        AuthData(
          identityId: response.identityId!,
          accessToken: response.token!,
          refreshToken: response.refreshToken!,
          userIdentificationRecord: response.user!.email!,
        ),
      );
    }

    if (user.type == UserType.guest) {
      if (locate<ListenablePermissionService>().request(['toViewShop'])) {
        return GoRouter.of(context).go(AppRoutes.store);
      }
    }

    locate<DraftCartHandler>().sync();
    locate<InAppNotificationHandler>().sync();
    locate<BannerItemHandler>().sync();

    await locate<CloudMessagingHelperService>().requestPermission();
    await locate<CloudMessagingHelperService>().registerDeviceToken();

    await locate<DeviceLocationService>().requestServicePermission();
    final hasLocationPermission = await locate<DeviceLocationService>().requestLocationPermission();
    if (hasLocationPermission) {
      final ld = await locate<DeviceLocationService>().location;
      await locate<RestService>().updateDeviceLocation(
        latitude: ld.latitude!,
        longitude: ld.longitude!,
      );
    }

    if (context.mounted) GoRouter.of(context).go(AppRoutes.launcher);
  }

  handleError(dynamic error) {
    if (error is UserNotFoundException) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User not found",
          subtitle: "There is no user record corresponding to this Email address",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else if (error is UnauthorizedException) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Invalid login credentials",
          subtitle: "You may have entered invalid username or password",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else if (error is BlockedUserException) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User Deactivated",
          subtitle: "Your account has been deactivated",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else if (error is PasswordResetException) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Password reset error",
          subtitle: error.message,
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else if (error is PasswordException) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Password error",
          subtitle: error.message,
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else {
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

  handleResetPassword(BuildContext context) async {
    try {
      RestService restService = locate<RestService>();
      final value = await showIdentityDialog(context);
      if (value == null) return;

      locate<ProgressIndicatorController>().show();

      UserResponseDto? user;
      if (!StringValidators.isEmpty(value.email)) {
        user = await restService.getUserByEmail(value.email!);
      } else if (value.mobile != null) {
        user = await restService.getUserByMobile(value.fullMobile!);
      }

      if (user == null || user.email == null) throw Exception();
      await restService.sendOtp(user.email!);

      locate<ProgressIndicatorController>().hide();

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
        final authorizationCode = await showOtpDialog(context, email: user.email!, mobile: user.mobileNo!);
        if (authorizationCode == null) return;

        if (context.mounted) {
          final password = await showPasswordConfirmationDialog(context);
          if (password == null) return;

          locate<ProgressIndicatorController>().show();

          await restService.resetPasswordWithAuthorizationCode(
            authorizationCode,
            password: password,
          );

          locate<ProgressIndicatorController>().hide();

          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Success",
              subtitle: "Password reset successful",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
        }
      }
    } catch (error) {
      handleError(error);
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: LoginFormView(
            onAppleLogin: () async {
              try {
                locate<ProgressIndicatorController>().show();
                RestService restService = locate<RestService>();
                final userData = await AppleAuthService.getUserData();
                if (userData != null) {
                  final response = await restService.socialLogin(
                    username: userData.data.email!,
                    socialLoginType: "apple",
                    socialToken: userData.tokens.idToken!,
                  );
                  if (context.mounted) handleTokenResponse(context, response);
                }
              } catch (error) {
                handleError(error);
              } finally {
                locate<ProgressIndicatorController>().hide();
              }
            },
            onGoogleLogin: () async {
              try {
                locate<ProgressIndicatorController>().show();
                RestService restService = locate<RestService>();
                final userData = await GoogleAuthService.getUserData();
                if (userData != null) {
                  final response = await restService.socialLogin(
                    username: userData.data.email!,
                    socialLoginType: "google",
                    socialToken: userData.tokens.idToken!,
                  );
                  if (context.mounted) handleTokenResponse(context, response);
                } else {
                  throw Exception();
                }
              } catch (error) {
                handleError(error);
              } finally {
                locate<ProgressIndicatorController>().hide();
              }
            },
            onFacebookLogin: () async {
              try {
                locate<ProgressIndicatorController>().show();
                RestService restService = locate<RestService>();
                final userData = await FacebookAuthService.getUserData();
                if (userData != null) {
                  final response = await restService.socialLogin(
                    username: userData.data.email!,
                    socialLoginType: "facebook",
                    socialToken: userData.tokens.accessToken!,
                  );
                  if (context.mounted) handleTokenResponse(context, response);
                } else {
                  throw Exception();
                }
              } catch (error) {
                handleError(error);
              } finally {
                locate<ProgressIndicatorController>().hide();
              }
            },
            onRegularLogin: (LoginFormValue value) async {
              try {
                locate<ProgressIndicatorController>().show();
                RestService restService = locate<RestService>();
                final response = await restService.login(uName: value.userName!, pwd: value.password!);
                if (context.mounted) handleTokenResponse(context, response);
              } catch (error) {
                handleError(error);
              } finally {
                locate<ProgressIndicatorController>().hide();
              }
            },
            onContinueAsGuest: () async {
              try {
                locate<ProgressIndicatorController>().show();
                RestService restService = locate<RestService>();
                final response = await restService.login(uName: 'guestuser@mailinator.com', pwd: 'abcd@123');
                if (context.mounted) handleTokenResponse(context, response);
              } catch (error) {
                handleError(error);
              } finally {
                locate<ProgressIndicatorController>().hide();
              }
            },
            onResetPasswordPress: () => handleResetPassword(context),
            onRegisterSelect: () async {
              await showRegistrationDialog(context, onDone: (value) async {});
            },
          ),
        ),
      ),
    );
  }
}
