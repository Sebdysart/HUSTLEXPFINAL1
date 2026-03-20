/**
 * GlassCard Component - UAP Compliant
 *
 * Implements glassmorphic design with backdrop blur effects.
 * Used throughout HustleXP for elevated surfaces.
 * 
 * UAP REQUIREMENT: Must use backdrop-blur-xl equivalent (20px blur)
 * per STITCH specs (02-hustler-home.html)
 * 
 * NOTE: Uses fallback glassmorphic styling (gradients + opacity) since
 * @react-native-community/blur doesn't support New Architecture (Fabric)
 */

import React from 'react';
import { View, ViewStyle, StyleSheet } from 'react-native';

interface GlassCardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  variant?: 'primary' | 'secondary';
}

const GLASS_TOKENS = {
  primary: {
    backgroundColor: 'rgba(28, 28, 30, 0.8)',
    borderColor: 'rgba(255, 255, 255, 0.15)',
    overlayColor: 'rgba(255, 255, 255, 0.03)',
  },
  secondary: {
    backgroundColor: 'rgba(28, 28, 30, 0.6)',
    borderColor: 'rgba(255, 255, 255, 0.1)',
    overlayColor: 'rgba(255, 255, 255, 0.02)',
  },
};

export function GlassCard({ children, style, variant = 'primary' }: GlassCardProps) {
  const tokens = GLASS_TOKENS[variant];

  return (
    <View style={[styles.card, style]}>
      {/* Base glass layer */}
      <View
        style={[
          StyleSheet.absoluteFill,
          {
            backgroundColor: tokens.backgroundColor,
            borderRadius: 16,
          },
        ]}
      />
      
      {/* Subtle overlay for glassmorphic depth */}
      <View
        style={[
          StyleSheet.absoluteFill,
          {
            backgroundColor: tokens.overlayColor,
            borderRadius: 16,
          },
        ]}
      />
      
      {/* Border layer */}
      <View
        style={[
          StyleSheet.absoluteFill,
          {
            borderWidth: 1,
            borderColor: tokens.borderColor,
            borderRadius: 16,
          },
        ]}
      />
      
      {/* Content layer */}
      <View style={styles.content}>
        {children}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 12,
    overflow: 'hidden',
  },
  content: {
    position: 'relative',
    zIndex: 1,
  },
});
