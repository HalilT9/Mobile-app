from locust import HttpUser, task, between
import random

class CalorieAppUser(HttpUser):
    wait_time = between(1, 3)
    user_id = None

    def on_start(self):
        """Uygulama açılış simülasyonu: Login ol"""
        response = self.client.post("/api/auth/login", json={
            "email": f"test_user_{random.randint(1, 1000)}@example.com",
            "username": "TestUser"
        })
        if response.status_code == 200:
            self.user_id = response.json()['user']['userId'] # String ID döner

    @task(3)
    def load_feed(self):
        """Kullanıcı ana ekranı yeniler (GET Meals)"""
        if self.user_id:
            self.client.get(f"/api/meals/{self.user_id}")

    @task(1)
    def add_manual_meal(self):
        """Manuel yemek ekleme simülasyonu"""
        if self.user_id:
            self.client.post("/api/meals/add", json={
                "userId": self.user_id,
                "name": "Locust Burger",
                "calories": 500,
                "isEaten": True
            })

    @task(1)
    def update_goal(self):
        """Hedef güncelleme"""
        if self.user_id:
            self.client.post("/api/goals/update", json={
                "userId": self.user_id,
                "dailyCalorieGoal": random.randint(1500, 3000)
            })