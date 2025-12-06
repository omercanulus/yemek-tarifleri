import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/kayit_ekrani.dart';
import 'package:yemek_tarifleri/animations.dart';

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    // ARTIK 'isEnglish' KONTROLÜNE GEREK YOK
    // EasyLocalization bunu 'tr()' fonksiyonu ile hallediyor.

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    'welcome'.tr(), // JSON'daki "Hoş Geldiniz"i çeker
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'welcome_desc'.tr(), // JSON'daki açıklamayı çeker
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/dondurma.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  // GİRİŞ YAP BUTONU
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, SlideLeftRoute(page: GirisEkrani()));
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'login'.tr(), // "Giriş Yap"
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20),
                  // KAYIT OL BUTONU
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, SlideLeftRoute(page: KayitEkrani()));
                    },
                    color: Colors.blue.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'signup'.tr(), // "Kaydol"
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}