import { useState, useRef, useEffect } from 'react';

type AppState = 'main' | 'scan' | 'pin' | 'opening' | 'success' | 'closing';
type TabState = 'home' | 'scan' | 'history' | 'profile';

interface PhoneMockupProps {
  onSelectLocker: (lockerId: number) => void;
  onCloseLocker: (lockerId: number) => void;
  availableLockers: number[];
  selectedLockerId: number | null;
}

export default function PhoneMockup({ onSelectLocker, onCloseLocker, availableLockers, selectedLockerId }: PhoneMockupProps) {
  const [appState, setAppState] = useState<AppState>('main');
  const [activeTab, setActiveTab] = useState<TabState>('home');
  const [scanProgress, setScanProgress] = useState(0);
  const [pinValue, setPinValue] = useState<string[]>(['', '', '', '']);
  const [pinError, setPinError] = useState('');
  const [activeMode, setActiveMode] = useState<'scan' | 'pin'>('scan');
  const pinRefs = useRef<(HTMLInputElement | null)[]>([]);
  const scanIntervalRef = useRef<number | null>(null);

  useEffect(() => {
    if (appState === 'pin') {
      setTimeout(() => pinRefs.current[0]?.focus(), 100);
    }
  }, [appState]);

  useEffect(() => {
    if (selectedLockerId) {
      setAppState('main');
      setActiveTab('home');
      setPinValue(['', '', '', '']);
      setPinError('');
    }
  }, [selectedLockerId]);

  // Cleanup scan interval on unmount
  useEffect(() => {
    return () => {
      if (scanIntervalRef.current) {
        clearInterval(scanIntervalRef.current);
      }
    };
  }, []);

  const handleScanQR = () => {
    if (scanIntervalRef.current) {
      clearInterval(scanIntervalRef.current);
    }
    setAppState('scan');
    setScanProgress(0);
    
    scanIntervalRef.current = window.setInterval(() => {
      setScanProgress(prev => {
        if (prev >= 100) {
          if (scanIntervalRef.current) {
            clearInterval(scanIntervalRef.current);
            scanIntervalRef.current = null;
          }
          if (selectedLockerId) {
            setAppState('opening');
            setTimeout(() => {
              onSelectLocker(selectedLockerId);
              setAppState('success');
            }, 1500);
          }
          return 100;
        }
        return prev + 2;
      });
    }, 50);
  };

  const handlePinChange = (index: number, value: string) => {
    const digit = value.replace(/\D/g, '').slice(-1);
    const newPin = [...pinValue];
    newPin[index] = digit;
    setPinValue(newPin);
    setPinError('');

    if (digit && index < 3) {
      pinRefs.current[index + 1]?.focus();
    }

    // Check if all digits are filled
    if (newPin.every(d => d !== '')) {
      setTimeout(() => {
        if (newPin.join('') === '1234' && selectedLockerId) {
          setAppState('opening');
          setTimeout(() => {
            onSelectLocker(selectedLockerId);
            setAppState('success');
          }, 1500);
        } else if (newPin.join('').length === 4) {
          setPinError('Mã PIN không đúng');
          setPinValue(['', '', '', '']);
        }
      }, 300);
    }
  };

  const handlePinKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !pinValue[index] && index > 0) {
      pinRefs.current[index - 1]?.focus();
    }
  };

  const resetToMain = () => {
    if (scanIntervalRef.current) {
      clearInterval(scanIntervalRef.current);
      scanIntervalRef.current = null;
    }
    setAppState('main');
    setPinValue(['', '', '', '']);
    setScanProgress(0);
    setPinError('');
  };

  const isLockerSelected = selectedLockerId !== null && availableLockers.includes(selectedLockerId);

  const handleCloseLocker = () => {
    if (selectedLockerId) {
      onCloseLocker(selectedLockerId);
    }
    setAppState('closing');
    setTimeout(() => {
      setAppState('main');
      setActiveTab('home');
    }, 2000);
  };

  const handlePinSubmit = () => {
    if (pinValue.join('') === '1234' && selectedLockerId) {
      setAppState('opening');
      setTimeout(() => {
        onSelectLocker(selectedLockerId);
        setAppState('success');
      }, 1500);
    } else if (pinValue.join('').length === 4) {
      setPinError('Mã PIN không đúng');
    }
  };

  return (
    <div className="relative mx-auto w-full max-w-sm">
      {/* Phone Frame */}
      <div className="relative bg-gray-900 rounded-[3rem] p-2 shadow-2xl overflow-hidden">
        {/* Dynamic Island */}
        <div className="absolute top-2 left-1/2 -translate-x-1/2 w-32 h-7 bg-black rounded-full z-50" />

        {/* Screen */}
        <div className="relative bg-gray-50 rounded-[2.5rem] overflow-hidden flex flex-col" style={{ height: '720px' }}>
          {/* Status Bar */}
          <div className="flex items-center justify-between px-6 py-3 bg-gray-900 text-white text-xs shrink-0">
            <span className="font-semibold">9:41</span>
            <div className="flex items-center gap-1.5">
              <div className="flex items-center">
                <div className="w-4 h-3 border border-white/50 rounded-sm relative">
                  <div className="absolute right-[-2px] top-1/2 -translate-y-1/2 w-[2px] h-1.5 bg-white/50" />
                </div>
              </div>
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 3C7.46 3 3.34 4.78.29 7.67c-.18.18-.29.43-.29.71 0 .28.11.53.29.71l2.48 2.48c.18.18.43.29.71.29.27 0 .52-.11.7-.28.79-.74 1.69-1.36 2.66-1.85.33-.16.56-.5.56-.9v-3.1c1.45-.48 3-.73 4.6-.73s3.15.25 4.6.72v3.1c0 .39.23.74.56.9.98.49 1.87 1.12 2.67 1.85.18.18.43.28.7.28.28 0 .53-.11.71-.29l2.48-2.48c.18-.18.29-.43.29-.71 0-.28-.11-.53-.29-.71C20.66 4.78 16.54 3 12 3z"/>
              </svg>
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M17 4h-3V2h-4v2H7v18h10V4z"/>
              </svg>
            </div>
          </div>

          {/* App Content */}
          <div className="flex-1 flex flex-col min-h-0 relative">
            {/* Header */}
            <div className="bg-white px-5 py-4 shrink-0 shadow-sm z-10">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <img src="/LOGO-EBOX.png" alt="E-BOX" className="h-9 w-auto" />
                  <div>
                    <h1 className="text-lg font-bold text-gray-900 leading-tight">E-BOX</h1>
                    <p className="text-[10px] text-orange-500 font-medium -mt-0.5">Smart Locker</p>
                  </div>
                </div>
                <button className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                  <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                  </svg>
                </button>
              </div>
            </div>

            {/* Scrollable Content */}
            <div className={`flex-1 overflow-y-auto overscroll-contain p-4 ${appState === 'success' || appState === 'closing' ? 'pointer-events-none' : ''}`}>
              
              {/* Main Screen */}
              {appState === 'main' && (
                <div className="space-y-4">
                  {/* Selected Locker Card */}
                  {isLockerSelected ? (
                    <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                      <div className="flex items-center gap-4">
                        <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-500 rounded-2xl flex items-center justify-center shadow-lg">
                          <span className="text-white text-2xl font-black">{selectedLockerId}</span>
                        </div>
                        <div className="flex-1">
                          <p className="font-bold text-gray-800 text-lg">Tủ #{selectedLockerId}</p>
                          <p className="text-sm text-green-600 font-medium flex items-center gap-1">
                            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                            Sẵn sàng sử dụng
                          </p>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="bg-orange-50 border-2 border-orange-200 rounded-2xl p-5 text-center">
                      <svg className="w-12 h-12 mx-auto text-orange-400 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
                      </svg>
                      <p className="text-orange-600 font-medium">Chọn tủ trên cabinet để bắt đầu</p>
                    </div>
                  )}

                  {/* Mode Toggle */}
                  <div className="bg-white rounded-2xl p-2 shadow-sm border border-gray-100">
                    <div className="flex">
                      <button
                        onClick={() => setActiveMode('scan')}
                        className={`flex-1 py-3 px-4 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2 ${
                          activeMode === 'scan' 
                            ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-md' 
                            : 'text-gray-500'
                        }`}
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
                        </svg>
                        Quét QR
                      </button>
                      <button
                        onClick={() => setActiveMode('pin')}
                        className={`flex-1 py-3 px-4 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2 ${
                          activeMode === 'pin' 
                            ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-md' 
                            : 'text-gray-500'
                        }`}
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                        </svg>
                        Nhập mã PIN
                      </button>
                    </div>
                  </div>

                  {/* QR Scan Mode */}
                  {activeMode === 'scan' && (
                    <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                      <div className="relative aspect-square bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl overflow-hidden mb-4">
                        <div className="absolute inset-0 flex items-center justify-center">
                          <div className="w-48 h-48 border-4 border-white/30 rounded-3xl relative">
                            <div className="absolute top-0 left-0 w-10 h-10 border-t-4 border-l-4 border-orange-500 rounded-tl-2xl" />
                            <div className="absolute top-0 right-0 w-10 h-10 border-t-4 border-r-4 border-orange-500 rounded-tr-2xl" />
                            <div className="absolute bottom-0 left-0 w-10 h-10 border-b-4 border-l-4 border-orange-500 rounded-bl-2xl" />
                            <div className="absolute bottom-0 right-0 w-10 h-10 border-b-4 border-r-4 border-orange-500 rounded-br-2xl" />
                            <div className="absolute inset-8 border-2 border-dashed border-white/20 rounded-2xl" />
                          </div>
                        </div>
                      </div>
                      <p className="text-center text-gray-600 font-medium">Đưa camera về phía mã QR</p>
                      <button
                        onClick={handleScanQR}
                        disabled={!isLockerSelected}
                        className={`w-full mt-4 rounded-xl py-4 font-bold shadow-lg transition-all ${
                          isLockerSelected
                            ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white active:scale-95'
                            : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                        }`}
                      >
                        {isLockerSelected ? 'Bắt đầu quét' : 'Chọn tủ trước'}
                      </button>
                    </div>
                  )}

                  {/* PIN Mode */}
                  {activeMode === 'pin' && (
                    <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                      <div className="text-center mb-6">
                        <p className="text-gray-600 font-medium">Nhập mã PIN 4 chữ số</p>
                        <p className="text-xs text-gray-400 mt-1">Demo: 1234</p>
                      </div>
                      <div className="flex justify-center gap-3 mb-4">
                        {pinValue.map((digit, i) => (
                          <input
                            key={i}
                            ref={el => { pinRefs.current[i] = el; }}
                            type="text"
                            inputMode="numeric"
                            maxLength={1}
                            value={digit}
                            onChange={(e) => handlePinChange(i, e.target.value)}
                            onKeyDown={(e) => handlePinKeyDown(i, e)}
                            className={`w-14 h-16 text-center text-2xl font-bold border-2 rounded-xl transition-all ${
                              digit ? 'border-orange-500 bg-orange-50' : 'border-gray-200 bg-white'
                            }`}
                          />
                        ))}
                      </div>
                      {pinError && <p className="text-center text-red-500 text-sm mb-4">{pinError}</p>}
                      <button
                        onClick={handlePinSubmit}
                        disabled={!isLockerSelected || pinValue.join('').length !== 4}
                        className={`w-full rounded-xl py-4 font-bold shadow-lg transition-all ${
                          isLockerSelected && pinValue.join('').length === 4
                            ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white active:scale-95'
                            : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                        }`}
                      >
                        {isLockerSelected ? 'Xác nhận' : 'Chọn tủ trước'}
                      </button>
                    </div>
                  )}

                  {/* Available Lockers */}
                  <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-3">
                      <h3 className="font-bold text-gray-800">Tủ trống</h3>
                      <span className="text-xs text-gray-500">{availableLockers.length} tủ</span>
                    </div>
                    <div className="grid grid-cols-5 gap-2">
                      {availableLockers.map((locker) => (
                        <button
                          key={locker}
                          onClick={() => onSelectLocker(locker)}
                          className={`aspect-square rounded-xl border-2 flex items-center justify-center font-bold text-sm transition-all ${
                            selectedLockerId === locker
                              ? 'border-orange-500 bg-orange-50 text-orange-600'
                              : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300'
                          }`}
                        >
                          {locker}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* Scan State */}
              {appState === 'scan' && (
                <div className="space-y-4">
                  <button onClick={resetToMain} className="text-orange-500 text-sm font-medium flex items-center gap-1">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7"/>
                    </svg>
                    Quay lại
                  </button>
                  <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div className="relative aspect-square bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl overflow-hidden mb-4">
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-48 h-48 border-4 border-white/30 rounded-3xl relative">
                          <div className="absolute top-0 left-0 w-10 h-10 border-t-4 border-l-4 border-orange-500 rounded-tl-2xl" />
                          <div className="absolute top-0 right-0 w-10 h-10 border-t-4 border-r-4 border-orange-500 rounded-tr-2xl" />
                          <div className="absolute bottom-0 left-0 w-10 h-10 border-b-4 border-l-4 border-orange-500 rounded-bl-2xl" />
                          <div className="absolute bottom-0 right-0 w-10 h-10 border-b-4 border-r-4 border-orange-500 rounded-br-2xl" />
                          <div className="absolute inset-8 border-2 border-dashed border-white/20 rounded-2xl" />
                        </div>
                      </div>
                      <div
                        className="absolute left-4 right-4 h-0.5 bg-gradient-to-r from-transparent via-orange-500 to-transparent"
                        style={{ top: `${scanProgress}%`, transition: 'top 0.05s linear' }}
                      />
                    </div>
                    <p className="text-center text-gray-600 font-medium">Đang quét tủ #{selectedLockerId}</p>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden mt-4">
                      <div
                        className="h-full bg-gradient-to-r from-orange-500 to-orange-600 rounded-full transition-all duration-100"
                        style={{ width: `${scanProgress}%` }}
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* PIN State (Full Screen) */}
              {appState === 'pin' && (
                <div className="space-y-4">
                  <button onClick={resetToMain} className="text-orange-500 text-sm font-medium flex items-center gap-1">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7"/>
                    </svg>
                    Quay lại
                  </button>
                  <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div className="text-center mb-4">
                      <p className="font-bold text-gray-800">Nhập mã PIN</p>
                      <p className="text-sm text-gray-500 mt-1">Tủ #{selectedLockerId}</p>
                    </div>
                    <div className="flex justify-center gap-3 mb-4">
                      {pinValue.map((digit, i) => (
                        <div
                          key={i}
                          className={`w-14 h-16 text-center text-2xl font-bold border-2 rounded-xl flex items-center justify-center ${
                            digit ? 'border-orange-500 bg-orange-50' : 'border-gray-200 bg-white'
                          }`}
                        >
                          {digit ? '•' : ''}
                        </div>
                      ))}
                    </div>
                    <div className="grid grid-cols-3 gap-2">
                      {['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'].map((key, i) => (
                        <button
                          key={i}
                          disabled={key === ''}
                          onClick={() => {
                            if (key === '⌫') {
                              const lastFilled = [...pinValue].reverse().findIndex(d => d !== '');
                              if (lastFilled !== -1) {
                                const index = 3 - lastFilled;
                                handlePinChange(index, '');
                              }
                            } else if (key) {
                              const nextEmpty = pinValue.findIndex(d => d === '');
                              if (nextEmpty !== -1) {
                                handlePinChange(nextEmpty, key);
                              }
                            }
                          }}
                          className={`h-12 rounded-xl font-bold text-lg transition-all ${
                            key === '' 
                              ? 'bg-transparent' 
                              : 'bg-gray-100 text-gray-700 active:bg-gray-200'
                          }`}
                        >
                          {key}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* Spacer for TabBar */}
              <div className="h-20" />
            </div>

            {/* Tab Bar */}
            <div className="bg-white border-t border-gray-100 px-4 py-2 z-20 shrink-0">
              <div className="flex justify-around">
                {[
                  { id: 'home', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6', label: 'Trang chủ' },
                  { id: 'scan', icon: 'M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z', label: 'Quét QR' },
                  { id: 'history', icon: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z', label: 'Lịch sử', disabled: true },
                  { id: 'profile', icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z', label: 'Tài khoản', disabled: true },
                ].map((tab) => (
                  <button
                    key={tab.id}
                    disabled={'disabled' in tab && tab.disabled}
                    onClick={() => setActiveTab(tab.id as TabState)}
                    className={`flex flex-col items-center py-1 px-3 rounded-lg transition-all ${
                      activeTab === tab.id ? 'text-orange-500' : 'disabled' in tab && tab.disabled ? 'text-gray-300 cursor-not-allowed' : 'text-gray-400'
                    }`}
                  >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={activeTab === tab.id ? 2.5 : 2} d={tab.icon} />
                    </svg>
                    <span className="text-[10px] mt-0.5 font-medium">{tab.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Bottom Safe Area */}
            <div className="h-8 shrink-0" />

            {/* Overlay States (Positioned absolutely over everything) */}
            {appState === 'opening' && (
              <div className="absolute inset-0 bg-white/98 z-40 flex flex-col items-center justify-center p-6">
                <div className="w-20 h-20 bg-gradient-to-br from-orange-400 to-orange-500 rounded-full flex items-center justify-center shadow-xl mb-4">
                  <svg className="w-10 h-10 text-white animate-spin" style={{ animationDuration: '2s' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                </div>
                <h2 className="text-xl font-bold text-gray-800">Đang mở tủ...</h2>
                <p className="text-sm text-gray-500 mt-1">Tủ #{selectedLockerId}</p>
              </div>
            )}

            {appState === 'success' && (
              <div className="absolute inset-0 bg-white/98 z-40 flex flex-col items-center justify-center p-6">
                <div className="w-20 h-20 bg-gradient-to-br from-green-400 to-green-500 rounded-full flex items-center justify-center shadow-xl mb-4">
                  <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <h2 className="text-xl font-bold text-gray-800">Mở tủ thành công!</h2>
                <p className="text-sm text-gray-500 mt-1">Tủ #{selectedLockerId}</p>
                <p className="text-sm text-gray-400 mt-4 mb-6">Lấy đồ và nhấn đóng tủ</p>
                <button
                  onClick={handleCloseLocker}
                  className="bg-gradient-to-r from-orange-500 to-orange-600 text-white rounded-xl px-8 py-3 font-bold shadow-lg active:scale-95 transition-transform"
                >
                  Đóng tủ
                </button>
              </div>
            )}

            {appState === 'closing' && (
              <div className="absolute inset-0 bg-white/98 z-40 flex flex-col items-center justify-center p-6">
                <img src="/LOGO-EBOX.png" alt="E-BOX" className="h-12 w-auto mb-4 opacity-60" />
                <div className="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center mb-4">
                  <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <h2 className="text-lg font-bold text-gray-800">Tủ đã đóng!</h2>
                <p className="text-sm text-gray-500 mt-1">Cảm ơn bạn đã sử dụng</p>
              </div>
            )}
          </div>

          {/* Home Indicator */}
          <div className="absolute bottom-1 left-1/2 -translate-x-1/2 w-32 h-1 bg-gray-400 rounded-full" />
        </div>
      </div>
    </div>
  );
}
