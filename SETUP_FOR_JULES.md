# 🛠️ Development Environment Setup for Jules

Hey Jules! Here's everything you need to get the Crystal Grimoire development environment running on your machine.

## 🚀 Quick Start (One Command Setup)

### Linux/Mac:
```bash
bash setup-dev-environment.sh
```

### Windows:
```cmd
# Run as Administrator
setup-dev-environment.bat
```

## 📋 What the Scripts Install

1. **Package Lists** - Updates your system packages
2. **Prerequisites** - curl, git, unzip, wget, etc.
3. **Flutter 3.32.4** - Complete Flutter SDK
4. **Firebase CLI** - For deployment and Firebase management
5. **Google Cloud SDK** - For cloud services and authentication
6. **PATH Updates** - Automatically adds tools to your PATH

## ✅ After Setup

1. **Restart your terminal** (or run `source ~/.bashrc` on Linux/Mac)
2. **Clone the repo**:
   ```bash
   git clone https://github.com/Domusgpt/crystal-grimoire-v3-production.git
   cd crystal-grimoire-v3-production
   ```
3. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```
4. **Login to services**:
   ```bash
   firebase login
   gcloud auth login
   firebase use crystalgrimoire-production
   ```

## 🔧 Development Commands

| Command | Purpose |
|---------|---------|
| `flutter run -d chrome` | Run web app locally |
| `flutter build web --release` | Build for production |
| `firebase deploy --only hosting` | Deploy frontend |
| `firebase deploy --only functions` | Deploy backend |
| `flutter doctor` | Check installation |

## 🐛 Current Issues Paul & I Are Working On

### ✅ Fixed
- Multiple Firebase auth conflicts
- Service worker MIME type errors
- Profile showing placeholder data

### 🔧 In Progress  
- Model compatibility between UnifiedCrystalData and Crystal
- Backend functions deployment timeouts
- Compilation errors in unified backend

### 📍 Current State
- **Web App**: Live at https://crystalgrimoire-production.web.app
- **Authentication**: Working (shows Paul's actual email)
- **Backend**: Partially deployed, functions need work

## 🎯 What You Can Help With

1. **Backend Functions Deployment** - The functions are timing out during deployment
2. **Model Integration** - Need to resolve UnifiedCrystalData vs Crystal model conflicts
3. **Testing** - End-to-end testing of all features once compilation is fixed

## 📂 Key Files to Know

```
crystal-grimoire-v3-production/
├── lib/
│   ├── main.dart                    # Main Flutter app
│   ├── services/                    # Backend services
│   │   ├── firebase_service.dart    # Firebase integration
│   │   ├── unified_data_service.dart # Unified backend
│   │   └── backend_service.dart     # API calls
│   ├── models/                      # Data models
│   │   ├── crystal.dart             # Legacy crystal model
│   │   ├── unified_crystal_data.dart # New unified model
│   │   └── collection_models.dart   # Collection management
│   └── screens/                     # UI screens
├── functions/                       # Firebase functions (backend)
├── web/                            # Web-specific files
└── firebase.json                   # Firebase configuration
```

## 🔥 Firebase Configuration

The app uses:
- **Project**: `crystalgrimoire-production`
- **Hosting**: https://crystalgrimoire-production.web.app
- **Database**: Firestore
- **Auth**: Firebase Auth with Google/Apple sign-in
- **Functions**: Node.js backend API

## 💡 Helpful Tips

1. **Use the latest commits** - Paul and I just pushed several fixes
2. **Check the branches** - There are specific fix branches you can review
3. **Focus on the backend** - The frontend is mostly working, backend needs attention
4. **Test locally first** - Always test with `flutter run -d chrome` before deploying

## 🆘 If Something Goes Wrong

1. **Flutter issues**: Run `flutter doctor` and fix any red X's
2. **Firebase issues**: Check you're logged in with `firebase login`
3. **Permission errors**: Make sure you have access to `crystalgrimoire-production` project
4. **Git issues**: Contact Paul at phillips.paul.email@gmail.com

## 📞 Contact

- **Paul**: phillips.paul.email@gmail.com
- **Project**: https://github.com/Domusgpt/crystal-grimoire-v3-production
- **Live App**: https://crystalgrimoire-production.web.app

---

**Note**: The development environment setup scripts were created by Claude to get you up and running quickly. If you run into any issues, let Paul know and we can troubleshoot together!

Happy coding! 🔮✨