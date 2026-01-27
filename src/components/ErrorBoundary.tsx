/**
 * Error Boundary - Catches JS errors in component tree
 */

import React, { Component, ErrorInfo, ReactNode } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Text } from './Text';
import { colors, spacing, radii } from '../theme';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <View style={styles.container}>
          <View style={styles.content}>
            <Text variant="title1" style={styles.emoji}>😵</Text>
            <Text variant="title2" bold style={styles.title}>
              Something went wrong
            </Text>
            <Text variant="body" color="tertiary" style={styles.message}>
              We hit an unexpected error. Try again or restart the app.
            </Text>
            
            {__DEV__ && this.state.error && (
              <View style={styles.errorBox}>
                <Text variant="caption" color="danger">
                  {this.state.error.message}
                </Text>
              </View>
            )}
            
            <TouchableOpacity 
              style={styles.button} 
              onPress={this.handleRetry}
              activeOpacity={0.8}
            >
              <Text variant="callout" bold color={colors.black}>
                Try Again
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface.primary,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  content: {
    alignItems: 'center',
    maxWidth: 300,
  },
  emoji: {
    fontSize: 64,
    marginBottom: spacing.lg,
  },
  title: {
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  message: {
    textAlign: 'center',
    marginBottom: spacing.xl,
  },
  errorBox: {
    backgroundColor: colors.surface.tertiary,
    padding: spacing.md,
    borderRadius: radii.md,
    marginBottom: spacing.xl,
    width: '100%',
  },
  button: {
    backgroundColor: colors.primary,
    paddingHorizontal: spacing['2xl'],
    paddingVertical: spacing.md,
    borderRadius: radii.full,
  },
});
