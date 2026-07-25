# 🔔 AKA Notify

<p align="center">
  <img src="https://i.imgur.com/K77vhUk.png" width="900">
</p>

<p align="center">
  <b>Modern • Smooth • Customizable</b>
</p>

<p align="center">
  A premium notification system for FiveM servers with a modern glassmorphism interface.
</p>

<p align="center">

![FiveM](https://img.shields.io/badge/FiveM-Ready-red?style=for-the-badge&logo=fivem)
![ESX](https://img.shields.io/badge/ESX-Compatible-blue?style=for-the-badge)
![Dependencies](https://img.shields.io/badge/Dependencies-0-green?style=for-the-badge)
![AKA Suite](https://img.shields.io/badge/AKA_Suite-Premium-black?style=for-the-badge)

</p>

---

# 📖 Overview

**AKA Notify** is a modern notification system created for FiveM servers, designed with a premium glassmorphism interface and the visual identity of the **AKA Suite**.

Replace the default GTA/FiveM notifications with a clean, immersive and customizable toast system featuring smooth animations, dynamic colors, custom icons and sound feedback.

Built to be **lightweight, scalable and easy to integrate** into any server.

---

# 🎥 Preview

<p align="center">
  <video width="900" controls>
    <source src="https://i.imgur.com/i8dk8sI.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</p>

---

# ✨ Features

## 🎨 Premium Interface

- Modern glassmorphism design
- Smooth slide animations
- Dynamic glow effects
- Clean right-side notification layout
- Immersive UI experience
- Fully responsive design

---

# 🔔 Notification Types

AKA Notify includes multiple notification styles:

| Type | Description |
|------|-------------|
| ✅ Success | Successful actions |
| ❌ Error | Errors and failures |
| ⚠️ Warning | Important warnings |
| 🔵 Info | General information |
| 🔔 Main | System notifications |
| 📦 Item | Item related messages |

---

# 🚀 Main Features

## ⚡ Optimized Performance

Designed with performance as a priority:

- Zero dependencies
- Lightweight NUI system
- Minimal resource usage
- Clean architecture
- Server friendly
- Scalable system

---

## 🎨 Full Customization

Every notification can be customized:

- Custom HEX colors
- Custom SVG icons
- Custom titles
- Custom duration
- Custom sounds
- Custom notification styles

Example:

```lua
exports['aka-notify']:ShowNotification(
    'Custom message',
    'info',
    {
        title = 'Information',
        color = '#00ffff',
        duration = 5000
    }
)
```

---

# 🔗 ESX Integration

AKA Notify includes automatic ESX notification support.

Compatible with:

```lua
ESX.ShowNotification()

ESX.ShowAdvancedNotification()
```

Existing ESX scripts can continue working without major modifications.

---

# 📦 Installation

### 1. Download the resource

Place it inside your resources folder:

```
resources/
└── aka-notify
```

### 2. Add it to your server.cfg

```cfg
ensure aka-notify
```

### 3. Restart your server

Your server is now using AKA Notify.

---

# 🛠 API

## Client Side

### Simple notification

```lua
exports['aka-notify']:ShowNotification(
    'Operation successful',
    'success'
)
```

---

### Advanced notification

```lua
exports['aka-notify']:ShowNotification(
    'Something went wrong',
    'error',
    {
        title = 'Error',
        color = '#ff0000',
        duration = 6000
    }
)
```

---

## Server Side

Send a notification to players:

```lua
TriggerClientEvent(
    'aka-notify:notification',
    -1,
    'Server restart in 5 minutes',
    'warning'
)
```

---

# 📂 Resource Structure

```
aka-notify/

├── fxmanifest.lua
├── config.lua
├── client.lua

└── html/
    ├── index.html
    ├── style.css
    ├── config.js
    ├── script.js

    └── assets/
        └── notif.mp3
```

---

# 🎯 Performance

AKA Notify was built with optimization in mind.

```
✔ Zero dependencies
✔ Lightweight UI
✔ Smooth animations
✔ Clean codebase
✔ Scalable architecture
```

---

# 🖤 AKA Suite

AKA Notify is part of the **AKA Suite**, a collection of premium FiveM resources focused on:

- Modern interfaces
- Smooth animations
- Performance
- Customization
- Immersive gameplay

---

# 📜 License

MIT License

---

<p align="center">
  Made with ❤️ by <b>AKA Studio</b>
</p>
