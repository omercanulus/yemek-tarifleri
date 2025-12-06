import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'package:yemek_tarifleri/tarif_sayfasi.dart'; // Detay sayfası
import 'package:yemek_tarifleri/animations.dart'; // Slide efekti

class FavorilerSayfasi extends StatefulWidget {
  // Artık dışarıdan liste almasına gerek yok, kendisi çekecek
  const FavorilerSayfasi({super.key, required List<dynamic> yemekListesi}); 

  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  List<Yemek> favoriYemekler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _favorileriGetir();
  }

  Future<void> _favorileriGetir() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      // 1. Önce favori tablosundan kullanıcının kaydettiği yemek isimlerini alalım
      final favResponse = await Supabase.instance.client
          .from('favorites')
          .select('yemek_ad')
          .eq('user_id', user.id);

      List<String> favNames = (favResponse as List)
          .map((e) => e['yemek_ad'] as String)
          .toList();

      if (favNames.isEmpty) {
        if (mounted) {
          setState(() {
            favoriYemekler = [];
            isLoading = false;
          });
        }
        return;
      }

      // 2. Bu isimlere sahip olan yemeklerin detaylarını 'yemekler' tablosundan çekelim
      final yemekResponse = await Supabase.instance.client
          .from('yemekler')
          .select()
          .filter('ad', 'in', '(${favNames.map((e) => "'$e'").join(',')})'); // 'ad' sütunu favori listesinde olanları getir

      if (mounted) {
        setState(() {
          favoriYemekler = (yemekResponse as List)
              .map((item) => Yemek.fromMap(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Favori getirme hatası: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Favorilerim",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Geri butonunu kaldırıyoruz (Tab bar var)
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriYemekler.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesGrid(),
    );
  }

  // Favori listesi boşsa gösterilecek ekran
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Henüz favorin yok",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Beğendiğin tarifleri kaydetmeye başla!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Dolu ise gösterilecek ızgara yapısı
  Widget _buildFavoritesGrid() {
    return RefreshIndicator(
      onRefresh: _favorileriGetir,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Yan yana 2 kutu
          childAspectRatio: 0.75, // Dikey dikdörtgen (Instagram style)
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favoriYemekler.length,
        itemBuilder: (context, index) {
          final yemek = favoriYemekler[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, SlideRightRoute(page: TarifSayfasi(yemek: yemek)));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Yemek Resmi
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.asset(
                        yemek.foto,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Yemek Bilgileri
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            yemek.getAd(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.orange[800]),
                              const SizedBox(width: 4),
                              Text(
                                "${yemek.hazirlamaSuresi} dk",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.favorite, color: Colors.red, size: 20),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}