import { GOOGLE_PLAY_URL } from '../lib/constants';

const footerLinks = {
  product: [
    { label: 'Tính năng', href: '#features' },
    { label: 'Bảng giá', href: '#' },
    { label: 'Hướng dẫn sử dụng', href: '#' },
    { label: 'Tải ứng dụng', href: GOOGLE_PLAY_URL },
  ],
  company: [
    { label: 'Về chúng tôi', href: '#' },
    { label: 'Tin tức', href: '#' },
    { label: 'Tuyển dụng', href: '#' },
    { label: 'Liên hệ', href: '#' },
  ],
  support: [
    { label: 'Trung tâm trợ giúp', href: '#' },
    { label: 'Câu hỏi thường gặp', href: '#' },
    { label: 'Chính sách bảo mật', href: '#' },
    { label: 'Điều khoản sử dụng', href: '#' },
  ],
};

const socialLinks = [
  { 
    icon: (
      <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
        <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"/>
      </svg>
    ),
    label: 'Twitter',
    href: '#'
  },
  { 
    icon: (
      <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
        <path d="M22.675 0h-21.35c-.732 0-1.325.593-1.325 1.325v21.351c0 .731.593 1.324 1.325 1.324h11.495v-9.294h-3.128v-3.622h3.128v-2.671c0-3.1 1.893-4.788 4.659-4.788 1.325 0 2.463.099 2.795.143v3.24l-1.918.001c-1.504 0-1.795.715-1.795 1.763v2.313h3.587l-.467 3.622h-3.12v9.293h6.116c.73 0 1.323-.593 1.323-1.325v-21.35c0-.732-.593-1.325-1.325-1.325z"/>
      </svg>
    ),
    label: 'Facebook',
    href: '#'
  },
  { 
    icon: (
      <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
      </svg>
    ),
    label: 'Instagram',
    href: '#'
  },
  { 
    icon: (
      <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
        <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
      </svg>
    ),
    label: 'LinkedIn',
    href: '#'
  },
];

