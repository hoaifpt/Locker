// Shared Framer Motion animation helpers

export const hidden = { opacity: 0, y: 28 };
export const visible = { opacity: 1, y: 0 };

/** Returns a transition object with optional delay. */
export const trans = (delay = 0) =>
  ({ duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] } as const);
