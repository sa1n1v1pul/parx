import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  // Token Management
  static Future<void> saveToken(String token) async {
    await _storage.write(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _storage.read(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.remove(AppConstants.tokenKey);
  }

  // Dealer Data Management
  static Future<void> saveDealerData(Map<String, dynamic> dealerData) async {
    await _storage.write(AppConstants.dealerDataKey, dealerData);
  }

  static Map<String, dynamic>? getDealerData() {
    return _storage.read(AppConstants.dealerDataKey);
  }

  static Future<void> removeDealerData() async {
    await _storage.remove(AppConstants.dealerDataKey);
  }

  // User Type Management
  static Future<void> saveUserType(String userType) async {
    await _storage.write(AppConstants.userTypeKey, userType);
  }

  static String? getUserType() {
    return _storage.read(AppConstants.userTypeKey);
  }

  // Clear All Data - Complete cleanup from all storage locations
  static Future<void> clearAll() async {
    try {
      // Step 1: Remove all individual keys explicitly
      await _storage.remove(AppConstants.tokenKey);
      await _storage.remove(AppConstants.dealerDataKey);
      await _storage.remove(AppConstants.userTypeKey);
      
      // Step 2: Get all keys and remove them one by one (extra safety)
      final allKeys = _storage.getKeys();
      for (final key in allKeys) {
        try {
          await _storage.remove(key);
        } catch (e) {
          // Continue removing other keys even if one fails
        }
      }
      
      // Step 3: Erase everything (this clears the entire storage)
      await _storage.erase();
      
      // Step 4: Verify by checking if token is still there
      final token = _storage.read(AppConstants.tokenKey);
      if (token != null) {
        // If token still exists, force remove again
        await _storage.remove(AppConstants.tokenKey);
      }
      
      // Step 5: Write and immediately remove a test key to ensure storage is writable
      await _storage.write('_logout_test', 'cleared');
      await _storage.remove('_logout_test');
      
    } catch (e) {
      // If any step fails, try basic cleanup
      try {
        await _storage.remove(AppConstants.tokenKey);
        await _storage.remove(AppConstants.dealerDataKey);
        await _storage.remove(AppConstants.userTypeKey);
        await _storage.erase();
      } catch (_) {
        // Last resort - try erase only
        try {
          await _storage.erase();
        } catch (__) {
          // If everything fails, at least try to remove token
          _storage.remove(AppConstants.tokenKey);
        }
      }
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null;
  }
}

