import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Store, ArrowLeft, Star, MapPin, Plus, Minus, ShoppingBag, ChevronRight } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

type Restaurant = {
  id: string;
  name: string;
  description: string;
  address: string;
  imageUrl: string;
  rating: number;
  latitude: number;
  longitude: number;
};

type MenuItem = {
  id: string;
  restaurantId: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: string;
  isAvailable: boolean;
};

export default function RestaurantDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [menu, setMenu] = useState<MenuItem[]>([]);
  const [loading, setLoading] = useState(true);

  // Cart state: { [menuItemId]: quantity }
  const [cart, setCart] = useState<Record<string, number>>({});

  useEffect(() => {
    if (!id) {
      setLoading(false);
      return;
    }

    const fetchDetails = async () => {
      setLoading(true);
      try {
        const [restaurantResponse, menuResponse] = await Promise.all([
          apiFetch(`/restaurants/${id}`),
          apiFetch(`/restaurants/${id}/menu`),
        ]);

        if (!restaurantResponse.ok) throw new Error('Không thể tải thông tin nhà hàng.');
        if (!menuResponse.ok) throw new Error('Không thể tải thực đơn.');

        const restaurantData = (await restaurantResponse.json()) as Restaurant;
        const menuData = (await menuResponse.json()) as MenuItem[];

        setRestaurant(restaurantData);
        setMenu(menuData);
      } catch (error) {
        showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
        navigate('/food', { replace: true });
      } finally {
        setLoading(false);
      }
    };

    fetchDetails();
  }, [id, navigate, showToast]);

  const updateCart = (itemId: string, delta: number) => {
    setCart(prev => {
      const current = prev[itemId] || 0;
      const next = Math.max(0, current + delta);
      const newCart = { ...prev };
      if (next === 0) delete newCart[itemId];
      else newCart[itemId] = next;
      return newCart;
    });
  };

  const totalItems = Object.values(cart).reduce((a, b) => a + b, 0);
  const totalPrice = Object.entries(cart).reduce((total, [itemId, qty]) => {
    const item = menu.find(m => m.id === itemId);
    return total + (item ? item.price * qty : 0);
  }, 0);

  const handleCheckout = () => {
    if (totalItems === 0 || !restaurant) return;
    const cartItems = Object.entries(cart).map(([itemId, qty]) => {
      const item = menu.find(m => m.id === itemId)!;
      return { ...item, quantity: qty };
    });
    navigate('/food/checkout', { state: { restaurant, cartItems, totalPrice } });
  };

  if (loading) return (
    <div className="min-h-screen bg-[#F9F8F6]">
      <AppHeader />
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    </div>
  );

  if (!restaurant) return null;

  // Group menu by category
  const categories = Array.from(new Set(menu.map(m => m.category)));

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased pb-32">
      <AppHeader />

      {/* Restaurant Banner */}
      <div className="relative h-64 md:h-80 w-full overflow-hidden bg-gray-900">
        <img
          src={restaurant.imageUrl}
          alt={restaurant.name}
          className="h-full w-full object-cover opacity-60"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
        <div className="absolute bottom-0 w-full p-6 lg:px-8 max-w-5xl mx-auto text-white">
          <Link to="/food" className="mb-4 inline-flex items-center gap-1.5 text-sm font-medium text-gray-300 hover:text-white">
            <ArrowLeft size={15} /> Quay lại
          </Link>
          <div className="flex flex-col md:flex-row md:items-end gap-4 justify-between">
            <div>
              <span className="inline-flex items-center gap-1.5 rounded-full bg-orange-500 px-3 py-1 text-xs font-bold shadow-sm mb-2">
                <Store size={12} /> Tủ khoá giao nhận
              </span>
              <h1 className="text-3xl md:text-4xl font-extrabold tracking-tight">{restaurant.name}</h1>
              <p className="mt-2 text-sm text-gray-200 line-clamp-2 max-w-2xl">{restaurant.description}</p>
            </div>
            <div className="flex flex-col gap-2 text-sm text-gray-200">
              <span className="flex items-center gap-1.5 bg-black/30 rounded-xl px-3 py-1.5 backdrop-blur-sm">
                <Star size={14} className="text-yellow-400 fill-yellow-400" /> {restaurant.rating.toFixed(1)}
              </span>
              <span className="flex items-center gap-1.5 bg-black/30 rounded-xl px-3 py-1.5 backdrop-blur-sm">
                <MapPin size={14} /> {restaurant.address}
              </span>
            </div>
          </div>
        </div>
      </div>

      <main className="mx-auto max-w-5xl px-4 py-8 lg:px-8">
        {/* Menu Items */}
        <div className="space-y-10">
          {categories.map((category, catIndex) => {
            const items = menu.filter(m => m.category === category);
            return (
              <motion.div key={category} initial={hidden} animate={visible} transition={trans(0.1 + catIndex * 0.1)}>
                <h2 className="mb-4 text-xl font-bold text-gray-900 border-b border-gray-200 pb-2">{category}</h2>
                <div className="grid gap-4 md:grid-cols-2">
                  {items.map((item) => (
                    <div key={item.id} className="flex gap-4 rounded-3xl border border-gray-100 bg-white p-4 shadow-sm transition hover:shadow-md hover:border-orange-200">
                      <div className="h-24 w-24 shrink-0 overflow-hidden rounded-2xl bg-gray-100">
                        <img src={item.imageUrl} alt={item.name} className="h-full w-full object-cover" />
                      </div>
                      <div className="flex flex-1 flex-col justify-between">
                        <div>
                          <h3 className="font-bold text-gray-900">{item.name}</h3>
                          <p className="mt-1 text-xs text-gray-500 line-clamp-2">{item.description}</p>
                        </div>
                        <div className="flex items-center justify-between mt-2">
                          <span className="font-semibold text-orange-600">{item.price.toLocaleString('vi-VN')}đ</span>

                          {/* Add to cart controls */}
                          <div className="flex items-center gap-3 rounded-full bg-gray-50 p-1 border border-gray-100 shadow-inner">
                            <button
                              onClick={() => updateCart(item.id, -1)}
                              className={`flex h-7 w-7 items-center justify-center rounded-full transition ${cart[item.id] ? 'bg-white text-gray-700 shadow-sm hover:bg-gray-200' : 'text-gray-300'}`}
                              disabled={!cart[item.id]}
                            >
                              <Minus size={14} />
                            </button>
                            <span className="w-4 text-center text-sm font-semibold text-gray-900">
                              {cart[item.id] || 0}
                            </span>
                            <button
                              onClick={() => updateCart(item.id, 1)}
                              className="flex h-7 w-7 items-center justify-center rounded-full bg-orange-500 text-white shadow-sm transition hover:bg-orange-600"
                            >
                              <Plus size={14} />
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </motion.div>
            );
          })}
        </div>
      </main>

      {/* Floating Cart Bar */}
      <AnimatePresence>
        {totalItems > 0 && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            className="fixed bottom-0 left-0 right-0 z-40 bg-white border-t border-gray-200 shadow-[0_-10px_40px_rgba(0,0,0,0.1)] p-4"
          >
            <div className="mx-auto max-w-5xl flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="relative flex h-12 w-12 items-center justify-center rounded-2xl bg-orange-100 text-orange-500">
                  <ShoppingBag size={24} />
                  <span className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white shadow-sm">
                    {totalItems}
                  </span>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Tổng cộng</p>
                  <p className="text-lg font-bold text-gray-900">{totalPrice.toLocaleString('vi-VN')}đ</p>
                </div>
              </div>

              <button
                onClick={handleCheckout}
                className="flex items-center gap-2 rounded-xl bg-orange-500 px-6 py-3.5 font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 active:scale-95"
              >
                Giao đến Tủ khoá <ChevronRight size={18} />
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
