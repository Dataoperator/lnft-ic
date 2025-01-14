import { useState, useEffect } from 'react';
import { Actor, Identity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import { canisterId, createActor } from '../declarations/lnft_core';

interface AuthState {
  isAuthenticated: boolean;
  identity: Identity | null;
  actor: Actor | null;
}

export const useAuth = () => {
  const [authClient, setAuthClient] = useState<AuthClient | null>(null);
  const [state, setState] = useState<AuthState>({
    isAuthenticated: false,
    identity: null,
    actor: null
  });

  useEffect(() => {
    AuthClient.create().then(client => {
      setAuthClient(client);
      const identity = client.getIdentity();
      const actor = createActor(canisterId, { agentOptions: { identity } });
      
      setState({
        isAuthenticated: client.isAuthenticated(),
        identity,
        actor
      });
    });
  }, []);

  const login = async () => {
    if (!authClient) return;
    
    try {
      await authClient.login({
        identityProvider: process.env.DFX_NETWORK === 'ic' 
          ? 'https://identity.ic0.app'
          : `http://localhost:${process.env.INTERNET_IDENTITY_PORT}`,
        onSuccess: () => {
          const identity = authClient.getIdentity();
          const actor = createActor(canisterId, { agentOptions: { identity } });
          
          setState({
            isAuthenticated: true,
            identity,
            actor
          });
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  };

  const logout = async () => {
    if (!authClient) return;
    
    await authClient.logout();
    setState({
      isAuthenticated: false,
      identity: null,
      actor: null
    });
  };

  return {
    ...state,
    login,
    logout
  };
};