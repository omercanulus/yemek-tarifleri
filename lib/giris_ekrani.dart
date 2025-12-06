import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/kayit_ekrani.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/globals.dart'; // FavoriCache ve kullaniciGirisYapti için
import 'package:yemek_tarifleri/animations.dart';
import 'package:yemek_tarifleri/profil_sayfasi.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    // Dil Kontrolü
    bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(isEnglish ? "Please fill in all fields" : "Lütfen tüm alanları doldurun");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        kullaniciGirisYapti = true;
        
        // Giriş yapıldığında favorileri veritabanından çekip Cache'i güncelle
        try {
          final List<dynamic> rows = await Supabase.instance.client
              .from('favorites')
              .select('yemek_ad')
              .eq('user_id', response.user!.id);
          
          final Set<String> favorites = rows.map((row) => row['yemek_ad'] as String).toSet();
          FavoriCache.updateFavorites(favorites);
        } catch (e) {
          print('Favori yükleme hatası: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEnglish ? "Login successful! Welcome!" : "Giriş başarılı! Hoş geldiniz!"),
              backgroundColor: Colors.green,
            ),
          );
          
          // Profil sayfasına git (Geri dönemesin)
          Navigator.of(context).pushAndRemoveUntil(
            FadeRoute(page: const KullaniciProfili()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      String errorMessage = isEnglish ? "An error occurred" : "Bir hata oluştu";
      
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = isEnglish ? "Invalid email or password" : "Email veya şifre hatalı";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = isEnglish ? "Please confirm your email address" : "Lütfen email adresinizi onaylayın";
      } else if (e.toString().contains('Network')) {
        errorMessage = isEnglish ? "Check your internet connection" : "İnternet bağlantınızı kontrol edin";
      }
      
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      resizeToAvoidBottomInset: false, // Klavye açılınca tasarım bozulmasın
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // Geri butonu direkt ana Profil (Welcome) sayfasına atsın
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ProfilSayfasi()),
              (route) => false,
            );
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        isEnglish ? "Login" : "Giriş Yap",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        isEnglish ? "Login to your account" : "Hesabına giriş yap",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        inputFile(label: isEnglish ? "Email" : "E-posta", controller: emailController),
                        inputFile(label: isEnglish ? "Password" : "Şifre", obscureText: true, controller: passwordController)
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: isLoading ? null : signIn,
                        color: Colors.blue.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        child: isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEnglish ? "Login" : "Giriş Yap",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(isEnglish ? "Don't have an account? " : "Bir hesabın yok mu? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, SlideUpRoute(page: KayitEkrani()));
                        },
                        child: Text(
                          isEnglish ? "Sign up" : "Kaydolun",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100),
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/assets/images/dondurma.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// inputFile fonksiyonu burada da lazım olabilir, ama zaten Kayıt ekranıyla aynı dosyada 
// tanımlı değilse en alta eklemek gerekir. Yukarıdaki aynı inputFile'ı buraya da ekle:
Widget inputFile({required String label, bool obscureText = false, required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade400)),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}