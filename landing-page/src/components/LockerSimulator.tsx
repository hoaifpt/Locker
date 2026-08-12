import { useState, useCallback } from 'react';
import PhoneMockup from './PhoneMockup';

interface LockerUnit {
  id: number;
  isOpen: boolean;
  isOpening: boolean;
  isClosing: boolean;
  status: 'available' | 'occupied' | 'reserved';
}

const initialLockers: LockerUnit[] = [
  { id: 1, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 2, isOpen: false, isOpening: false, isClosing: false, status: 'occupied' },
  { id: 3, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 4, isOpen: false, isOpening: false, isClosing: false, status: 'reserved' },
  { id: 5, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 6, isOpen: false, isOpening: false, isClosing: false, status: 'occupied' },
  { id: 7, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 8, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 9, isOpen: false, isOpening: false, isClosing: false, status: 'occupied' },
  { id: 10, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 11, isOpen: false, isOpening: false, isClosing: false, status: 'available' },
  { id: 12, isOpen: false, isOpening: false, isClosing: false, status: 'occupied' },
];

const statusLabels = {
  available: 'Sẵn sàng',
  occupied: 'Đang dùng',
  reserved: 'Đã đặt',
};

const statusColors = {
  available: { bg: 'bg-green-100', text: 'text-green-600', border: 'border-green-400', dot: 'bg-green-500' },
  occupied: { bg: 'bg-red-100', text: 'text-red-600', border: 'border-red-400', dot: 'bg-red-500' },
  reserved: { bg: 'bg-yellow-100', text: 'text-yellow-600', border: 'border-yellow-400', dot: 'bg-yellow-500' },
};

