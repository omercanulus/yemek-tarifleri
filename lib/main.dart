import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart'; // Yeni paketimiz
import 'package:yemek_tarifleri/profil_sayfasi.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/globals.dart';
import 'package:yemek_tarifleri/main_navigation.dart'; // Yeni navigasyon dosyamız

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
      locale: context.locale, 
      
      // DEĞİŞEN KISIM:
      // Eski anasayfa yerine MainNavigation kullanıyoruz.
      // Eğer kullanıcı giriş yapmışsa yeni kabuk sayfaya, yapmamışsa profil/giriş sayfasına gider.
      home: kullaniciGirisYapti ? const MainNavigation() : const ProfilSayfasi(),
    );
  }
}