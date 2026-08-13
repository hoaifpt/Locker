import {
  ChevronLeft,
  ChevronRight,
  Download,
  Eye,
  EyeOff,
  LoaderCircle,
  MessageSquareText,
  RefreshCw,
  Search,
  ShieldCheck,
  Star,
} from 'lucide-react';
import { useCallback, useEffect, useRef, useState } from 'react';
import AppHeader from '../../../components/layout/AppHeader';
import { useToast } from '../../../context/ToastContext';
import {
  downloadFeedbackCsv,
  getAdminFeedback,
  setFeedbackVisibility,
} from '../api/feedbackApi';
import {
  FEEDBACK_TOPIC_LABELS,
  FeedbackTopic,
  type AdminFeedbackItemDto,
  type AdminFeedbackResponse,
  type FeedbackFilters,
} from '../types';

const PAGE_SIZE = 20;
const RATINGS = [5, 4, 3, 2, 1] as const;
const TOPICS = Object.values(FeedbackTopic);

function getErrorMessage(error: unknown, fallback: string) {
  return error instanceof Error && error.message ? error.message : fallback;
}

function filtersMatch(left: FeedbackFilters, right: FeedbackFilters) {
  return (
    left.page === right.page &&
    left.pageSize === right.pageSize &&
    left.rating === right.rating &&
    left.topic === right.topic &&
    left.visibility === right.visibility &&
    left.search === right.search
  );
}

function formatDateTime(value: string) {
  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return 'Không xác định';
  }

  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(date);
}

function DistributionBar({ label, count, total }: { label: string; count: number; total: number }) {
  const percentage = total === 0 ? 0 : Math.round((count / total) * 100);

  return (
    <div>
      <div className="mb-1.5 flex items-center justify-between gap-3 text-sm">
        <span className="font-medium text-gray-700">{label}</span>
        <span className="shrink-0 tabular-nums text-gray-500">
          {count} ({percentage}%)
        </span>
      </div>
      <div
        role="progressbar"
        aria-label={`${label}: ${count} đánh giá, ${percentage}%`}
        aria-valuemin={0}
        aria-valuemax={Math.max(total, 1)}
        aria-valuenow={count}
        className="h-2.5 overflow-hidden rounded-full bg-gray-100"
      >
        <div className="h-full rounded-full bg-orange-500 transition-[width]" style={{ width: `${percentage}%` }} />
      </div>
    </div>
  );
}

function LoadingState() {
  return (
    <div className="space-y-6" aria-label="Đang tải dữ liệu feedback" aria-busy="true">
      <div className="grid gap-4 sm:grid-cols-3">
        {Array.from({ length: 3 }, (_, index) => (
          <div key={index} className="h-32 animate-pulse rounded-2xl bg-gray-200" />
        ))}
      </div>
      <div className="h-72 animate-pulse rounded-2xl bg-gray-200" />
    </div>
  );
}

function FeedbackContent({ item }: { item: AdminFeedbackItemDto }) {
  return (
    <details className="group max-w-xs">
      <summary className="cursor-pointer list-none rounded text-sm text-gray-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500">
        <span className="block max-h-10 overflow-hidden whitespace-pre-wrap break-words group-open:max-h-none">
          {item.content}
        </span>
        <span className="mt-1 inline-block text-xs font-semibold text-orange-600 group-open:hidden">Xem đầy đủ</span>
      </summary>
    </details>
  );
}

