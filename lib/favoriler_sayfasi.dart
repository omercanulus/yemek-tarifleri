import 'package:flutter/material.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/tarif_sayfasi.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'package:yemek_tarifleri/animations.dart'; // Animasyonlar için
import 'package:yemek_tarifleri/globals.dart'; // kullaniciGirisYapti ve FavoriCache için

class FavorilerSayfasi extends StatefulWidget {
  final List<Yemek> yemekListesi;
  const FavorilerSayfasi({super.key, required this.yemekListesi});

  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  int _currentIndex = 2; // Favoriler sayfası 2. index

  @override
  Widget build(BuildContext context) {
    // Favori olan yemekleri filtrele
    // Not: Veritabanından gelen listedeki 'isFavorite' durumu veya Cache sistemi kullanılabilir
    final favoriYemekler = widget.yemekListesi.where((yemek) {
      // Hem nesne üzerindeki durumu hem de Cache'i kontrol edelim (garanti olsun)
      return yemek.isFavorite || FavoriCache.isFavorite(yemek.ad);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Favorilerim',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: favoriYemekler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text(
                    "Henüz favori eklemedin",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriYemekler.length,
              itemBuilder: (context, index) {
                final yemek = favoriYemekler[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRightRoute(page: TarifSayfasi(yemek: yemek)),
                        ).then((_) {
                          // Geri dönüldüğünde sayfayı yenile (belki favoriden çıkarmıştır)
                          setState(() {});
                        });
                      },
                      child: Row(
                        children: [
                          // Sol taraf: Resim
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: Image.asset(
                              yemek.foto,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.restaurant, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          // Sağ taraf: Bilgiler
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    yemek.getAd(context), // DİLE GÖRE İSİM
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        "${yemek.hazirlamaSuresi + yemek.pisirmeSuresi} dk",
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Favori İkonu (Kaldırmak için)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.favorite, color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (index) {
          if (index == _currentIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(context, SlideLeftRoute(page: Anasayfa()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, SlideLeftRoute(page: FiltrelemeSayfasi()));
          } else if (index == 3) {
            if (kullaniciGirisYapti) {
              Navigator.pushReplacement(context, SlideUpRoute(page: const KullaniciProfili()));
            } else {
              Navigator.pushReplacement(context, SlideUpRoute(page: const GirisEkrani()));
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ara'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Giriş'),
        ],
      ),
    );
  }
}