/**
 * Shared client-side validation for the auth feature (login / register).
 *
 * The rules below intentionally mirror the backend constraints so we fail
 * fast in the browser and don't end up with the dreaded
 * "Đăng ký thất bại. Vui lòng thử lại." banner the user has been seeing:
 *
 *   - Username:  3-30 chars, alphanumeric + `._-` only
 *   - Email:     RFC-ish shape (good-enough for FE), max 254 chars
 *   - Phone:     Vietnamese mobile (10 digits, `0` or `+84` prefix)
 *   - Password:  ≥8 chars, must contain uppercase + lowercase + digit
 *   (matches backend IdentityOptions in
 *    backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs)
 *
 * Each validator returns either `''` (valid) or a Vietnamese error string
 * that can be rendered directly under the field.
 */

export interface RegisterForm {
    username: string;
    email: string;
    fullName: string;
    phoneNumber: string;
    password: string;
    confirm: string;
}

export type RegisterErrors = Partial<Record<keyof RegisterForm, string>>;

// Username: 3-30 chars, starts with a letter/digit, only letters/digits/_.
const USERNAME_RE = /^[A-Za-z0-9][A-Za-z0-9._-]{2,29}$/;

// Pragmatic email check — enough to catch the common typos the backend's
// `[EmailAddress]` would reject, without being RFC-strict and rejecting
// valid addresses.
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Vietnamese mobile: 0xxxxxxxxx (10 digits) or +84xxxxxxxxx.
const PHONE_RE = /^(?:\+?84|0)(?:3|5|7|8|9)[0-9]{8}$/;

export function validateUsername(value: string): string {
    const v = value.trim();
    if (!v) return 'Vui lòng nhập tên đăng nhập.';
    if (v.length < 3) return 'Tên đăng nhập phải có ít nhất 3 ký tự.';
    if (v.length > 30) return 'Tên đăng nhập tối đa 30 ký tự.';
    if (!USERNAME_RE.test(v)) {
        return 'Chỉ được dùng chữ cái, số, dấu chấm, gạch dưới, gạch ngang.';
    }
    return '';
}

export function validateEmail(value: string): string {
    const v = value.trim();
    if (!v) return 'Vui lòng nhập email.';
    if (v.length > 254) return 'Email quá dài.';
    if (!EMAIL_RE.test(v)) return 'Email không đúng định dạng.';
    return '';
}

export function validateVietnamesePhone(value: string): string {
    const v = value.trim();
    if (!v) return ''; // optional
    // Strip spaces/dashes before testing.
    const normalized = v.replace(/[\s-]/g, '');
    if (!PHONE_RE.test(normalized)) {
        return 'Số điện thoại không hợp lệ (vd: 0912345678).';
    }
    return '';
}

export function validatePassword(value: string): string {
    if (!value) return 'Vui lòng nhập mật khẩu.';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự.';
    if (!/[a-z]/.test(value)) return 'Mật khẩu phải có ít nhất 1 chữ thường.';
    if (!/[A-Z]/.test(value)) return 'Mật khẩu phải có ít nhất 1 chữ hoa.';
    if (!/[0-9]/.test(value)) return 'Mật khẩu phải có ít nhất 1 chữ số.';
    return '';
}

export function validateConfirm(value: string, password: string): string {
    if (!value) return 'Vui lòng xác nhận mật khẩu.';
    if (value !== password) return 'Mật khẩu xác nhận không khớp.';
    return '';
}

/**
 * Runs every register-form validator and returns a flat map. Empty string
 * = field is valid. Used both for real-time UI gating and submit gating.
 */
export function validateRegisterForm(form: RegisterForm): RegisterErrors {
    return {
        username: validateUsername(form.username),
        email: validateEmail(form.email),
        fullName: '',
        phoneNumber: validateVietnamesePhone(form.phoneNumber),
        password: validatePassword(form.password),
        confirm: validateConfirm(form.confirm, form.password),
    };
}

export function hasErrors(errors: RegisterErrors): boolean {
    return Object.values(errors).some((v) => !!v);
}

/**
 * Pull a human message out of an `apiFetch` error response. ASP.NET can
 * return several shapes depending on where validation fails:
 *
 *   - ProblemDetails:   { title, errors: { Field: ["…"] } }
 *   - Identity errors:  { message: "Username 'x' is invalid..." }
 *   - Flat:             { message: "…" } or { error: "…" }
 *   - String body:      "Some plain text"
 *
 * This helper normalises them into a single Vietnamese-friendly string.
 */
export async function extractApiError(
    response: Response,
    fallback: string,
): Promise<string> {
    const contentType = response.headers.get('content-type') ?? '';
    if (!contentType.includes('application/json')) {
        return response.statusText || fallback;
    }

    try {
        const data: any = await response.json();

        // 1. ProblemDetails.errors map (ASP.NET model validation).
        if (data && typeof data === 'object' && data.errors) {
            const lines: string[] = [];
            for (const [field, msgs] of Object.entries<any>(data.errors)) {
                if (Array.isArray(msgs) && msgs.length > 0) {
                    lines.push(`${field}: ${msgs[0]}`);
                }
            }
            if (lines.length > 0) return lines.join('\n');
        }

        // 2. Flat message.
        if (typeof data?.message === 'string' && data.message) {
            return data.message;
        }
        if (typeof data?.error === 'string' && data.error) {
            return data.error;
        }

        // 3. ProblemDetails.title.
        if (typeof data?.title === 'string' && data.title) {
            return data.title;
        }
    } catch {
        // body was unparseable JSON — fall through.
    }

    return fallback;
}