export default function AdminFeedbackPage() {
  const { show: showToast } = useToast();
  const [filters, setFilters] = useState<FeedbackFilters>({ page: 1, pageSize: PAGE_SIZE });
  const [searchValue, setSearchValue] = useState('');
  const [feedback, setFeedback] = useState<AdminFeedbackResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [updatingIds, setUpdatingIds] = useState<Set<string>>(() => new Set());
  const [isExporting, setIsExporting] = useState(false);
  const requestIdRef = useRef(0);
  const filterVersionRef = useRef(0);
  const normalizedEffectQueryRef = useRef<FeedbackFilters | null>(null);
  const isMountedRef = useRef(true);
  const filtersRef = useRef(filters);

  const loadFeedback = useCallback(async (query: FeedbackFilters, allowPageNormalization = true) => {
    const requestId = ++requestIdRef.current;
    const filterVersion = filterVersionRef.current;

    if (isMountedRef.current) {
      setIsLoading(true);
      setErrorMessage(null);
    }

    try {
      const response = await getAdminFeedback(query);
      if (
        isMountedRef.current &&
        requestId === requestIdRef.current &&
        filterVersion === filterVersionRef.current
      ) {
        const maximumPage = Math.max(response.page.totalPages, 1);
        const requestedPage = query.page ?? 1;

        if (allowPageNormalization && requestedPage > maximumPage && filtersMatch(filtersRef.current, query)) {
          const normalizedQuery = { ...query, page: maximumPage };
          normalizedEffectQueryRef.current = normalizedQuery;
          filterVersionRef.current += 1;
          setFilters((current) => filtersMatch(current, query) ? normalizedQuery : current);
          await loadFeedback(normalizedQuery, false);
          return;
        }

        setFeedback(response);
      }
    } catch (error) {
      if (
        isMountedRef.current &&
        requestId === requestIdRef.current &&
        filterVersion === filterVersionRef.current
      ) {
        setErrorMessage(getErrorMessage(error, 'Không thể tải dữ liệu feedback.'));
      }
    } finally {
      if (
        isMountedRef.current &&
        requestId === requestIdRef.current &&
        filterVersion === filterVersionRef.current
      ) {
        setIsLoading(false);
      }
    }
  }, []);

  useEffect(() => {
    isMountedRef.current = true;

    return () => {
      isMountedRef.current = false;
      requestIdRef.current += 1;
    };
  }, []);

  useEffect(() => {
    filtersRef.current = filters;

    if (normalizedEffectQueryRef.current && filtersMatch(normalizedEffectQueryRef.current, filters)) {
      normalizedEffectQueryRef.current = null;
      return;
    }

    normalizedEffectQueryRef.current = null;
    void loadFeedback(filters);
  }, [filters, loadFeedback]);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      const normalizedSearch = searchValue.trim() || undefined;
      if (filtersRef.current.search === normalizedSearch) {
        return;
      }

      filterVersionRef.current += 1;
      setFilters((current) => ({ ...current, search: normalizedSearch, page: 1 }));
    }, 300);

    return () => window.clearTimeout(timeoutId);
  }, [searchValue]);

  const updateFilter = <K extends 'rating' | 'topic' | 'visibility'>(key: K, value: FeedbackFilters[K]) => {
    filterVersionRef.current += 1;
    setFilters((current) => ({ ...current, [key]: value, page: 1 }));
  };

  const resetFilters = () => {
    setSearchValue('');
    filterVersionRef.current += 1;
    setFilters({ page: 1, pageSize: PAGE_SIZE });
  };

  const changePage = (page: number) => {
    filterVersionRef.current += 1;
    setFilters((current) => ({ ...current, page }));
  };

  const handleVisibilityChange = async (item: AdminFeedbackItemDto) => {
    setUpdatingIds((current) => new Set(current).add(item.id));

    try {
      await setFeedbackVisibility(item.id, !item.isVisible);
      if (!isMountedRef.current) return;

      showToast(item.isVisible ? 'Đã ẩn feedback.' : 'Đã hiển thị feedback.', 'success');
      await loadFeedback(filtersRef.current);
    } catch (error) {
      if (isMountedRef.current) {
        showToast(getErrorMessage(error, 'Không thể cập nhật trạng thái feedback.'), 'error');
      }
    } finally {
      if (isMountedRef.current) {
        setUpdatingIds((current) => {
          const next = new Set(current);
          next.delete(item.id);
          return next;
        });
      }
    }
  };

  const handleExport = async () => {
    setIsExporting(true);

    try {
      const { rating, topic, visibility, search } = filtersRef.current;
      await downloadFeedbackCsv({ rating, topic, visibility, search });
    } catch (error) {
      if (isMountedRef.current) {
        showToast(getErrorMessage(error, 'Không thể xuất file CSV.'), 'error');
      }
    } finally {
      if (isMountedRef.current) {
        setIsExporting(false);
      }
    }
  };

  const summary = feedback?.summary;
  const page = feedback?.page;
  const distributionTotal = summary?.ratingDistribution.reduce((sum, bucket) => sum + bucket.count, 0) ?? 0;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        <div className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-purple-200 bg-purple-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-purple-600">
            <ShieldCheck size={13} aria-hidden="true" /> Quản trị viên
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Quản lý feedback</h1>
          <p className="mt-2 text-sm text-gray-600">Theo dõi đánh giá và kiểm soát nội dung hiển thị công khai.</p>
        </div>

        {isLoading && !feedback ? (
          <LoadingState />
        ) : errorMessage ? (
          <div role="alert" className="rounded-2xl border border-red-100 bg-red-50 px-5 py-5 text-sm text-red-700">
            <p>{errorMessage}</p>
            <button
              type="button"
              onClick={() => void loadFeedback(filtersRef.current)}
              className="mt-3 inline-flex items-center gap-2 rounded-lg bg-red-600 px-3 py-2 font-semibold text-white transition hover:bg-red-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-red-500 focus-visible:ring-offset-2"
            >
              <RefreshCw size={15} aria-hidden="true" /> Thử lại
            </button>
          </div>
        ) : feedback && summary && page ? (
          <>
            <section aria-label="Tổng quan feedback" className="grid gap-4 sm:grid-cols-3">
              <div className={`rounded-2xl border p-5 shadow-sm ${summary.totalReviewers >= 10 ? 'border-green-200 bg-green-50' : 'border-gray-100 bg-white'}`}>
                <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${summary.totalReviewers >= 10 ? 'bg-green-500' : 'bg-orange-500'}`}>
                  <MessageSquareText size={19} className="text-white" aria-hidden="true" />
                </div>
                <p className="mt-4 text-xl font-extrabold text-gray-900">Đã có {summary.totalReviewers}/10 người dùng đánh giá</p>
                <p className="mt-1 text-xs text-gray-500">Mốc bằng chứng đánh giá toàn hệ thống</p>
              </div>
              <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-500">
                  <Star size={19} className="fill-current text-white" aria-hidden="true" />
                </div>
                <p className="mt-4 text-3xl font-extrabold text-gray-900">{summary.averageRating.toFixed(1)}</p>
                <p className="mt-1 text-sm text-gray-500">Điểm trung bình</p>
              </div>
              <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-500">
                  <Eye size={19} className="text-white" aria-hidden="true" />
                </div>
                <p className="mt-4 text-3xl font-extrabold text-gray-900">{summary.visibleReviewers}</p>
                <p className="mt-1 text-sm text-gray-500">Review đang hiển thị</p>
              </div>
            </section>

            <section aria-labelledby="distribution-heading" className="mt-6 grid gap-6 lg:grid-cols-2">
              <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
                <h2 id="distribution-heading" className="font-bold text-gray-900">Phân bố điểm đánh giá</h2>
                <div className="mt-5 space-y-4">
                  {[...summary.ratingDistribution]
                    .sort((left, right) => right.rating - left.rating)
                    .map((bucket) => (
                      <DistributionBar key={bucket.rating} label={`${bucket.rating} sao`} count={bucket.count} total={distributionTotal} />
                    ))}
                </div>
              </div>
              <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
                <h2 className="font-bold text-gray-900">Phân bố chủ đề</h2>
                <div className="mt-5 space-y-4">
                  {summary.topicDistribution.map((bucket) => (
                    <DistributionBar key={bucket.topic} label={FEEDBACK_TOPIC_LABELS[bucket.topic]} count={bucket.count} total={distributionTotal} />
                  ))}
                </div>
              </div>
            </section>

            <section aria-labelledby="feedback-list-heading" className="mt-6 rounded-2xl border border-gray-100 bg-white shadow-sm">
              <div className="border-b border-gray-100 p-5">
                <div className="flex flex-col gap-4 xl:flex-row xl:items-end xl:justify-between">
                  <div>
                    <h2 id="feedback-list-heading" className="font-bold text-gray-900">Danh sách feedback</h2>
                    <p className="mt-1 text-sm text-gray-500">{page.totalCount} kết quả theo bộ lọc hiện tại</p>
                  </div>
                  <div className="grid flex-1 gap-3 sm:grid-cols-2 xl:max-w-4xl xl:grid-cols-5">
                    <label className="text-xs font-semibold text-gray-600">
                      Điểm
                      <select
                        value={filters.rating ?? ''}
                        onChange={(event) => updateFilter('rating', event.target.value ? Number(event.target.value) : undefined)}
                        className="mt-1 block w-full rounded-xl border border-gray-200 bg-white px-3 py-2.5 text-sm font-normal text-gray-700 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
                      >
                        <option value="">Tất cả</option>
                        {RATINGS.map((rating) => <option key={rating} value={rating}>{rating} sao</option>)}
                      </select>
                    </label>
                    <label className="text-xs font-semibold text-gray-600">
                      Chủ đề
                      <select
                        value={filters.topic ?? ''}
                        onChange={(event) => updateFilter('topic', event.target.value === '' ? undefined : Number(event.target.value) as FeedbackTopic)}
                        className="mt-1 block w-full rounded-xl border border-gray-200 bg-white px-3 py-2.5 text-sm font-normal text-gray-700 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
                      >
                        <option value="">Tất cả</option>
                        {TOPICS.map((topic) => <option key={topic} value={topic}>{FEEDBACK_TOPIC_LABELS[topic]}</option>)}
                      </select>
                    </label>
                    <label className="text-xs font-semibold text-gray-600">
                      Trạng thái
                      <select
                        value={filters.visibility === undefined ? '' : String(filters.visibility)}
                        onChange={(event) => updateFilter('visibility', event.target.value === '' ? undefined : event.target.value === 'true')}
                        className="mt-1 block w-full rounded-xl border border-gray-200 bg-white px-3 py-2.5 text-sm font-normal text-gray-700 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
                      >
                        <option value="">Tất cả</option>
                        <option value="true">Đang hiển thị</option>
                        <option value="false">Đang ẩn</option>
                      </select>
                    </label>
                    <label className="text-xs font-semibold text-gray-600 sm:col-span-2 xl:col-span-2">
                      Tìm kiếm
                      <span className="relative mt-1 block">
                        <Search size={16} aria-hidden="true" className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                        <input
                          type="search"
                          value={searchValue}
                          maxLength={200}
                          onChange={(event) => setSearchValue(event.target.value)}
                          placeholder="Tên người dùng hoặc nội dung"
                          className="block w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-9 pr-3 text-sm font-normal text-gray-700 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
                        />
                      </span>
                    </label>
                  </div>
                </div>
                <div className="mt-4 flex flex-wrap gap-3">
                  <button
                    type="button"
                    onClick={resetFilters}
                    className="inline-flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2"
                  >
                    <RefreshCw size={16} aria-hidden="true" /> Đặt lại bộ lọc
                  </button>
                  <button
                    type="button"
                    onClick={() => void handleExport()}
                    disabled={isExporting}
                    className="inline-flex items-center gap-2 rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
                  >
                    {isExporting ? <LoaderCircle size={16} className="animate-spin" aria-hidden="true" /> : <Download size={16} aria-hidden="true" />}
                    {isExporting ? 'Đang xuất...' : 'Xuất CSV'}
                  </button>
                  {isLoading && <span role="status" className="self-center text-sm text-gray-500">Đang cập nhật dữ liệu...</span>}
                </div>
              </div>

              {page.items.length === 0 ? (
                <div className="px-6 py-16 text-center">
                  <MessageSquareText size={36} className="mx-auto text-gray-300" aria-hidden="true" />
                  <p className="mt-3 font-semibold text-gray-800">Không tìm thấy feedback phù hợp.</p>
                  <p className="mt-1 text-sm text-gray-500">Hãy thử thay đổi hoặc đặt lại bộ lọc.</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="min-w-[1200px] w-full text-left text-sm">
                    <thead className="bg-gray-50 text-xs uppercase tracking-wide text-gray-600">
                      <tr>
                        <th scope="col" className="px-4 py-3 font-semibold">Người dùng</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Sao</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Chủ đề</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Nội dung</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Trang gửi</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Tạo lúc</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Cập nhật lúc</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Trạng thái</th>
                        <th scope="col" className="px-4 py-3 font-semibold">Hành động</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                      {page.items.map((item) => {
                        const isUpdating = updatingIds.has(item.id);
                        return (
                          <tr key={item.id} className="align-top transition hover:bg-orange-50/30">
                            <td className="px-4 py-4 font-semibold text-gray-900">{item.username}</td>
                            <td className="px-4 py-4"><span className="font-semibold text-amber-600">{item.rating}/5</span></td>
                            <td className="px-4 py-4 text-gray-700">{FEEDBACK_TOPIC_LABELS[item.topic]}</td>
                            <td className="px-4 py-4"><FeedbackContent item={item} /></td>
                            <td className="max-w-48 px-4 py-4"><span className="block truncate text-gray-600" title={item.pageUrl}>{item.pageUrl}</span></td>
                            <td className="whitespace-nowrap px-4 py-4 text-gray-600">{formatDateTime(item.createdAt)}</td>
                            <td className="whitespace-nowrap px-4 py-4 text-gray-600">{formatDateTime(item.updatedAt)}</td>
                            <td className="px-4 py-4">
                              <span className={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${item.isVisible ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>
                                {item.isVisible ? 'Đang hiển thị' : 'Đang ẩn'}
                              </span>
                            </td>
                            <td className="px-4 py-4">
                              <button
                                type="button"
                                onClick={() => void handleVisibilityChange(item)}
                                disabled={isUpdating}
                                aria-label={item.isVisible ? `Ẩn feedback của ${item.username}` : `Hiển thị feedback của ${item.username}`}
                                className="inline-flex items-center gap-1.5 whitespace-nowrap rounded-lg border border-gray-200 px-3 py-2 text-xs font-semibold text-gray-700 transition hover:border-orange-200 hover:bg-orange-50 hover:text-orange-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
                              >
                                {isUpdating ? <LoaderCircle size={14} className="animate-spin" aria-hidden="true" /> : item.isVisible ? <EyeOff size={14} aria-hidden="true" /> : <Eye size={14} aria-hidden="true" />}
                                {isUpdating ? 'Đang lưu...' : item.isVisible ? 'Ẩn' : 'Hiển thị'}
                              </button>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}

              <div className="flex flex-col gap-3 border-t border-gray-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
                <p className="text-sm text-gray-600">
                  Trang <span className="font-semibold text-gray-900">{page.pageNumber}</span> / {Math.max(page.totalPages, 1)}
                </p>
                <div className="flex gap-2">
                  <button
                    type="button"
                    disabled={!page.hasPreviousPage || isLoading}
                    onClick={() => changePage(page.pageNumber - 1)}
                    className="inline-flex items-center gap-1 rounded-lg border border-gray-200 px-3 py-2 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <ChevronLeft size={16} aria-hidden="true" /> Trang trước
                  </button>
                  <button
                    type="button"
                    disabled={!page.hasNextPage || isLoading}
                    onClick={() => changePage(page.pageNumber + 1)}
                    className="inline-flex items-center gap-1 rounded-lg border border-gray-200 px-3 py-2 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    Trang sau <ChevronRight size={16} aria-hidden="true" />
                  </button>
                </div>
              </div>
            </section>
          </>
        ) : null}
      </main>
    </div>
  );
}
