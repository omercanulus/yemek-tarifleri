import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/yemek.dart';
import 'package:yemek_tarifleri/tarif_sayfasi.dart'; // Detay sayfası için
import 'package:yemek_tarifleri/animations.dart'; // Slide efekti için

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Yemek> yemekler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _verileriGetir();
  }

  Future<void> _verileriGetir() async {
    // Supabase'den verileri çekme mantığı (Mevcut kodundan)
    try {
      final response = await Supabase.instance.client.from('yemekler').select();
      if (mounted) {
        setState(() {
          yemekler = (response as List).map((item) => Yemek.fromMap(item)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'recipeD',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito', // Senin fontun
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber[800],
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Follows'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Sekme: For You (Veritabanından gelenler)
          _buildFeedList(),
          // 2. Sekme: Follows (Şimdilik boş veya aynı liste)
          const Center(child: Text("Takip ettiğiniz şefler burada görünecek")),
        ],
      ),
    );
  }

  Widget _buildFeedList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: yemekler.length,
      itemBuilder: (context, index) {
        final yemek = yemekler[index];
        return _buildRecipeCard(yemek);
      },
    );
  }

  Widget _buildRecipeCard(Yemek yemek) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar ve Kullanıcı Adı (Şimdilik Mock Data)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150'), // Mock Avatar
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "chef_omercan", // Mock Username
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "İstanbul, TR",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
          ),

          // Görsel (Tıklanabilir -> Detaya gider)
          GestureDetector(
            onTap: () {
               Navigator.push(context, SlideRightRoute(page: TarifSayfasi(yemek: yemek)));
            },
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(
                yemek.foto, // Senin yerel asset yolun
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
              ),
            ),
          ),

          // Alt Kısım: Butonlar ve Açıklama
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İkonlar
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 28),
                    const SizedBox(width: 6),
                    const Text("324", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline, size: 28),
                    const SizedBox(width: 6),
                    const Text("42", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Başlık ve Açıklama
                Text(
                  yemek.getAd(context),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bu nefis tarifin hazırlama süresi sadece ${yemek.hazirlamaSuresi} dakika!", // Mock açıklama
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}