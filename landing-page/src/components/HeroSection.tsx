import GooglePlayButton from './GooglePlayButton';
import { GOOGLE_PLAY_URL } from '../lib/constants';

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex items-center pt-20 pb-16 overflow-hidden" style={{ backgroundColor: '#FFFBF7' }}>
      {/* Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        {/* Gradient mesh */}
        <div className="absolute -top-40 -right-40 h-[700px] w-[700px] rounded-full bg-gradient-to-br from-orange-300/50 to-orange-500/30 blur-3xl" style={{ animation: 'float 6s ease-in-out infinite' }} />
        <div className="absolute -bottom-40 -left-40 h-[600px] w-[600px] rounded-full bg-gradient-to-br from-orange-200/40 to-orange-400/30 blur-3xl" style={{ animation: 'float-delayed 5s ease-in-out infinite', animationDelay: '1s' }} />
        
        {/* Grid pattern */}
        <div 
          className="absolute inset-0"
          style={{
            backgroundImage: 'linear-gradient(rgba(249, 115, 22, 0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(249, 115, 22, 0.05) 1px, transparent 1px)',
            backgroundSize: '60px 60px'
          }}
        />
      </div>

      <div className="relative mx-auto max-w-7xl px-6 w-full">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-20">
          {/* Left: Content */}
          <div className="text-center lg:text-left order-2 lg:order-1">
            {/* Badge */}
            <span className="inline-flex items-center gap-2 rounded-full border-2 border-orange-200 bg-gradient-to-r from-orange-50 to-orange-100 px-5 py-2 text-sm font-bold uppercase tracking-widest text-orange-600 shadow-lg shadow-orange-200/50">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-500"></span>
              </span>
              Smart Locker System
            </span>

            {/* Main Heading */}
            <h1 className="mt-8 text-5xl sm:text-6xl lg:text-7xl font-black leading-tight tracking-tight">
              <span className="block text-gray-900">CHỦ ĐỘNG</span>
              <span className="block" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>MỌI LÚC</span>
              <span className="block text-gray-900">TIỆN LỢI</span>
              <span className="block text-gray-900">MỌI</span>
              <span className="block" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>NƠI</span>
            </h1>

            {/* Subheading */}
            <p className="mx-auto mt-8 max-w-xl text-lg sm:text-xl leading-relaxed text-gray-600 lg:mx-0">
              <span className="font-semibold text-gray-800">E-BOX</span> mang đến giải pháp gửi nhận hàng, 
              lưu trữ đồ cá nhân và đặt đồ ăn 
              <span className="font-semibold text-orange-500"> tiện lợi dành cho sinh viên </span>
              với công nghệ tủ thông minh tiên tiến nhất.
            </p>

            {/* CTA Buttons */}
            <div className="mt-10 flex flex-col items-center gap-5 sm:flex-row lg:justify-start">
              <GooglePlayButton />
              <a
                href="#simulator"
                className="glass-btn-secondary"
              >
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span className="font-semibold">Trải nghiệm demo</span>
              </a>
            </div>

            {/* Trust Indicators */}
            <div className="mt-12 flex flex-wrap items-center justify-center gap-6 lg:justify-start">
              <div className="glass-trust-badge">
                <div className="trust-icon trust-icon-green">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800">Bảo mật</div>
                  <div className="text-xs text-gray-500">256-bit AES</div>
                </div>
              </div>
              <div className="glass-trust-badge">
                <div className="trust-icon trust-icon-blue">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800">Tốc độ</div>
                  <div className="text-xs text-gray-500">Phản hồi &lt;1s</div>
                </div>
              </div>
              <div className="glass-trust-badge">
                <div className="trust-icon trust-icon-purple">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800">Hỗ trợ</div>
                  <div className="text-xs text-gray-500">24/7</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right: Visual */}
          <div className="relative order-1 lg:order-2">
            {/* Main locker visual */}
            <div className="relative mx-auto w-full max-w-lg">
              {/* Glow behind */}
              <div className="absolute inset-0 bg-gradient-to-br from-orange-400 to-orange-600 blur-3xl opacity-40 scale-110" />
              
              {/* Locker Illustration */}
              <div className="relative bg-gradient-to-br from-gray-800 to-gray-900 rounded-3xl p-8 shadow-2xl border border-gray-700">
                {/* Header */}
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center gap-2">
                    <div className="h-3 w-3 rounded-full bg-green-500 animate-pulse" />
                    <span className="text-xs font-bold text-green-400 uppercase tracking-wider">Online</span>
                  </div>
                  <div className="text-xs text-gray-400 font-mono">v2.0.1</div>
                </div>

                {/* Locker Display */}
                <div className="bg-gray-900 rounded-2xl p-6 mb-6">
                  <div className="grid grid-cols-3 gap-3">
                    {[1, 2, 3, 4, 5, 6].map((i) => (
                      <div
                        key={i}
                        className={`relative h-20 rounded-lg border-2 transition-all duration-300 ${
                          i === 3 
                            ? 'border-orange-500 bg-orange-500/20' 
                            : i === 5 
                            ? 'border-green-500 bg-green-500/20' 
                            : 'border-gray-600 bg-gray-800'
                        }`}
                      >
                        <div className="absolute top-1 right-1">
                          <div className={`h-2 w-2 rounded-full ${
                            i === 3 
                              ? 'bg-orange-400 animate-pulse' 
                              : i === 5 
                              ? 'bg-green-400' 
                              : 'bg-gray-500'
                          }`} />
                        </div>
                        <div className="absolute inset-0 flex items-center justify-center">
                          <span className="text-lg font-black text-gray-400">
                            {String(i).padStart(2, '0')}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Status Bar */}
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-400">Đang hoạt động</span>
                  <div className="flex items-center gap-2">
                    <div className="h-2 w-2 rounded-full bg-green-500 animate-pulse" />
                    <span className="font-bold text-green-400">Tất cả tủ online</span>
                  </div>
                </div>
              </div>

              {/* Floating notification */}
              <div 
                className="liquid-glass-v2 absolute -left-8 top-1/4 rounded-2xl p-4 shadow-xl"
                style={{ animation: 'float 6s ease-in-out infinite' }}
              >
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-green-100">
                    <svg className="h-5 w-5 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <div>
                    <div className="font-bold text-gray-800 text-sm">Giao hàng thành công!</div>
                    <div className="text-xs text-gray-500">Tủ #07 đã mở</div>
                  </div>
                </div>
              </div>

              {/* Stats floating card */}
              <div 
                className="liquid-glass-v2 absolute -right-4 bottom-1/4 rounded-2xl p-4 shadow-xl"
                style={{ 
                  animation: 'float-delayed 5s ease-in-out infinite',
                  animationDelay: '1s'
                }}
              >
                <div className="text-center">
                  <div className="text-2xl font-black" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>98%</div>
                  <div className="text-xs text-gray-500">Uptime</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Stats Bar */}
        <div className="mt-20 grid grid-cols-2 md:grid-cols-4 gap-6">
          {[
            { value: '10K+', label: 'Sinh viên' },
            { value: '500+', label: 'Tủ locker' },
            { value: '50K+', label: 'Giao dịch' },
            { value: '24/7', label: 'Hỗ trợ' },
          ].map((stat) => (
            <div key={stat.label} className="text-center">
              <div className="text-3xl font-black" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>{stat.value}</div>
              <div className="text-sm text-gray-500 font-medium">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
