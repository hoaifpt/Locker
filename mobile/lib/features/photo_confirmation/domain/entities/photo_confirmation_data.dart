class PhotoConfirmationData {
  final String lockerId;
  final String title;
  final String instruction;
  final String previewImageUrl;

  const PhotoConfirmationData({
    required this.lockerId,
    required this.title,
    required this.instruction,
    required this.previewImageUrl,
  });
}
