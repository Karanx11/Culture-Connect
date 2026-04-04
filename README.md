# 🌍 Culture Connect – Social Media App

Culture Connect is a full-featured social media mobile application built using **Flutter + Firebase + Cloudinary**, inspired by Instagram.

It allows users to share posts, stories, reels, follow others, and interact through likes, comments, and notifications.

---

## 🚀 Features

### 👤 Authentication

- Firebase Email/Password login & signup
- Email verification system
- Persistent login session

---

### 🏠 Feed (Home Screen)

- Real-time posts from all users
- Like, comment, and share functionality
- Image + video support
- Tap user → open profile

---

### 🎥 Explore (Reels)

- Vertical scroll reels (like Instagram)
- Auto-play videos
- Like & share functionality
- Profile navigation from reels

---

### 🔍 Search

- Search users by username
- Search posts by caption
- Explore grid (all posts)
- Tap post → full post view

---

### 👤 Profile System

- Profile photo & cover photo
- Bio, username, name
- Followers / Following system
- Follow / Unfollow
- Editable profile
- Tabs:
  - Posts
  - Reels

---

### 📸 Stories

- Add story (image)
- View stories
- Auto play

---

### ⭐ Highlights (PRO)

- Create highlight from stories
- Custom cover image
- Multiple stories per highlight
- Edit & delete highlights
- Instagram-style UI

---

### ❤️ Social Features

- Like posts
- Comment system
- Share post link
- Follow system

---

### 🔔 Notifications (Advanced)

- Real-time notifications for:
  - Follow
  - Like
  - Comment
- Seen / Unseen status
- Notification badge 🔴
- Swipe to delete
- Open profile/post from notification

---

### 📲 Push Notifications

- Firebase Cloud Messaging (FCM)
- Background & foreground notifications
- Triggered via Firebase Functions

---

## 🛠️ Tech Stack

### Frontend

- Flutter (Dart)

### Backend

- Firebase Authentication
- Cloud Firestore (Database)
- Firebase Cloud Messaging (Push Notifications)

### Media Storage

- Cloudinary (Images & Videos)

---

## 📂 Project Structure

lib/
│
├── screens/
│ ├── auth/
│ ├── home_screen.dart
│ ├── explore_screen.dart
│ ├── search_screen.dart
│ ├── profile_screen.dart
│ ├── add_post_screen.dart
│ ├── story/
│ ├── highlight/
│ ├── notification_screen.dart
│
├── widgets/
├── utils/
├── main.dart


---

## ⚙️ Setup Instructions

### 1️⃣ Clone Repository

git clone https://github.com/Karanx11/Culture-Connect.git
cd culture-connect
2️⃣ Install Dependencies
flutter pub get
3️⃣ Firebase Setup
Create project in Firebase
Enable:
Authentication (Email/Password)
Firestore Database
Cloud Messaging
Add google-services.json to:
android/app/
4️⃣ Cloudinary Setup
Create account
Get:
Cloud Name
Upload Preset
Replace upload function in code
5️⃣ Run App
flutter run


# 📸 Screenshots

🔐 Auth Screen

🏠 Home Feed

🎥 Reels / Explore

👤 Profile

⭐ Highlights

🔔 Notifications

## 🔥 Future Improvements

Chat system (DM)
Saved posts
Story viewers list
Explore algorithm
Dark/light theme toggle

## 👨‍💻 Author

Karan Sharma

⭐ Show your support

If you like this project, give it a ⭐ on GitHub!