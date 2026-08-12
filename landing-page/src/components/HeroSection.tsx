import GooglePlayButton from './GooglePlayButton';
import { GOOGLE_PLAY_URL } from '../lib/constants';

export default function HeroSection() {
  // Cột A: 14 ô (A01–A14), Cột B: 18 ô (B01–B18), Cột C: 18 ô (C01–C18)
  const colA = Array.from({ length: 14 }, (_, i) => i + 1);
  const colB = Array.from({ length: 18 }, (_, i) => i + 1);
  const colC = Array.from({ length: 18 }, (_, i) => i + 1);

  // Tủ bận ngẫu nhiên để trông "đang hoạt động"
  const occupiedB = new Set([3, 7, 12, 15]);
  const occupiedC = new Set([2, 5, 9, 14, 17]);
  const reservedA = new Set([5, 9]);

  return (
    <section className="relative min-h-screen flex items-center pt-28 sm:pt-32 md:pt-20 pb-16 overflow-hidden" style={{ backgroundColor: '#FFFBF7' }}>
      {/* Background */}
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
        <div className="grid items-center gap-10 lg:grid-cols-5 lg:gap-12 xl:gap-16">
          {/* Left: Content - nhỏ hơn để nhường chỗ cho tủ */}
          <div className="text-center lg:text-left order-2 lg:order-1 lg:col-span-2">
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

          {/* Right: REAL-WORLD style cabinet (matches photo) */}
          <div className="relative order-1 lg:order-2 lg:col-span-3">
            <div className="absolute inset-0 bg-gradient-to-br from-orange-400/20 to-orange-600/20 blur-3xl transform scale-110 rounded-3xl" />

            <div className="relative mx-auto max-w-4xl">
              {/* Top orange header strip */}
              <div className="relative bg-gradient-to-b from-orange-500 to-orange-600 rounded-t-2xl sm:rounded-t-3xl px-6 sm:px-10 py-3 sm:py-4 shadow-lg flex items-center justify-center">
                <span className="text-white text-sm sm:text-base md:text-lg font-bold tracking-[0.2em] sm:tracking-[0.3em] uppercase">
                  IT Smart Locker
                </span>
                {/* Small LEDs */}
                <div className="absolute left-4 sm:left-6 flex items-center gap-1.5">
                  <div className="h-2 w-2 rounded-full bg-green-400 animate-pulse" />
                  <div className="h-2 w-2 rounded-full bg-yellow-400" />
                </div>
                <div className="absolute right-4 sm:right-6 flex items-center gap-1.5">
                  <div className="h-2 w-2 rounded-full bg-white/70" />
                  <div className="h-2 w-2 rounded-full bg-white/40" />
                </div>
              </div>

              {/* Cabinet body */}
              <div className="relative bg-gradient-to-b from-orange-500 via-orange-500 to-orange-600 p-2 sm:p-3 shadow-2xl rounded-b-2xl sm:rounded-b-3xl">

                {/* Columns grid: B - LCD panel (with A column on its sides) - C */}
                <div className="grid grid-cols-12 gap-2 sm:gap-3">

                  {/* Column B - 18 small lockers */}
                  <div className="col-span-3 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg p-1.5 sm:p-2 space-y-1 shadow-inner">
                    {colB.map((n) => {
                      const occupied = occupiedB.has(n);
                      return (
                        <div
                          key={n}
                          className={`relative h-7 sm:h-9 md:h-11 rounded-sm flex items-center justify-center text-[10px] sm:text-xs md:text-sm font-semibold transition-all
                            ${occupied
                              ? 'bg-gradient-to-b from-gray-300 to-gray-400 text-gray-600 shadow-inner'
                              : 'bg-gradient-to-b from-white to-gray-50 text-gray-700 shadow-sm hover:from-orange-50 hover:to-orange-100'
                            }`}
                        >
                          <span className="opacity-70">B{n.toString().padStart(2, '0')}</span>
                          {occupied && (
                            <div className="absolute right-1 top-1 h-1.5 w-1.5 rounded-full bg-red-500" />
                          )}
                        </div>
                      );
                    })}
                  </div>

                  {/* Column A (left part) + LCD + Column A (right part) */}
                  <div className="col-span-6 space-y-2 sm:space-y-3">
                    {/* Top half: A01 - A09 (left) + LCD screen + A01 - A14 (right with offset positions) */}
                    <div className="grid grid-cols-7 gap-2 sm:gap-3 h-full">
                      {/* Left side of LCD: empty white column to align */}
                      <div className="col-span-3 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg p-1.5 sm:p-2 shadow-inner">
                        {/* Top A's on left side */}
                        <div className="grid grid-cols-2 gap-1">
                          {colA.slice(0, 8).map((n) => {
                            const reserved = reservedA.has(n);
                            return (
                              <div
                                key={n}
                                className={`relative h-8 sm:h-11 md:h-14 rounded-sm flex items-center justify-center text-[10px] sm:text-xs font-semibold transition-all
                                  ${reserved
                                    ? 'bg-gradient-to-b from-yellow-100 to-yellow-200 text-yellow-800 shadow-inner'
                                    : 'bg-gradient-to-b from-white to-gray-50 text-gray-700 shadow-sm hover:from-orange-50 hover:to-orange-100'
                                  }`}
                              >
                                <span className="opacity-70">A{n.toString().padStart(2, '0')}</span>
                              </div>
                            );
                          })}
                        </div>
                      </div>

                      {/* Center column: LCD screen + a few bottom A's */}
                      <div className="col-span-1 flex flex-col gap-1.5 sm:gap-2">
                        {/* LCD Screen */}
                        <div className="flex-1 bg-gradient-to-br from-gray-900 to-black rounded-lg p-1.5 sm:p-2 shadow-2xl border-2 border-orange-400 relative overflow-hidden">
                          <div className="absolute inset-1 bg-gradient-to-br from-orange-400 to-orange-600 rounded opacity-10" />
                          <div className="relative h-full flex flex-col items-center justify-center text-center">
                            <div className="text-white text-[8px] sm:text-[10px] font-bold tracking-wider">IT SMART</div>
                            <div className="text-orange-400 text-[7px] sm:text-[9px] font-bold">LOCKER</div>
                            <div className="mt-1 flex flex-col gap-1 items-center">
                              <div className="h-1 w-8 sm:w-12 bg-orange-400 rounded animate-pulse" />
                              <div className="h-1 w-6 sm:w-10 bg-white/60 rounded" />
                              <div className="h-1 w-7 sm:w-11 bg-white/40 rounded" />
                            </div>
                            {/* Scan line */}
                            <div className="absolute left-1 right-1 h-px bg-orange-400 opacity-80" style={{ animation: 'scan-line 3s linear infinite', top: '50%' }} />
                          </div>
                        </div>
                        {/* Small bottom A's under LCD */}
                        {colA.slice(12, 14).map((n) => (
                          <div key={n} className="h-8 sm:h-11 md:h-14 bg-gradient-to-b from-white to-gray-50 rounded-sm flex items-center justify-center text-[10px] sm:text-xs font-semibold text-gray-700 shadow-sm">
                            <span className="opacity-70">A{n.toString().padStart(2, '0')}</span>
                          </div>
                        ))}
                      </div>

                      {/* Right side of LCD */}
                      <div className="col-span-3 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg p-1.5 sm:p-2 shadow-inner">
                        <div className="grid grid-cols-2 gap-1">
                          {colA.slice(0, 8).map((n) => (
                            <div
                              key={`r-${n}`}
                              className="relative h-8 sm:h-11 md:h-14 rounded-sm flex items-center justify-center text-[10px] sm:text-xs font-semibold bg-gradient-to-b from-white to-gray-50 text-gray-700 shadow-sm hover:from-orange-50 hover:to-orange-100 transition-all"
                            >
                              <span className="opacity-70">A{n.toString().padStart(2, '0')}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Bottom row: A15, A16, A17, A18 + special gray section */}
                    <div className="grid grid-cols-7 gap-2 sm:gap-3">
                      {/* Left bottom: A extra + gray */}
                      <div className="col-span-3 bg-gradient-to-b from-gray-200 to-gray-300 rounded-lg p-1.5 sm:p-2 shadow-inner space-y-1">
                        {[15, 16, 17, 18].map((n) => (
                          <div key={n} className="relative h-7 sm:h-9 md:h-11 bg-gradient-to-b from-gray-100 to-gray-200 rounded-sm flex items-center justify-center text-[10px] sm:text-xs font-semibold text-gray-700 shadow-inner">
                            <span className="opacity-70">A{n.toString().padStart(2, '0')}</span>
                            <div className="absolute inset-0 opacity-30" style={{
                              backgroundImage: 'radial-gradient(circle, rgba(0,0,0,0.15) 1px, transparent 1px)',
                              backgroundSize: '4px 4px'
                            }} />
                          </div>
                        ))}
                      </div>

                      {/* Center: empty / logo */}
                      <div className="col-span-1 flex flex-col items-center justify-end">
                        <div className="text-orange-300 text-[6px] sm:text-[8px] font-black tracking-widest">E-BOX</div>
                      </div>

                      {/* Right bottom: mirror */}
                      <div className="col-span-3 bg-gradient-to-b from-gray-200 to-gray-300 rounded-lg p-1.5 sm:p-2 shadow-inner space-y-1">
                        {[15, 16, 17, 18].map((n) => (
                          <div key={`r-${n}`} className="relative h-7 sm:h-9 md:h-11 bg-gradient-to-b from-gray-100 to-gray-200 rounded-sm flex items-center justify-center text-[10px] sm:text-xs font-semibold text-gray-700 shadow-inner">
                            <span className="opacity-70">A{n.toString().padStart(2, '0')}</span>
                            <div className="absolute inset-0 opacity-30" style={{
                              backgroundImage: 'radial-gradient(circle, rgba(0,0,0,0.15) 1px, transparent 1px)',
                              backgroundSize: '4px 4px'
                            }} />
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Column C - 18 small lockers */}
                  <div className="col-span-3 bg-gradient-to-b from-gray-100 to-gray-200 rounded-lg p-1.5 sm:p-2 space-y-1 shadow-inner">
                    {colC.map((n) => {
                      const occupied = occupiedC.has(n);
                      return (
                        <div
                          key={n}
                          className={`relative h-7 sm:h-9 md:h-11 rounded-sm flex items-center justify-center text-[10px] sm:text-xs md:text-sm font-semibold transition-all
                            ${occupied
                              ? 'bg-gradient-to-b from-gray-300 to-gray-400 text-gray-600 shadow-inner'
                              : 'bg-gradient-to-b from-white to-gray-50 text-gray-700 shadow-sm hover:from-orange-50 hover:to-orange-100'
                            }`}
                        >
                          <span className="opacity-70">C{n.toString().padStart(2, '0')}</span>
                          {occupied && (
                            <div className="absolute right-1 top-1 h-1.5 w-1.5 rounded-full bg-red-500" />
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>

              {/* Base/floor shadow */}
              <div className="h-3 sm:h-4 bg-gradient-to-b from-black/20 to-transparent blur-sm mx-2 sm:mx-6" />
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

      <style>{`
        @keyframes scan-line {
          0% { top: 10%; }
          50% { top: 90%; }
          100% { top: 10%; }
        }
      `}</style>
    </section>
  );
}
