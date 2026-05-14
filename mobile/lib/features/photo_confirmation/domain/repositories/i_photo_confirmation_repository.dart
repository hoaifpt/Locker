import '../entities/photo_confirmation_data.dart';

abstract class IPhotoConfirmationRepository {
  Future<PhotoConfirmationData> getPhotoConfirmationData(String? lockerId);
}
