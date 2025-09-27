import 'package:flutter/material.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'yemek_listesi.dart';
import 'yemek.dart';
import 'tarif_sayfasi.dart';
import 'main.dart';
import 'animations.dart';

class FiltrelemeSayfasi extends StatefulWidget {
  @override
  _FiltrelemeSayfasiState createState() => _FiltrelemeSayfasiState();
}

class _FiltrelemeSayfasiState extends State<FiltrelemeSayfasi> {
  List<String> secilenMalzemeler = [];
  List<Yemek> filtrelenmisYemekler = [];
  List<String> tumMalzemeler = [];
  List<String> gosterilenMalzemeler = [];

  String aramaKelimesi = '';
  bool filtrelendi = false;
   int _currentIndex=1;
  @override
  void initState() {
    super.initState();
    tumMalzemeler = List<String>.from(
      yemekListesi
          .map((yemek) =>//her yemek icin ayni islem yapiliyor
              yemek.yazilacakMalzemeler.map((m) => m.toLowerCase().trim()).toSet())
          .expand((set) => set)
          .toSet(),
    );

    gosterilenMalzemeler = List.from(tumMalzemeler);
  }

  void filtrele() {
    setState(() {
      filtrelenmisYemekler = yemekListesi.where((yemek) {
        final yemekMalzemeleri = yemek.yazilacakMalzemeler
            .map((m) => m.toLowerCase().trim())
            .toList();
        return secilenMalzemeler
            .every((malzeme) => yemekMalzemeleri.contains(malzeme));
      }).toList();

      filtrelendi = true;
    });
  }

  void aramaYap(String kelime) {
    setState(() {
      aramaKelimesi = kelime.toLowerCase();
      gosterilenMalzemeler = tumMalzemeler
          .where((m) => m.contains(aramaKelimesi))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Malzemeye Göre Filtrele",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!filtrelendi) ...[
              TextField(
                decoration:InputDecoration(
            hintText:'Malzeme ara...' ,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white, 
                width: 5.0
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
              color:  Colors.white, //  tıklanmamisken
              width: 3,
              ),
              borderRadius: BorderRadius.circular(100),
              ),
            filled: true,
          fillColor: Colors.white
          ),
                onChanged: aramaYap,
              ),
              const SizedBox(height: 20),
              Column(
                children:[ 
                  Text('Malzemelerinizi seçin ve yapılabilecek yemekleri görün.',
                  style: TextStyle(fontWeight: FontWeight.bold),),
                  
                  SizedBox(height:0),
                  /*Text(
                  '',
                  style: TextStyle(fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500),
                ),*/
                ]
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: gosterilenMalzemeler.map((malzeme) {
                      final secili = secilenMalzemeler.contains(malzeme);
                      return FilterChip(
                        label: Text(malzeme),
                        selected: secili,
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              secilenMalzemeler.add(malzeme);
                            } else {
                              secilenMalzemeler.remove(malzeme);
                            }
                          });
                        },
                        selectedColor: Colors.blue.shade200,
                        checkmarkColor: Colors.black,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: secili ? Colors.black : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
                ),
                onPressed: filtrele,
                icon: Icon(Icons.filter_list,
                color: Colors.blue.shade300,),
                label: Text("Yemekleri Filtrele",
                style: TextStyle(
                  color: Colors.blue.shade200,
                  fontWeight: FontWeight.w700
                ),
                )
              ),
            ] else ...[
              // Filtredenn sonra ekran
              if (filtrelenmisYemekler.isEmpty)
                Text("Uygun yemek bulunamadı.")
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filtrelenmisYemekler.length,
                    cacheExtent: 800,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemExtent: 84, // ListTile yaklaşık yükseklik + margin
                    itemBuilder: (context, index) {
                      final gosterilenYemek = filtrelenmisYemekler[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dpr = MediaQuery.of(context).devicePixelRatio;
                                final targetW = (60 * dpr).round();
                                return Image.asset(
                                  gosterilenYemek.foto,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  cacheWidth: targetW,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 30,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          title: Text(gosterilenYemek.ad,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16,
                          color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              FadeRoute(
                                page: TarifSayfasi(yemek: gosterilenYemek),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    filtrelendi = false;
                    secilenMalzemeler.clear();
                    filtrelenmisYemekler.clear();
                    gosterilenMalzemeler = List.from(tumMalzemeler);
                  });
                },
                icon: Icon(Icons.refresh),
                label: Text("Yeni Filtreleme Yap",
                style: TextStyle(fontWeight: FontWeight.w700),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.blue.shade200),
              ),
            ]
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
    Navigator.pushReplacement(
      context,
     SlideRightRoute(page: const Anasayfa()),
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
    );
  }
}
