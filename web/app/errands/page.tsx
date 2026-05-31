import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Errands on the Eastside — HustleXP",
  description:
    "Post an errand and get an estimate. Funds stay in escrow until proof is reviewed. Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.",
};

export default function ErrandsPage() {
  return (
    <LandingPage
      eyebrow="Errands · Eastside beta"
      headline="Errands on the Eastside"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What you can post"
      examples={[
        "Pick up and drop off packages",
        "Grab groceries or make a hardware-store run",
        "Wait for a delivery or a repair appointment",
        "Return items to a store",
      ]}
      initialCategory="errands"
    />
  );
}
