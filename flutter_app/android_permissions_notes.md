# Permissions Android à ajouter

Après `flutter create`, ajoute ces lignes dans `android/app/src/main/AndroidManifest.xml` :

## 1. Permissions (avant la balise `<application>`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## 2. Autoriser HTTP clair (dans la balise `<application>`)
```xml
<application
    android:usesCleartextTraffic="true"
    ... >
```

Ceci est nécessaire pour que l'app puisse appeler l'API en HTTP (pas HTTPS) sur le réseau local.

## 3. iOS (ios/Runner/Info.plist)
Ajoute avant `</dict>` :
```xml
<key>NSCameraUsageDescription</key>
<string>L'app a besoin de la caméra pour photographier vos repas.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>L'app a besoin d'accéder à vos photos pour analyser un repas.</string>
```
