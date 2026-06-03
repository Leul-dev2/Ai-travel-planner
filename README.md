# Smart Travel AI

AI-powered travel itinerary planner built with Flutter, Firebase, and Riverpod.

## Prerequisites

- Flutter SDK 3.22+ (stable)
- Android Studio / Android SDK (for Android)
- Chrome (for Web)
- Firebase project: `ai-planner-39b1a`

## Setup

1. **Clone and install dependencies**

   ```bash
   flutter pub get
   ```

2. **Environment variables**

   ```bash
   cp .env.example .env
   ```

   Fill in API keys in `.env`. For Android native Google Maps, also add to `android/local.properties`:

   ```properties
   GOOGLE_MAPS_API_KEY=your-google-maps-key
   ```

3. **Firebase**

   - Android package: `com.aiplanner.app` (see `android/app/google-services.json`)
   - Web: register a Web app in [Firebase Console](https://console.firebase.google.com/) and set `FIREBASE_WEB_APP_ID` in `.env`
   - Or run: `dart pub global activate flutterfire_cli && flutterfire configure --project=ai-planner-39b1a`

4. **Google Maps on Web**

   In `web/index.html`, replace `YOUR_GOOGLE_MAPS_API_KEY` in the Maps script tag with the same key from `.env`.

5. **Firestore rules and indexes**

   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

   Requires [Firebase CLI](https://firebase.google.com/docs/cli) logged into the project.

6. **Google Sign-In**

   - **Web:** Uses Firebase `signInWithPopup` (no extra client setup in code). In [Firebase Console](https://console.firebase.google.com/) → Authentication → Settings → **Authorized domains**, ensure `localhost` is listed. If Google shows “Access blocked”, open [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials → your **Web client** → add **Authorized JavaScript origins**: `http://localhost`, `http://127.0.0.1`, and your dev URL (e.g. `http://localhost:7357` — check the port in the browser address bar when running `flutter run -d chrome`).
   - **Android:** Add debug/release SHA-1 fingerprints in Firebase Console for package `com.aiplanner.app`.

## Run

```bash
# Android
flutter run -d android

# Web (set FIREBASE_WEB_APP_ID and Maps key first)
flutter run -d chrome
```

## Test & analyze

```bash
flutter analyze
flutter test
```

## Project structure

- `lib/features/` — feature modules (auth, trip planner, maps, AI chat, …)
- `lib/core/` — theme, routing, config, shared widgets
- `firestore.rules` — Firestore security rules
- `firestore.indexes.json` — composite indexes (trips by `ownerId` + `updatedAt`)

## AI provider fallback order

1. **Web:** Gemini → OpenRouter (if key set) → local templates  
2. **Android/iOS:** OpenAI (`OPEN_AI_API_KEY`) → Gemini → OpenRouter → local templates  

OpenRouter uses `OPENROUTER_API_KEY` or an `OPENAI_API_KEY` that starts with `sk-or-`. Set `OPENROUTER_MODEL` (default `openai/gpt-4o-mini`).

## Not yet implemented

- Payments (`flutter_stripe`, Chapa — commented out in `pubspec.yaml`)
- Weather service (`OPENWEATHER_API_KEY` unused)
- iOS platform folder (run `flutter create .` + `flutterfire configure` to add)
- Admin panel, bookings UI, collaborative trips UI (domain entities only)

## Security

Do not commit `.env`. Web builds bundle `.env` as an asset — restrict API keys in Google Cloud Console (HTTP referrer / app restrictions).
