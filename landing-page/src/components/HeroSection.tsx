import GooglePlayButton from './GooglePlayButton';
import { GOOGLE_PLAY_URL } from '../lib/constants';

export default function HeroSection() {
  // Generate 3 columns - keep it small and recognizable
  const colLeft = Array.from({ length: 18 }, (_, i) => i + 1); // B01-B18
  const colRight = Array.from({ length: 18 }, (_, i) => i + 1); // C01-C18
  const colCenterTop = Array.from({ length: 12 }, (_, i) => i + 1); // A01-A12
  const colCenterBottom = Array.from({ length: 6 }, (_, i) => i + 13); // A13-A18

  return (
    <section className="relative min-h-screen flex items-center pt-28 sm:pt-32 md:pt-20 pb-16 overflow-hidden" style={{ backgroundColor: '#FFFBF7' }}>
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 h-[700px] w-[700px] rounded-full bg-gradient-to-br from-orange-300/40 to-orange-500/20 blur-3xl" style={{ animation: 'float 6s ease-in-out infinite' }} />
        <div className="absolute -bottom-40 -left-40 h-[600px] w-[600px] rounded-full bg-gradient-to-br from-orange-200/30 to-orange-400/20 blur-3xl" style={{ animation: 'float-delayed 5s ease-in-out infinite', animationDelay: '1s' }} />
        <div
          className="absolute inset-0"
          style={{
            backgroundImage: 'linear-gradient(rgba(249, 115, 22, 0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(249, 115, 22, 0.04) 1px, transparent 1px)',
            backgroundSize: '60px 60px'
          }}
        />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 w-full">
        <div className="grid items-center gap-10 lg:grid-cols-2 lg:gap-16">
          {/* Left: Content */}
          <div className="text-center lg:text-left order-2 lg:order-1">
            <span className="inline-flex items-center gap-2 rounded-full border-2 border-orange-200 bg-gradient-to-r from-orange-50 to-orange-100 px-4 sm:px-5 py-1.5 sm:py-2 text-xs sm:text-sm font-bold uppercase tracking-widest text-orange-600 shadow-lg shadow-orange-200/50">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-500"></span>
              </span>
              Smart Locker System
            </span>

            <h1 className="mt-6 sm:mt-8 text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black leading-tight tracking-tight">
              <span className="block text-gray-900">CHỦ ĐỘNG</span>
              <span className="block" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>MỌI LÚC</span>
              <span className="block text-gray-900">TIỆN LỢI</span>
              <span className="block text-gray-900">MỌI</span>
              <span className="block" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>NƠI</span>
            </h1>

            <p className="mx-auto mt-6 sm:mt-8 max-w-xl text-base sm:text-lg md:text-xl leading-relaxed text-gray-600 lg:mx-0">
              <span className="font-semibold text-gray-800">E-BOX</span> mang đến giải pháp gửi nhận hàng,
              lưu trữ đồ cá nhân và đặt đồ ăn
              <span className="font-semibold text-orange-500"> tiện lợi dành cho sinh viên </span>
              với công nghệ tủ thông minh tiên tiến nhất.
            </p>

            <div className="mt-8 sm:mt-10 flex flex-col items-center gap-4 sm:flex-row lg:justify-start">
              <GooglePlayButton />
              <a href="#simulator" className="glass-btn-secondary">
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span className="font-semibold">Trải nghiệm demo</span>
              </a>
            </div>

            <div className="mt-8 sm:mt-12 flex flex-wrap items-center justify-center gap-3 sm:gap-5 lg:justify-start">
              <div className="glass-trust-badge">
                <div className="trust-icon trust-icon-green">
                  <svg className="h-4 w-4 sm:h-5 sm:w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800 text-xs sm:text-sm">Bảo mật</div>
                  <div className="text-[10px] sm:text-xs text-gray-500">256-bit AES</div>
                </div>
              </div>
              <div className="glass-trust-badge">
                <div className="trust-icon trust-icon-blue">
                  <svg className="h-4 w-4 sm:h-5 sm:w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800 text-xs sm:text-sm">Tốc độ</div>
                  <div className="text-[10px] sm:text-xs text-gray-500">&lt; 1s</div>
                </div>
              </div>
              <div className="glass-trust-badge hidden sm:flex">
                <div className="trust-icon trust-icon-purple">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div>
                  <div className="font-bold text-gray-800 text-sm">Hỗ trợ</div>
                  <div className="text-xs text-gray-500">24/7</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right: SMALL illustrative locker cabinet */}
          <div className="relative order-1 lg:order-2 flex justify-center lg:justify-end">
            <div className="absolute inset-0 bg-gradient-to-br from-orange-300/20 to-orange-500/20 blur-3xl transform scale-110 rounded-3xl" />

            {/* Cabinet - small, illustrative, real-product look */}
            <div className="relative" style={{ width: 'min(420px, 95vw)' }}>
              {/* Orange top header */}
              <div className="relative bg-gradient-to-b from-orange-500 to-orange-600 rounded-t-2xl shadow-lg px-4 py-2 flex items-center justify-center">
                <span className="text-white text-[10px] sm:text-xs font-bold tracking-[0.25em] uppercase">
                  IT Smart Locker
                </span>
                <div className="absolute left-3 flex items-center gap-1">
                  <div className="h-1.5 w-1.5 rounded-full bg-green-400 animate-pulse" />
                  <div className="h-1.5 w-1.5 rounded-full bg-yellow-400" />
                </div>
                <div className="absolute right-3 flex items-center gap-1">
                  <div className="h-1.5 w-1.5 rounded-full bg-white/70" />
                  <div className="h-1.5 w-1.5 rounded-full bg-white/40" />
                </div>
              </div>

              {/* Cabinet body */}
              <div className="bg-gradient-to-b from-[#FF7A1A] to-[#FF6B0A] p-2 shadow-2xl rounded-b-2xl">
                <div className="grid grid-cols-12 gap-0.5 sm:gap-1">
                  {/* Left column - B18 small lockers */}
                  <div className="col-span-3 bg-gradient-to-b from-[#F5F2ED] to-[#E8E3D9] p-1 rounded-sm space-y-0.5">
                    {colLeft.map((n) => (
                      <div
                        key={n}
                        className="relative h-3 sm:h-4 bg-gradient-to-b from-white to-[#F8F5F0] rounded-[1px] border border-[#E0DAD0] flex items-center justify-center shadow-sm"
                      >
                        <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">B{n.toString().padStart(2, '0')}</span>
                        <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-px h-1.5 bg-[#D0C8B8] rounded-full" />
                      </div>
                    ))}
                  </div>

                  {/* Center - LCD + A column */}
                  <div className="col-span-6 flex gap-0.5 sm:gap-1">
                    {/* Left A column (top half) */}
                    <div className="flex-1 bg-gradient-to-b from-[#F5F2ED] to-[#E8E3D9] p-1 rounded-sm space-y-0.5">
                      {colCenterTop.slice(0, 6).map((n) => (
                        <div
                          key={n}
                          className="relative h-3 sm:h-4 bg-gradient-to-b from-white to-[#F8F5F0] rounded-[1px] border border-[#E0DAD0] flex items-center justify-center shadow-sm"
                        >
                          <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">A{n.toString().padStart(2, '0')}</span>
                          <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-px h-1.5 bg-[#D0C8B8] rounded-full" />
                        </div>
                      ))}
                    </div>

                    {/* LCD center column */}
                    <div className="w-10 sm:w-12 flex flex-col gap-0.5">
                      {/* LCD screen */}
                      <div className="flex-1 bg-gradient-to-br from-gray-900 to-black rounded-sm p-1 border border-orange-300 flex flex-col items-center justify-center relative overflow-hidden">
                        <div className="text-white text-[5px] sm:text-[6px] font-bold tracking-tight leading-tight">IT</div>
                        <div className="text-orange-400 text-[5px] sm:text-[6px] font-bold tracking-tight leading-tight">SMART</div>
                        <div className="text-orange-400 text-[5px] sm:text-[6px] font-bold tracking-tight leading-tight">LOCKER</div>
                        <div className="mt-0.5 space-y-0.5 w-full px-0.5">
                          <div className="h-px w-full bg-orange-400 opacity-80 animate-pulse" />
                          <div className="h-px w-3/4 bg-white/60" />
                          <div className="h-px w-2/3 bg-white/40" />
                        </div>
                        <div className="absolute left-0.5 right-0.5 h-px bg-orange-400" style={{ animation: 'scan-line 2.5s linear infinite', top: '50%' }} />
                      </div>
                      {/* Small mini lockers below LCD */}
                      {colCenterTop.slice(6, 12).map((n) => (
                        <div
                          key={n}
                          className="relative h-3 sm:h-4 bg-gradient-to-b from-white to-[#F8F5F0] rounded-[1px] border border-[#E0DAD0] flex items-center justify-center shadow-sm"
                        >
                          <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">A{n.toString().padStart(2, '0')}</span>
                          <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-px h-1.5 bg-[#D0C8B8] rounded-full" />
                        </div>
                      ))}
                    </div>

                    {/* Right A column */}
                    <div className="flex-1 bg-gradient-to-b from-[#F5F2ED] to-[#E8E3D9] p-1 rounded-sm space-y-0.5">
                      {colCenterTop.slice(0, 6).map((n) => (
                        <div
                          key={`r-${n}`}
                          className="relative h-3 sm:h-4 bg-gradient-to-b from-white to-[#F8F5F0] rounded-[1px] border border-[#E0DAD0] flex items-center justify-center shadow-sm"
                        >
                          <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">A{n.toString().padStart(2, '0')}</span>
                          <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-px h-1.5 bg-[#D0C8B8] rounded-full" />
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Right column - C18 small lockers */}
                  <div className="col-span-3 bg-gradient-to-b from-[#F5F2ED] to-[#E8E3D9] p-1 rounded-sm space-y-0.5">
                    {colRight.map((n) => (
                      <div
                        key={n}
                        className="relative h-3 sm:h-4 bg-gradient-to-b from-white to-[#F8F5F0] rounded-[1px] border border-[#E0DAD0] flex items-center justify-center shadow-sm"
                      >
                        <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">C{n.toString().padStart(2, '0')}</span>
                        <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-px h-1.5 bg-[#D0C8B8] rounded-full" />
                      </div>
                    ))}
                  </div>
                </div>

                {/* Bottom shelf - A13-A18 */}
                <div className="mt-1 bg-gradient-to-b from-[#E8E3D9] to-[#D8D0C0] p-1 rounded-sm">
                  <div className="grid grid-cols-6 gap-0.5">
                    {colCenterBottom.map((n) => (
                      <div
                        key={n}
                        className="relative h-3 sm:h-4 bg-gradient-to-b from-[#F5F2ED] to-[#E8E3D9] rounded-[1px] border border-[#C8C0B0] flex items-center justify-center shadow-inner"
                      >
                        <span className="text-[6px] sm:text-[7px] font-bold text-[#8B7E6A]">A{n.toString().padStart(2, '0')}</span>
                        <div className="absolute inset-0 opacity-20" style={{
                          backgroundImage: 'radial-gradient(circle, rgba(0,0,0,0.3) 0.5px, transparent 0.5px)',
                          backgroundSize: '2px 2px'
                        }} />
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Cabinet base/legs */}
              <div className="bg-gradient-to-b from-[#E05A00] to-[#C04A00] h-1.5 rounded-b-md mx-6 shadow-lg" />
              <div className="flex justify-between px-4 sm:px-8 -mt-0.5">
                <div className="w-10 sm:w-14 h-2 sm:h-3 bg-gradient-to-b from-gray-700 to-gray-900 rounded-b-md shadow-md" />
                <div className="w-10 sm:w-14 h-2 sm:h-3 bg-gradient-to-b from-gray-700 to-gray-900 rounded-b-md shadow-md" />
              </div>

              {/* Floor shadow */}
              <div className="h-2 sm:h-3 bg-gradient-to-b from-black/20 to-transparent blur-md mx-8 sm:mx-12 mt-1" />
            </div>
          </div>
        </div>

        {/* Bottom Stats */}
        <div className="mt-12 sm:mt-16 grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
          {[
            { value: '10K+', label: 'Sinh viên' },
            { value: '500+', label: 'Tủ locker' },
            { value: '50K+', label: 'Giao dịch' },
            { value: '24/7', label: 'Hỗ trợ' },
          ].map((stat) => (
            <div key={stat.label} className="text-center">
              <div className="text-2xl sm:text-3xl lg:text-4xl font-black" style={{ background: 'linear-gradient(135deg, #F97316, #DC2626)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>{stat.value}</div>
              <div className="text-xs sm:text-sm text-gray-500 font-medium">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
