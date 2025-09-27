import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/profil_sayfasi.dart';
import 'package:yemek_tarifleri/yemek_listesi.dart';
import 'main.dart';
import 'animations.dart';

class KullaniciProfili extends StatefulWidget {
  const KullaniciProfili({super.key});

  @override
  State<KullaniciProfili> createState() => _KullaniciProfiliState();
}

class _KullaniciProfiliState extends State<KullaniciProfili> {

  void cikisYap() async {
  await Supabase.instance.client.auth.signOut();
  kullaniciGirisYapti = false; // BURAYA EKLE
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const ProfilSayfasi()),
  );
}


  String _getUsername(User? user) {
    if (user == null) return "Kullanıcı";
    
    // Önce metadata'dan kullanıcı adını almaya çalış
    final metadata = user.userMetadata;
    if (metadata != null && metadata['username'] != null) {
      return metadata['username'] as String;
    }
    
    // Eğer metadata'da yoksa email'den al
    final email = user.email ?? "";
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    
    return "Kullanıcı";
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex=3;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "email@ornek.com";
    final username = _getUsername(user);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri butonunu kaldır
        title: const Text("Profilim",
            style: TextStyle(fontFamily: 'Nunito', fontSize: 28, fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 48, color: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontFamily: 'Nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: Icon(Icons.favorite, color: Colors.blue.shade300),
                      title: const Text(
                        'Favori Yemeklerim',
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text('Kaydettiğiniz favorileri görüntüleyin'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          ScaleRoute(
                              page: FavorilerSayfasi(yemekListesi: yemekListesi)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red.shade400),
                      title: const Text(
                        'Çıkış Yap',
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text('Hesabınızdan güvenli çıkış yapın'),
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        kullaniciGirisYapti=false;
                        // Cache'i temizle
                        FavoriCache.clear();
                        Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(page: const ProfilSayfasi()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // aktif olan index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // tıklanan index'i güncelle
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Anasayfa()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FiltrelemeSayfasi()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => FavorilerSayfasi(yemekListesi: yemekListesi)));
              break;
            case 3:
              // Kullanıcı zaten profil sayfasında, bu yüzden hiçbir şey yapmaya gerek yok
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade300,
        unselectedItemColor: const Color.fromARGB(255, 17, 19, 22),
        selectedLabelStyle: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.filter_list_sharp), label: 'Filtrele'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Giriş'),
        ],
      ),
    );
  }
}
