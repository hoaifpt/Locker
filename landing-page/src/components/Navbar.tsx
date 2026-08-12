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
        scrolled ? 'pt-1 md:pt-2' : 'pt-2 md:pt-4'
      }`}
    >
      {/* Glass container */}
      <div
        className={`mx-3 sm:mx-4 md:mx-8 rounded-2xl transition-all duration-500 ${
          scrolled ? 'liquid-glass-nav' : ''
        }`}
      >
        <div className="mx-auto flex h-12 sm:h-14 md:h-16 max-w-7xl items-center justify-between px-3 sm:px-4 md:px-6">
          {/* Logo */}
          <a href="#" className="flex items-center gap-2 md:gap-3 group">
            <img
              src="/LOGO-EBOX.png"
              alt="E-BOX Logo"
              className="h-7 sm:h-12 md:h-16 w-auto object-contain transition-transform duration-300 group-hover:scale-105"
            />
            <div className="block">
              <span className="text-lg sm:text-xl md:text-2xl font-black text-gray-800">E</span>
              <span className="text-lg sm:text-xl md:text-2xl font-black gradient-text">-BOX</span>
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
              {/* Android Robot Icon */}
              <svg className="h-4 w-4 md:h-5 md:w-5" viewBox="0 0 24 24" fill="#3DDC84" xmlns="http://www.w3.org/2000/svg">
                {/* Antenna left */}
                <path d="M7 3L9.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                {/* Antenna right */}
                <path d="M17 3L14.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                {/* Head - half circle */}
                <path d="M2.5 15.5C2.5 9.7 6.7 5 12 5C17.3 5 21.5 9.7 21.5 15.5V21H2.5V15.5Z" fill="#3DDC84"/>
                {/* Left eye */}
                <circle cx="8.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
                {/* Right eye */}
                <circle cx="15.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
              </svg>
              <span className="hidden lg:inline text-sm font-semibold">Tải APK</span>
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
                {/* Android Robot Icon */}
                <svg className="h-5 w-5" viewBox="0 0 24 24" fill="#3DDC84" xmlns="http://www.w3.org/2000/svg">
                  {/* Antenna left */}
                  <path d="M7 3L9.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                  {/* Antenna right */}
                  <path d="M17 3L14.5 7" stroke="#3DDC84" strokeWidth="1.8" strokeLinecap="round"/>
                  {/* Head - half circle */}
                  <path d="M2.5 15.5C2.5 9.7 6.7 5 12 5C17.3 5 21.5 9.7 21.5 15.5V21H2.5V15.5Z" fill="#3DDC84"/>
                  {/* Left eye */}
                  <circle cx="8.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
                  {/* Right eye */}
                  <circle cx="15.5" cy="12.5" r="1.4" fill="#FFFFFF"/>
                </svg>
                <span>Tải APK</span>
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
