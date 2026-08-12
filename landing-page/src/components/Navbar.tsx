import { useState, useEffect } from 'react';
import { GOOGLE_PLAY_URL } from '../lib/constants';

const navLinks = [
  { href: '#features', label: 'Tính năng' },
  { href: '#simulator', label: 'Demo' },
  { href: '#benefits', label: 'Lợi ích' },
  { href: '#stats', label: 'Thống kê' },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const handleProgressScroll = () => {
      const progressBar = document.getElementById('scroll-progress');
      if (progressBar) {
        const scrollTop = window.scrollY;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrollPercent = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
        progressBar.style.width = `${scrollPercent}%`;
      }
    };

    window.addEventListener('scroll', handleProgressScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleProgressScroll);
  }, []);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-500 ${
        scrolled ? 'pt-2' : 'pt-4'
      }`}
    >
      {/* Glass container */}
      <div
        className={`mx-4 md:mx-8 rounded-2xl transition-all duration-500 ${
          scrolled ? 'liquid-glass-nav' : ''
        }`}
      >
        <div className="mx-auto flex h-14 md:h-16 max-w-7xl items-center justify-between px-4 md:px-6">
          {/* Logo */}
          <a href="#" className="flex items-center gap-2 md:gap-3 group">
            <img
              src="/LOGO-EBOX.png"
              alt="E-BOX Logo"
              className="h-10 md:h-12 w-auto object-contain transition-transform duration-300 group-hover:scale-105"
            />
            <div className="hidden sm:block">
              <span className="text-lg md:text-xl font-black text-gray-800">E</span>
              <span className="text-lg md:text-xl font-black gradient-text">-BOX</span>
            </div>
          </a>

          {/* Desktop Navigation */}
          <nav className="hidden items-center gap-1 md:flex">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="nav-link"
              >
                {link.label}
              </a>
            ))}
            
            {/* Download Button - Rounded Liquid Glass */}
            <a
              href={GOOGLE_PLAY_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="ml-2 md:ml-4 nav-button"
            >
              <svg className="h-4 w-4 md:h-5 md:w-5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <defs>
                  <linearGradient id="nav-chplay-g1" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#00C9FF" />
                    <stop offset="100%" stopColor="#0080FF" />
                  </linearGradient>
                  <linearGradient id="nav-chplay-g2" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#FFEE00" />
                    <stop offset="100%" stopColor="#FFA800" />
                  </linearGradient>
                  <linearGradient id="nav-chplay-g3" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#FF4D6D" />
                    <stop offset="100%" stopColor="#FF1A4D" />
                  </linearGradient>
                  <linearGradient id="nav-chplay-g4" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#00E676" />
                    <stop offset="100%" stopColor="#00A152" />
                  </linearGradient>
                </defs>
                <path d="M3.609 1.814L13.792 12 3.61 22.186a1 1 0 01-.61-.916V2.73a1 1 0 01.609-.916z" fill="url(#nav-chplay-g1)" />
                <path d="M13.792 12L3.609 1.814c.197-.132.443-.196.685-.196.243 0 .485.063.682.184l10.13 5.788L13.792 12z" fill="url(#nav-chplay-g4)" />
                <path d="M13.792 12L3.609 22.186c.197.13.44.195.682.195.243 0 .487-.066.682-.195l10.13-5.787L13.792 12z" fill="url(#nav-chplay-g3)" />
                <path d="M20.16 10.13l-2.873-1.643L15.106 12l2.182 3.513 2.873-1.643a1.487 1.487 0 000-2.737z" fill="url(#nav-chplay-g2)" />
              </svg>
              <span className="hidden lg:inline text-sm font-semibold">Tải App</span>
            </a>
          </nav>

          {/* Mobile Menu Button - Rounded Glass */}
          <button
            className="menu-button md:hidden"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Mở menu"
          >
            <div className="relative w-5 h-5">
              <span className={`absolute left-0 h-0.5 w-5 bg-current transition-all duration-300 ${mobileMenuOpen ? 'top-2.5 rotate-45' : 'top-1'}`} />
              <span className={`absolute left-0 top-2.5 h-0.5 w-5 bg-current transition-all duration-300 ${mobileMenuOpen ? 'opacity-0' : ''}`} />
              <span className={`absolute left-0 h-0.5 w-5 bg-current transition-all duration-300 ${mobileMenuOpen ? 'top-2.5 -rotate-45' : 'top-4'}`} />
            </div>
          </button>
        </div>
      </div>

      {/* Mobile Menu - Liquid Glass Overlay */}
      <div
        className={`md:hidden absolute top-full left-0 right-0 transition-all duration-500 ${
          mobileMenuOpen ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4 pointer-events-none'
        }`}
      >
        <div className="mx-4 mt-2 liquid-glass-nav rounded-2xl p-4">
          <div className="flex flex-col gap-1">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                onClick={() => setMobileMenuOpen(false)}
                className="mobile-nav-link"
              >
                {link.label}
              </a>
            ))}
            <div className="mt-3 pt-3 border-t border-white/20">
              <a
                href={GOOGLE_PLAY_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="nav-button w-full justify-center"
              >
                <svg className="h-5 w-5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <defs>
                    <linearGradient id="mobile-chplay-g1" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#00C9FF" />
                      <stop offset="100%" stopColor="#0080FF" />
                    </linearGradient>
                    <linearGradient id="mobile-chplay-g2" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#FFEE00" />
                      <stop offset="100%" stopColor="#FFA800" />
                    </linearGradient>
                    <linearGradient id="mobile-chplay-g3" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#FF4D6D" />
                      <stop offset="100%" stopColor="#FF1A4D" />
                    </linearGradient>
                    <linearGradient id="mobile-chplay-g4" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#00E676" />
                      <stop offset="100%" stopColor="#00A152" />
                    </linearGradient>
                  </defs>
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a1 1 0 01-.61-.916V2.73a1 1 0 01.609-.916z" fill="url(#mobile-chplay-g1)" />
                  <path d="M13.792 12L3.609 1.814c.197-.132.443-.196.685-.196.243 0 .485.063.682.184l10.13 5.788L13.792 12z" fill="url(#mobile-chplay-g4)" />
                  <path d="M13.792 12L3.609 22.186c.197.13.44.195.682.195.243 0 .487-.066.682-.195l10.13-5.787L13.792 12z" fill="url(#mobile-chplay-g3)" />
                  <path d="M20.16 10.13l-2.873-1.643L15.106 12l2.182 3.513 2.873-1.643a1.487 1.487 0 000-2.737z" fill="url(#mobile-chplay-g2)" />
                </svg>
                <span>Tải Ứng Dụng</span>
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll Progress Indicator */}
      <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-gray-200/30">
        <div
          id="scroll-progress"
          className="h-full bg-gradient-to-r from-orange-400 to-orange-500 transition-all duration-150 ease-out"
          style={{ width: '0%' }}
        />
      </div>
    </header>
  );
}
