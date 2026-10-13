# Premium Berber — Flutter app

Setup, architecture and test instructions are in the root [README](../README.md).

```bash
flutter pub get
flutter run                                              # Android emulator → http://10.0.2.2:8010
flutter run --dart-define=API_URL=http://192.168.1.20:8010   # physical device on the same Wi-Fi
```
