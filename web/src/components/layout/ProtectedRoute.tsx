import { Navigate, Outlet } from 'react-router-dom';
import FeedbackButton from '../../features/feedback/components/FeedbackButton';
import { FeedbackProvider } from '../../features/feedback/context/FeedbackContext';

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
    const redirectPath = role === 'Admin' ? '/dashboard' : '/my-dashboard';
    return <Navigate to={redirectPath} replace />;
  }

  return (
    <FeedbackProvider>
      <Outlet />
      <FeedbackButton />
    </FeedbackProvider>
  );
}
