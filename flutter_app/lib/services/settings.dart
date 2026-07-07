/// Configuration de l'URL de l'API.
/// Change cette valeur selon ton environnement.
class AppSettings {
  // ── Émulateur Android → localhost du PC hôte
  static const emulatorUrl = 'http://10.0.2.2:8000';

  // ── iOS Simulator → localhost directement
  static const iosSimulatorUrl = 'http://localhost:8000';

  // ── Device physique → IP LAN du PC (ex: 192.168.1.XX)
  // Lance `ipconfig` (Windows) ou `ifconfig` (Mac) pour trouver ton IP
  static const lanUrl = 'http://192.168.1.XX:8000';  // <-- MODIFIER ICI

  // ── ngrok (si tu utilises un tunnel)
  static const ngrokUrl = 'https://xxxx-xxxx.ngrok-free.app';  // <-- MODIFIER ICI
}
