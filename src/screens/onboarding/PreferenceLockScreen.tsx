/**
 * PreferenceLockScreen - Confirm preferences before proceeding
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';

export function PreferenceLockScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed

  const handleConfirm = () => {
    console.log('Preferences confirmed');
  };

  const handleEdit = () => {
    console.log('Edit preferences');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.header}>
          <Text variant="title1" color="primary" align="center">
            Ready to go!
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Here's what we've set up for you
          </Text>
        </View>

        <Spacing size={32} />

        <Card variant="default" padding="lg">
          <PreferenceRow label="Role" value="Hustler & Poster" />
          <Spacing size={16} />
          <PreferenceRow label="Interests" value="Delivery, Tech Help, Assembly" />
          <Spacing size={16} />
          <PreferenceRow label="Notifications" value="Enabled" />
        </Card>

        <Spacing size={16} />

        <Button variant="ghost" size="sm" onPress={handleEdit}>
          Edit preferences
        </Button>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={handleConfirm}>
          Let's Go!
        </Button>
      </View>
    </View>
  );
}

function PreferenceRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.prefRow}>
      <Text variant="footnote" color="secondary">{label}</Text>
      <Text variant="body" color="primary">{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  content: {
    flex: 1,
    paddingHorizontal: theme.spacing[4],
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  prefRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  footer: {
    paddingHorizontal: theme.spacing[4],
    paddingBottom: theme.spacing[4],
  },
});

export default PreferenceLockScreen;
