import 'package:flutter/material.dart';

class WorldCuisinePage extends StatelessWidget {
  const WorldCuisinePage({super.key});

  final List<Map<String, String>> cuisines = const [
    {'country': 'Türk Mutfağı', 'flag': 'https://flagcdn.com/w320/tr.png'},
    {'country': 'İtalyan', 'flag': 'https://flagcdn.com/w320/it.png'},
    {'country': 'Japon', 'flag': 'https://flagcdn.com/w320/jp.png'},
    {'country': 'Meksika', 'flag': 'https://flagcdn.com/w320/mx.png'},
    {'country': 'Fransız', 'flag': 'https://flagcdn.com/w320/fr.png'},
    {'country': 'Hint', 'flag': 'https://flagcdn.com/w320/in.png'},
    {'country': 'Amerikan', 'flag': 'https://flagcdn.com/w320/us.png'},
    {'country': 'Çin', 'flag': 'https://flagcdn.com/w320/cn.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dünya Mutfakları",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Yan yana 2 ülke
            childAspectRatio: 1.0, // Kare şeklinde
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: cuisines.length,
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        // O ülkenin yemeklerini listeleme sayfasına git
                      },
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 60, // Büyüklük ayarı
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(cuisine['flag']!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cuisine['country']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}