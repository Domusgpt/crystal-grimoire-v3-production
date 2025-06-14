// Re-export the RedesignedHomeScreen as UnifiedHomeScreen for backwards compatibility
export 'redesigned_home_screen.dart';

// Create a typedef so existing imports continue to work
import 'redesigned_home_screen.dart';

typedef UnifiedHomeScreen = RedesignedHomeScreen;