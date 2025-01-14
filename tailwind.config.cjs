/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/frontend/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'cyber': {
          'neon': '#00ff9f',
          'blue': '#01cdfe',
          'pink': '#ff71ce',
          'purple': '#b967ff',
        },
      },
    },
  },
  plugins: [],
}