
import 'package:flutter/material.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/filtreleme_sayfasi.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'tarif_sayfasi.dart';
import 'yemek_listesi.dart';
import 'main.dart';
import 'animations.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});
  

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {

 String aramaMetni = '';
List<Yemek> filtreliYemekler = [];
  int _currentIndex=0;

  @override
  void initState() {
    super.initState();
    filtreliYemekler = List.from(yemekListesi); // ilk başta tüm yemekleri göster
    // İlk ekranda görünen birkaç görseli önbelleğe al
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final precacheCount = filtreliYemekler.length > 8 ? 8 : filtreliYemekler.length;
      for (int i = 0; i < precacheCount; i++) {
        final path = filtreliYemekler[i].foto;
        precacheImage(AssetImage(path), context);
      }
    });
  }

  void _filtrele(String girilen) {
    setState(() {
      aramaMetni = girilen;
      filtreliYemekler = yemekListesi
          .where((yemekAdi) =>
              yemekAdi.ad.toLowerCase().contains(aramaMetni.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    
final padding = Padding(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  child: Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText:'Yemek ara...' ,
            hintStyle: TextStyle(fontWeight: FontWeight.w300),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue.shade300, 
                width: 3.0
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
              color:  Colors.blue.shade100, //  tıklanmamisken
              width: 3,
              ),
              borderRadius: BorderRadius.circular(100),
              ),

            filled: true,
          fillColor: Colors.white
          ),
          onChanged: _filtrele,
        ),
      ),

      SizedBox(height: 10), // Search bar ile liste arasinda bosluk

     
      Expanded(
        child: ListView.builder(
          itemCount: filtreliYemekler.length,
          cacheExtent: 1000, // Daha fazla öğe cache'le
          addAutomaticKeepAlives: false, // Gereksiz widget'ları dispose et
          addRepaintBoundaries: false, // Repaint optimizasyonu
          itemExtent: 216, // 200 yükseklik + 16 padding (üst-alt 8+8)
          itemBuilder: (BuildContext context, int index) {
            final yemekIndex = filtreliYemekler[index];

            return SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  elevation: 10,
                  //color: Colors.white,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideRightRoute(
                              page: TarifSayfasi(yemek: yemekIndex),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final dpr = MediaQuery.of(context).devicePixelRatio;
                              final targetW = (constraints.maxWidth * dpr).round();
                              return Image.asset(
                                yemekIndex.foto,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            yemekIndex.ad,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              shadows: [
                                Shadow(
                                  blurRadius: 15,
                                  color: const Color.fromARGB(255, 9, 52, 127),
                                  offset: Offset(2,2),
                                )
                              ],
                              color: Colors.white,
                              fontSize: 30,
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
);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //leading: Icon(Icons.menu),
          backgroundColor: Colors.white,
          title: Text.rich(
            TextSpan(
              children:[
                TextSpan(
                  text: 'yemek',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color:Colors.blue.shade200,
                  fontSize: 50,
                  fontWeight: FontWeight.w900)
                ),
                TextSpan(
                  text: 'tarifleri',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  )
                )
              ]
             ),
          ),
),
             body:IndexedStack(
               children:[ InkWell(child: padding,
               onTap: () {
                FocusScope.of(context).unfocus();
               },),
            ] ),
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
     MaterialPageRoute(builder: (_) => const Anasayfa()),
             );
      break;
    case 1:
      Navigator.pushReplacement(
        context,
        SlideLeftRoute(page: FiltrelemeSayfasi()),
      );
      break;
    case 2:
      Navigator.pushReplacement(
        context,
        SlideLeftRoute(page: FavorilerSayfasi(yemekListesi: yemekListesi,)),
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
              unselectedItemColor:  const Color.fromARGB(255, 17, 19, 22),
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
                  icon: Icon(Icons.favorite),
                  label:'Favoriler'
                  ),
                 BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label:'Giriş')
                   

              ],
      ),
    ),
    );


  }
}