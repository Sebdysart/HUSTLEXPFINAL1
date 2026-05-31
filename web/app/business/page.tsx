import type { Metadata } from "next";
import { BusinessLanding } from "@/components/business-landing";

export const metadata: Metadata = {
  title: "For local businesses — HustleXP",
  description:
    "Eastside businesses can register early interest in flexible, on-demand task help. Funds can be held until proof is reviewed. No guaranteed timeline.",
};

export default function BusinessPage() {
  return <BusinessLanding />;
}
