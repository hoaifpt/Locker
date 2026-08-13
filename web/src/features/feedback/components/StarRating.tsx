import { Star } from 'lucide-react';
import type { KeyboardEvent } from 'react';

interface StarRatingProps {
  value: number;
  onChange: (value: number) => void;
  disabled?: boolean;
}

const MIN_RATING = 1;
const MAX_RATING = 5;

export default function StarRating({ value, onChange, disabled = false }: StarRatingProps) {
  const selectRating = (nextValue: number) => {
    onChange(Math.min(MAX_RATING, Math.max(MIN_RATING, nextValue)));
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLButtonElement>) => {
    let nextValue: number | null = null;

    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowDown':
        nextValue = value - 1;
        break;
      case 'ArrowRight':
      case 'ArrowUp':
        nextValue = value + 1;
        break;
      case 'Home':
        nextValue = MIN_RATING;
        break;
      case 'End':
        nextValue = MAX_RATING;
        break;
      default:
        return;
    }

    event.preventDefault();
    selectRating(nextValue);
  };

  return (
    <div className="flex flex-wrap gap-2.5" role="group" aria-label="Mức độ hài lòng">
      {Array.from({ length: MAX_RATING }, (_, index) => {
        const starValue = index + 1;
        const selected = starValue <= value;

        return (
          <button
            key={starValue}
            type="button"
            aria-label={`${starValue} sao`}
            aria-pressed={selected}
            disabled={disabled}
            onClick={() => selectRating(starValue)}
            onKeyDown={handleKeyDown}
            className={`flex size-12 items-center justify-center rounded-xl border shadow-sm transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60 ${
              selected
                ? 'border-orange-300 bg-orange-50 text-orange-500 shadow-orange-100 dark:border-orange-500/60 dark:bg-orange-950/50 dark:text-orange-400 dark:shadow-none'
                : 'border-slate-200 bg-slate-50 text-slate-400 hover:-translate-y-0.5 hover:border-orange-300 hover:bg-orange-50 hover:text-orange-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-500 dark:hover:border-orange-500/60 dark:hover:bg-orange-950/40 dark:hover:text-orange-400'
            }`}
          >
            <Star
              aria-hidden="true"
              className={selected ? 'fill-current' : undefined}
              size={24}
              strokeWidth={1.8}
            />
          </button>
        );
      })}
    </div>
  );
}
