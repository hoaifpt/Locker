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
  available: { bg: 'bg-emerald-500/20', text: 'text-emerald-400', border: 'border-emerald-400', dot: 'bg-emerald-400' },
  occupied: { bg: 'bg-red-500/20', text: 'text-red-400', border: 'border-red-400', dot: 'bg-red-400' },
  reserved: { bg: 'bg-amber-500/20', text: 'text-amber-400', border: 'border-amber-400', dot: 'bg-amber-400' },
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
            <span className="text-gray-900">Thiết Bị IoT Thông Minh</span>
          </h2>
          <p className="mx-auto mt-4 sm:mt-6 max-w-2xl text-sm sm:text-lg text-gray-600 px-4 sm:px-0">
            Kiosk thông minh kết nối IoT - chọn tủ, quét QR, mở tự động
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

          {/* Right: Smart IoT Kiosk */}
          <div className="relative order-1 lg:order-2 flex justify-center lg:justify-start">
            {/* Ambient Glow */}
            <div className="absolute inset-0 bg-gradient-to-br from-cyan-400/20 via-orange-400/20 to-purple-400/20 blur-3xl transform scale-110" />

            {/* IoT Kiosk Device */}
            <div className="relative" style={{ maxWidth: '380px' }}>

              {/* ===== TOP: Touchscreen Display ===== */}
              <div className="relative bg-gradient-to-b from-slate-800 to-slate-900 rounded-t-3xl p-3 shadow-2xl border-t border-x border-slate-700">
                {/* Screen Bezel */}
                <div className="relative bg-black rounded-2xl p-2 shadow-inner">
                  {/* Camera Notch */}
                  <div className="absolute top-3 left-1/2 -translate-x-1/2 w-16 h-1.5 bg-slate-800 rounded-full z-10 flex items-center justify-center gap-2">
                    <div className="w-1 h-1 rounded-full bg-cyan-400 animate-pulse" />
                    <div className="w-1 h-1 rounded-full bg-slate-600" />
                  </div>

                  {/* Screen Content */}
                  <div className="relative bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 rounded-xl overflow-hidden aspect-[4/3]">

                    {/* Screen UI */}
                    <div className="absolute inset-0 p-3 flex flex-col">
                      {/* Status Bar */}
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-1">
                          <div className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                          <span className="text-[8px] text-emerald-400 font-mono">ONLINE</span>
                        </div>
                        <div className="text-[8px] text-slate-400 font-mono">WiFi · 4G</div>
                        <div className="flex items-center gap-1">
                          <span className="text-[8px] text-slate-400 font-mono">86%</span>
                          <div className="w-3 h-1.5 border border-slate-400 rounded-sm relative">
                            <div className="absolute inset-0.5 bg-emerald-400 rounded-xs" style={{ width: '80%' }} />
                          </div>
                        </div>
                      </div>

                      {/* QR Code + Info Row */}
                      <div className="flex gap-2 mb-2">
                        {/* QR Scanner */}
                        <div className="bg-white rounded-md p-1 shadow-lg relative">
                          <div className="w-12 h-12 relative">
                            <div className="absolute inset-0 grid grid-cols-4 gap-px">
                              {[...Array(16)].map((_, i) => (
                                <div
                                  key={i}
                                  className={`rounded-xs ${
                                    [0, 1, 2, 3, 4, 5, 8, 9, 13, 14, 15].includes(i)
                                      ? 'bg-black'
                                      : 'bg-white'
                                  }`}
                                />
                              ))}
                            </div>
                            <div className="absolute top-0 left-0 w-3 h-3 bg-black">
                              <div className="absolute inset-0.5 bg-white">
                                <div className="absolute inset-0.5 bg-black" />
                              </div>
                            </div>
                            <div className="absolute top-0 right-0 w-3 h-3 bg-black">
                              <div className="absolute inset-0.5 bg-white">
                                <div className="absolute inset-0.5 bg-black" />
                              </div>
                            </div>
                            <div className="absolute bottom-0 left-0 w-3 h-3 bg-black">
                              <div className="absolute inset-0.5 bg-white">
                                <div className="absolute inset-0.5 bg-black" />
                              </div>
                            </div>
                            <div
                              className="absolute left-0 right-0 h-0.5 bg-cyan-400 shadow-lg shadow-cyan-400/50"
                              style={{ animation: 'scan-line 2s linear infinite', top: '50%' }}
                            />
                          </div>
                        </div>

                        {/* Center Info */}
                        <div className="flex-1 flex flex-col items-center justify-center bg-slate-700/30 rounded-md px-1">
                          <div className="text-[10px] font-bold text-white leading-none">E-BOX</div>
                          <div className="text-[7px] text-orange-400 font-mono">SMART IoT</div>
                          <div className="text-[6px] text-slate-400 font-mono mt-0.5">v2.0.1</div>
                        </div>

                        {/* Available Count */}
                        <div className="bg-slate-700/30 rounded-md px-2 flex flex-col items-center justify-center">
                          <div className="text-base font-black text-orange-400 leading-none">
                            {availableLockers.length}
                          </div>
                          <div className="text-[6px] text-slate-400 font-mono">TRỐNG</div>
                        </div>
                      </div>

                      {/* Mini Locker Grid */}
                      <div className="grid grid-cols-6 gap-0.5 flex-1">
                        {lockers.map((locker) => {
                          const colors = statusColors[locker.status];
                          const selected = isSelected(locker.id);
                          return (
                            <div
                              key={locker.id}
                              onClick={() => handleLockerClick(locker)}
                              className={`
                                relative aspect-square rounded-xs cursor-pointer transition-all
                                ${colors.bg} ${colors.border} border
                                ${selected ? 'ring-1 ring-orange-400 scale-110 z-10' : ''}
                                ${locker.status === 'available' && !selected ? 'hover:scale-105' : ''}
                              `}
                            >
                              <div className="absolute inset-0 flex items-center justify-center">
                                <span className={`text-[8px] font-black ${colors.text}`}>
                                  {String(locker.id).padStart(2, '0')}
                                </span>
                              </div>
                              <div className={`absolute top-0.5 right-0.5 w-1 h-1 rounded-full ${colors.dot} ${locker.status === 'available' ? 'animate-pulse' : ''}`} />
                            </div>
                          );
                        })}
                      </div>
                    </div>

                    {/* Touch Ripple Effect */}
                    <div className="absolute inset-0 pointer-events-none">
                      <div className="absolute top-1/2 left-1/2 w-20 h-20 -translate-x-1/2 -translate-y-1/2 rounded-full border border-cyan-400/30 animate-ping" />
                    </div>
                  </div>
                </div>

                {/* IoT Indicator Lights */}
                <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 flex gap-1">
                  <div className="w-1 h-1 rounded-full bg-emerald-400 animate-pulse" />
                  <div className="w-1 h-1 rounded-full bg-cyan-400" />
                  <div className="w-1 h-1 rounded-full bg-orange-400 animate-pulse" />
                </div>
              </div>

              {/* ===== MIDDLE: Sensor Strip ===== */}
              <div className="relative bg-gradient-to-b from-slate-700 to-slate-800 px-4 py-2 border-x border-slate-600 flex items-center justify-between">
                {/* Left sensors */}
                <div className="flex items-center gap-2">
                  <div className="flex flex-col items-center">
                    <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
                    <span className="text-[6px] text-slate-400 font-mono mt-0.5">IR</span>
                  </div>
                  <div className="w-4 h-4 rounded-full border border-slate-500 flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                  </div>
                </div>

                {/* Brand Logo */}
                <div className="flex items-center gap-1">
                  <div className="w-4 h-4 rounded bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                    <span className="text-[6px] font-black text-white">E</span>
                  </div>
                  <span className="text-[8px] font-bold text-white tracking-wider">E-BOX</span>
                </div>

                {/* Right sensors */}
                <div className="flex items-center gap-2">
                  <div className="w-4 h-4 rounded-full border border-slate-500 flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-cyan-400 animate-pulse" />
                  </div>
                  <div className="flex flex-col items-center">
                    <div className="w-2 h-2 rounded-full bg-emerald-500" />
                    <span className="text-[6px] text-slate-400 font-mono mt-0.5">RFID</span>
                  </div>
                </div>
              </div>

              {/* ===== BOTTOM: Locker Compartments ===== */}
              <div className="relative bg-gradient-to-b from-slate-800 to-slate-900 rounded-b-3xl p-3 shadow-2xl border-b border-x border-slate-700">

                {/* Ventilation Grille */}
                <div className="absolute top-2 left-1/2 -translate-x-1/2 flex gap-0.5">
                  {[...Array(8)].map((_, i) => (
                    <div key={i} className="w-3 h-0.5 bg-slate-600 rounded-full" />
                  ))}
                </div>

                {/* Locker Grid - 4 columns x 3 rows */}
                <div className="grid grid-cols-4 gap-1.5 mt-4">
                  {lockers.map((locker) => {
                    const colors = statusColors[locker.status];
                    const selected = isSelected(locker.id);
                    return (
                      <div
                        key={locker.id}
                        className="relative cursor-pointer group"
                        onClick={() => handleLockerClick(locker)}
                      >
                        {/* Selection Ring */}
                        {selected && !locker.isOpen && (
                          <div className="absolute -inset-1 rounded-md border-2 border-orange-400 z-20 pointer-events-none animate-pulse" />
                        )}

                        {/* Locker Door - Smart Design */}
                        <div
                          className={`
                            relative bg-gradient-to-b from-slate-700 to-slate-800 rounded-md border overflow-hidden
                            transition-all duration-300
                            ${locker.isOpen ? 'border-emerald-400 shadow-lg shadow-emerald-400/30' : 'border-slate-600'}
                            ${selected && !locker.isOpen ? 'border-orange-400 shadow-lg shadow-orange-400/30' : ''}
                            ${locker.status === 'available' && !selected ? 'hover:border-cyan-400' : ''}
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
                          {/* LED Strip Top */}
                          <div className={`h-0.5 w-full ${colors.dot} ${locker.status === 'available' ? 'animate-pulse' : ''}`} />

                          {/* Door Content */}
                          {!locker.isOpen && (
                            <div className="px-1 py-1.5">
                              {/* Locker Number */}
                              <div className="text-center">
                                <span className={`text-[10px] sm:text-xs font-black ${selected ? 'text-orange-400' : colors.text}`}>
                                  {String(locker.id).padStart(2, '0')}
                                </span>
                              </div>

                              {/* Status Dot + Label */}
                              <div className="flex items-center justify-center gap-0.5 mt-0.5">
                                <div className={`w-1 h-1 rounded-full ${colors.dot}`} />
                                <span className={`text-[6px] font-bold uppercase tracking-wider ${colors.text}`}>
                                  {selected ? 'SEL' : locker.status === 'available' ? 'OK' : locker.status === 'occupied' ? 'USE' : 'RSV'}
                                </span>
                              </div>

                              {/* Smart Lock Icon */}
                              <div className="absolute bottom-0.5 right-0.5">
                                <svg className="w-1.5 h-1.5 text-slate-500" fill="currentColor" viewBox="0 0 20 20">
                                  <path d="M10 2a5 5 0 00-5 5v2a2 2 0 00-2 2v5a2 2 0 002 2h10a2 2 0 002-2v-5a2 2 0 00-2-2H7V7a3 3 0 015.905-.75 1 1 0 001.937-.5A5 5 0 0010 2z" />
                                </svg>
                              </div>
                            </div>
                          )}

                          {/* Locker Interior (when open) */}
                          {locker.isOpen && (
                            <div className="absolute inset-0 bg-gradient-to-b from-slate-900 to-black flex items-center justify-center">
                              <div className="w-full h-full border border-emerald-400/30 m-1 rounded-sm flex items-center justify-center">
                                <span className="text-emerald-400 text-[8px] font-mono">OPEN</span>
                              </div>
                            </div>
                          )}

                          {/* 3D Side Shadow */}
                          <div className="absolute inset-y-0 -right-0.5 w-0.5 bg-gradient-to-r from-black/40 to-transparent" />
                        </div>

                        {/* Close Button */}
                        {locker.isOpen && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleCloseLocker(locker.id);
                            }}
                            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-30 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white rounded px-1.5 py-0.5 font-bold text-[8px] shadow-lg hover:from-emerald-600 hover:to-emerald-700 active:scale-95 transition-all"
                          >
                            ĐÓNG
                          </button>
                        )}
                      </div>
                    );
                  })}
                </div>

                {/* Bottom Status Bar */}
                <div className="mt-3 pt-2 border-t border-slate-700 flex items-center justify-between">
                  <div className="flex items-center gap-2 text-[8px] text-slate-400 font-mono">
                    <div className="flex items-center gap-0.5">
                      <div className="w-1 h-1 rounded-full bg-emerald-400 animate-pulse" />
                      <span>{availableLockers.length}</span>
                    </div>
                    <div className="flex items-center gap-0.5">
                      <div className="w-1 h-1 rounded-full bg-red-400" />
                      <span>{lockers.filter(l => l.status === 'occupied').length}</span>
                    </div>
                  </div>
                  <div className="text-[8px] text-orange-400 font-mono font-bold">
                    IoT · 4G
                  </div>
                </div>

                {/* Base Stand */}
                <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-3/4 h-2 bg-gradient-to-b from-slate-700 to-slate-900 rounded-b-lg" />
              </div>

              {/* ===== Floating Status Badges ===== */}
              <div className="absolute -top-3 -right-3 bg-gradient-to-br from-emerald-400 to-emerald-600 text-white rounded-full px-2 py-0.5 shadow-lg shadow-emerald-400/30 flex items-center gap-1">
                <div className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
                <span className="text-[8px] font-bold">LIVE</span>
              </div>

              <div className="absolute -bottom-3 -left-3 bg-gradient-to-br from-cyan-400 to-cyan-600 text-white rounded-full px-2 py-0.5 shadow-lg shadow-cyan-400/30 flex items-center gap-1">
                <svg className="w-2 h-2" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z" />
                </svg>
                <span className="text-[8px] font-bold">IoT</span>
              </div>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="mt-12 sm:mt-16 text-center">
          <div className="inline-flex flex-wrap justify-center gap-3 sm:gap-6 bg-white/80 backdrop-blur-sm rounded-xl sm:rounded-2xl px-4 sm:px-8 py-3 sm:py-4 shadow-lg">
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-orange-500 text-white text-[10px] sm:text-xs font-bold">1</span>
              <span className="hidden sm:inline">Chọn tủ trống</span>
              <span className="sm:hidden">Chọn tủ</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-orange-500 text-white text-[10px] sm:text-xs font-bold">2</span>
              <span className="hidden sm:inline">Quét QR hoặc nhập OTP</span>
              <span className="sm:hidden">Quét QR/OTP</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-green-500 text-white text-[10px] sm:text-xs font-bold">3</span>
              <span className="hidden sm:inline">Tủ tự động mở</span>
              <span className="sm:hidden">Tủ mở</span>
            </div>
            <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
              <span className="flex items-center justify-center w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-blue-500 text-white text-[10px] sm:text-xs font-bold">4</span>
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