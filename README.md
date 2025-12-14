# 🎓 eUIT - Hệ thống Thông tin Sinh viên Đại học

<p align="center">
  <img src="https://img.shields.io/badge/.NET-9.0-512BD4?style=for-the-badge&logo=dotnet" alt=".NET 9.0"/>
  <img src="https://img.shields.io/badge/Flutter-3.9-02569B?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=for-the-badge&logo=postgresql" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/SignalR-Realtime-512BD4?style=for-the-badge" alt="SignalR"/>
</p>

## 📖 Giới thiệu

**eUIT** là một hệ thống quản lý thông tin sinh viên toàn diện, được thiết kế dành cho các trường đại học. Hệ thống bao gồm ứng dụng di động đa nền tảng (iOS/Android), backend API mạnh mẽ, chatbot AI thông minh và hệ thống thông báo realtime.

## 🏗️ Kiến trúc Hệ thống

```
┌───────────────────────────────────────────────────────────────────────┐
│                            eUIT System                                │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│                        ┌──────────────────┐                           │
│                        │    Mobile App    │                           │
│                        │    (Flutter)     │                           │
│                        └────────┬─────────┘                           │
│                    ┌────────────┼────────────┐                        │
│                    │            │            │                        │
│                    ▼            ▼            ▼                        │
│      ┌──────────────────┐ ┌──────────┐ ┌──────────────────┐           │
│      │     Chatbot      │ │ Backend  │ │      Socket      │           │
│      │ (LangChain + RAG)│ │ (.NET 9) │ │    (SignalR)     │           │
│      └────────┬─────────┘ └────┬─────┘ └────────┬─────────┘           │
│               │                │                │                     │
│               └────────────────┼────────────────┘                     │
│                                │                                      │
│                                ▼                                      │
│                     ┌────────────────────┐                            │
│                     │     PostgreSQL     │                            │
│                     │     + pgvector     │                            │
│                     └────────────────────┘                            │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## 📁 Cấu trúc Dự án

```
eUIT---SE-APP-2025/
├── src/
│   ├── backend/          # .NET 9 Web API
│   ├── mobile/           # Flutter Mobile App
│   ├── chatbot/          # RAG Chatbot với LangChain
│   └── socket/           # SignalR Realtime Server
├── scripts/
│   └── database/         # SQL scripts & data import
├── tests/                # Unit & Integration Tests
└── docs/                 # API Documentation & HTTP tests
```

## ✨ Tính năng Chính

### 👨‍🎓 Dành cho Sinh viên
- **Xem thời khóa biểu** - Lịch học cá nhân theo tuần/tháng
- **Tra cứu điểm số** - Bảng điểm chi tiết theo học kỳ
- **Đăng ký học phần** - Đăng ký môn học online
- **Thanh toán học phí** - Xem và quản lý học phí
- **Xin giấy xác nhận** - Đề xuất các loại giấy tờ
- **Thông báo realtime** - Nhận thông báo từ trường
- **Chatbot AI** - Hỏi đáp thông tin tự động
- **Tin tức & Thông báo** - Cập nhật tin tức từ trường

### 👨‍🏫 Dành cho Giảng viên
- **Quản lý lớp học** - Xem danh sách lớp giảng dạy
- **Nhập điểm** - Nhập và quản lý điểm sinh viên
- **Lịch giảng dạy** - Xem lịch dạy cá nhân

### 🔧 Dành cho Quản trị viên
- **Quản lý người dùng** - Quản lý tài khoản SV/GV
- **Đăng thông báo** - Gửi thông báo đến toàn trường
- **Báo cáo thống kê** - Xem các báo cáo tổng hợp

## 🛠️ Công nghệ Sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| **Mobile App** | Flutter 3.9, Dart |
| **Backend API** | .NET 9, ASP.NET Core |
| **Database** | PostgreSQL 15+ với pgvector |
| **Authentication** | JWT Bearer Token |
| **Realtime** | SignalR |
| **Chatbot** | LangChain, Google Gemini 2.5 Pro |
| **Vector Store** | pgvector extension |
| **Containerization** | Docker |

## Hướng dẫn sử dụng

### Yêu cầu Hệ thống

- **.NET SDK 9.0** hoặc cao hơn
- **Flutter SDK 3.9** hoặc cao hơn
- **PostgreSQL 15+** với extension pgvector
- **Docker** (tùy chọn, để deploy)

### 1️⃣ Cài đặt Database

```bash
# Tạo database PostgreSQL
psql -U postgres -f scripts/database/sql/create_database.sql

# Import dữ liệu mẫu (nếu cần)
# Các file CSV trong scripts/database/main_data/
```

### 2️⃣ Cấu hình Backend

```bash
cd src/backend

# Copy file cấu hình mẫu
cp appsettings.Example.json appsettings.json

# Chỉnh sửa appsettings.json với thông tin database của bạn
# Sau đó chạy backend
dotnet restore
dotnet run
```

API sẽ chạy tại: `http://localhost:5128`\
Swagger UI: `http://localhost:5128/swagger`

