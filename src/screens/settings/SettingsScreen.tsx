/**
 * SettingsScreen - App settings
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Grouped logically
 * - Toggles for booleans
 * - Navigation for sub-screens
 * - No overwhelming options
 * - Calm, organized, trustworthy
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Switch, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';
import { useAuthStore } from '../../store';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function SettingsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user, logout } = useAuthStore();

  // Toggle states
  const [darkMode, setDarkMode] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [locationServices, setLocationServices] = useState(true);

  const handleBack = () => navigation.goBack();

  const handleLogout = () => {
    Alert.alert(
      'Sign Out',
      'You\'ll need to sign in again to access your account.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Sign Out', 
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
      'This will permanently remove your account and all data. This can\'t be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Learn More', 
          onPress: () => Alert.alert('Contact Us', 'Please reach out to support@hustlexp.com for account deletion.')
        },
      ]
    );
  };

  const navigateTo = (screen: string) => {
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
        Alert.alert('Coming Soon', 'This feature is on the way.');
    }
  };

  return (
    <HScreen ambient={false}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
        <HButton variant="ghost" size="sm" onPress={handleBack}>
          ← Back
        </HButton>
        <HText variant="title2" color="primary">Settings</HText>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView 
        style={styles.scrollContainer}
        contentContainerStyle={styles.scroll}
      >
        {/* User Info */}
        <HCard variant="elevated" padding="md" style={styles.userCard}>
          <View style={styles.userRow}>
            <View style={styles.avatar}>
              <HText variant="title2">👤</HText>
            </View>
            <View style={styles.userInfo}>
              <HText variant="headline" color="primary">{user?.name || 'User'}</HText>
              <HText variant="caption" color="secondary">{user?.email || 'user@example.com'}</HText>
            </View>
            <HButton variant="ghost" size="sm" onPress={() => navigateTo('Profile')}>
              Edit
            </HButton>
          </View>
        </HCard>

        {/* Account Section */}
        <HText variant="footnote" color="tertiary" style={styles.sectionLabel}>
          ACCOUNT
        </HText>
        <HCard variant="default" padding="none" style={styles.sectionCard}>
          <SettingsRow icon="👤" label="Edit Profile" onPress={() => navigateTo('Profile')} />
          <SettingsRow icon="💳" label="Wallet" onPress={() => navigateTo('Wallet')} />
          <SettingsRow icon="📋" label="Work Eligibility" onPress={() => navigateTo('WorkEligibility')} last />
        </HCard>

        {/* Preferences Section */}
        <HText variant="footnote" color="tertiary" style={styles.sectionLabel}>
          PREFERENCES
        </HText>
        <HCard variant="default" padding="none" style={styles.sectionCard}>
          <SettingsToggle 
            icon="🔔" 
            label="Notifications" 
            value={notifications} 
            onToggle={setNotifications} 
          />
          <SettingsToggle 
            icon="📍" 
            label="Location Services" 
            value={locationServices} 
            onToggle={setLocationServices} 
          />
          <SettingsToggle 
            icon="🌙" 
            label="Dark Mode" 
            value={darkMode} 
            onToggle={setDarkMode}
            last
          />
        </HCard>

        {/* Support Section */}
        <HText variant="footnote" color="tertiary" style={styles.sectionLabel}>
          SUPPORT
        </HText>
        <HCard variant="default" padding="none" style={styles.sectionCard}>
          <SettingsRow icon="❓" label="Help Center" onPress={() => navigateTo('Help')} />
          <SettingsRow icon="💬" label="Contact Support" onPress={() => navigateTo('Support')} />
          <SettingsRow icon="📜" label="Terms of Service" onPress={() => navigateTo('Terms')} />
          <SettingsRow icon="🔐" label="Privacy Policy" onPress={() => navigateTo('Privacy')} last />
        </HCard>

        {/* Danger Zone */}
        <HCard variant="default" padding="none" style={styles.sectionCard}>
          <SettingsRow icon="🚪" label="Sign Out" onPress={handleLogout} />
          <SettingsRow 
            icon="🗑️" 
            label="Delete Account" 
            onPress={handleDeleteAccount} 
            danger 
            last 
          />
        </HCard>

        {/* Footer info */}
        <View style={styles.footer}>
          <HText variant="caption" color="tertiary" center>
            HustleXP v1.0.0
          </HText>
          <HText variant="caption" color="tertiary" center style={styles.footerDetail}>
            Trust Tier {user?.trustTier || 1} · {user?.xp || 0} XP
          </HText>
        </View>
      </ScrollView>
    </HScreen>
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
    <TouchableOpacity 
      style={[styles.row, !last && styles.rowBorder]} 
      onPress={onPress}
      activeOpacity={0.7}
    >
      <HText variant="body">{icon}</HText>
      <HText 
        variant="body" 
        color={danger ? 'error' : 'primary'} 
        style={styles.rowLabel}
      >
        {label}
      </HText>
      {value && <HText variant="body" color="secondary">{value}</HText>}
      <HText variant="body" color="tertiary">›</HText>
    </TouchableOpacity>
  );
}

interface SettingsToggleProps {
  icon: string;
  label: string;
  value: boolean;
  last?: boolean;
  onToggle: (value: boolean) => void;
}

function SettingsToggle({ icon, label, value, last, onToggle }: SettingsToggleProps) {
  return (
    <View style={[styles.row, !last && styles.rowBorder]}>
      <HText variant="body">{icon}</HText>
      <HText variant="body" color="primary" style={styles.rowLabel}>{label}</HText>
      <Switch
        value={value}
        onValueChange={onToggle}
        trackColor={{ 
          false: hustleColors.dark.surface, 
          true: hustleColors.purple.soft 
        }}
        thumbColor={hustleColors.white}
        ios_backgroundColor={hustleColors.dark.surface}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  headerSpacer: { width: 60 },
  scrollContainer: {
    flex: 1,
  },
  scroll: { 
    padding: hustleSpacing.lg,
    paddingTop: 0,
    paddingBottom: hustleSpacing['3xl'],
  },
  userCard: {
    marginBottom: hustleSpacing.xl,
  },
  userRow: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  avatar: { 
    width: 56, 
    height: 56, 
    borderRadius: 28, 
    backgroundColor: hustleColors.dark.surface, 
    justifyContent: 'center', 
    alignItems: 'center',
  },
  userInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  sectionLabel: {
    marginBottom: hustleSpacing.sm,
    marginTop: hustleSpacing.md,
    paddingLeft: hustleSpacing.sm,
  },
  sectionCard: {
    marginBottom: hustleSpacing.md,
  },
  row: { 
    flexDirection: 'row', 
    alignItems: 'center', 
    paddingVertical: hustleSpacing.md,
    paddingHorizontal: hustleSpacing.lg,
  },
  rowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: hustleColors.dark.border,
  },
  rowLabel: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  footer: {
    marginTop: hustleSpacing.xl,
    alignItems: 'center',
  },
  footerDetail: {
    marginTop: hustleSpacing.xs,
  },
});

export default SettingsScreen;
