import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/injection.dart';
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
          backgroundColor: Color(0xFFEC5B13),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFAF5),
          appBar: AppBar(
            title: const Text('Gửi feedback'),
            backgroundColor: const Color(0xCCFFFAF5),
            surfaceTintColor: Colors.transparent,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFFFEDD5)),
            ),
          ),
          body: SafeArea(
            top: false,
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
        );
      },
    );
  }

  Widget _buildForm(FeedbackState state) {
    final errorMessage = _validationMessage ?? state.errorMessage;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÙNG HOÀN THIỆN E-BOX',
            style: TextStyle(
              color: Color(0xFFEA580C),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Trải nghiệm của bạn\nnhư thế nào?',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 28,
              height: 1.2,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Chia sẻ một khoảnh khắc cụ thể để chúng tôi cải thiện trải nghiệm của bạn.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.55,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 28),
          const _FieldLabel('Chuyện này là sao vậy?'),
          const SizedBox(height: 10),
          DropdownButtonFormField<FeedbackTopic>(
            initialValue: _topic,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: _inputDecoration(),
            items: FeedbackTopic.values
                .map(
                  (topic) =>
                      DropdownMenuItem(value: topic, child: Text(topic.label)),
                )
                .toList(),
            onChanged: state.isSubmitting
                ? null
                : (topic) {
                    if (topic != null) setState(() => _topic = topic);
                  },
          ),
          const SizedBox(height: 24),
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
            decoration: _inputDecoration().copyWith(
              hintText:
                  'Một khoảnh khắc cụ thể sẽ giúp chúng tôi tiến bộ nhanh hơn...',
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_contentController.text.length} / $_maxContentLength ký tự',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (state.feedback != null)
                const Text(
                  'Cập nhật phản hồi',
                  style: TextStyle(
                    color: Color(0xFFEA580C),
                    fontSize: 12,
                    fontFamily: 'Manrope',
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
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
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
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC5B13),
                disabledBackgroundColor: const Color(0xFFFDBA8C),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEC5B13), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
        color: Color(0xFF334155),
        fontSize: 14,
        height: 1.4,
        fontFamily: 'Manrope',
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
                      color: selected ? const Color(0xFFFFF7ED) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFDBA74)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: selected
                          ? const Color(0xFFF97316)
                          : const Color(0xFF94A3B8),
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
          CircularProgressIndicator(color: Color(0xFFEC5B13)),
          SizedBox(height: 16),
          Text('Đang tải phản hồi của bạn...'),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
