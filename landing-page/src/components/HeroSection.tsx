import GooglePlayButton from './GooglePlayButton';
import { GOOGLE_PLAY_URL } from '../lib/constants';

interface LockerUnit {
  id: number;
  status: 'available' | 'occupied' | 'reserved';
}

const colA: LockerUnit[] = Array.from({ length: 8 }, (_, i) => ({
  id: i + 1,
  status: ([2, 6].includes(i + 1) ? 'occupied' : [4].includes(i + 1) ? 'reserved' : 'available') as LockerUnit['status'],
}));

const colB: LockerUnit[] = Array.from({ length: 18 }, (_, i) => ({
  id: i + 1,
  status: ([3, 7, 11, 15].includes(i + 1) ? 'occupied' : [5].includes(i + 1) ? 'reserved' : 'available') as LockerUnit['status'],
}));

const colC: LockerUnit[] = Array.from({ length: 18 }, (_, i) => ({
  id: i + 1,
  status: ([2, 9, 14, 17].includes(i + 1) ? 'occupied' : [6].includes(i + 1) ? 'reserved' : 'available') as LockerUnit['status'],
}));

const statusColors = {
  available: { bg: 'bg-green-50', text: 'text-green-600', dot: 'bg-green-500' },
  occupied: { bg: 'bg-red-50', text: 'text-red-600', dot: 'bg-red-500' },
  reserved: { bg: 'bg-yellow-50', text: 'text-yellow-600', dot: 'bg-yellow-500' },
};
const statusLabels = {
  available: 'Sẵn',
  occupied: 'Đang dùng',
  reserved: 'Đã đặt',
};

// Compact locker door - same style as LockerSimulator but smaller
function MiniLocker({ label, status }: { label: string; status: LockerUnit['status'] }) {
  const colors = statusColors[status];
  return (
    <div className="group relative">
      <div className={`relative bg-white rounded-md sm:rounded-lg border-2 shadow-sm overflow-hidden transition-all duration-300
        ${status === 'available' ? 'border-gray-200 hover:border-orange-400' : 'border-gray-300'}`}>
        {/* Door Handle (small) */}
        <div className="absolute right-0.5 top-1/2 -translate-y-1/2 w-0.5 h-3 sm:h-4 bg-gradient-to-b from-gray-300 to-gray-400 rounded-full" />
        {/* Status LED */}
        <div className="absolute top-1 left-1">
          <div className={`w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full ${colors.dot} ${status === 'available' ? 'animate-pulse' : ''}`} />
        </div>
        {/* Locker Number */}
        <div className="h-7 sm:h-9 md:h-10 flex items-center justify-center">
          <span className="text-[10px] sm:text-xs md:text-sm font-black text-gray-700">{label}</span>
        </div>
        {/* 3D Effect */}
        <div className="absolute inset-y-0 -right-0.5 w-0.5 bg-gradient-to-r from-black/10 to-transparent rounded-r-md" />
      </div>
      {/* Status mini label */}
      {status !== 'available' && (
        <div className={`hidden lg:block text-center mt-0.5 text-[8px] font-bold uppercase ${colors.text}`}>
          {statusLabels[status]}
        </div>
      )}
    </div>
  );
}

