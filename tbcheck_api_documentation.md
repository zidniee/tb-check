# 📘 TBCheck Backend — Dokumentasi API Lengkap

> **Versi**: 1.0 | **Tanggal**: 24 Juli 2026  
> **Base URL Gateway**: `https://<gateway-host>:8000`  
> **Format**: JSON (kecuali endpoint file upload/download)

---

## Daftar Isi

1. [Arsitektur & Analisis Service](#1-arsitektur--analisis-service)
2. [Analisis API Gateway](#2-analisis-api-gateway)
3. [Validasi Routing](#3-validasi-routing)
4. [Dokumentasi API per Module](#4-dokumentasi-api-per-module)
   - [4.1 Authentication](#41-authentication)
   - [4.2 Identity (Profile)](#42-identity-profile)
   - [4.3 Hospital](#43-hospital)
   - [4.4 Doctor](#44-doctor)
   - [4.5 Education](#45-education)
   - [4.6 Screening](#46-screening)
   - [4.7 Consultation & Telemedicine](#47-consultation--telemedicine)
   - [4.8 Monitoring](#48-monitoring)
   - [4.9 Notification](#49-notification)
   - [4.10 File Storage](#410-file-storage)
   - [4.11 JWT Key Rotation (Internal/Admin)](#411-jwt-key-rotation-internaladmin)
   - [4.12 SVIR Simulator](#412-svir-simulator)
5. [Ringkasan API](#5-ringkasan-api)
6. [Catatan Penting](#6-catatan-penting)

---

## 1. Arsitektur & Analisis Service

### Diagram Arsitektur

```mermaid
graph TB
    subgraph "API Gateway :8000"
        GW["API Gateway (Go/Gin)"]
    end
    
    subgraph "app-tbcheck :8080"
        AUTH["Auth Module"]
        IDENT["Identity Module"]
        HOSP["Hospital Module"]
        DOC["Doctor Module"]
        EDU["Education Module"]
        SCR["Screening Module"]
        CONS["Consultation Module"]
        MON["Monitoring Module"]
        NOTIF["Notification Module"]
        FILE["File Module"]
        JWT["JWT Key Module"]
    end
    
    subgraph "app-ai :8003"
        SVIR["SVIR Simulator (FastAPI)"]
    end
    
    GW --> AUTH
    GW --> IDENT
    GW --> HOSP
    GW --> DOC
    GW --> EDU
    GW --> SCR
    GW --> CONS
    GW --> MON
    GW --> NOTIF
    GW --> FILE
    GW --> JWT
    GW --> SVIR
```

### Daftar Service

| # | Service | Tech | Port | Fungsi |
|---|---------|------|------|--------|
| 1 | **API Gateway** | Go (Gin) | 8000 | Reverse proxy, CORS, rate limiting, request routing |
| 2 | **Auth Module** | Go (Gin) | 8080 | Registrasi, login, OAuth2 Google, OTP email, JWT token management |
| 3 | **Identity Module** | Go (Gin) | 8080 | Manajemen profil pasien & dokter, upload avatar, update lokasi |
| 4 | **Hospital Module** | Go (Gin) | 8080 | CRUD rumah sakit, pencarian publik, upload logo |
| 5 | **Doctor Module** | Go (Gin) | 8080 | Manajemen data operasional dokter, pencarian terdekat (PostGIS) |
| 6 | **Education Module** | Go (Gin) | 8080 | Konten edukasi TB (artikel/video), progress baca, ensiklopedia herbal |
| 7 | **Screening Module** | Go (Gin) | 8080 | Laporan skrining TB berbasis AI (batuk + kuesioner) |
| 8 | **Consultation Module** | Go (Gin) | 8080 | Telemedicine real-time (WebSocket), E2EE chat, manajemen konsultasi |
| 9 | **Monitoring Module** | Go (Gin) | 8080 | Pemantauan klinis pasien oleh dokter, tren data skrining |
| 10 | **Notification Module** | Go (Gin) | 8080 | Push notification (FCM), riwayat notifikasi, mark as read |
| 11 | **File Module** | Go (Gin) | 8080 | Upload/download file terpusat (Local/Cloudflare R2) |
| 12 | **JWT Key Module** | Go (Gin) | 8080 | Rotasi kunci JWT (generate, activate, revoke) — Internal |
| 13 | **SVIR Simulator** | Python (FastAPI) | 8003 | Simulasi epidemiologi SVIR, community risk assessment |

---

## 2. Analisis API Gateway

### Mekanisme Routing

API Gateway menggunakan arsitektur **reverse proxy** dengan dua backend service:

1. **`tbcheck-service`** → `http://localhost:8080` (Go monolith)
2. **`svir-service`** → `http://localhost:8003` (Python FastAPI)

### Routing Rules

| Prioritas | Pattern | Target | Middleware |
|-----------|---------|--------|------------|
| 1 | `GET /healthz` | Gateway internal | — |
| 2 | `GET /readyz` | Gateway internal | — |
| 3 | `/auth/register`, `/resend-verification`, `/forgot-password`, `/reset-password` | tbcheck-service | RateLimiter (3 req/min, IP Ban) |
| 4 | `/auth/login`, `/verify-email`, `/google/mobile-login` | tbcheck-service | RateLimiter (5 req/min, IP Ban) |
| 5 | `/auth/refresh`, `/logout`, `/google/login`, `/google/callback` | tbcheck-service | RateLimiter (10 req/min, IP Ban) |
| 6 | `GET /patient/dashboard`, `/doctor/dashboard`, `/admin/system-settings` | Gateway internal | 308 Permanent Redirect |
| 7 | `ANY /api/v1/internal/*path` | Gateway internal | Block (403 Forbidden) |
| 8 | **NoRoute (catch-all)** | tbcheck-service | — |

### Gateway → Service Endpoint Mapping

| Gateway Endpoint | Method | Service Tujuan | Internal Endpoint | Authentication | Roles |
|---|---|---|---|---|---|
| `/auth/register` | POST | tbcheck-service | `/auth/register` | ❌ | Public |
| `/auth/login` | POST | tbcheck-service | `/auth/login` | ❌ | Public |
| `/auth/verify-email` | POST | tbcheck-service | `/auth/verify-email` | ❌ | Public |
| `/auth/resend-verification` | POST | tbcheck-service | `/auth/resend-verification` | ❌ | Public |
| `/auth/forgot-password` | POST | tbcheck-service | `/auth/forgot-password` | ❌ | Public |
| `/auth/reset-password` | POST | tbcheck-service | `/auth/reset-password` | ❌ | Public |
| `/auth/refresh` | POST | tbcheck-service | `/auth/refresh` | ❌ | Public |
| `/auth/logout` | POST | tbcheck-service | `/auth/logout` | ❌* | Public |
| `/auth/google/login` | GET | tbcheck-service | `/auth/google/login` | ❌ | Public |
| `/auth/google/callback` | GET | tbcheck-service | `/auth/google/callback` | ❌ | Public |
| `/auth/google/mobile-login` | POST | tbcheck-service | `/auth/google/mobile-login` | ❌ | Public |
| `/api/v1/profile` | GET | tbcheck-service | `/api/v1/profile` | ✅ Bearer | ALL |
| `/api/v1/profile/patient` | PUT | tbcheck-service | `/api/v1/profile/patient` | ✅ Bearer | PATIENT* |
| `/api/v1/profile/doctor` | PUT | tbcheck-service | `/api/v1/profile/doctor` | ✅ Bearer | DOCTOR* |
| `/api/v1/profile/location` | PUT | tbcheck-service | `/api/v1/profile/location` | ✅ Bearer | PATIENT* |
| `/api/v1/profile/avatar` | POST | tbcheck-service | `/api/v1/profile/avatar` | ✅ Bearer | ALL |
| `/api/v1/admin/hospitals` | POST | tbcheck-service | `/api/v1/admin/hospitals` | ✅ Bearer | ADMIN |
| `/api/v1/admin/hospitals` | GET | tbcheck-service | `/api/v1/admin/hospitals` | ✅ Bearer | ADMIN |
| `/api/v1/admin/hospitals/:id` | GET | tbcheck-service | `/api/v1/admin/hospitals/:id` | ✅ Bearer | ADMIN |
| `/api/v1/admin/hospitals/:id` | PUT | tbcheck-service | `/api/v1/admin/hospitals/:id` | ✅ Bearer | ADMIN |
| `/api/v1/admin/hospitals/:id` | DELETE | tbcheck-service | `/api/v1/admin/hospitals/:id` | ✅ Bearer | ADMIN |
| `/api/v1/admin/hospitals/:id/logo` | POST | tbcheck-service | `/api/v1/admin/hospitals/:id/logo` | ✅ Bearer | ADMIN |
| `/api/v1/hospitals` | GET | tbcheck-service | `/api/v1/hospitals` | ✅ Bearer | ALL |
| `/api/v1/hospitals/:id` | GET | tbcheck-service | `/api/v1/hospitals/:id` | ✅ Bearer | ALL |
| `/api/v1/doctors/nearest` | GET | tbcheck-service | `/api/v1/doctors/nearest` | ✅ Bearer | ALL |
| `/api/v1/doctors/:id` | GET | tbcheck-service | `/api/v1/doctors/:id` | ✅ Bearer | ALL |
| `/api/v1/doctors/availability` | PUT | tbcheck-service | `/api/v1/doctors/availability` | ✅ Bearer | DOCTOR, ADMIN |
| `/api/v1/doctors` | POST | tbcheck-service | `/api/v1/doctors` | ✅ Bearer | ADMIN |
| `/api/v1/doctors/license-status` | PUT | tbcheck-service | `/api/v1/doctors/license-status` | ✅ Bearer | ADMIN |
| `/api/v1/doctors/employment-status` | PUT | tbcheck-service | `/api/v1/doctors/employment-status` | ✅ Bearer | ADMIN |
| `/api/v1/education` | GET | tbcheck-service | `/api/v1/education` | ✅ Bearer | ALL |
| `/api/v1/education/:id` | GET | tbcheck-service | `/api/v1/education/:id` | ✅ Bearer | ALL |
| `/api/v1/education/search` | GET | tbcheck-service | `/api/v1/education/search` | ✅ Bearer | ALL |
| `/api/v1/education/progress` | GET | tbcheck-service | `/api/v1/education/progress` | ✅ Bearer | ALL |
| `/api/v1/education/:id/progress` | PUT | tbcheck-service | `/api/v1/education/:id/progress` | ✅ Bearer | ALL |
| `/api/v1/education` | POST | tbcheck-service | `/api/v1/education` | ✅ Bearer | ADMIN |
| `/api/v1/education/:id` | PUT | tbcheck-service | `/api/v1/education/:id` | ✅ Bearer | ADMIN |
| `/api/v1/education/:id` | DELETE | tbcheck-service | `/api/v1/education/:id` | ✅ Bearer | ADMIN |
| `/api/v1/education/:id/publish` | PUT | tbcheck-service | `/api/v1/education/:id/publish` | ✅ Bearer | ADMIN |
| `/api/v1/education/herbal` | POST | tbcheck-service | `/api/v1/education/herbal` | ✅ Bearer | ADMIN |
| `/api/v1/education/herbal` | GET | tbcheck-service | `/api/v1/education/herbal` | ✅ Bearer | ALL |
| `/api/v1/education/herbal/:id` | GET | tbcheck-service | `/api/v1/education/herbal/:id` | ✅ Bearer | ALL |
| `/api/v1/education/herbal/:id` | DELETE | tbcheck-service | `/api/v1/education/herbal/:id` | ✅ Bearer | ADMIN |
| `/api/v1/files` | POST | tbcheck-service | `/api/v1/files` | ✅ Bearer | ALL |
| `/api/v1/files/:id` | GET | tbcheck-service | `/api/v1/files/:id` | ✅ Bearer | ALL |
| `/api/v1/files/:id` | DELETE | tbcheck-service | `/api/v1/files/:id` | ✅ Bearer | ALL |
| `/api/v1/screening/reports` | POST | tbcheck-service | `/api/v1/screening/reports` | ✅ Bearer | PATIENT |
| `/api/v1/screening/reports` | GET | tbcheck-service | `/api/v1/screening/reports` | ✅ Bearer | PATIENT |
| `/api/v1/screening/reports/:id` | GET | tbcheck-service | `/api/v1/screening/reports/:id` | ✅ Bearer | ALL* |
| `/api/v1/consultations` | POST | tbcheck-service | `/api/v1/consultations` | ✅ Bearer | PATIENT |
| `/api/v1/consultations` | GET | tbcheck-service | `/api/v1/consultations` | ✅ Bearer | PATIENT, DOCTOR |
| `/api/v1/consultations/:id` | GET | tbcheck-service | `/api/v1/consultations/:id` | ✅ Bearer | PATIENT, DOCTOR, ADMIN |
| `/api/v1/consultations/:id/messages` | GET | tbcheck-service | `/api/v1/consultations/:id/messages` | ✅ Bearer | PATIENT, DOCTOR, ADMIN |
| `/api/v1/consultations/:id/ws` | GET | tbcheck-service | `/api/v1/consultations/:id/ws` | ✅ Bearer | PATIENT, DOCTOR, ADMIN |
| `/api/v1/consultations/keys` | POST | tbcheck-service | `/api/v1/consultations/keys` | ✅ Bearer | PATIENT, DOCTOR, ADMIN |
| `/api/v1/consultations/keys/:user_id` | GET | tbcheck-service | `/api/v1/consultations/keys/:user_id` | ✅ Bearer | PATIENT, DOCTOR, ADMIN |
| `/api/v1/monitoring/patients` | GET | tbcheck-service | `/api/v1/monitoring/patients` | ✅ Bearer | DOCTOR, ADMIN |
| `/api/v1/monitoring/patients/:patient_id` | GET | tbcheck-service | `/api/v1/monitoring/patients/:patient_id` | ✅ Bearer | DOCTOR, PATIENT, ADMIN |
| `/api/v1/monitoring/patients/:patient_id` | PUT | tbcheck-service | `/api/v1/monitoring/patients/:patient_id` | ✅ Bearer | DOCTOR, ADMIN |
| `/api/v1/monitoring/patients/:patient_id/trends` | GET | tbcheck-service | `/api/v1/monitoring/patients/:patient_id/trends` | ✅ Bearer | DOCTOR, PATIENT, ADMIN |
| `/api/v1/notifications` | GET | tbcheck-service | `/api/v1/notifications` | ✅ Bearer | ALL |
| `/api/v1/notifications/:id/read` | PUT | tbcheck-service | `/api/v1/notifications/:id/read` | ✅ Bearer | ALL |
| `/api/v1/notifications/read-all` | PUT | tbcheck-service | `/api/v1/notifications/read-all` | ✅ Bearer | ALL |
| `/api/v1/notifications/device-token` | POST | tbcheck-service | `/api/v1/notifications/device-token` | ✅ Bearer | ALL |
| `/api/v1/internal/jwt-keys` | POST | tbcheck-service | `/api/v1/internal/jwt-keys` | ✅ Bearer | ADMIN |
| `/api/v1/internal/jwt-keys` | GET | tbcheck-service | `/api/v1/internal/jwt-keys` | ✅ Bearer | ADMIN |
| `/api/v1/internal/jwt-keys/active` | GET | tbcheck-service | `/api/v1/internal/jwt-keys/active` | ✅ Bearer | ADMIN |
| `/api/v1/internal/jwt-keys/:id/activate` | PATCH | tbcheck-service | `/api/v1/internal/jwt-keys/:id/activate` | ✅ Bearer | ADMIN |
| `/api/v1/internal/jwt-keys/:id/revoke` | PATCH | tbcheck-service | `/api/v1/internal/jwt-keys/:id/revoke` | ✅ Bearer | ADMIN |
| `/api/v1/svir/simulate` | POST | tbcheck-service | `/api/v1/svir/simulate` | ✅ Bearer | PATIENT |
| `/api/v1/svir/community-risk` | GET | tbcheck-service | `/api/v1/svir/community-risk` | ✅ Bearer | PATIENT |
| `/api/v1/patient/dashboard` | GET | tbcheck-service | `/api/v1/patient/dashboard` | ✅ Bearer | PATIENT, ADMIN |
| `/api/v1/doctor/dashboard` | GET | tbcheck-service | `/api/v1/doctor/dashboard` | ✅ Bearer | DOCTOR, ADMIN |
| `/api/v1/admin/system-settings` | GET | tbcheck-service | `/api/v1/admin/system-settings` | ✅ Bearer | ADMIN |

> **Catatan**: `*` pada Roles menandakan bahwa otorisasi tambahan dilakukan di level controller (misalnya PATIENT hanya bisa mengakses data miliknya sendiri).

---

## 3. Validasi Routing

### ✅ Temuan

#### 3.1 Endpoint yang Tidak Terdaftar Eksplisit di Gateway

Semua endpoint di `app-tbcheck` tercover oleh **catch-all route** (`NoRoute → tbcheckProxy`). Gateway mem-forward semua request yang tidak match route eksplisit ke `tbcheck-service`. Oleh karena itu, seluruh endpoint di app-tbcheck secara implisit terpublikasi melalui gateway.

Endpoint SVIR service juga terdaftar via pattern `ANY /api/v1/svir/*path`.

> [!IMPORTANT]
> Tidak ditemukan endpoint internal service yang gagal dipublikasikan. Catch-all route memastikan seluruh path diteruskan.

#### 3.2 Inkonsistensi yang Ditemukan

| # | Temuan | Severity | Detail |
|---|--------|----------|--------|
| 1 | **Rate limit hanya 5 endpoint auth di gateway** | ⚠️ Medium | `POST /auth/reset-password`, `POST /auth/refresh`, `POST /auth/logout`, `GET /auth/google/login`, `GET /auth/google/callback`, `POST /auth/google/mobile-login` tidak memiliki rate limit di gateway. Mereka tetap berfungsi via catch-all, namun tanpa rate limiting. |
| 2 | **Dashboard endpoints menggunakan path tanpa prefix `/api/v1/`** | ⚠️ Low | `/patient/dashboard`, `/doctor/dashboard`, `/admin/system-settings` berbeda konvensi penamaan dibanding endpoint lain (`/api/v1/...`). |
| 3 | **SVIR endpoints tidak memerlukan autentikasi** | ⚠️ Medium | `POST /api/v1/svir/simulate` dan `GET /api/v1/svir/community-risk` terbuka tanpa token JWT. Pertimbangkan apakah ini disengaja. |
| 4 | **Internal JWT Key endpoint diakses via catch-all** | ℹ️ Info | Meskipun path `/internal/jwt-keys` dimaksudkan internal, endpoint ini masih bisa diakses melalui gateway (dilindungi oleh AuthMiddleware + ADMIN role). |

#### 3.3 Rekomendasi

1. **Tambahkan rate limiting** untuk endpoint auth yang belum dilindungi (`/auth/reset-password`, `/auth/google/mobile-login`)
2. **Standardisasi path prefix** — pertimbangkan migrasi dashboard endpoints ke `/api/v1/patient/dashboard`
3. **Pertimbangkan proteksi SVIR** — tambahkan API key atau auth jika data bersifat sensitif
4. **Blokir path `/internal/*`** di gateway — atau pindahkan ke mekanisme internal-only networking

---

## 4. Dokumentasi API per Module

### Header Umum

Semua endpoint yang memerlukan autentikasi menggunakan header berikut:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Response Error Umum

Semua endpoint menghasilkan response error dalam format berikut:

```json
{
  "error": "Pesan error yang menjelaskan masalah"
}
```

| HTTP Status | Deskripsi |
|---|---|
| `400` | Bad Request — validasi input gagal |
| `401` | Unauthorized — token tidak valid/expired |
| `403` | Forbidden — role tidak memiliki akses |
| `404` | Not Found — resource tidak ditemukan |
| `409` | Conflict — terjadi konflik data |
| `422` | Unprocessable Entity — bisnis logic gagal |
| `429` | Too Many Requests — rate limit terlampaui |
| `500` | Internal Server Error |
| `502` | Bad Gateway — upstream service gagal |
| `503` | Service Unavailable — circuit breaker open |

---

### 4.1 Authentication

#### 4.1.1 Register

| Field | Detail |
|---|---|
| **Nama** | Register User |
| **Deskripsi** | Membuat akun pengguna baru. OTP verifikasi email dikirim otomatis. |
| **URL** | `/auth/register` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |
| **Rate Limit** | 3 request/menit |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `name` | string | ✅ | — | Nama lengkap pengguna |
| `email` | string | ✅ | format email | Alamat email |
| `password` | string | ✅ | min 6 karakter | Password |
| `role` | string | ✅ | `PATIENT` \| `DOCTOR` \| `ADMIN` | Peran pengguna |

**Contoh Request**

```json
POST /auth/register
Content-Type: application/json

{
  "name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "rahasia123",
  "role": "PATIENT"
}
```

**Response Success** — `201 Created`

```json
{
  "message": "Registrasi berhasil. Silakan cek email untuk verifikasi.",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "budi@example.com",
  "role": "PATIENT",
  "status": "PENDING_VERIFICATION",
  "verification_required": true
}
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `message` | string | Pesan informasi registrasi |
| `user_id` | string (UUID) | ID unik pengguna yang baru dibuat |
| `email` | string | Email yang terdaftar |
| `role` | string | Role yang dipilih |
| `status` | string | Status akun (PENDING_VERIFICATION) |
| `verification_required` | boolean | Apakah verifikasi email diperlukan |

**Status Code**

| Code | Deskripsi |
|---|---|
| `201` | Registrasi berhasil |
| `400` | Validasi gagal (email invalid, password terlalu pendek, dll.) |
| `429` | Rate limit exceeded |
| `500` | Gagal membuat akun |

---

#### 4.1.2 Login

| Field | Detail |
|---|---|
| **Nama** | Login |
| **Deskripsi** | Autentikasi pengguna dan mendapatkan access + refresh token |
| **URL** | `/auth/login` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |
| **Rate Limit** | 5 request/menit |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `email` | string | ✅ | Email terdaftar |
| `password` | string | ✅ | Password |
| `device_id` | string \| null | ❌ | ID perangkat (untuk multi-device tracking) |
| `device_name` | string \| null | ❌ | Nama perangkat |

**Contoh Request**

```json
POST /auth/login
Content-Type: application/json

{
  "email": "budi@example.com",
  "password": "rahasia123",
  "device_id": "android-abc123",
  "device_name": "Samsung Galaxy S24"
}
```

**Response Success** — `200 OK`

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "expires_in": 900,
  "refresh_expires_in": 604800,
  "user": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "role": "PATIENT"
  }
}
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `access_token` | string | JWT access token (valid 15 menit) |
| `refresh_token` | string | Refresh token (valid 7 hari) |
| `expires_in` | integer | Masa berlaku access token (detik) |
| `refresh_expires_in` | integer | Masa berlaku refresh token (detik) |
| `user` | object | Informasi pengguna |
| `user.user_id` | string (UUID) | ID pengguna |
| `user.name` | string | Nama pengguna |
| `user.email` | string | Email pengguna |
| `user.role` | string | Role pengguna |

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Login berhasil |
| `400` | Validasi gagal |
| `401` | Email/password salah |
| `403` | Email belum diverifikasi |
| `429` | Rate limit exceeded |

---

#### 4.1.3 Refresh Token

| Field | Detail |
|---|---|
| **Nama** | Refresh Token |
| **Deskripsi** | Mendapatkan access token baru menggunakan refresh token |
| **URL** | `/auth/refresh` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `refresh_token` | string | ✅ | Refresh token yang valid |
| `device_id` | string \| null | ❌ | ID perangkat |
| `device_name` | string \| null | ❌ | Nama perangkat |

**Contoh Request**

```json
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g..."
}
```

**Response Success** — `200 OK`

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
  "expires_in": 900,
  "refresh_expires_in": 604800,
  "user": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "role": "PATIENT"
  }
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Refresh berhasil |
| `400` | Validasi gagal |
| `401` | Refresh token invalid/expired |

---

#### 4.1.4 Verify Email

| Field | Detail |
|---|---|
| **Nama** | Verify Email OTP |
| **Deskripsi** | Verifikasi email menggunakan kode OTP 6 digit |
| **URL** | `/auth/verify-email` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |
| **Rate Limit** | 5 request/menit |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `email` | string | ✅ | format email | Email yang didaftarkan |
| `otp` | string | ✅ | panjang 6 | Kode OTP dari email |

**Contoh Request**

```json
POST /auth/verify-email
Content-Type: application/json

{
  "email": "budi@example.com",
  "otp": "123456"
}
```

**Response Success** — `200 OK`

```json
{
  "message": "Email berhasil diverifikasi."
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Verifikasi berhasil |
| `400` | OTP invalid/expired atau email tidak ditemukan |
| `429` | Rate limit exceeded |

---

#### 4.1.5 Resend Verification OTP

| Field | Detail |
|---|---|
| **Nama** | Resend Verification OTP |
| **Deskripsi** | Mengirim ulang kode OTP verifikasi email |
| **URL** | `/auth/resend-verification` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |
| **Rate Limit** | 3 request/menit |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `email` | string | ✅ | Email yang terdaftar |

**Contoh Request**

```json
POST /auth/resend-verification
Content-Type: application/json

{
  "email": "budi@example.com"
}
```

**Response Success** — `200 OK`

```json
{
  "message": "OTP baru berhasil dikirim ke email."
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | OTP berhasil dikirim ulang |
| `400` | Email tidak ditemukan atau sudah terverifikasi |
| `429` | Rate limit exceeded |

---

#### 4.1.6 Forgot Password

| Field | Detail |
|---|---|
| **Nama** | Forgot Password |
| **Deskripsi** | Memulai alur reset password, mengirim OTP ke email |
| **URL** | `/auth/forgot-password` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |
| **Rate Limit** | 3 request/menit |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `email` | string | ✅ | Email terdaftar |

**Contoh Request**

```json
POST /auth/forgot-password
Content-Type: application/json

{
  "email": "budi@example.com"
}
```

**Response Success** — `200 OK`

```json
{
  "message": "Jika email terdaftar, kode OTP untuk reset password telah dikirim."
}
```

> [!NOTE]
> Response selalu sukses untuk menghindari email enumeration attack.

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Selalu dikembalikan (anti enumeration) |
| `429` | Rate limit exceeded |
| `500` | Internal error |

---

#### 4.1.7 Reset Password

| Field | Detail |
|---|---|
| **Nama** | Reset Password |
| **Deskripsi** | Mereset password menggunakan OTP. Semua sesi akan di-logout. |
| **URL** | `/auth/reset-password` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `email` | string | ✅ | format email | Email terdaftar |
| `otp` | string | ✅ | panjang 6 | Kode OTP dari email |
| `new_password` | string | ✅ | min 6 karakter | Password baru |
| `confirm_password` | string | ✅ | harus sama dengan `new_password` | Konfirmasi password baru |

**Contoh Request**

```json
POST /auth/reset-password
Content-Type: application/json

{
  "email": "budi@example.com",
  "otp": "654321",
  "new_password": "passwordBaru123",
  "confirm_password": "passwordBaru123"
}
```

**Response Success** — `200 OK`

```json
{
  "message": "Password berhasil diubah. Semua sesi telah logout."
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Password berhasil diubah |
| `400` | OTP invalid, password tidak cocok |

---

#### 4.1.8 Logout

| Field | Detail |
|---|---|
| **Nama** | Logout |
| **Deskripsi** | Logout dari sesi saat ini atau semua perangkat |
| **URL** | `/auth/logout` |
| **Method** | `POST` |
| **Auth** | ❌ Opsional (token diekstrak jika ada) |
| **Roles** | Public |

**Request Headers (Opsional)**

| Header | Deskripsi |
|---|---|
| `Authorization` | `Bearer <access_token>` |
| `X-Refresh-Token` | Refresh token yang ingin di-revoke |

**Request Body (Opsional)**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `all_devices` | boolean | ❌ | `true` untuk logout dari semua perangkat |

**Contoh Request**

```json
POST /auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
X-Refresh-Token: dGhpcyBpcyBhIHJlZnJlc2g...
Content-Type: application/json

{
  "all_devices": false
}
```

**Response Success** — `200 OK`

```json
{
  "message": "Logout berhasil."
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Logout berhasil |
| `400` | Token tidak valid |

---

#### 4.1.9 Google OAuth2 Login (Web)

| Field | Detail |
|---|---|
| **Nama** | Google OAuth2 Login URL |
| **Deskripsi** | Mendapatkan URL redirect untuk login via Google (web flow) |
| **URL** | `/auth/google/login` |
| **Method** | `GET` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |

**Response Success** — `200 OK`

```json
{
  "login_url": "https://accounts.google.com/o/oauth2/v2/auth?..."
}
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `login_url` | string | URL untuk redirect ke halaman consent Google |

---

#### 4.1.10 Google OAuth2 Callback (Web)

| Field | Detail |
|---|---|
| **Nama** | Google OAuth2 Callback |
| **Deskripsi** | Menangani callback redirect dari Google setelah consent |
| **URL** | `/auth/google/callback` |
| **Method** | `GET` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |

**Query Parameters**

| Param | Tipe | Required | Deskripsi |
|---|---|---|---|
| `code` | string | ✅ | Authorization code dari Google |
| `state` | string | ✅ | State parameter untuk CSRF protection |

**Response Success** — `200 OK`

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "expires_in": 900,
  "refresh_expires_in": 604800,
  "user": {
    "user_id": "...",
    "name": "...",
    "email": "...",
    "role": "PATIENT"
  }
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Login berhasil |
| `400` | Missing code/state |
| `401` | State invalid/CSRF, email belum verified di Google |
| `500` | Internal error |

---

#### 4.1.11 Google OAuth2 Mobile Login

| Field | Detail |
|---|---|
| **Nama** | Google Mobile Login |
| **Deskripsi** | Login via Google menggunakan ID token dari Flutter/Android/iOS SDK |
| **URL** | `/auth/google/mobile-login` |
| **Method** | `POST` |
| **Auth** | ❌ Tidak diperlukan |
| **Roles** | Public |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `id_token` | string | ✅ | Google ID token dari native SDK |
| `device_id` | string \| null | ❌ | ID perangkat |
| `device_name` | string \| null | ❌ | Nama perangkat |

**Contoh Request**

```json
POST /auth/google/mobile-login
Content-Type: application/json

{
  "id_token": "eyJhbGciOiJSUzI1NiIs...",
  "device_id": "android-xyz789",
  "device_name": "Pixel 8"
}
```

**Response Success** — `200 OK` — Sama seperti format login biasa (AuthResponse).

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Login berhasil |
| `400` | Validasi gagal |
| `401` | ID token invalid, audience mismatch, email unverified |
| `500` | Internal error |

---

### 4.2 Identity (Profile)

#### 4.2.1 Get My Profile

| Field | Detail |
|---|---|
| **Nama** | Get My Profile |
| **Deskripsi** | Mengambil profil pengguna yang sedang login (pasien atau dokter) |
| **URL** | `/api/v1/profile` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL (PATIENT, DOCTOR, ADMIN) |

**Request Headers**

| Header | Required | Deskripsi |
|---|---|---|
| `Authorization` | ✅ | `Bearer <access_token>` |

**Response Success (PATIENT)** — `200 OK`

```json
{
  "patient_id": "uuid",
  "user_id": "uuid",
  "full_name": "Budi Santoso",
  "phone": "08123456789",
  "gender": "M",
  "birth_date": "1990-01-15",
  "address": "Jl. Merdeka No. 1, Jakarta",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "bcg_vaccinated": true,
  "profile_picture_url": "https://storage.example.com/avatars/budi.jpg",
  "nik": "3171XXXXXX",
  "kk_number": "3171XXXXXX",
  "location_updated_at": "2026-07-24T10:00:00Z",
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-07-24T10:00:00Z"
}
```

**Response Success (DOCTOR)** — `200 OK`

```json
{
  "doctor_id": "uuid",
  "user_id": "uuid",
  "full_name": "Dr. Siti Aminah",
  "phone": "08198765432",
  "specialization": "Pulmonologi",
  "str_number": "STR-123456789",
  "profile_picture_url": "https://storage.example.com/avatars/siti.jpg",
  "is_active": true,
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-07-24T10:00:00Z"
}
```

| Field (Patient) | Tipe | Deskripsi |
|---|---|---|
| `patient_id` | string (UUID) | ID pasien |
| `user_id` | string (UUID) | ID user akun |
| `full_name` | string | Nama lengkap |
| `phone` | string | Nomor telepon |
| `gender` | string | Jenis kelamin |
| `birth_date` | string | Tanggal lahir (YYYY-MM-DD) |
| `address` | string | Alamat |
| `latitude` | float \| null | Latitude lokasi |
| `longitude` | float \| null | Longitude lokasi |
| `bcg_vaccinated` | boolean | Status vaksinasi BCG |
| `profile_picture_url` | string | URL foto profil |
| `nik` | string | Nomor Induk Kependudukan |
| `kk_number` | string | Nomor Kartu Keluarga |
| `location_updated_at` | string \| null | Timestamp update lokasi terakhir |
| `created_at` | string | Timestamp pembuatan profil |
| `updated_at` | string | Timestamp update terakhir |

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Profil ditemukan |
| `401` | Token invalid |
| `404` | Profil belum dibuat |
| `500` | Internal error |

---

#### 4.2.2 Update Patient Profile

| Field | Detail |
|---|---|
| **Nama** | Update Patient Profile |
| **Deskripsi** | Memperbarui data profil pasien. Mendukung upload file avatar secara bersamaan via multipart. |
| **URL** | `/api/v1/profile/patient` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT (enforced di controller) |
| **Content-Type** | `multipart/form-data` atau `application/json` |

**Request Body (form-data)**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `full_name` | string | ✅ | Nama lengkap |
| `phone` | string | ✅ | Nomor telepon |
| `gender` | string | ✅ | Jenis kelamin |
| `birth_date` | string | ✅ | Tanggal lahir (YYYY-MM-DD) |
| `address` | string | ✅ | Alamat |
| `nik` | string | ✅ | NIK |
| `kk_number` | string | ✅ | Nomor KK |
| `bcg_vaccinated` | boolean | ❌ | Status vaksinasi BCG |
| `file` | File | ❌ | Foto profil (opsional) |

**Response Success** — `200 OK`

```json
{
  "message": "profile updated successfully"
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Profil berhasil diperbarui |
| `400` | Validasi gagal |
| `401` | Tidak terautentikasi |
| `403` | Bukan role PATIENT |

---

#### 4.2.3 Update Doctor Profile

| Field | Detail |
|---|---|
| **Nama** | Update Doctor Profile |
| **Deskripsi** | Memperbarui data profil dokter |
| **URL** | `/api/v1/profile/doctor` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR (enforced di controller) |
| **Content-Type** | `multipart/form-data` atau `application/json` |

**Request Body (form-data)**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `full_name` | string | ✅ | Nama lengkap |
| `phone` | string | ✅ | Nomor telepon |
| `specialization` | string | ✅ | Spesialisasi |
| `str_number` | string | ✅ | Nomor STR |
| `file` | File | ❌ | Foto profil (opsional) |

**Response Success** — `200 OK`

```json
{
  "message": "profile updated successfully"
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Profil berhasil diperbarui |
| `400` | Validasi gagal |
| `401` | Tidak terautentikasi |
| `403` | Bukan role DOCTOR |

---

#### 4.2.4 Update Location

| Field | Detail |
|---|---|
| **Nama** | Update Patient Location |
| **Deskripsi** | Memperbarui koordinat lokasi pasien |
| **URL** | `/api/v1/profile/location` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT (enforced di controller) |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `latitude` | float | ✅ | Latitude |
| `longitude` | float | ✅ | Longitude |

**Contoh Request**

```json
PUT /api/v1/profile/location
Authorization: Bearer eyJ...
Content-Type: application/json

{
  "latitude": -6.2088,
  "longitude": 106.8456
}
```

**Response Success** — `200 OK`

```json
{
  "success": true
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Lokasi berhasil diperbarui |
| `400` | Validasi gagal |
| `403` | Bukan role PATIENT |

---

#### 4.2.5 Upload Avatar

| Field | Detail |
|---|---|
| **Nama** | Upload Avatar |
| **Deskripsi** | Upload atau update foto profil pengguna |
| **URL** | `/api/v1/profile/avatar` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |
| **Content-Type** | `multipart/form-data` |

**Request Body (form-data)**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `file` | File | ✅ | File gambar (jpg, png, dll.) |

**Response Success** — `200 OK`

```json
{
  "message": "profile picture updated successfully",
  "profile_picture_url": "https://storage.example.com/avatars/550e8400.jpg"
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `200` | Avatar berhasil diupload |
| `400` | File tidak ditemukan atau format invalid |
| `401` | Tidak terautentikasi |

---

### 4.3 Hospital

#### 4.3.1 Get All Public Hospitals

| Field | Detail |
|---|---|
| **Nama** | Get All Public Hospitals |
| **Deskripsi** | Mengambil daftar semua rumah sakit aktif |
| **URL** | `/api/v1/hospitals` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response Success** — `200 OK`

```json
[
  {
    "hospital_id": "uuid",
    "hospital_name": "RS Paru Dr. Ario",
    "address": "Jl. Kesehatan No. 10",
    "latitude": -6.2088,
    "longitude": 106.8456,
    "phone": "021-12345678",
    "email": "info@rsparu.com",
    "website": "https://rsparu.com",
    "logo_url": "https://storage.example.com/logos/rsparu.png",
    "is_active": true,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-07-24T10:00:00Z"
  }
]
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `hospital_id` | string (UUID) | ID rumah sakit |
| `hospital_name` | string | Nama rumah sakit |
| `address` | string | Alamat |
| `latitude` | float | Latitude |
| `longitude` | float | Longitude |
| `phone` | string | Nomor telepon |
| `email` | string | Email |
| `website` | string \| null | Website |
| `logo_url` | string \| null | URL logo |
| `is_active` | boolean | Status aktif |
| `created_at` | string | Timestamp dibuat |
| `updated_at` | string | Timestamp diperbarui |

---

#### 4.3.2 Get Hospital By ID

| Field | Detail |
|---|---|
| **Nama** | Get Hospital By ID |
| **Deskripsi** | Mengambil detail satu rumah sakit |
| **URL** | `/api/v1/hospitals/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Path Parameters**

| Param | Tipe | Deskripsi |
|---|---|---|
| `id` | string (UUID) | ID rumah sakit |

**Response Success** — `200 OK` — Sama format HospitalResponse di atas.

**Status Code**: `200`, `401`, `404`

---

#### 4.3.3 Create Hospital (Admin)

| Field | Detail |
|---|---|
| **Nama** | Create Hospital |
| **Deskripsi** | Membuat data rumah sakit baru |
| **URL** | `/api/v1/admin/hospitals` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `hospital_name` | string | ✅ | — | Nama rumah sakit |
| `address` | string | ✅ | — | Alamat |
| `latitude` | float | ✅ | -90 s/d 90 | Latitude |
| `longitude` | float | ✅ | -180 s/d 180 | Longitude |
| `phone` | string | ✅ | — | Telepon |
| `email` | string | ✅ | format email | Email |
| `website` | string \| null | ❌ | format URL | Website |
| `logo_url` | string \| null | ❌ | — | URL logo |
| `is_active` | boolean | ✅ | — | Status aktif |

**Response Success** — `201 Created` — HospitalResponse

**Status Code**: `201`, `400`, `401`, `403`

---

#### 4.3.4 Update Hospital (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/admin/hospitals/:id` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Path Parameters**: `id` (UUID)

**Request Body** — Sama seperti CreateHospitalRequest

**Response** — `200 OK` — HospitalResponse

---

#### 4.3.5 Delete Hospital (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/admin/hospitals/:id` |
| **Method** | `DELETE` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Response Success** — `200 OK`

```json
{ "message": "hospital deleted successfully" }
```

---

#### 4.3.6 Get All Admin Hospitals (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/admin/hospitals` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Response** — `200 OK` — Array HospitalResponse (termasuk inactive)

---

#### 4.3.7 Upload Hospital Logo (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/admin/hospitals/:id/logo` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |
| **Content-Type** | `multipart/form-data` |

**Request Body (form-data)**

| Field | Tipe | Required |
|---|---|---|
| `file` | File | ✅ |

**Response Success** — `200 OK`

```json
{
  "message": "hospital logo updated successfully",
  "logo_url": "https://storage.example.com/logos/hospital-abc.png"
}
```

---

### 4.4 Doctor

#### 4.4.1 Get Nearest Doctors

| Field | Detail |
|---|---|
| **Nama** | Get Nearest Doctors |
| **Deskripsi** | Mencari dokter terdekat berdasarkan lokasi (PostGIS spatial query) |
| **URL** | `/api/v1/doctors/nearest` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Query Parameters**

| Param | Tipe | Required | Default | Deskripsi |
|---|---|---|---|---|
| `latitude` atau `lat` | float | ✅ | — | Latitude lokasi |
| `longitude` atau `lon` | float | ✅ | — | Longitude lokasi |
| `radius` atau `radius_km` | float | ❌ | 50.0 | Radius pencarian (km) |

**Contoh Request**

```
GET /api/v1/doctors/nearest?lat=-6.2088&lon=106.8456&radius_km=25
Authorization: Bearer eyJ...
```

**Response Success** — `200 OK`

```json
[
  {
    "doctor_id": "uuid",
    "doctor_name": "Dr. Siti Aminah",
    "specialization": "Pulmonologi",
    "hospital_name": "RS Paru Dr. Ario",
    "hospital_address": "Jl. Kesehatan No. 10",
    "distance_meter": 3250.5,
    "accepting_patient": true,
    "online_status": "ONLINE"
  }
]
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `doctor_id` | string (UUID) | ID dokter |
| `doctor_name` | string | Nama dokter |
| `specialization` | string | Spesialisasi |
| `hospital_name` | string | Nama rumah sakit |
| `hospital_address` | string | Alamat rumah sakit |
| `distance_meter` | float | Jarak dari lokasi (meter) |
| `accepting_patient` | boolean | Apakah menerima pasien |
| `online_status` | string | `ONLINE` atau `OFFLINE` |

---

#### 4.4.2 Get Doctor By ID

| Field | Detail |
|---|---|
| **URL** | `/api/v1/doctors/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response Success** — `200 OK`

```json
{
  "doctor_id": "uuid",
  "user_id": "uuid",
  "hospital_id": "uuid",
  "specialization": "Pulmonologi",
  "employment_status": "ACTIVE",
  "license_status": "VERIFIED",
  "accepting_patient": true,
  "online_status": "ONLINE",
  "max_daily_patient": 20,
  "current_patient": 5,
  "remaining_quota": 15,
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-07-24T10:00:00Z"
}
```

---

#### 4.4.3 Create Doctor (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/doctors` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `user_id` | string | ✅ | UUID | ID user yang akan dijadikan dokter |
| `hospital_id` | string | ✅ | UUID | ID rumah sakit afiliasi |
| `specialization` | string | ✅ | — | Spesialisasi |
| `max_daily_patient` | integer | ✅ | min 1 | Kuota pasien harian |

**Response** — `201 Created` — DoctorDTO

---

#### 4.4.4 Update Availability (Doctor)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/doctors/availability` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR, ADMIN |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `online_status` | string | ✅ | `ONLINE` \| `OFFLINE` | Status online |
| `accepting_patient` | boolean | ✅ | — | Apakah menerima pasien baru |

**Response** — `200 OK` — DoctorDTO

---

#### 4.4.5 Update License Status (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/doctors/license-status` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Query Parameters**

| Param | Tipe | Required |
|---|---|---|
| `id` atau `doctor_id` | string (UUID) | ✅ |

**Request Body**

| Field | Tipe | Required | Validasi |
|---|---|---|---|
| `license_status` | string | ✅ | `VERIFIED` \| `EXPIRED` \| `REJECTED` |

**Response** — `200 OK` — DoctorDTO

---

#### 4.4.6 Update Employment Status (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/doctors/employment-status` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Query Parameters**

| Param | Tipe | Required |
|---|---|---|
| `id` atau `doctor_id` | string (UUID) | ✅ |

**Request Body**

| Field | Tipe | Required | Validasi |
|---|---|---|---|
| `employment_status` | string | ✅ | `ACTIVE` \| `INACTIVE` \| `SUSPENDED` |

**Response** — `200 OK` — DoctorDTO

---

### 4.5 Education

#### 4.5.1 Get Published Contents

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Query Parameters**

| Param | Tipe | Default | Deskripsi |
|---|---|---|---|
| `limit` | integer | 10 | Jumlah konten per halaman |
| `offset` | integer | 0 | Offset pagination |

**Response Success** — `200 OK`

```json
{
  "contents": [
    {
      "content_id": "uuid",
      "title": "Mengenal TBC: Gejala dan Pencegahan",
      "summary": "Artikel tentang...",
      "body": "...",
      "content_type": "article",
      "image_url": "https://...",
      "video_url": "",
      "youtube_video_id": "",
      "thumbnail_url": "",
      "duration_seconds": 0,
      "tags": ["tbc", "pencegahan"],
      "source_url": "https://...",
      "author_name": "Tim TBCheck",
      "is_published": true,
      "requires_disclaimer": false,
      "user_progress": {
        "progress_id": "uuid",
        "user_id": "uuid",
        "content_id": "uuid",
        "is_completed": false,
        "progress_percent": 50,
        "last_position": 250,
        "started_at": "2026-07-20T10:00:00Z",
        "completed_at": null,
        "updated_at": "2026-07-24T10:00:00Z"
      },
      "references": [],
      "published_at": "2026-07-01T00:00:00Z",
      "created_at": "2026-06-28T00:00:00Z",
      "updated_at": "2026-07-01T00:00:00Z"
    }
  ],
  "page": 1,
  "page_size": 10,
  "total": 25
}
```

---

#### 4.5.2 Get Content By ID

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Path Parameters**: `id` (UUID)

**Response** — `200 OK` — EducationContentDTO

---

#### 4.5.3 Search or Filter Contents

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education/search` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Query Parameters**

| Param | Tipe | Required | Deskripsi |
|---|---|---|---|
| `q` | string | ❌ | Kata kunci pencarian teks |
| `tags` | string | ❌ | Tag (comma-separated, misal `tbc,pencegahan`) |
| `limit` | integer | ❌ | Default: 10 |
| `offset` | integer | ❌ | Default: 0 |

> [!NOTE]
> Jika `tags` diberikan, akan melakukan filter berdasarkan tag. Jika hanya `q`, akan melakukan pencarian teks.

**Response** — `200 OK` — EducationListResponse

---

#### 4.5.4 Get User Progress

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education/progress` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response Success** — `200 OK`

```json
[
  {
    "progress_id": "uuid",
    "user_id": "uuid",
    "content_id": "uuid",
    "is_completed": false,
    "progress_percent": 50,
    "last_position": 250,
    "started_at": "2026-07-20T10:00:00Z",
    "completed_at": null,
    "updated_at": "2026-07-24T10:00:00Z"
  }
]
```

---

#### 4.5.5 Update Progress

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education/:id/progress` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Path Parameters**: `id` — Content ID

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `progress_percent` | integer | ✅ | 0-100 | Persentase progress baca |
| `last_position` | integer | ❌ | — | Posisi scroll/waktu video terakhir |

**Response** — `200 OK` — ProgressDTO

---

#### 4.5.6 Create Content (Admin)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/education` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ADMIN |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `title` | string | ✅ | — | Judul konten |
| `summary` | string | ✅ | — | Ringkasan |
| `body` | string | ❌ | — | Isi artikel (HTML/Markdown) |
| `content_type` | string | ✅ | `article` \| `video` | Tipe konten |
| `image_url` | string | ❌ | — | URL gambar header |
| `video_url` | string | ❌ | — | URL video |
| `thumbnail_url` | string | ❌ | — | URL thumbnail |
| `duration_seconds` | integer | ❌ | — | Durasi video (detik) |
| `tags` | string[] | ❌ | — | Tag kategori |
| `source_url` | string | ❌ | — | URL sumber referensi |
| `author_name` | string | ❌ | — | Nama penulis |
| `is_published` | boolean | ❌ | — | Publish langsung? |
| `references` | object[] | ❌ | — | Referensi ilmiah |

**Response** — `201 Created` — EducationContentDTO

---

#### 4.5.7 Update Content (Admin)

| **URL** | `/api/v1/education/:id` |
|---|---|
| **Method** | `PUT` |
| **Roles** | ADMIN |

**Request Body** — Semua field bersifat opsional (UpdateContentRequest)

**Response** — `200 OK` — EducationContentDTO

---

#### 4.5.8 Delete Content (Admin)

| **URL** | `/api/v1/education/:id` |
|---|---|
| **Method** | `DELETE` |
| **Roles** | ADMIN |

**Response** — `200 OK` — `{"message": "content deleted successfully"}`

---

#### 4.5.9 Publish Content (Admin)

| **URL** | `/api/v1/education/:id/publish` |
|---|---|
| **Method** | `PUT` |
| **Roles** | ADMIN |

**Request Body**

| Field | Tipe | Required |
|---|---|---|
| `is_published` | boolean | ✅ |

**Response** — `200 OK` — EducationContentDTO

---

#### 4.5.10 Create Herbal Plant (Admin)

| **URL** | `/api/v1/education/herbal` |
|---|---|
| **Method** | `POST` |
| **Roles** | ADMIN |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `name` | string | ✅ | Nama tanaman lokal |
| `scientific_name` | string | ✅ | Nama ilmiah |
| `description` | string | ✅ | Deskripsi tanaman |
| `compounds` | object[] | ❌ | Senyawa fitokimia |
| `compounds[].name` | string | ✅ | Nama senyawa |
| `compounds[].chemical_group` | string | ✅ | Kelompok kimia |
| `compounds[].mechanism_of_action` | string | ✅ | Mekanisme aksi |
| `compounds[].references` | object[] | ❌ | Referensi ilmiah |

**Response** — `201 Created` — HerbalPlantDTO

---

#### 4.5.11 Get All Herbal Plants

| **URL** | `/api/v1/education/herbal` |
|---|---|
| **Method** | `GET` |
| **Roles** | ALL |

**Query Parameters**

| Param | Tipe | Deskripsi |
|---|---|---|
| `q` | string | Pencarian berdasarkan nama |
| `group` | string | Filter kelompok kimia |

**Response** — `200 OK` — Array HerbalPlantDTO

---

#### 4.5.12 Get Herbal Plant By ID

| **URL** | `/api/v1/education/herbal/:id` |
|---|---|
| **Method** | `GET` |
| **Roles** | ALL |

**Response** — `200 OK` — HerbalPlantDTO

---

#### 4.5.13 Delete Herbal Plant (Admin)

| **URL** | `/api/v1/education/herbal/:id` |
|---|---|
| **Method** | `DELETE` |
| **Roles** | ADMIN |

**Response** — `200 OK` — `{"message": "herbal plant deleted successfully"}`

---

### 4.6 Screening

#### 4.6.1 Create Screening Report

| Field | Detail |
|---|---|
| **Nama** | Create Screening Report |
| **Deskripsi** | Membuat laporan skrining TB baru berdasarkan hasil AI (MFCC + kuesioner klinis) |
| **URL** | `/api/v1/screening/reports` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `probability_score` | float | ✅ | — | Skor probabilitas TB dari AI (0-1) |
| `prediction_status` | string | ✅ | `Terkena TBC` \| `Tidak Terkena TBC` | Hasil prediksi |
| `mfcc_mean_vector` | float[] | ✅ | panjang = 13 | 13 koefisien MFCC rata-rata dari rekaman batuk |
| `clinical_answers` | object | ✅ | — | Jawaban kuesioner klinis (key-value) |

**Contoh Request**

```json
POST /api/v1/screening/reports
Authorization: Bearer eyJ...
Content-Type: application/json

{
  "probability_score": 0.87,
  "prediction_status": "Terkena TBC",
  "mfcc_mean_vector": [-12.5, 4.2, 1.3, -0.8, 2.1, 0.5, -1.2, 3.4, 0.9, -2.1, 1.7, 0.3, -0.6],
  "clinical_answers": {
    "batuk_lebih_2_minggu": true,
    "demam_malam": true,
    "penurunan_berat_badan": true,
    "riwayat_kontak": false
  }
}
```

**Response Success** — `201 Created`

```json
{
  "report_id": "uuid",
  "patient_id": "uuid",
  "probability_score": 0.87,
  "prediction_status": "Terkena TBC",
  "mfcc_mean_vector": [-12.5, 4.2, ...],
  "clinical_answers": { ... },
  "created_at": "2026-07-24T10:30:00Z"
}
```

---

#### 4.6.2 Get My Screening Reports

| Field | Detail |
|---|---|
| **URL** | `/api/v1/screening/reports` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT |

**Query Parameters**

| Param | Tipe | Default | Deskripsi |
|---|---|---|---|
| `limit` | integer | 100 | Jumlah per halaman |
| `page` | integer | 1 | Halaman |

**Response** — `200 OK` — Array ScreeningReportResponse

---

#### 4.6.3 Get Screening Report By ID

| Field | Detail |
|---|---|
| **URL** | `/api/v1/screening/reports/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL (PATIENT hanya bisa lihat milik sendiri) |

**Path Parameters**: `id` (UUID)

**Response** — `200 OK` — ScreeningReportResponse

**Status Code**: `200`, `401`, `403` (bukan pemilik report), `404`

---

### 4.7 Consultation & Telemedicine

#### 4.7.1 Create Consultation

| Field | Detail |
|---|---|
| **Nama** | Create Consultation |
| **Deskripsi** | Membuat sesi konsultasi baru dengan dokter, menggunakan kuota harian dokter |
| **URL** | `/api/v1/consultations` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `doctor_id` | string | ✅ | UUID | ID dokter yang dipilih |
| `report_id` | string | ✅ | UUID | ID laporan skrining terkait |
| `consent_granted` | boolean | ✅ | — | Persetujuan berbagi data medis (UU PDP) |

**Contoh Request**

```json
POST /api/v1/consultations
Authorization: Bearer eyJ...
Content-Type: application/json

{
  "doctor_id": "550e8400-e29b-41d4-a716-446655440001",
  "report_id": "550e8400-e29b-41d4-a716-446655440002",
  "consent_granted": true
}
```

**Response Success** — `201 Created`

```json
{
  "consultation_id": "uuid",
  "patient_id": "uuid",
  "doctor_id": "uuid",
  "report_id": "uuid",
  "consent_granted": true,
  "consent_timestamp": "2026-07-24T10:30:00Z",
  "status": "ACTIVE",
  "created_at": "2026-07-24T10:30:00Z",
  "updated_at": "2026-07-24T10:30:00Z"
}
```

**Status Code**

| Code | Deskripsi |
|---|---|
| `201` | Konsultasi berhasil dibuat |
| `400` | Validasi gagal |
| `409` | Kuota dokter habis (race condition) |
| `422` | Dokter tidak menerima pasien (offline/tutup kuota) |
| `500` | Internal error |

---

#### 4.7.2 Get My Consultations

| Field | Detail |
|---|---|
| **URL** | `/api/v1/consultations` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT, DOCTOR |

**Query Parameters**

| Param | Tipe | Default |
|---|---|---|
| `limit` | integer | 100 |
| `page` | integer | 1 |

**Response** — `200 OK` — Array ConsultationResponse

---

#### 4.7.3 Get Consultation By ID

| Field | Detail |
|---|---|
| **URL** | `/api/v1/consultations/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT, DOCTOR, ADMIN |

**Response** — `200 OK` — ConsultationResponse

---

#### 4.7.4 Get Chat History

| Field | Detail |
|---|---|
| **URL** | `/api/v1/consultations/:id/messages` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT, DOCTOR, ADMIN |

**Query Parameters**

| Param | Tipe | Default |
|---|---|---|
| `limit` | integer | 100 |
| `page` | integer | 1 |

**Response Success** — `200 OK`

```json
[
  {
    "message_id": "uuid",
    "consultation_id": "uuid",
    "sender_id": "uuid",
    "message_text": "BASE64_E2EE_CIPHERTEXT...",
    "is_read": true,
    "created_at": "2026-07-24T10:35:00Z"
  }
]
```

> [!IMPORTANT]
> Field `message_text` berisi **E2EE ciphertext** (Base64 encoded). Dekripsi dilakukan di sisi klien menggunakan private key.

---

#### 4.7.5 WebSocket Chat (Real-time)

| Field | Detail |
|---|---|
| **Nama** | WebSocket Chat Connection |
| **Deskripsi** | Upgrade ke WebSocket untuk chat real-time dengan E2EE |
| **URL** | `/api/v1/consultations/:id/ws` |
| **Method** | `GET` (WebSocket Upgrade) |
| **Auth** | ✅ Bearer Token (via query/header) |
| **Roles** | PATIENT, DOCTOR, ADMIN |

**WebSocket Message Format**

```json
{
  "type": "chat",
  "encrypted_payload": "BASE64_CIPHERTEXT..."
}
```

```json
{
  "type": "read",
  "encrypted_payload": ""
}
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `type` | string | `chat` untuk pesan baru, `read` untuk read receipt |
| `encrypted_payload` | string | Pesan terenkripsi (Base64) |

---

#### 4.7.6 Save Public Key (E2EE)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/consultations/keys` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT, DOCTOR, ADMIN |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `public_key` | string | ✅ | Public key E2EE (Base64/PEM) |

**Response Success** — `200 OK`

```json
{
  "user_id": "uuid",
  "public_key": "MIIBIjANBgkqhkiG9w0BAQEF...",
  "updated_at": "2026-07-24T10:30:00Z"
}
```

---

#### 4.7.7 Get Public Key (E2EE)

| Field | Detail |
|---|---|
| **URL** | `/api/v1/consultations/keys/:user_id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT, DOCTOR, ADMIN |

**Response** — `200 OK` — PublicKeyResponse

---

### 4.8 Monitoring

#### 4.8.1 Get My Patients

| Field | Detail |
|---|---|
| **Nama** | Get My Patients |
| **Deskripsi** | Mengambil daftar pasien yang dipantau oleh dokter |
| **URL** | `/api/v1/monitoring/patients` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR, ADMIN |

**Query Parameters**

| Param | Tipe | Default |
|---|---|---|
| `limit` | integer | 100 |
| `page` | integer | 1 |

**Response Success** — `200 OK`

```json
[
  {
    "monitoring_id": "uuid",
    "patient_id": "uuid",
    "doctor_id": "uuid",
    "patient_name": "Budi Santoso",
    "followup_status": "under_treatment",
    "last_screening_at": "2026-07-20T10:00:00Z",
    "inactivity_alert": false,
    "notes": "Kondisi membaik",
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-24T10:00:00Z"
  }
]
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `monitoring_id` | string (UUID) | ID record monitoring |
| `patient_id` | string (UUID) | ID pasien |
| `doctor_id` | string (UUID) | ID dokter |
| `patient_name` | string | Nama pasien |
| `followup_status` | string | `referred_to_tcm` \| `under_treatment` \| `cured` \| `defaulted` |
| `last_screening_at` | string \| null | Tanggal skrining terakhir |
| `inactivity_alert` | boolean | Apakah ada alert inaktivitas |
| `notes` | string \| null | Catatan dokter |
| `created_at` | string | Timestamp dibuat |
| `updated_at` | string | Timestamp diperbarui |

---

#### 4.8.2 Get Patient Monitoring

| Field | Detail |
|---|---|
| **URL** | `/api/v1/monitoring/patients/:patient_id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR, PATIENT, ADMIN |

**Response** — `200 OK` — PatientMonitoringResponse

---

#### 4.8.3 Update Patient Monitoring

| Field | Detail |
|---|---|
| **URL** | `/api/v1/monitoring/patients/:patient_id` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR, ADMIN |

**Request Body**

| Field | Tipe | Required | Validasi | Deskripsi |
|---|---|---|---|---|
| `followup_status` | string | ✅ | `referred_to_tcm` \| `under_treatment` \| `cured` \| `defaulted` | Status follow-up |
| `notes` | string | ❌ | — | Catatan klinis |

**Response** — `200 OK` — `{"message": "patient monitoring record updated successfully"}`

---

#### 4.8.4 Get Patient Clinical Trends

| Field | Detail |
|---|---|
| **URL** | `/api/v1/monitoring/patients/:patient_id/trends` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | DOCTOR, PATIENT, ADMIN |

**Response Success** — `200 OK`

```json
{
  "probability_trends": [
    {
      "created_at": "2026-07-01T00:00:00Z",
      "probability_score": 0.87
    },
    {
      "created_at": "2026-07-15T00:00:00Z",
      "probability_score": 0.65
    }
  ],
  "questionnaire_trends": [
    {
      "created_at": "2026-07-01T00:00:00Z",
      "clinical_answers": { "batuk": true, "demam": true }
    }
  ]
}
```

---

### 4.9 Notification

#### 4.9.1 Get My Notifications

| Field | Detail |
|---|---|
| **URL** | `/api/v1/notifications` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Query Parameters**

| Param | Tipe | Default |
|---|---|---|
| `limit` | integer | 100 |
| `page` | integer | 1 |

**Response Success** — `200 OK`

```json
[
  {
    "notification_id": "uuid",
    "user_id": "uuid",
    "title": "Konsultasi Baru",
    "message": "Dr. Siti Aminah telah menerima konsultasi Anda",
    "is_read": false,
    "notification_type": "consultation",
    "created_at": "2026-07-24T10:35:00Z"
  }
]
```

---

#### 4.9.2 Mark Notification as Read

| Field | Detail |
|---|---|
| **URL** | `/api/v1/notifications/:id/read` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response** — `200 OK` — `{"message": "notification marked as read"}`

---

#### 4.9.3 Mark All Notifications as Read

| Field | Detail |
|---|---|
| **URL** | `/api/v1/notifications/read-all` |
| **Method** | `PUT` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response** — `200 OK` — `{"message": "all notifications marked as read"}`

---

#### 4.9.4 Register FCM Device Token

| Field | Detail |
|---|---|
| **Nama** | Register FCM Token |
| **Deskripsi** | Mendaftarkan token perangkat FCM untuk push notification |
| **URL** | `/api/v1/notifications/device-token` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Request Body**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `fcm_token` | string | ✅ | Firebase Cloud Messaging token |
| `device_id` | string | ✅ | ID perangkat |

**Contoh Request**

```json
POST /api/v1/notifications/device-token
Authorization: Bearer eyJ...
Content-Type: application/json

{
  "fcm_token": "dkLpYqZ3RsC...",
  "device_id": "android-abc123"
}
```

**Response** — `200 OK` — `{"message": "FCM device token registered successfully"}`

---

### 4.10 File Storage

#### 4.10.1 Upload File

| Field | Detail |
|---|---|
| **URL** | `/api/v1/files` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |
| **Content-Type** | `multipart/form-data` |

**Request Body (form-data)**

| Field | Tipe | Required | Deskripsi |
|---|---|---|---|
| `file` | File | ✅ | File yang diupload |
| `module_name` | string | ❌ | Nama module pengguna (default: `general`) |

**Response Success** — `201 Created`

```json
{
  "file_id": "uuid",
  "original_name": "photo.jpg",
  "stored_name": "550e8400-photo.jpg",
  "mime_type": "image/jpeg",
  "file_size": 1048576,
  "storage_path": "uploads/general/550e8400-photo.jpg",
  "url": "https://storage.example.com/uploads/general/550e8400-photo.jpg",
  "uploaded_by": "uuid",
  "created_at": "2026-07-24T10:30:00Z"
}
```

---

#### 4.10.2 Download File

| Field | Detail |
|---|---|
| **URL** | `/api/v1/files/:id` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response** — `200 OK` — File binary stream dengan header:
- `Content-Type`: MIME type file
- `Content-Length`: ukuran file
- `Content-Disposition`: `inline; filename="original_name.ext"`

---

#### 4.10.3 Delete File

| Field | Detail |
|---|---|
| **URL** | `/api/v1/files/:id` |
| **Method** | `DELETE` |
| **Auth** | ✅ Bearer Token |
| **Roles** | ALL |

**Response** — `200 OK` — `{"message": "file deleted successfully"}`

---

### 4.11 JWT Key Rotation (Internal/Admin)

> [!WARNING]
> Endpoint ini ditujukan untuk operasi internal admin saja. Tidak digunakan oleh frontend klien.

#### 4.11.1 Generate New JWT Key

| **URL** | `/api/v1/internal/jwt-keys` | **Method** | `POST` | **Roles** | ADMIN |
|---|---|---|---|---|---|

**Request Body**: `{"key_id": "key-2026-07-v2"}`  
**Response** — `201 Created` — `{"data": JwtKeyDTO}` (secret: `[ENCRYPTED]`)

#### 4.11.2 Get All JWT Keys

| **URL** | `/api/v1/internal/jwt-keys` | **Method** | `GET` | **Roles** | ADMIN |
|---|---|---|---|---|---|

**Response** — `200 OK` — `{"data": [JwtKeyDTO, ...]}`

#### 4.11.3 Get Active JWT Key

| **URL** | `/api/v1/internal/jwt-keys/active` | **Method** | `GET` | **Roles** | ADMIN |
|---|---|---|---|---|---|

**Response** — `200 OK` — `{"data": JwtKeyDTO}`

#### 4.11.4 Activate JWT Key

| **URL** | `/api/v1/internal/jwt-keys/:id/activate` | **Method** | `PATCH` | **Roles** | ADMIN |
|---|---|---|---|---|---|

**Response** — `200 OK` — `{"message": "key activated successfully"}`

#### 4.11.5 Revoke JWT Key

| **URL** | `/api/v1/internal/jwt-keys/:id/revoke` | **Method** | `PATCH` | **Roles** | ADMIN |
|---|---|---|---|---|---|

**Response** — `200 OK` — `{"message": "key revoked successfully"}`

---

### 4.12 SVIR Simulator

> [!NOTE]
> SVIR endpoints memerlukan autentikasi Bearer Token dan hanya dapat diakses oleh user dengan role `PATIENT`. API Gateway mem-proxy request ini melalui monolith `app-tbcheck` untuk memproses autentikasi secara terpusat.

#### 4.12.1 Run SVIR Simulation

| Field | Detail |
|---|---|
| **Nama** | Run SVIR Simulation |
| **Deskripsi** | Menjalankan simulasi model epidemiologi SVIR (Susceptible-Vaccinated-Infected-Recovered) |
| **URL** | `/api/v1/svir/simulate` |
| **Method** | `POST` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT |

**Request Body**

| Field | Tipe | Required | Default | Validasi | Deskripsi |
|---|---|---|---|---|---|
| `population` | integer | ❌ | 100000 | ≥ 1 | Total populasi (N) |
| `initial_infected` | integer | ❌ | 100 | ≥ 0 | Jumlah terinfeksi awal (I₀) |
| `initial_recovered` | integer | ❌ | 0 | ≥ 0 | Jumlah sembuh awal (R₀) |
| `vaccination_rate` | float | ❌ | 0.3 | 0-1 | Tingkat vaksinasi (v) |
| `contact_rate` | float | ❌ | 0.5 | ≥ 0 | Tingkat transmisi (β) |
| `recovery_rate` | float | ❌ | 0.1 | ≥ 0 | Tingkat pemulihan (γ) |
| `vaccine_efficacy` | float | ❌ | 0.8 | 0-1 | Efikasi vaksin (σ) |
| `mortality_rate` | float | ❌ | 0.0 | 0-1 | Angka kematian alami (μ) |
| `days` | integer | ❌ | 180 | 1-1000 | Durasi simulasi (hari) |

**Contoh Request**

```json
POST /api/v1/svir/simulate
Content-Type: application/json

{
  "population": 100000,
  "initial_infected": 500,
  "vaccination_rate": 0.5,
  "contact_rate": 0.3,
  "recovery_rate": 0.15,
  "vaccine_efficacy": 0.85,
  "days": 365
}
```

**Response Success** — `200 OK`

```json
{
  "days": [0, 1, 2, ..., 365],
  "susceptible": [99500.0, 99450.2, ...],
  "vaccinated": [0.0, 49.8, ...],
  "infected": [500.0, 485.3, ...],
  "recovered": [0.0, 14.7, ...],
  "parameters": {
    "population": 100000,
    "vaccination_rate": 0.5,
    "contact_rate": 0.3,
    "recovery_rate": 0.15,
    "vaccine_efficacy": 0.85,
    "mortality_rate": 0.0
  }
}
```

---

#### 4.12.2 Get Community Risk

| Field | Detail |
|---|---|
| **Nama** | Get Community Risk |
| **Deskripsi** | Menghitung tingkat risiko TB komunitas berdasarkan data skrining di area tertentu |
| **URL** | `/api/v1/svir/community-risk` |
| **Method** | `GET` |
| **Auth** | ✅ Bearer Token |
| **Roles** | PATIENT |

**Query Parameters**

| Param | Tipe | Required | Default | Validasi | Deskripsi |
|---|---|---|---|---|---|
| `lat` | float | ✅ | — | — | Latitude |
| `lon` | float | ✅ | — | — | Longitude |
| `radius_km` | float | ❌ | 10.0 | 0.1-100 | Radius pencarian (km) |

**Contoh Request**

```
GET /api/v1/svir/community-risk?lat=-6.2088&lon=106.8456&radius_km=15
```

**Response Success** — `200 OK`

```json
{
  "total_screenings": 150,
  "positive_cases": 45,
  "negative_cases": 105,
  "infection_ratio": 0.3,
  "risk_level": "HIGH",
  "radius_km": 15.0
}
```

| Field | Tipe | Deskripsi |
|---|---|---|
| `total_screenings` | integer | Total skrining di area |
| `positive_cases` | integer | Jumlah kasus positif |
| `negative_cases` | integer | Jumlah kasus negatif |
| `infection_ratio` | float | Rasio infeksi (0-1) |
| `risk_level` | string | Level risiko (`LOW`, `MEDIUM`, `HIGH`) |
| `radius_km` | float | Radius area yang dihitung |

---

## 5. Ringkasan API

| Module | Endpoint | Method | Auth | Roles | Status |
|---|---|---|---|---|---|
| **Auth** | `/auth/register` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/login` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/refresh` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/logout` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/verify-email` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/resend-verification` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/forgot-password` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/reset-password` | POST | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/google/login` | GET | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/google/callback` | GET | ❌ | Public | ✅ Implemented |
| **Auth** | `/auth/google/mobile-login` | POST | ❌ | Public | ✅ Implemented |
| **Identity** | `/api/v1/profile` | GET | ✅ | ALL | ✅ Implemented |
| **Identity** | `/api/v1/profile/patient` | PUT | ✅ | PATIENT | ✅ Implemented |
| **Identity** | `/api/v1/profile/doctor` | PUT | ✅ | DOCTOR | ✅ Implemented |
| **Identity** | `/api/v1/profile/location` | PUT | ✅ | PATIENT | ✅ Implemented |
| **Identity** | `/api/v1/profile/avatar` | POST | ✅ | ALL | ✅ Implemented |
| **Hospital** | `/api/v1/hospitals` | GET | ✅ | ALL | ✅ Implemented |
| **Hospital** | `/api/v1/hospitals/:id` | GET | ✅ | ALL | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals` | POST | ✅ | ADMIN | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals` | GET | ✅ | ADMIN | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals/:id` | GET | ✅ | ADMIN | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals/:id` | PUT | ✅ | ADMIN | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals/:id` | DELETE | ✅ | ADMIN | ✅ Implemented |
| **Hospital** | `/api/v1/admin/hospitals/:id/logo` | POST | ✅ | ADMIN | ✅ Implemented |
| **Doctor** | `/api/v1/doctors/nearest` | GET | ✅ | ALL | ✅ Implemented |
| **Doctor** | `/api/v1/doctors/:id` | GET | ✅ | ALL | ✅ Implemented |
| **Doctor** | `/api/v1/doctors` | POST | ✅ | ADMIN | ✅ Implemented |
| **Doctor** | `/api/v1/doctors/availability` | PUT | ✅ | DOCTOR, ADMIN | ✅ Implemented |
| **Doctor** | `/api/v1/doctors/license-status` | PUT | ✅ | ADMIN | ✅ Implemented |
| **Doctor** | `/api/v1/doctors/employment-status` | PUT | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/:id` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/search` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/progress` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/:id/progress` | PUT | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education` | POST | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education/:id` | PUT | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education/:id` | DELETE | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education/:id/publish` | PUT | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education/herbal` | POST | ✅ | ADMIN | ✅ Implemented |
| **Education** | `/api/v1/education/herbal` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/herbal/:id` | GET | ✅ | ALL | ✅ Implemented |
| **Education** | `/api/v1/education/herbal/:id` | DELETE | ✅ | ADMIN | ✅ Implemented |
| **Screening** | `/api/v1/screening/reports` | POST | ✅ | PATIENT | ✅ Implemented |
| **Screening** | `/api/v1/screening/reports` | GET | ✅ | PATIENT | ✅ Implemented |
| **Screening** | `/api/v1/screening/reports/:id` | GET | ✅ | ALL* | ✅ Implemented |
| **Consultation** | `/api/v1/consultations` | POST | ✅ | PATIENT | ✅ Implemented |
| **Consultation** | `/api/v1/consultations` | GET | ✅ | PATIENT, DOCTOR | ✅ Implemented |
| **Consultation** | `/api/v1/consultations/:id` | GET | ✅ | PATIENT, DOCTOR, ADMIN | ✅ Implemented |
| **Consultation** | `/api/v1/consultations/:id/messages` | GET | ✅ | PATIENT, DOCTOR, ADMIN | ✅ Implemented |
| **Consultation** | `/api/v1/consultations/:id/ws` | GET | ✅ | PATIENT, DOCTOR, ADMIN | ✅ Implemented |
| **Consultation** | `/api/v1/consultations/keys` | POST | ✅ | PATIENT, DOCTOR, ADMIN | ✅ Implemented |
| **Consultation** | `/api/v1/consultations/keys/:user_id` | GET | ✅ | PATIENT, DOCTOR, ADMIN | ✅ Implemented |
| **Monitoring** | `/api/v1/monitoring/patients` | GET | ✅ | DOCTOR, ADMIN | ✅ Implemented |
| **Monitoring** | `/api/v1/monitoring/patients/:patient_id` | GET | ✅ | DOCTOR, PATIENT, ADMIN | ✅ Implemented |
| **Monitoring** | `/api/v1/monitoring/patients/:patient_id` | PUT | ✅ | DOCTOR, ADMIN | ✅ Implemented |
| **Monitoring** | `/api/v1/monitoring/patients/:patient_id/trends` | GET | ✅ | DOCTOR, PATIENT, ADMIN | ✅ Implemented |
| **Notification** | `/api/v1/notifications` | GET | ✅ | ALL | ✅ Implemented |
| **Notification** | `/api/v1/notifications/:id/read` | PUT | ✅ | ALL | ✅ Implemented |
| **Notification** | `/api/v1/notifications/read-all` | PUT | ✅ | ALL | ✅ Implemented |
| **Notification** | `/api/v1/notifications/device-token` | POST | ✅ | ALL | ✅ Implemented |
| **File** | `/api/v1/files` | POST | ✅ | ALL | ✅ Implemented |
| **File** | `/api/v1/files/:id` | GET | ✅ | ALL | ✅ Implemented |
| **File** | `/api/v1/files/:id` | DELETE | ✅ | ALL | ✅ Implemented |
| **JWT Key** | `/api/v1/internal/jwt-keys` | POST | ✅ | ADMIN | ✅ Implemented |
| **JWT Key** | `/api/v1/internal/jwt-keys` | GET | ✅ | ADMIN | ✅ Implemented |
| **JWT Key** | `/api/v1/internal/jwt-keys/active` | GET | ✅ | ADMIN | ✅ Implemented |
| **JWT Key** | `/api/v1/internal/jwt-keys/:id/activate` | PATCH | ✅ | ADMIN | ✅ Implemented |
| **JWT Key** | `/api/v1/internal/jwt-keys/:id/revoke` | PATCH | ✅ | ADMIN | ✅ Implemented |
| **SVIR** | `/api/v1/svir/simulate` | POST | ✅ | PATIENT | ✅ Implemented |
| **SVIR** | `/api/v1/svir/community-risk` | GET | ✅ | PATIENT | ✅ Implemented |
| **Dashboard** | `/api/v1/patient/dashboard` | GET | ✅ | PATIENT, ADMIN | ✅ Implemented |
| **Dashboard** | `/api/v1/doctor/dashboard` | GET | ✅ | DOCTOR, ADMIN | ✅ Implemented |
| **Dashboard** | `/api/v1/admin/system-settings` | GET | ✅ | ADMIN | ✅ Implemented |

> **Total Endpoint**: **71 endpoint** (termasuk health check & dashboard)  
> **Status**: Seluruh endpoint ✅ **Implemented** — tidak ditemukan endpoint draft atau belum dipublish.

---

## 6. Catatan Penting

1. **Access Token berlaku 15 menit** — Gunakan `/auth/refresh` untuk mendapatkan token baru sebelum expired.

2. **E2EE (End-to-End Encryption)** — Pesan chat pada modul Consultation dienkripsi di sisi klien. Server hanya menyimpan ciphertext.

3. **UU PDP Compliance** — Beberapa data (NIK, KK, koordinat, alamat) dienkripsi/pseudonim di database. Response API menampilkan data yang sudah didekripsi untuk user yang berhak.

4. **Rate Limiting** — Hanya berlaku di API Gateway untuk endpoint auth tertentu. Endpoint lain tidak memiliki rate limit di gateway.

5. **Catch-all Routing** — Seluruh path yang tidak didefinisikan secara eksplisit di gateway diteruskan ke `tbcheck-service`. Ini berarti tidak ada endpoint internal yang gagal dipublish.

6. **WebSocket** — Koneksi WebSocket untuk chat memerlukan JWT token yang valid. Upgrade dilakukan via `GET /api/v1/consultations/:id/ws`.

7. **File Upload** — Gunakan `Content-Type: multipart/form-data` untuk endpoint yang menerima file upload (`/api/v1/files`, `/api/v1/profile/avatar`, dll).

8. **Pagination** — Endpoint yang mengembalikan list mendukung query param `limit` dan `page`/`offset`.
