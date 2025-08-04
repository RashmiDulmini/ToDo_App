# 📱 To-Do List Mobile App

A clean and intuitive mobile To-Do list app built with **Flutter**, powered by a **Node.js + Express.js** backend and **PostgreSQL** database. This app allows users to create custom task lists, filter by priority, and manage them efficiently from their mobile device.

---

## ✨ Features

### ✅ Task Management
- Add tasks with **title** and **priority** (High, Medium, Low)
- Mark tasks as **completed**
- Delete completed or unnecessary tasks

### 📂 List Management
- Create **custom task lists**
- Rename or delete lists via the `...` menu
- Delete all completed tasks in a list


### 🖼️ Mobile-Friendly UI
- Designed using **Material Design** with:
  - Large touch-friendly buttons
  - Clear visual hierarchy
  - Color-coded priorities
- Supports Android and iOS

---

## 🏗️ Tech Stack

| Layer       | Technology       |
|-------------|------------------|
| Frontend    | Flutter, Dart     |
| Backend     | Node.js, Express.js |
| Database    | PostgreSQL        |
| Networking  | `http` package in Flutter |

---

## 🚀 Getting Started

### 📦 Prerequisites
- Flutter SDK installed: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Node.js installed: [Install Node.js](https://nodejs.org/)
- PostgreSQL installed: [Install PostgreSQL](https://www.postgresql.org/download/)
- Android/iOS Emulator or a physical device

---

### 💻 Backend Setup

```bash
# 1. Clone the backend repo
cd todo-backend
npm install

# 2. Create a PostgreSQL database
CREATE DATABASE todo_app;

# 3. Create tasks table
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  priority TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  list_name TEXT NOT NULL,
  assigned_user TEXT 
);

# 4. Start the backend server
node index.js
