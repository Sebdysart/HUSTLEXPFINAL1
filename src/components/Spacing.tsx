/**
 * Spacing Component
 * Simple spacer for layout gaps
 */

import React from 'react';
import { View, ViewStyle } from 'react-native';
import { spacing, SpacingKey } from '../theme';

export interface SpacingProps {
  /** Preset size from design tokens OR numeric px value */
  size?: SpacingKey | number;
  /** Custom height in pixels */
  height?: number;
  /** Custom width in pixels */
  width?: number;
  /** Flex grow (for flexible spacing) */
  flex?: number;
}

export const Spacing: React.FC<SpacingProps> = ({
  size,
  height,
  width,
  flex,
}) => {
  const style: ViewStyle = {};

  if (size !== undefined) {
    const value = typeof size === 'number' ? size : spacing[size];
    style.height = value;
    style.width = value;
  }

  if (height !== undefined) {
    style.height = height;
  }

  if (width !== undefined) {
    style.width = width;
  }

  if (flex !== undefined) {
    style.flex = flex;
  }

  return <View style={style} />;
};

// Convenience exports for common spacings
export const SpaceXS: React.FC = () => <Spacing size="xs" />;
export const SpaceSM: React.FC = () => <Spacing size="sm" />;
export const SpaceMD: React.FC = () => <Spacing size="md" />;
export const SpaceLG: React.FC = () => <Spacing size="lg" />;
export const SpaceXL: React.FC = () => <Spacing size="xl" />;
export const Space2XL: React.FC = () => <Spacing size="2xl" />;
export const Space3XL: React.FC = () => <Spacing size="3xl" />;
export const Space4XL: React.FC = () => <Spacing size="4xl" />;
export const Space5XL: React.FC = () => <Spacing size="5xl" />;
export const Flex: React.FC = () => <Spacing flex={1} />;

// Horizontal spacers
export const HSpaceXS: React.FC = () => <Spacing width={4} height={0} />;
export const HSpaceSM: React.FC = () => <Spacing width={8} height={0} />;
export const HSpaceMD: React.FC = () => <Spacing width={12} height={0} />;
export const HSpaceLG: React.FC = () => <Spacing width={16} height={0} />;

export default Spacing;