### 3️⃣ Cấu hình Socket Server

```bash
cd src/socket

dotnet restore
dotnet run
```

Socket server sẽ chạy tại: `http://localhost:5200`

### 4️⃣ Cấu hình Chatbot

```bash
cd src/chatbot

# Tạo file .env với các biến môi trường
echo "GOOGLE_API_KEY=your_gemini_api_key" > .env
echo "AZURE_POSTGRES_URL=postgres://user:pass@host:port/db" >> .env

dotnet restore
dotnet run
```

### 5️⃣ Chạy Mobile App

```bash
cd src/mobile

# Copy file env mẫu
cp env/.env.example env/.env
# Chỉnh sửa env/.env với URL API của bạn

# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

## 🐳 Docker Deployment

Mỗi thành phần đều có `Dockerfile` riêng:

```bash
# Build Backend
docker build -t euit-backend ./src/backend

# Build Socket Server
docker build -t euit-socket ./src/socket

# Build Chatbot
docker build -t euit-chatbot ./src/chatbot
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/refresh` - Làm mới token

### Student
- `GET /api/student/profile` - Thông tin cá nhân
- `GET /api/student/schedule` - Thời khóa biểu
- `GET /api/student/transcript` - Bảng điểm

### Lecturer
- `GET /api/lecturer/courses` - Danh sách lớp giảng dạy
- `GET /api/lecturer/schedule` - Lịch giảng dạy

### Services
- `POST /api/service/certificate` - Yêu cầu giấy xác nhận
- `GET /api/service/status` - Trạng thái yêu cầu

> Xem thêm chi tiết API tại Swagger UI hoặc trong thư mục `docs/`

## 📂 Tài liệu API

Các file test HTTP có sẵn trong thư mục `docs/`:
- `api-auth-refresh-testing.http` - Test authentication
- `api-personal-schedule-endpoints.http` - Test schedule APIs
- `test-lecturer-endpoints.http` - Test lecturer APIs

## 📄 License

Dự án này được phát triển cho mục đích giáo dục tại UIT (Trường Đại học Công nghệ Thông tin - ĐHQG-HCM).

## 👥 Nhóm Phát triển

Dự án được phát triển bởi các thành viên của UIT Knowledge Team trong khuôn khổ cuộc thi SEAPP năm 2025.

| Thành viên | Vai trò | MSSV |
|------------|---------|-------------|
| **Huỳnh Hoàng Hưng** | Team Leader, Fullstack&DevOps Developer, Database Administrator | 23520560 |
| **Nguyễn Hữu Lam Giang** | AI Engineer, Fullstack&DevOps Developer | 23520408 |
| **Nguyễn Võ Ngọc Bảo** | Fullstack Developer | 23520131 |
| **Nguyễn Xuân Nhật Tân** | Frontend Developer, Tester | 24521582 |
| **Nguyễn Huy Hoàng** | Fullstack Developer | 24520554 |
| **Đặng Duy Bảo** | Frontend Developer | 24520146 |

---
English Section
---

# 🎓 eUIT - University Student Information System

<p align="center">
  <img src="https://img.shields.io/badge/.NET-9.0-512BD4?style=for-the-badge&logo=dotnet" alt=".NET 9.0"/>
  <img src="https://img.shields.io/badge/Flutter-3.9-02569B?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=for-the-badge&logo=postgresql" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/SignalR-Realtime-512BD4?style=for-the-badge" alt="SignalR"/>
</p>

## 📖 Introduction

**eUIT** is a comprehensive student information management system designed for universities. The system includes a cross-platform mobile application (iOS/Android), powerful backend API, intelligent AI chatbot, and real-time notification system.

## 🏗️ System Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                            eUIT System                                │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│                        ┌──────────────────┐                           │
│                        │    Mobile App    │                           │
│                        │    (Flutter)     │                           │
│                        └────────┬─────────┘                           │
│                    ┌────────────┼────────────┐                        │
│                    │            │            │                        │
│                    ▼            ▼            ▼                        │
│      ┌──────────────────┐ ┌──────────┐ ┌──────────────────┐           │
│      │     Chatbot      │ │ Backend  │ │      Socket      │           │
│      │ (LangChain + RAG)│ │ (.NET 9) │ │    (SignalR)     │           │
│      └────────┬─────────┘ └────┬─────┘ └────────┬─────────┘           │
│               │                │                │                     │
│               └────────────────┼────────────────┘                     │
│                                │                                      │
│                                ▼                                      │
│                     ┌────────────────────┐                            │
│                     │     PostgreSQL     │                            │
│                     │     + pgvector     │                            │
│                     └────────────────────┘                            │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
eUIT---SE-APP-2025/
├── src/
│   ├── backend/          # .NET 9 Web API
│   ├── mobile/           # Flutter Mobile App
│   ├── chatbot/          # RAG Chatbot with LangChain
│   └── socket/           # SignalR Realtime Server
├── scripts/
│   └── database/         # SQL scripts & data import
├── tests/                # Unit & Integration Tests
└── docs/                 # API Documentation & HTTP tests
```

