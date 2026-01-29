/**
 * HText - Typography atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - Human, simple, slightly clever
 * - Never salesy or aggressive
 * - Hierarchy through weight/size, not color abuse
 */

import React from 'react';
import { Text as RNText, TextProps as RNTextProps } from 'react-native';
import { hustleColors, hustleTypography } from '../../theme/hustle-tokens';

type TypographyVariant = keyof typeof hustleTypography;
type TextColor = 'primary' | 'secondary' | 'tertiary' | 'muted' | 'purple' | 'success' | 'warning' | 'error' | string;
type TextAlign = 'left' | 'center' | 'right';

export interface HTextProps extends RNTextProps {
  /** Typography variant */
  variant?: TypographyVariant;
  /** Text color */
  color?: TextColor;
  /** Text alignment */
  align?: TextAlign;
  /** Center align (shorthand for align="center") */
  center?: boolean;
  /** Bold weight override */
  bold?: boolean;
  /** Medium weight override */
  medium?: boolean;
}

const colorMap: Record<string, string> = {
  primary: hustleColors.text.primary,
  secondary: hustleColors.text.secondary,
  tertiary: hustleColors.text.tertiary,
  muted: hustleColors.text.muted,
  purple: hustleColors.purple.soft,
  success: hustleColors.semantic.success,
  warning: hustleColors.semantic.warning,
  error: hustleColors.semantic.error,
};

export const HText: React.FC<HTextProps> = ({
  variant = 'body',
  color = 'primary',
  align,
  center = false,
  bold = false,
  medium = false,
  style,
  children,
  ...props
}) => {
  const typography = hustleTypography[variant];
  const resolvedColor = colorMap[color] || color;
  
  let fontWeight = typography.fontWeight;
  if (bold) fontWeight = '700';
  if (medium) fontWeight = '500';

  // Resolve text alignment
  const textAlign = align || (center ? 'center' : 'left');

  return (
    <RNText
      style={[
        {
          fontSize: typography.fontSize,
          lineHeight: typography.lineHeight,
          fontWeight,
          letterSpacing: typography.letterSpacing,
          color: resolvedColor,
          textAlign,
        },
        style,
      ]}
      {...props}
    >
      {children}
    </RNText>
  );
};

/**
 * Convenience components for common patterns
 */
export const HHero: React.FC<Omit<HTextProps, 'variant'>> = (props) => (
  <HText variant="hero" {...props} />
);

export const HTitle: React.FC<Omit<HTextProps, 'variant'>> = (props) => (
  <HText variant="title1" {...props} />
);

export const HHeadline: React.FC<Omit<HTextProps, 'variant'>> = (props) => (
  <HText variant="headline" {...props} />
);

export const HBody: React.FC<Omit<HTextProps, 'variant'>> = (props) => (
  <HText variant="body" {...props} />
);

export const HCaption: React.FC<Omit<HTextProps, 'variant'>> = (props) => (
  <HText variant="caption" color="tertiary" {...props} />
);
