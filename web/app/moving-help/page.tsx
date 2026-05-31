import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Moving help on the Eastside — HustleXP",
  description:
    "Post a moving task and get an estimate. Funds stay in escrow until proof is reviewed. Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.",
};

export default function MovingHelpPage() {
  return (
    <LandingPage
      eyebrow="Moving help · Eastside beta"
      headline="Moving help on the Eastside"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What you can post"
      examples={[
        "Load and unload a rental truck",
        "Carry boxes and furniture up to an apartment",
        "Move a couch, bed, or appliance to a new place",
        "Shift heavy items between rooms or to storage",
      ]}
      initialCategory="moving"
    />
  );
}
