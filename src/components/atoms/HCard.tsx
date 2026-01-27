/**
 * HCard - Card atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - Glass feel with subtle depth
 * - Never empty feeling
 * - Tap feedback is light and obvious
 */

import React from 'react';
import { View, StyleSheet, ViewStyle, Pressable } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { hustleColors, hustleRadii, hustleSpacing, hustleShadows, hustleGradients } from '../../theme/hustle-tokens';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

type CardVariant = 'default' | 'elevated' | 'outlined' | 'success';
type CardPadding = 'none' | 'sm' | 'md' | 'lg' | 'xl';

interface HCardProps {
  children: React.ReactNode;
  variant?: CardVariant;
  padding?: CardPadding;
  /** Make card pressable */
  onPress?: () => void;
  /** Custom style */
  style?: ViewStyle;
}

const paddingMap: Record<CardPadding, number> = {
  none: 0,
  sm: hustleSpacing.sm,
  md: hustleSpacing.md,
  lg: hustleSpacing.lg,
  xl: hustleSpacing.xl,
};

export const HCard: React.FC<HCardProps> = ({
  children,
  variant = 'default',
  padding = 'lg',
  onPress,
  style,
}) => {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    if (onPress) {
      scale.value = withSpring(0.98, { damping: 20, stiffness: 400 });
    }
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const variantStyles = getVariantStyles(variant);

  const cardContent = (
    <>
      {/* Glass shine overlay */}
      <LinearGradient
        colors={hustleGradients.cardShine as unknown as string[]}
        style={StyleSheet.absoluteFill}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />
      <View style={{ padding: paddingMap[padding] }}>
        {children}
      </View>
    </>
  );

  if (onPress) {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        style={[styles.card, variantStyles, animatedStyle, style]}
      >
        {cardContent}
      </AnimatedPressable>
    );
  }

  return (
    <View style={[styles.card, variantStyles, style]}>
      {cardContent}
    </View>
  );
};

function getVariantStyles(variant: CardVariant): ViewStyle {
  switch (variant) {
    case 'elevated':
      return {
        backgroundColor: hustleColors.dark.surface,
        ...hustleShadows.lg,
      };
    case 'outlined':
      return {
        backgroundColor: 'transparent',
        borderWidth: 1,
        borderColor: hustleColors.purple.soft,
      };
    case 'success':
      return {
        backgroundColor: hustleColors.dark.elevated,
        borderWidth: 1,
        borderColor: `${hustleColors.semantic.success}44`,
        ...hustleShadows.moneyGlow,
      };
    default:
      return {
        backgroundColor: hustleColors.dark.elevated,
      };
  }
}

const styles = StyleSheet.create({
  card: {
    borderRadius: hustleRadii.xl,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    overflow: 'hidden',
  },
});

/**
 * HStatCard - Card showing a stat with label
 * Implies: "Activity is happening"
 */
interface HStatCardProps {
  label: string;
  value: string | number;
  color?: string;
  onPress?: () => void;
}

export const HStatCard: React.FC<HStatCardProps> = ({
  label,
  value,
  color = hustleColors.text.primary,
  onPress,
}) => (
  <HCard variant="default" padding="md" onPress={onPress} style={statStyles.card}>
    <View style={statStyles.content}>
      <Animated.Text style={[statStyles.value, { color }]}>{value}</Animated.Text>
      <Animated.Text style={statStyles.label}>{label}</Animated.Text>
    </View>
  </HCard>
);

const statStyles = StyleSheet.create({
  card: {
    minWidth: 100,
  },
  content: {
    alignItems: 'center',
  },
  value: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 4,
  },
  label: {
    fontSize: 12,
    color: hustleColors.text.tertiary,
  },
});
