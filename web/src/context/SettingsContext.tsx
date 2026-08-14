import { createContext, ReactNode, useCallback, useContext, useEffect, useLayoutEffect, useMemo, useState } from 'react';
import { useTheme } from './ThemeContext';

export type FontSize = 'normal' | 'easy-read';

export interface NotificationSettings {
  sound: boolean;
  vibration: boolean;
  orderUpdates: boolean;
  deliveryUpdates: boolean;
  promotions: boolean;
}

export interface Settings {
  fontSize: FontSize;
  notifications: NotificationSettings;
}

interface SettingsContextValue {
  settings: Settings;
  setFontSize: (size: FontSize) => void;
  updateNotifications: (updates: Partial<NotificationSettings>) => void;
}

const SETTINGS_KEY = 'e-box-settings';

const DEFAULT_SETTINGS: Settings = {
  fontSize: 'normal',
  notifications: {
    sound: true,
    vibration: true,
    orderUpdates: true,
    deliveryUpdates: true,
    promotions: false,
  },
};

const FONT_SCALE_MAP: Record<FontSize, number> = {
  normal: 1,
  'easy-read': 1.25,
};

const SettingsContext = createContext<SettingsContextValue | undefined>(undefined);

function loadSettings(): Settings {
  try {
    const saved = localStorage.getItem(SETTINGS_KEY);
    if (saved) {
      const parsed = JSON.parse(saved);
      return {
        fontSize: parsed.fontSize === 'easy-read' ? 'easy-read' : 'normal',
        notifications: {
          sound: parsed.notifications?.sound ?? true,
          vibration: parsed.notifications?.vibration ?? true,
          orderUpdates: parsed.notifications?.orderUpdates ?? true,
          deliveryUpdates: parsed.notifications?.deliveryUpdates ?? true,
          promotions: parsed.notifications?.promotions ?? false,
        },
      };
    }
  } catch {
    // Use defaults on parse error.
  }
  return DEFAULT_SETTINGS;
}

export function SettingsProvider({ children }: { children: ReactNode }) {
  const [settings, setSettings] = useState<Settings>(loadSettings);
  const { theme } = useTheme();

  const setFontSize = useCallback((size: FontSize) => {
    setSettings((prev) => {
      const next = { ...prev, fontSize: size };
      try {
        localStorage.setItem(SETTINGS_KEY, JSON.stringify(next));
      } catch {
        // Session-only when storage is unavailable.
      }
      return next;
    });
  }, []);

  const updateNotifications = useCallback((updates: Partial<NotificationSettings>) => {
    setSettings((prev) => {
      const next = {
        ...prev,
        notifications: { ...prev.notifications, ...updates },
      };
      try {
        localStorage.setItem(SETTINGS_KEY, JSON.stringify(next));
      } catch {
        // Session-only when storage is unavailable.
      }
      return next;
    });
  }, []);

  useLayoutEffect(() => {
    const root = document.documentElement;
    root.style.setProperty('--font-scale', String(FONT_SCALE_MAP[settings.fontSize]));
  }, [settings.fontSize]);

  useEffect(() => {
    const syncSettings = (event: StorageEvent) => {
      if (event.key === SETTINGS_KEY && event.newValue) {
        try {
          const parsed = JSON.parse(event.newValue);
          setSettings({
            fontSize: parsed.fontSize === 'easy-read' ? 'easy-read' : 'normal',
            notifications: {
              sound: parsed.notifications?.sound ?? true,
              vibration: parsed.notifications?.vibration ?? true,
              orderUpdates: parsed.notifications?.orderUpdates ?? true,
              deliveryUpdates: parsed.notifications?.deliveryUpdates ?? true,
              promotions: parsed.notifications?.promotions ?? false,
            },
          });
        } catch {
          // Ignore sync errors.
        }
      }
    };

    window.addEventListener('storage', syncSettings);
    return () => window.removeEventListener('storage', syncSettings);
  }, []);

  const value = useMemo<SettingsContextValue>(
    () => ({
      settings,
      setFontSize,
      updateNotifications,
    }),
    [settings, setFontSize, updateNotifications],
  );

  return <SettingsContext.Provider value={value}>{children}</SettingsContext.Provider>;
}

export function useSettings(): SettingsContextValue {
  const context = useContext(SettingsContext);
  if (!context) throw new Error('useSettings must be used within SettingsProvider.');
  return context;
}
