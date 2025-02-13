import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<List<String?>?> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'tif', 'tiff', 'jpeg'],
      );

      if (result != null) {
        return result.paths;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking files: $e');
      return null;
    }
  }

  Future<String?> pickDirectory() async {
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        return directoryPath;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking directory: $e');
      return null;
    }
  }


  Future<String?> createZip({required List<String> files}) async {
    try {
      // Create a new ZIP file
      final archive = Archive();

      for (String filePath in files) {
        final file = File(filePath);
        final fileName = file.uri.pathSegments.last;
        final fileBytes = file.readAsBytesSync();

        // Add the file to the archive
        archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
      }

      // Encode the archive to a ZIP file
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final zipFilePath = '${tempDir.path}\\compressed_files.zip';

      // Save the ZIP file
      final zipFile = File(zipFilePath);
      await zipFile.writeAsBytes(zipData);

      return zipFilePath;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating ZIP file: $e');
      return null;
    }
  }
}