/// Validators cho SignUp form. Trả về `null` khi hợp lệ, ngược lại
/// trả về chuỗi tiếng Việt user-friendly hiển thị dưới `TextFormField`.
///
/// Rules mirror backend để fail-fast trước khi round-trip server:
///
///   Username  : 3-30 ký tự, chữ cái/số + `._-`
///   Email     : RFC-ish (good-enough), max 254 ký tự
///   Phone     : 0xxxxxxxxx hoặc +84xxxxxxxxx (mobile VN hợp lệ)
///   Password  : ≥8 ký tự, có chữ hoa + chữ thường + số
///                (IdentityOptions trong
///                backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs)
///   Confirm   : trùng với password
library;

class SignUpValidators {
  SignUpValidators._();

  // Chữ cái/số đầu tiên, theo sau là chữ cái/số hoặc ._-
  static final _usernameRe = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{2,29}$');
  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  // 10 số, đầu số VN hợp lệ (3/5/7/8/9) — mobile & fixed-line cơ bản
  static final _phoneRe = RegExp(r'^(?:\+?84|0)(?:3|5|7|8|9)[0-9]{8}$');

  static String? username(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập tên đăng nhập';
    if (v.length < 3) return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    if (v.length > 30) return 'Tên đăng nhập tối đa 30 ký tự';
    if (!_usernameRe.hasMatch(v)) {
      return 'Chỉ được dùng chữ cái, số, dấu chấm, gạch dưới, gạch ngang';
    }
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập email';
    if (v.length > 254) return 'Email quá dài';
    if (!_emailRe.hasMatch(v)) return 'Email không đúng định dạng';
    return null;
  }

  /// Số điện thoại là optional. Trả về `null` nếu trống (user bỏ qua)
  /// hoặc hợp lệ; trả message nếu user đã gõ mà sai.
  static String? phone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    // Bỏ qua space và dấu gạch ngang trước khi test
    final normalized = v.replaceAll(RegExp(r'[\s-]'), '');
    if (!_phoneRe.hasMatch(normalized)) {
      return 'Số điện thoại không hợp lệ (vd: 0912345678)';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }
    return null;
  }

  static String? Function(String?) confirm(String password) {
    return (String? value) {
      final v = value ?? '';
      if (v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
      if (v != password) return 'Mật khẩu xác nhận không khớp';
      return null;
    };
  }
}