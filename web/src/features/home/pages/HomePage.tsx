import Navbar from '../components/Navbar';
import HeroSection from '../components/HeroSection';
import PortalSection from '../components/PortalSection';
import LocationsSection from '../components/LocationsSection';
import Footer from '../components/Footer';

export default function HomePage() {
  return (
    <div className="font-sans antialiased">
      <Navbar />
      <HeroSection />
      <PortalSection />
      <LocationsSection />
      <Footer />
    </div>
  );
}
