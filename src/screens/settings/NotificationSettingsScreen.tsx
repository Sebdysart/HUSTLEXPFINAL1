import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function NotificationSettingsScreen() {
  const [pushNotifications, setPushNotifications] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [smsNotifications, setSmsNotifications] = useState(false);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Notification Settings</Text>

      <View style={styles.section}>
        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>Push Notifications</Text>
            <Text style={styles.settingDescription}>
              Receive push notifications on your device
            </Text>
          </View>
          <Switch
            value={pushNotifications}
            onValueChange={setPushNotifications}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>Email Notifications</Text>
            <Text style={styles.settingDescription}>
              Receive notifications via email
            </Text>
          </View>
          <Switch
            value={emailNotifications}
            onValueChange={setEmailNotifications}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingLabel}>SMS Notifications</Text>
            <Text style={styles.settingDescription}>
              Receive notifications via SMS
            </Text>
          </View>
          <Switch
            value={smsNotifications}
            onValueChange={setSmsNotifications}
            trackColor={{ false: NEUTRAL.BORDER, true: '#10B981' }}
            thumbColor={NEUTRAL.TEXT_INVERSE}
          />
        </View>
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
});
