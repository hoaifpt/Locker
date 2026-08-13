import { AnimatePresence } from 'framer-motion';
import { MessageSquareText } from 'lucide-react';
import { useCallback, useRef, useState } from 'react';
import FeedbackModal from './FeedbackModal';

export default function FeedbackButton() {
  const [isOpen, setIsOpen] = useState(false);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const previousFocusRef = useRef<HTMLElement | null>(null);

  const handleOpen = () => {
    previousFocusRef.current = document.activeElement instanceof HTMLElement
      ? document.activeElement
      : triggerRef.current;
    setIsOpen(true);
  };

  const handleClose = useCallback(() => {
    setIsOpen(false);
  }, []);

  const restoreFocus = useCallback(() => {
    (triggerRef.current ?? previousFocusRef.current)?.focus();
  }, []);

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        onClick={handleOpen}
        aria-haspopup="dialog"
        aria-expanded={isOpen}
        className="fixed bottom-5 right-5 z-40 inline-flex items-center gap-2 rounded-full bg-orange-500 px-4 py-3 text-sm font-bold text-white shadow-lg shadow-orange-200 transition hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2"
      >
        <MessageSquareText aria-hidden="true" size={18} />
        Feedback
      </button>

      <AnimatePresence onExitComplete={restoreFocus}>
        {isOpen && <FeedbackModal key="feedback-modal" onClose={handleClose} />}
      </AnimatePresence>
    </>
  );
}
