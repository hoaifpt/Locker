import { Globe, Lock, Mail, Phone } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="bg-[#0F172A] text-gray-400">
      <div className="mx-auto max-w-7xl px-6 py-16">
        <div className="grid gap-10 md:grid-cols-4">
          {/* Brand */}
          <div className="md:col-span-1">
            <a href="#" className="flex items-center gap-2 text-xl font-bold text-white">
              <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500">
                <Lock size={16} className="text-white" />
              </span>
              LuxeLock
            </a>
            <p className="mt-4 text-sm leading-relaxed">
              Hệ sinh thái tủ khóa thông minh hàng đầu, kết nối và bảo vệ cuộc sống hiện đại.
            </p>
            <div className="mt-6 flex gap-4">
              <a href="mailto:hello@luxelock.io" className="transition hover:text-orange-400">
                <Mail size={18} />
              </a>
              <a href="tel:+84900000000" className="transition hover:text-orange-400">
                <Phone size={18} />
              </a>
              <a href="#" className="transition hover:text-orange-400">
                <Globe size={18} />
              </a>
            </div>
          </div>

          {/* Products */}
          <div>
            <p className="mb-4 text-sm font-semibold uppercase tracking-widest text-white">
              Sản phẩm
            </p>
            <ul className="space-y-3 text-sm">
              {['Tính năng', 'Phần cứng', 'Tích hợp', 'Bảo mật', 'Giá cả'].map((item) => (
                <li key={item}>
                  <a href="#" className="transition hover:text-orange-400">
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <p className="mb-4 text-sm font-semibold uppercase tracking-widest text-white">
              Công ty
            </p>
            <ul className="space-y-3 text-sm">
              {['Về chúng tôi', 'Liên hệ', 'Blog', 'Tuyển dụng', 'Báo chí'].map((item) => (
                <li key={item}>
                  <a href="#" className="transition hover:text-orange-400">
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Newsletter */}
          <div>
            <p className="mb-4 text-sm font-semibold uppercase tracking-widest text-white">
              Nhận tin tức
            </p>
            <p className="mb-4 text-sm">Cập nhật tính năng mới và ưu đãi độc quyền.</p>
            <form className="flex flex-col gap-2" onSubmit={(e) => e.preventDefault()}>
              <input
                type="email"
                placeholder="Email của bạn"
                className="rounded-lg bg-white/10 px-4 py-2 text-sm text-white placeholder-gray-500 outline-none ring-1 ring-white/10 focus:ring-orange-500"
              />
              <button
                type="submit"
                className="rounded-lg bg-orange-500 py-2 text-sm font-semibold text-white transition hover:bg-orange-600"
              >
                Đăng ký
              </button>
            </form>
          </div>
        </div>

        <div className="mt-16 border-t border-white/10 pt-8 text-center text-xs text-gray-600">
          © 2024 LuxeLock Systems. Bảo lưu mọi quyền.
        </div>
      </div>
    </footer>
  );
}
