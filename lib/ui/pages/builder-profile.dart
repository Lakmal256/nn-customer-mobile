import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';
import 'package:nawa_niwasa/ui/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n.dart';
import '../ui.dart';

class BuilderProfileView extends StatefulWidget {
  final BuilderDto builder;

  const BuilderProfileView({Key? key, required this.builder}) : super(key: key);

  @override
  State<BuilderProfileView> createState() => _BuilderProfileViewState();
}

class _BuilderProfileViewState extends State<BuilderProfileView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileViewImageWithAvatar(
                name: widget.builder.displayNameLong,
                coverUrl: "https://uat-customer.nawaniwasa.lk/images/Builder_Creation_Cover.png",
                avatarUrl:
                    widget.builder.profileImageUrl ?? 'https://uat-customer.nawaniwasa.lk/images/builderImge.jpg',
              ),
              JobDescription(widget.builder.jobDescription!),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: JobCard(
                  slot1: widget.builder.availability ?? "N/A",
                  slot2: widget.builder.jobType ?? "N/A",
                  slot3: widget.builder.contactNumber ?? "N/A",
                  slot4: widget.builder.id,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: GestureDetector(
            onTap: GoRouter.of(context).pop,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 30,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ItemContainer extends StatelessWidget {
  final Widget child;
  const ItemContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0x11000000),
      ),
      child: child,
    );
  }
}

