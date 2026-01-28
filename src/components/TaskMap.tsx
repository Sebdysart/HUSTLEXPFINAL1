/**
 * TaskMap - Interactive map component for displaying task locations
 * 
 * Features:
 * - Shows task marker with custom pin
 * - User location indicator
 * - Distance calculation
 * - Tap to open directions
 */

import React, { useEffect, useRef, useState } from 'react';
import { StyleSheet, View, Platform, Linking, Alert, TouchableOpacity, Text } from 'react-native';
import MapView, { Marker, PROVIDER_DEFAULT, Region } from 'react-native-maps';
import { colors, typography } from '../theme';

interface TaskLocation {
  latitude: number;
  longitude: number;
  title?: string;
  description?: string;
}

interface TaskMapProps {
  location: TaskLocation;
  showUserLocation?: boolean;
  height?: number;
  interactive?: boolean;
  onRegionChange?: (region: Region) => void;
}

const DEFAULT_DELTA = {
  latitudeDelta: 0.01,
  longitudeDelta: 0.01,
};

export const TaskMap: React.FC<TaskMapProps> = ({
  location,
  showUserLocation = true,
  height = 200,
  interactive = true,
  onRegionChange,
}) => {
  const mapRef = useRef<MapView>(null);
  const [userLocation, setUserLocation] = useState<TaskLocation | null>(null);
  const [distance, setDistance] = useState<string | null>(null);

  // Calculate distance between two points (Haversine formula)
  const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
    const R = 3959; // Earth's radius in miles
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * (Math.PI / 180)) *
        Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  };

  // Update distance when user location changes
  useEffect(() => {
    if (userLocation) {
      const dist = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        location.latitude,
        location.longitude
      );
      if (dist < 1) {
        setDistance(`${(dist * 5280).toFixed(0)} ft`);
      } else {
        setDistance(`${dist.toFixed(1)} mi`);
      }
    }
  }, [userLocation, location]);

  // Open directions in native maps app
  const openDirections = () => {
    const url = Platform.select({
      ios: `maps:?daddr=${location.latitude},${location.longitude}`,
      android: `geo:${location.latitude},${location.longitude}?q=${location.latitude},${location.longitude}`,
    });

    if (url) {
      Linking.canOpenURL(url).then((supported) => {
        if (supported) {
          Linking.openURL(url);
        } else {
          Alert.alert('Error', 'Unable to open maps');
        }
      });
    }
  };

  // Center map on task location
  const centerOnTask = () => {
    mapRef.current?.animateToRegion({
      ...location,
      ...DEFAULT_DELTA,
    });
  };

  return (
    <View style={[styles.container, { height }]}>
      <MapView
        ref={mapRef}
        style={styles.map}
        provider={PROVIDER_DEFAULT}
        initialRegion={{
          ...location,
          ...DEFAULT_DELTA,
        }}
        showsUserLocation={showUserLocation}
        showsMyLocationButton={false}
        scrollEnabled={interactive}
        zoomEnabled={interactive}
        rotateEnabled={false}
        pitchEnabled={false}
        onUserLocationChange={(event) => {
          if (event.nativeEvent.coordinate) {
            setUserLocation({
              latitude: event.nativeEvent.coordinate.latitude,
              longitude: event.nativeEvent.coordinate.longitude,
            });
          }
        }}
        onRegionChangeComplete={onRegionChange}
      >
        <Marker
          coordinate={location}
          title={location.title || 'Task Location'}
          description={location.description}
          pinColor={colors.secondary}
        />
      </MapView>

      {/* Distance badge */}
      {distance && (
        <View style={styles.distanceBadge}>
          <Text style={styles.distanceText}>{distance} away</Text>
        </View>
      )}

      {/* Directions button */}
      <TouchableOpacity style={styles.directionsButton} onPress={openDirections}>
        <Text style={styles.directionsText}>📍 Directions</Text>
      </TouchableOpacity>

      {/* Center button */}
      {interactive && (
        <TouchableOpacity style={styles.centerButton} onPress={centerOnTask}>
          <Text style={styles.centerIcon}>◎</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    borderRadius: 12,
    overflow: 'hidden',
    position: 'relative',
  },
  map: {
    ...StyleSheet.absoluteFillObject,
  },
  distanceBadge: {
    position: 'absolute',
    top: 12,
    left: 12,
    backgroundColor: colors.surface.primary,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  distanceText: {
    ...typography.caption,
    color: colors.text.primary,
    fontWeight: '600',
  },
  directionsButton: {
    position: 'absolute',
    bottom: 12,
    right: 12,
    backgroundColor: colors.secondary,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    flexDirection: 'row',
    alignItems: 'center',
  },
  directionsText: {
    ...typography.headline,
    color: colors.text.primary,
    fontSize: 14,
  },
  centerButton: {
    position: 'absolute',
    bottom: 12,
    left: 12,
    backgroundColor: colors.surface.primary,
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  centerIcon: {
    fontSize: 20,
    color: colors.text.primary,
  },
});

export default TaskMap;
