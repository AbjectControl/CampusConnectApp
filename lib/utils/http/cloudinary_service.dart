import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  XFile? imageFile;
  String? imageUrl;
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the provided [ImageSource]
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile = pickedFile;
      imageUrl = null; // Clear previous upload URL
    }
  }

  /// Uploads the selected image to Cloudinary
  Future<String?> uploadImage(
    Function(bool) onUploadingChanged,
    Function(String) onError,
  ) async {
    if (imageFile == null) return null;

    isUploading = true;
    onUploadingChanged(true);

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dhqh40nyz/image/upload',
      );
      final request = http.MultipartRequest('POST', url);
      
      request.fields['upload_preset'] = 'flutteruploads';
      
      // Use fromBytes for web compatibility
      final bytes = await imageFile!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile!.name,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        imageUrl = jsonMap['secure_url'] ?? jsonMap['url'];
        return imageUrl;
      } else {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print("Cloudinary Upload Failed: ${response.statusCode} - $responseString");
        onError('Upload failed with status: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      onError('Upload failed: $e');
      return null;
    } finally {
      isUploading = false;
      onUploadingChanged(false);
    }
  }

  Future<String?> uploadImageFile(
    File file,
    Function(bool) onUploadingChanged,
    Function(String) onError,
  ) async {
    // This method is kept for backward compatibility if needed, but uploadImage is preferred
    // For web, File from dart:io doesn't work well, so this might fail if called on web.
    isUploading = true;
    onUploadingChanged(true);

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dhqh40nyz/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'flutteruploads'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        return jsonMap['secure_url'] ?? jsonMap['url'];
      } else {
        onError('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      onError('Upload failed: $e');
      return null;
    } finally {
      isUploading = false;
      onUploadingChanged(false);
    }
  }
}
