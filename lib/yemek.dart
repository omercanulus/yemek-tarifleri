class Yemek {
  final String ad;
  final String foto;
  final String tarif;
  List <String> malzemeler;
  List<String> yazilacakMalzemeler;
  bool isFavorite;
  final int hazirlamaSuresi; // dakika cinsinden
  final int pisirmeSuresi; // dakika cinsinden
  final List<String> tarifAdimlari; // adım adım tarif
  
  Yemek({
  required this.ad ,
  required this.foto, 
  required this.tarif,
  required this.malzemeler,
  required this.yazilacakMalzemeler,
  this.isFavorite=false,
  required this.hazirlamaSuresi,
  required this.pisirmeSuresi,
  required this.tarifAdimlari,
  });
  
}