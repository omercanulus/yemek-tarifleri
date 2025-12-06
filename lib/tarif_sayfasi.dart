import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/animations.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/favoriler_sayfasi.dart';
import 'package:yemek_tarifleri/yemek_listesi.dart';
import 'yemek.dart';
import 'package:yemek_tarifleri/globals.dart';

class TarifSayfasi extends StatefulWidget {
  final Yemek yemek;

  const TarifSayfasi({super.key, required this.yemek});

  @override
  State<TarifSayfasi> createState() => _TarifSayfasiState();
}

class _TarifSayfasiState extends State<TarifSayfasi> {
  bool isStepByStepMode = false;
  int currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _syncFavoriteFromDatabase();
  }

  // Veritabanından favori durumunu kontrol et
  Future<void> _syncFavoriteFromDatabase() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return;
      }

      // Not: Veritabanında 'yemek_ad' yerine artık benzersiz ID kullanmak daha doğrudur
      // ama şimdilik mevcut yapını bozmadan yemek adıyla devam ediyoruz.
      final response = await Supabase.instance.client
          .from('favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('yemek_ad', widget.yemek.ad) // Türkçe adını ID niyetine kullanıyoruz
          .maybeSingle();

      final isFav = response != null;
      if (mounted) {
        setState(() {
          widget.yemek.isFavorite = isFav;
        });
      }
    } catch (_) {
      // Sessiz geç
    }
  }

  Future<void> _updateFavoriteInDatabase(bool makeFavorite) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      if (makeFavorite) {
        await Supabase.instance.client.from('favorites').insert({
          'user_id': user.id,
          'yemek_ad': widget.yemek.ad, // Favorilere her zaman Türkçe adıyla kaydedelim ki karışmasın
        });
        
        // Cache'i güncelle
        FavoriCache.toggleFavorite(widget.yemek.ad, true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.yemek.getAd(context)} favorilere eklendi! '),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await Supabase.instance.client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('yemek_ad', widget.yemek.ad);
            
        // Cache'i güncelle
        FavoriCache.toggleFavorite(widget.yemek.ad, false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.yemek.getAd(context)} favorilerden çıkarıldı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          widget.yemek.isFavorite = !makeFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _nextStep(List<String> adimlar) {
    if (currentStep < adimlar.length - 1) {
      setState(() {
        currentStep++;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: Duration(milliseconds: 300),
        );
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dil kontrolü ile doğru listeleri alıyoruz
    final displayMalzemeler = widget.yemek.getMalzemeler(context);
    final displayAdimlar = widget.yemek.getAdimlar(context);
    final displayAd = widget.yemek.getAd(context);
    final displayTarif = widget.yemek.getTarif(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.black,)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isStepByStepMode ? Icons.list : Icons.format_list_numbered,
              color: Colors.blue.shade600,
            ),
            onPressed: () {
              setState(() {
                isStepByStepMode = !isStepByStepMode;
                currentStep = 0;
              });
            },
          ),
          IconButton(
            icon: Icon(
              widget.yemek.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.yemek.isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () async {
              // Giriş kontrolü
              final user = Supabase.instance.client.auth.currentUser;
              if (user == null || !kullaniciGirisYapti) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GirisEkrani()),
                );
                return;
              }

              final newValue = !widget.yemek.isFavorite;
              setState(() {
                widget.yemek.isFavorite = newValue;
              });
              await _updateFavoriteInDatabase(newValue);
            },
          )
        ],
        title: Text(displayAd,
        style: TextStyle(fontSize:20, fontFamily: 'Nunito', color:  Colors.black, fontWeight: FontWeight.w900),
        ),
         backgroundColor: Colors.white
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(             
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yemek Fotoğrafı (Supabase'den veya Asset'ten)
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          widget.yemek.foto,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.restaurant, size: 80, color: Colors.grey.shade400),
                            );
                          },
                        ),
                      ),
                      Container(                     
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Text(
                          displayAd,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Süre Bilgileri
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: Colors.blue.shade600),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hazırlama', // Burayı da çevirebilirsin istersen
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${widget.yemek.hazirlamaSuresi} dk',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(Icons.restaurant, color: Colors.orange.shade600),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pişirme',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${widget.yemek.pisirmeSuresi} dk',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Malzemeler
                Text(
                  'Malzemeler:',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayMalzemeler.join('\n'), // DİLE GÖRE LİSTE
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),

                SizedBox(height: 20),

                // Tarif Başlığı ve Mod Seçici
                Row(
                  children: [
                    Text(
                      'Tarif:',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito', fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    if (!isStepByStepMode)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isStepByStepMode = true;
                            currentStep = 0;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                        icon: Icon(Icons.format_list_numbered, size: 18),
                        label: Text('Adım Adım'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue.shade600),
                      ),
                  ],
                ),

                SizedBox(height: 12),

                // Tarif İçeriği
                if (isStepByStepMode) ...[
                  // Adım Adım Mod
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        // Adım Göstergesi
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                'Adım ${currentStep + 1}/${displayAdimlar.length}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${((currentStep + 1) / displayAdimlar.length * 100).round()}%',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        LinearProgressIndicator(
                          value: (currentStep + 1) / displayAdimlar.length,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                        ),
                        SizedBox(height: 20),

                        // Adım İçeriği
                        Text(
                          displayAdimlar.isNotEmpty ? displayAdimlar[currentStep] : "Adım bulunamadı",
                          style: TextStyle(fontSize: 18, height: 1.6, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),

                         // Navigasyon Butonları
                         Row(
                           children: [
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: currentStep > 0 ? _previousStep : null,
                                 icon: Icon(Icons.arrow_back),
                                 label: Text('Önceki'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.grey.shade300,
                                   foregroundColor: Colors.grey.shade700,
                                   padding: EdgeInsets.symmetric(vertical: 12),
                                 ),
                               ),
                             ),
                             SizedBox(width: 16),
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: currentStep < displayAdimlar.length - 1 
                                   ? () => _nextStep(displayAdimlar)
                                   : () {
                                       setState(() {
                                         isStepByStepMode = false;
                                         currentStep = 0;
                                       });
                                     },
                                 icon: Icon(currentStep < displayAdimlar.length - 1 ? Icons.arrow_forward : Icons.check),
                                 label: Text(currentStep < displayAdimlar.length - 1 ? 'Sonraki' : 'Tamamlandı'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: currentStep < displayAdimlar.length - 1 ? Colors.blue.shade600 : Colors.green.shade600,
                                   foregroundColor: Colors.white,
                                   padding: EdgeInsets.symmetric(vertical: 12),
                                 ),
                               ),
                             ),
                           ],
                         ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Normal Mod
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayTarif, // DİLE GÖRE TARİF
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}