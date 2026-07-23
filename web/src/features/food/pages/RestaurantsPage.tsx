import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Store, Search, Star, MapPin } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { SEED_RESTAURANTS, SeedRestaurant } from '../../../mocks/seed';

export default function RestaurantsPage() {
  const [restaurants, setRestaurants] = useState<SeedRestaurant[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    // Simulate API fetch
    setTimeout(() => {
      setRestaurants(SEED_RESTAURANTS);
      setLoading(false);
    }, 400);
  }, []);

  const filteredRestaurants = restaurants.filter(r => 
    r.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    r.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      
      <main className="mx-auto max-w-5xl px-4 py-10 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            <Store size={13} /> Khám phá
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Giao đồ ăn đến <span className="text-orange-500">Tủ khóa</span>
          </h1>
          <p className="mt-2 text-sm text-gray-500">
            Đặt món ngon từ các nhà hàng yêu thích và nhận ngay tại tủ khóa E-Box của bạn.
          </p>
          
          {/* Current Location Banner */}
          <div className="mt-6 flex items-center justify-between rounded-2xl bg-orange-500/10 px-4 py-3 border border-orange-500/20 max-w-fit">
            <div className="flex items-center gap-2">
              <span className="flex h-8 w-8 items-center justify-center rounded-full bg-orange-500 text-white">
                <MapPin size={16} />
              </span>
              <div>
                <p className="text-xs font-semibold text-orange-600">Vị trí giao hàng của bạn</p>
                <p className="text-sm font-bold text-gray-900">Tòa nhà FPT, Quận 9, TP.HCM</p>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Search bar & Sort */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="relative w-full max-w-md">
            <span className="absolute inset-y-0 left-4 flex items-center text-gray-400">
              <Search size={18} />
            </span>
            <input
              type="text"
              placeholder="Tìm nhà hàng, món ăn..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full rounded-2xl border border-gray-200 bg-white py-3.5 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:ring-2 focus:ring-orange-100 shadow-sm"
            />
          </div>
          <div className="w-full sm:w-auto">
            <select className="w-full sm:w-auto rounded-xl border border-gray-200 bg-white py-3 px-4 text-sm font-medium text-gray-700 outline-none hover:bg-gray-50">
              <option value="nearest">Gần tôi nhất</option>
              <option value="rating">Đánh giá cao</option>
            </select>
          </div>
        </motion.div>

        {/* List of restaurants */}
        {loading ? (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {[1, 2, 3].map(i => (
              <div key={i} className="h-64 rounded-3xl bg-gray-200 animate-pulse" />
            ))}
          </div>
        ) : filteredRestaurants.length === 0 ? (
          <div className="rounded-3xl border bg-white py-16 text-center shadow-sm">
            <Store size={48} className="mx-auto mb-4 text-gray-300" />
            <h3 className="text-lg font-bold text-gray-900">Không tìm thấy nhà hàng</h3>
            <p className="mt-1 text-sm text-gray-500">Vui lòng thử từ khóa khác.</p>
          </div>
        ) : (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {filteredRestaurants.map((restaurant, index) => (
              <motion.div 
                key={restaurant.id} 
                initial={hidden} 
                animate={visible} 
                transition={trans(0.1 + index * 0.05)}
              >
                <Link to={`/food/${restaurant.id}`} className="group block overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm transition hover:shadow-md hover:border-orange-200">
                  <div className="relative h-48 overflow-hidden bg-gray-100">
                    <img 
                      src={restaurant.imageUrl} 
                      alt={restaurant.name}
                      className="h-full w-full object-cover transition duration-300 group-hover:scale-105"
                    />
                    <div className="absolute top-3 right-3 flex items-center gap-1 rounded-full bg-white/90 px-2.5 py-1 text-xs font-bold text-gray-900 backdrop-blur-sm shadow-sm">
                      <Star size={13} className="text-yellow-400 fill-yellow-400" />
                      {restaurant.rating}
                    </div>
                  </div>
                  <div className="p-5">
                    <h3 className="font-bold text-lg text-gray-900 transition group-hover:text-orange-500 line-clamp-1">{restaurant.name}</h3>
                    <p className="mt-1 text-sm text-gray-500 line-clamp-1">{restaurant.description}</p>
                    
                    <div className="mt-4 flex items-center justify-between">
                      <div className="flex items-center gap-1.5 text-xs text-gray-400">
                        <MapPin size={14} className="text-gray-400" />
                        <span className="line-clamp-1">{restaurant.address}</span>
                      </div>
                      <div className="rounded-full bg-gray-100 px-2 py-1 text-[10px] font-bold text-gray-600 whitespace-nowrap">
                        {restaurant.distanceKm} km
                      </div>
                    </div>
                  </div>
                </Link>
              </motion.div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
