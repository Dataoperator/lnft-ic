import { HttpAgent } from '@dfinity/agent';

export class HttpClient {
  private agent: HttpAgent;
  private baseUrl: string;

  constructor() {
    this.baseUrl = process.env.DFX_NETWORK === 'ic' 
      ? 'https://ic0.app' 
      : 'http://localhost:4943';
    
    this.agent = new HttpAgent({
      host: this.baseUrl
    });

    if (process.env.DFX_NETWORK !== 'ic') {
      this.agent.fetchRootKey().catch(console.error);
    }
  }

  async get<T>(path: string, init?: RequestInit): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...init,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...init?.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async post<T>(path: string, body: any, init?: RequestInit): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...init,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...init?.headers,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async transformAgentResponse<T>(response: any): Promise<T> {
    if ('Ok' in response) {
      return response.Ok;
    }
    throw new Error(response.Err || 'Unknown error occurred');
  }
}