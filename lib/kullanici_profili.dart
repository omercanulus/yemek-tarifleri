import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/animations.dart';

class KullaniciProfili extends StatefulWidget {
  const KullaniciProfili({super.key});

  @override
  State<KullaniciProfili> createState() => _KullaniciProfiliState();
}

class _KullaniciProfiliState extends State<KullaniciProfili> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentUser = Supabase.instance.client.auth.currentUser;

  // Mock veriler
  final List<String> mockMyRecipes = [
    'assets/images/makarna.jpg',
    'assets/images/pizza.jpg',
    'assets/images/kebab.jpg',
    'assets/images/tatli.jpg', // Test için fazladan veri
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _cikisYap() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        SlideUpRoute(page: const GirisEkrani()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Instagram beyazından kaçış: Hafif gri/mavi tonlu modern zemin
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        centerTitle: true, // Başlığı ortaladık
        title: Text(
          _currentUser?.email?.split('@')[0] ?? "chef_user",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800, // Daha kalın font
            fontFamily: 'Nunito',
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87), // Instagram'ın hamburger menüsü yerine dikey üç nokta
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. MODERN PROFİL KARTI (Hero Section)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // Yumuşak köşeler
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ortalı Profil Fotoğrafı
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade300, width: 2), // Marka rengi vurgusu
                  ),
                  child: const CircleAvatar(
                    radius: 45, // Biraz daha büyük
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                ),
                const SizedBox(height: 12),
                
                // İsim
                const Text(
                  "Ömer Can Ulus",
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 22,
                    color: Colors.black87
                  ),
                ),
                
                // Biyografi (Ortalı)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "👨‍🍳 Food Lover & Developer | İstanbul 📍\nLezzetli tarifler paylaşıyorum.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                ),

                const SizedBox(height: 16),

                // İstatistikler (Yatay Şerit - Instagram'dan farklılaşma noktası)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModernStat("3", "Tarif"),
                    Container(height: 24, width: 1, color: Colors.grey.shade300), // Dikey çizgi ayıracı
                    _buildModernStat("1.2M", "Takipçi"),
                    Container(height: 24, width: 1, color: Colors.grey.shade300),
                    _buildModernStat("145", "Takip"),
                  ],
                ),

                const SizedBox(height: 20),

                // Butonlar (Tam Oval / Pill Shape)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          elevation: 0,
                          shape: const StadiumBorder(), // Hap şeklinde buton
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Düzenle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Paylaş", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Tab Bar (Daha minimalist)
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.orange, // Marka rengi
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey.shade400,
            dividerColor: Colors.transparent, // Alt çizgiyi kaldırdık
            tabs: const [
              Tab(text: "Tariflerim"), // İkon yerine yazı (Daha blog havası)
              Tab(text: "Kaydedilenler"),
            ],
          ),

          // 3. İçerik Izgarası
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildModernGrid(mockMyRecipes),
                _buildModernGrid([]), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern İstatistik Tasarımı
  Widget _buildModernStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 0.5),
        ),
      ],
    );
  }

  // Modern Grid Yapısı (2 Sütun, Boşluklu, Yuvarlak Köşeli)
  Widget _buildModernGrid(List<String> images) {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text("Henüz içerik yok", style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16), // Kenarlardan boşluk
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 3 yerine 2 sütun (Daha ferah)
        crossAxisSpacing: 16, // Yatay boşluk
        mainAxisSpacing: 16, // Dikey boşluk
        childAspectRatio: 0.8, // Kare değil, hafif dikey dikdörtgen (Pinterest havası)
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // Görsellerin köşeleri yuvarlak
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(images[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.settings, color: Colors.orange),
                ),
                title: const Text("Ayarlar", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {},
              ),
              const Divider(indent: 20, endIndent: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _cikisYap();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}