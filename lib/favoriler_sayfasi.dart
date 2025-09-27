import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/yemek_listesi.dart';
import 'yemek.dart';
import 'tarif_sayfasi.dart';
import 'main.dart';
import 'animations.dart';

class FavorilerSayfasi extends StatefulWidget {
  final List<Yemek> yemekListesi;

  FavorilerSayfasi({required this.yemekListesi});

  @override
  _FavorilerSayfasiState createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  int _currentIndex=2;
  List<Yemek> favoriYemekler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || !kullaniciGirisYapti) {
        setState(() {
          favoriYemekler = [];
          isLoading = false;
        });
        return;
      }

      // Önce cache'den favorileri al
      Set<String> favoriteNames = FavoriCache.getFavorites();
      
      // Eğer cache geçerli değilse veritabanından güncelle
      if (!FavoriCache.isCacheValid()) {
        try {
          final List<dynamic> rows = await Supabase.instance.client
              .from('favorites')
              .select('yemek_ad')
              .eq('user_id', user.id);

          favoriteNames = rows.map((row) => row['yemek_ad'] as String).toSet();
          FavoriCache.updateFavorites(favoriteNames);
        } catch (e) {
          print('Favoriler güncellenirken hata: $e');
          // Hata durumunda cache'deki veriyi kullan
        }
      }

      final selected = widget.yemekListesi
          .where((yemek) => favoriteNames.contains(yemek.ad))
          .toList();

      // UI tutarlılığı için isFavorite işaretlerini güncelle
      for (final yemek in widget.yemekListesi) {
        yemek.isFavorite = favoriteNames.contains(yemek.ad);
      }

      if (mounted) {
        setState(() {
          favoriYemekler = selected;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          favoriYemekler = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('Favori Tarifler',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriYemekler.isEmpty
              ? const Center(child: Text('Henüz favori yemek yok.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: favoriYemekler.length,
                cacheExtent: 1000, // Daha fazla öğe cache'le
                addAutomaticKeepAlives: false, // Gereksiz widget'ları dispose et
                addRepaintBoundaries: false, // Repaint optimizasyonu
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // bi sutunda 2 yemek var
                  crossAxisSpacing: 10,//yatay bosluk
                  mainAxisSpacing: 10,//dikey bosluk
                  childAspectRatio: 1, // Kart oranı
                ),
                itemBuilder: (context, index) {
                  final favoriYemek = favoriYemekler[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        ScaleRoute(
                          page: TarifSayfasi(yemek: favoriYemek),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 14,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dpr = MediaQuery.of(context).devicePixelRatio;
                                final targetW = (constraints.maxWidth * dpr).round();
                                return Image.asset(
                                  favoriYemek.foto,
                                  fit: BoxFit.cover,
                                  cacheWidth: targetW,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              color: Colors.white.withOpacity(0.9),
                              child: Text(
                                favoriYemek.ad,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
    Navigator.pushReplacement(
      context,
     SlideRightRoute(page: Anasayfa()),
             );
      break;
    case 1:
      Navigator.pushReplacement(
        context,
        SlideRightRoute(page: FiltrelemeSayfasi()),
      );
      break;
    case 2:
      Navigator.pushReplacement(
        context,
        SlideRightRoute(page: FavorilerSayfasi(yemekListesi: yemekListesi,)),
      );
      break;
    case 3:
      if (kullaniciGirisYapti) {
        Navigator.pushReplacement(
          context,
          SlideUpRoute(page: const KullaniciProfili()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          SlideUpRoute(page: const GirisEkrani()),
        );
      }
      break;
  }
        },
        
              type: BottomNavigationBarType.fixed,
              selectedItemColor:  Colors.blue.shade200,
              unselectedItemColor:   Color.fromARGB(255, 17, 19, 22),
              selectedLabelStyle: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w900
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black
              ),
              items:[ 
                BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Ana Sayfa'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.filter_list_sharp),
                  label: 'Filtrele'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite, color: Colors.red,),
                  label:'Favoriler',
                  ),
                 BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label:'Giriş')
                   

              ],
      ),
   

    );
  }
}
