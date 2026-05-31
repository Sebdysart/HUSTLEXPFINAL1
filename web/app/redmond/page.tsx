import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Get tasks done in Redmond — HustleXP",
  description:
    "Post a task in Redmond and get an estimate. Funds stay in escrow until proof is reviewed. Eastside beta.",
};

export default function RedmondPage() {
  return (
    <LandingPage
      eyebrow="Redmond · Eastside beta"
      headline="Get help with tasks in Redmond"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What Redmond neighbors can post"
      examples={[
        "Move a couch up to a Redmond Ridge apartment",
        "Haul yard debris to the dump after a weekend cleanup",
        "Assemble a desk and bookshelf for a home office",
        "Run errands around Redmond Town Center",
      ]}
      initialZip="98052"
    />
  );
}
