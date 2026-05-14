import '../domain/entities/photo_confirmation_data.dart';
import '../domain/repositories/i_photo_confirmation_repository.dart';

class PhotoConfirmationRepository implements IPhotoConfirmationRepository {
  @override
  Future<PhotoConfirmationData> getPhotoConfirmationData(
      String? lockerId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return PhotoConfirmationData(
      lockerId: lockerId ?? 'EBOX-VNB329',
      title: 'Chụp ảnh xác nhận',
      instruction: 'Đảm bảo kiện hàng nằm rõ trong khung hình',
      previewImageUrl: 'https://placehold.co/358x558',
    );
  }
}
