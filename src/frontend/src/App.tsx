import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useEffect } from 'react';
import { useAuthStore } from './features/auth/auth.store';
import { AuthGuard } from './features/auth/components/AuthGuard';
import { DashboardView } from './features/dashboard/DashboardView';
import { Toaster } from '@/components/ui/toaster';
import { ErrorBoundary } from './components/ErrorBoundary';

export default function App() {
  const initialize = useAuthStore(state => state.initialize);

  useEffect(() => {
    initialize();
  }, [initialize]);

  return (
    <ErrorBoundary>
      <Router>
        <div className="min-h-screen bg-black text-white">
          <Routes>
            <Route path="/" element={
              <AuthGuard>
                <DashboardView />
              </AuthGuard>
            } />
          </Routes>
          <Toaster />
        </div>
      </Router>
    </ErrorBoundary>
  );
}