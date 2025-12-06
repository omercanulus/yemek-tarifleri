import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart'; // Ana sayfaya yönlendirmek için
import 'package:yemek_tarifleri/giris_ekrani.dart'; // Giriş ekranına dönmek için
import 'package:yemek_tarifleri/animations.dart';
import 'package:yemek_tarifleri/globals.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  // Controller'lar veriyi almak için gerekli
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isLoading = false; // Yükleniyor durumu

  Future<void> signUp() async {
    // Dil Kontrolü (Hata mesajları için)
    bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // 1. Basit Kontroller
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError(isEnglish ? "Please fill in all fields" : "Lütfen tüm alanları doldurun");
      return;
    }

    if (password != confirmPassword) {
      _showError(isEnglish ? "Passwords do not match" : "Şifreler uyuşmuyor");
      return;
    }

    if (password.length < 6) {
      _showError(isEnglish ? "Password must be at least 6 characters" : "Şifre en az 6 karakter olmalı");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 2. Supabase Kayıt İşlemi
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Kayıt Başarılı!
        // Supabase bazen kayıt sonrası otomatik giriş yapmaz, o yüzden manuel giriş de yapıyoruz garanti olsun
         await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        kullaniciGirisYapti = true;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEnglish ? "Account created successfully! Welcome!" : "Hesap başarıyla oluşturuldu! Hoş geldiniz!"),
              backgroundColor: Colors.green,
            ),
          );
          
          // Ana sayfaya yönlendir ve geçmişi sil (Geri dönemesin)
          Navigator.of(context).pushAndRemoveUntil(
            FadeRoute(page: Anasayfa()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Hata Yönetimi
      String errorMessage = isEnglish ? "An error occurred" : "Bir hata oluştu";
      
      if (e.toString().contains("already registered") || e.toString().contains("unique constraint")) {
        errorMessage = isEnglish ? "This email is already in use" : "Bu e-posta adresi zaten kayıtlı";
      } else if (e.toString().contains("Network")) {
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
  Widget build(BuildContext context) {
    bool isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    isEnglish ? "Sign up" : "Kaydol",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isEnglish ? "Create an account, it's free" : "Hesap oluştur, tamamen ücretsiz",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: isEnglish ? "Email" : "E-posta", controller: emailController),
                  inputFile(label: isEnglish ? "Password" : "Şifre", obscureText: true, controller: passwordController),
                  inputFile(label: isEnglish ? "Confirm Password" : "Şifre Tekrar", obscureText: true, controller: confirmPasswordController),
                ],
              ),
              Container(
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
                  onPressed: isLoading ? null : signUp, // Yüklenirken tıklanmasın
                  color: Colors.blue.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  child: isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text(
                        isEnglish ? "Sign up" : "Kaydol",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(isEnglish ? "Already have an account? " : "Zaten bir hesabın var mı? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, SlideRightRoute(page: GirisEkrani()));
                    },
                    child: Text(
                      isEnglish ? "Login" : "Giriş Yap",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Yardımcı Widget: Giriş Kutusu (Aynen kullanıyoruz)
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