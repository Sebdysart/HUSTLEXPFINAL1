/**
 * API Client - Base HTTP client for HustleXP
 */

const API_BASE_URL = __DEV__ 
  ? 'http://localhost:3000/api' 
  : 'https://api.hustlexp.com';

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  headers?: Record<string, string>;
  timeout?: number;
}

interface ApiResponse<T> {
  data: T;
  status: number;
  ok: boolean;
  error?: string;
}

class ApiClient {
  private baseUrl: string;
  private authToken: string | null = null;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  setAuthToken(token: string | null) {
    this.authToken = token;
  }

  private async request<T>(
    endpoint: string,
    options: RequestOptions = {}
  ): Promise<ApiResponse<T>> {
    const { method = 'GET', body, headers = {}, timeout = 10000 } = options;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const url = `${this.baseUrl}${endpoint}`;
      
      const requestHeaders: Record<string, string> = {
        'Content-Type': 'application/json',
        ...headers,
      };

      if (this.authToken) {
        requestHeaders['Authorization'] = `Bearer ${this.authToken}`;
      }

      const response = await fetch(url, {
        method,
        headers: requestHeaders,
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      const data = await response.json();

      return {
        data,
        status: response.status,
        ok: response.ok,
        error: response.ok ? undefined : data.message || 'Request failed',
      };
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          return {
            data: null as T,
            status: 408,
            ok: false,
            error: 'Request timed out',
          };
        }
        return {
          data: null as T,
          status: 0,
          ok: false,
          error: error.message,
        };
      }
      
      return {
        data: null as T,
        status: 0,
        ok: false,
        error: 'Unknown error',
      };
    }
  }

  // HTTP methods
  get<T>(endpoint: string, options?: Omit<RequestOptions, 'method' | 'body'>) {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  post<T>(endpoint: string, body?: unknown, options?: Omit<RequestOptions, 'method' | 'body'>) {
    return this.request<T>(endpoint, { ...options, method: 'POST', body });
  }

  put<T>(endpoint: string, body?: unknown, options?: Omit<RequestOptions, 'method' | 'body'>) {
    return this.request<T>(endpoint, { ...options, method: 'PUT', body });
  }

  patch<T>(endpoint: string, body?: unknown, options?: Omit<RequestOptions, 'method' | 'body'>) {
    return this.request<T>(endpoint, { ...options, method: 'PATCH', body });
  }

  delete<T>(endpoint: string, options?: Omit<RequestOptions, 'method' | 'body'>) {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }
}

export const api = new ApiClient(API_BASE_URL);
export type { ApiResponse };
