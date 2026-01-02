import 'dart:convert';
import 'dart:typed_data'; // Web için byte işlemleri
import 'package:flutter/foundation.dart'; // Web/Mobil ayrımı için (kIsWeb)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../providers/meal_provider.dart';
import '../providers/auth_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhotoAndAnalyze() async {
    try {
      // 1. Kamerayı Aç
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (photo == null) return;

      setState(() {
        _isAnalyzing = true;
      });

      // Dosyayı Byte (Sayı dizisi) olarak oku.
      final bytes = await photo.readAsBytes();

      // 2. Fotoğrafı Sunucuya Gönder
      // Senin IP Adresin:
      String ip = "10.78.171.213";

      // NOT: Web'de "http" isteği bazen güvenlik takılabilir ama
      // "flutter run -d chrome --web-renderer html" ile genelde çalışır.
      var uri = Uri.parse('http://$ip:5000/api/analyze-image');

      var request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'upload.jpg',
      ));

      print("📤 Fotoğraf gönderiliyor...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("📥 AI Sonucu: $result");

        if (!mounted) return;

        // 3. Sonucu Kaydet
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final mealProvider = Provider.of<MealProvider>(context, listen: false);
        final userId = authProvider.email ?? "1";

        // 🔥 DÜZELTME BURADA: Kaloriyi TAM SAYI (int) yapıyoruz
        int calories = 0;
        if (result['calories'] != null) {
          // Gelen sayı ne olursa olsun (int veya double), int'e çevir
          calories = (result['calories'] as num).toInt();
        }

        await mealProvider.addMeal(
          userId,
          result['name'],
          calories, // Artık burası int, hata vermeyecek
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Başarılı: ${result['name']} ($calories kcal)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Hata: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 WEB İÇİN ÖZEL EKRAN
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Web Modu", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                "Kamera özelliği Web'de kapalıdır.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Lütfen fotoğraf yüklemek için\nmobil uygulamayı kullanın.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Geri Dön",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    // 🔥 MOBİL İÇİN KAMERA EKRANI
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined,
                  size: 100, color: Colors.white24),
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      "Analiz ediliyor...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isAnalyzing)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "Fotoğraf Çek & Analiz Et",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _takePhotoAndAnalyze,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 4),
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.camera, size: 40, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("İptal",
                        style: TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
