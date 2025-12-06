import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase kütüphanesini ekledik
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'tarif_sayfasi.dart';
import 'yemek_listesi.dart'; // Eski liste kalsın ama kullanmayacağız
import 'package:yemek_tarifleri/globals.dart';
import 'animations.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  String aramaMetni = '';
  List<Yemek> tumYemekler = []; // Veritabanından gelen ham liste
  List<Yemek> filtreliYemekler = []; // Ekranda gösterilen liste
  bool veriYukleniyor = true; // Yükleniyor dairesi göstermek için
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _yemekleriGetir(); // Uygulama açılınca verileri çek
  }

  // Supabase'den verileri çeken fonksiyon
  Future<void> _yemekleriGetir() async {
    try {
      final response = await Supabase.instance.client
          .from('yemekler') // Tablo adımız
          .select();

      setState(() {
        // Gelen veriyi Yemek listesine çeviriyoruz
        tumYemekler = (response as List)
            .map((item) => Yemek.fromMap(item))
            .toList();
        
        filtreliYemekler = tumYemekler;
        veriYukleniyor = false; // Yükleme bitti
      });
    } catch (e) {
      print("Hata oluştu: $e");
      setState(() {
        veriYukleniyor = false;
      });
      // İstersen burada kullanıcıya hata mesajı gösterebilirsin
    }
  }

  void _filtrele(String girilen) {
    setState(() {
      aramaMetni = girilen.toLowerCase();
      filtreliYemekler = tumYemekler.where((yemek) {
        // Hem Türkçe hem İngilizce isminde arama yapıyoruz
        final adTr = yemek.ad.toLowerCase();
        final adEn = yemek.adEn.toLowerCase();
        
        return adTr.contains(aramaMetni) || adEn.contains(aramaMetni);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'recipeD',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.blue.shade200,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Boşluğa basınca klavyeyi kapat
          },
          child: Column(
            children: [
              // Arama Kutusu
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'search_meals'.tr(),
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white),
                    onChanged: _filtrele,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Liste veya Yükleniyor Simgesi
              Expanded(
                child: veriYukleniyor
                    ? Center(child: CircularProgressIndicator()) // Yükleniyorsa dönen daire
                    : filtreliYemekler.isEmpty
                        ? Center(child: Text("Yemek bulunamadı"))
                        : ListView.builder(
                            itemCount: filtreliYemekler.length,
                            itemBuilder: (BuildContext context, int index) {
                              final yemek = filtreliYemekler[index];

                              return SizedBox(
                                height: 200,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30)),
                                    elevation: 5,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              SlideRightRoute(
                                                page: TarifSayfasi(yemek: yemek),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            // Asset resmi veritabanındaki yoldan yüklüyoruz
                                            child: Image.asset(
                                              yemek.foto,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Yemek Adı Yazısı
                                       // Değişecek Kısım (ana_sayfa.dart içinde):

Align(
  alignment: Alignment.bottomLeft,
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Text(
      // ESKİSİ: yemek.ad
      // YENİSİ:
      yemek.getAd(context), 
      
      style: TextStyle(
        fontFamily: 'Nunito',
        shadows: [
          Shadow(
            blurRadius: 15,
            color: Colors.black.withOpacity(0.8),
            offset: Offset(2, 2),
          )
        ],
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
    ),
  ),
),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue.shade200,
          unselectedItemColor: const Color.fromARGB(255, 17, 19, 22),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Sayfa geçiş mantığı
            if (index == 1) {
              Navigator.pushReplacement(context, SlideLeftRoute(page: FiltrelemeSayfasi()));
            } else if (index == 2) {
              // Favorilere mevcut listeyi gönderiyoruz ama aslında orası da güncellenmeli
              Navigator.pushReplacement(context, SlideLeftRoute(page: FavorilerSayfasi(yemekListesi: tumYemekler)));
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
            BottomNavigationBarItem(icon: Icon(Icons.filter_list_sharp), label: 'Filtrele'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Giriş'),
          ],
        ),
      ),
    );
  }
}