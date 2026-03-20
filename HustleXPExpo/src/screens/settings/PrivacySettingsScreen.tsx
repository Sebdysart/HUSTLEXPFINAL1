import React from 'react';
import { ScrollView, StyleSheet, Switch, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';

export default function PrivacySettingsScreen() {
  // SwiftUI parity for these settings can be ported from the backend-backed Preferences model.
  // For now this is a UI shell.
  const [profileVisibility, setProfileVisibility] = React.useState(true);
  const [showOnlineStatus, setShowOnlineStatus] = React.useState(false);

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Privacy</Text>

        <View style={styles.card}>
          <Row
            title="Profile visibility"
            subtitle="Allow others to view your profile"
            value={profileVisibility}
            onChange={setProfileVisibility}
          />
          <View style={styles.divider} />
          <Row
            title="Online status"
            subtitle="Show whether you are active"
            value={showOnlineStatus}
            onChange={setShowOnlineStatus}
          />
        </View>

        <Text style={styles.note}>
          These controls are not wired to backend yet in this Expo port.
        </Text>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function Row({
  title,
  subtitle,
  value,
  onChange,
}: {
  title: string;
  subtitle: string;
  value: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.rowTitle}>{title}</Text>
        <Text style={styles.rowSubtitle}>{subtitle}</Text>
      </View>
      <Switch value={value} onValueChange={onChange} trackColor={{ true: '#5B2DFF', false: GRAY[200] }} />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  scrollContent: { paddingHorizontal: SPACING[4], paddingTop: SPACING[3], paddingBottom: 32 },
  title: { fontSize: 22, fontWeight: '900', color: GRAY[900], marginBottom: SPACING[4] },
  card: { backgroundColor: '#fff', borderRadius: 16, borderWidth: 1, borderColor: GRAY[200], padding: SPACING[4] },
  row: { flexDirection: 'row', alignItems: 'center', paddingVertical: SPACING[2] },
  rowTitle: { fontSize: 14, fontWeight: '900', color: GRAY[900] },
  rowSubtitle: { marginTop: 4, fontSize: 12, fontWeight: '600', color: GRAY[600] },
  divider: { height: 1, backgroundColor: GRAY[200] },
  note: { marginTop: SPACING[2], color: GRAY[600], fontSize: 12, fontWeight: '700', textAlign: 'center' },
});
