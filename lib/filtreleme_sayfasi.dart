import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/tarif_sayfasi.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/animations.dart';
import 'main.dart'; // kullaniciGirisYapti değişkeni için

class FiltrelemeSayfasi extends StatefulWidget {
  const FiltrelemeSayfasi({super.key});

  @override
  State<FiltrelemeSayfasi> createState() => _FiltrelemeSayfasiState();
}

class _FiltrelemeSayfasiState extends State<FiltrelemeSayfasi> {
  String aramaMetni = '';
  List<Yemek> tumYemekler = [];
  List<Yemek> filtreliYemekler = [];
  bool veriYukleniyor = true;
  int _currentIndex = 1; // Filtreleme sayfası 1. index

  @override
  void initState() {
    super.initState();
    _yemekleriGetir();
  }

  // Verileri Supabase'den çek
  Future<void> _yemekleriGetir() async {
    try {
      final response = await Supabase.instance.client.from('yemekler').select();

      setState(() {
        tumYemekler = (response as List).map((item) => Yemek.fromMap(item)).toList();
        filtreliYemekler = tumYemekler;
        veriYukleniyor = false;
      });
    } catch (e) {
      print("Hata: $e");
      setState(() {
        veriYukleniyor = false;
      });
    }
  }

void _filtrele(String girilen) {
    setState(() {
      aramaMetni = girilen.toLowerCase();
      
      // --- DEBUG BAŞLANGIÇ (Dedektif Modu) ---
      print("----------------------------------");
      print("Aranan Kelime: '$aramaMetni'");
      
      filtreliYemekler = tumYemekler.where((yemek) {
        final adTr = yemek.ad.toLowerCase();
        final adEn = yemek.adEn.toLowerCase();
        
        // Eşleşme var mı kontrol et
        bool trEslesti = adTr.contains(aramaMetni);
        bool enEslesti = adEn.contains(aramaMetni);

        // Eğer aranan kelime 'las' ise ve İngilizcesi 'Lasagna' ise bunu yakalamalı
        // Bunu terminalde görmek için yazdırıyoruz:
        if (aramaMetni.length > 2 && (adEn.contains("las") || adTr.contains("laz"))) {
           print("Yemek: ${yemek.ad} | İngilizcesi: '${yemek.adEn}'");
           print("Kontrol: '$adEn' içinde '$aramaMetni' var mı? -> $enEslesti");
        }

        return trEslesti || enEslesti;
      }).toList();
      print("----------------------------------");
      // --- DEBUG BİTİŞ ---
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri butonunu kaldır
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ara & Keşfet',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Arama Kutusu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: _filtrele,
                  decoration: InputDecoration(
                    hintText: 'Yemek, tatlı veya malzeme ara...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),

            // Sonuç Listesi
            Expanded(
              child: veriYukleniyor
                  ? Center(child: CircularProgressIndicator())
                  : filtreliYemekler.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                              SizedBox(height: 10),
                              Text("Sonuç bulunamadı", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtreliYemekler.length,
                          itemBuilder: (context, index) {
                            final yemek = filtreliYemekler[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 3,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideRightRoute(page: TarifSayfasi(yemek: yemek)),
                                  );
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    yemek.foto,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(width: 80, height: 80, color: Colors.grey.shade200, child: Icon(Icons.restaurant)),
                                  ),
                                ),
                                title: Text(
                                  yemek.getAd(context), // DİLE GÖRE İSİM
                                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Text(
                                  "${yemek.hazirlamaSuresi + yemek.pisirmeSuresi} dk • ${yemek.getMalzemeler(context).length} malzeme",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade300),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar (Ana Sayfa ile aynı mantıkta)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (index) {
          if (index == _currentIndex) return;
          
          if (index == 0) {
            Navigator.pushReplacement(context, SlideLeftRoute(page: Anasayfa()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, SlideRightRoute(page: FavorilerSayfasi(yemekListesi: tumYemekler)));
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ara'), // İkonu değiştirdim
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Giriş'),
        ],
      ),
    );
  }
}