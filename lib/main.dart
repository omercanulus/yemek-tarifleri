import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart'; // Yeni paketimiz
import 'package:yemek_tarifleri/profil_sayfasi.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';

// --- GLOBAL DEĞİŞKEN ---
bool kullaniciGirisYapti = false;

// --- FAVORI CACHE (Aynen Kalıyor) ---
class FavoriCache {
  static Set<String> _favoriYemekler = {};
  static void clear() => _favoriYemekler.clear();
  static void updateFavorites(Set<String> favorites) => _favoriYemekler = favorites;
  static Set<String> getFavorites() => Set.from(_favoriYemekler);
  static bool isFavorite(String yemekAd) => _favoriYemekler.contains(yemekAd);
  static void toggleFavorite(String yemekAd, bool isFavorite) {
    if (isFavorite) _favoriYemekler.add(yemekAd);
    else _favoriYemekler.remove(yemekAd);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Dil Sistemini Başlat
  await EasyLocalization.ensureInitialized();

  // 2. .env ve Supabase
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );

  // 3. Kullanıcı Kontrolü
  final user = Supabase.instance.client.auth.currentUser;
  kullaniciGirisYapti = user != null;
  
  if (kullaniciGirisYapti) {
     try {
        final List<dynamic> rows = await Supabase.instance.client
            .from('favorites')
            .select('yemek_ad')
            .eq('user_id', user!.id);
        FavoriCache.updateFavorites(rows.map((row) => row['yemek_ad'] as String).toSet());
      } catch (_) {}
  }

  // 4. Uygulamayı EasyLocalization ile sarıp başlatıyoruz
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('tr'), Locale('en')],
      path: 'assets/translations', // JSON dosyalarının yolu
      fallbackLocale: Locale('tr'), // Varsayılan dil
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yemek Tarifleri',
      
      // EasyLocalization Ayarları
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // Anlık seçili dil
      
      home: kullaniciGirisYapti ? Anasayfa() : ProfilSayfasi(),
    );
  }
}