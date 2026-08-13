/**
 * ASP.NET Core serializes FeedbackTopic as its numeric enum value because the
 * backend does not register JsonStringEnumConverter.
 */
export const FeedbackTopic = {
  General: 0,
  BookingOrder: 1,
  Payment: 2,
  Delivery: 3,
  Interface: 4,
  Other: 5,
} as const;

export type FeedbackTopic = (typeof FeedbackTopic)[keyof typeof FeedbackTopic];
export type FeedbackTopicName = keyof typeof FeedbackTopic;

export const FEEDBACK_TOPIC_LABELS: Record<FeedbackTopic, string> = {
  [FeedbackTopic.General]: 'Trải nghiệm chung',
  [FeedbackTopic.BookingOrder]: 'Đặt tủ / đơn hàng',
  [FeedbackTopic.Payment]: 'Thanh toán',
  [FeedbackTopic.Delivery]: 'Giao nhận',
  [FeedbackTopic.Interface]: 'Giao diện',
  [FeedbackTopic.Other]: 'Khác',
};

export interface UpsertFeedbackInput {
  rating: number;
  topic: FeedbackTopic;
  content: string;
  pageUrl: string;
}

export interface FeedbackDto {
  id: string;
  rating: number;
  topic: FeedbackTopic;
  content: string;
  pageUrl: string;
  isVisible: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PublicFeedbackDto {
  username: string;
  rating: number;
  topic: FeedbackTopic;
  content: string;
  updatedAt: string;
}

export interface RatingDistributionDto {
  rating: number;
  count: number;
}

export interface TopicDistributionDto {
  topic: FeedbackTopic;
  count: number;
}

export interface FeedbackSummaryDto {
  totalReviewers: number;
  averageRating: number;
  visibleReviewers: number;
  ratingDistribution: RatingDistributionDto[];
  topicDistribution: TopicDistributionDto[];
}

export interface PublicFeedbackResponse {
  averageRating: number;
  totalVisibleReviewers: number;
  reviews: PublicFeedbackDto[];
}

export interface FeedbackFilters {
  rating?: number;
  topic?: FeedbackTopic;
  visibility?: boolean;
  search?: string;
  page?: number;
  pageSize?: number;
}

export interface AdminFeedbackItemDto {
  id: string;
  username: string;
  rating: number;
  topic: FeedbackTopic;
  content: string;
  pageUrl: string;
  isVisible: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PaginatedResult<T> {
  items: T[];
  totalCount: number;
  pageNumber: number;
  pageSize: number;
  totalPages: number;
  hasPreviousPage: boolean;
  hasNextPage: boolean;
}

export interface AdminFeedbackResponse {
  page: PaginatedResult<AdminFeedbackItemDto>;
  summary: FeedbackSummaryDto;
}
