import logo from '../../assets/logo/logo.png';

type LogoProps = {
  size?: number;
  showText?: boolean;
  textClassName?: string;
};

export default function Logo({
  size = 72,
  showText = true,
  textClassName = 'text-xl font-bold tracking-tight text-gray-900 dark:text-white',
}: LogoProps) {
  return (
    <span className="flex items-center gap-2">
      <img
        src={logo}
        alt="E-Box"
        width={size}
        height={size}
        className="shrink-0 object-contain"
        style={{ width: size, height: size }}
      />
      {showText && <span className={textClassName}>E-Box</span>}
    </span>
  );
}
