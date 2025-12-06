import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/profil_sayfasi.dart';
import 'package:yemek_tarifleri/animations.dart';
import 'package:yemek_tarifleri/globals.dart'; // FavoriCache ve kullaniciGirisYapti için

class KullaniciProfili extends StatefulWidget {
  const KullaniciProfili({super.key});

  @override
  State<KullaniciProfili> createState() => _KullaniciProfiliState();
}

class _KullaniciProfiliState extends State<KullaniciProfili> {
  int _currentIndex = 3;

  Future<void> _cikisYap() async {
    await Supabase.instance.client.auth.signOut();
    kullaniciGirisYapti = false;
    FavoriCache.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        FadeRoute(page: ProfilSayfasi()), 
        (route) => false,
      );
    }
  }

  // --- DİL DEĞİŞTİRME FONKSİYONU ---
  void _dilDegistir() {
    // Eğer şu anki dil Türkçe ise İngilizce yap, değilse Türkçe yap
    if (context.locale.languageCode == 'tr') {
      context.setLocale(Locale('en'));
    } else {
      context.setLocale(Locale('tr'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // EasyLocalization'a soruyoruz: Dil İngilizce mi?
    bool isEnglish = context.locale.languageCode == 'en';
    
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? (isEnglish ? "Guest User" : "Misafir Kullanıcı");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'my_profile'.tr(), // JSON'dan "Profilim"
          style: TextStyle(fontFamily: 'Nunito', color: Colors.black, fontWeight: FontWeight.w900, fontSize: 28),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // Sağ üstte küçük dil butonu (Opsiyonel)
        actions: [
          TextButton(
            onPressed: _dilDegistir,
            child: Text(
              isEnglish ? "TR" : "EN", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200, width: 3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage('lib/assets/images/dondurma.png'),
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              userEmail,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              isEnglish ? "Food Explorer" : "Lezzet Kaşifi",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            
            SizedBox(height: 40),

            // --- DİL DEĞİŞTİRME BUTONU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: ElevatedButton.icon(
                onPressed: _dilDegistir,
                icon: Icon(Icons.language, color: Colors.blue.shade700),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'language'.tr() + ": " + (isEnglish ? "English" : "Türkçe"),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Icon(Icons.swap_horiz, color: Colors.grey),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),

            // ÇIKIŞ YAP BUTONU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                onPressed: _cikisYap,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'sign_out'.tr(), // JSON'dan "Çıkış Yap"
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 0) Navigator.pushReplacement(context, SlideLeftRoute(page: Anasayfa()));
          else if (index == 1) Navigator.pushReplacement(context, SlideLeftRoute(page: FiltrelemeSayfasi()));
          else if (index == 2) Navigator.pushReplacement(context, SlideLeftRoute(page: FavorilerSayfasi(yemekListesi: [])));
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr()),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'.tr()),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'favorites'.tr()),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'.tr()),
        ],
      ),
    );
  }
}