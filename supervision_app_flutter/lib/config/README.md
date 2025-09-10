# Network Configuration Setup

This app now supports automatic IP detection for both Android emulator and real device environments.

## Automatic Configuration

The app will automatically detect:
- **Android Emulator**: Uses `10.0.2.2:3000` (Android emulator's host machine IP)
- **Real Android Device**: Uses `192.168.1.69:3000` (your current network IP)
- **iOS Simulator**: Uses `localhost:3000`
- **Real iOS Device**: Uses `192.168.1.69:3000`

## Manual Configuration (Development)

### Option 1: Using Environment Selector Widget
1. Run the app in debug mode
2. Look for the orange network settings button (floating action button)
3. Tap it to open the environment selector
4. Choose your preferred environment:
   - **Real Device**: `192.168.1.69:3000`
   - **Android Emulator**: `10.0.2.2:3000`
   - **Localhost**: `127.0.0.1:3000`

### Option 2: Code-based Override
```dart
import 'package:supervision_app/config/app_config.dart';

// Override base URL for testing
AppConfigExtension.setBaseUrlOverride("http://YOUR_IP:3000/api");
```

### Option 3: Update Default IP
If your backend server IP changes, update it in:
- `lib/config/app_config.dart` - line with `_realDeviceBaseUrl`
- `lib/config/network_config.dart` - line with `_realDeviceIP`

## Backend Server Setup

Make sure your backend server is accessible:

### For Real Device Testing:
1. Find your computer's IP address:
   ```bash
   # Windows
   ipconfig
   
   # macOS/Linux
   ifconfig
   ```
2. Update the IP in the config files if different from `192.168.1.69`
3. Ensure your backend server binds to `0.0.0.0:3000` (not just `localhost:3000`)

### For Android Emulator:
- No changes needed - `10.0.2.2` automatically maps to your host machine

### For iOS Simulator:
- No changes needed - uses `localhost` directly

## Troubleshooting

1. **Connection refused**: Check if backend server is running and accessible
2. **Wrong IP**: Use the environment selector to manually choose the correct environment
3. **Firewall issues**: Ensure your firewall allows connections on port 3000
4. **Network changes**: If you switch networks, the IP might change - update accordingly
