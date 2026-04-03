# Rhapathon 2026 – Attendee Search App

Flutter app to search registered Rhapathon 2026 attendees behind a **staff access password**, with optional KingsChat-related helpers in code for future use.

## Security (read this)

- **Nothing secret stays secret inside a shipped mobile app.** Anyone with the APK or IPA can eventually extract strings and logic. Treat `RHAP_API_KEY` as an identifier that **must be backed by server checks** (rate limits, abuse detection, rotating or revoking keys on the backend, IP rules if appropriate, etc.).
- **Do not commit real keys or passwords.** This repo expects you to inject them at build time (see below). The tracked `secrets.json.example` is a template only; copy it to `secrets.json` (gitignored) for local runs.
- **Never publish** `secrets.json`, production `--dart-define` values, or screenshots that show them.

## Configuration (build-time)

Copy the example file and fill in real values:

```bash
cp secrets.json.example secrets.json
```

Run or build with:

```bash
flutter run --dart-define-from-file=secrets.json
# or
flutter build apk --dart-define-from-file=secrets.json
```

Equivalent without a file (e.g. CI):

```bash
flutter run \
  --dart-define=RHAP_API_KEY=your_api_key \
  --dart-define=RHAP_ACCESS_PASSWORD=your_password \
  --dart-define=RHAP_KC_CLIENT_ID=optional_client_id
```

Define names: `RHAP_API_KEY`, `RHAP_ACCESS_PASSWORD`, `RHAP_KC_CLIENT_ID` (optional).

## Setup

### 1. Server

Keep server secrets in server `.env` or your host’s secret store. Align the search API key with what you pass as `RHAP_API_KEY` for the app build.

### 2. Flutter – dependencies

```bash
cd rhapathon-app
flutter pub get
```

### 3. KingsChat redirect URI (only if you use OAuth in the client)

Register in the KingsChat developer portal:

```
rhapaton://callback
```

### 4. Run

```bash
flutter run --dart-define-from-file=secrets.json
```

## Architecture

```
App root
  └── SharedPreferences → password gate or search

Login Screen
  └── Access password (from RHAP_ACCESS_PASSWORD)

Search Screen
  ├── Debounced search (400ms)
  ├── Searches: name, email, phone, KingsChat username, zone, church
  ├── Infinite scroll pagination
  └── Tap → Detail Screen

Detail Screen
  ├── Full attendee profile
  ├── Contact info (long-press to copy email/phone)
  ├── Church/affiliation
  ├── Selected days & sessions
  └── Feedback
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/kc_auth.php?action=auth_url` | Get KingsChat OAuth URL |
| `POST /api/kc_auth.php?action=exchange` | Exchange code for token |
| `POST /api/kc_auth.php?action=verify` | Verify token, get profile |
| `GET /api/search_registrations.php?q=...&api_key=...` | Search registrations |
| `GET /api/search_registrations.php?action=detail&id=...&api_key=...` | Get single record |
