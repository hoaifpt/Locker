import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Search, Plus, Edit2, Trash2, ChevronLeft, ChevronRight, X, UserPlus, ShieldCheck } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

type AdminUser = {
  id: string;
  username: string;
  email: string;
  fullName: string | null;
  phoneNumber: string | null;
  role: string;
  isActive: boolean;
  createdAt: string;
};

type UserForm = {
  username: string;
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role: 'User' | 'Shipper' | 'Admin';
};

const ROLES = ['User', 'Shipper', 'Admin'] as const;
const PAGE_SIZE = 10;

export default function AdminUsersPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterRole, setFilterRole] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [page, setPage] = useState(1);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [editingUser, setEditingUser] = useState<AdminUser | null>(null);
  const { show: showToast } = useToast();

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await apiFetch('/admin/users');
      if (!res.ok) throw new Error('Không thể tải danh sách users.');
      const data = await res.json() as AdminUser[];
      setUsers(data);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // Filter & paginate
  const filtered = users.filter(u => {
    const matchSearch = !search ||
      u.username.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      (u.fullName?.toLowerCase() ?? '').includes(search.toLowerCase());
    const matchRole = filterRole === 'all' || u.role === filterRole;
    const matchStatus = filterStatus === 'all' ||
      (filterStatus === 'active' && u.isActive) ||
      (filterStatus === 'inactive' && !u.isActive);
    return matchSearch && matchRole && matchStatus;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleDelete = async (id: string) => {
    try {
      const res = await apiFetch(`/admin/users/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error('Không thể xóa user.');
      setUsers(prev => prev.filter(u => u.id !== id));
      showToast('Đã xóa người dùng thành công.', 'success');
      setDeleteConfirm(null);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    }
  };

  const handleToggleActive = async (user: AdminUser) => {
    const endpoint = user.isActive
      ? `/admin/users/${user.id}/deactivate`
      : `/admin/users/${user.id}/activate`;
    try {
      const res = await apiFetch(endpoint, { method: 'PUT' });
      if (!res.ok) throw new Error('Không thể cập nhật trạng thái.');
      setUsers(prev => prev.map(u => u.id === user.id ? { ...u, isActive: !u.isActive } : u));
      showToast(`Đã ${user.isActive ? 'vô hiệu hóa' : 'kích hoạt'} tài khoản.`, 'success');
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    }
  };

  return (
    <div className="flex min-h-screen bg-[#F9F8F6]">
      <AdminSidebar />
      <main className="ml-64 flex-1 px-8 py-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-extrabold tracking-tight text-gray-900">Quản lý Users</h1>
            <p className="mt-1 text-sm text-gray-500">Tổng cộng {users.length} người dùng</p>
          </div>
          <button
            onClick={() => { setEditingUser(null); setModalOpen(true); }}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-orange-500 to-orange-600 px-5 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200/50 transition hover:from-orange-600 hover:to-orange-700"
          >
            <UserPlus size={18} />
            Thêm User mới
          </button>
        </motion.div>

        {/* Filters */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 flex flex-wrap items-center gap-4">
          {/* Search */}
          <div className="relative flex-1 min-w-[240px]">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm kiếm username, email, tên..."
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              className="w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
            />
          </div>

          {/* Role Filter */}
          <select
            value={filterRole}
            onChange={e => { setFilterRole(e.target.value); setPage(1); }}
            className="rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none"
          >
            <option value="all">Tất cả vai trò</option>
            {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
          </select>

          {/* Status Filter */}
          <select
            value={filterStatus}
            onChange={e => { setFilterStatus(e.target.value); setPage(1); }}
            className="rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none"
          >
            <option value="all">Tất cả trạng thái</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </select>
        </motion.div>

        {/* Table */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mt-6 overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead className="border-b border-gray-100 bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Tên</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Email</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Vai trò</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Trạng thái</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Ngày tạo</th>
                <th className="px-4 py-3 text-right font-semibold text-gray-600">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b border-gray-50">
                    {[...Array(6)].map((_, j) => (
                      <td key={j} className="px-4 py-3"><div className="h-4 w-full animate-pulse rounded bg-gray-200" /></td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-12 text-center text-gray-400">Không tìm thấy người dùng nào</td>
                </tr>
              ) : (
                paginated.map(u => (
                  <tr key={u.id} className="border-b border-gray-50 transition hover:bg-orange-50/30">
                    <td className="px-4 py-3 font-medium text-gray-900">{u.fullName ?? u.username}</td>
                    <td className="px-4 py-3 text-gray-500">{u.email}</td>
                    <td className="px-4 py-3">
                      <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                        u.role === 'Admin' ? 'bg-purple-100 text-purple-600' :
                        u.role === 'Shipper' ? 'bg-blue-100 text-blue-600' :
                        'bg-gray-100 text-gray-600'
                      }`}>{u.role}</span>
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => handleToggleActive(u)}
                        className={`rounded-full px-2 py-0.5 text-xs font-semibold transition ${
                          u.isActive
                            ? 'bg-green-100 text-green-600 hover:bg-green-200'
                            : 'bg-red-100 text-red-500 hover:bg-red-200'
                        }`}
                      >
                        {u.isActive ? 'Active' : 'Inactive'}
                      </button>
                    </td>
                    <td className="px-4 py-3 text-gray-500">{new Date(u.createdAt).toLocaleDateString('vi-VN')}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => { setEditingUser(u); setModalOpen(true); }}
                          className="rounded-lg p-2 text-gray-400 transition hover:bg-blue-50 hover:text-blue-500"
                          title="Sửa"
                        >
                          <Edit2 size={16} />
                        </button>
                        <button
                          onClick={() => setDeleteConfirm(u.id)}
                          className="rounded-lg p-2 text-gray-400 transition hover:bg-red-50 hover:text-red-500"
                          title="Xóa"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </motion.div>

        {/* Pagination */}
        {!loading && filtered.length > PAGE_SIZE && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="mt-4 flex items-center justify-between">
            <p className="text-sm text-gray-500">
              Hiển thị {(page - 1) * PAGE_SIZE + 1} - {Math.min(page * PAGE_SIZE, filtered.length)} của {filtered.length}
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 disabled:opacity-50"
              >
                <ChevronLeft size={18} />
              </button>
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i + 1}
                  onClick={() => setPage(i + 1)}
                  className={`h-8 w-8 rounded-lg text-sm font-medium transition ${
                    page === i + 1
                      ? 'bg-orange-500 text-white'
                      : 'text-gray-500 hover:bg-gray-100'
                  }`}
                >
                  {i + 1}
                </button>
              ))}
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 disabled:opacity-50"
              >
                <ChevronRight size={18} />
              </button>
            </div>
          </motion.div>
        )}

        {/* Create/Edit Modal */}
        {modalOpen && (
          <UserModal
            user={editingUser}
            onClose={() => { setModalOpen(false); setEditingUser(null); }}
            onSuccess={(updated) => {
              if (editingUser) {
                setUsers(prev => prev.map(u => u.id === updated.id ? updated : u));
              } else {
                setUsers(prev => [updated, ...prev]);
              }
              setModalOpen(false);
              setEditingUser(null);
            }}
            showToast={showToast}
          />
        )}

        {/* Delete Confirmation */}
        {deleteConfirm && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl"
            >
              <h3 className="text-lg font-bold text-gray-900">Xác nhận xóa</h3>
              <p className="mt-2 text-sm text-gray-500">Bạn có chắc muốn xóa người dùng này? Hành động này không thể hoàn tác.</p>
              <div className="mt-6 flex justify-end gap-3">
                <button
                  onClick={() => setDeleteConfirm(null)}
                  className="rounded-xl px-4 py-2 text-sm font-semibold text-gray-600 transition hover:bg-gray-100"
                >
                  Hủy
                </button>
                <button
                  onClick={() => handleDelete(deleteConfirm)}
                  className="rounded-xl bg-red-500 px-4 py-2 text-sm font-semibold text-white transition hover:bg-red-600"
                >
                  Xóa
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </main>
    </div>
  );
}

