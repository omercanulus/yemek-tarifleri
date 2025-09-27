import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/main.dart';
import 'package:yemek_tarifleri/animations.dart';
import 'package:yemek_tarifleri/profil_sayfasi.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController passwordConfirmController = TextEditingController();

Future<void> signUp() async {
  final supabase = Supabase.instance.client;

  final email = emailController.text.trim();
  final username = usernameController.text.trim();
  final password = passwordController.text.trim();
  final passwordConfirm = passwordConfirmController.text.trim();

  // Alan kontrolü
  if (email.isEmpty || username.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lütfen tüm alanları doldurun'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Email formatını kontrol et
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geçerli bir email adresi girin'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Kullanıcı adı uzunluğunu kontrol et
  if (username.length < 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kullanıcı adı en az 3 karakter olmalıdır'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Şifre uzunluğunu kontrol et
  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifre en az 6 karakter olmalıdır'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  if (password != passwordConfirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifreler eşleşmiyor'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Loading göster
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    },
  );

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Loading'i kapat
    Navigator.pop(context);

    if (response.user != null) {
      // Kullanıcı adını metadata'ya manuel olarak ekle
      try {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {'username': username},
          ),
        );
      } catch (e) {
        print('Kullanıcı adı güncellenirken hata: $e');
      }
      
      // Kullanıcı giriş yaptı olarak işaretle
      kullaniciGirisYapti = true;
      
      // Yeni kullanıcı için boş favori cache'i oluştur
      FavoriCache.updateFavorites({});

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Hoş geldiniz! '),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Başarılı kayıt sonrası profil sayfasına geçiş
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const KullaniciProfili()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarısız oldu. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    // Loading'i kapat
    Navigator.pop(context);
    
    String errorMessage = 'Bir hata oluştu';
    
    if (e.toString().contains('User already registered')) {
      errorMessage = 'Bu email adresi zaten kayıtlı';
    } else if (e.toString().contains('Password should be at least')) {
      errorMessage = 'Şifre çok kısa';
    } else if (e.toString().contains('Invalid email')) {
      errorMessage = 'Geçersiz email formatı';
    } else if (e.toString().contains('Too many requests')) {
      errorMessage = 'Çok fazla deneme. Lütfen bekleyin';
    } else if (e.toString().contains('Network')) {
      errorMessage = 'İnternet bağlantınızı kontrol edin';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ProfilSayfasi()),
                (route) => false,
              );
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal:40),
            height: MediaQuery.of(context).size.height-200,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Kayıt Ol',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 35,
                      fontWeight: FontWeight.w900,

                    ),),
                    SizedBox(height: 10),
                      Text('Yeni bir hesap oluşturun',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: Colors.grey
                    ))
                    
                  ],
                ),
                Column(
                  children: [
                    inputFile(label: 'Kullanıcı Adı', controller: usernameController),
                    inputFile(label: 'E-posta', controller: emailController),
                    inputFile(label: 'Şifre', obscureText: true, controller: passwordController),
                    inputFile(label: 'Şifreyi Tekrar Giriniz', obscureText: true, controller: passwordConfirmController)
                  ],
                ),
                Container(
                  //padding: EdgeInsets.only(top: 3,left: 3),
                   decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.blue.shade300
                            )
                          ),
                           child: MaterialButton(
                            minWidth: double.infinity,
                            height:60,
                            color: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(60)
                            ),
                            onPressed: () {
                            signUp();
                          },
                          child: Text('Kayıt Ol',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Colors.white
                          ),),
                          ),
                ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Zaten bir hesabınız var mı?'),
                 TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideUpRoute(page: GirisEkrani()),
                    );
                  },
                  child: Text(
                    'Giriş Yapın',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.blue.shade600),
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


Widget inputFile({required String label, bool obscureText = false, required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
