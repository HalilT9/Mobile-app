from locust import HttpUser, task, between
import random

class CalorieAppUser(HttpUser):
    wait_time = between(1, 2)
    # Host'u koda gömüyoruz ki arayüzde hata payı kalmasın
    host = "http://127.0.0.1:5000"

    @task(3)
    def get_meals_list(self):
        self.client.get("/api/meals?userId=stress_test_user")

    @task(1)
    def add_random_meal(self):
        self.client.post("/api/meals/add", json={
            "name": random.choice(["Elma", "Pizza", "Muz"]),
            "calories": random.randint(50, 500),
            "userId": "stress_test_user"
        })

    @task(2)
    def stress_test_ai(self):
        fake_img = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82'
        files = {'image': ('test.jpg', fake_img, 'image/jpeg')}
        self.client.post("/api/analyze-image", files=files)