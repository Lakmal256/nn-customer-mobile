import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../util/util.dart';
import '../ui.dart';

class ImageReference {
  ImageReference({required this.fullPath, required this.bucketReference});

  final String fullPath;
  final String bucketReference;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageReference && runtimeType == other.runtimeType && bucketReference == other.bucketReference;

  @override
  int get hashCode => bucketReference.hashCode;
}

class ComplaintWizardStateValue {
  ComplaintTypeDto? type;
  ComplaintProductCategoryDto? productCategory;
  ComplaintProductDto? product;
  String? name;
  String? businessName;
  String? contactNumber;
  String? location;
  String? description;
  List<ImageReference> images;
  Map<String, String> errors = {};

  ComplaintWizardStateValue() : images = List.empty(growable: true);

  String? getError(String key) => errors[key];
}

class ComplaintWizardController extends FormController<ComplaintWizardStateValue> {
  ComplaintWizardController({required super.initialValue});

  /// Using to validate image upload duplication
  List<ImageBoxImage> fileRefs = List.empty(growable: true);

  clear() {
    fileRefs.clear();
    value.images.clear();
    setValue(value);
  }

  @override
  Future<bool> validate() async {
    value.errors.clear();

    /// Name Validations
    String? name = value.name;
    if (StringValidators.isEmpty(name)) {
      value.errors.addAll({"name": "Name is required"});
    } else {
      try {
        StringValidators.isPureWithSingleWhiteSpace(name!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"name": err.message});
      }
    }

