/**
 * HScreen - Base screen wrapper
 * 
 * CHOSEN-STATE CONTRACT:
 * - Never feels empty (ambient motion always present)
 * - Dark void foundation
 * - Safe area handled
 * - Scroll behavior standardized
 */

import React, { ReactNode } from 'react';
import { View, ScrollView, StyleSheet, StatusBar, ViewStyle } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import LinearGradient from 'react-native-linear-gradient';
import { hustleColors, hustleGradients } from '../../theme/hustle-tokens';
import { HAmbientOrb } from './HAmbient';

interface HScreenProps {
  children: ReactNode;
  /** Show ambient orb animation */
  ambient?: boolean;
  /** Scroll content */
  scroll?: boolean;
  /** Custom padding */
  padding?: number;
  /** Header component */
  header?: ReactNode;
  /** Footer component (fixed at bottom) */
  footer?: ReactNode;
  /** Custom style */
  style?: ViewStyle;
}

export const HScreen: React.FC<HScreenProps> = ({
  children,
  ambient = true,
  scroll = true,
  padding = 20,
  header,
  footer,
  style,
}) => {
  const insets = useSafeAreaInsets();

  const content = scroll ? (
    <ScrollView
      contentContainerStyle={[
        styles.scrollContent,
        { padding, paddingBottom: padding + (footer ? 100 : 0) },
      ]}
      showsVerticalScrollIndicator={false}
    >
      {children}
    </ScrollView>
  ) : (
    <View style={[styles.content, { padding }, style]}>
      {children}
    </View>
  );

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <StatusBar barStyle="light-content" backgroundColor={hustleColors.dark.void} />
      
      {/* Background gradient */}
      <LinearGradient
        colors={hustleGradients.backgroundMesh}
        style={StyleSheet.absoluteFill}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      {/* Ambient orb - system is alive */}
      {ambient && <HAmbientOrb />}
      
      {/* Header */}
      {header && <View style={styles.header}>{header}</View>}
      
      {/* Content */}
      {content}
      
      {/* Footer */}
      {footer && (
        <View style={[styles.footer, { paddingBottom: insets.bottom + 16 }]}>
          {footer}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: hustleColors.dark.void,
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  header: {
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  footer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 20,
    paddingTop: 16,
    backgroundColor: hustleColors.dark.void,
    borderTopWidth: 1,
    borderTopColor: hustleColors.glass.border,
  },
});
