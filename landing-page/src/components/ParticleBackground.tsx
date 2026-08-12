import { useEffect, useMemo } from 'react';

interface Particle {
  id: number;
  x: number;
  size: number;
  duration: number;
  delay: number;
  opacity: number;
}

export default function ParticleBackground() {
  const particles = useMemo<Particle[]>(() => {
    return Array.from({ length: 30 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      size: Math.random() * 4 + 2,
      duration: Math.random() * 20 + 15,
      delay: Math.random() * 20,
      opacity: Math.random() * 0.5 + 0.1,
    }));
  }, []);

  return (
    <div className="pointer-events-none fixed inset-0 overflow-hidden z-0">
      {/* Gradient mesh background */}
      <div className="absolute inset-0 bg-gradient-to-br from-orange-50 via-white to-orange-100" />
      
      {/* Animated gradient blobs */}
      <div className="absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-gradient-to-br from-orange-200/40 to-orange-300/30 blur-3xl animate-float" />
      <div className="absolute -bottom-40 -left-40 h-[400px] w-[400px] rounded-full bg-gradient-to-br from-orange-100/50 to-orange-200/40 blur-3xl animate-float-delayed" />
      <div className="absolute right-1/4 top-1/2 h-[300px] w-[300px] rounded-full bg-orange-300/20 blur-3xl animate-gradient" />
      
      {/* Grid pattern */}
      <div className="absolute inset-0 grid-bg opacity-50" />
      
      {/* Floating particles */}
      {particles.map((particle) => (
        <div
          key={particle.id}
          className="absolute rounded-full bg-orange-400"
          style={{
            left: `${particle.x}%`,
            width: `${particle.size}px`,
            height: `${particle.size}px`,
            opacity: particle.opacity,
            animation: `particle-float ${particle.duration}s linear infinite`,
            animationDelay: `${particle.delay}s`,
          }}
        />
      ))}
      
      {/* Glowing lines */}
      <svg className="absolute inset-0 w-full h-full opacity-10">
        <defs>
          <linearGradient id="line-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#F97316" stopOpacity="0" />
            <stop offset="50%" stopColor="#F97316" stopOpacity="1" />
            <stop offset="100%" stopColor="#F97316" stopOpacity="0" />
          </linearGradient>
        </defs>
        <line x1="0" y1="30%" x2="100%" y2="30%" stroke="url(#line-gradient)" strokeWidth="1" className="animate-shimmer" />
        <line x1="0" y1="70%" x2="100%" y2="70%" stroke="url(#line-gradient)" strokeWidth="1" className="animate-shimmer" style={{ animationDelay: '1s' }} />
        <line x1="20%" y1="0" x2="20%" y2="100%" stroke="url(#line-gradient)" strokeWidth="1" className="animate-shimmer" style={{ animationDelay: '0.5s' }} />
        <line x1="80%" y1="0" x2="80%" y2="100%" stroke="url(#line-gradient)" strokeWidth="1" className="animate-shimmer" style={{ animationDelay: '1.5s' }} />
      </svg>
    </div>
  );
}
