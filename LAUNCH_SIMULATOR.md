# Launching the Xcode Simulator

## Quick Start

Run the following command from the project root:

```bash
npm run ios
```

This will:
1. Start the Metro bundler (if not already running)
2. Build the iOS app
3. Launch the iPhone simulator
4. Deploy and run the app on the simulator

## What to Expect

- The first build may take 1-3 minutes
- The simulator will open automatically
- Once built, the app will load and display the login screen
- The app icon will show "HustleXP" with your custom logo

## Prerequisites

Make sure you have completed the initial setup:

```bash
npm install
cd ios && pod install && cd ..
```

## Troubleshooting

### If the app doesn't appear:
- Wait for the Metro bundler to finish bundling (check terminal for "Ready to launch...")
- The simulator may take a few moments to render the app
- Check the terminal for any error messages

### To restart the simulator:
```bash
npm run ios
```

### To view Metro bundler output:
Look at the terminal window running `npm run ios` to see bundling progress and any errors.

## Manual Simulator Launch (Alternative)

If you prefer to launch the simulator manually:

1. Open Xcode workspace:
   ```bash
   open ios/HustleXP.xcworkspace
   ```

2. Select "HustleXP" as the target

3. Select an iPhone simulator from the device dropdown

4. Click the Run button or press Cmd+R

## Notes

- Keep the Metro bundler terminal window open while developing
- The app is set to use the Hermes JavaScript engine for better performance
- App name is "HustleXP" with the custom logo from `lakshLogoBig.png`
