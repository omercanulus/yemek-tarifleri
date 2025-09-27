import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yemek_tarifleri/kayit_ekrani.dart';
import 'package:yemek_tarifleri/kullanici_profili.dart';
import 'package:yemek_tarifleri/main.dart';
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

  Future<void> signIn() async {
    final supabase = Supabase.instance.client;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Loading'i kapat
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (response.user != null) {
        kullaniciGirisYapti = true;
        
        // Giriş yapıldığında favorileri cache'le
        try {
          final List<dynamic> rows = await Supabase.instance.client
              .from('favorites')
              .select('yemek_ad')
              .eq('user_id', response.user!.id);
          
          final Set<String> favorites = rows.map((row) => row['yemek_ad'] as String).toSet();
          FavoriCache.updateFavorites(favorites);
        } catch (e) {
          print('Giriş sonrası favori cache yüklenirken hata: $e');
        }
        
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı! Hoş geldiniz! '),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Giriş başarılıysa profil sayfasına git
        Navigator.of(context).pushAndRemoveUntil(
          FadeRoute(page: const KullaniciProfili()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarısız oldu. Lütfen bilgilerinizi kontrol edin.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      Navigator.pop(context);
      
      String errorMessage = 'Bir hata oluştu';
      
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Email veya şifre hatalı';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Email adresinizi onaylayın';
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ProfilSayfasi()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.black))),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(
                children: [
                  Text(
                    'Giriş Yap',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hesabına Giriş Yap',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Colors.grey.shade700),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // 4. inputFile içine controller gönderiyoruz
                    inputFile(label: 'E-posta', controller: emailController),
                    inputFile(label: 'Şifre', obscureText: true, controller: passwordController)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.blue.shade300)),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    color: Colors.blue.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                    // 3. signIn fonksiyonunu burada çağırıyoruz
                    onPressed: signIn,
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 25, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bir hesabınız yok mu?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, SlideUpRoute(page: KayitEkrani()));
                    },
                    child: Text(
                      'Kaydolun',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade600),
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 100),
                height: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/assets/images/dondurma.png'), fit: BoxFit.fitHeight)),
              )
            ]))
          ])),

    );
  }
}

// 1. inputFile widget'ına controller parametresi eklenmeli
Widget inputFile({required String label, bool obscureText = false, required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
