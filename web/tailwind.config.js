/** @type {import('tailwindcss').Config} */
export default {
    darkMode: "class",
    content: ["./index.html", "./src/**/*.{ts,tsx}"],
    theme: {
        extend: {
            keyframes: {
                'inline-alert-shake': {
                    '0%, 100%': { transform: 'translateX(0)' },
                    '15%': { transform: 'translateX(-6px)' },
                    '30%': { transform: 'translateX(6px)' },
                    '45%': { transform: 'translateX(-5px)' },
                    '60%': { transform: 'translateX(5px)' },
                    '75%': { transform: 'translateX(-2px)' },
                },
            },
            animation: {
                'inline-alert-shake': 'inline-alert-shake 0.6s ease-in-out',
            },
        }
    },
    plugins: []
};
