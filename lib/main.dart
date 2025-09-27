
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/profil_sayfasi.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';

bool kullaniciGirisYapti = false;

// Global favori cache sistemi
class FavoriCache {
  static Set<String> _favoriYemekler = {};
  static bool _isInitialized = false;
  static DateTime? _lastUpdate;

  // Cache'i temizle (çıkış yapıldığında)
  static void clear() {
    _favoriYemekler.clear();
    _isInitialized = false;
    _lastUpdate = null;
  }

  // Cache'i güncelle
  static void updateFavorites(Set<String> favorites) {
    _favoriYemekler = favorites;
    _isInitialized = true;
    _lastUpdate = DateTime.now();
  }

  // Cache'den favori listesini al
  static Set<String> getFavorites() {
    return Set.from(_favoriYemekler);
  }

  // Belirli bir yemeğin favori olup olmadığını kontrol et
  static bool isFavorite(String yemekAd) {
    return _favoriYemekler.contains(yemekAd);
  }

  // Cache'in güncel olup olmadığını kontrol et (5 dakika)
  static bool isCacheValid() {
    if (!_isInitialized || _lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!).inMinutes < 5;
  }

  // Favori ekle/çıkar
  static void toggleFavorite(String yemekAd, bool isFavorite) {
    if (isFavorite) {
      _favoriYemekler.add(yemekAd);
    } else {
      _favoriYemekler.remove(yemekAd);
    }
    _lastUpdate = DateTime.now();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vqusrhtyeztxhnsuiftd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxdXNyaHR5ZXp0eGhuc3VpZnRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MTY0MzQsImV4cCI6MjA3MDQ5MjQzNH0.35qeTyxWqlrKr6m5VkNTk2jCNaWVdD7uXfczEs5Hz30',
  );

  // Kullanıcının giriş durumunu kontrol et
  final user = Supabase.instance.client.auth.currentUser;
  kullaniciGirisYapti = user != null;
  
  // Eğer kullanıcı giriş yapmışsa favorileri cache'le
  if (kullaniciGirisYapti && user != null) {

  }
  
  // Performans optimizasyonu
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: kullaniciGirisYapti ? Anasayfa() : ProfilSayfasi(),
    );
  }
}
