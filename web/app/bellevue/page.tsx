import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Get tasks done in Bellevue — HustleXP",
  description:
    "Post a task in Bellevue and get an estimate. Funds stay in escrow until proof is reviewed. Eastside beta.",
};

export default function BellevuePage() {
  return (
    <LandingPage
      eyebrow="Bellevue · Eastside beta"
      headline="Get help with tasks in Bellevue"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What Bellevue neighbors can post"
      examples={[
        "Move a one-bedroom apartment near downtown Bellevue",
        "Mount a TV and assemble furniture in a high-rise unit",
        "Haul old furniture to the dump from a condo",
        "Pick up groceries and drop off packages around Crossroads",
      ]}
      initialZip="98004"
    />
  );
}
