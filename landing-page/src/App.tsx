import { useEffect } from 'react';
import Navbar from './components/Navbar';
import ParticleBackground from './components/ParticleBackground';
import HeroSection from './components/HeroSection';
import LockerSimulator from './components/LockerSimulator';
import FeaturesSection from './components/FeaturesSection';
import StatisticsSection from './components/StatisticsSection';
import BenefitsSection from './components/BenefitsSection';
import DownloadCTASection from './components/DownloadCTASection';
import Footer from './components/Footer';

export default function App() {
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.querySelectorAll('.scroll-animate').forEach((el, i) => {
              setTimeout(() => {
                el.classList.add('visible');
              }, i * 100);
            });
          }
        });
      },
      { threshold: 0.1 }
    );

    document.querySelectorAll('section').forEach((section) => {
      observer.observe(section);
    });

    return () => observer.disconnect();
  }, []);

  return (
    <div className="min-h-screen bg-cream dark:bg-[#0B1220] font-sans antialiased transition-colors duration-300">
      <ParticleBackground />
      <Navbar />
      <main>
        <HeroSection />
        <LockerSimulator />
        <FeaturesSection />
        <StatisticsSection />
        <BenefitsSection />
        <DownloadCTASection />
      </main>
      <Footer />
    </div>
  );
}
