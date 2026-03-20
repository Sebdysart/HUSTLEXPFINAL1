import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';
import { AppConfig } from '../app/config';
import { webMockCall } from './webMocks';

export type ProcedureType = 'query' | 'mutation';

export class TRPCError extends Error {
  code?: string;
  statusCode?: number;
  constructor(message: string, opts?: { code?: string; statusCode?: number }) {
    super(message);
    this.name = 'TRPCError';
    this.code = opts?.code;
    this.statusCode = opts?.statusCode;
  }
}

type TRPCEnvelope<T> = { result: { data: T } };
type TRPCErrorEnvelope = { error: { message: string; code?: string } };

const AUTH_TOKEN_KEY = 'hx.authToken';

/**
 * Minimal tRPC client matching the Swift `TRPCClient` call style:
 * - query: GET /trpc/router.proc?input=<json>
 * - mutation: POST /trpc/router.proc with JSON body
 * - Authorization: Bearer <firebase_jwt>
 */
export class TRPCClient {
  private authToken: string | null = null;

  static shared = new TRPCClient();

  async setAuthToken(token: string) {
    this.authToken = token;
    await AsyncStorage.setItem(AUTH_TOKEN_KEY, token);
  }

  async clearAuthToken() {
    this.authToken = null;
    await AsyncStorage.removeItem(AUTH_TOKEN_KEY);
  }

  async loadAuthToken() {
    const token = await AsyncStorage.getItem(AUTH_TOKEN_KEY);
    this.authToken = token;
    return token;
  }

  async call<Input extends object, Output>(
    router: string,
    procedure: string,
    type: ProcedureType,
    input: Input
  ): Promise<Output> {
    const path = `${router}.${procedure}`;

    // Web preview: backend CORS blocks browser fetches to Railway.
    // We provide minimal mocks so the UI can render in Expo Web.
    if (Platform.OS === 'web') {
      const mocked = webMockCall(path, type, input);
      if (mocked !== undefined) return mocked as Output;
      throw new TRPCError(
        `Web preview mock missing for ${path}. This call is blocked by backend CORS in the browser.`,
        { code: 'WEB_CORS_BLOCKED' }
      );
    }

    const base = AppConfig.backendBaseUrl.replace(/\/$/, '');
    const url = `${base}/trpc/${path}`;

    const headers: Record<string, string> = {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    };
    if (this.authToken) headers.Authorization = `Bearer ${this.authToken}`;

    let res: Response;
    if (type === 'query') {
      const inputStr = JSON.stringify(input ?? {});
      const q = inputStr === '{}' ? '' : `?input=${encodeURIComponent(inputStr)}`;
      res = await fetch(`${url}${q}`, { method: 'GET', headers });
    } else {
      res = await fetch(url, { method: 'POST', headers, body: JSON.stringify(input ?? {}) });
    }

    const text = await res.text();
    const parseJson = () => {
      try {
        return text ? JSON.parse(text) : null;
      } catch {
        return null;
      }
    };
    const json = parseJson();

    if (!res.ok) {
      const trpcErr = json as TRPCErrorEnvelope | null;
      const message = trpcErr?.error?.message ?? `HTTP ${res.status}`;
      throw new TRPCError(message, { code: trpcErr?.error?.code, statusCode: res.status });
    }

    const envelope = json as TRPCEnvelope<Output> | null;
    if (!envelope?.result?.data) {
      throw new TRPCError('Invalid server response (missing result.data)', { statusCode: res.status });
    }
    return envelope.result.data;
  }
}

