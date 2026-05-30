/**
 * tRPC client bound to the backend AppRouter. Use `trpc.<router>.<procedure>`
 * inside client components. The provider lives in providers/trpc-provider.tsx.
 */

import { createTRPCReact } from "@trpc/react-query";
import type { AppRouter } from "@/types/trpc/AppRouter";
import { env } from "./env";

export const trpc = createTRPCReact<AppRouter>();

export function getBaseUrl(): string {
  return env.apiUrl.replace(/\/+$/, "");
}

export function getTrpcUrl(): string {
  return `${getBaseUrl()}/trpc`;
}
