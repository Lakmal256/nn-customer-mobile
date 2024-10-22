import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' show extension;
import '../../l10n.dart';
import '../../service/service.dart';
import '../../util/util.dart';
import '../../locator.dart';
import '../ui.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = ProfileFormController(
    initialValue: ProfileFormValue.empty(),
  );
  late Future<UserResponseDto?> action;
  late UserResponseDto? unTouchedData;

  @override
  void initState() {
    fetchUser();
    super.initState();
  }

  fetchUser() {
    setState(() {
      action = () async {
        String email = locate<UserService>().value!.data.email!;
        final data = await locate<RestService>().getUserByEmail(email);
        var number = data?.mobileNo ?? "";

        /// Currently system handles two number formats; 0 & +94
        /// Take last 9 characters
        number = number.substring(number.length - 9);
        unTouchedData = data?..mobileNo = number;
        controller.setValue(controller.value.copyWith(
          firstName: data?.firstName,
          lastName: data?.lastName,
          location: data?.geoLocation,
          email: data?.email,
          imagePath: ImageReference(
            fullPath: data?.profileImageUrl ?? "",
            bucketReference: data?.profileImage ?? "",
          ),
          mobileNumber: number,
        ));
        return data;
      }.call();
    });
  }

  updateProfile() async {
    if (await controller.validate()) {
      String mobileNumber = "+94${controller.value.mobileNumber}";

      try {
        /// Handle mobile change is there is any
        if (isMobileNumberTouched) {
          locate<ProgressIndicatorController>().show();
          await locate<RestService>().initUpdateMobile(mobileNumber);
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
            final authorizationCode = await showOtpDialog(
              context,
              email: controller.value.email!,
              mobile: mobileNumber,
            );

            if (authorizationCode == null) return;
            await locate<RestService>().completeUpdateMobile(mobileNumber, authorizationCode);
          }
        }

        locate<ProgressIndicatorController>().show();
        await locate<RestService>().updateUser(
          firstName: controller.value.firstName,
          lastName: controller.value.lastName,
          email: controller.value.email,
          mobileNo: mobileNumber,
          profileImage: controller.value.imagePath!.bucketReference,
          geoLocation: controller.value.location,
        );

        if (isMobileNumberTouched) {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Success",
              subtitle: "Mobile number reset successful",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          if (context.mounted) GoRouter.of(context).go("/login");
        }

        fetchUser();
      } on ConflictedUserException {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "The mobile number already exists",
            subtitle: "Sorry, Please enter a different number",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } catch (_) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Something went wrong",
            subtitle: "Sorry, something went wrong here",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }
  }

  handleProfileImageUpload(ImageReference? initialPath) async {
    showBottomSheet(
      context: context,
      builder: (context) => ImageEditorView(
        initialValue: initialPath,
        onDone: (path) {
          controller.setValue(controller.value.copyWith(
            imagePath: path,
          ));
          updateProfile();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: action,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileViewHeader(
                        coverUrl: Uri.https(
                          locate<LocatorConfig>().imageBaseUrl,
                          '/images/Builder_Creation_Cover.png',
                        ).toString(),
                        avatarUrl: snapshot.data?.profileImageUrl,
                        onProfileChange: () => handleProfileImageUpload(
                          ImageReference(
                            fullPath: snapshot.data!.profileImageUrl ?? "",
                            bucketReference: snapshot.data!.profileImage ?? "",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ProfileForm(controller: controller),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: StandaloneReferralUrl(),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: UserDeactivateButton(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
                child: FilledButton(
                  onPressed: updateProfile,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                    backgroundColor: MaterialStateProperty.all(AppColors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  // child: const Text("Save Changes"),
                  child: Text(AppLocalizations.of(context)!.nN_1012),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  bool get isMobileNumberTouched => unTouchedData?.mobileNo != controller.value.mobileNumber;
}

class StandaloneReferralUrl extends StatelessWidget {
  const StandaloneReferralUrl({super.key});

  handleCopyToClipboard(String data) async {
    await Clipboard.setData(ClipboardData(text: data));
    locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "Copied to clipboard",
        subtitle: "Referral link has been copied",
        color: Colors.green,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locate<RestService>().getReferral(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // "Referral Link",
              AppLocalizations.of(context)!.nN_196,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(child: Text(snapshot.data ?? "N/A")),
                IconButton.outlined(
                  onPressed: () => handleCopyToClipboard(snapshot.data!),
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            Text(
              AppLocalizations.of(context)!.nN_197,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        );
      },
    );
  }
}

class ProfileViewHeader extends StatelessWidget {
  final String coverUrl;
  final String? avatarUrl;
  final Function() onProfileChange;
  const ProfileViewHeader({
    Key? key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.onProfileChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 100),
          height: MediaQuery.of(context).size.height / 5,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: NetworkImage(coverUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0.0, (MediaQuery.of(context).size.height / 5) - 60),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: CircleAvatar(
                    radius: 55.0,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  ),
                ),
                OutlinedButton(
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(StadiumBorder()),
                  ),
                  onPressed: onProfileChange,
                  // child: const Text("Edit profile picture"),
                  child: Text(AppLocalizations.of(context)!.nN_1023),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserDeactivateButton extends StatefulWidget {
  const UserDeactivateButton({super.key});

  @override
  State<UserDeactivateButton> createState() => _UserDeactivateButtonState();
}

class _UserDeactivateButtonState extends State<UserDeactivateButton> {
  Future<bool>? action;

  handleAction() async {
    setState(() {
      action = locate<RestService>().deactivateUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
          future: action,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            return const SizedBox.shrink();
          },
        ),
        Text(
          // "Delete Account",
          AppLocalizations.of(context)!.nN_1028,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          // "This action will delete your account.",
          AppLocalizations.of(context)!.nN_1029,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          onPressed: handleAction,
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
            visualDensity: VisualDensity.standard,
            // backgroundColor: const MaterialStatePropertyAll(Colors.red),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                side: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          child: Text(
            // "Delete",
            AppLocalizations.of(context)!.nN_1030,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ImageEditorView extends StatefulWidget {
  final Function(ImageReference? path) onDone;
  final ImageReference? initialValue;
  const ImageEditorView({super.key, required this.onDone, this.initialValue});

  @override
  State<ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  List<String> extensions = ["jpg", "jpeg", "png"];
  ImageReference? imagePath;
  late Future<String?> action;

  @override
  void initState() {
    imagePath = widget.initialValue;
    super.initState();
  }

  handleUpload(Source source) async {
    action = () async {
      late File? file;
      try {
        locate<ProgressIndicatorController>().show();

        file = await pickFile(source, extensions: extensions);
        if (file == null) return null;

        String fileExtension = extension(file.path);
        if (!extensions.any((ext) => ext == fileExtension.substring(1))) {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Extension is not supported",
              subtitle: "Extension: $fileExtension is not supported",
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          return;
        }

        if (file.lengthSync() > 5e+6) {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "File is too large",
              subtitle: "File size is larger than 5MB",
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          return;
        }

        final result = await locate<RestService>().uploadBase64EncodeAsync(await fileToBase64(file));
        if (result == null) throw Exception();

        /// Get full image url from file name
        String path = await locate<RestService>().getFullFilePath(result);

        setState(() {
          imagePath = ImageReference(fullPath: path, bucketReference: result);
        });

        widget.onDone(imagePath);
      } catch (error) {
        rethrow;
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }.call();
  }

  handleCameraUpload() async {
    handleUpload(Source.camera);
  }

  handleGalleryUpload() async {
    handleUpload(Source.gallery);
  }

  handleRemove() async {
    var user = locate<UserService>().value!.data;
    String? path = "https://ui-avatars.com/api/?background=random&name=${user.firstName}+${user.lastName}";
    setState(() {
      imagePath = ImageReference(fullPath: path, bucketReference: "");
    });
    widget.onDone(imagePath);
  }

  Widget buildOption(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [Text(title), child],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF4A7A36).withOpacity(.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            constraints: const BoxConstraints.tightFor(width: double.infinity),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    // "Upload Image",
                    AppLocalizations.of(context)!.nN_1024,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A7A36),
                        ),
                  ),
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.cancel_outlined),
                  color: const Color(0xFF4A7A36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(5),
            child: CircleAvatar(
              radius: 55.0,
              backgroundImage: imagePath != null ? NetworkImage(imagePath!.fullPath) : null,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: handleCameraUpload,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          // Expanded(child: Text("Take Photo")),
                          Expanded(child: Text(AppLocalizations.of(context)!.nN_1025)),
                          const Icon(Icons.camera_alt_outlined),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                  InkWell(
                    onTap: handleGalleryUpload,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          // Expanded(child: Text("Choose Photo")),
                          Expanded(child: Text(AppLocalizations.of(context)!.nN_1026)),
                          const Icon(Icons.photo_size_select_actual_outlined),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                  InkWell(
                    onTap: handleRemove,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              // "Remove Photo",
                              AppLocalizations.of(context)!.nN_1027,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileFormValue {
  String? firstName;
  String? lastName;
  String? email;
  String? location;
  String? mobileNumber;
  // String? imagePath;
  ImageReference? imagePath;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  ProfileFormValue.empty();

  ProfileFormValue copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? location,
    String? mobileNumber,
    // String? imagePath,
    ImageReference? imagePath,
    Map<String, String>? errors,
  }) {
    return ProfileFormValue.empty()
      ..firstName = firstName ?? this.firstName
      ..lastName = lastName ?? this.lastName
      ..email = email ?? this.email
      ..location = location ?? this.location
      ..mobileNumber = mobileNumber ?? this.mobileNumber
      ..imagePath = imagePath
      ..errors = errors ?? this.errors;
  }
}

class ProfileFormController extends FormController<ProfileFormValue> {
  ProfileFormController({required super.initialValue});

  clear() {
    value = ProfileFormValue.empty();
  }

  @override
  Future<bool> validate() async {
    value.errors.clear();

    /// First Name Validations
    String? firstName = value.firstName;
    if (StringValidators.isEmpty(firstName)) {
      value.errors.addAll({"firstName": "First name is required"});
    } else {
      try {
        if (firstName!.length > 20) {
          value.errors.addAll({"firstName": "You have exceeded the maximum number of 20 characters"});
        }
        StringValidators.isPure(firstName);
      } on ArgumentError catch (err) {
        value.errors.addAll({"firstName": err.message});
      }
    }

    /// Last Name Validations
    String? lastName = value.lastName;
    if (StringValidators.isEmpty(lastName)) {
      value.errors.addAll({"lastName": "Last name is required"});
    } else {
      try {
        if (lastName!.length > 20) {
          value.errors.addAll({"lastName": "You have exceeded the maximum number of 20 characters"});
        }
        StringValidators.isPure(lastName);
      } on ArgumentError catch (err) {
        value.errors.addAll({"lastName": err.message});
      }
    }

    /// Email Validations
    String? email = value.email;
    if (StringValidators.isEmpty(email)) {
      value.errors.addAll({"email": "Email is required"});
    } else {
      try {
        StringValidators.email(value.email!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"email": err.message});
      }
    }

    /// Location Validations
    String? location = value.location;
    if (StringValidators.isEmpty(location)) {
      value.errors.addAll({"location": "Location is required"});
    } else {
      if (location!.length > 20) {
        value.errors.addAll({"location": "You have exceeded the maximum number of 20 characters"});
      }
    }

    /// Mobile Validations
    String? mobile = value.mobileNumber;
    if (StringValidators.isEmpty(mobile)) {
      value.errors.addAll({"mobileNumber": "Mobile number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile("+94${mobile!}");
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobileNumber": err.message});
      }
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class ProfileForm extends StatefulFormWidget<ProfileFormValue> {
  const ProfileForm({super.key, required super.controller});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> with FormMixin {
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController contactNumberTextEditingController = TextEditingController();

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

      final location = value.location ?? "";
      locationTextEditingController.value = locationTextEditingController.value.copyWith(
        text: location,
      );

      final mobile = value.mobileNumber ?? "";
      contactNumberTextEditingController.value = contactNumberTextEditingController.value.copyWith(
        text: mobile,
      );
    } on Error catch (_) {
      super.handleFormControllerEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          children: [
            TextField(
              controller: firstNameTextEditingController,
              decoration: InputDecoration(
                // hintText: "First Name",
                hintText: AppLocalizations.of(context)!.nN_026,
                label: Text(AppLocalizations.of(context)!.nN_026),
                errorText: formValue.getError("firstName"),
              ),
              onChanged: (value) {
                widget.controller.setValue(
                  widget.controller.value..firstName = value,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: lastNameTextEditingController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.nN_027,
                label: Text(AppLocalizations.of(context)!.nN_027),
                errorText: formValue.getError("lastName"),
              ),
              onChanged: (value) {
                widget.controller.setValue(
                  widget.controller.value..lastName = value,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              enabled: false,
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.nN_003,
                label: Text(AppLocalizations.of(context)!.nN_003),
                errorText: formValue.getError("email"),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..email = value,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationTextEditingController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.nN_073,
                label: Text(AppLocalizations.of(context)!.nN_073),
                errorText: formValue.getError("location"),
              ),
              onChanged: (value) {
                widget.controller.setValue(
                  widget.controller.value..location = value,
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("+94"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: contactNumberTextEditingController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.nN_015,
                      label: Text(AppLocalizations.of(context)!.nN_015),
                      errorText: formValue.getError("mobileNumber"),
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..mobileNumber = value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
