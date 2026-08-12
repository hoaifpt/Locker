import { useEffect, useRef, useState } from 'react';

interface Stat {
  value: number;
  suffix: string;
  label: string;
  description: string;
}

interface Metric {
  label: string;
  value: string;
  progress: number;
  unit: string;
}

const stats: Stat[] = [
  { value: 10, suffix: 'K+', label: 'Sinh viên sử dụng', description: 'Được tin tưởng bởi sinh viên FPT' },
  { value: 500, suffix: '+', label: 'Tủ locker', description: 'Phủ rộng khắp khuôn viên' },
  { value: 98, suffix: '%', label: 'Uptime', description: 'Hoạt động 24/7 không ngừng nghỉ' },
  { value: 50, suffix: 'K+', label: 'Giao dịch/tháng', description: 'Xử lý hàng ngàn đơn hàng' },
];

const metrics: Metric[] = [
  { label: 'Thời gian phản hồi', value: '0.5', progress: 95, unit: 'giây' },
  { label: 'Bảo mật dữ liệu', value: '256', progress: 100, unit: 'bit encryption' },
  { label: 'Độ khả dụng', value: '99.9', progress: 99.9, unit: '%' },
  { label: 'Tiết kiệm thời gian', value: '85', progress: 85, unit: '%' },
];

function AnimatedCounter({ value, suffix }: { value: number; suffix: string }) {
  const [count, setCount] = useState(0);
  const [hasAnimated, setHasAnimated] = useState(false);
  const ref = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasAnimated) {
          setHasAnimated(true);
          let start = 0;
          const duration = 2000;
          const increment = value / (duration / 16);
          
          const timer = setInterval(() => {
            start += increment;
            if (start >= value) {
              setCount(value);
              clearInterval(timer);
            } else {
              setCount(Math.floor(start));
            }
          }, 16);
        }
      },
      { threshold: 0.5 }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, [value, hasAnimated]);

  return (
    <span ref={ref} className="stat-number">
      {count}{suffix}
    </span>
  );
}

function CircularProgress({ percentage, label }: { percentage: number; label: string }) {
  const [progress, setProgress] = useState(0);
  const [hasAnimated, setHasAnimated] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const circumference = 2 * Math.PI * 45;

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasAnimated) {
          setHasAnimated(true);
          let start = 0;
          const duration = 1500;
          const increment = percentage / (duration / 16);
          
          const timer = setInterval(() => {
            start += increment;
            if (start >= percentage) {
              setProgress(percentage);
              clearInterval(timer);
            } else {
              setProgress(Math.floor(start));
            }
          }, 16);
        }
      },
      { threshold: 0.5 }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, [percentage, hasAnimated]);

  return (
    <div ref={ref} className="flex flex-col items-center">
      <div className="relative w-28 h-28">
        <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
          <circle
            cx="50"
            cy="50"
            r="45"
            stroke="currentColor"
            strokeWidth="6"
            fill="none"
            className="text-gray-200"
          />
          <circle
            cx="50"
            cy="50"
            r="45"
            stroke="url(#progress-gradient)"
            strokeWidth="6"
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={circumference - (progress / 100) * circumference}
            className="transition-all duration-100"
          />
          <defs>
            <linearGradient id="progress-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#F97316" />
              <stop offset="100%" stopColor="#DC2626" />
            </linearGradient>
          </defs>
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-2xl font-black text-gray-900">{progress}%</span>
        </div>
      </div>
      <span className="mt-3 text-sm font-medium text-gray-600">{label}</span>
    </div>
  );
}

