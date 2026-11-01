
## Stack: Expo (React Native)

- **Expo ships breaking changes every SDK.** Before using an Expo, EAS or React Native API, check the versioned docs for the installed SDK (`https://docs.expo.dev/versions/v<SDK>.0.0/`) or `https://docs.expo.dev/llms.txt`.
- **Add packages with `npx expo install <pkg>`**, never plain `npm install`, so versions match the SDK.
- **Routes** live in `src/app/` (Expo Router). Tabs sit in a group, and full-screen routes sit beside it under the root `Stack`. Signed-in routes go inside `Stack.Protected` guards. Everything else is outside `src/app/`, imported with an alias (`@/`).
- **`ios/` and `android/` are generated and gitignored.** Configure native behaviour only in `app.json` and config plugins. A new native module or config change needs a new dev build; JS-only changes can ship with EAS Update.
- **Builds run on EAS** via a workflow with profiles in `eas.json`. Rebuild the dev client locally with `npx expo prebuild -p android --clean` then `npx expo run:android --no-bundler` when a native module changes.
- **Reanimated**: write shared values with `.set()` in callbacks and effects (React Compiler lint), and call back to JS with `scheduleOnRN` from `react-native-worklets`, not `runOnJS`. Animate views; don't redraw SVG per frame. No always-on animation on the main screen, and stop it under Reduce Motion (`useReducedMotion`).
- **Text scaling**: test Android at `font_scale 2.0` and iOS at `accessibility-extra-extra-extra-large`. Display text uses `maxFontSizeMultiplier={1.4}`; text inside fixed art uses `allowFontScaling={false}` (not `maxFontSizeMultiplier={1}`, because Android still scales the line height). A row with a button stacks it at `fontScale >= 1.5`. Touch targets are at least 44 pt (iOS) and 48 dp (Android), with `hitSlop` when the drawing is smaller.
- **Android rebuilds the activity on some settings changes** (font scale, display size), and the React tree mounts again in the same JS runtime. State that must survive (locks, one-time prompts) lives at module level, and native prompts open during a rebuild may never resolve.
- **Hermes lacks some Intl APIs** (`supportedValuesOf`, sometimes `PluralRules`): polyfill or bundle the data, and test with the global deleted.
- **Files**: never store absolute paths (the app folder moves on iOS updates); derive them from ids. Re-encode photos to drop EXIF. Use the system photo picker (no storage permission), and block unused permissions in `app.json`.
- **Secure storage**: sessions are encrypted at rest (`expo-secure-store` holds the key for a larger encrypted store).
- **Testing on devices**: emulator `adb reverse tcp:8081 tcp:8081` (plus backend ports). Launch the dev client with `am start -a android.intent.action.VIEW -d "<scheme>://expo-development-client/?url=http%3A%2F%2F127.0.0.1%3A8081"`. Screenshots with `adb exec-out screencap -p`. iOS simulator builds come from an EAS `development-simulator` profile; drive the simulator with Maestro. Stop emulators, simulators and Metro afterwards.
- **UI changes**: add emulator screenshots to the PR (a `screenshots` branch, never the default branch).
