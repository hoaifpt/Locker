import { GOOGLE_PLAY_URL } from '../lib/constants';

export default function GooglePlayButton() {
  return (
    <a
      href={GOOGLE_PLAY_URL}
      target="_blank"
      rel="noopener noreferrer"
      className="glass-btn-google group inline-flex items-center gap-3"
    >
      {/* Google Play icon */}
      <svg className="h-8 w-8 flex-shrink-0" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="gp-grad-1" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#00C9FF" />
            <stop offset="100%" stopColor="#0080FF" />
          </linearGradient>
          <linearGradient id="gp-grad-2" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#FFEE00" />
            <stop offset="100%" stopColor="#FFA800" />
          </linearGradient>
          <linearGradient id="gp-grad-3" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#FF4D6D" />
            <stop offset="100%" stopColor="#FF1A4D" />
          </linearGradient>
          <linearGradient id="gp-grad-4" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#00E676" />
            <stop offset="100%" stopColor="#00A152" />
          </linearGradient>
        </defs>
        <path d="M3.609 1.814L13.792 12 3.61 22.186a1 1 0 01-.61-.916V2.73a1 1 0 01.609-.916z" fill="url(#gp-grad-1)" />
        <path d="M13.792 12L3.609 1.814c.197-.132.443-.196.685-.196.243 0 .485.063.682.184l10.13 5.788L13.792 12z" fill="url(#gp-grad-4)" />
        <path d="M13.792 12L3.609 22.186c.197.13.44.195.682.195.243 0 .487-.066.682-.195l10.13-5.787L13.792 12z" fill="url(#gp-grad-3)" />
        <path d="M20.16 10.13l-2.873-1.643L15.106 12l2.182 3.513 2.873-1.643a1.487 1.487 0 000-2.737z" fill="url(#gp-grad-2)" />
      </svg>
      <div className="text-left leading-tight">
        <div className="text-[10px] font-medium uppercase tracking-wider opacity-90">
          Tải xuống trên
        </div>
        <div className="text-xl font-semibold tracking-tight">
          Google Play
        </div>
      </div>
    </a>
  );
}
