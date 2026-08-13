import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    server: {
        proxy: {
            // Chuyển tiếp tất cả các yêu cầu bắt đầu bằng '/api' đến server backend
            '/api': {
                target: 'http://localhost:5000',
                changeOrigin: true,
            },
            // SignalR hub: phải proxy thủ công vì path không bắt đầu bằng '/api'
            '/hubs': {
                target: 'http://localhost:5000',
                changeOrigin: true,
                ws: true,
            },
        },
    },
});