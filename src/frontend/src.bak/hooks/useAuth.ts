import { useState, useEffect } from 'react';
import { Identity } from '@dfinity/agent';
import { authStore } from '../features/auth/auth.store';

export const useAuth = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [identity, setIdentity] = useState<Identity | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    initialize();
  }, []);

  const initialize = async () => {
    try {
      setIsLoading(true);
      await authStore.initialize();
      const currentIdentity = authStore.getIdentity();
      setIdentity(currentIdentity);
      setIsAuthenticated(!!currentIdentity);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to initialize auth'));
    } finally {
      setIsLoading(false);
    }
  };

  const login = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const success = await authStore.login();
      if (success) {
        const currentIdentity = authStore.getIdentity();
        setIdentity(currentIdentity);
        setIsAuthenticated(true);
        return true;
      }
      return false;
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Login failed'));
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      setIsLoading(true);
      setError(null);
      await authStore.logout();
      setIdentity(null);
      setIsAuthenticated(false);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Logout failed'));
    } finally {
      setIsLoading(false);
    }
  };

  return {
    isAuthenticated,
    identity,
    isLoading,
    error,
    login,
    logout,
  };
};