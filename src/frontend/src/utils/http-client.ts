import { HttpAgent } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';

interface RequestOptions extends RequestInit {
  params?: Record<string, string>;
  timeout?: number;
}

export class HttpClient {
  private agent: HttpAgent;
  private baseUrl: string;
  private defaultTimeout: number;

  constructor(options: {
    baseUrl?: string;
    timeout?: number;
  } = {}) {
    this.baseUrl = options.baseUrl || (
      process.env.DFX_NETWORK === 'ic' 
        ? 'https://ic0.app' 
        : 'http://localhost:4943'
    );
    
    this.defaultTimeout = options.timeout || 30000; // 30 seconds default timeout
    
    this.agent = new HttpAgent({
      host: this.baseUrl
    });

    // Initialize local development environment
    if (process.env.DFX_NETWORK !== 'ic') {
      this.initializeLocalDevelopment();
    }
  }

  private async initializeLocalDevelopment() {
    try {
      await this.agent.fetchRootKey();
    } catch (error) {
      console.error('Failed to initialize local development environment:', error);
      throw new Error('Local development environment initialization failed');
    }
  }

  private async handleRequest<T>(
    path: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const { 
      params,
      timeout = this.defaultTimeout,
      ...init 
    } = options;

    // Build URL with query parameters
    const url = new URL(`${this.baseUrl}${path}`);
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.append(key, value);
      });
    }

    // Create abort controller for timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url.toString(), {
        ...init,
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
          ...init.headers,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return this.transformResponse<T>(data);

    } catch (error) {
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          throw new Error(`Request timeout after ${timeout}ms`);
        }
        throw error;
      }
      throw new Error('Unknown error occurred');

    } finally {
      clearTimeout(timeoutId);
    }
  }

  async get<T>(path: string, options?: RequestOptions): Promise<T> {
    return this.handleRequest<T>(path, {
      ...options,
      method: 'GET'
    });
  }

  async post<T>(path: string, body: unknown, options?: RequestOptions): Promise<T> {
    return this.handleRequest<T>(path, {
      ...options,
      method: 'POST',
      body: JSON.stringify(body)
    });
  }

  async transformResponse<T>(response: unknown): Promise<T> {
    if (response && typeof response === 'object') {
      if ('Ok' in response) {
        return (response as { Ok: T }).Ok;
      }
      if ('Err' in response) {
        throw new Error((response as { Err: string }).Err);
      }
    }
    return response as T;
  }

  /**
   * Utility method to create a Principal from text
   */
  static createPrincipal(text: string): Principal {
    try {
      return Principal.fromText(text);
    } catch (error) {
      throw new Error('Invalid principal format');
    }
  }

  /**
   * Utility method to validate a Principal
   */
  static isValidPrincipal(principal: string): boolean {
    try {
      Principal.fromText(principal);
      return true;
    } catch {
      return false;
    }
  }
}