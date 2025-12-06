import 'package:flutter/material.dart';

// --- GLOBAL DEĞİŞKENLER VE FONKSİYONLAR ---
bool kullaniciGirisYapti = false;

class FavoriCache {
  static Set<String> _favoriYemekler = {};
  static void clear() => _favoriYemekler.clear();
  static void updateFavorites(Set<String> favorites) => _favoriYemekler = favorites;
  static Set<String> getFavorites() => Set.from(_favoriYemekler);
  static bool isFavorite(String yemekAd) => _favoriYemekler.contains(yemekAd);
  static void toggleFavorite(String yemekAd, bool isFavorite) {
    if (isFavorite) _favoriYemekler.add(yemekAd);
    else _favoriYemekler.remove(yemekAd);
  }
}
