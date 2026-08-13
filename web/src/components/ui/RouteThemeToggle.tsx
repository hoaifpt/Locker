import { useLocation } from 'react-router-dom';
import ThemeToggle from './ThemeToggle';

const STANDALONE_PUBLIC_ROUTES = [
  '/login',
  '/register',
  '/verify-email',
  '/forgot-password',
  '/reset-password',
];

export default function RouteThemeToggle() {
  const { pathname } = useLocation();
  const shouldDisplay = STANDALONE_PUBLIC_ROUTES.some(
    (route) => pathname === route || pathname.startsWith(`${route}/`),
  );

  if (!shouldDisplay) return null;

  return <ThemeToggle className="fixed right-4 top-4 z-[70] sm:right-6 sm:top-6" />;
}
