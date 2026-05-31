import type { Metadata } from "next";
import { LandingPage } from "@/components/landing-page";

export const metadata: Metadata = {
  title: "Get tasks done in Sammamish — HustleXP",
  description:
    "Post a task in Sammamish and get an estimate. Funds stay in escrow until proof is reviewed. Eastside beta.",
};

export default function SammamishPage() {
  return (
    <LandingPage
      eyebrow="Sammamish · Eastside beta"
      headline="Get help with tasks in Sammamish"
      subhead="Post a task and get an estimate. Funds stay in escrow until proof is reviewed."
      examplesHeading="What Sammamish neighbors can post"
      examples={[
        "Clear brush and bag leaves on a Plateau yard",
        "Move boxes from the garage to a storage unit",
        "Assemble a trampoline or patio furniture",
        "Take a dump-run trip after a garage cleanout",
      ]}
      initialZip="98074"
    />
  );
}
