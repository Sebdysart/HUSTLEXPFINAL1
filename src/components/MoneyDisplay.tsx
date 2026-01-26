/**
 * MoneyDisplay Component
 * Formats and displays currency with HustleXP styling
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import { colors, typography, spacing } from '../theme';
import { Text } from './Text';

export type MoneySize = 'sm' | 'md' | 'lg' | 'hero';

export interface MoneyDisplayProps {
  /** Amount in dollars (or smallest currency unit if pennies) */
  amount: number;
  /** Display size */
  size?: MoneySize;
  /** Show cents (default: true for amounts < $100) */
  showCents?: boolean;
  /** Currency symbol (default: $) */
  currency?: string;
  /** Positive/negative coloring */
  signed?: boolean;
  /** Animate value changes */
  animated?: boolean;
  /** Show plus sign for positive amounts */
  showPlus?: boolean;
  /** Custom style */
  style?: ViewStyle;
  /** Text alignment */
  align?: 'left' | 'center' | 'right';
}

const sizeConfig: Record<MoneySize, {
  variant: 'hero' | 'title1' | 'title3' | 'headline';
  symbolSize: number;
}> = {
  sm: { variant: 'headline', symbolSize: 14 },
  md: { variant: 'title3', symbolSize: 18 },
  lg: { variant: 'title1', symbolSize: 24 },
  hero: { variant: 'hero', symbolSize: 32 },
};

const formatAmount = (amount: number, showCents: boolean): string => {
  const absAmount = Math.abs(amount);
  
  if (showCents) {
    return absAmount.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }
  
  // For large amounts, abbreviate
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

export const MoneyDisplay: React.FC<MoneyDisplayProps> = ({
  amount,
  size = 'md',
  showCents,
  currency = '$',
  signed = false,
  animated = true,
  showPlus = false,
  style,
  align = 'left',
}) => {
  const scale = useSharedValue(1);
  const previousAmount = useSharedValue(amount);

  // Determine if we should show cents
  const shouldShowCents = showCents ?? Math.abs(amount) < 100;

  // Determine color based on sign
  const getColor = (): string => {
    if (!signed) return colors.accent; // Default money green
    if (amount > 0) return colors.accent;
    if (amount < 0) return colors.danger;
    return colors.text.secondary;
  };

  // Animate on value change
  useEffect(() => {
    if (animated && amount !== previousAmount.value) {
      scale.value = withSequence(
        withSpring(1.1, { damping: 10, stiffness: 400 }),
        withSpring(1, { damping: 15, stiffness: 300 })
      );
      previousAmount.value = amount;
    }
  }, [amount, animated]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const config = sizeConfig[size];
  const color = getColor();
  const formattedAmount = formatAmount(amount, shouldShowCents);
  
  // Build the display string
  let prefix = '';
  if (signed && amount < 0) prefix = '-';
  else if (showPlus && amount > 0) prefix = '+';

  const alignStyle: ViewStyle = {
    alignItems: align === 'center' ? 'center' : align === 'right' ? 'flex-end' : 'flex-start',
  };

  return (
    <Animated.View style={[styles.container, alignStyle, animatedStyle, style]}>
      <View style={styles.row}>
        {prefix && (
          <Text variant={config.variant} color={color} bold>
            {prefix}
          </Text>
        )}
        <Text
          style={[styles.symbol, { fontSize: config.symbolSize, color }]}
          bold
        >
          {currency}
        </Text>
        <Text variant={config.variant} color={color} bold>
          {formattedAmount}
        </Text>
      </View>
    </Animated.View>
  );
};

// Inline money display for use in text
export interface MoneyInlineProps {
  amount: number;
  showCents?: boolean;
  signed?: boolean;
}

export const MoneyInline: React.FC<MoneyInlineProps> = ({
  amount,
  showCents = true,
  signed = false,
}) => {
  const color = signed
    ? amount >= 0
      ? colors.accent
      : colors.danger
    : colors.accent;

  const prefix = signed && amount > 0 ? '+' : '';
  const formatted = formatAmount(amount, showCents);

  return (
    <Text color={color} bold>
      {prefix}${amount < 0 ? '-' : ''}{formatted}
    </Text>
  );
};

// Balance display with label
export interface BalanceDisplayProps extends MoneyDisplayProps {
  label?: string;
  labelPosition?: 'top' | 'bottom';
}

export const BalanceDisplay: React.FC<BalanceDisplayProps> = ({
  label = 'Balance',
  labelPosition = 'top',
  ...props
}) => {
  return (
    <View style={styles.balanceContainer}>
      {labelPosition === 'top' && (
        <Text variant="caption" color="secondary" style={styles.balanceLabel}>
          {label}
        </Text>
      )}
      <MoneyDisplay {...props} />
      {labelPosition === 'bottom' && (
        <Text variant="caption" color="secondary" style={styles.balanceLabel}>
          {label}
        </Text>
      )}
    </View>
  );
};

// Transaction amount with +/- styling
export interface TransactionAmountProps {
  amount: number;
  type: 'income' | 'expense' | 'transfer';
  size?: MoneySize;
}

export const TransactionAmount: React.FC<TransactionAmountProps> = ({
  amount,
  type,
  size = 'md',
}) => {
  const displayAmount = type === 'expense' ? -Math.abs(amount) : Math.abs(amount);
  
  return (
    <MoneyDisplay
      amount={displayAmount}
      size={size}
      signed
      showPlus={type === 'income'}
    />
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
  symbol: {
    fontWeight: '700',
    marginRight: 2,
  },
  balanceContainer: {
    alignItems: 'center',
  },
  balanceLabel: {
    marginVertical: spacing.xs,
  },
});

export default MoneyDisplay;
