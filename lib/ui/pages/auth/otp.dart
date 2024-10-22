import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../l10n.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../../util/util.dart';
import '../../ui.dart';

enum OtpMedium { email, mobile }

class OtpView extends StatefulWidget {
  const OtpView({
    Key? key,
    this.mobile,
    this.obfuscateMobile = true,
    this.medium = OtpMedium.mobile,
    required this.onDone,
    required this.onCancel,
    required this.onResend,
  }) : super(key: key);

  final String? mobile;
  final bool obfuscateMobile;
  final Function(String code) onDone;
  final Function() onResend;
  final Function() onCancel;
  final OtpMedium medium;

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? error;

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  handleResendOTP() async {
    widget.onResend();
  }

  String? validate() {
    if (controller.text.trim().isEmpty || controller.text.length < 6) {
      return "Please enter 6 digits OTP";
    }
    return null;
  }

  handleOtp() async {
    String? error = validate();
    setState(() => this.error = error);
    if (error == null) {
      return widget.onDone(controller.text);
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
                // "VERIFICATION CODE",
                AppLocalizations.of(context)!.nN_1000.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              Text(
                // "Please enter the 6-digit OTP sent to your\n mobile, "
                "${AppLocalizations.of(context)!.nN_1001} "
                "${widget.obfuscateMobile ? obfuscateMobile(widget.mobile!) : widget.mobile}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 70),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              errorText: error,
            ),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Pinput(
                length: 6,
                controller: controller,
                focusNode: focusNode,
                errorText: error,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 70),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FilledButton(
            onPressed: handleOtp,
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
            // child: const Text("Verify"),
            child: Text(AppLocalizations.of(context)!.nN_1002),
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
            child: Text(AppLocalizations.of(context)!.nN_161),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // "Didn't receive OTP?",
              AppLocalizations.of(context)!.nN_1003,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.blue),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: handleResendOTP,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: AppColors.blue.withOpacity(0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  // "Resend",
                  AppLocalizations.of(context)!.nN_1004,
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
      ],
    );
  }
}

showOtpDialog(
  BuildContext context, {
  required String email,
  required String mobile,
}) =>
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) {
        return Material(
          child: SafeArea(
            child: SingleChildScrollView(
              child: OtpView(
                mobile: mobile,
                onCancel: Navigator.of(context).pop,
                onResend: () async {
                  try {
                    RestService restService = locate<RestService>();
                    await restService.sendOtp(mobile, method: OtpMethod.mobile);

                    locate<PopupController>().addItemFor(
                      DismissiblePopup(
                        title: "OTP has been sent",
                        subtitle: "Please check your messages",
                        color: Colors.green,
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
                },
                onDone: (value) async {
                  try {
                    RestService restService = locate<RestService>();
                    final authorizationCode = await restService.verifyOtp(email, value);
                    if (context.mounted) Navigator.of(context).pop(authorizationCode);
                  } catch (err) {
                    locate<PopupController>().addItemFor(
                      DismissiblePopup(
                        title: "OTP is not valid",
                        subtitle: "Please resend and try again",
                        color: Colors.red,
                        onDismiss: (self) => locate<PopupController>().removeItem(self),
                      ),
                      const Duration(seconds: 5),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
