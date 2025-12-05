# ZenFocus 🧠✨

**A biometric-aware Pomodoro timer that adapts to your stress levels**

ZenFocus combines the proven Pomodoro technique with Apple Watch health data to help you focus smarter, not harder. Get personalized break recommendations based on your actual stress levels.

## ✨ Features

### 🎯 Smart Focus Timer
- Classic Pomodoro technique (25/5/15 intervals)
- Multiple preset timers (Classic, Extended, Quick)
- Custom timer creation
- Beautiful circular progress visualization
- Session tracking and statistics

### 💓 Stress-Aware Breaks (Unique!)
- Real-time heart rate monitoring via Apple Watch
- HRV-based stress level detection
- **Adaptive break suggestions** - longer breaks when you need them
- Heart rate recovery tracking during breaks
- Focus score based on heart rate stability

### 🌬️ Guided Breathing Exercises
- Box Breathing (4-4-4-4)
- 4-7-8 Relaxing Breath
- Coherent Breathing
- Energizing Breath
- Visual breathing guide with haptic feedback

### 📊 Progress Tracking
- Daily/weekly/monthly focus statistics
- Session history with stress data
- Streak tracking for motivation
- Goal setting and progress

### 🎨 Beautiful Design
- Warm, calming color palette
- Smooth animations throughout
- Dark mode support
- Multiple accent color options
- Custom tab bar navigation

## 📱 Screenshots

| Timer | Breathing | Stats | Settings |
|-------|-----------|-------|----------|
| ![Timer](docs/timer.png) | ![Breathing](docs/breathing.png) | ![Stats](docs/stats.png) | ![Settings](docs/settings.png) |

## 🛠️ Technical Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- Apple Watch (optional, for health features)

## 📦 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/ZenFocus.git
cd ZenFocus
```

### 2. Open in Xcode
```bash
open ZenFocus.xcodeproj
```

### 3. Configure Signing
1. Select the ZenFocus target
2. Go to "Signing & Capabilities"
3. Select your Development Team
4. Update the Bundle Identifier if needed

### 4. Enable HealthKit (Required for stress features)
The HealthKit capability is already configured. Just ensure your provisioning profile supports it.

### 5. Build and Run
- Select your target device (iPhone)
- Press `Cmd + R` to build and run

## 🏗️ Project Structure

```
ZenFocus/
├── ZenFocusApp.swift          # App entry point
├── Views/
│   ├── ContentView.swift       # Main tab navigation
│   ├── TimerView.swift         # Focus timer screen
│   ├── BreathingView.swift     # Breathing exercises
│   ├── StatsView.swift         # Statistics & history
│   ├── SettingsView.swift      # App settings
│   └── OnboardingView.swift    # First-launch experience
├── ViewModels/
│   ├── TimerManager.swift      # Timer state & logic
│   └── SettingsManager.swift   # User preferences
├── Models/
│   └── TimerModels.swift       # Data models
├── Services/
│   └── HealthKitManager.swift  # Apple Health integration
├── Extensions/
│   └── DesignSystem.swift      # Colors, fonts, styles
└── Resources/
    └── Assets.xcassets         # App icons, colors
```

## 🎨 Design System

### Colors
| Name | Hex | Usage |
|------|-----|-------|
| Zen Focus | `#5B8A72` | Focus sessions, primary actions |
| Zen Break | `#E8985E` | Short breaks, secondary actions |
| Zen Rest | `#7BA3C9` | Long breaks, breathing exercises |
| Zen Accent | `#D4A574` | Highlights, achievements |

### Typography
- **Display**: SF Rounded Light (timer numbers)
- **Headlines**: SF Rounded Semibold
- **Body**: SF Rounded Regular
- **Captions**: SF Rounded Regular (smaller)

## 💰 Monetization Strategy

### Free Tier
- Basic Pomodoro timer (25/5)
- 3 preset timers
- Basic statistics
- 2 breathing exercises
- 3 ambient sounds

### Premium ($29.99/year or $4.99/month)
- Unlimited custom timers
- Full Apple Watch integration
- All breathing exercises
- All ambient sounds
- Advanced analytics
- iCloud sync
- Priority support

### Lifetime ($79.99)
- All premium features forever

## 🚀 Deployment Checklist

### Before App Store Submission
- [ ] Create App Store Connect listing
- [ ] Prepare screenshots (6.7", 6.5", 5.5" iPhones)
- [ ] Write compelling description
- [ ] Set up keywords for ASO
- [ ] Create preview video (optional but recommended)
- [ ] Configure in-app purchases in App Store Connect
- [ ] Set up App Privacy nutrition labels
- [ ] Test on multiple devices

### App Store Optimization (ASO)
**Suggested Keywords:**
- pomodoro timer
- focus timer
- productivity
- stress relief
- breathing exercises
- habit tracker
- wellness
- mindfulness
- concentration
- study timer

## 🔮 Roadmap

### Version 1.1
- [ ] Apple Watch standalone app
- [ ] Widget support (Home Screen & Lock Screen)
- [ ] Siri Shortcuts integration
- [ ] Focus modes integration

### Version 1.2
- [ ] Social features (challenges with friends)
- [ ] Team/workspace support
- [ ] Calendar integration
- [ ] Task linking

### Version 2.0
- [ ] AI-powered focus insights
- [ ] Personalized break recommendations
- [ ] Sleep quality correlation
- [ ] Long-term wellness trends

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique® by Francesco Cirillo
- Design influenced by calm, wellness-focused apps
- Heart rate variability research from HeartMath Institute

---

**Built with ❤️ for focused minds**

Questions? Issues? [Open an issue](https://github.com/yourusername/ZenFocus/issues) or reach out!
