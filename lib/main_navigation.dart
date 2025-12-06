import 'package:flutter/material.dart';
import 'package:yemek_tarifleri/home_feed.dart'; // Birazdan oluşturacağız
import 'package:yemek_tarifleri/search_page.dart'; // Birazdan oluşturacağız
import 'package:yemek_tarifleri/world_cuisine_page.dart'; // Dünya mutfağı
import 'package:yemek_tarifleri/favoriler_sayfasi.dart'; // Mevcut dosyan
import 'package:yemek_tarifleri/kullanici_profili.dart'; // Mevcut dosyan (veya profil_sayfasi.dart)
import 'package:yemek_tarifleri/globals.dart'; // Veri listesi için gerekebilir

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Sayfaların Listesi
  final List<Widget> _pages = [
    const HomeFeed(),          // 1. Anasayfa (Akış)
    const SearchPage(),        // 2. Arama
    const WorldCuisinePage(),  // 3. Dünya Mutfağı
    const FavorilerSayfasi(yemekListesi: []), // Parametre artık kullanılmıyor ama constructor istiyorsa içi boş kalabilir
    const KullaniciProfili(),  // 5. Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // 5 ikon olduğu için fixed şart
          backgroundColor: Colors.white,
          selectedItemColor: Colors.amber[800], // Tasarımdaki Amber rengi
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false, // Daha temiz görünüm için label kapatılabilir
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'World'), // Globe ikonu
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}