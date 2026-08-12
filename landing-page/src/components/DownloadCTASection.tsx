import { useEffect, useRef } from 'react';
import { GOOGLE_PLAY_URL } from '../lib/constants';

export default function DownloadCTASection() {
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
    <section ref={sectionRef} id="download" className="relative py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900" />
      <div className="absolute inset-0 grid-bg-dark opacity-40" />
      
      {/* Animated gradient orbs */}
      <div className="absolute top-0 left-1/4 w-[500px] h-[500px] bg-orange-500/30 rounded-full blur-[150px] animate-pulse" />
      <div className="absolute bottom-0 right-1/4 w-[500px] h-[500px] bg-orange-600/20 rounded-full blur-[150px] animate-pulse" style={{ animationDelay: '1s' }} />

      <div className="relative mx-auto max-w-7xl px-6">
        <div className="grid items-center gap-16 lg:grid-cols-2">
          {/* Left: Content */}
          <div className="scroll-animate">
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-500/30 bg-orange-500/10 px-5 py-2 text-sm font-bold uppercase tracking-widest text-orange-400">
              <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Tải Về Ngay
            </span>
            
            <h2 className="mt-8 text-4xl font-black tracking-tight sm:text-5xl lg:text-6xl">
              <span className="text-white">Sẵn Sàng</span>
              <br />
              <span className="gradient-text">Bắt Đầu?</span>
            </h2>
            
            <p className="mt-6 max-w-lg text-lg text-gray-400 leading-relaxed">
              Tải ứng dụng E-BOX ngay hôm nay và trải nghiệm giải pháp gửi nhận hàng thông minh dành cho sinh viên FPT.
            </p>

            {/* Features List */}
            <div className="mt-8 space-y-4">
              {[
                'Miễn phí tải về & sử dụng',
                'Hỗ trợ iOS & Android',
                'Cập nhật tính năng mới liên tục',
                'Dịch vụ hỗ trợ 24/7',
              ].map((item, index) => (
                <div key={index} className="flex items-center gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-green-500/20 text-green-400">
                    <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <span className="text-gray-300 font-medium">{item}</span>
                </div>
              ))}
            </div>

            {/* Download Buttons */}
            <div className="mt-10 flex flex-wrap gap-4">
              <a
                href={GOOGLE_PLAY_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="glass-btn-google"
              >
                <svg className="h-10 w-10 flex-shrink-0" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <defs>
                    <linearGradient id="cta-chplay-g1" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#00C9FF" />
                      <stop offset="100%" stopColor="#0080FF" />
                    </linearGradient>
                    <linearGradient id="cta-chplay-g2" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#FFEE00" />
                      <stop offset="100%" stopColor="#FFA800" />
                    </linearGradient>
                    <linearGradient id="cta-chplay-g3" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#FF4D6D" />
                      <stop offset="100%" stopColor="#FF1A4D" />
                    </linearGradient>
                    <linearGradient id="cta-chplay-g4" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#00E676" />
                      <stop offset="100%" stopColor="#00A152" />
                    </linearGradient>
                  </defs>
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a1 1 0 01-.61-.916V2.73a1 1 0 01.609-.916z" fill="url(#cta-chplay-g1)" />
                  <path d="M13.792 12L3.609 1.814c.197-.132.443-.196.685-.196.243 0 .485.063.682.184l10.13 5.788L13.792 12z" fill="url(#cta-chplay-g4)" />
                  <path d="M13.792 12L3.609 22.186c.197.13.44.195.682.195.243 0 .487-.066.682-.195l10.13-5.787L13.792 12z" fill="url(#cta-chplay-g3)" />
                  <path d="M20.16 10.13l-2.873-1.643L15.106 12l2.182 3.513 2.873-1.643a1.487 1.487 0 000-2.737z" fill="url(#cta-chplay-g2)" />
                </svg>
                <div className="text-left">
                  <div className="text-[10px] font-medium uppercase tracking-wider opacity-90">Get it on</div>
                  <div className="text-lg font-bold">Google Play</div>
                </div>
              </a>
            </div>
          </div>

          {/* Right: Phone Mockup */}
          <div className="relative scroll-animate" style={{ animationDelay: '200ms' }}>
            <div className="relative mx-auto w-full max-w-sm">
              {/* Glow behind */}
              <div className="absolute inset-0 bg-gradient-to-br from-orange-500 to-orange-600 blur-3xl opacity-50 scale-110" />
              
              {/* Phone Frame */}
              <div className="relative">
                {/* Phone body */}
                <div className="bg-gray-900 rounded-[3rem] p-3 shadow-2xl border border-gray-700">
                  <div className="bg-gray-800 rounded-[2.5rem] overflow-hidden">
                    {/* Notch */}
                    <div className="h-8 bg-gray-900 flex items-center justify-center">
                      <div className="w-20 h-5 bg-black rounded-full" />
                    </div>
                    
                    {/* Screen Content */}
                    <div className="p-6 bg-gradient-to-b from-gray-800 to-gray-900">
                      {/* App Header */}
                      <div className="flex items-center justify-between mb-6">
                        <div>
                          <div className="text-white font-bold text-lg">E-BOX</div>
                          <div className="text-gray-500 text-xs">Smart Locker</div>
                        </div>
                        <div className="w-8 h-8 rounded-full bg-orange-500 flex items-center justify-center">
                          <span className="text-white text-xs font-bold">EB</span>
                        </div>
                      </div>

                      {/* Status Card */}
                      <div className="bg-gradient-to-br from-green-500/10 to-green-600/5 rounded-2xl p-4 mb-4 border border-green-500/20">
                        <div className="flex items-center gap-3 mb-3">
                          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-green-400 to-green-500 flex items-center justify-center shadow-lg shadow-green-500/30">
                            <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <div>
                            <div className="text-white text-sm font-bold">Giao hàng thành công!</div>
                            <div className="text-gray-400 text-xs">Tủ #07 đã mở</div>
                          </div>
                        </div>
                        <div className="h-1.5 bg-gray-700/50 rounded-full overflow-hidden">
                          <div className="h-full w-3/4 bg-gradient-to-r from-green-400 to-green-500 rounded-full shadow-lg shadow-green-500/50" />
                        </div>
                      </div>

                      {/* Quick Actions */}
                      <div className="grid grid-cols-3 gap-3 mb-4">
                        {[
                          { label: 'Mở tủ', icon: 'M12 4v16m8-8H4', color: 'from-orange-400 to-orange-500' },
                          { label: 'Đặt tủ', icon: 'M12 6v6m0 0v6m0-6h6m-6 0H6', color: 'from-blue-400 to-blue-500' },
                          { label: 'Lịch sử', icon: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z', color: 'from-purple-400 to-purple-500' },
                        ].map((action) => (
                          <div key={action.label} className="bg-gradient-to-b from-gray-700/50 to-gray-800/50 rounded-xl p-3 text-center border border-gray-600/30 hover:border-gray-500/50 transition-all hover:scale-105 cursor-pointer">
                            <div className={`w-8 h-8 mx-auto mb-2 rounded-lg bg-gradient-to-br ${action.color} flex items-center justify-center shadow-lg`}>
                              <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={action.icon} />
                              </svg>
                            </div>
                            <div className="text-white text-xs font-medium">{action.label}</div>
                          </div>
                        ))}
                      </div>

                      {/* Locker Preview */}
                      <div className="relative bg-gradient-to-b from-gray-100 to-gray-200 rounded-2xl p-3 shadow-inner border border-gray-300">
                        {/* Top Display */}
                        <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-lg p-2 mb-3 flex items-center justify-between">
                          <div className="w-8 h-8 bg-white rounded flex items-center justify-center">
                            <div className="w-5 h-5 bg-black rounded-sm grid grid-cols-3 gap-px p-0.5">
                              <div className="bg-white rounded-sm" />
                              <div className="bg-black" />
                              <div className="bg-white rounded-sm" />
                              <div className="bg-black" />
                              <div className="bg-white rounded-sm" />
                              <div className="bg-black" />
                              <div className="bg-white rounded-sm" />
                              <div className="bg-black" />
                              <div className="bg-white rounded-sm" />
                            </div>
                          </div>
                          <div className="text-[10px] text-gray-400 font-mono">E-BOX</div>
                          <div className="text-right">
                            <div className="text-sm font-black text-orange-500">3</div>
                            <div className="text-[8px] text-gray-500">Trống</div>
                          </div>
                        </div>
                        
                        {/* Locker Grid */}
                        <div className="grid grid-cols-4 gap-1.5">
                          {[
                            { id: 1, status: 'available' },
                            { id: 2, status: 'occupied' },
                            { id: 3, status: 'available' },
                            { id: 4, status: 'available' },
                            { id: 5, status: 'reserved' },
                            { id: 6, status: 'occupied' },
                            { id: 7, status: 'selected' },
                            { id: 8, status: 'available' },
                          ].map((locker) => {
                            const statusStyles = {
                              available: 'bg-gradient-to-b from-white to-gray-50 border-gray-200 text-gray-700',
                              occupied: 'bg-gradient-to-b from-red-100 to-red-50 border-red-300 text-red-600',
                              reserved: 'bg-gradient-to-b from-yellow-100 to-yellow-50 border-yellow-300 text-yellow-600',
                              selected: 'bg-gradient-to-b from-orange-400 to-orange-500 border-orange-500 text-white shadow-orange-200 shadow-lg',
                            };
                            return (
                              <div
                                key={locker.id}
                                className={`relative aspect-square rounded-lg border-2 flex flex-col items-center justify-center shadow-sm ${statusStyles[locker.status as keyof typeof statusStyles]}`}
                              >
                                {locker.status === 'selected' && (
                                  <div className="absolute -inset-0.5 rounded-lg border-2 border-orange-600 animate-pulse" />
                                )}
                                <span className={`text-[10px] font-black ${locker.status === 'selected' ? 'text-white' : ''}`}>
                                  {String(locker.id).padStart(2, '0')}
                                </span>
                                <div className={`w-1.5 h-1.5 rounded-full mt-0.5 ${
                                  locker.status === 'available' ? 'bg-green-500 animate-pulse' :
                                  locker.status === 'occupied' ? 'bg-red-500' :
                                  locker.status === 'reserved' ? 'bg-yellow-500' :
                                  'bg-white'
                                }`} />
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    </div>

                    {/* Home Indicator */}
                    <div className="h-6 bg-gray-900 flex items-center justify-center">
                      <div className="w-32 h-1 bg-gray-600 rounded-full" />
                    </div>
                  </div>
                </div>

                {/* Floating Elements */}
                <div className="absolute -top-4 -right-4 liquid-glass-dark-v2 rounded-2xl p-3 shadow-xl animate-float">
                  {/* Shimmer overlay */}
                  <div className="shimmer" />
                  
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-green-400 to-green-500 flex items-center justify-center shadow-lg">
                      <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                    <span className="text-white text-xs font-bold">Thành công</span>
                  </div>
                </div>

                <div className="absolute -bottom-4 -left-4 liquid-glass-dark-v2 rounded-2xl p-3 shadow-xl animate-float-delayed">
                  {/* Shimmer overlay */}
                  <div className="shimmer" />
                  
                  <div className="text-center">
                    <div className="text-2xl font-black gradient-text">98%</div>
                    <div className="text-gray-400 text-[10px]">Uptime</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
