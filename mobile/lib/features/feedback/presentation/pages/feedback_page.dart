import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/feedback.dart';
import '../controllers/feedback_cubit.dart';
import '../controllers/feedback_state.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedbackCubit>()..load(),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  static const _maxContentLength = 2000;

  final _contentController = TextEditingController();
  int _rating = 0;
  FeedbackTopic _topic = FeedbackTopic.general;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_refreshCharacterCount);
  }

  @override
  void dispose() {
    _contentController
      ..removeListener(_refreshCharacterCount)
      ..dispose();
    super.dispose();
  }

  void _refreshCharacterCount() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (_rating < 1 || _rating > 5) {
      setState(() => _validationMessage = 'Vui lòng chọn từ 1 đến 5 sao.');
      return;
    }
    if (content.isEmpty || content.length > _maxContentLength) {
      setState(() {
        _validationMessage = 'Nội dung phản hồi phải có từ 1 đến 2.000 ký tự.';
      });
      return;
    }

    setState(() => _validationMessage = null);
    final succeeded = await context.read<FeedbackCubit>().submit(
      rating: _rating,
      topic: _topic,
      content: content,
    );
    if (!mounted || !succeeded) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn! Phản hồi đã được gửi thành công.'),
          backgroundColor: AppColors.settingsAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.settingsBackground,
      body: SafeArea(
        child: BlocBuilder<FeedbackCubit, FeedbackState>(
          builder: (context, state) {
            return Column(
              children: [
                SettingsTopBar(
                  title: 'Gửi feedback',
                  icon: Icons.chat_bubble_outline_rounded,
                  onBack: () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: switch (state.status) {
                    FeedbackLoadStatus.initial ||
                    FeedbackLoadStatus.loading => const _LoadingView(),
                    FeedbackLoadStatus.failure => _LoadErrorView(
                      message: state.errorMessage ?? 'Không thể tải phản hồi.',
                      onRetry: () {
                        context.read<FeedbackCubit>().load();
                      },
                    ),
                    FeedbackLoadStatus.ready => _buildForm(state),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(FeedbackState state) {
    final errorMessage = _validationMessage ?? state.errorMessage;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: settingsCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CÙNG HOÀN THIỆN E-BOX',
                  style: TextStyle(
                    color: AppColors.settingsAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trải nghiệm của bạn\nnhư thế nào?',
                  style: TextStyle(
                    color: AppColors.settingsTextPrimary,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chia sẻ một khoảnh khắc cụ thể để chúng tôi cải thiện trải nghiệm của bạn.',
                  style: TextStyle(
                    color: AppColors.settingsTextSecondary,
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _StarSelector(
                  value: _rating,
                  enabled: !state.isSubmitting,
                  onChanged: (rating) {
                    setState(() {
                      _rating = rating;
                      _validationMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: settingsCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Chuyện này là sao vậy?'),
                const SizedBox(height: 10),
                DropdownButtonFormField<FeedbackTopic>(
                  initialValue: _topic,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: settingsInputDecoration(),
                  items: FeedbackTopic.values
                      .map(
                        (topic) => DropdownMenuItem(
                          value: topic,
                          child: Text(topic.label),
                        ),
                      )
                      .toList(),
                  onChanged: state.isSubmitting
                      ? null
                      : (topic) {
                          if (topic != null) setState(() => _topic = topic);
                        },
                ),
                const SizedBox(height: 20),
                const _FieldLabel(
                  'Điều gì đã hiệu quả — hoặc điều gì đang cản trở bạn?',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contentController,
                  enabled: !state.isSubmitting,
                  minLines: 6,
                  maxLines: 8,
                  maxLength: _maxContentLength,
                  decoration: settingsInputDecoration(
                    hintText:
                        'Một khoảnh khắc cụ thể sẽ giúp chúng tôi tiến bộ nhanh hơn...',
                  ).copyWith(counterText: ''),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_contentController.text.length} / $_maxContentLength ký tự',
                      style: const TextStyle(
                        color: AppColors.settingsTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.feedback != null)
                      const Text(
                        'Cập nhật phản hồi',
                        style: TextStyle(
                          color: AppColors.settingsAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: state.isSubmitting ? null : _submit,
            icon: state.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 19),
            label: Text(
              state.isSubmitting ? 'Đang gửi...' : 'Gửi phản hồi',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: settingsPrimaryButtonStyle(),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.settingsTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StarSelector extends StatelessWidget {
  const _StarSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mức độ hài lòng, $value trên 5 sao',
      child: Row(
        children: List.generate(5, (index) {
          final rating = index + 1;
          final selected = rating <= value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
              child: Semantics(
                button: true,
                selected: rating == value,
                label: '$rating sao',
                child: InkWell(
                  onTap: enabled ? () => onChanged(rating) : null,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.settingsAccentSoft
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.settingsAccent
                            : AppColors.settingsCardBorder,
                      ),
                    ),
                    child: Icon(
                      selected
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: selected
                          ? AppColors.settingsAccent
                          : AppColors.settingsTextMuted,
                      size: 27,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.settingsAccent),
          SizedBox(height: 16),
          Text(
            'Đang tải phản hồi của bạn...',
            style: TextStyle(color: AppColors.settingsTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 44,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không thể tải feedback',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.settingsTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.settingsTextSecondary,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.settingsAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}