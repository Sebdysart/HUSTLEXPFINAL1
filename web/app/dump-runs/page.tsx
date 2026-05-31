import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Dump runs on the Eastside — HustleXP",
  description:
    "Post a dump-run task and get an estimate. Funds stay in escrow until proof is reviewed. Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.",
};

export default function DumpRunsPage() {
  return (
    <LandingPage
      eyebrow="Dump runs · Eastside beta"
      headline="Dump runs on the Eastside"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What you can post"
      examples={[
        "Haul old furniture to the transfer station",
        "Clear out a garage or basement",
        "Take construction debris off your hands",
        "Dispose of yard waste after a big cleanup",
      ]}
      initialCategory="dump"
    />
  );
}
