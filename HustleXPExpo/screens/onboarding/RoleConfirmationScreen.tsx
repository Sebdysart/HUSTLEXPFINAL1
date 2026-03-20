import React, { useMemo, useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View, Vibration } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useAppState } from '../../src/app/state';
import type { UserRole } from '../../src/app/types';

const COLORS = {
  black: '#050507',
  purple: '#5B2DFF',
  purpleBright: '#7B4DFF',
  textPrimary: '#FFFFFF',
  textSecondary: '#8E8E93',
  surfaceElevated: 'rgba(255,255,255,0.06)',
  borderSubtle: 'rgba(255,255,255,0.12)',
} as const;

type RoleCardProps = {
  role: UserRole;
  title: string;
  subtitle: string;
  selected: boolean;
  onPress: () => void;
};

function RoleCard(props: RoleCardProps) {
  return (
    <TouchableOpacity
      style={[
        styles.card,
        props.selected ? { borderColor: COLORS.purple, backgroundColor: 'rgba(91,45,255,0.10)' } : null,
      ]}
      activeOpacity={0.9}
      onPress={() => {
        Vibration.vibrate(10);
        props.onPress();
      }}
    >
      <View style={styles.cardRow}>
        <View
          style={[
            styles.iconCircle,
            props.selected ? { borderColor: COLORS.purple, backgroundColor: 'rgba(91,45,255,0.18)' } : null,
          ]}
        >
          <Text style={styles.iconText}>{props.role === 'hustler' ? '🏃' : '📣'}</Text>
        </View>
        <View style={{ flex: 1 }}>
          <Text style={styles.cardTitle}>{props.title}</Text>
          <Text style={styles.cardSubtitle}>{props.subtitle}</Text>
        </View>
        <View style={[styles.radioOuter, props.selected ? { borderColor: COLORS.purple } : { borderColor: COLORS.borderSubtle }]}>
          {props.selected ? <View style={styles.radioInner} /> : null}
        </View>
      </View>
    </TouchableOpacity>
  );
}

export function RoleConfirmationScreen() {
  const navigation = useNavigation<any>();
  const appState = useAppState();

  const [selectedRole, setSelectedRole] = useState<UserRole | null>(appState.userRole);

  const canContinue = useMemo(() => selectedRole !== null, [selectedRole]);

  const handleContinue = () => {
    if (!selectedRole) return;
    Vibration.vibrate(15);
    appState.setRole(selectedRole);
    navigation.navigate('PreferenceLock');
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>How will you use HustleXP?</Text>
          <Text style={styles.subtitle}>You can switch anytime in settings</Text>
        </View>

        <View style={{ height: 16 }} />

        <RoleCard
          role="hustler"
          title="Hustler"
          subtitle="Find tasks and earn money"
          selected={selectedRole === 'hustler'}
          onPress={() => setSelectedRole('hustler')}
        />

        <View style={{ height: 12 }} />

        <RoleCard
          role="poster"
          title="Poster"
          subtitle="Post tasks and get help"
          selected={selectedRole === 'poster'}
          onPress={() => setSelectedRole('poster')}
        />

        <View style={{ flex: 1 }} />

        <View style={styles.bottomBar}>
          <TouchableOpacity
            style={[
              styles.continueButton,
              !canContinue ? { opacity: 0.55 } : null,
            ]}
            disabled={!canContinue}
            onPress={handleContinue}
          >
            <Text style={styles.continueText}>Continue</Text>
            <Text style={styles.chevron}>{'›'}</Text>
          </TouchableOpacity>
          {!canContinue ? (
            <Text style={styles.helperText}>Select a role to continue</Text>
          ) : null}
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: COLORS.black },
  container: { flex: 1, paddingHorizontal: 20, paddingTop: 10 },
  header: { marginTop: 10 },
  title: { color: COLORS.textPrimary, fontSize: 26, fontWeight: '800', textAlign: 'center', lineHeight: 32 },
  subtitle: { color: COLORS.textSecondary, fontSize: 14, textAlign: 'center', marginTop: 10 },
  card: {
    borderWidth: 1,
    borderColor: COLORS.borderSubtle,
    backgroundColor: COLORS.surfaceElevated,
    borderRadius: 14,
    padding: 14,
  },
  cardRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  iconCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: COLORS.borderSubtle,
    backgroundColor: 'rgba(255,255,255,0.04)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconText: { fontSize: 18 },
  cardTitle: { color: COLORS.textPrimary, fontSize: 18, fontWeight: '800' },
  cardSubtitle: { color: COLORS.textSecondary, fontSize: 13, marginTop: 4 },
  radioOuter: {
    width: 26,
    height: 26,
    borderRadius: 13,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  radioInner: { width: 12, height: 12, borderRadius: 6, backgroundColor: COLORS.purple },
  bottomBar: { paddingBottom: 12 },
  continueButton: {
    height: 50,
    borderRadius: 12,
    backgroundColor: COLORS.purple,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  continueText: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 16 },
  chevron: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 18, marginLeft: 2 },
  helperText: { color: COLORS.textSecondary, fontSize: 12, marginTop: 10, textAlign: 'center' },
});

