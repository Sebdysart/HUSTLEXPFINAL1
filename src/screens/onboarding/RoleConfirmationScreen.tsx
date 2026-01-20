import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Button } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function RoleConfirmationScreen() {
  const navigation = useNavigation();
  const [selectedRole, setSelectedRole] = useState<'hustler' | 'poster' | 'both' | null>(null);

  const handleContinue = () => {
    console.log('Continue button pressed', { selectedRole });
    navigation.navigate('O4' as never);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Choose Your Role</Text>
      <Text style={styles.description}>Select how you want to use HustleXP</Text>
      
      <TouchableOpacity
        style={[styles.card, selectedRole === 'hustler' && styles.cardSelected]}
        onPress={() => setSelectedRole('hustler')}
      >
        <Text style={styles.cardTitle}>Hustler</Text>
        <Text style={styles.cardDescription}>Complete tasks and earn</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.card, selectedRole === 'poster' && styles.cardSelected]}
        onPress={() => setSelectedRole('poster')}
      >
        <Text style={styles.cardTitle}>Poster</Text>
        <Text style={styles.cardDescription}>Post tasks and get work done</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.card, selectedRole === 'both' && styles.cardSelected]}
        onPress={() => setSelectedRole('both')}
      >
        <Text style={styles.cardTitle}>Both</Text>
        <Text style={styles.cardDescription}>Post and complete tasks</Text>
      </TouchableOpacity>

      <Button title="Continue" onPress={handleContinue} disabled={!selectedRole} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[6],
  },
  card: {
    padding: SPACING[4],
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  cardSelected: {
    borderColor: NEUTRAL.TEXT,
    borderWidth: 2,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
  },
  cardTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  cardDescription: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
});
