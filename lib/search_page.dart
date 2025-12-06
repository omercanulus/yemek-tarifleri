import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Dil desteği için

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Örnek Kategoriler (Daha sonra veritabanından da çekilebilir)
  final List<Map<String, dynamic>> categories = [
    {'name': 'Kahvaltı', 'icon': Icons.egg_alt_outlined, 'color': Colors.orange},
    {'name': 'Akşam Yemeği', 'icon': Icons.dinner_dining, 'color': Colors.red},
    {'name': 'Tatlılar', 'icon': Icons.icecream_outlined, 'color': Colors.pink},
    {'name': 'İçecekler', 'icon': Icons.local_cafe_outlined, 'color': Colors.brown},
    {'name': 'Vegan', 'icon': Icons.grass, 'color': Colors.green},
    {'name': 'Hızlı Atıştırmalık', 'icon': Icons.fastfood_outlined, 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Arama Çubuğu ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Tarif, malzeme veya şef ara...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Filtreleme ekranını burada açabiliriz
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Başlık ---
              const Text(
                "Kategorilere Göz At",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              
              const SizedBox(height: 16),

              // --- Kategori Grid Yapısı ---
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Yan yana 2 kutu
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // Kutuların yatay/dikey oranı
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (cat['color'] as Color).withOpacity(0.3)),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Kategoriye tıklanınca yapılacak işlem
                          print("${cat['name']} tıklandı");
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], size: 40, color: cat['color']),
                            const SizedBox(height: 10),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cat['color'],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}