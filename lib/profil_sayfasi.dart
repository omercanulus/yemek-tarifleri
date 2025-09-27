import 'package:flutter/material.dart';
import 'package:yemek_tarifleri/ana_sayfa.dart';
import 'package:yemek_tarifleri/giris_ekrani.dart';
import 'package:yemek_tarifleri/kayit_ekrani.dart';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({super.key});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        // backgroundColor: Colors.blue,
       body: SingleChildScrollView(
         child: SafeArea(
          child: Container(
            width: double.infinity,
            //height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 30,vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0,),
            Column(
              children: [
                Text.rich(
            TextSpan(
              children:[
                TextSpan(
                  text: 'yemek',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color:Colors.blue.shade200,
                  fontSize: 50,
                  fontWeight: FontWeight.w900)
                ),
                TextSpan(
                  text: 'tarifleri',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  )
                )
              ]
             ),
          ),
                SizedBox(
                  height:30,
                ),
                Container(
                  height: MediaQuery.of(context).size.height/2.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/images/pizza.png'
                      ),
                      fit: BoxFit.fill
                      ),
                  ),
                ),
                SizedBox(height: 60,),
                Column(
                  children: [
                    MaterialButton(
                      color: Colors.blue[200],
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>GirisEkrani()));
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.blue.shade300
                      ),
                    borderRadius: BorderRadius.circular(50)
                    ),
                      child: Text('Giriş Yap',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20
                      ),),
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      color: Colors.black,
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>KayitEkrani()));
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color:Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('Kaydol',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900
                    ),),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                      child: Text('Giriş yapmadan devam et',
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                      onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Anasayfa()));
                    },)
                  ],
                )
              ],
            )
          ],
          ),
         )),
       ),
       
            
      );
    
  }
}