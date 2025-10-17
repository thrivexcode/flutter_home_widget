# <div align="center">📝 Flutter Home Widget Notes App</div>

<div align="center">

[![Status](https://img.shields.io/badge/Status-Active-blueviolet.svg)](https://github.com/thrivexcode/flutter_home_widget)
[![Flutter](https://img.shields.io/badge/Flutter-App-blue.svg?&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Drift](https://img.shields.io/badge/Drift-Local%20Database-009688?style=flat-square&logo=sqlite&logoColor=white)](https://drift.simonbinder.eu/)

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/thrivexcode)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/thrivexcode/)

</div>

---

<p align="center">
  <img src="https://res.cloudinary.com/dkpesnimh/image/upload/v1760688089/banner_hmvdv5.gif" width="100%" alt="Flutter Home Widget Notes Banner Preview" />
</p>

---

## 🎯 Overview

**Flutter Home Widget Notes App** adalah aplikasi catatan sederhana yang terintegrasi langsung dengan **Android Home Widget**.  
Catatan terbaru yang disimpan di aplikasi akan muncul langsung di **widget layar utama**, menjadikannya cepat diakses tanpa membuka aplikasi.

Aplikasi ini juga menggunakan **Drift** untuk menyimpan catatan secara lokal (offline), dengan arsitektur modular agar mudah dikembangkan lebih lanjut.

---

## 🎥 Live Demo

**Berikut preview interaksi aplikasi & widget:**

<div align="center"> 
  <a href="https://res.cloudinary.com/dhhm853e7/image/upload/v1751533393/flutter_home_widget_demo_abcd.gif" target="_blank"> 
    <img src="https://img.shields.io/badge/🎬%20View%20Live%20Demo-Click%20Here-blue?style=for-the-badge" alt="Live Demo Button"/> 
  </a> 
</div>

---

## ✨ Features

- 🏠 **Home Widget Integration** — tampilkan note langsung di layar utama Android  
- 💾 **Offline Local Storage** — menggunakan **Drift (SQLite)**  
- 🧭 **Reactive UI** — update otomatis saat catatan berubah  
- ⚡ **Lightweight** — performa cepat dan efisien untuk widget update  

---

## 🧩 Tech Stack

| Layer | Tools |
|-------|--------|
| **Frontend** | Flutter 3.27.2 |
| **Database** | Drift (SQLite ORM for Flutter) |
| **Widget Integration** | Home Widget Plugin |
| **Storage** | SharedPreferences + Drift |

---

## 🛠 Getting Started

Untuk menjalankan proyek ini di lokal:

### 1. Clone Repository
```bash
git clone https://github.com/thrivexcode/flutter_home_widget.git
cd flutter_home_widget
