/**
 * SettingsScreen - App settings
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';

export function SettingsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { logout } = useAuthStore();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Settings</Text>

        <Spacing size={24} />

        {/* Account */}
        <Text variant="headline" color="secondary">Account</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="👤" label="Edit Profile" />
          <SettingsRow icon="🔔" label="Notifications" />
          <SettingsRow icon="🔒" label="Privacy & Security" />
          <SettingsRow icon="💳" label="Payment Methods" last />
        </Card>

        <Spacing size={24} />

        {/* Preferences */}
        <Text variant="headline" color="secondary">Preferences</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="📍" label="Location Settings" />
          <SettingsRow icon="🌙" label="Dark Mode" value="On" />
          <SettingsRow icon="🔤" label="Language" value="English" last />
        </Card>

        <Spacing size={24} />

        {/* Support */}
        <Text variant="headline" color="secondary">Support</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="❓" label="Help Center" />
          <SettingsRow icon="💬" label="Contact Support" />
          <SettingsRow icon="📝" label="Send Feedback" />
          <SettingsRow icon="📜" label="Terms of Service" />
          <SettingsRow icon="🔐" label="Privacy Policy" last />
        </Card>

        <Spacing size={24} />

        {/* Danger Zone */}
        <Card variant="default" padding="none">
          <SettingsRow icon="🚪" label="Sign Out" danger />
          <SettingsRow icon="🗑️" label="Delete Account" danger last />
        </Card>

        <Spacing size={24} />

        <Text variant="caption" color="tertiary" align="center">
          HustleXP v1.0.0
        </Text>
      </ScrollView>
    </View>
  );
}

function SettingsRow({ icon, label, value, danger, last }: { 
  icon: string; 
  label: string; 
  value?: string; 
  danger?: boolean;
  last?: boolean;
}) {
  return (
    <TouchableOpacity style={[styles.row, !last && styles.rowBorder]}>
      <Text variant="body">{icon}</Text>
      <Text variant="body" color={danger ? 'danger' : 'primary'} style={styles.rowLabel}>{label}</Text>
      {value && <Text variant="body" color="secondary">{value}</Text>}
      <Text variant="body" color="tertiary"> ›</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  row: { 
    flexDirection: 'row', 
    alignItems: 'center', 
    padding: theme.spacing[4],
  },
  rowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.surface.secondary,
  },
  rowLabel: { flex: 1, marginLeft: theme.spacing[3] },
});

export default SettingsScreen;
