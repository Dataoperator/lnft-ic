import React from 'react';
import { useAuthStore } from '../auth.store';

export const LoginButton: React.FC = () => {
  const { isAuthenticated, login, logout } = useAuthStore();

  if (isAuthenticated) {
    return (
      <button
        onClick={logout}
        className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
      >
        Logout
      </button>
    );
  }

  return (
    <button
      onClick={login}
      className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
    >
      Login with Internet Identity
    </button>
  );
};