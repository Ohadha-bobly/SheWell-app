# HerWellness MVP Blueprint – "SheWell"

## 1️⃣ App Overview
**Goal:** Help women track mental and physical health, access resources, and ask health-related questions via an **AI-powered chatbot**.

**Target SDGs:**  
- SDG 3 – Good Health and Well-being  
- SDG 5 – Gender Equality  

---

## 2️⃣ Features

### A. Wellness Tracker
- Track **mood, sleep, and menstrual cycle** (optional: pregnancy, postpartum)
- Log entries saved **locally** using `Hive` or `SharedPreferences`.
- Optional: display **weekly trends** with charts (`fl_chart`).

### B. AI Chatbot
- Users ask questions about:
  - Mental health (stress, anxiety, emotional wellness)  
  - Women’s health (menstrual cycle, reproductive health, self-care tips)
- AI powered by **OpenAI GPT API**.
- Chat UI:  
  - `ListView` for messages  
  - `TextField` + `ElevatedButton` to send messages
- Optional: save chat history locally.

### C. Resources Directory
- List clinics, hotlines, and NGOs with:
  - Name, type, contact info
- Scrollable list using `ListView` and `Card`.
- Optional: location filter.

### D. Notifications / Reminders
- Daily reminder to **log mood**
- Optional: menstrual cycle alerts
- Implement with `flutter_local_notifications`.

---

## 3️⃣ Screens & Navigation

| Screen | Purpose | Widgets |
|--------|---------|--------|
| Home / Tracker | Track mood, sleep, cycle | `Column`, `Card`, `DropdownButton`/`RadioListTile`, `ElevatedButton` |
| Chatbot | Ask AI questions | `ListView`, `TextField`, `ElevatedButton` |
| Resources | Clinics, hotlines, NGOs | `ListView`, `Card`, `ListTile` |
| Settings | Notification preferences | `SwitchListTile`, `TimePicker` |

**Navigation:** BottomNavigationBar: Tracker | Chatbot | Resources | Settings

---

## 4️⃣ Data Models

**1. MoodLog**
```dart
class MoodLog {
  final DateTime date;
  final String mood; // happy, neutral, sad, stressed
  final double sleepHours;
  final String? cycleInfo;

  MoodLog({required this.date, required this.mood, required this.sleepHours, this.cycleInfo});
}

// ChatMessage
class ChatMessage {
  final String message;
  final bool isUser; // true if sent by user, false if AI
  final DateTime timestamp;

  ChatMessage({required this.message, required this.isUser, required this.timestamp});
}

// Resource
class Resource {
  final String name;
  final String type; // clinic, hotline, NGO
  final String contact;

  Resource({required this.name, required this.type, required this.contact});
}

// Packages to Use
| Package                       | Purpose                       |
| ----------------------------- | ----------------------------- |
| `http`                        | API calls to OpenAI GPT       |
| `flutter_dotenv`              | Store API keys securely       |
| `Hive` / `SharedPreferences`  | Local storage for logs & chat |
| `provider`                    | State management              |
| `fl_chart`                    | Trend charts (optional)       |
| `flutter_local_notifications` | Reminders & notifications     |

// AI Chatbot Flow
1. User types question → Flutter sends POST request to OpenAI API
2. API returns AI response
3. Display response in chat UI
4. Optional: save chat to local storage

Example Request (simplified):
final response = await http.post(
  Uri.parse('https://api.openai.com/v1/completions'),
  headers: {
    'Authorization': 'Bearer $OPENAI_API_KEY',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': 'text-davinci-003',
    'prompt': userQuestion,
    'max_tokens': 150,
  }),
);

// MVP Workflow
1. Open app → Home shows today’s wellness summary
2. Log mood, sleep, and cycle
3. Ask question to AI chatbot → response appears instantly
4. Check resources list → scroll clinics/NGOs
5. Receive notifications for reminders
