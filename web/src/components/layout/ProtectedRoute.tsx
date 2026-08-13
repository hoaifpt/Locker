import { Navigate, Outlet } from 'react-router-dom';
import FeedbackButton from '../../features/feedback/components/FeedbackButton';

interface ProtectedRouteProps {
  allowedRoles?: string[];
}

export default function ProtectedRoute({ allowedRoles }: ProtectedRouteProps) {
  const token = localStorage.getItem('token');
  const role = localStorage.getItem('role') ?? 'User';

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(role)) {
    // Nếu role không nằm trong danh sách cho phép, redirect về dashboard
    return <Navigate to="/dashboard" replace />;
  }

  return (
    <>
      <Outlet />
      <FeedbackButton />
    </>
  );
}
