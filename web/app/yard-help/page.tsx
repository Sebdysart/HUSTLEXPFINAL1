import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Yard help on the Eastside — HustleXP",
  description:
    "Post a yard-work task and get an estimate. Funds stay in escrow until proof is reviewed. Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.",
};

export default function YardHelpPage() {
  return (
    <LandingPage
      eyebrow="Yard help · Eastside beta"
      headline="Yard help on the Eastside"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What you can post"
      examples={[
        "Rake leaves and bag yard debris",
        "Pull weeds and clear overgrown beds",
        "Spread mulch or gravel",
        "Haul brush to the dump after a cleanup",
      ]}
      initialCategory="yard"
    />
  );
}
