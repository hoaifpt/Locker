# E-Box Logo Integration Design

## Goal
Thay các "logo placeholder" hiện tại (icon `Lock` trong box cam + chữ "E-Box") bằng logo chính thức của dự án (hình tròn nền cam với chữ "E" trắng bên trong) tại 4 vị trí branding, theo cách nhất quán, dễ bảo trì và hỗ trợ light/dark mode.

## Scope
- 2 file SVG asset: `logo-light.svg`, `logo-dark.svg`
- 1 component React: `<Logo />` ở `components/ui/`
- Cập nhật 4 vị trí sử dụng:
  - `web/src/features/home/components/Navbar.tsx` (landing header)
  - `web/src/components/layout/AppHeader.tsx` (in-app header)
  - `web/src/features/admin/components/AdminSidebar.tsx` (admin sidebar)
  - `web/src/features/home/components/Footer.tsx` (landing footer)

## Asset Design

### `logo-light.svg` (nền sáng)
- viewBox `0 0 64 64`
- Khung: `<rect x=0 y=0 width=64 height=64 rx=16 fill="url(#g)"/>` với gradient cam `#FB923C → #EA580C`
- Chữ "E" trắng, font-weight bold, kích thước lớn (~40), căn giữa

### `logo-dark.svg` (nền tối)
- Cùng thiết kế nhưng gradient cam ấm hơn `#FB923C → #C2410C` để nổi bật trên nền dark

## Component: `<Logo />`

```ts
type LogoProps = {
  size?: number;          // default 32
  showText?: boolean;     // default true; hiển thị chữ "E-Box" cạnh logo
  textClassName?: string; // optional override cho style chữ
  variant?: 'light' | 'dark'; // default: auto-detect từ <html class="dark">
}
```

- Auto-detect dark mode bằng `useEffect` đọc `document.documentElement.classList.contains('dark')`.
- Lắng nghe sự kiện đổi theme (qua custom event `themechange` nếu `ThemeToggle` đã dispatch, hoặc `MutationObserver` trên `<html>` class).
- Khi `showText=true`: render `<img src={...} />` + `<span>E-Box</span>`.
- Khi `showText=false`: chỉ render `<img>` (dùng cho favicon, avatar nếu sau này cần).

## Placement Details

### Navbar (landing, light mode chủ đạo)
- Bỏ icon `Lock`, thay bằng `<Logo size={32} showText variant="light" />`
- Giữ text class: `text-xl font-bold tracking-tight text-gray-900 dark:text-white`

### AppHeader (in-app, có dark mode)
- `<Logo size={32} showText />` (variant auto)
- Giữ text class tương tự Navbar

### AdminSidebar
- `<Logo size={36} showText />`
- Sau logo vẫn giữ cấu trúc 2 dòng: "E-Box Admin" + "Quản trị hệ thống"
  → chỉ thay icon, giữ phần text bên phải

### Footer (dark background `#0F172A`)
- `<Logo size={32} showText variant="dark" />`
- Đổi text color thành `text-white`

## Không thay đổi
- Routing
- Layout
- Hover/active states
- ThemeToggle component
- Màu sắc gradient cam hiện có

## Out of Scope
- Favicon / PWA icon (có thể làm sau nếu cần)
- Animated logo
- Logo trong email templates
