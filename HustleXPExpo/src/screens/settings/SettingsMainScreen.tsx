import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../../auth/AuthProvider';
import { useAppState } from '../../app/state';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';

function ListItem({
  title,
  subtitle,
  onPress,
}: {
  title: string;
  subtitle?: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity style={styles.item} activeOpacity={0.85} onPress={onPress}>
      <View style={{ flex: 1 }}>
        <Text style={styles.itemTitle}>{title}</Text>
        {subtitle ? <Text style={styles.itemSubtitle}>{subtitle}</Text> : null}
      </View>
      <Text style={styles.chevron}>{'>'}</Text>
    </TouchableOpacity>
  );
}

export default function SettingsMainScreen() {
  const navigation = useNavigation<any>();
  const { signOut } = useAuth();
  const appState = useAppState();

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.headerCard}>
          <Text style={styles.title}>Settings</Text>
          <Text style={styles.subtitle}>
            {appState.userName ? appState.userName : '—'} · Trust tier {appState.trustTier}
          </Text>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          <ListItem title="Account Settings" subtitle="Profile & security" onPress={() => navigation.navigate('AccountSettings')} />
          <ListItem title="Notifications" subtitle="Email and push preferences" onPress={() => navigation.navigate('NotificationSettings')} />
          <ListItem title="Payment Methods" subtitle="Cards and payout settings" onPress={() => navigation.navigate('PaymentSettings')} />
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Privacy & Security</Text>
          <ListItem title="Privacy" subtitle="Privacy controls" onPress={() => navigation.navigate('PrivacySettings')} />
          <ListItem title="Verification" subtitle="Trust tier verification status" onPress={() => navigation.navigate('Verification')} />
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Support</Text>
          <ListItem title="Help & Support" subtitle="FAQs and contact" onPress={() => navigation.navigate('Support')} />
        </View>

        <TouchableOpacity style={styles.logoutButton} activeOpacity={0.85} onPress={() => signOut()}>
          <Text style={styles.logoutText}>Log Out</Text>
        </TouchableOpacity>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: 32,
  },
  headerCard: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: GRAY[200],
    borderRadius: 16,
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  title: {
    fontSize: 22,
    fontWeight: '900',
    color: GRAY[900],
  },
  subtitle: {
    marginTop: 6,
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '600',
  },
  section: {
    marginBottom: SPACING[4],
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: GRAY[200],
    borderRadius: 16,
    overflow: 'hidden',
  },
  sectionTitle: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: SPACING[2],
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '900',
  },
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    borderTopWidth: 1,
    borderTopColor: GRAY[200],
  },
  itemTitle: {
    fontSize: 14,
    fontWeight: '900',
    color: GRAY[900],
  },
  itemSubtitle: {
    marginTop: 2,
    fontSize: 12,
    color: GRAY[600],
    fontWeight: '600',
  },
  chevron: {
    color: GRAY[500],
    fontSize: 18,
    fontWeight: '700',
    paddingLeft: SPACING[2],
  },
  logoutButton: {
    marginTop: SPACING[2],
    height: 52,
    borderRadius: 14,
    backgroundColor: '#EF4444',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoutText: {
    color: '#fff',
    fontWeight: '900',
    fontSize: 16,
  },
});
