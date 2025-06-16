# Jules Development Workflow Guide

## 🔮 Crystal Grimoire V3 Production Development Setup

### Branch Strategy
- **main**: Production-ready code
- **shared-core**: Jules' working branch for development and testing
- **feature branches**: Individual features (e.g., `feat/crystal-ai`, `fix/auth-issues`)

### Jules Setup Commands

```bash
# 1. Clone and switch to shared-core branch
git clone https://github.com/Domusgpt/crystal-grimoire-v3-production.git
cd crystal-grimoire-v3-production
git checkout shared-core

# 2. Run complete setup
./JULES_COMPLETE_SETUP.sh

# 3. Create your feature branch from shared-core
git checkout -b feat/your-feature-name

# 4. Work on your changes...

# 5. Push your feature branch
git push -u origin feat/your-feature-name

# 6. Create PR to merge into shared-core
```

### Development Workflow

#### For New Features:
1. **Branch from shared-core**: `git checkout -b feat/crystal-enhancement`
2. **Make changes**: Edit Flutter/Dart code in `/lib` or backend in `/functions`
3. **Test locally**: `./run_local.sh`
4. **Commit**: Follow conventional commits (feat:, fix:, docs:, etc.)
5. **Push**: `git push -u origin feat/crystal-enhancement`
6. **Create PR**: Target `shared-core` branch, not `main`

#### For Bug Fixes:
1. **Branch from shared-core**: `git checkout -b fix/auth-bug`
2. **Fix the issue**: Make targeted changes
3. **Test**: Ensure fix works and doesn't break existing features
4. **Create PR**: Target `shared-core` branch

### PR Template Compliance

When creating PRs, use this template:

```markdown
## 📋 Description
Brief description of changes

## 🔗 Related Issue
Fixes #(issue_number)

## 🛠️ Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📚 Documentation update
- [ ] 🔧 Configuration change

## 🧪 Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Flutter web build successful
- [ ] Firebase deployment tested

## 📝 Changes Made
- Specific change 1
- Specific change 2
- etc.

## 📱 Component Impact
- [ ] Flutter Frontend (/lib)
- [ ] Firebase Functions (/functions)
- [ ] Configuration files
- [ ] Documentation

## ✅ Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
```

### Testing Requirements

Before creating PRs:

```bash
# 1. Test Flutter build
flutter build web --release

# 2. Test Firebase Functions locally
firebase emulators:start --only functions

# 3. Run full deployment test
./deploy.sh

# 4. Verify endpoints work
curl https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net/api/health
```

### Merge Strategy

1. **Feature branches** → **shared-core** (Jules' working area)
2. **shared-core** → **main** (when ready for production)

### File Structure for Jules

```
crystal-grimoire-v3-production/
├── lib/                    # Flutter/Dart frontend
│   ├── main.dart          # Beautiful mystical UI
│   ├── screens/           # All screen components
│   ├── services/          # Backend integration
│   └── models/            # Data models
├── functions/             # Firebase Functions backend
│   ├── index.js           # Professional API endpoints
│   └── package.json       # Node.js dependencies
├── web/                   # Web assets
├── JULES_COMPLETE_SETUP.sh # Your setup script
└── firebase.json          # Firebase configuration
```

### API Endpoints Available

- **Health Check**: `/api/health`
- **Crystal ID**: `/api/crystal/identify`
- **Status**: `/helloworld`

Base URL: `https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net`

### Key Commands for Jules

```bash
# Quick setup
./JULES_COMPLETE_SETUP.sh

# Local development
./run_local.sh

# Deploy to staging
./deploy.sh

# Create feature branch
git checkout shared-core
git pull origin shared-core
git checkout -b feat/your-feature

# Update shared-core with your changes
git checkout shared-core
git merge feat/your-feature
git push origin shared-core
```

### Important Notes

- **Always work in shared-core or feature branches**
- **Never commit directly to main**
- **Test locally before pushing**
- **Follow the PR template**
- **Beautiful mystical UI is preserved**
- **Professional backend with UnifiedCrystalData is ready**

🔮 **shared-core branch is your playground, Jules!**