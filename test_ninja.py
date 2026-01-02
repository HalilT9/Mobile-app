import requests

# 👇 Sitedeki o garip uzun yazının TAMAMINI buraya yapıştır:
glitched_key = "BzLvIP87zXQjWw8bCAvXSw==nINesLnvwBNBjJHt"

# Kodumuz bu yazıyı parçalayıp ihtimalleri deneyecek
candidates = [
    glitched_key,                               # 1. İhtimal: Hepsi
    glitched_key.split('==')[0] + "==",         # 2. İhtimal: Sol Taraf (BzLv...)
    glitched_key.split('==')[1],                # 3. İhtimal: Sağ Taraf (nINes...)
]

print("🕵️‍♂️ DOĞRU ANAHTAR ARANIYOR... Lütfen bekleyin.\n")
api_url = 'https://api.api-ninjas.com/v1/nutrition?query=apple'

found_key = None

for i, key in enumerate(candidates):
    print(f"🔑 {i+1}. Deneme: {key} ...")
    
    try:
        response = requests.get(api_url, headers={'X-Api-Key': key.strip()})
        
        if response.status_code == 200:
            print("\n" + "="*40)
            print("🎉 BINGO! ÇALIŞAN ŞİFRE BULUNDU! 🎉")
            print("="*40)
            print(f"\n👉 {key}")
            print("\n✅ Hemen bunu kopyala ve app.py dosyasına yapıştır!")
            found_key = key
            break
        else:
            print(f"❌ Hata: {response.json().get('error')}")
            
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")

if not found_key:
    print("\n😔 Hiçbiri çalışmadı. Sitedeki 'Regenerate' butonuna basıp yeni bir tane alman gerekebilir.")