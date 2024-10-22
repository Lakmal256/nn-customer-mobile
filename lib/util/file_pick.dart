import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

enum Source { camera, gallery, files }

Future<File?> pickFile(
  Source source, {
  List<String>? extensions,
}) async {
  final ImagePicker picker = ImagePicker();
  switch (source) {
    case Source.camera:
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        return File(file.path);
      }
      break;
    case Source.gallery:
      final file = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.image,
        // type: FileType.custom,
        // allowedExtensions: extensions
      );
      if (file != null) {
        return File(file.files.first.path!);
      }
      break;
    case Source.files:
      final file = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: extensions != null ? FileType.custom : FileType.any,
        allowedExtensions: extensions,
      );
      if (file != null) {
        return File(file.files.first.path!);
      }
      break;
  }
  return null;
}

extension FileName on File {
  String get name => uri.pathSegments.last;
}

String readableFileSize(int num, {bool base1024 = true}) {
  final base = base1024 ? 1024 : 1000;
  if (num <= 0) return "0";
  final units = ["B", "kB", "MB", "GB", "TB"];
  int digitGroups = (log(num) / log(base)).round();
  return "${NumberFormat("#,##0.#").format(num / pow(base, digitGroups))} ${units[digitGroups]}";
}

Future<String> fileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  final base64EncodedFile = base64Encode(bytes);
  final mime = lookupMimeType(file.path);
  return "data:$mime;base64,$base64EncodedFile";
}