/* ─── User Modal ────────────────────────────────────── */
function UserModal({
  user,
  onClose,
  onSuccess,
  showToast,
}: {
  user: AdminUser | null;
  onClose: () => void;
  onSuccess: (u: AdminUser) => void;
  showToast: (msg: string, type: 'success' | 'error') => void;
}) {
  const isEdit = !!user;
  const [form, setForm] = useState<UserForm>({
    username: user?.username ?? '',
    email: user?.email ?? '',
    password: '',
    fullName: user?.fullName ?? '',
    phoneNumber: user?.phoneNumber ?? '',
    role: (user?.role as UserForm['role']) ?? 'User',
  });
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState<Partial<Record<keyof UserForm, string>>>({});

  const validate = () => {
    const newErrors: Partial<Record<keyof UserForm, string>> = {};
    if (!form.username.trim()) newErrors.username = 'Username không được trống';
    if (!form.email.trim()) newErrors.email = 'Email không được trống';
    else if (!/\S+@\S+\.\S+/.test(form.email)) newErrors.email = 'Email không hợp lệ';
    if (!isEdit && !form.password) newErrors.password = 'Mật khẩu không được trống';
    else if (!isEdit && form.password.length < 6) newErrors.password = 'Mật khẩu tối thiểu 6 ký tự';
    if (!form.role) newErrors.role = 'Vai trò không được trống';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setSaving(true);
    try {
      if (isEdit) {
        const res = await apiFetch(`/admin/users/${user.id}/role`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ role: form.role }),
        });
        if (!res.ok) throw new Error('Không thể cập nhật người dùng.');
        showToast('Đã cập nhật người dùng.', 'success');
        onSuccess({ ...user, role: form.role });
      } else {
        const res = await apiFetch('/admin/users', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(form),
        });
        if (!res.ok) throw new Error('Không thể tạo người dùng.');
        const saved = await res.json() as AdminUser;
        showToast('Đã tạo người dùng mới.', 'success');
        onSuccess(saved);
      }
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl"
      >
        <div className="flex items-center justify-between">
          <h3 className="flex items-center gap-2 text-lg font-bold text-gray-900">
            <ShieldCheck size={20} className="text-purple-500" />
            {isEdit ? 'Sửa người dùng' : 'Thêm người dùng mới'}
          </h3>
          <button onClick={onClose} className="rounded-lg p-1 text-gray-400 hover:bg-gray-100">
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Username *</label>
            <input
              type="text"
              value={form.username}
              onChange={e => setForm(f => ({ ...f, username: e.target.value }))}
              className={`mt-1 w-full rounded-xl border bg-white px-4 py-2.5 text-sm shadow-sm focus:outline-none ${
                errors.username ? 'border-red-300 focus:border-red-300 focus:ring-red-100' : 'border-gray-200 focus:border-orange-300 focus:ring-orange-100 focus:ring-2'
              }`}
              placeholder="username"
            />
            {errors.username && <p className="mt-1 text-xs text-red-500">{errors.username}</p>}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Email *</label>
            <input
              type="email"
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              className={`mt-1 w-full rounded-xl border bg-white px-4 py-2.5 text-sm shadow-sm focus:outline-none ${
                errors.email ? 'border-red-300 focus:ring-red-100' : 'border-gray-200 focus:border-orange-300 focus:ring-2 focus:ring-orange-100'
              }`}
              placeholder="email@example.com"
            />
            {errors.email && <p className="mt-1 text-xs text-red-500">{errors.email}</p>}
          </div>

          {!isEdit && (
            <div>
              <label className="block text-sm font-medium text-gray-700">Mật khẩu *</label>
              <input
                type="password"
                value={form.password}
                onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
                className={`mt-1 w-full rounded-xl border bg-white px-4 py-2.5 text-sm shadow-sm focus:outline-none ${
                  errors.password ? 'border-red-300 focus:ring-red-100' : 'border-gray-200 focus:border-orange-300 focus:ring-2 focus:ring-orange-100'
                }`}
                placeholder="••••••••"
              />
              {errors.password && <p className="mt-1 text-xs text-red-500">{errors.password}</p>}
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700">Họ và tên</label>
            <input
              type="text"
              value={form.fullName}
              onChange={e => setForm(f => ({ ...f, fullName: e.target.value }))}
              className="mt-1 w-full rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
              placeholder="Nguyễn Văn A"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Số điện thoại</label>
            <input
              type="tel"
              value={form.phoneNumber}
              onChange={e => setForm(f => ({ ...f, phoneNumber: e.target.value }))}
              className="mt-1 w-full rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
              placeholder="0901234567"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Vai trò *</label>
            <select
              value={form.role}
              onChange={e => setForm(f => ({ ...f, role: e.target.value as UserForm['role'] }))}
              className="mt-1 w-full rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
            >
              {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
            </select>
            {errors.role && <p className="mt-1 text-xs text-red-500">{errors.role}</p>}
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-xl px-5 py-2.5 text-sm font-semibold text-gray-600 transition hover:bg-gray-100"
            >
              Hủy
            </button>
            <button
              type="submit"
              disabled={saving}
              className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-orange-500 to-orange-600 px-5 py-2.5 text-sm font-semibold text-white shadow-md shadow-orange-200/50 transition hover:from-orange-600 hover:to-orange-700 disabled:opacity-50"
            >
              {saving ? 'Đang lưu...' : isEdit ? 'Cập nhật' : 'Tạo mới'}
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  );
}
