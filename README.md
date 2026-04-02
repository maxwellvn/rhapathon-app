# Rhapathon 2026 – Attendee Search App

Flutter app to search registered Rhapathon 2026 attendees. Authenticates via KingsChat OAuth.

## Setup

### 1. Server – `.env` requirements

Make sure your `.env` (or environment) has:

```
KC_CLIENT_ID=your_kingschat_client_id
KC_CLIENT_SECRET=your_kingschat_client_secret
```

The search API key is currently hardcoded as `rhapaton_search_2026` — change it in:
- `api/search_registrations.php` (line: `$API_KEY`)
- `lib/services/api_service.dart` (line: `apiKey`)

### 2. Flutter – Install dependencies

```bash
cd flutter_app
flutter pub get
```

### 3. Register OAuth redirect URI

In your KingsChat developer portal, register this redirect URI:
```
rhapaton://callback
```

### 4. Run

```bash
flutter run
```

## Architecture

```
Login Screen
  └── KingsChat OAuth (browser popup → rhapaton://callback)
  └── Token stored in SharedPreferences

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
