import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Furniture assembly on the Eastside — HustleXP",
  description:
    "Post a furniture assembly task and get an estimate. Funds stay in escrow until proof is reviewed. Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.",
};

export default function FurnitureAssemblyPage() {
  return (
    <LandingPage
      eyebrow="Furniture assembly · Eastside beta"
      headline="Furniture assembly on the Eastside"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What you can post"
      examples={[
        "Assemble a flat-pack desk, bed frame, or dresser",
        "Put together a bookshelf or wardrobe",
        "Build patio furniture or a grill",
        "Mount a TV and tidy the cables",
      ]}
      initialCategory="assembly"
    />
  );
}
