<div align="center">
  
# 🪷 Sakhya: Financial Independence for Rural Women
<img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/579d9dbb-4f45-4237-a3dd-80d2cd00ba25"/>


> *"We don’t teach theory. We simulate survival."*

**Team:** FinSpark  
**Hackathon:** Gamifying Financial Literacy for Bharat. Interactive Learning through Play  
**Track B:** The Woman  
**Problem Statement:** Overcoming the psychological barriers of digital finance for rural women.

[![Demo Video](https://img.shields.io/badge/🎥_Demo_Video-Click_Here-red?style=for-the-badge)](https://drive.google.com/file/d/19ZkYxHghAnsuMGvaq4wuZI7l3uHHYx1N/view?usp=drive_link)
[![PPT Presentation](https://img.shields.io/badge/📊_Pitch_Deck-Click_Here-blue?style=for-the-badge)](https://www.canva.com/design/DAHFUg2ha7o/G94lnDcfBnxIMn3MC3Ycfw/edit?utm_content=DAHFUg2ha7o&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)
[![App Download](https://img.shields.io/badge/📱_Download_App-Click_Here-brightgreen?style=for-the-badge)](https://drive.google.com/file/d/1UpVKyKrVQ6_QB-xVX4u0Wl5UnKLXjB40/view?usp=sharing)

</div>

---

## 📖 About Sakhya

Sakhya is an **offline-first, voice-guided financial simulation app** designed specifically for rural women in Bharat.

Instead of teaching finance through theory, Sakhya helps users **learn by doing**—managing daily income, making spending decisions, and safely experiencing scams in a simulated environment. By turning everyday financial challenges into interactive gameplay, Sakhya builds **confidence, resilience, and digital trust**.

---

## 🌟 Key Features

| Feature | Description |
| :--- | :--- |
| 🔄 **Daily Simulation Loop** | Income Generation → Budget Allocation (Ghar/Dhanda) → Interractive Events (UPI/Scam/Store) → Save → Progress |
| ⚖️ **Two-Pot Budgeting** | Simple slider-based allocation between household and business needs. |
| 🛡️ **Scam Dojo** | Practice identifying and avoiding digital fraud in a safe space. |
| 🏦 **Mock UPI** | A completely safe environment to build trust in digital payments. |
| 🎙️ **Voice Guidance** | **Laxmi Didi**, a step-by-step voice assistant for low-literacy users. |
| 📴 **Offline-First** | Works completely without the internet; syncs only when connected. |

---

## 🛠 Tech Stack & Architecture

### 📱 Frontend (Mobile App)
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Database:** SQLite (`sqflite`) – Offline-first persistence
*   **Accessibility:** `flutter_tts` (Offline voice output) & `speech_to_text` (Voice input)
*   **Network:** `connectivity_plus` (Network detection)

### ☁️ Backend (Cloud Sync Service)
*   **API:** FastAPI (Python)
*   **Database:** PostgreSQL
*   **ORM:** SQLAlchemy + asyncpg
*   **Infrastructure:** Docker & Docker Compose

### 🧠 AI
*   **On-device LLM:** Gemma 2B via MediaPipe *(Ensuring zero-latency intelligence)*

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK installed
*   Docker & Docker Compose installed
*   Python 3.12+ *(Optional)*

### Step 1: Start Backend (Optional)
> 💡 *The app works fully offline. The backend is only used for background synchronization.*

```bash
# Navigate to the project folder
cd Sakhya

# Start the PostgreSQL and FastAPI containers
docker compose -f doker-componse.yml up -d --build

# Verify backend health (Should return {"status": "ok"})
curl http://localhost:5001/health
```

### Step 2: Run Mobile App

```bash
# Navigate to the frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on an emulator or connected device
flutter run
```

### Step 3: Use Ngrok for Demo (Optional)
If you are presenting from a physical phone and want to connect it to your local backend:
```bash
# Start an ngrok tunnel on port 5001
ngrok http 5001
```
Next, update the URL in `frontend/lib/config/app_config.dart`:
```dart
static const String backendUrl = 'https://your-ngrok-url.ngrok-free.app';
```

---

## 🔑 How to Play / Test

1. **Launch the app** and create a new profile (e.g., *Radha*, *Sunita*).
2. **Set a monthly savings goal**.
3. **Start the day** to receive a randomized daily income.
4. **Allocate** the funds between **Ghar** (Household) and **Dhanda** (Business).
5. **Perform daily actions:** Buy supplies, handle incoming scams, and learn financial concepts.
6. **Complete the day** to track your progress and streak.

### 📴 Offline Mode Test
To verify the offline-first architecture:
*   Turn on **Airplane Mode**.
*   Play through an entire day (everything from UI to TTS will work perfectly). 
*   Turn the internet back on; the app will sync data automatically in the background without interrupting the user.

---

## 📸 Screen Previews

*Below are placeholders for key screens showcasing the Sakhya prototype:*

<div align="center">

| User Selection | Profile | Home Dashboard | Income & Allocation|
| :---: | :---: | :---: | :---: |
| ![Screen 1](https://github.com/user-attachments/assets/743dd89e-5801-48f9-89f3-527d699aabbe) | ![Screen 2](https://github.com/user-attachments/assets/e97ef6fb-1dbb-4988-b9cb-669dd570b60a) | ![Screen 3](https://github.com/user-attachments/assets/a5a58299-93cb-4edc-9832-7e493bd2edfe) | ![Screen 4](https://github.com/user-attachments/assets/1ddbc444-8f67-43f5-aa4f-0725bfc4f935) |

| Laxmi Didi Chat | Store (Supplies) | Mock UPI | Scam Dojo(Call) |
| :---: | :---: | :---: | :---: |
| ![Screen 5](https://github.com/user-attachments/assets/92cc6466-af8f-4a83-9f61-2002c4d79d4d) | ![Screen 6](https://github.com/user-attachments/assets/1e220c37-8f59-460e-9053-17e68a680873) | ![Screen 7](https://github.com/user-attachments/assets/ab7e0887-c9cd-4966-9702-045654a29c0c) | ![Screen 8](https://github.com/user-attachments/assets/407c8176-1351-46b2-bf84-8fcdf98eb9df) |

| Learning Module | Streak | End Day Summary | Rewards |
| :---: | :---: | :---: | :---: |
| ![Screen 9](https://github.com/user-attachments/assets/68e5389a-931a-479f-9ae5-b457c934c618) | ![Screen 10](https://github.com/user-attachments/assets/87eb048b-40f6-4f5d-987e-a86acc73da12) | ![Screen 11](https://github.com/user-attachments/assets/563f9724-0388-480f-a1cb-b703ed1121e8) | ![Screen 12](https://github.com/user-attachments/assets/9f6f1ac4-a265-44db-a791-4ee5e2339920) |

</div>

---

## 🎯 The Impact

*   **Builds financial confidence** through low-risk practice.
*   **Reduces fear** of digital transactions and banking.
*   **Improves scam awareness** through simulated exposure.
*   **Designed for real-world rural adoption** with extreme hardware and network tolerance.

---

<div align="center">
  <b>Built for Bharat by Team FinSpark</b>
</div>

## 🤠 Team Members

1. [@Joy Almeida](https://www.linkedin.com/in/joy-almeida0/)
2. [@Sagarika Matey](https://www.linkedin.com/in/sagarika-m-85b876122/)
