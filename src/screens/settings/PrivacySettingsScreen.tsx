import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function PrivacySettingsScreen() {
  const [profileVisibility, setProfileVisibility] = useState(true);
  const [locationSharing, setLocationSharing] = useState(true);
  const [dataAnalytics, setDataAnalytics] = useState(false);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Privacy Settings</Text>

      <View style={styles.section}>
        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>Profile Visibility</Text>
            <Text style={styles.settingDescription}>
              Allow others to see your profile information
            </Text>
          </View>
          <Switch
            value={profileVisibility}
            onValueChange={setProfileVisibility}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>Location Sharing</Text>
            <Text style={styles.settingDescription}>
              Share your location for task matching
            </Text>
          </View>
          <Switch
            value={locationSharing}
            onValueChange={setLocationSharing}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>Data Analytics</Text>
            <Text style={styles.settingDescription}>
              Help improve HustleXP by sharing anonymous usage data
            </Text>
          </View>
          <Switch
            value={dataAnalytics}
            onValueChange={setDataAnalytics}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>
      </View>

      <View style={styles.infoCard}>
        <Text style={styles.infoTitle}>Your Privacy Matters</Text>
        <Text style={styles.infoText}>
          We take your privacy seriously. Your personal information is encrypted and never shared with third parties without your consent.
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  contentContainer: {
    padding: SPACING[4],
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[6],
  },
  section: {
    gap: SPACING[3],
    marginBottom: SPACING[6],
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
  },
  settingInfo: {
    flex: 1,
    marginRight: SPACING[4],
  },
  settingLabel: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  settingDescription: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  infoCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: '#10B981',
  },
  infoTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  infoText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
});