## ✨ Key Features

### 👨‍🎓 For Students
- **View Schedule** - Personal class schedule by week/month
- **Check Grades** - Detailed transcript by semester
- **Course Registration** - Online course enrollment
- **Tuition Payment** - View and manage tuition fees
- **Request Certificates** - Apply for various documents
- **Real-time Notifications** - Receive school announcements
- **AI Chatbot** - Automated Q&A system
- **News & Announcements** - Latest updates from school

### 👨‍🏫 For Lecturers
- **Class Management** - View teaching class list
- **Grade Entry** - Enter and manage student grades
- **Teaching Schedule** - Personal teaching calendar

### 🔧 For Administrators
- **User Management** - Manage student/lecturer accounts
- **Post Announcements** - Send notifications to entire school
- **Statistical Reports** - View comprehensive reports

## 🛠️ Technologies Used

| Component | Technology |
|-----------|------------|
| **Mobile App** | Flutter 3.9, Dart |
| **Backend API** | .NET 9, ASP.NET Core |
| **Database** | PostgreSQL 15+ with pgvector |
| **Authentication** | JWT Bearer Token |
| **Realtime** | SignalR |
| **Chatbot** | LangChain, Google Gemini 2.5 Pro |
| **Vector Store** | pgvector extension |
| **Containerization** | Docker |

## Getting Started

### System Requirements

- **.NET SDK 9.0** or higher
- **Flutter SDK 3.9** or higher
- **PostgreSQL 15+** with pgvector extension
- **Docker** (optional, for deployment)

### 1️⃣ Database Setup

```bash
# Create PostgreSQL database
psql -U postgres -f scripts/database/sql/create_database.sql

# Import sample data (if needed)
# CSV files are in scripts/database/main_data/
```

### 2️⃣ Backend Configuration

```bash
cd src/backend

# Copy example configuration file
cp appsettings.Example.json appsettings.json

# Edit appsettings.json with your database information
# Then run the backend
dotnet restore
dotnet run
```

API will run at: `http://localhost:5128`\
Swagger UI: `http://localhost:5128/swagger`

### 3️⃣ Socket Server Configuration

```bash
cd src/socket

dotnet restore
dotnet run
```

Socket server will run at: `http://localhost:5200`

### 4️⃣ Chatbot Configuration

```bash
cd src/chatbot

# Create .env file with environment variables
echo "GOOGLE_API_KEY=your_gemini_api_key" > .env
echo "AZURE_POSTGRES_URL=postgres://user:pass@host:port/db" >> .env

dotnet restore
dotnet run
```

### 5️⃣ Run Mobile App

```bash
cd src/mobile

# Copy example env file
cp env/.env.example env/.env
# Edit env/.env with your API URL

# Install dependencies
flutter pub get

# Run app
flutter run
```

## 🐳 Docker Deployment

Each component has its own `Dockerfile`:

```bash
# Build Backend
docker build -t euit-backend ./src/backend

# Build Socket Server
docker build -t euit-socket ./src/socket

# Build Chatbot
docker build -t euit-chatbot ./src/chatbot
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `POST /api/auth/refresh` - Refresh token

### Student
- `GET /api/student/profile` - Personal information
- `GET /api/student/schedule` - Class schedule
- `GET /api/student/transcript` - Transcript

### Lecturer
- `GET /api/lecturer/courses` - Teaching class list
- `GET /api/lecturer/schedule` - Teaching schedule

### Services
- `POST /api/service/certificate` - Request certificate
- `GET /api/service/status` - Request status

> See more API details at Swagger UI or in the `docs/` folder

## 📂 API Documentation

HTTP test files available in `docs/` folder:
- `api-auth-refresh-testing.http` - Test authentication
- `api-personal-schedule-endpoints.http` - Test schedule APIs
- `test-lecturer-endpoints.http` - Test lecturer APIs

## 📄 License

This project is developed for educational purposes at UIT (University of Information Technology - VNU-HCM).

## 👥 Development Team

This project is developed by members of UIT Knowledge Team as part of the SEAPP 2025 competition.

| Member | Role | Student ID |
|------------|---------|-------------|
| **Huỳnh Hoàng Hưng** | Team Leader, Fullstack&DevOps Developer, Database Administrator | 23520560 |
| **Nguyễn Hữu Lam Giang** | AI Engineer, Fullstack&DevOps Developer | 23520408 |
| **Nguyễn Võ Ngọc Bảo** | Fullstack Developer | 23520131 |
| **Nguyễn Xuân Nhật Tân** | Frontend Developer, Tester | 24521582 |
| **Nguyễn Huy Hoàng** | Fullstack Developer | 24520554 |
| **Đặng Duy Bảo** | Frontend Developer | 24520146 |

---

<p align="center">
  Made with ❤️ by UIT Knowledge Team
</p>
