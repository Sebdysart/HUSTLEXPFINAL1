/**
 * Text Component
 * Typography component with all design system variants
 */

import React from 'react';
import {
  Text as RNText,
  TextProps as RNTextProps,
  TextStyle,
} from 'react-native';
import { colors, typography, TypographyKey } from '../theme';

export interface TextProps extends RNTextProps {
  /** Typography variant */
  variant?: TypographyKey;
  /** Text color - defaults to primary */
  color?: 'primary' | 'secondary' | 'tertiary' | 'inverse' | 'brand' | 'accent' | 'danger' | 'success' | 'warning' | string;
  /** Center text */
  center?: boolean;
  /** Text alignment */
  align?: 'left' | 'center' | 'right';
  /** Bold override */
  bold?: boolean;
  /** Uppercase text */
  uppercase?: boolean;
  /** Children */
  children: React.ReactNode;
}

const colorMap: Record<string, string> = {
  primary: colors.text.primary,
  secondary: colors.text.secondary,
  tertiary: (colors.text as any).tertiary || '#636366',
  inverse: (colors.text as any).inverse || '#000000',
  brand: (colors as any).brand?.primary || colors.primary,
  accent: colors.accent,
  danger: colors.danger,
  success: colors.success,
  warning: colors.warning,
};

export const Text: React.FC<TextProps> = ({
  variant = 'body',
  color = 'primary',
  center = false,
  align,
  bold = false,
  uppercase = false,
  style,
  children,
  ...props
}) => {
  const textColor = colorMap[color] || color;
  const variantStyle = typography[variant];
  const textAlign = align || (center ? 'center' : undefined);

  const composedStyle: TextStyle = {
    ...variantStyle,
    color: textColor,
    ...(textAlign && { textAlign }),
    ...(bold && { fontWeight: '700' }),
    ...(uppercase && { textTransform: 'uppercase', letterSpacing: 1.5 }),
  };

  return (
    <RNText style={[composedStyle, style]} {...props}>
      {children}
    </RNText>
  );
};

// Convenience components
export const HeroText: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="hero" {...props} />
);

export const Title1: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="title1" {...props} />
);

export const Title2: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="title2" {...props} />
);

export const Title3: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="title3" {...props} />
);

export const Headline: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="headline" {...props} />
);

export const Body: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="body" {...props} />
);

export const Callout: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="callout" {...props} />
);

export const Subhead: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="subhead" {...props} />
);

export const Footnote: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="footnote" {...props} />
);

export const Caption: React.FC<Omit<TextProps, 'variant'>> = (props) => (
  <Text variant="caption" {...props} />
);

export default Text;
