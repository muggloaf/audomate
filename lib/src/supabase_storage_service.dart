import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'models.dart';

class SupabaseStorageService {
  SupabaseStorageService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  static const auditMediaBucket = 'audit-media';
  static const reportAssetsBucket = 'report-assets';
  static const auditReportsBucket = 'audit-reports';

  final SupabaseClient? _client;

  SupabaseClient get _requiredClient {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured for this build.');
    }
    return client;
  }

  Future<String> uploadFindingPhoto({
    required String organisationId,
    required String projectId,
    required String findingId,
    required String photoId,
    required Uint8List bytes,
    required String mimeType,
    required String originalFilename,
  }) async {
    final extension = _safeExtension(originalFilename, mimeType);
    final path = '$organisationId/$projectId/$findingId/$photoId.$extension';
    await _requiredClient.storage
        .from(auditMediaBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    return path;
  }

  Future<String> uploadProjectCover({
    required String organisationId,
    required String projectId,
    required PhotoData photo,
  }) async {
    final extension = _safeExtension(photo.name, _imageMime(photo.name));
    final path = '$organisationId/$projectId/cover/${photo.id}.$extension';
    await _requiredClient.storage
        .from(auditMediaBucket)
        .uploadBinary(
          path,
          photo.bytes,
          fileOptions: FileOptions(
            contentType: _imageMime(photo.name),
            upsert: true,
          ),
        );
    return path;
  }

  Future<String> uploadReportAsset({
    required String organisationId,
    required String assetId,
    required String kind,
    required Uint8List bytes,
    required String mimeType,
    required String originalFilename,
  }) async {
    if (kind != 'letterhead' && kind != 'signature') {
      throw ArgumentError.value(kind, 'kind', 'Use letterhead or signature.');
    }
    final extension = _safeExtension(originalFilename, mimeType);
    final path = '$organisationId/$kind/$assetId.$extension';
    await _requiredClient.storage
        .from(reportAssetsBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    return path;
  }

  Future<String> uploadGeneratedReport({
    required String organisationId,
    required String projectId,
    required String reportId,
    required Uint8List bytes,
  }) async {
    final path = '$organisationId/$projectId/$reportId.pdf';
    await _requiredClient.storage
        .from(auditReportsBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return path;
  }

  Future<Uint8List> download(String bucket, String objectPath) =>
      _requiredClient.storage.from(bucket).download(objectPath);

  Future<void> delete(String bucket, String objectPath) async {
    await _requiredClient.storage.from(bucket).remove([objectPath]);
  }

  String _safeExtension(String filename, String mimeType) {
    final extension =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'pdf'};
    if (allowed.contains(extension)) return extension;
    return switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      'application/pdf' => 'pdf',
      _ => 'jpg',
    };
  }

  String _imageMime(String filename) {
    final value = filename.toLowerCase();
    if (value.endsWith('.png')) return 'image/png';
    if (value.endsWith('.webp')) return 'image/webp';
    if (value.endsWith('.heic')) return 'image/heic';
    if (value.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }
}
