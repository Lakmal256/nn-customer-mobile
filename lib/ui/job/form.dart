import 'package:flutter/material.dart';
import 'package:nawa_niwasa/service/service.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../ui/ui.dart';
import '../../util/util.dart';

class JobFormValue {
  JobTypeDto? typeOfRepair;
  String? title;
  String? location;
  String? description;
  List<ImageReference> images;
  List<JobTypeDto> jobTypeOptions;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  JobFormValue.empty()
      : jobTypeOptions = List.empty(growable: true),
        images = List.empty(growable: true);
}

class JobFormController extends FormController<JobFormValue> {
  JobFormController({required super.initialValue});

  /// Using to validate image upload duplication
  List<ImageBoxImage> fileRefs = List.empty(growable: true);

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? description = value.description;
    if (StringValidators.isEmpty(description)) {
      value.errors.addAll({"description": "Description is required"});
    } else {
      if (description!.length > 250) {
        value.errors.addAll({"description": "The maximum character limit of 250 has been exceeded"});
      }
    }

    String? location = value.location;
    if (StringValidators.isEmpty(location)) {
      value.errors.addAll({"location": "Location is required"});
    }

    String? title = value.title;
    if (StringValidators.isEmpty(title)) {
      value.errors.addAll({"title": "Title is required"});
    } else {
      try{
        StringValidators.isPureWithSingleWhiteSpace(title!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"title": err.message});
      }
    }

    JobTypeDto? typeOfRepair = value.typeOfRepair;
    if (typeOfRepair == null) {
      value.errors.addAll({"tor": "Type of repair is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class JobForm extends StatefulFormWidget<JobFormValue> {
  const JobForm({super.key, required super.controller});

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> with FormMixin {
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          children: [
            TextField(
              controller: titleTextEditingController,
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
            InputDecorator(
              decoration: InputDecoration(
                // label: const Text("Type of Repair"),
                label: Text(AppLocalizations.of(context)!.nN_072),
                errorText: formValue.getError("tor"),
              ),
              child: DropdownButton(
                isExpanded: true,
                // hint: const Text("Select Type"),
                hint: Text(AppLocalizations.of(context)!.nN_072),
                isDense: true,
                underline: const SizedBox.shrink(),
                onChanged: (value) => widget.controller.setValue(
                  widget.controller.value..typeOfRepair = value,
                ),
                value: formValue.typeOfRepair,
                items: formValue.jobTypeOptions
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text("${type.jobTypeName}"),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationTextEditingController,
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
                  controller: descriptionTextEditingController,
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
          ],
        );
      },
    );
  }
}

class StandaloneJobFormView extends StatefulWidget {
  const StandaloneJobFormView({super.key});

  @override
  State<StandaloneJobFormView> createState() => _StandaloneJobFormViewState();
}

class _StandaloneJobFormViewState extends State<StandaloneJobFormView> {
  JobFormController controller = JobFormController(initialValue: JobFormValue.empty());

  @override
  void initState() {
    fetchAllJobTypes();
    super.initState();
  }

  fetchAllJobTypes() async {
    final jobTypes = await locate<RestService>().getAllJobTypes();
    controller.setValue(controller.value..jobTypeOptions = jobTypes);
  }

  handleJobPost() async {
    if (await controller.validate()) {
      try {
        locate<ProgressIndicatorController>().show();
        final user = locate<UserService>().value;
        locate<RestService>().createJob(
          title: controller.value.title!,
          jobType: controller.value.typeOfRepair!.jobTypeName!,
          customerEmail: user!.data.email!,
          jobDescription: controller.value.description!,
          location: controller.value.location!,
          image: controller.value.images.fold("", (previousValue, element) => "$previousValue\n${element.bucketReference}"),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: JobForm(
                  controller: controller,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
            child: FilledButton(
              onPressed: handleJobPost,
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
              // child: const Text("Post"),
              child: Text(AppLocalizations.of(context)!.nN_078),
            ),
          ),
        ],
      ),
    );
  }
}
