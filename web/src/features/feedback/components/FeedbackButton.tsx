import { MessageSquareText } from 'lucide-react';
import { useFeedback } from '../context/FeedbackContext';

export default function FeedbackButton() {
  const feedback = useFeedback();
  if (!feedback) return null;

  return (
    <button
      ref={feedback.floatingTriggerRef}
      type="button"
      onClick={(event) => feedback.openFeedback(event.currentTarget)}
      aria-haspopup="dialog"
      aria-expanded={feedback.isOpen}
      className="fixed bottom-5 right-4 z-40 inline-flex min-h-11 items-center gap-2 rounded-full border border-orange-400/40 bg-orange-500 px-4 py-2.5 text-sm font-bold text-white shadow-[0_12px_28px_-10px_rgba(249,115,22,0.85)] transition hover:-translate-y-0.5 hover:bg-orange-600 hover:shadow-[0_16px_32px_-10px_rgba(249,115,22,0.9)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 sm:bottom-6 sm:right-6"
    >
      <MessageSquareText aria-hidden="true" size={17} />
      Feedback
    </button>
  );
}
