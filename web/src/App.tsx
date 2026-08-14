import { BrowserRouter } from 'react-router-dom';
import { SettingsProvider } from './context/SettingsContext';
import { ToastProvider } from './context/ToastContext';
import { ThemeProvider } from './context/ThemeContext';
import RouteThemeToggle from './components/ui/RouteThemeToggle';
import AppRoutes from './routes';

export default function App() {
  return (
    <ThemeProvider>
      <SettingsProvider>
        <BrowserRouter>
          <ToastProvider>
            <RouteThemeToggle />
            <AppRoutes />
          </ToastProvider>
        </BrowserRouter>
      </SettingsProvider>
    </ThemeProvider>
  );
}
