import 'services/app_init_service.dart';

void testServices() async {
  print('=== TEST SERVICES ===');
  
  try {
    final appInit = AppInitService();
    await appInit.initializeApp();
    print('✅ AppInitService initialized successfully');
    
    final hasSession = await appInit.restoreUserSession();
    print('✅ Session restored: $hasSession');
    
    print('=== ALL SERVICES WORKING ===');
  } catch (e) {
    print('❌ Error: $e');
  }
}
