import GooglePlayButton from './GooglePlayButton';
import { GOOGLE_PLAY_URL } from '../lib/constants';

interface LockerUnit {
  id: number;
  status: 'available' | 'occupied' | 'reserved';
}

const lockers: LockerUnit[] = [
  { id: 1, status: 'available' },
  { id: 2, status: 'occupied' },
  { id: 3, status: 'available' },
  { id: 4, status: 'reserved' },
  { id: 5, status: 'available' },
  { id: 6, status: 'occupied' },
  { id: 7, status: 'available' },
  { id: 8, status: 'available' },
  { id: 9, status: 'occupied' },
  { id: 10, status: 'available' },
  { id: 11, status: 'available' },
  { id: 12, status: 'occupied' },
];

const statusColors = {
  available: { bg: 'bg-green-100', text: 'text-green-600', dot: 'bg-green-500' },
  occupied: { bg: 'bg-red-100', text: 'text-red-600', dot: 'bg-red-500' },
  reserved: { bg: 'bg-yellow-100', text: 'text-yellow-600', dot: 'bg-yellow-500' },
};

const statusLabels = {
  available: 'Sẵn sàng',
  occupied: 'Đang dùng',
  reserved: 'Đã đặt',
};

export default function HeroSection() {
  const availableCount = lockers.filter(l => l.status === 'available').length;

  return (
    <section className="relative min-h-screen flex items-center pt-28 sm:pt-32 md:pt-24 pb-16 overflow-hidden" style={{ backgroundColor: '#FFFBF7' }}>
      {/* Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 h-[700px] w-[700px] rounded-full bg-gradient-to-br from-orange-300/50 to-orange-500/30 blur-3xl" style={{ animation: 'float 6s ease-in-out infinite' }} />
        <div className="absolute -bottom-40 -left-40 h-[600px] w-[600px] rounded-full bg-gradient-to-br from-orange-200/40 to-orange-400/30 blur-3xl" style={{ animation: 'float-delayed 5s ease-in-out infinite', animationDelay: '1s' }} />

        <div
          className="absolute inset-0"
          style={{
            backgroundImage: 'linear-gradient(rgba(249, 115, 22, 0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(249, 115, 22, 0.05) 1px, transparent 1px)',
            backgroundSize: '60px 60px'
          }}
        />
      </div>

      <div className="relative mx-auto max-w-7xl px-6 w-full">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16 xl:gap-20">
          {/* Left: Content */}
          <div className="text-center lg:text-left order-2 lg:order-1">
            <span className="inline-flex items-center gap-2 rounded-full border-2 border-orange-200 bg-gradient-to-r from-orange-50 to-orange-100 px-5 py-2 text-sm font-bold uppercase tracking-widest text-orange-600 shadow-lg shadow-orange-200/50">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-500"></span>
              </span>
              Smart Locker System
            </span>

            <h1 className="mt-8 text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black leading-tight tracking-tight">
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

            <div className="mt-10 sm:mt-12 flex flex-wrap items-center justify-center gap-4 sm:gap-6 lg:justify-start">
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
                  <div className="text-[10px] sm:text-xs text-gray-500">Phản hồi &lt;1s</div>
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

          {/* Right: Locker Cabinet (matches LockerSimulator design) */}
          <div className="relative order-1 lg:order-2">
            <div className="absolute inset-0 bg-gradient-to-br from-orange-400/20 to-orange-600/20 blur-3xl transform scale-110" />

            <div className="relative bg-gradient-to-b from-gray-100 to-gray-200 rounded-2xl sm:rounded-3xl p-5 sm:p-6 md:p-8 shadow-2xl border border-gray-300 max-w-2xl mx-auto lg:mx-0 lg:ml-auto">

              {/* Top Display Panel */}
              <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-xl sm:rounded-2xl p-3 sm:p-4 md:p-5 mb-4 sm:mb-6 shadow-lg">
                <div className="flex items-center gap-3 sm:gap-4 md:gap-6">
                  {/* QR Code */}
                  <div className="bg-white rounded-lg sm:rounded-xl p-1.5 sm:p-2 shadow-md">
                    <div className="w-16 h-16 sm:w-24 sm:h-24 md:w-28 md:h-28 bg-black rounded-lg relative overflow-hidden">
                      <div className="absolute inset-1 grid grid-cols-5 gap-px">
                        {[...Array(25)].map((_, i) => (
                          <div
                            key={i}
                            className={`rounded-sm ${[0,1,2,3,4,5,9,10,14,15,16,20,21,22,23,24].includes(i) ? 'bg-white' : 'bg-black'}`}
                          />
                        ))}
                      </div>
                      <div className="absolute top-1 left-1 w-5 h-5 sm:w-7 sm:h-7 md:w-8 md:h-8 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      <div className="absolute top-1 right-1 w-5 h-5 sm:w-7 sm:h-7 md:w-8 md:h-8 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      <div className="absolute bottom-1 left-1 w-5 h-5 sm:w-7 sm:h-7 md:w-8 md:h-8 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      <div className="absolute left-1 right-1 h-0.5 bg-orange-500" style={{ animation: 'scan-line 2s linear infinite', top: '50%' }} />
                    </div>
                  </div>

                  {/* Logo */}
                  <div className="flex-1 flex items-center justify-center">
                    <img src="/LOGO-EBOX.png" alt="E-BOX" className="h-10 sm:h-14 md:h-20 w-auto" />
                  </div>

                  {/* Status */}
                  <div className="text-right">
                    <div className="text-2xl sm:text-3xl md:text-4xl font-black text-orange-500">{availableCount}</div>
                    <div className="text-gray-400 text-[10px] sm:text-xs">Tủ trống</div>
                  </div>
                </div>
              </div>

              {/* Locker Grid */}
              <div className="grid grid-cols-4 gap-2 sm:gap-3">
                {lockers.map((locker) => {
                  const colors = statusColors[locker.status];
                  return (
                    <div key={locker.id} className="relative">
                      <div className="relative bg-white rounded-lg sm:rounded-xl border-2 border-gray-200 shadow-md overflow-hidden hover:border-orange-400 transition-all">
                        {/* Door Handle */}
                        <div className="absolute right-1 top-1/2 -translate-y-1/2 w-0.5 sm:w-1 h-4 sm:h-6 bg-gradient-to-b from-gray-300 to-gray-400 rounded-full shadow-sm" />

                        {/* Status LED */}
                        <div className="absolute top-1 left-1">
                          <div className={`w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full ${colors.dot} ${locker.status === 'available' ? 'animate-pulse' : ''}`} />
                        </div>

                        {/* Locker Number */}
                        <div className="h-12 sm:h-16 flex items-center justify-center">
                          <span className="text-sm sm:text-lg font-black text-gray-700">
                            {String(locker.id).padStart(2, '0')}
                          </span>
                        </div>

                        {/* Status Label */}
                        <div className={`text-center py-0.5 sm:py-1 text-[8px] sm:text-[9px] font-bold uppercase tracking-wide ${colors.text} ${colors.bg}`}>
                          {statusLabels[locker.status]}
                        </div>

                        {/* 3D Effect */}
                        <div className="absolute inset-y-0 -right-0.5 sm:-right-1 w-0.5 sm:w-1 bg-gradient-to-r from-black/10 to-transparent rounded-r-lg" />
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Footer */}
              <div className="mt-4 sm:mt-6 pt-3 sm:pt-4 border-t border-gray-300 flex items-center justify-between">
                <div className="flex items-center gap-2 sm:gap-4 text-[10px] sm:text-xs text-gray-500">
                  <span className="flex items-center gap-1">
                    <span className="h-1.5 w-1.5 sm:h-2 sm:w-2 rounded-full bg-green-500" />
                    <span className="hidden sm:inline">{availableCount} Trống</span>
                    <span className="sm:hidden">{availableCount}</span>
                  </span>
                  <span className="flex items-center gap-1">
                    <span className="h-1.5 w-1.5 sm:h-2 sm:w-2 rounded-full bg-red-500" />
                    <span className="hidden sm:inline">{lockers.filter(l => l.status === 'occupied').length} Đã dùng</span>
                    <span className="sm:hidden">{lockers.filter(l => l.status === 'occupied').length}</span>
                  </span>
                  <span className="hidden sm:flex items-center gap-1">
                    <span className="h-2 w-2 rounded-full bg-yellow-500" /> {lockers.filter(l => l.status === 'reserved').length} Đã đặt
                  </span>
                </div>
                <div className="text-orange-500 text-[10px] sm:text-xs font-mono font-bold">
                  E-BOX v2.0
                </div>
              </div>

              {/* Brand Logo Badge */}
              <div className="absolute -bottom-2 sm:-bottom-3 left-1/2 -translate-x-1/2 bg-white rounded-full px-3 sm:px-4 py-0.5 sm:py-1 shadow-md border border-gray-200">
                <span className="text-[10px] sm:text-xs font-bold text-gray-600">E-BOX</span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Stats Bar */}
        <div className="mt-16 sm:mt-20 grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
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