import { motion } from 'framer-motion';
import { AlertCircle, LoaderCircle, RotateCcw, X } from 'lucide-react';
import { FormEvent, useCallback, useEffect, useRef, useState } from 'react';
import { useLocation } from 'react-router-dom';
import { useToast } from '../../../context/ToastContext';
import { getMyFeedback, upsertMyFeedback } from '../api/feedbackApi';
import { FEEDBACK_TOPIC_LABELS, FeedbackTopic } from '../types';
import type { FeedbackTopic as FeedbackTopicValue } from '../types';
import StarRating from './StarRating';

interface FeedbackModalProps {
  onClose: () => void;
}

type LoadState = 'loading' | 'error' | 'ready';

const MIN_CONTENT_LENGTH = 1;
const MAX_CONTENT_LENGTH = 2000;
const FEEDBACK_TOPICS = Object.values(FeedbackTopic);

function getErrorMessage(error: unknown, fallback: string): string {
  return error instanceof Error ? error.message : fallback;
}

export default function FeedbackModal({ onClose }: FeedbackModalProps) {
  const location = useLocation();
  const { show: showToast } = useToast();
  const dialogRef = useRef<HTMLElement>(null);
  const headingRef = useRef<HTMLHeadingElement>(null);
  const loadRequestIdRef = useRef(0);
  const isSubmittingRef = useRef(false);
  const [loadState, setLoadState] = useState<LoadState>('loading');
  const [loadError, setLoadError] = useState('');
  const [rating, setRating] = useState(0);
  const [topic, setTopic] = useState<FeedbackTopicValue>(FeedbackTopic.General);
  const [content, setContent] = useState('');
  const [validationError, setValidationError] = useState('');
  const [submitError, setSubmitError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadFeedback = useCallback(async () => {
    const requestId = ++loadRequestIdRef.current;
    setLoadState('loading');
    setLoadError('');

    try {
      const existing = await getMyFeedback();
      if (requestId !== loadRequestIdRef.current) return;

      setRating(existing?.rating ?? 0);
      setTopic(existing?.topic ?? FeedbackTopic.General);
      setContent(existing?.content ?? '');
      setValidationError('');
      setSubmitError('');
      setLoadState('ready');
    } catch (error) {
      if (requestId !== loadRequestIdRef.current) return;

      setLoadError(getErrorMessage(error, 'Không thể tải feedback của bạn.'));
      setLoadState('error');
    }
  }, []);

  useEffect(() => {
    void loadFeedback();

    return () => {
      loadRequestIdRef.current += 1;
    };
  }, [loadFeedback]);

  useEffect(() => {
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    headingRef.current?.focus();

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && !isSubmittingRef.current) {
        event.preventDefault();
        onClose();
        return;
      }

      if (event.key !== 'Tab') return;

      const dialog = dialogRef.current;
      if (!dialog) return;

      const focusableElements = Array.from(
        dialog.querySelectorAll<HTMLElement>(
          'button, select, textarea, input, a[href], [tabindex]:not([tabindex="-1"])',
        ),
      ).filter((element) => !element.matches(':disabled') && element.offsetParent !== null);

      if (focusableElements.length === 0) {
        event.preventDefault();
        headingRef.current?.focus();
        return;
      }

      const firstElement = focusableElements[0];
      const lastElement = focusableElements[focusableElements.length - 1];
      const activeElement = document.activeElement;

      if (
        event.shiftKey
        && (activeElement === firstElement || activeElement === headingRef.current || !dialog.contains(activeElement))
      ) {
        event.preventDefault();
        lastElement.focus();
      } else if (!event.shiftKey && activeElement === lastElement) {
        event.preventDefault();
        firstElement.focus();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.body.style.overflow = previousOverflow;
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [onClose]);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const trimmedContent = content.trim();

    if (rating < 1 || rating > 5) {
      setValidationError('Vui lòng chọn mức đánh giá từ 1 đến 5 sao.');
      return;
    }

    if (trimmedContent.length < MIN_CONTENT_LENGTH || trimmedContent.length > MAX_CONTENT_LENGTH) {
      setValidationError('Nội dung feedback phải có từ 1 đến 2.000 ký tự.');
      return;
    }

    setValidationError('');
    setSubmitError('');
    isSubmittingRef.current = true;
    setIsSubmitting(true);

    try {
      await upsertMyFeedback({
        rating,
        topic,
        content: trimmedContent,
        pageUrl: location.pathname,
      });
      showToast('Cảm ơn bạn đã gửi feedback!', 'success');
      onClose();
    } catch (error) {
      setSubmitError(getErrorMessage(error, 'Không thể gửi feedback. Vui lòng thử lại.'));
    } finally {
      isSubmittingRef.current = false;
      setIsSubmitting(false);
    }
  };

  const characterCount = content.trim().length;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[60] flex items-center justify-center p-3 sm:p-6"
    >
      <div className="absolute inset-0 bg-black/50" aria-hidden="true" />

      <motion.section
        ref={dialogRef}
        initial={{ opacity: 0, scale: 0.96, y: 12 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.96, y: 12 }}
        transition={{ duration: 0.2 }}
        role="dialog"
        aria-modal="true"
        aria-labelledby="feedback-dialog-title"
        className="relative flex max-h-[90vh] w-full max-w-lg flex-col overflow-hidden rounded-2xl bg-white shadow-2xl"
      >
        <header className="flex shrink-0 items-start justify-between gap-4 border-b border-gray-100 px-4 py-4 sm:px-6">
          <div>
            <h2
              ref={headingRef}
              id="feedback-dialog-title"
              tabIndex={-1}
              className="text-xl font-bold text-gray-900 outline-none"
            >
              Gửi feedback
            </h2>
            <p className="mt-1 text-sm text-gray-500">Chia sẻ trải nghiệm để chúng tôi phục vụ bạn tốt hơn.</p>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={isSubmitting}
            aria-label="Đóng hộp thoại feedback"
            className="shrink-0 rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 hover:text-gray-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 disabled:cursor-not-allowed disabled:opacity-50"
          >
            <X aria-hidden="true" size={20} />
          </button>
        </header>

        <div className="min-h-0 overflow-y-auto px-4 py-5 sm:px-6">
          {loadState === 'loading' && (
            <div className="flex min-h-48 flex-col items-center justify-center gap-3 text-gray-600" role="status">
              <LoaderCircle className="animate-spin text-orange-500" aria-hidden="true" size={30} />
              <p className="text-sm font-medium">Đang tải feedback của bạn...</p>
            </div>
          )}

          {loadState === 'error' && (
            <div className="flex min-h-48 flex-col items-center justify-center text-center">
              <AlertCircle className="text-red-500" aria-hidden="true" size={34} />
              <h3 className="mt-3 font-semibold text-gray-900">Không thể tải feedback</h3>
              <p className="mt-1 max-w-sm text-sm text-red-700" role="alert">{loadError}</p>
              <div className="mt-5 flex flex-col-reverse gap-2 sm:flex-row">
                <button
                  type="button"
                  onClick={onClose}
                  className="rounded-xl border border-gray-200 px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500"
                >
                  Đóng
                </button>
                <button
                  type="button"
                  onClick={() => void loadFeedback()}
                  className="inline-flex items-center justify-center gap-2 rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2"
                >
                  <RotateCcw aria-hidden="true" size={16} />
                  Thử lại
                </button>
              </div>
            </div>
          )}

          {loadState === 'ready' && (
            <form onSubmit={handleSubmit} noValidate>
              <fieldset disabled={isSubmitting} className="space-y-5 disabled:opacity-70">
                <div>
                  <label className="mb-2 block text-sm font-semibold text-gray-800">Mức độ hài lòng</label>
                  <StarRating value={rating} onChange={setRating} disabled={isSubmitting} />
                </div>

                <div>
                  <label htmlFor="feedback-topic" className="mb-2 block text-sm font-semibold text-gray-800">
                    Chủ đề
                  </label>
                  <select
                    id="feedback-topic"
                    value={topic}
                    onChange={(event) => setTopic(Number(event.target.value) as FeedbackTopicValue)}
                    className="w-full rounded-xl border border-gray-200 bg-white px-3 py-2.5 text-sm text-gray-900 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-100 disabled:cursor-not-allowed"
                  >
                    {FEEDBACK_TOPICS.map((topicOption) => (
                      <option key={topicOption} value={topicOption}>
                        {FEEDBACK_TOPIC_LABELS[topicOption]}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <div className="mb-2 flex items-center justify-between gap-3">
                    <label htmlFor="feedback-content" className="text-sm font-semibold text-gray-800">
                      Nội dung
                    </label>
                    <span
                      id="feedback-character-count"
                      className={`text-xs ${characterCount > MAX_CONTENT_LENGTH ? 'font-semibold text-red-600' : 'text-gray-500'}`}
                    >
                      {characterCount.toLocaleString('vi-VN')}/2.000
                    </span>
                  </div>
                  <textarea
                    id="feedback-content"
                    rows={6}
                    value={content}
                    onChange={(event) => setContent(event.target.value)}
                    aria-describedby="feedback-character-count feedback-form-error"
                    placeholder="Điều gì khiến bạn hài lòng hoặc cần được cải thiện?"
                    className="w-full resize-y rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-500 focus:ring-2 focus:ring-orange-100 disabled:cursor-not-allowed"
                  />
                </div>
              </fieldset>

              {(validationError || submitError) && (
                <p id="feedback-form-error" className="mt-4 rounded-xl bg-red-50 px-3 py-2.5 text-sm text-red-700" role="alert">
                  {validationError || submitError}
                </p>
              )}

              <div className="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
                <button
                  type="button"
                  onClick={onClose}
                  disabled={isSubmitting}
                  className="rounded-xl border border-gray-200 px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="inline-flex min-w-32 items-center justify-center gap-2 rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  {isSubmitting && <LoaderCircle className="animate-spin" aria-hidden="true" size={16} />}
                  {isSubmitting ? 'Đang gửi...' : 'Gửi feedback'}
                </button>
              </div>
            </form>
          )}
        </div>
      </motion.section>
    </motion.div>
  );
}