export default function StatisticsSection() {
  const [animatedMetrics, setAnimatedMetrics] = useState<boolean[]>(metrics.map(() => false));
  const metricsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setAnimatedMetrics(metrics.map(() => true));
        }
      },
      { threshold: 0.3 }
    );

    if (metricsRef.current) {
      observer.observe(metricsRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <section className="relative py-16 sm:py-24 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-gray-900 to-gray-800" />
      <div className="absolute inset-0 grid-bg-dark opacity-30" />
      
      {/* Glow orbs */}
      <div className="absolute top-0 left-1/4 w-96 h-96 bg-orange-500/20 rounded-full blur-3xl" />
      <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-orange-600/20 rounded-full blur-3xl" />

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6">
        {/* Section Header */}
        <div className="text-center mb-12 sm:mb-16 scroll-animate">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-500/30 bg-orange-500/10 px-4 py-1.5 text-xs sm:text-sm font-semibold uppercase tracking-widest text-orange-400">
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            Thống Kê
          </span>
          <h2 className="mt-4 sm:mt-6 text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black tracking-tight">
            <span className="text-white">Những Con Số</span>
            <br />
            <span className="gradient-text">Ấn Tượng</span>
          </h2>
          <p className="mx-auto mt-4 sm:mt-6 max-w-2xl text-sm sm:text-lg text-gray-400 px-4 sm:px-0">
            E-BOX tự hào với những thành tựu đáng kinh ngạc trong việc phục vụ sinh viên
          </p>
        </div>

        {/* Main Stats Grid */}
        <div className="grid gap-4 sm:gap-6 md:grid-cols-2 lg:grid-cols-4 mb-12 sm:mb-20">
          {stats.map((stat, index) => (
            <div
              key={stat.label}
              className="liquid-glass-dark-v2 p-6 sm:p-8 text-center"
              style={{ animationDelay: `${index * 100}ms` }}
            >
              {/* Shimmer overlay */}
              <div className="shimmer" />
              
              <div className="relative">
                <div className="text-4xl sm:text-5xl lg:text-6xl font-black gradient-text mb-2">
                  <AnimatedCounter value={stat.value} suffix={stat.suffix} />
                </div>
                <div className="text-base sm:text-lg font-bold text-white mb-1">{stat.label}</div>
                <div className="text-xs sm:text-sm text-gray-400">{stat.description}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Metrics with Progress Bars */}
        <div ref={metricsRef} className="grid gap-8 lg:grid-cols-2">
          {/* Progress Bars */}
          <div className="space-y-6">
            <h3 className="text-xl sm:text-2xl font-bold text-white mb-6">Hiệu Suất Hệ Thống</h3>
            {metrics.slice(0, 2).map((metric, index) => (
              <div key={metric.label} className="scroll-animate" style={{ animationDelay: `${index * 150}ms` }}>
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium text-gray-300 text-sm sm:text-base">{metric.label}</span>
                  <span className="font-bold text-orange-400 text-sm sm:text-base">{metric.value} {metric.unit}</span>
                </div>
                <div className="progress-bar">
                  <div
                    className={`progress-bar-fill ${animatedMetrics[index] ? 'animated' : ''}`}
                    style={{ '--progress': `${metric.progress}%` } as React.CSSProperties}
                  />
                </div>
              </div>
            ))}
          </div>

          {/* Circular Progress */}
          <div className="flex justify-around items-center">
            {metrics.slice(2).map((metric, index) => (
              <div key={metric.label} className="scroll-animate" style={{ animationDelay: `${index * 150 + 300}ms` }}>
                <CircularProgress 
                  percentage={metric.progress} 
                  label={metric.label}
                />
              </div>
            ))}
          </div>
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 sm:mt-20 text-center">
          <div className="liquid-glass-dark-v2 inline-flex items-center gap-4 px-6 sm:px-8 py-4">
            {/* Shimmer overlay */}
            <div className="shimmer" />
            
            <div className="flex -space-x-2">
              {[1, 2, 3, 4, 5].map((i) => (
                <div
                  key={i}
                  className="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 border-2 border-gray-900 flex items-center justify-center text-white text-xs sm:text-sm font-bold"
                >
                  {String.fromCharCode(64 + i)}
                </div>
              ))}
            </div>
            <div className="text-left hidden sm:block">
              <div className="text-white font-bold">10,000+ sinh viên đã tham gia</div>
              <div className="text-gray-400 text-sm">Gia nhập cộng đồng E-BOX ngay hôm nay</div>
            </div>
            <div className="text-left sm:hidden">
              <div className="text-white font-bold text-sm">10,000+ thành viên</div>
              <div className="text-gray-400 text-xs">E-BOX</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
