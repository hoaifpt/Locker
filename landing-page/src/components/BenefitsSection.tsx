import { useEffect, useRef } from 'react';

const benefits = [
  {
    title: 'Tiết kiệm thời gian',
    description: 'Không còn phải xếp hàng hay chờ đợi. Lấy và gửi đồ chỉ trong 30 giây với E-BOX.',
    improvement: '85%',
    improvementLabel: 'Giảm thời gian chờ',
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  },
  {
    title: 'An toàn tuyệt đối',
    description: 'Hệ thống bảo mật đa lớp với mã hóa 256-bit và camera giám sát 24/7.',
    improvement: '100%',
    improvementLabel: 'Bảo vệ đồ của bạn',
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
      </svg>
    ),
  },
  {
    title: 'Thuận tiện mọi lúc',
    description: 'Hoạt động 24/7, nhận hàng bất kỳ lúc nào mà không cần chờ giờ hành chính.',
    improvement: '24/7',
    improvementLabel: 'Luôn sẵn sàng',
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
  },
  {
    title: 'Theo dõi dễ dàng',
    description: 'Thông báo real-time qua app, cập nhật trạng thái đơn hàng tức thì.',
    improvement: 'Real-time',
    improvementLabel: 'Cập nhật tức thì',
    icon: (
      <svg className="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M15 17.5h.01m-4.99.5h-.01M4.17 15h-.01M7 7h.01M4.17 7h-.01m14.66 0h-.01M7 17.5H5.17m12.83 0h-.01M7 7l-4.5 7.5L7 17.5M7 7l-4.5 7.5M7 7l-4.5 7.5" />
      </svg>
    ),
  },
];

const comparisonData = {
  traditional: [
    'Chờ đợi 15-30 phút để nhận hàng',
    'Giới hạn giờ làm việc',
    'Rủi ro mất cắp đồ đạc',
    'Không theo dõi được trạng thái',
    'Phải liên hệ nhiều lần để xác nhận',
  ],
  ebox: [
    'Nhận hàng trong 30 giây',
    'Hoạt động 24/7 không giới hạn',
    'Bảo mật đa lớp, camera 24/7',
    'Thông báo real-time qua app',
    'Tự động cập nhật và xác nhận',
  ],
};

export default function BenefitsSection() {
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
    <section ref={sectionRef} id="benefits" className="relative py-16 sm:py-24 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-orange-50/50 to-white" />
      <div className="absolute inset-0 grid-bg opacity-20" />

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6">
        {/* Section Header */}
        <div className="text-center mb-12 sm:mb-16 scroll-animate">
          <span className="inline-flex items-center gap-2 rounded-full border-2 border-orange-200 bg-white px-4 sm:px-5 py-2 text-xs sm:text-sm font-bold uppercase tracking-widest text-orange-600 shadow-lg">
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Lợi Ích
          </span>
          <h2 className="mt-6 sm:mt-8 text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black tracking-tight">
            <span className="text-gray-900">Tại Sao Chọn</span>
            <br />
            <span className="gradient-text">E-BOX?</span>
          </h2>
          <p className="mx-auto mt-4 sm:mt-6 max-w-2xl text-sm sm:text-lg text-gray-600 px-4 sm:px-0">
            E-BOX mang đến những lợi ích vượt trội so với phương thức truyền thống
          </p>
        </div>

        {/* Benefits Grid */}
        <div className="grid gap-6 lg:grid-cols-2">
          {/* Left: Benefits Cards */}
          <div className="space-y-4 sm:space-y-6">
            {benefits.map((benefit, index) => (
              <div
                key={benefit.title}
                className="liquid-glass-v2 p-4 sm:p-6"
                style={{ animationDelay: `${index * 100}ms` }}
              >
                <div className="flex items-start gap-4 sm:gap-5">
                  {/* Icon */}
                  <div className="relative flex-shrink-0">
                    <div className="absolute inset-0 bg-orange-400 rounded-2xl blur-lg opacity-40" />
                    <div className="relative flex h-12 w-12 sm:h-14 sm:w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-orange-500 to-orange-600 text-white shadow-lg shadow-orange-500/40">
                      {benefit.icon}
                    </div>
                  </div>

                  {/* Content */}
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <h3 className="text-base sm:text-lg font-bold text-gray-900">
                        {benefit.title}
                      </h3>
                      <span className="text-xs sm:text-sm font-black text-orange-500 bg-orange-100 px-2 sm:px-3 py-1 rounded-full">
                        {benefit.improvement}
                      </span>
                    </div>
                    <p className="text-xs sm:text-base text-gray-600 leading-relaxed mb-2">
                      {benefit.description}
                    </p>
                    <span className="text-[10px] sm:text-xs text-gray-400 font-medium">
                      {benefit.improvementLabel}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Right: Comparison */}
          <div className="liquid-glass-v2 p-4 sm:p-6 md:p-8" style={{ animationDelay: '200ms' }}>
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-6 sm:mb-8 text-center">
              So Sánh Ngay
            </h3>

              {/* Comparison Table */}
              <div className="space-y-3 sm:space-y-4">
                {/* Header */}
                <div className="grid grid-cols-2 gap-2 sm:gap-4 pb-3 sm:pb-4 border-b border-gray-200">
                  <div className="text-left">
                    <span className="inline-flex items-center gap-1 sm:gap-2 text-xs sm:text-sm font-bold text-gray-400 uppercase tracking-wider">
                      <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                      <span className="hidden sm:inline">Truyền thống</span>
                      <span className="sm:hidden">Cũ</span>
                    </span>
                  </div>
                  <div className="text-right">
                    <span className="inline-flex items-center gap-1 sm:gap-2 text-xs sm:text-sm font-bold text-orange-500 uppercase tracking-wider">
                      E-BOX
                      <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </span>
                  </div>
                </div>

                {/* Comparison Items */}
                {comparisonData.traditional.map((item, index) => (
                  <div key={index} className="grid grid-cols-2 gap-2 sm:gap-4 py-2 sm:py-3 border-b border-gray-100 last:border-0">
                    <div className="flex items-start gap-1 sm:gap-2">
                      <svg className="w-4 h-4 sm:w-5 sm:h-5 text-red-400 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                      <span className="text-xs sm:text-sm text-gray-600">{item}</span>
                    </div>
                    <div className="flex items-start gap-1 sm:gap-2">
                      <svg className="w-4 h-4 sm:w-5 sm:h-5 text-green-500 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      <span className="text-xs sm:text-sm text-gray-800 font-medium">{comparisonData.ebox[index]}</span>
                    </div>
                  </div>
                ))}
              </div>

              {/* CTA */}
              <div className="mt-6 sm:mt-8 pt-4 sm:pt-6 border-t border-gray-100">
                <a
                  href="#simulator"
                  className="glass-btn-primary w-full justify-center text-sm sm:text-base"
                >
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                  <span>Trải Nghiệm Ngay</span>
                </a>
              </div>
          </div>
        </div>
      </div>
    </section>
  );
}
