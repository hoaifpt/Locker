import { LockerDto } from '../../types';
import MapPin from 'lucide-react/dist/icons/map-pin';

interface LockersMapGridProps {
    lockers: LockerDto[];
    onLockerSelect?: (locker: LockerDto) => void;
    selectedLockerId?: string;
}

export default function LockersMapGrid({
    lockers,
    onLockerSelect = () => { },
    selectedLockerId,
}: LockersMapGridProps) {
    // Group lockers by city
    const lockersByCity = lockers.reduce(
        (acc, locker) => {
            const city = locker.location.includes('Hà Nội') ? 'Hà Nội' : 'TP.HCM';
            if (!acc[city]) acc[city] = [];
            acc[city].push(locker);
            return acc;
        },
        {} as Record<string, LockerDto[]>
    );

    const calculateDistance = (lat: number, lng: number) => {
        // Return a placeholder distance in km (in real app, use user location)
        return Math.random() * 15 + 1;
    };

    return (
        <div className="space-y-8">
            {Object.entries(lockersByCity).map(([city, cityLockers]) => (
                <div key={city} className="space-y-4">
                    <div className="flex items-center gap-2">
                        <h3 className="text-lg font-semibold text-gray-900">{city}</h3>
                        <span className="inline-flex items-center rounded-full bg-orange-100 px-3 py-0.5 text-sm font-medium text-orange-700">
                            {cityLockers.length} tủ khóa
                        </span>
                    </div>

                    <div className="grid gap-4 md:grid-cols-2">
                        {cityLockers.map((locker) => (
                            <button
                                key={locker.id}
                                onClick={() => onLockerSelect(locker)}
                                className={`rounded-lg border-2 p-4 text-left transition ${selectedLockerId === locker.id
                                        ? 'border-orange-500 bg-orange-50'
                                        : 'border-gray-200 bg-white hover:border-orange-300'
                                    }`}
                            >
                                <div className="space-y-2">
                                    {/* Locker name */}
                                    <p className="font-semibold text-gray-900">{locker.name}</p>

                                    {/* Location with distance */}
                                    <div className="flex items-start gap-2">
                                        <MapPin className="mt-1 h-4 w-4 flex-shrink-0 text-gray-500" />
                                        <div className="text-sm text-gray-600">
                                            <p>{locker.location}</p>
                                            <p className="text-xs text-gray-500">
                                                {calculateDistance(locker.latitude, locker.longitude).toFixed(1)} km từ bạn
                                            </p>
                                        </div>
                                    </div>

                                    {/* Available slots */}
                                    <div className="flex items-center gap-2">
                                        <div className="aspect-square w-6 rounded bg-green-100 flex items-center justify-center text-xs font-semibold text-green-700">
                                            {locker.slots.filter((s) => s.status === 'Available').length}
                                        </div>
                                        <p className="text-xs text-gray-600">
                                            Chỗ trống / {locker.slots.length} chỗ
                                        </p>
                                    </div>

                                    {/* View on map button */}
                                    <a
                                        href={`https://www.google.com/maps/search/?api=1&query=${locker.latitude},${locker.longitude}`}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="mt-2 inline-flex text-xs font-medium text-orange-600 hover:text-orange-700"
                                    >
                                        Xem trên bản đồ →
                                    </a>
                                </div>
                            </button>
                        ))}
                    </div>
                </div>
            ))}
        </div>
    );
}