export default function LockerSimulator() {
  const [lockers, setLockers] = useState<LockerUnit[]>(initialLockers);
  const [selectedLocker, setSelectedLocker] = useState<LockerUnit | null>(null);
  const [showClosedNotification, setShowClosedNotification] = useState(false);
  const [closedLockerId, setClosedLockerId] = useState<number | null>(null);

  const availableLockers = lockers.filter(l => l.status === 'available' && !l.isOpen).map(l => l.id);

  const handleOpenLocker = useCallback((lockerId: number) => {
    setLockers(prev =>
      prev.map(l =>
        l.id === lockerId ? { ...l, isOpening: true } : l
      )
    );

    setTimeout(() => {
      setLockers(prev =>
        prev.map(l =>
          l.id === lockerId ? { ...l, isOpening: false, isOpen: true, status: 'occupied' as const } : l
        )
      );
    }, 1000);
  }, []);

  const handleCloseLocker = useCallback((lockerId: number) => {
    setLockers(prev =>
      prev.map(l =>
        l.id === lockerId ? { ...l, isClosing: true, isOpen: false } : l
      )
    );

    setTimeout(() => {
      setLockers(prev =>
        prev.map(l =>
          l.id === lockerId ? { ...l, isClosing: false, status: 'available' as const } : l
        )
      );
      setClosedLockerId(lockerId);
      setShowClosedNotification(true);
      setSelectedLocker(null);

      setTimeout(() => setShowClosedNotification(false), 3000);
    }, 1000);
  }, []);

  const handleLockerClick = useCallback((locker: LockerUnit) => {
    if (locker.status !== 'available' || locker.isOpen) return;
    setSelectedLocker(locker);
  }, []);

  const isSelected = (lockerId: number) => selectedLocker?.id === lockerId;

  return (
    <section id="simulator" className="relative py-16 sm:py-24 overflow-hidden" style={{ backgroundColor: '#FFFBF7' }}>
      {/* Closed Notification Toast */}
      {showClosedNotification && (
        <div className="fixed top-20 sm:top-6 left-1/2 -translate-x-1/2 z-50 animate-slide-down">
          <div className="bg-gray-900 text-white px-4 sm:px-6 py-3 sm:py-4 rounded-2xl shadow-2xl flex items-center gap-3 sm:gap-4">
            <div className="w-8 h-8 sm:w-10 sm:h-10 bg-green-500 rounded-full flex items-center justify-center">
              <svg className="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7"/>
              </svg>
            </div>
            <div>
              <p className="font-bold text-sm sm:text-base">Tủ #{closedLockerId} đã đóng!</p>
              <p className="text-xs text-gray-400 hidden sm:block">Sẵn sàng cho người tiếp theo</p>
            </div>
          </div>
        </div>
      )}

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6">
        {/* Section Header */}
        <div className="text-center mb-10 sm:mb-16">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-semibold uppercase tracking-widest text-orange-600">
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            Live Demo
          </span>
          <h2 className="mt-4 sm:mt-6 text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black tracking-tight">
            <span className="gradient-text">Trải Nghiệm</span>
            <br />
            <span className="text-gray-900">Tủ E-BOX Thông Minh</span>
          </h2>
          <p className="mx-auto mt-4 sm:mt-6 max-w-2xl text-sm sm:text-lg text-gray-600 px-4 sm:px-0">
            Chọn tủ trên cabinet, sau đó quét QR hoặc nhập OTP để mở
          </p>
        </div>

        <div className="grid items-center justify-center gap-8 lg:grid-cols-2 lg:gap-12 xl:gap-16">
          {/* Left: Phone Mockup */}
          <div className="flex justify-center lg:justify-end order-2 lg:order-1">
            <PhoneMockup
              onSelectLocker={handleOpenLocker}
              onCloseLocker={handleCloseLocker}
              availableLockers={availableLockers}
              selectedLockerId={selectedLocker?.id || null}
            />
          </div>

          {/* Right: Locker Cabinet - NEW WHITE DESIGN */}
          <div className="relative order-1 lg:order-2">
            {/* Glow effect */}
            <div className="absolute inset-0 bg-gradient-to-br from-orange-400/10 to-orange-600/10 blur-3xl transform scale-110" />

            {/* Main Locker Cabinet */}
            <div className="relative bg-gradient-to-b from-gray-100 to-gray-200 rounded-2xl sm:rounded-3xl p-8 sm:p-10 shadow-2xl border border-gray-300 max-w-4xl w-full mx-auto lg:mx-0">

              {/* Top Display Panel */}
              <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-xl sm:rounded-2xl p-5 sm:p-6 mb-6 sm:mb-8 shadow-lg">
                <div className="flex items-center gap-4 sm:gap-6">
                  {/* QR Code Display */}
                  <div className="bg-white rounded-lg sm:rounded-xl p-2 sm:p-2.5 shadow-md">
                    <div className="w-20 h-20 sm:w-28 sm:h-28 md:w-32 md:h-32 bg-black rounded-lg relative overflow-hidden">
                      {/* QR pattern */}
                      <div className="absolute inset-1 grid grid-cols-5 gap-px">
                        {[...Array(25)].map((_, i) => (
                          <div
                            key={i}
                            className={`rounded-sm ${[0,1,2,3,4,5,9,10,14,15,16,20,21,22,23,24].includes(i) ? 'bg-white' : 'bg-black'}`}
                          />
                        ))}
                      </div>
                      {/* QR corners */}
                      <div className="absolute top-1 left-1 w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      <div className="absolute top-1 right-1 w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      <div className="absolute bottom-1 left-1 w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-white rounded-sm">
                        <div className="absolute inset-0.5 bg-black rounded-sm">
                          <div className="absolute inset-0.5 bg-white rounded-sm" />
                        </div>
                      </div>
                      {/* Scan line animation */}
                      <div className="absolute left-1 right-1 h-0.5 bg-orange-500" style={{ animation: 'scan-line 2s linear infinite', top: '50%' }} />
                    </div>
                  </div>

                  {/* Info Panel */}
                  <div className="flex-1 flex items-center justify-center">
                    <img src="/LOGO-EBOX.png" alt="E-BOX" className="h-16 sm:h-20 md:h-24 lg:h-28 w-auto" />
                  </div>

                  {/* Status Display */}
                  <div className="text-right">
                    <div className="text-3xl sm:text-4xl md:text-5xl font-black text-orange-500">{availableLockers.length}</div>
                    <div className="text-gray-400 text-xs sm:text-sm">Tủ trống</div>
                  </div>
                </div>
              </div>

              {/* Locker Grid - Responsive columns */}
              <div className="grid grid-cols-4 gap-3 sm:gap-4">
                {lockers.map((locker) => {
                  const colors = statusColors[locker.status];
                  return (
                    <div
                      key={locker.id}
                      className={`relative cursor-pointer group ${locker.status !== 'available' || locker.isOpen ? '' : ''}`}
                      onClick={() => handleLockerClick(locker)}
                    >
                      {/* Selection Ring */}
                      {isSelected(locker.id) && !locker.isOpen && (
                        <div className="absolute -inset-1 rounded-lg sm:rounded-xl border-2 sm:border-4 border-orange-500 z-20 pointer-events-none" />
                      )}

                      {/* Locker Door */}
                      <div
                        className={`
                          relative bg-white rounded-lg sm:rounded-xl border-2 shadow-md overflow-hidden
                          transition-all duration-300
                          ${locker.isOpen ? 'border-green-400 shadow-green-200' : 'border-gray-200 hover:border-orange-400'}
                          ${isSelected(locker.id) && !locker.isOpen ? 'border-orange-500 shadow-orange-200 shadow-lg' : ''}
                        `}
                        style={{
                          transform: locker.isOpening
                            ? 'perspective(200px) rotateY(-90deg)'
                            : locker.isClosing
                              ? 'perspective(200px) rotateY(90deg)'
                              : 'perspective(200px) rotateY(0deg)',
                          transformOrigin: 'left center',
                          transition: 'transform 1s ease-in-out',
                        }}
                      >
                        {/* Door Handle */}
                        <div className="absolute right-1 top-1/2 -translate-y-1/2 w-1 sm:w-1.5 h-6 sm:h-8 bg-gradient-to-b from-gray-300 to-gray-400 rounded-full shadow-sm" />

                        {/* Locker Interior (visible when open) */}
                        {locker.isOpen && (
                          <div className="absolute inset-0 bg-gradient-to-b from-gray-100 to-gray-200 flex items-center justify-center">
                            <span className="text-gray-400 text-[10px] sm:text-xs">Trống</span>
                          </div>
                        )}

                        {/* Door Content */}
                        {!locker.isOpen && (
                          <>
                            {/* Status LED */}
                            <div className="absolute top-1 left-1">
                              <div className={`w-2 h-2 sm:w-2.5 sm:h-2.5 rounded-full ${colors.dot} ${locker.status === 'available' ? 'animate-pulse' : ''}`} />
                            </div>

                            {/* Locker Number */}
                            <div className="h-16 sm:h-20 flex items-center justify-center">
                              <span className={`text-base sm:text-xl md:text-2xl font-black ${isSelected(locker.id) ? 'text-orange-500' : 'text-gray-700'}`}>
                                {String(locker.id).padStart(2, '0')}
                              </span>
                            </div>

                            {/* Status Label */}
                            <div className={`text-center py-1 sm:py-1.5 text-[9px] sm:text-[10px] md:text-xs font-bold uppercase tracking-wide ${colors.text} ${colors.bg}`}>
                              {isSelected(locker.id) ? 'Đã chọn' : statusLabels[locker.status]}
                            </div>
                          </>
                        )}

                        {/* 3D Effect */}
                        <div className="absolute inset-y-0 -right-0.5 sm:-right-1 w-0.5 sm:w-1 bg-gradient-to-r from-black/10 to-transparent rounded-r-lg" />
                      </div>

                      {/* Close Button (shown when open) */}
                      {locker.isOpen && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleCloseLocker(locker.id);
                          }}
                          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-30 bg-gradient-to-r from-gray-600 to-gray-700 text-white rounded-lg sm:rounded-xl px-3 sm:px-5 py-1.5 sm:py-2.5 font-bold text-xs sm:text-sm shadow-lg hover:from-gray-700 hover:to-gray-800 active:scale-95 transition-all"
                        >
                          Đóng tủ
                        </button>
                      )}
                    </div>
                  );
                })}
              </div>

              {/* Cabinet Footer */}
              <div className="mt-6 sm:mt-8 pt-4 sm:pt-6 border-t border-gray-300 flex items-center justify-between">
                <div className="flex items-center gap-3 sm:gap-5 text-xs sm:text-sm text-gray-500">
                  <span className="flex items-center gap-1.5">
                    <span className="h-2 w-2 sm:h-2.5 sm:w-2.5 rounded-full bg-green-500" /> <span className="hidden sm:inline">{availableLockers.length} Trống</span><span className="sm:hidden">{availableLockers.length}</span>
                  </span>
                  <span className="flex items-center gap-1.5">
                    <span className="h-2 w-2 sm:h-2.5 sm:w-2.5 rounded-full bg-red-500" /> <span className="hidden sm:inline">{lockers.filter(l => l.status === 'occupied').length} Đã dùng</span><span className="sm:hidden">{lockers.filter(l => l.status === 'occupied').length}</span>
                  </span>
                  <span className="hidden sm:flex items-center gap-1.5">
                    <span className="h-2.5 w-2.5 rounded-full bg-yellow-500" /> {lockers.filter(l => l.status === 'reserved').length} Đã đặt
                  </span>
                </div>
                <div className="text-orange-500 text-xs sm:text-sm font-mono font-bold">
                  E-BOX v2.0
                </div>
              </div>

              {/* Brand Logo */}
              <div className="absolute -bottom-2 sm:-bottom-3 left-1/2 -translate-x-1/2 bg-white rounded-full px-4 sm:px-5 py-1 sm:py-1.5 shadow-md border border-gray-200">
                <span className="text-xs sm:text-sm font-bold text-gray-600">E-BOX</span>
              </div>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="mt-12 sm:mt-16 text-center">
          <div className="inline-flex flex-wrap justify-center gap-3 sm:gap-6 bg-white/80 backdrop-blur-sm rounded-xl sm:rounded-2xl px-4 sm:px-8 py-3 sm:py-4 shadow-lg">
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-orange-500 text-white text-xs sm:text-sm font-bold">1</span>
              <span className="hidden sm:inline">Chọn tủ trống</span>
              <span className="sm:hidden">Chọn tủ</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-orange-500 text-white text-xs sm:text-sm font-bold">2</span>
              <span className="hidden sm:inline">Quét QR hoặc nhập OTP</span>
              <span className="sm:hidden">Quét QR/OTP</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-green-500 text-white text-xs sm:text-sm font-bold">3</span>
              <span className="hidden sm:inline">Tủ tự động mở</span>
              <span className="sm:hidden">Tủ mở</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-blue-500 text-white text-xs sm:text-sm font-bold">4</span>
              <span className="hidden sm:inline">Đóng tủ khi lấy xong</span>
              <span className="sm:hidden">Đóng tủ</span>
            </div>
          </div>
        </div>
      </div>

      {/* CSS Animation */}
      <style>{`
        @keyframes slide-down {
          from {
            opacity: 0;
            transform: translate(-50%, -20px);
          }
          to {
            opacity: 1;
            transform: translate(-50%, 0);
          }
        }
        .animate-slide-down {
          animation: slide-down 0.3s ease-out forwards;
        }
      `}</style>
    </section>
  );
}
