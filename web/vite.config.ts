import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    server: {
        proxy: {
            // Chuyển tiếp tất cả các yêu cầu bắt đầu bằng '/api' đến server backend
            '/api': {
                target: 'https://api.hoaitran.online',
                changeOrigin: true,
            },
        },
    },
});