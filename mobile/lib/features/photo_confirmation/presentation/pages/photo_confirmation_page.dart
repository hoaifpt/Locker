import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/photo_confirmation_cubit.dart';
import '../controllers/photo_confirmation_state.dart';
import '../widgets/locker_id_badge.dart';
import '../widgets/photo_confirmation_controls.dart';
import '../widgets/photo_confirmation_preview_frame.dart';
import '../widgets/photo_confirmation_top_bar.dart';

class PhotoConfirmationPage extends StatelessWidget {
  final String? lockerId;

  const PhotoConfirmationPage({super.key, this.lockerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhotoConfirmationCubit()..load(lockerId),
      child: BlocConsumer<PhotoConfirmationCubit, PhotoConfirmationState>(
        listener: (context, state) {
          final feedback = state.feedbackMessage;
          if (feedback != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(feedback)));
            context.read<PhotoConfirmationCubit>().clearFeedback();
          }

          final nav = state.navigateToSendSuccess;
          if (nav != null) {
            Navigator.pushNamed(context, '/send-success', arguments: nav);
            context.read<PhotoConfirmationCubit>().clearNavigation();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (state.errorMessage != null || state.data == null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: Text(
                    state.errorMessage ??
                        'Khong tai duoc du lieu chup anh xac nhan',
                  ),
                ),
              ),
            );
          }

          final data = state.data!;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  PhotoConfirmationTopBar(
                    title: data.title,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: PhotoConfirmationPreviewFrame(
                                previewImageUrl: data.previewImageUrl,
                                instruction: data.instruction,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                            child: Column(
                              children: [
                                PhotoConfirmationControls(
                                  flashOn: state.flashOn,
                                  onRetake: () => context
                                      .read<PhotoConfirmationCubit>()
                                      .retake(),
                                  onCapture: () => context
                                      .read<PhotoConfirmationCubit>()
                                      .capture(),
                                  onToggleFlash: () => context
                                      .read<PhotoConfirmationCubit>()
                                      .toggleFlash(),
                                ),
                                const SizedBox(height: 24),
                                LockerIdBadge(lockerId: data.lockerId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
