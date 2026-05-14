import '../entities/photo_confirmation_data.dart';
import '../repositories/i_photo_confirmation_repository.dart';

class GetPhotoConfirmationDataUsecase {
  final IPhotoConfirmationRepository _repository;

  GetPhotoConfirmationDataUsecase(this._repository);

  Future<PhotoConfirmationData> call(String? lockerId) {
    return _repository.getPhotoConfirmationData(lockerId);
  }
}
