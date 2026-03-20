import React, { useEffect, useMemo, useState } from 'react';
import { Alert, ScrollView, Switch, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TRPCClient } from '../../network/trpcClient';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';
import { StatusBanner } from '../../components/molecules';
import type { UserRole } from '../../app/types';
import { useAppState } from '../../app/state';

type NotificationPreferences = {
  pushEnabled: boolean;
  emailEnabled: boolean;
  taskUpdates: boolean;
  paymentUpdates: boolean;
  messageNotifications: boolean;
  marketingEmails: boolean;
};

export default function NotificationSettingsScreen() {
  const appState = useAppState();
  const [prefs, setPrefs] = useState<NotificationPreferences | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;

    (async () => {
      try {
        setLoading(true);
        setError(null);

        const backendPrefs = await TRPCClient.shared.call<{}, NotificationPreferences>(
          'notification',
          'getPreferences',
          'query',
          {} as any
        );

        if (!mounted) return;
        setPrefs(backendPrefs);
      } catch (e) {
        if (!mounted) return;
        setError(e instanceof Error ? e.message : 'Failed to load preferences');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const pushEnabled = prefs?.pushEnabled ?? false;

  const canSave = useMemo(() => !!prefs && !saving, [prefs, saving]);

  const savePreferences = async (next: NotificationPreferences) => {
    if (!canSave) return;
    try {
      setSaving(true);
      setError(null);

      // SwiftUI maps frontend prefs -> backend updatePreferences input schema:
      // { pushEnabled, emailEnabled, categoryPreferences: { taskUpdates, paymentUpdates, messageNotifications, marketingEmails } }
      await TRPCClient.shared.call<
        {
          pushEnabled: boolean;
          emailEnabled: boolean;
          categoryPreferences: {
            taskUpdates: boolean;
            paymentUpdates: boolean;
            messageNotifications: boolean;
            marketingEmails: boolean;
          };
        },
        any
      >('notification', 'updatePreferences', 'mutation', {
        pushEnabled: next.pushEnabled,
        emailEnabled: next.emailEnabled,
        categoryPreferences: {
          taskUpdates: next.taskUpdates,
          paymentUpdates: next.paymentUpdates,
          messageNotifications: next.messageNotifications,
          marketingEmails: next.marketingEmails,
        },
      } as any);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not save preferences');
      Alert.alert('Save failed', e instanceof Error ? e.message : 'Could not save preferences');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <Text style={styles.title}>Notifications</Text>
          <Text style={styles.subtle}>Loading preferences...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (!prefs || error) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <Text style={styles.title}>Notifications</Text>
          {error ? <Text style={styles.error}>{error}</Text> : null}
          <View style={{ height: SPACING[4] }} />
          <Text style={styles.subtle}>Please try again later.</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Notifications</Text>

        {!pushEnabled ? (
          <View style={styles.banner}>
            <StatusBanner tone="warning" text="Push is disabled. Alert types are inactive." />
          </View>
        ) : null}

        <Section title="Push Notifications">
          <ToggleRow
            icon="bell"
            iconColor="#5B2DFF"
            title="Push Notifications"
            subtitle="Receive notifications on your device"
            value={prefs.pushEnabled}
            onChange={(v) => {
              const next = { ...prefs, pushEnabled: v };
              setPrefs(next);
              savePreferences(next);
            }}
          />
        </Section>

        <Section title="Alert Types">
          <View style={!pushEnabled ? styles.dimmed : null}>
            <ToggleRow
              icon="briefcase"
              iconColor="#3B82F6"
              title="New Task Opportunities"
              subtitle="Tasks matching your skills nearby"
              value={prefs.taskUpdates}
              disabled={!pushEnabled}
              onChange={(v) => {
                const next = { ...prefs, taskUpdates: v };
                setPrefs(next);
                savePreferences(next);
              }}
            />

            <ToggleRow
              icon="message"
              iconColor="#5B2DFF"
              title="Messages"
              subtitle="Chat messages from posters/hustlers"
              value={prefs.messageNotifications}
              disabled={!pushEnabled}
              onChange={(v) => {
                const next = { ...prefs, messageNotifications: v };
                setPrefs(next);
                savePreferences(next);
              }}
            />

            <ToggleRow
              icon="dollarsign"
              iconColor="#10B981"
              title="Payments"
              subtitle="Payment received and payout updates"
              value={prefs.paymentUpdates}
              disabled={!pushEnabled}
              onChange={(v) => {
                const next = { ...prefs, paymentUpdates: v };
                setPrefs(next);
                savePreferences(next);
              }}
            />
          </View>
        </Section>

        <Section title="Email">
          <ToggleRow
            icon="envelope"
            iconColor="#3B82F6"
            title="Email Notifications"
            subtitle="Summaries and important updates"
            value={prefs.emailEnabled}
            onChange={(v) => {
              const next = { ...prefs, emailEnabled: v };
              setPrefs(next);
              savePreferences(next);
            }}
          />

          <ToggleRow
            icon="megaphone"
            iconColor="#5B2DFF"
            title="Marketing & Promotions"
            subtitle="Tips, promotions, and new features"
            value={prefs.marketingEmails}
            disabled={!prefs.emailEnabled}
            onChange={(v) => {
              const next = { ...prefs, marketingEmails: v };
              setPrefs(next);
              savePreferences(next);
            }}
          />
        </Section>

        <Text style={styles.note}>
          You can also manage notifications in your device's Settings app.
        </Text>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      <View style={styles.sectionBody}>{children}</View>
    </View>
  );
}

function ToggleRow({
  icon,
  iconColor,
  title,
  subtitle,
  value,
  disabled,
  onChange,
}: {
  icon: string;
  iconColor: string;
  title: string;
  subtitle: string;
  value: boolean;
  disabled?: boolean;
  onChange: (next: boolean) => void;
}) {
  return (
    <View style={styles.row}>
      <View style={[styles.iconCircle, { backgroundColor: `${iconColor}22` }]}>
        <Text style={[styles.iconText, { color: iconColor }]}>{icon}</Text>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.rowTitle}>{title}</Text>
        <Text style={styles.rowSubtitle}>{subtitle}</Text>
      </View>
      <Switch
        value={value}
        onValueChange={onChange}
        disabled={disabled}
        trackColor={{ false: GRAY[200], true: iconColor }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  content: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: 32,
  },
  title: {
    fontSize: 22,
    fontWeight: '800',
    color: GRAY[900],
    marginBottom: SPACING[3],
  },
  subtle: {
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '600',
  },
  error: {
    marginTop: SPACING[2],
    color: '#EF4444',
    fontWeight: '800',
  },
  banner: {
    marginBottom: SPACING[3],
  },
  section: {
    marginBottom: SPACING[4],
  },
  sectionTitle: {
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '800',
    marginBottom: SPACING[2],
  },
  sectionBody: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[3],
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING[3],
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING[3],
  },
  iconText: {
    fontSize: 12,
    fontWeight: '800',
  },
  rowTitle: {
    fontSize: 14,
    fontWeight: '800',
    color: GRAY[900],
  },
  rowSubtitle: {
    marginTop: 2,
    fontSize: 12,
    color: GRAY[600],
  },
  note: {
    marginTop: SPACING[2],
    color: GRAY[600],
    fontSize: 12,
    textAlign: 'center',
  },
  dimmed: {
    opacity: 0.5,
  },
});