export default function Footer() {
  return (
    <footer className="relative bg-gray-900 pt-16 sm:pt-20 pb-8 sm:pb-10 overflow-hidden">
      {/* Gradient border top */}
      <div className="absolute top-0 left-0 right-0 h-0.5 sm:h-1 bg-gradient-to-r from-orange-500 via-orange-600 to-red-500" />
      
      {/* Background pattern */}
      <div className="absolute inset-0 grid-bg-dark opacity-20" />
      
      {/* Glow effect */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] sm:w-[800px] h-[200px] sm:h-[300px] bg-orange-500/10 blur-[150px]" />

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6">
        {/* Main Footer Content */}
        <div className="grid gap-10 lg:grid-cols-5">
          {/* Brand Column */}
          <div className="lg:col-span-2">
            {/* Logo */}
            <a href="#" className="flex items-center gap-2 sm:gap-3 mb-6">
              <img
                src="/LOGO-EBOX.png"
                alt="E-BOX Logo"
                className="h-12 sm:h-16 w-auto object-contain"
              />
              <div>
                <span className="text-xl sm:text-2xl font-black text-white">E</span>
                <span className="text-xl sm:text-2xl font-black gradient-text">-BOX</span>
              </div>
            </a>
            
            <p className="text-gray-400 leading-relaxed max-w-md mb-6 sm:mb-8 text-sm sm:text-base">
              E-BOX là giải pháp tủ locker thông minh dành cho sinh viên FPT University. 
              Giúp bạn gửi nhận hàng, lưu trữ đồ cá nhân tiện lợi và an toàn 24/7.
            </p>

            {/* Social Links */}
            <div className="flex items-center gap-3 sm:gap-4">
              {socialLinks.map((social) => (
                <a
                  key={social.label}
                  href={social.href}
                  className="liquid-button-dark flex h-9 w-9 sm:h-10 sm:w-10 items-center justify-center rounded-xl text-gray-400 transition-all duration-300 hover:text-white"
                  aria-label={social.label}
                >
                  {social.icon}
                </a>
              ))}
            </div>
          </div>

          {/* Links Columns */}
          <div className="lg:col-span-3">
            <div className="grid gap-8 sm:grid-cols-3">
              {/* Product */}
              <div>
                <h4 className="text-xs sm:text-sm font-bold uppercase tracking-wider text-white mb-4">
                  Sản phẩm
                </h4>
                <ul className="space-y-2 sm:space-y-3">
                  {footerLinks.product.map((link) => (
                    <li key={link.label}>
                      <a
                        href={link.href}
                        className="text-gray-400 transition-colors hover:text-orange-400 text-sm"
                      >
                        {link.label}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Company */}
              <div>
                <h4 className="text-xs sm:text-sm font-bold uppercase tracking-wider text-white mb-4">
                  Công ty
                </h4>
                <ul className="space-y-2 sm:space-y-3">
                  {footerLinks.company.map((link) => (
                    <li key={link.label}>
                      <a
                        href={link.href}
                        className="text-gray-400 transition-colors hover:text-orange-400 text-sm"
                      >
                        {link.label}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Support */}
              <div>
                <h4 className="text-xs sm:text-sm font-bold uppercase tracking-wider text-white mb-4">
                  Hỗ trợ
                </h4>
                <ul className="space-y-2 sm:space-y-3">
                  {footerLinks.support.map((link) => (
                    <li key={link.label}>
                      <a
                        href={link.href}
                        className="text-gray-400 transition-colors hover:text-orange-400 text-sm"
                      >
                        {link.label}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </div>

        {/* Download App Banner */}
        <div className="liquid-glass-accent mt-12 sm:mt-16 p-4 sm:p-6 md:p-8 rounded-2xl sm:rounded-3xl">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6 sm:gap-8">
            <div className="text-center md:text-left">
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-2">
                Tải ứng dụng E-BOX
              </h3>
              <p className="text-gray-600 text-sm sm:text-base">
                Trải nghiệm ngay hôm nay trên Android
              </p>
            </div>
            <div className="flex items-center gap-4">
              <a
                href={GOOGLE_PLAY_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="glass-btn-google"
              >
                <svg className="h-6 w-6 sm:h-8 sm:w-8 flex-shrink-0" viewBox="0 0 24 24" fill="#3DDC84" xmlns="http://www.w3.org/2000/svg">
                  <path d="M7 3L9.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                  <path d="M17 3L14.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                  <path d="M2.5 15.5C2.5 9.7 6.7 5 12 5C17.3 5 21.5 9.7 21.5 15.5V21H2.5V15.5Z" fill="#3DDC84"/>
                  <circle cx="8.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
                  <circle cx="15.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
                </svg>
                <div className="text-left">
                  <div className="text-[8px] sm:text-[10px] font-medium uppercase tracking-wider opacity-90">Tải về</div>
                  <div className="text-sm sm:text-base font-bold">APK Android</div>
                </div>
              </a>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="mt-8 sm:mt-12 pt-6 sm:pt-8 border-t border-gray-800">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4 text-center md:text-left">
            <div className="text-gray-500 text-xs sm:text-sm">
              © {new Date().getFullYear()} E-BOX. All rights reserved. Developed by SWP391 Team.
            </div>
            <div className="flex items-center gap-4 text-xs sm:text-sm flex-wrap justify-center">
              <a href="#" className="text-gray-500 hover:text-orange-400 transition-colors">
                Chính sách bảo mật
              </a>
              <span className="text-gray-700">|</span>
              <a href="#" className="text-gray-500 hover:text-orange-400 transition-colors">
                Điều khoản sử dụng
              </a>
              <span className="text-gray-700">|</span>
              <a href="#" className="text-gray-500 hover:text-orange-400 transition-colors">
                Sitemap
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
