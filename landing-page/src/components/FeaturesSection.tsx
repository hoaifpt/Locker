import { useEffect, useRef } from 'react';

interface Feature {
  icon: React.ReactNode;
  title: string;
  description: string;
  badge?: string;
}

const features: Feature[] = [
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607zM10.5 7.5v6m3-3h-6" />
      </svg>
    ),
    title: 'Mở Khóa Từ Xa',
    description: 'Điều khiển tủ từ smartphone. Nhận mã OTP qua SMS/Email hoặc quét QR code để mở tủ nhanh chóng.',
    badge: 'NEW',
  },
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 01-.825-.242m9.345-8.334a2.126 2.126 0 00-.476-.095 48.64 48.64 0 00-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0011.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
      </svg>
    ),
    title: 'Giao Nhận Tự Động',
    description: 'Nhận hàng online 24/7. Hệ thống tự thông báo khi có đơn hàng mới và hướng dẫn lấy hàng chi tiết.',
    badge: 'HOT',
  },
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
      </svg>
    ),
    title: 'Bảo Mật Cao Cấp',
    description: 'Mã hóa 256-bit AES, camera giám sát 24/7, và hệ thống cảnh báo xâm nhập thông minh.',
  },
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    title: 'Tiết Kiệm Thời Gian',
    description: 'Không cần chờ đợi, không cần xếp hàng. Lấy và gửi đồ chỉ trong 30 giây với E-BOX.',
  },
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
    title: 'Sạc Pin Thiết Bị',
    description: 'Tủ locker được trang bị cổng sạc USB-C và sạc không dây Qi. Sạc thiết bị ngay khi lấy đồ.',
  },
  {
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25" />
      </svg>
    ),
    title: 'Ứng Dụng Thông Minh',
    description: 'Giao diện trực quan, dễ sử dụng. Theo dõi lịch sử giao dịch, nhận thông báo real-time.',
    badge: 'PRO',
  },
];

export default function FeaturesSection() {
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          entry.target.querySelectorAll('.scroll-animate').forEach((el, i) => {
            setTimeout(() => {
              el.classList.add('visible');
            }, i * 100);
          });
        }
      },
      { threshold: 0.1 }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <section ref={sectionRef} id="features" className="relative py-24 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-white to-orange-50/50" />
      <div className="absolute inset-0 grid-bg opacity-20" />
      
      {/* Decorative elements */}
      <div className="absolute top-20 left-10 w-32 h-32 border-2 border-orange-200/30 rounded-full" />
      <div className="absolute bottom-20 right-10 w-48 h-48 border-2 border-orange-300/20 rounded-full" />

      <div className="relative mx-auto max-w-7xl px-6">
        {/* Section Header */}
        <div className="text-center mb-16 scroll-animate">
          <span className="inline-flex items-center gap-2 rounded-full border-2 border-orange-200 bg-white px-5 py-2 text-sm font-bold uppercase tracking-widest text-orange-600 shadow-lg">
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
            </svg>
            Tính Năng Nổi Bật
          </span>
          <h2 className="mt-8 text-4xl font-black tracking-tight sm:text-5xl lg:text-6xl">
            <span className="text-gray-900">Giải Pháp</span>
            <br />
            <span className="gradient-text">Thông Minh</span>
          </h2>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-gray-600">
            E-BOX tích hợp công nghệ tiên tiến nhất để mang đến trải nghiệm tốt nhất cho sinh viên
          </p>
        </div>

        {/* Features Grid - Card Style */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <div
              key={feature.title}
              className="feature-card group"
              style={{ animationDelay: `${index * 100}ms` }}
            >
              {/* Badge */}
              {feature.badge && (
                <span className={`feature-badge ${
                  feature.badge === 'NEW' ? 'bg-blue-500' :
                  feature.badge === 'HOT' ? 'bg-red-500' :
                  'bg-purple-500'
                }`}>
                  {feature.badge}
                </span>
              )}

              {/* Icon Container */}
              <div className="feature-icon-container">
                <div className="feature-icon-bg" />
                <div className="feature-icon">
                  {feature.icon}
                </div>
              </div>

              {/* Content */}
              <div className="feature-content">
                <h3 className="feature-title">
                  {feature.title}
                </h3>
                <p className="feature-description">
                  {feature.description}
                </p>
              </div>

              {/* Hover Arrow */}
              <div className="feature-arrow">
                <span>Tìm hiểu thêm</span>
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </div>

              {/* Bottom gradient line */}
              <div className="feature-bottom-line" />
            </div>
          ))}
        </div>

        {/* Bottom highlight */}
        <div className="mt-16 text-center">
          <div className="feature-highlight">
            <div className="flex items-center gap-2 text-orange-600">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              <span className="font-bold">Công nghệ tiên tiến</span>
            </div>
            <span className="text-gray-400">|</span>
            <div className="flex items-center gap-2 text-gray-600">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
              <span className="font-medium">App thông minh</span>
            </div>
            <span className="text-gray-400">|</span>
            <div className="flex items-center gap-2 text-gray-600">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
              <span className="font-medium">Bảo mật cao</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
