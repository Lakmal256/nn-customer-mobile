# Nwasa Niwasa Mobile

## Build Command

```flutter build appbundle --flavor [env] -t lib/[dart target] --dart-define-from-file configs/[.env]```

### Android build commands
```
flutter build appbundle --flavor uat -t lib/main.dart --dart-define-from-file configs/.env.uat
```

```
flutter build apk --flavor uat -t lib/main.dart --dart-define-from-file configs/.env.uat
```

```
flutter build appbundle --flavor production -t lib/main.dart --dart-define-from-file configs/.env.production
```

```
flutter build apk --flavor production -t lib/main.dart --dart-define-from-file configs/.env.production
```

### iOS build commands
```
flutter build ipa --flavor uat -t lib/main.dart --dart-define-from-file configs/.env.uat
```

```
flutter build ipa --flavor production -t lib/main.dart --dart-define-from-file configs/.env.production
```

