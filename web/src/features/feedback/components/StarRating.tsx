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
    <div className="flex gap-1" role="group" aria-label="Mức độ hài lòng">
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
            className="rounded-lg p-1 text-gray-300 transition hover:text-orange-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
          >
            <Star
              aria-hidden="true"
              className={selected ? 'fill-current text-orange-500' : undefined}
              size={30}
              strokeWidth={2}
            />
          </button>
        );
      })}
    </div>
  );
}
