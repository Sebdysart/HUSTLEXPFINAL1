/**
 * HustleXP Component Library
 * Barrel export for all components
 */

// Typography
export {
  Text,
  HeroText,
  Title1,
  Title2,
  Title3,
  Headline,
  Body,
  Callout,
  Subhead,
  Footnote,
  Caption,
} from './Text';
export type { TextProps } from './Text';

// Spacing
export {
  Spacing,
  SpaceXS,
  SpaceSM,
  SpaceMD,
  SpaceLG,
  SpaceXL,
  Space2XL,
  Space3XL,
  Space4XL,
  Space5XL,
  Flex,
  HSpaceXS,
  HSpaceSM,
  HSpaceMD,
  HSpaceLG,
} from './Spacing';
export type { SpacingProps } from './Spacing';

// Button
export { Button } from './Button';
export type { ButtonProps, ButtonVariant, ButtonSize } from './Button';

// Card
export { Card, ElevatedCard, PressableCard } from './Card';
export type { CardProps, CardVariant, CardPadding } from './Card';

// Input
export { Input, PasswordInput } from './Input';
export type { InputProps, PasswordInputProps } from './Input';

// Trust Badge
export { TrustBadge, TrustBadgeInline } from './TrustBadge';
export type { TrustBadgeProps, TrustBadgeInlineProps, BadgeSize } from './TrustBadge';

// Money Display
export {
  MoneyDisplay,
  MoneyInline,
  BalanceDisplay,
  TransactionAmount,
} from './MoneyDisplay';
export type {
  MoneyDisplayProps,
  MoneyInlineProps,
  BalanceDisplayProps,
  TransactionAmountProps,
  MoneySize,
} from './MoneyDisplay';

// Error Boundary
export { ErrorBoundary } from './ErrorBoundary';

// Map
export { TaskMap } from './TaskMap';

// Image Picker
export { ImagePicker } from './ImagePicker';

// Re-export theme for convenience
export { theme, colors, spacing, radii, typography, shadows } from '../theme';
