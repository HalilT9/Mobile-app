import requests

# 👇 Senin o uzun garip anahtarın:
long_key = "XLWoI+YQC+/GE6U0SotiXg==VHKhDqJxtxx03KsT"

# İhtimaller (Parçalara ayırıyoruz)
candidates = [
    ("UZUN (Hepsi)", long_key),
    ("SOL PARÇA",    long_key.split('==')[0] + "=="),
    ("SAĞ PARÇA",    long_key.split('==')[1])
]

print("🕵️‍♂️ GERÇEK ANAHTAR TESTİ BAŞLIYOR... (Sayı arıyoruz)\n")
api_url = 'https://api.api-ninjas.com/v1/nutrition?query=apple'

found_real_key = None

for name, key in candidates:
    print(f"🔑 Deneniyor: {name}")
    print(f"👉 Anahtar: {key}")
    
    try:
        response = requests.get(api_url, headers={'X-Api-Key': key.strip()})
        
        if response.status_code == 200:
            data = response.json()
            # Cevabın içinde gerçekten kalori sayısı var mı bakıyoruz?
            if isinstance(data, list) and len(data) > 0 and 'calories' in data[0]:
                cal = data[0]['calories']
                
                # EĞER KALORİ BİR YAZI DEĞİL, SAYI İSE (Örn: 52.0)
                if isinstance(cal, (int, float)):
                    print(f"✅ SONUÇ: {cal} kcal (Bu bir sayı!)")
                    print("\n" + "="*40)
                    print(f"🏆 İŞTE GERÇEK ÇALIŞAN ANAHTAR: {key}")
                    print("="*40)
                    found_real_key = key
                    break # Bulduk, çıkabiliriz!
                else:
                    print(f"⚠️ Hata: Sunucu sayı yerine yazı gönderdi -> '{cal}'")
            else:
                print(f"⚠️ Hata: Cevap boş veya format bozuk: {data}")
        else:
            print(f"❌ Başarısız (Kod: {response.status_code})")
            
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")
    
    print("-" * 30)

if not found_real_key:
    print("\n😔 Hiçbir parça çalışmadı. Hesapta veya mail onayında bir sorun olabilir.")