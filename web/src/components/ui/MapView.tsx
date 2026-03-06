import { LockerDto } from '../../types';

interface MapViewProps {
    locker: LockerDto;
    height?: string;
}

export default function MapView({ locker, height = '400px' }: MapViewProps) {
    // Open locker location in Google Maps
    const handleOpenInMaps = () => {
        const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${locker.latitude},${locker.longitude}&query_place_id=${locker.id}`;
        window.open(mapsUrl, '_blank');
    };

    // Google Maps Embed API URL
    const mapsEmbedUrl = `https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3919.3${locker.id}!2d${locker.longitude}!3d${locker.latitude}!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2z${locker.latitude},${locker.longitude}`;

    return (
        <div className="space-y-4">
            <div className="rounded-lg border border-gray-200 overflow-hidden" style={{ height }}>
                <iframe
                    width="100%"
                    height="100%"
                    frameBorder="0"
                    src={`https://www.google.com/maps?q=${locker.latitude},${locker.longitude}&z=16&output=embed`}
                    title={`${locker.name} location map`}
                    allowFullScreen
                    loading="lazy"
                    referrerPolicy="no-referrer-when-downgrade"
                />
            </div>

            <button
                onClick={handleOpenInMaps}
                className="w-full inline-flex items-center justify-center gap-2 rounded-lg bg-orange-500 px-4 py-3 font-medium text-white transition hover:bg-orange-600"
            >
                📍 Mở trong Google Maps
            </button>

            {/* Location details */}
            <div className="rounded-lg bg-gray-50 p-4 space-y-2">
                <div className="text-sm">
                    <p className="text-gray-600">Địa điểm:</p>
                    <p className="font-semibold text-gray-900">{locker.location}</p>
                </div>
                <div className="text-sm">
                    <p className="text-gray-600">Tọa độ:</p>
                    <p className="font-semibold text-gray-900">
                        {locker.latitude.toFixed(4)}, {locker.longitude.toFixed(4)}
                    </p>
                </div>
            </div>
        </div>
    );
}
