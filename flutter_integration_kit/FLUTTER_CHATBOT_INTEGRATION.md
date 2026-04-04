# Flutter to NagarSetu Chatbot Integration Guide

This guide is for your friend who has the Flutter app code.

## 1) What is already prepared

You already have a chatbot backend endpoint available on your system:

- Health: `GET /health`
- Chat: `POST /api/chat`

Current public tunnel URL (ngrok):

- https://comparably-pyroligneous-del.ngrok-free.app

Final endpoint to use in app:

- https://comparably-pyroligneous-del.ngrok-free.app/api/chat

> Note: ngrok free URL may change after restart. Update app config when that happens.

## 2) Required request format from app

### Headers

- `Authorization: Bearer dev-chat-token-123`
- `Content-Type: application/json`

### JSON body

```json
{
  "userId": "1i3bNIaTn5aEPSyVEjni0QyaMyj2",
  "query": "Show weather impact on electricity complaints."
}
```

### Success response

```json
{
  "ok": true,
  "answer": "Natural language response...",
  "parsed": { },
  "result": { }
}
```

### Error response examples

```json
{ "error": "Unauthorized cross-department query" }
```

```json
{ "error": "userId and query are required" }
```

## 3) Add dependencies in Flutter app

In app `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
```

Then run:

```bash
flutter pub get
```

## 4) Copy integration kit files into Flutter app

Copy these files from this folder into your Flutter app `lib/`:

- `models/chatbot_models.dart`
- `services/chatbot_api_service.dart`
- `controllers/chat_controller.dart`
- `ui/chat_screen.dart`

Optional runnable demo:

- `example_main.dart`

## 5) Minimal wiring in friend app

Create service and controller:

```dart
final service = ChatbotApiService(
  baseUrl: 'https://comparably-pyroligneous-del.ngrok-free.app',
  bearerToken: 'dev-chat-token-123',
);

final controller = ChatController(
  service: service,
  userId: '1i3bNIaTn5aEPSyVEjni0QyaMyj2',
);
```

Open UI:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatScreen(controller: controller),
  ),
);
```

## 6) Recommended secure config (important)

Do not hardcode secrets in production app. Use runtime config:

```bash
flutter run \
  --dart-define=CHATBOT_BASE_URL=https://comparably-pyroligneous-del.ngrok-free.app \
  --dart-define=CHATBOT_BEARER_TOKEN=dev-chat-token-123 \
  --dart-define=CHATBOT_USER_ID=1i3bNIaTn5aEPSyVEjni0QyaMyj2
```

## 7) Commands on your system (chatbot owner)

Run backend API:

```bash
npm run chat-api
```

Run ngrok tunnel:

```bash
npm run ngrok-chat
```

If SQLite data is stale, refresh:

```bash
npm run backfill-sqlite
```

## 8) Troubleshooting

- `401 Missing bearer token` or `Invalid token`
  - Fix app header token.
- `403 Unauthorized cross-department query`
  - Query department does not match user's department.
- `No matching data found`
  - Data not available in that user scope; try valid user/query combination.
- Connection timeout in app
  - Ensure `npm run chat-api` and `npm run ngrok-chat` are running.
- ngrok URL changed
  - Update app base URL.

## 9) Production suggestion

ngrok is fine for testing. For production, host backend on fixed HTTPS domain (Cloud Run / VM / App Service) and rotate token regularly.