export default function HeroSection() {
  const availableCount =
    colA.filter(l => l.status === 'available').length +
    colB.filter(l => l.status === 'available').length +
    colC.filter(l => l.status === 'available').length;

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
        <div className="grid items-center gap-10 lg:grid-cols-5 lg:gap-12 xl:gap-16">
          {/* Left: Content */}
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

          {/* Right: White cabinet with mini lockers */}
          <div className="relative order-1 lg:order-2 lg:col-span-3">
            <div className="absolute inset-0 bg-gradient-to-br from-orange-300/15 to-orange-500/15 blur-3xl transform scale-110 rounded-3xl" />

            <div className="relative mx-auto max-w-4xl">
              {/* Top Display Panel - dark with QR + Logo + status */}
              <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-2xl sm:rounded-3xl p-4 sm:p-5 md:p-6 shadow-2xl border border-gray-700">
                <div className="flex items-center gap-3 sm:gap-5 md:gap-6">
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

              {/* Cabinet body - white mini lockers */}
              <div className="bg-gradient-to-b from-gray-50 to-gray-100 rounded-2xl sm:rounded-3xl p-4 sm:p-5 md:p-6 shadow-2xl border border-gray-200 mt-3 sm:mt-4">
                <div className="grid grid-cols-12 gap-2 sm:gap-3">
                  {/* Column B */}
                  <div className="col-span-3 space-y-1 sm:space-y-1.5">
                    {colB.map((l) => (
                      <MiniLocker key={l.id} label={`B${l.id.toString().padStart(2, '0')}`} status={l.status} />
                    ))}
                  </div>

                  {/* Center: A column + LCD */}
                  <div className="col-span-6 flex gap-2 sm:gap-3">
                    {/* Left A column */}
                    <div className="flex-1 grid grid-cols-2 gap-1 sm:gap-1.5">
                      {colA.map((l) => (
                        <MiniLocker key={l.id} label={`A${l.id.toString().padStart(2, '0')}`} status={l.status} />
                      ))}
                    </div>

                    {/* LCD display */}
                    <div className="w-12 sm:w-16 md:w-20 bg-gradient-to-br from-gray-900 to-black rounded-lg sm:rounded-xl p-1 sm:p-2 shadow-2xl border-2 border-orange-500 flex flex-col items-center justify-center relative overflow-hidden">
                      <div className="absolute inset-1 bg-gradient-to-br from-orange-500/10 to-orange-600/10 rounded" />
                      <div className="relative text-center">
                        <div className="text-white text-[7px] sm:text-[9px] font-bold tracking-widest">IT</div>
                        <div className="text-orange-400 text-[7px] sm:text-[9px] font-bold tracking-widest">SMART</div>
                        <div className="text-orange-400 text-[7px] sm:text-[9px] font-bold tracking-widest">LOCKER</div>
                        <div className="mt-1 sm:mt-2 flex flex-col gap-0.5 items-center">
                          <div className="h-0.5 w-6 sm:w-10 bg-orange-400 rounded animate-pulse" />
                          <div className="h-0.5 w-5 sm:w-8 bg-white/60 rounded" />
                          <div className="h-0.5 w-4 sm:w-7 bg-white/40 rounded" />
                        </div>
                      </div>
                      <div className="absolute left-1 right-1 h-px bg-orange-400 opacity-80" style={{ animation: 'scan-line 3s linear infinite', top: '50%' }} />
                    </div>

                    {/* Right A column (mirror) */}
                    <div className="flex-1 grid grid-cols-2 gap-1 sm:gap-1.5">
                      {colA.map((l) => (
                        <MiniLocker key={`r-${l.id}`} label={`A${l.id.toString().padStart(2, '0')}`} status={l.status === 'occupied' ? 'available' : l.status === 'reserved' ? 'available' : 'available'} />
                      ))}
                    </div>
                  </div>

                  {/* Column C */}
                  <div className="col-span-3 space-y-1 sm:space-y-1.5">
                    {colC.map((l) => (
                      <MiniLocker key={l.id} label={`C${l.id.toString().padStart(2, '0')}`} status={l.status} />
                    ))}
                  </div>
                </div>

                {/* Footer */}
                <div className="mt-3 sm:mt-4 pt-2 sm:pt-3 border-t border-gray-200 flex items-center justify-between">
                  <div className="flex items-center gap-2 sm:gap-4 text-[10px] sm:text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <span className="h-1.5 w-1.5 sm:h-2 sm:w-2 rounded-full bg-green-500" />
                      <span className="font-semibold">{availableCount}</span>
                    </span>
                    <span className="flex items-center gap-1">
                      <span className="h-1.5 w-1.5 sm:h-2 sm:w-2 rounded-full bg-red-500" />
                      <span className="font-semibold">
                        {colA.filter(l => l.status === 'occupied').length + colB.filter(l => l.status === 'occupied').length + colC.filter(l => l.status === 'occupied').length}
                      </span>
                    </span>
                    <span className="hidden sm:flex items-center gap-1">
                      <span className="h-2 w-2 rounded-full bg-yellow-500" />
                      <span className="font-semibold">
                        {colA.filter(l => l.status === 'reserved').length + colB.filter(l => l.status === 'reserved').length + colC.filter(l => l.status === 'reserved').length}
                      </span>
                    </span>
                  </div>
                  <div className="text-orange-500 text-[10px] sm:text-xs font-mono font-bold">E-BOX v2.0</div>
                </div>
              </div>

              {/* Floor shadow */}
              <div className="h-2 sm:h-3 bg-gradient-to-b from-black/15 to-transparent blur-md mx-4 sm:mx-8 mt-1" />
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
