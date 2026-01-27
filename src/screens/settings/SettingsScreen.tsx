/**
 * SettingsScreen - App settings
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function SettingsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user, logout } = useAuthStore();

  const handleBack = () => navigation.goBack();

  const handleLogout = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Sign Out', 
          style: 'destructive',
          onPress: () => {
            logout();
            navigation.reset({
              index: 0,
              routes: [{ name: 'Bootstrap' }],
            });
          }
        },
      ]
    );
  };

  const handleDeleteAccount = () => {
    Alert.alert(
      'Delete Account',
      'This action cannot be undone. All your data will be permanently deleted.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: () => Alert.alert('Contact Support', 'Please email support@hustlexp.com to delete your account.')
        },
      ]
    );
  };

  const handleNavigation = (screen: string) => {
    switch (screen) {
      case 'Profile':
        navigation.navigate('Profile');
        break;
      case 'Notifications':
        navigation.navigate('Notifications');
        break;
      case 'Wallet':
        navigation.navigate('Wallet');
        break;
      case 'WorkEligibility':
        navigation.navigate('WorkEligibility');
        break;
      default:
        Alert.alert('Coming Soon', 'This feature is not yet available.');
    }
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleBack}>
          <Text variant="body" color="primary">← Back</Text>
        </TouchableOpacity>
        <Text variant="title2" color="primary">Settings</Text>
        <View style={{ width: 50 }} />
      </View>

      <ScrollView contentContainerStyle={styles.scroll}>
        {/* User Info */}
        <Card variant="elevated" padding="md">
          <View style={styles.userRow}>
            <View style={styles.avatar}>
              <Text variant="title2">👤</Text>
            </View>
            <View style={styles.userInfo}>
              <Text variant="headline" color="primary">{user?.name || 'User'}</Text>
              <Text variant="caption" color="secondary">{user?.email || 'user@example.com'}</Text>
            </View>
            <TouchableOpacity onPress={() => handleNavigation('Profile')}>
              <Text variant="body" color="brand">Edit</Text>
            </TouchableOpacity>
          </View>
        </Card>

        <Spacing size={24} />

        {/* Account */}
        <Text variant="headline" color="secondary">Account</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="👤" label="Edit Profile" onPress={() => handleNavigation('Profile')} />
          <SettingsRow icon="🔔" label="Notifications" onPress={() => handleNavigation('Notifications')} />
          <SettingsRow icon="💳" label="Wallet & Payments" onPress={() => handleNavigation('Wallet')} />
          <SettingsRow icon="📋" label="Work Eligibility" onPress={() => handleNavigation('WorkEligibility')} last />
        </Card>

        <Spacing size={24} />

        {/* Preferences */}
        <Text variant="headline" color="secondary">Preferences</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="📍" label="Location Settings" onPress={() => handleNavigation('Location')} />
          <SettingsRow icon="🌙" label="Dark Mode" value="On" onPress={() => {}} />
          <SettingsRow icon="🔤" label="Language" value="English" onPress={() => {}} last />
        </Card>

        <Spacing size={24} />

        {/* Support */}
        <Text variant="headline" color="secondary">Support</Text>
        <Spacing size={12} />
        <Card variant="default" padding="none">
          <SettingsRow icon="❓" label="Help Center" onPress={() => handleNavigation('Help')} />
          <SettingsRow icon="💬" label="Contact Support" onPress={() => handleNavigation('Support')} />
          <SettingsRow icon="📜" label="Terms of Service" onPress={() => handleNavigation('Terms')} />
          <SettingsRow icon="🔐" label="Privacy Policy" onPress={() => handleNavigation('Privacy')} last />
        </Card>

        <Spacing size={24} />

        {/* Danger Zone */}
        <Card variant="default" padding="none">
          <SettingsRow icon="🚪" label="Sign Out" danger onPress={handleLogout} />
          <SettingsRow icon="🗑️" label="Delete Account" danger onPress={handleDeleteAccount} last />
        </Card>

        <Spacing size={24} />

        <Text variant="caption" color="tertiary" align="center">
          HustleXP v1.0.0
        </Text>
        <Spacing size={8} />
        <Text variant="caption" color="tertiary" align="center">
          {`Trust Tier ${user?.trustTier || 1} • ${user?.xp || 0} XP`}
        </Text>
      </ScrollView>
    </View>
  );
}

interface SettingsRowProps {
  icon: string;
  label: string;
  value?: string;
  danger?: boolean;
  last?: boolean;
  onPress: () => void;
}

function SettingsRow({ icon, label, value, danger, last, onPress }: SettingsRowProps) {
  return (
    <TouchableOpacity style={[styles.row, !last && styles.rowBorder]} onPress={onPress}>
      <Text variant="body">{icon}</Text>
      <Text variant="body" color={danger ? 'error' : 'primary'} style={styles.rowLabel}>{label}</Text>
      {value && <Text variant="body" color="secondary">{value}</Text>}
      <Text variant="body" color="tertiary"> ›</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    padding: theme.spacing[4],
  },
  scroll: { padding: theme.spacing[4], paddingTop: 0 },
  userRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { 
    width: 56, 
    height: 56, 
    borderRadius: 28, 
    backgroundColor: theme.colors.surface.tertiary, 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  userInfo: { flex: 1, marginLeft: theme.spacing[3] },
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
