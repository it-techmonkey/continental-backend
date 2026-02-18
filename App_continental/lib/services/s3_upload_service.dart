import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

class S3UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final TokenStorage _tokenStorage = TokenStorage();
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick a PDF or image file
  Future<FilePickerResult?> pickFile({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );
      return result;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Upload image to S3 via backend
  Future<String?> uploadImage({
    required File imageFile,
    required String uploadType, // 'property-image', 'agreement', 'profile-image', 'payment-proof'
    String? fileName,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create FormData
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: fileName ?? 'image.jpg',
        ),
      });

      // Determine upload endpoint
      String endpoint;
      switch (uploadType) {
        case 'property-image':
          endpoint = '/upload/property-image';
          break;
        case 'agreement':
          endpoint = '/upload/agreement';
          break;
        case 'profile-image':
          endpoint = '/upload/profile-image';
          break;
        case 'payment-proof':
          endpoint = '/upload/payment-proof';
          break;
        default:
          throw Exception('Invalid upload type: $uploadType');
      }

      // Upload to backend
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['url'] as String;
      } else {
        print('Upload failed: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload PDF or image file to S3 via backend
  Future<String?> uploadFile({
    required File file,
    required String uploadType,
    String? fileName,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);

      // Read file as bytes
      final bytes = await file.readAsBytes();

      // Get file extension to determine content type
      final extension = fileName?.split('.').last ?? file.path.split('.').last;
      
      // Create FormData
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName ?? 'file.$extension',
        ),
      });

      // Determine upload endpoint
      String endpoint;
      switch (uploadType) {
        case 'agreement':
          endpoint = '/upload/agreement';
          break;
        default:
          throw Exception('Invalid upload type: $uploadType');
      }

      // Upload to backend
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['url'] as String;
      } else {
        print('Upload failed: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Convenience method: Pick and upload property image
  Future<String?> pickAndUploadPropertyImage() async {
    final image = await pickImage();
    if (image != null) {
      return await uploadImage(
        imageFile: File(image.path),
        uploadType: 'property-image',
        fileName: image.name,
      );
    }
    return null;
  }

  /// Convenience method: Pick and upload agreement
  Future<String?> pickAndUploadAgreement() async {
    final result = await pickFile(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      return await uploadFile(
        file: File(result.files.single.path!),
        uploadType: 'agreement',
        fileName: result.files.single.name,
      );
    }
    return null;
  }

  /// Convenience method: Pick and upload profile image
  Future<String?> pickAndUploadProfileImage() async {
    final image = await pickImage();
    if (image != null) {
      return await uploadImage(
        imageFile: File(image.path),
        uploadType: 'profile-image',
        fileName: image.name,
      );
    }
    return null;
  }

  /// Convenience method: Pick and upload payment proof
  Future<String?> pickAndUploadPaymentProof() async {
    final image = await pickImage();
    if (image != null) {
      return await uploadImage(
        imageFile: File(image.path),
        uploadType: 'payment-proof',
        fileName: image.name,
      );
    }
    return null;
  }
}

