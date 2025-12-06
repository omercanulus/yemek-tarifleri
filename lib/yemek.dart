import 'package:flutter/material.dart';

class Yemek {
  final String ad;
  final String adEn; // İngilizce Ad
  final String foto;
  final String tarif;
  final String tarifEn; // İngilizce Tarif
  final List<String> malzemeler;
  final List<String> malzemelerEn; // İngilizce Malzemeler
  final List<String> tarifAdimlari;
  final List<String> tarifAdimlariEn; // İngilizce Adımlar
  
  bool isFavorite;
  final int hazirlamaSuresi;
  final int pisirmeSuresi;

  Yemek({
    required this.ad,
    required this.adEn,
    required this.foto,
    required this.tarif,
    required this.tarifEn,
    required this.malzemeler,
    required this.malzemelerEn,
    required this.tarifAdimlari,
    required this.tarifAdimlariEn,
    this.isFavorite = false,
    required this.hazirlamaSuresi,
    required this.pisirmeSuresi,
  });

  // Veritabanından gelen veriyi çevirirken İngilizce sütunları (name_en vb.) alıyoruz
  factory Yemek.fromMap(Map<String, dynamic> map) {
    return Yemek(
      ad: map['ad'] ?? '',
      // SORUN BURADAYDI: Bu satırın 'name_en' sütununu okuduğundan emin ol
      adEn: map['name_en'] ?? '', 
      foto: map['foto_yolu'] ?? '',
      tarif: map['tarif_metni'] ?? '',
      tarifEn: map['recipe_text_en'] ?? '',
      
      malzemeler: List<String>.from(map['malzemeler'] ?? []),
      malzemelerEn: List<String>.from(map['ingredients_en'] ?? []),
      
      tarifAdimlari: List<String>.from(map['tarif_adimlari'] ?? []),
      tarifAdimlariEn: List<String>.from(map['steps_en'] ?? []),
      
      hazirlamaSuresi: map['hazirlama_suresi'] ?? 0,
      pisirmeSuresi: map['pisirme_suresi'] ?? 0,
      isFavorite: map['favori_mi'] ?? false,
    );
  }

  // --- AKILLI YARDIMCILAR ---
  // Telefonun diline göre doğru metni veren fonksiyonlar

  bool _isEnglish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en';
  }

  String getAd(BuildContext context) {
    // Eğer İngilizce ise ve İngilizce ad boş değilse onu döndür, yoksa Türkçeyi ver
    return _isEnglish(context) && adEn.isNotEmpty ? adEn : ad;
  }

  String getTarif(BuildContext context) {
    return _isEnglish(context) && tarifEn.isNotEmpty ? tarifEn : tarif;
  }

  List<String> getMalzemeler(BuildContext context) {
    return _isEnglish(context) && malzemelerEn.isNotEmpty ? malzemelerEn : malzemeler;
  }

  List<String> getAdimlar(BuildContext context) {
    return _isEnglish(context) && tarifAdimlariEn.isNotEmpty ? tarifAdimlariEn : tarifAdimlari;
  }
}