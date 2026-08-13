import { AnimatePresence } from 'framer-motion';
import {
  createContext,
  ReactNode,
  RefObject,
  useCallback,
  useContext,
  useRef,
  useState,
} from 'react';
import FeedbackModal from '../components/FeedbackModal';

interface FeedbackContextValue {
  isOpen: boolean;
  floatingTriggerRef: RefObject<HTMLButtonElement>;
  openFeedback: (trigger?: HTMLElement | null) => void;
  closeFeedback: () => void;
}

const FeedbackContext = createContext<FeedbackContextValue | null>(null);

export function FeedbackProvider({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  const floatingTriggerRef = useRef<HTMLButtonElement>(null);
  const previousFocusRef = useRef<HTMLElement | null>(null);

  const openFeedback = useCallback((trigger?: HTMLElement | null) => {
    previousFocusRef.current = trigger
      ?? (document.activeElement instanceof HTMLElement ? document.activeElement : null);
    setIsOpen(true);
  }, []);

  const closeFeedback = useCallback(() => setIsOpen(false), []);

  const restoreFocus = useCallback(() => {
    const previousFocus = previousFocusRef.current;
    if (previousFocus?.isConnected) {
      previousFocus.focus();
      return;
    }

    floatingTriggerRef.current?.focus();
  }, []);

  return (
    <FeedbackContext.Provider
      value={{ isOpen, floatingTriggerRef, openFeedback, closeFeedback }}
    >
      {children}
      <AnimatePresence onExitComplete={restoreFocus}>
        {isOpen && <FeedbackModal key="feedback-modal" onClose={closeFeedback} />}
      </AnimatePresence>
    </FeedbackContext.Provider>
  );
}

export function useFeedback() {
  return useContext(FeedbackContext);
}