class ProfileViewImageWithAvatar extends StatelessWidget {
  final String coverUrl;
  final String avatarUrl;
  final String name;
  const ProfileViewImageWithAvatar({
    Key? key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 80),
          height: MediaQuery.of(context).size.height / 5,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: NetworkImage(coverUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 160,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60.0,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55.0,
                      foregroundImage: NetworkImage(avatarUrl),
                      backgroundColor: Colors.white,
                      // backgroundImage: AssetImage("assets/images/user_p.png"),
                    ),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Builder',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: const Color(0xFFDA4540),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class JobDescription extends StatelessWidget {
  final String value;
  const JobDescription(this.value, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  /// Availability
  final String slot1;

  /// Job Type
  final String slot2;

  /// Mobile
  final String slot3;

  /// Builder id
  final int slot4;

  const JobCard({
    Key? key,
    required this.slot1,
    required this.slot2,
    required this.slot3,
    required this.slot4,
  }) : super(key: key);

  handleAssignJob(BuildContext context) async {
    var types = await locate<RestService>().getAllJobTypes();
    var type = (types).firstWhere((types) => types.jobTypeName == slot2);
    if (context.mounted) {
      var value = await showPrivateJobFormBottomSheet(
        context,
        jobType: type,
        controller: JobFormController(
          initialValue: JobFormValue.empty()..typeOfRepair = type,
        ),
      );
      if (value == null) return;
      try {
        locate<ProgressIndicatorController>().show();
        final user = locate<UserService>().value;
        await locate<RestService>().assignJob(
          builderId: slot4,
          title: value.title!,
          jobType: value.typeOfRepair!.jobTypeName!,
          customerEmail: user!.data.email!,
          jobDescription: value.description!,
          location: value.location!,
          image: value.images.fold("", (previousValue, element) => "$previousValue\n${element.bucketReference}"),
        );

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Successfully created",
            subtitle: "Job posted successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );

        if (context.mounted) Navigator.of(context).pop();
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
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }
  }

  handleSendMessage(BuildContext context) async {
    // if (context.mounted) {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (context) {
    //       return const MyMessagesView();
    //     }),
    //   );
    // }
    var builder = await locate<RestService>().getBuilderByMobile(slot3);
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return Material(
            child: ChatView(id: builder.id, name: builder.displayName),
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ItemContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Availability',
                      AppLocalizations.of(context)!.nN_083,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        slot1,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ItemContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Job Type',
                      AppLocalizations.of(context)!.nN_084,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        slot2,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ItemContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // "Contact Number",
                    AppLocalizations.of(context)!.nN_015,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(slot3),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => launchUrl(Uri.parse("tel://$slot3")),
                icon: const Icon(
                  Icons.call_outlined,
                  color: AppColors.red,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => handleAssignJob(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDA4540),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                // 'Assign a Job',
                AppLocalizations.of(context)!.nN_081,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => handleSendMessage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDA4540),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                // 'Send a Message',
                AppLocalizations.of(context)!.nN_082,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<JobFormValue?> showPrivateJobFormBottomSheet(
  BuildContext context, {
  required JobTypeDto jobType,
  required JobFormController controller,
}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => SingleChildScrollView(
        child: CreatePrivateJobBottomSheetView(
          controller: controller,
          onDone: (value) => Navigator.of(context).pop(value),
        ),
      ),
    );

class CreatePrivateJobBottomSheetView extends StatefulFormWidget<JobFormValue> {
  const CreatePrivateJobBottomSheetView({Key? key, required this.onDone, required JobFormController controller})
      : super(key: key, controller: controller);

  final Function(JobFormValue) onDone;

  @override
  State<CreatePrivateJobBottomSheetView> createState() => _CreatePrivateJobBottomSheetViewState();
}

class _CreatePrivateJobBottomSheetViewState extends State<CreatePrivateJobBottomSheetView> with FormMixin {
  // TextEditingController titleTextEditingController = TextEditingController();
  // TextEditingController locationTextEditingController = TextEditingController();
  // TextEditingController descriptionTextEditingController = TextEditingController();

  handleJobSubmit() async {
    var isValid = await widget.controller.validate();
    if (isValid) {
      widget.onDone(widget.controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                // controller: titleTextEditingController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.nN_071,
                  // label: const Text("Title"),
                  label: Text(AppLocalizations.of(context)!.nN_071),
                  errorText: formValue.getError("title"),
                ),
                onChanged: (value) {
                  widget.controller.setValue(
                    widget.controller.value..title = value,
                  );
                },
              ),
              const SizedBox(height: 20),
              TextField(
                // controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.nN_073,
                  // label: const Text("Location"),
                  label: Text(AppLocalizations.of(context)!.nN_073),
                  suffixIcon: const Icon(Icons.location_on_outlined),
                  errorText: formValue.getError("location"),
                ),
                onChanged: (value) {
                  widget.controller.setValue(
                    widget.controller.value..location = value,
                  );
                },
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  errorText: formValue.getError("description"),
                  // label: const Text("Enter the job description"),
                  label: Text(AppLocalizations.of(context)!.nN_074),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x08000000),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: Colors.black38,
                    ),
                  ),
                  child: TextField(
                    // controller: descriptionTextEditingController,
                    autocorrect: false,
                    maxLines: 5,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      // hintText: 'Description',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                    onChanged: (value) {
                      widget.controller.setValue(
                        widget.controller.value..description = value,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  errorText: formValue.getError("images"),
                  // label: const Text("Add an image"),
                  label: Text(AppLocalizations.of(context)!.nN_075),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                child: ImageBox(
                  maxCount: 5,
                  images: widget.controller.value.images.map((item) => ImageBoxImage(pathReference: item.fullPath, bucketPath: item.bucketReference)).toList(),
                  beforeUpload: (file) {
                    bool isDuplicate =
                        (widget.controller as JobFormController).fileRefs.any((item) => item.isSameFile(file));
                    return !isDuplicate;
                  },
                  onRemove: (image) {
                    (widget.controller as JobFormController).fileRefs.removeWhere((file) => file.isSame(image));
                    widget.controller.setValue(
                      widget.controller.value..images.remove(ImageReference(fullPath: image.pathReference, bucketReference: image.bucketPath)),
                    );
                  },
                  onUpload: (image) {
                    (widget.controller as JobFormController).fileRefs.add(image);
                    widget.controller.setValue(
                      widget.controller.value..images.add(ImageReference(fullPath: image.pathReference, bucketReference: image.bucketPath)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => handleJobSubmit(),
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
                child: Text(AppLocalizations.of(context)!.nN_193),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void handleFormControllerEvent() {
    super.handleFormControllerEvent();
  }
}

class StandaloneBuilderProfileView extends StatelessWidget {
  // final String mobile;
  final String nic;
  const StandaloneBuilderProfileView({super.key, required this.nic});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: locate<RestService>().getBuilderByNic(nic),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          return BuilderProfileView(builder: snapshot.data!);
        },
      ),
    );
  }
}
