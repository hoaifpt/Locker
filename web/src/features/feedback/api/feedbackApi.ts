import { apiFetch } from '../../../lib/api';
import type {
  AdminFeedbackResponse,
  FeedbackDto,
  FeedbackFilters,
  PublicFeedbackResponse,
  UpsertFeedbackInput,
} from '../types';

const DEFAULT_ERROR_MESSAGE = 'Không thể xử lý yêu cầu.';

async function getErrorMessage(response: Response): Promise<string> {
  const body = await response.json().catch(() => null);
  return body?.message ?? DEFAULT_ERROR_MESSAGE;
}

async function readJson<T>(response: Response): Promise<T> {
  if (!response.ok) {
    throw new Error(await getErrorMessage(response));
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

function buildQuery(filters: FeedbackFilters): string {
  const params = new URLSearchParams();

  for (const [key, value] of Object.entries(filters)) {
    if (value !== undefined && value !== '') {
      params.set(key, String(value));
    }
  }

  const query = params.toString();
  return query ? `?${query}` : '';
}

function getCsvFilename(contentDisposition: string | null): string {
  if (!contentDisposition) {
    return 'feedbacks.csv';
  }

  const encodedFilename = /filename\*\s*=\s*(?:[^']*'[^']*')?([^;]+)/i.exec(contentDisposition)?.[1];
  if (encodedFilename) {
    try {
      return decodeURIComponent(encodedFilename.trim().replace(/^"|"$/g, ''));
    } catch {
      return encodedFilename.trim().replace(/^"|"$/g, '');
    }
  }

  const filename = /filename\s*=\s*(?:"([^"]+)"|([^;]+))/i.exec(contentDisposition);
  return filename?.[1] ?? filename?.[2]?.trim() ?? 'feedbacks.csv';
}

export async function getMyFeedback(): Promise<FeedbackDto | null> {
  const response = await apiFetch('/feedbacks/me');
  return response.status === 204 ? null : readJson<FeedbackDto>(response);
}

export async function upsertMyFeedback(input: UpsertFeedbackInput): Promise<FeedbackDto> {
  const response = await apiFetch('/feedbacks/me', {
    method: 'PUT',
    data: input,
  });
  return readJson<FeedbackDto>(response);
}

export async function getPublicFeedback(limit = 6): Promise<PublicFeedbackResponse> {
  const response = await apiFetch(`/feedbacks/public?limit=${encodeURIComponent(limit)}`);
  return readJson<PublicFeedbackResponse>(response);
}

export async function getAdminFeedback(filters: FeedbackFilters = {}): Promise<AdminFeedbackResponse> {
  const response = await apiFetch(`/admin/feedbacks${buildQuery(filters)}`);
  return readJson<AdminFeedbackResponse>(response);
}

export async function setFeedbackVisibility(id: string, isVisible: boolean): Promise<void> {
  const response = await apiFetch(`/admin/feedbacks/${encodeURIComponent(id)}/visibility`, {
    method: 'PATCH',
    data: { isVisible },
  });
  await readJson<void>(response);
}

export async function downloadFeedbackCsv(filters: FeedbackFilters = {}): Promise<void> {
  const response = await apiFetch(`/admin/feedbacks/export${buildQuery(filters)}`);
  if (!response.ok) {
    throw new Error(await getErrorMessage(response));
  }

  const objectUrl = URL.createObjectURL(await response.blob());
  const anchor = document.createElement('a');
  anchor.href = objectUrl;
  anchor.download = getCsvFilename(response.headers.get('Content-Disposition'));

  document.body.appendChild(anchor);
  try {
    anchor.click();
  } finally {
    anchor.remove();
    URL.revokeObjectURL(objectUrl);
  }
}
