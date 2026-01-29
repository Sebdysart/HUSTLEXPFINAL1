/**
 * TaskCreationScreen - Calibration archetype
 * 
 * CHOSEN-STATE: "What needs doing?" not "Create Task"
 * One step at a time. Never feels like a form.
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  FadeIn,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HInput } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore, useAuthStore, Task, TaskCategory } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type Step = 'category' | 'description' | 'budget' | 'review';

const CATEGORIES: { id: TaskCategory; emoji: string; label: string }[] = [
  { id: 'moving', emoji: '📦', label: 'Moving' },
  { id: 'cleaning', emoji: '🧹', label: 'Cleaning' },
  { id: 'delivery', emoji: '🚚', label: 'Delivery' },
  { id: 'assembly', emoji: '🔧', label: 'Assembly' },
  { id: 'handyman', emoji: '🔨', label: 'Handyman' },
  { id: 'yard_work', emoji: '🌱', label: 'Yard' },
  { id: 'pet_care', emoji: '🐕', label: 'Pet Care' },
  { id: 'errands', emoji: '🏃', label: 'Errands' },
  { id: 'tech_help', emoji: '💻', label: 'Tech' },
  { id: 'other', emoji: '✨', label: 'Other' },
];

export function TaskCreationScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { addTask } = useTaskStore();
  const { user } = useAuthStore();

  const [step, setStep] = useState<Step>('category');
  const [category, setCategory] = useState<TaskCategory | null>(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [budget, setBudget] = useState('');
  const [posting, setPosting] = useState(false);

  const handleBack = () => {
    switch (step) {
      case 'description':
        setStep('category');
        break;
      case 'budget':
        setStep('description');
        break;
      case 'review':
        setStep('budget');
        break;
      default:
        navigation.goBack();
    }
  };

  const handleNext = () => {
    switch (step) {
      case 'category':
        if (category) setStep('description');
        break;
      case 'description':
        if (title.trim()) setStep('budget');
        break;
      case 'budget':
        if (budget.trim()) setStep('review');
        break;
    }
  };

  const handlePost = async () => {
    if (!category || !title || !budget) return;

    setPosting(true);

    const newTask: Task = {
      id: `task_${Date.now()}`,
      title,
      description: description || title,
      category,
      status: 'open',
      posterId: user?.id || 'poster_1',
      posterName: user?.name || 'You',
      address: 'Seattle, WA',
      latitude: 47.6062,
      longitude: -122.3321,
      minPay: parseInt(budget, 10),
      maxPay: parseInt(budget, 10),
      baseXP: Math.round(parseInt(budget, 10) * 2),
      estimatedMinutes: 60,
      requiredTrustTier: 1,
      requiresVehicle: ['moving', 'delivery'].includes(category),
      requiresTools: [],
      requiresBackground: false,
    };

    addTask(newTask);
    setPosting(false);
    navigation.navigate('PosterHome');
  };

  const renderStep = () => {
    switch (step) {
      case 'category':
        return <CategoryStep category={category} setCategory={setCategory} />;
      case 'description':
        return (
          <DescriptionStep
            title={title}
            setTitle={setTitle}
            description={description}
            setDescription={setDescription}
          />
        );
      case 'budget':
        return <BudgetStep budget={budget} setBudget={setBudget} />;
      case 'review':
        return (
          <ReviewStep
            category={category!}
            title={title}
            budget={budget}
          />
        );
    }
  };

  const getButtonText = () => {
    switch (step) {
      case 'category':
        return category ? 'Continue' : 'Pick one';
      case 'description':
        return title.trim() ? 'Continue' : 'Add a title';
      case 'budget':
        return budget.trim() ? 'Review' : 'Set your budget';
      case 'review':
        return `Post — $${budget}`;
    }
  };

  const isStepValid = () => {
    switch (step) {
      case 'category':
        return !!category;
      case 'description':
        return title.trim().length > 0;
      case 'budget':
        return budget.trim().length > 0 && parseInt(budget, 10) > 0;
      case 'review':
        return true;
    }
  };

  return (
    <HScreen
      ambient
      scroll={false}
      header={
        <Pressable onPress={handleBack} style={styles.backButton}>
          <HText variant="body" color="purple">← Back</HText>
        </Pressable>
      }
      footer={
        <HButton
          variant={step === 'review' ? 'success' : 'primary'}
          size="lg"
          fullWidth
          onPress={step === 'review' ? handlePost : handleNext}
          disabled={!isStepValid()}
          loading={posting}
        >
          {getButtonText()}
        </HButton>
      }
    >
      <View style={styles.content}>
        {renderStep()}
      </View>
    </HScreen>
  );
}

// Step 1: Category
function CategoryStep({
  category,
  setCategory,
}: {
  category: TaskCategory | null;
  setCategory: (c: TaskCategory) => void;
}) {
  return (
    <Animated.View entering={FadeIn.duration(300)} style={styles.stepContainer}>
      <View style={styles.header}>
        <HText variant="title1" center>
          What needs doing?
        </HText>
        <View style={styles.headerSpacer} />
        <HText variant="body" color="secondary" center>
          Tap what fits
        </HText>
      </View>

      <View style={styles.spacer} />

      <View style={styles.grid}>
        {CATEGORIES.map((cat) => (
          <CategoryChip
            key={cat.id}
            emoji={cat.emoji}
            label={cat.label}
            selected={category === cat.id}
            onPress={() => setCategory(cat.id)}
          />
        ))}
      </View>
    </Animated.View>
  );
}

// Step 2: Description
function DescriptionStep({
  title,
  setTitle,
  description,
  setDescription,
}: {
  title: string;
  setTitle: (t: string) => void;
  description: string;
  setDescription: (d: string) => void;
}) {
  return (
    <Animated.View entering={FadeIn.duration(300)} style={styles.stepContainer}>
      <View style={styles.header}>
        <HText variant="title1" center>
          Tell us more
        </HText>
        <View style={styles.headerSpacer} />
        <HText variant="body" color="secondary" center>
          Keep it simple
        </HText>
      </View>

      <View style={styles.spacer} />

      <HInput
        label="What's the gig?"
        placeholder="e.g., Help moving furniture"
        value={title}
        onChangeText={setTitle}
        autoFocus
      />

      <View style={styles.inputSpacer} />

      <HInput
        label="Any details? (optional)"
        placeholder="Add context if it helps..."
        value={description}
        onChangeText={setDescription}
        multiline
        numberOfLines={3}
      />
    </Animated.View>
  );
}

// Step 3: Budget
function BudgetStep({
  budget,
  setBudget,
}: {
  budget: string;
  setBudget: (b: string) => void;
}) {
  return (
    <Animated.View entering={FadeIn.duration(300)} style={styles.stepContainer}>
      <View style={styles.header}>
        <HText variant="title1" center>
          What's it worth?
        </HText>
        <View style={styles.headerSpacer} />
        <HText variant="body" color="secondary" center>
          Fair pay attracts great hustlers
        </HText>
      </View>

      <View style={styles.spacer} />

      <View style={styles.budgetContainer}>
        <HText variant="hero" color="success">$</HText>
        <HInput
          placeholder="50"
          value={budget}
          onChangeText={(text) => setBudget(text.replace(/[^0-9]/g, ''))}
          keyboardType="numeric"
          containerStyle={styles.budgetInput}
          autoFocus
        />
      </View>

      {budget && parseInt(budget, 10) > 0 && (
        <View style={styles.feedback}>
          <HText variant="caption" color="purple" center>
            Hustlers earn ~${Math.round(parseInt(budget, 10) * 2)} XP
          </HText>
        </View>
      )}
    </Animated.View>
  );
}

// Step 4: Review
function ReviewStep({
  category,
  title,
  budget,
}: {
  category: TaskCategory;
  title: string;
  budget: string;
}) {
  const cat = CATEGORIES.find((c) => c.id === category);

  return (
    <Animated.View entering={FadeIn.duration(300)} style={styles.stepContainer}>
      <View style={styles.header}>
        <HText variant="title1" center>
          Looking good
        </HText>
        <View style={styles.headerSpacer} />
        <HText variant="body" color="secondary" center>
          Ready to post?
        </HText>
      </View>

      <View style={styles.spacer} />

      <HCard variant="elevated" padding="lg">
        <View style={styles.reviewRow}>
          <HText variant="title2">{cat?.emoji}</HText>
          <View style={styles.reviewText}>
            <HText variant="headline">{title}</HText>
            <HText variant="caption" color="secondary">{cat?.label}</HText>
          </View>
          <HText variant="title2" color="success">${budget}</HText>
        </View>
      </HCard>

      <View style={styles.feedback}>
        <HText variant="footnote" color="tertiary" center>
          Hustlers nearby will be notified
        </HText>
      </View>
    </Animated.View>
  );
}

// Reusable chip
function CategoryChip({
  emoji,
  label,
  selected,
  onPress,
}: {
  emoji: string;
  label: string;
  selected: boolean;
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 20, stiffness: 400 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={styles.chipWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard variant={selected ? 'outlined' : 'default'} padding="md">
          <View style={styles.chipContent}>
            <HText variant="title2">{emoji}</HText>
            <View style={styles.chipSpacer} />
            <HText
              variant="callout"
              color={selected ? 'primary' : 'secondary'}
              center
            >
              {label}
            </HText>
          </View>
        </HCard>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  stepContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing['2xl'],
  },
  inputSpacer: {
    height: hustleSpacing.lg,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  chipWrapper: {
    width: '48%',
    marginBottom: hustleSpacing.md,
  },
  chipContent: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.sm,
  },
  chipSpacer: {
    height: hustleSpacing.xs,
  },
  backButton: {
    paddingVertical: hustleSpacing.sm,
  },
  budgetContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  budgetInput: {
    flex: 0,
    width: 150,
    marginLeft: hustleSpacing.sm,
  },
  feedback: {
    marginTop: hustleSpacing.lg,
  },
  reviewRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.md,
  },
  reviewText: {
    flex: 1,
  },
});

export default TaskCreationScreen;