    /// Mobile Validations
    String? mobile = value.contactNumber;
    if (StringValidators.isEmpty(mobile)) {
      value.errors.addAll({"contactNumber": "Contact number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile("+94${mobile!}");
      } on ArgumentError catch (err) {
        value.errors.addAll({"contactNumber": err.message});
      }
    }

    /// Location Validations
    String? location = value.location;
    if (StringValidators.isEmpty(location)) {
      value.errors.addAll({"location": "Location is required"});
    }

    /// Image Validations
    List<ImageReference> images = value.images;
    if (images.isNotEmpty && images.length > 5) {
      value.errors.addAll({"images": "Maximum picture count exceeded"});
    }

    /// Validate description
    String? description = value.description;
    if (StringValidators.isEmpty(description)) {
      value.errors.addAll({"description": "Description is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }

  set type(ComplaintTypeDto? type) {
    value.type = type;
    notifyListeners();
  }

  set productCategory(ComplaintProductCategoryDto? category) {
    value.productCategory = category;
    notifyListeners();
  }

  set product(ComplaintProductDto? product) {
    value.product = product;
    notifyListeners();
  }
}

class ComplaintForm extends StatefulFormWidget<ComplaintWizardStateValue> {
  const ComplaintForm({super.key, required super.controller});

  @override
  State<ComplaintForm> createState() => _ComplaintWizardState();
}

class _ComplaintWizardState extends State<ComplaintForm> with FormMixin {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController businessNameTextEditingController = TextEditingController();
  TextEditingController contactNumberTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, formValue, _) {
        return Column(
          children: [
            TextField(
              controller: nameTextEditingController,
              decoration: InputDecoration(
                // hintText: "Name",
                hintText: AppLocalizations.of(context)!.nN_190,
                errorText: formValue.getError("name"),
              ),
              onChanged: (value) {
                controller.setValue(
                  controller.value..name = value,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: businessNameTextEditingController,
              decoration: InputDecoration(
                // hintText: "Business Name (Optional)",
                hintText: AppLocalizations.of(context)!.nN_191,
                errorText: formValue.getError("businessName"),
              ),
              onChanged: (value) {
                controller.setValue(
                  controller.value..businessName = value,
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
                      // hintText: "Contact Number",
                      hintText: AppLocalizations.of(context)!.nN_015,
                      errorText: formValue.getError("contactNumber"),
                    ),
                    onChanged: (value) => controller.setValue(
                      controller.value..contactNumber = value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationTextEditingController,
              decoration: InputDecoration(
                // hintText: "Location",
                hintText: AppLocalizations.of(context)!.nN_073,
                errorText: formValue.getError("location"),
              ),
              onChanged: (value) {
                controller.setValue(
                  controller.value..location = value,
                );
              },
            ),
            const SizedBox(height: 20),
            InputDecorator(
              decoration: InputDecoration(
                errorText: formValue.getError("description"),
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    // hintText: 'Description',
                    hintText: AppLocalizations.of(context)!.nN_089,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  onChanged: (value) {
                    controller.setValue(
                      controller.value..description = value,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            InputDecorator(
              decoration: InputDecoration(
                errorText: formValue.getError("images"),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              child: ImageBox(
                images: controller.value.images
                    .map((path) => ImageBoxImage(
                          pathReference: path.fullPath,
                          bucketPath: path.bucketReference,
                        ))
                    .toList(),
                beforeUpload: (file) {
                  bool isDuplicate = controller.fileRefs.any((item) => item.isSameFile(file));
                  if (isDuplicate) {
                    locate<PopupController>().addItemFor(
                      DismissiblePopup(
                        title: "Duplicate image",
                        subtitle: "Image file already uploaded",
                        color: Colors.red,
                        onDismiss: (self) => locate<PopupController>().removeItem(self),
                      ),
                      const Duration(seconds: 5),
                    );
                  }
                  return !isDuplicate;
                },
                onUpload: (value) {
                  controller.fileRefs.add(value);
                  controller.setValue(
                    controller.value = controller.value
                      ..images.add(
                        ImageReference(fullPath: value.pathReference, bucketReference: value.bucketPath),
                      ),
                  );
                },
                onRemove: (value) {
                  controller.fileRefs.removeWhere((file) => file.isSame(value));
                  controller.setValue(
                    controller.value = controller.value
                      ..images.remove(
                        ImageReference(fullPath: value.pathReference, bucketReference: value.bucketPath),
                      ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  ComplaintWizardController get controller => widget.controller as ComplaintWizardController;
}

class ImageBoxImage {
  ImageBoxImage({this.file, required this.pathReference, required this.bucketPath});

  String bucketPath; // bucket reference

  String pathReference; // full image path

  File? file; // Original file

  bool isSame(ImageBoxImage value) => isSameFile(value.file) || value.pathReference == pathReference;
  bool isSameFile(File? value) => file?.path == value?.path;
}

class ImageBox extends StatefulWidget {
  final int maxCount;
  final List<ImageBoxImage> images;
  final Function(ImageBoxImage image) onUpload;
  final Function(ImageBoxImage image) onRemove;
  final bool Function(File file)? beforeUpload;
  final Function(String? value)? onUploadError;

  const ImageBox({
    super.key,
    this.beforeUpload,
    this.onUploadError,
    int? maxCount,
    required this.images,
    required this.onRemove,
    required this.onUpload,
  }) : maxCount = maxCount ?? -1;

  @override
  State<ImageBox> createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> {
  final focusNode = FocusNode();

  handleFileUpload(BuildContext context) async {
    late File? file;
    try {
      Source? source = await showSourceSelector(context);
      if (source == null) return;

      final extensions = ["jpg", "jpeg", "png"];
      file = await pickFile(source, extensions: extensions);
      if (file == null) return;

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

      bool canProceed = widget.beforeUpload == null;
      if (widget.beforeUpload != null) canProceed = widget.beforeUpload!(file);
      if (!canProceed) return;

      if (file.lengthSync() > 1e+7) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "File is too large",
            subtitle: "File size is larger than 10MB",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      locate<ProgressIndicatorController>().show();
      String? bucketReference = await locate<RestService>().uploadBase64EncodeAsync(await fileToBase64(file));

      if (bucketReference == null) throw Exception();
      final result = await locate<RestService>().getFullFilePath(bucketReference);

      widget.onUpload(ImageBoxImage(pathReference: result, file: file, bucketPath: bucketReference));
    } catch (_) {
      if (widget.onUploadError != null) widget.onUploadError!(file?.path);
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

  Widget buildEmptyIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        handleFileUpload(context);
      },
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Colors.black26,
            size: 50,
          ),
          // Text("Upload Images")
          Text(AppLocalizations.of(context)!.nN_192)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      canRequestFocus: true,
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x08000000),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 1,
              color: Colors.black38,
            ),
          ),
          constraints: const BoxConstraints.tightFor(width: double.infinity),
          child: Column(
            children: [
              if (canUpload)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    children: [
                      // const Expanded(child: Text("Upload Images")),
                      Expanded(
                        child: Text(AppLocalizations.of(context)!.nN_192),
                      ),
                      FilledButton(
                        onPressed: () {
                          focusNode.requestFocus();
                          handleFileUpload(context);
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        // child: const Text("Upload"),
                        child: Text(AppLocalizations.of(context)!.nN_077),
                      )
                    ],
                  ),
                ),
              widget.images.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: buildEmptyIndicator(context),
                      ),
                    )
                  : SizedBox(
                      height: 100,
                      child: ListView.separated(
                        itemCount: widget.images.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, i) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => ImageBoxItem(
                          path: widget.images[i].pathReference,
                          onRemove: () => widget.onRemove(widget.images[i]),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  bool get canUpload =>
      (widget.images.isNotEmpty) && (widget.maxCount.isNegative || widget.images.length < widget.maxCount);
}

class ImageBoxItem extends StatelessWidget {
  final String path;
  final Function() onRemove;
  const ImageBoxItem({
    super.key,
    required this.path,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black12,
            ),
          ),
          child: Image.network(
            path,
            fit: BoxFit.contain,
          ),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: Colors.black38,
            ),
          ),
        )
      ],
    );
  }
}

class ComplaintWizard extends StatelessWidget {
  const ComplaintWizard({super.key, required this.controller});

  final ComplaintWizardController controller;

  handleSubmit(BuildContext context) async {
    try {
      locate<ProgressIndicatorController>().show();

      if (!await controller.validate()) return;

      await locate<RestService>().createComplaint(
        name: controller.value.name ?? "",
        businessName: controller.value.businessName ?? "",
        contactNumber: "+94${controller.value.contactNumber}",
        location: controller.value.location ?? "",
        description: controller.value.description ?? "",
        imageUrls: controller.value.images.map((e) => e.bucketReference).toList(),
        productId: controller.value.product?.id,
        productCategoryId: controller.value.productCategory?.id,
        complaintTypeId: controller.value.type?.id,
      );

      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully created",
          subtitle: "Complaint created successfully",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );

      FocusManager.instance.primaryFocus?.unfocus();
      if (context.mounted) Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  // "MAKE A COMPLAINT",
                  AppLocalizations.of(context)!.nN_1008.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(thickness: 1),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ComplaintForm(
                  controller: controller,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
            child: FilledButton(
              onPressed: () => handleSubmit(context),
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
              // child: const Text("Submit"),
              child: Text(AppLocalizations.of(context)!.nN_013),
            ),
          )
        ],
      ),
    );
  }
}
