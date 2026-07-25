# AKA Notify

A modern notification system designed for FiveM servers, built with a premium glassmorphism interface and the visual identity of the AKA suite.

AKA Notify replaces the default GTA/FiveM notifications with a clean, immersive and highly customizable toast system featuring smooth animations, dynamic colors, custom icons and sound feedback.

Designed to be lightweight, scalable and easy to integrate into any server.

## Features

✨ Modern Glassmorphism UI  
⚡ Optimized performance with zero dependencies  
🎨 Fully customizable colors, icons and styles  
🔔 Multiple notification types  
🔊 Integrated notification sounds  
🔗 ESX compatibility  
📦 Simple installation  
🛠 Developer-friendly API  

## Notification Types

- Success
- Error
- Warning
- Information
- System
- Item

Each notification includes its own color theme, icon and visual effects.

## Customization

Every notification can be customized with:

- Custom HEX colors
- Custom SVG icons
- Custom titles
- Custom duration
- Individual sounds

Built to adapt to your server's identity.

## Compatibility

✔ ESX Legacy  
✔ Standalone  
✔ FiveM Native

No external dependencies required.

## Performance

AKA Notify was created with optimization in mind:

- Lightweight NUI system
- Minimal resource usage
- No unnecessary frameworks
- Clean and scalable code

## API Example

```lua
exports['aka-notify']:ShowNotification(
    'Operation successful',
    'success'
)
