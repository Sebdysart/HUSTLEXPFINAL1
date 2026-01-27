/**
 * HMoney - Money display atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - "Value is accumulating" feeling
 * - Prominent, earned, never apologetic
 * - Subtle glow on larger amounts
 */

import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
} from 'react-native-reanimated';
import { HText } from './HText';
import { hustleColors, hustleShadows, hustleSpacing } from '../../theme/hustle-tokens';

type MoneySize = 'sm' | 'md' | 'lg' | 'hero';

interface HMoneyProps {
  /** Amount in dollars */
  amount: number;
  /** Display size */
  size?: MoneySize;
  /** Show cents */
  showCents?: boolean;
  /** Label above amount (e.g., "You've earned") */
  label?: string;
  /** Show glow effect */
  glow?: boolean;
  /** Signed display (+/-) */
  signed?: boolean;
  /** Animate value changes */
  animated?: boolean;
  /** Container style */
  style?: ViewStyle;
  /** Alignment */
  align?: 'left' | 'center' | 'right';
}

const sizeConfig = {
  sm: { textVariant: 'headline' as const, symbolSize: 14 },
  md: { textVariant: 'title2' as const, symbolSize: 18 },
  lg: { textVariant: 'title1' as const, symbolSize: 24 },
  hero: { textVariant: 'hero' as const, symbolSize: 32 },
};

const formatAmount = (amount: number, showCents: boolean): string => {
  const absAmount = Math.abs(amount);
  
  if (showCents) {
    return absAmount.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }
  
  if (absAmount >= 1000000) {
    return `${(absAmount / 1000000).toFixed(1)}M`;
  }
  if (absAmount >= 10000) {
    return `${(absAmount / 1000).toFixed(1)}K`;
  }
  
  return absAmount.toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  });
};

export const HMoney: React.FC<HMoneyProps> = ({
  amount,
  size = 'md',
  showCents,
  label,
  glow = false,
  signed = false,
  animated = true,
  style,
  align = 'left',
}) => {
  const scale = useSharedValue(1);
  const previousAmountRef = useRef(amount);
  
  const config = sizeConfig[size];
  const shouldShowCents = showCents ?? Math.abs(amount) < 100;
  const formattedAmount = formatAmount(amount, shouldShowCents);
  
  const moneyColor = hustleColors.money.primary;
  
  // Animate on value change
  useEffect(() => {
    if (animated && amount !== previousAmountRef.current) {
      scale.value = withSequence(
        withSpring(1.05, { damping: 10, stiffness: 400 }),
        withSpring(1, { damping: 15, stiffness: 300 })
      );
      previousAmountRef.current = amount;
    }
  }, [amount, animated, scale]);
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));
  
  const alignStyle: ViewStyle = {
    alignItems: align === 'center' ? 'center' : align === 'right' ? 'flex-end' : 'flex-start',
  };
  
  const prefix = signed && amount > 0 ? '+' : signed && amount < 0 ? '-' : '';
  
  return (
    <Animated.View style={[styles.container, alignStyle, animatedStyle, style]}>
      {label && (
        <HText variant="footnote" color="secondary" style={styles.label}>
          {label}
        </HText>
      )}
      <View style={[styles.row, glow && hustleShadows.moneyGlow]}>
        {prefix && (
          <HText variant={config.textVariant} color={moneyColor} bold>
            {prefix}
          </HText>
        )}
        <HText
          variant={config.textVariant}
          color={moneyColor}
          bold
          style={{ marginRight: 2 }}
        >
          $
        </HText>
        <HText variant={config.textVariant} color={moneyColor} bold>
          {formattedAmount}
        </HText>
      </View>
    </Animated.View>
  );
};

/**
 * HMoneyInline - For inline money in text
 */
interface HMoneyInlineProps {
  amount: number;
  showCents?: boolean;
  signed?: boolean;
}

export const HMoneyInline: React.FC<HMoneyInlineProps> = ({
  amount,
  showCents = true,
  signed = false,
}) => {
  const prefix = signed && amount > 0 ? '+' : signed && amount < 0 ? '-' : '';
  const formatted = formatAmount(Math.abs(amount), showCents);
  
  return (
    <HText variant="body" color={hustleColors.money.primary} bold>
      {prefix}${formatted}
    </HText>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  label: {
    marginBottom: hustleSpacing.xs,
  },
});
