import random
import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from huggingface_hub import InferenceClient
import requests
import io

# --- SETTİNGS ---
# 1. Hugging Face Token 
HUGGING_FACE_API_KEY = "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"

# 2. API Ninjas Key 
NUTRITION_API_KEY = "BzLvIP87zXQjWw8bCAvXSw==nINesLnvwBNBjJHt"

# MODEL: Google ViT
MODEL_ID = "google/vit-base-patch16-224"

app = Flask(__name__)
CORS(app)

meals = []

def get_nutrition_info(query):
    """
    Önce API'yi dener. Eğer API sayı yerine 'Premium' yazısı gönderirse
    bunu reddeder ve Yedek Veritabanını kullanır.
    """
    clean_query = query.split(',')[0].strip().lower()
    
    # ---  ---
    backup_db = {
        # 
        "banana": 89, "apple": 52, "green apple": 50, "red apple": 55,
        "orange": 47, "mandarin": 53, "pomegranate": 83, "grape": 67,
        "strawberry": 32, "watermelon": 30, "melon": 34, "peach": 39,
        "pear": 57, "cherry": 50, "lemon": 29,
        
        # 
        "pizza": 266, "burger": 295, "hamburger": 295, "cheeseburger": 303,
        "fries": 312, "french fries": 312, "hot dog": 290, "sandwich": 250,
        "kebab": 200, "doner": 250, "chicken": 239, "meatball": 197,
        "pasta": 131, "rice": 130, "soup": 50, "steak": 271,
        
        # 
        "bread": 265, "egg": 155, "cheese": 402, "yogurt": 59,
        "chocolate": 546, "cake": 371, "cookie": 502, "donut": 452,
        "salad": 20, "caesar salad": 44, "water": 0, "coke": 140, 
        "coffee": 2, "tea": 1, "milk": 42, "potato": 77
    }
    
    # 
    if "water" in clean_query or "bottle" in clean_query:
        return 0

    print(f"🔍 API'ye Soruluyor: '{clean_query}'")
    
    # 1. 
    api_url = 'https://api.api-ninjas.com/v1/nutrition?query=' + clean_query
    
    try:
        response = requests.get(api_url, headers={'X-Api-Key': NUTRITION_API_KEY})
        
        if response.status_code == 200:
            data = response.json()
            
            if isinstance(data, list) and len(data) > 0 and 'calories' in data[0]:
                val = data[0]['calories']
                
                # 👇 İŞTE BURASI ÇÖZÜM: Gelen şey bir SAYI mı? (int veya float)
                if isinstance(val, (int, float)):
                    print(f"✅ API Gerçek Sayı Verdi: {val} kcal")
                    return val
                else:
                    print(f"⚠️ API saçmaladı (Yazı gönderdi): '{val}' -> Yedeğe geçiliyor.")
            else:
                print("⚠️ API cevabı boş veya anlaşılmadı.")

    except Exception as e:
        print(f"❌ API Bağlantı Hatası: {e}")
    
    # 2. B PLAN
    print(f"🔄 Yedek Veritabanında aranıyor: '{clean_query}'...")
    
    # 
    if clean_query in backup_db:
        print(f"💾 Yedek Listeden bulundu: {clean_query} -> {backup_db[clean_query]} kcal")
        return backup_db[clean_query]
    
    # 
    for key in backup_db:
        if key in clean_query or clean_query in key:
             print(f"💾 Yedek Listeden (Benzer) bulundu: {key} -> {backup_db[key]} kcal")
             return backup_db[key]

    print("❌ Listede yok, 0 dönüyor.")
    return 0

@app.route('/api/analyze-image', methods=['POST'])
def analyze_image():
    print("\n📸 --- FOTOĞRAF GELDİ ---")
    
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    file = request.files['image']
    
    # ADIM 1: Resmi geçici olarak kaydet
    temp_filename = "temp_image.jpg"
    try:
        file.save(temp_filename)
    except Exception as e:
        return jsonify({"error": "Server file error"}), 500

    try:
        # 2:
        client = InferenceClient(token=HUGGING_FACE_API_KEY)
        
        print(f"⏳ Yapay Zeka ({MODEL_ID}) düşünüyor...")
        
        #  3: 
        results = client.image_classification(temp_filename, model=MODEL_ID)
        
        detected_food_name = "Unknown"
        confidence = 0
        
        if isinstance(results, list) and len(results) > 0:
            best_guess = results[0]
            if hasattr(best_guess, 'label'):
                detected_food_name = best_guess.label
                confidence = best_guess.score
            elif isinstance(best_guess, dict) and 'label' in best_guess:
                detected_food_name = best_guess['label']
                confidence = best_guess['score']
            
            print(f"✅ AI Gördü: {detected_food_name} (Güven: {confidence:.2f})")
            
        else:
             print(f"⚠️ Sonuç anlaşılamadı")
             if os.path.exists(temp_filename):
                 os.remove(temp_filename)
             return jsonify({"name": "Try Again", "calories": 0})

        #  4: 
        calories = 0
        display_name = detected_food_name.split(',')[0].strip().capitalize()
        
        if detected_food_name != "Unknown":
            search_query = detected_food_name.split(',')[0].strip()
            print(f"🥷 Ninja'ya soruluyor: '{search_query}'")
            calories = get_nutrition_info(search_query)
        
        print(f"🏁 SONUÇ: {display_name} - {calories} kcal")
        
        #  5: 
        if os.path.exists(temp_filename):
            os.remove(temp_filename)
        
        return jsonify({
            "name": display_name,
            "calories": calories
        })

    except Exception as e:
        print(f"❌ HATA: {e}")
        if os.path.exists(temp_filename):
            os.remove(temp_filename)
        return jsonify({"name": "Error", "calories": 0}), 500

# 
@app.route('/api/meals/add', methods=['POST'])
def add_meal():
    data = request.json
    
    # 
    data['id'] = random.randint(1000, 999999) 
    
    meals.append(data)
    
    print(f"💾 Yemek Kaydedildi: {data.get('name')} (ID: {data['id']})")
    
    # 
    return jsonify(data), 200

@app.route('/api/meals', methods=['GET'])
def get_meals():
    user_id = request.args.get('userId')
    if user_id:
        return jsonify([m for m in meals if m.get('userId') == user_id])
    return jsonify(meals)

if __name__ == '__main__':
    # 
    app.run(host='0.0.0.0', port=5000, debug=False)
