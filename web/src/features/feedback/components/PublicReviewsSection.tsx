import { Star } from 'lucide-react';
import { useCallback, useEffect, useState } from 'react';
import { getPublicFeedback } from '../api/feedbackApi';
import { FEEDBACK_TOPIC_LABELS, type PublicFeedbackResponse } from '../types';

const REVIEW_LIMIT = 6;

function ReviewStars({ rating }: { rating: number }) {
  return (
    <div className="flex gap-1" aria-label={`${rating} trên 5 sao`}>
      {Array.from({ length: 5 }, (_, index) => (
        <Star
          key={index}
          aria-hidden="true"
          className={index < Math.round(rating) ? 'fill-current text-orange-500' : 'text-gray-300'}
          size={18}
        />
      ))}
    </div>
  );
}

function ReviewSkeleton() {
  return (
    <div className="animate-pulse rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
      <div className="h-5 w-32 rounded bg-gray-200" />
      <div className="mt-4 h-4 w-24 rounded bg-gray-200" />
      <div className="mt-5 h-4 rounded bg-gray-200" />
      <div className="mt-2 h-4 w-4/5 rounded bg-gray-200" />
    </div>
  );
}

function formatUpdatedAt(updatedAt: string) {
  return new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium' }).format(new Date(updatedAt));
}

export default function PublicReviewsSection() {
  const [feedback, setFeedback] = useState<PublicFeedbackResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  const loadFeedback = useCallback(async () => {
    setIsLoading(true);
    setHasError(false);

    try {
      setFeedback(await getPublicFeedback(REVIEW_LIMIT));
    } catch {
      setHasError(true);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadFeedback();
  }, [loadFeedback]);

  return (
    <section className="bg-white py-20" aria-labelledby="public-reviews-heading">
      <div className="mx-auto max-w-7xl px-6">
        <div className="max-w-2xl">
          <span className="inline-block rounded-full bg-orange-50 px-4 py-1 text-xs font-semibold uppercase tracking-widest text-orange-500">
            Phản hồi
          </span>
          <h2 id="public-reviews-heading" className="mt-3 text-4xl font-extrabold text-gray-900">
            Người dùng nói gì
          </h2>
        </div>

        {isLoading && (
          <div className="mt-10 grid gap-4 md:grid-cols-2 lg:grid-cols-3" aria-label="Đang tải đánh giá">
            {Array.from({ length: 3 }, (_, index) => (
              <ReviewSkeleton key={index} />
            ))}
          </div>
        )}

        {!isLoading && hasError && (
          <div className="mt-8 rounded-2xl border border-orange-100 bg-orange-50 px-5 py-4 text-sm text-gray-700">
            <p>Chưa thể tải các đánh giá công khai. Vui lòng thử lại sau.</p>
            <button
              type="button"
              onClick={() => void loadFeedback()}
              className="mt-3 rounded-lg bg-orange-500 px-3 py-2 font-semibold text-white transition hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2"
            >
              Thử lại
            </button>
          </div>
        )}

        {!isLoading && !hasError && feedback && feedback.reviews.length === 0 && (
          <div className="mt-8 rounded-2xl border border-dashed border-gray-200 bg-[#F9F8F6] px-6 py-8 text-gray-700">
            <p className="font-semibold text-gray-900">Hãy là người đầu tiên chia sẻ trải nghiệm của bạn.</p>
            <p className="mt-2 text-sm">Đăng nhập và dùng nút Feedback để gửi đánh giá.</p>
          </div>
        )}

        {!isLoading && !hasError && feedback && feedback.reviews.length > 0 && (
          <>
            <div className="mt-8 flex flex-wrap items-center gap-x-4 gap-y-2">
              <span className="text-3xl font-extrabold text-gray-900">{feedback.averageRating.toFixed(1)}</span>
              <ReviewStars rating={feedback.averageRating} />
              <span className="text-sm text-gray-600">{feedback.totalVisibleReviewers} người đã đánh giá</span>
            </div>

            <div className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {feedback.reviews.slice(0, REVIEW_LIMIT).map((review, index) => (
                <article key={`${review.username}-${review.updatedAt}-${index}`} className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <h3 className="font-semibold text-gray-900">{review.username}</h3>
                      <p className="mt-1 text-sm text-orange-600">{FEEDBACK_TOPIC_LABELS[review.topic]}</p>
                    </div>
                    <span className="shrink-0 text-sm font-semibold text-gray-700">{review.rating}/5</span>
                  </div>
                  <p className="mt-4 text-sm leading-6 text-gray-700">{review.content}</p>
                  <p className="mt-5 text-xs text-gray-500">Cập nhật {formatUpdatedAt(review.updatedAt)}</p>
                </article>
              ))}
            </div>
          </>
        )}
      </div>
    </section>
  );
}
