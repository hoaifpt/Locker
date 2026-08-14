import { BrowserRouter } from 'react-router-dom';
import { SettingsProvider } from './context/SettingsContext';
import { ToastProvider } from './context/ToastContext';
import { ThemeProvider } from './context/ThemeContext';
import { NotificationsProvider } from './features/notifications/context/NotificationsContext';
import RouteThemeToggle from './components/ui/RouteThemeToggle';
import AppRoutes from './routes';

export default function App() {
  return (
    <ThemeProvider>
      <SettingsProvider>
        <BrowserRouter>
          <ToastProvider>
            <NotificationsProvider>
              <RouteThemeToggle />
              <AppRoutes />
            </NotificationsProvider>
          </ToastProvider>
        </BrowserRouter>
      </SettingsProvider>
    </ThemeProvider>
  );
}
