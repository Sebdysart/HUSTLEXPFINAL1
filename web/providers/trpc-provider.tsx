"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  httpBatchLink,
  TRPCClientError,
  type TRPCLink,
} from "@trpc/client";
import { observable } from "@trpc/server/observable";
import type { AnyRouter } from "@trpc/server";
import { useState, type ReactNode } from "react";
import { trpc, getTrpcUrl } from "@/lib/trpc";
import { getIdToken } from "@/lib/firebase";
import type { AppRouter } from "@/types/trpc/AppRouter";

/**
 * Custom link: on 401, force a Firebase token refresh and retry the op once.
 * If the user is not signed in or the refresh still fails, the error propagates.
 */
const authTokenRefreshLink: TRPCLink<AnyRouter> = () => ({ next, op }) =>
  observable((observer) => {
    let attempt = 0;
    let currentSub: { unsubscribe: () => void } | null = null;

    const start = () => {
      attempt++;
      currentSub = next(op).subscribe({
        next: (value) => observer.next(value),
        error: async (err: unknown) => {
          const status =
            (err as { data?: { httpStatus?: number } } | undefined)?.data
              ?.httpStatus;
          if (status === 401 && attempt === 1) {
            const fresh = await getIdToken(true).catch(() => null);
            if (fresh) {
              start();
              return;
            }
          }
          observer.error(err as TRPCClientError<AnyRouter>);
        },
        complete: () => observer.complete(),
      });
    };

    start();

    return () => {
      currentSub?.unsubscribe();
    };
  });

export function TRPCProvider({ children }: { children: ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: { retry: false, refetchOnWindowFocus: false },
        },
      })
  );

  const [trpcClient] = useState(() =>
    trpc.createClient({
      links: [
        authTokenRefreshLink as TRPCLink<AppRouter>,
        httpBatchLink({
          url: getTrpcUrl(),
          fetch: (input, init) =>
            fetch(input, { ...init, credentials: "omit" }),
          headers: async () => {
            const token = await getIdToken();
            return token ? { Authorization: `Bearer ${token}` } : {};
          },
        }),
      ],
    })
  );

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </trpc.Provider>
  );
}
