/**
 * HustleXP custom icon system — UI credibility pass.
 *
 * A small, cohesive set of inline-SVG icons drawn in one consistent style
 * (24×24 viewBox, 1.6 stroke, round caps/joins, `currentColor`) so the public
 * site reads as bespoke rather than generic AI-SaaS. No external icon library,
 * no dependencies. Every icon is decorative by default (`aria-hidden`) and
 * inherits color from its container via `currentColor`.
 *
 * Usage:
 *   import { EscrowIcon } from "@/components/hx-icons";
 *   <EscrowIcon className="h-5 w-5 text-brand-purple-glow" />
 *   // or by key:
 *   import { HxIcon } from "@/components/hx-icons";
 *   <HxIcon name="escrow" className="h-5 w-5" />
 *
 * COLOR LAW: icons carry no intrinsic color — they take it from the parent.
 * On entry surfaces that means purple / violet / info-blue / white only.
 */

type IconProps = React.SVGProps<SVGSVGElement>;

function Svg({ children, className, ...props }: IconProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className={className ?? "h-5 w-5"}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      {children}
    </svg>
  );
}

/** A located task — pin with a centered marker. */
export function TaskPinIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <path d="M12 21c4.5-4.6 7-7.7 7-11a7 7 0 1 0-14 0c0 3.3 2.5 6.4 7 11Z" />
      <circle cx="12" cy="10" r="2.4" />
    </Svg>
  );
}

/** Escrow — funds held safe behind a lock. */
export function EscrowIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <rect x="4" y="10.5" width="16" height="9.5" rx="2.2" />
      <path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" />
      <circle cx="12" cy="15" r="1.4" />
      <path d="M12 16.4v1.6" />
    </Svg>
  );
}

/** Proof — photo/video proof submitted for review. */
export function ProofIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <path d="M4 8.5h3l1.6-2.2h6.8L17 8.5h3a0 0 0 0 1 0 0" />
      <rect x="3" y="6.3" width="18" height="13" rx="2.4" />
      <circle cx="12" cy="13" r="3.2" />
      <path d="m10.8 13 1 1 1.6-1.8" />
    </Svg>
  );
}

/** Route — a task moving along a path. */
export function RouteIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <circle cx="6" cy="18" r="2.1" />
      <circle cx="18" cy="6" r="2.1" />
      <path d="M8 17.4c2.2-.6 3.4-2 3.4-4 0-2.2 1.2-3.6 3.4-4.2" strokeDasharray="0.1 3" />
    </Svg>
  );
}

/** Business — a local storefront. */
export function BusinessIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <path d="M4 9.5 5.4 5h13.2L20 9.5" />
      <path d="M4 9.5a2.4 2.4 0 0 0 4 0 2.4 2.4 0 0 0 4 0 2.4 2.4 0 0 0 4 0 2.4 2.4 0 0 0 4 0" />
      <path d="M5.5 11.5V20h13v-8.5" />
      <path d="M10 20v-4.5h4V20" />
    </Svg>
  );
}

/** Checklist — describe what you need. */
export function ChecklistIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <rect x="5" y="3.5" width="14" height="17" rx="2.2" />
      <path d="m8 8.5 1.2 1.2 2-2.2" />
      <path d="m8 14 1.2 1.2 2-2.2" />
      <path d="M14 8.3h2.5" />
      <path d="M14 13.8h2.5" />
    </Svg>
  );
}

/** Clock — estimated time. */
export function ClockIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <circle cx="12" cy="12" r="8.2" />
      <path d="M12 7.6V12l3 1.8" />
    </Svg>
  );
}

/** Map dot — a precise local point. */
export function MapDotIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <circle cx="12" cy="12" r="2.4" />
      <circle cx="12" cy="12" r="6.4" strokeDasharray="0.1 3.2" />
      <circle cx="12" cy="12" r="9.6" strokeDasharray="0.1 3.8" />
    </Svg>
  );
}

/** Receipt / payment — the estimate and what you pay. */
export function ReceiptIcon(props: IconProps) {
  return (
    <Svg {...props}>
      <path d="M6 3.5h12v17l-2-1.3-2 1.3-2-1.3-2 1.3-2-1.3-2 1.3Z" />
      <path d="M9 8h6" />
      <path d="M9 11.5h6" />
      <path d="M9 15h3.5" />
    </Svg>
  );
}

export type HxIconName =
  | "taskPin"
  | "escrow"
  | "proof"
  | "route"
  | "business"
  | "checklist"
  | "clock"
  | "mapDot"
  | "receipt";

const ICONS: Record<HxIconName, (props: IconProps) => React.ReactElement> = {
  taskPin: TaskPinIcon,
  escrow: EscrowIcon,
  proof: ProofIcon,
  route: RouteIcon,
  business: BusinessIcon,
  checklist: ChecklistIcon,
  clock: ClockIcon,
  mapDot: MapDotIcon,
  receipt: ReceiptIcon,
};

/** Render an icon by key, e.g. <HxIcon name="escrow" className="h-5 w-5" />. */
export function HxIcon({ name, ...props }: { name: HxIconName } & IconProps) {
  const Cmp = ICONS[name];
  return <Cmp {...props} />;
}
