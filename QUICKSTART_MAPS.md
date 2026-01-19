# Quick Start - Google Maps Integration

## 🚀 Quick Setup (5 minutes)

### 1. Get Your API Key
1. Go to https://console.cloud.google.com/
2. Create a new project or select existing
3. Enable these APIs:
   - Maps SDK for Android
   - Maps JavaScript API
   - Geocoding API
4. Go to Credentials → Create API Key
5. Copy your API key

### 2. Add API Key to Your App

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**Web** (`web/index.html`):
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
```

### 3. Run Your App
```bash
flutter pub get
flutter run -d chrome   # For web
# or
flutter run            # For Android
```

## ✨ What's New

### For Users:
- 📍 **Pin location on map** - Select exact delivery location
- 🗺️ **Auto-fill address** - Address filled automatically from map
- 📱 **Use current location** - Quick select your current position
- ✏️ **Edit location** - Update location for existing addresses

### For Developers:
- **New Page**: [map_picker_page.dart](lib/pages/map_picker_page.dart)
- **Updated**: [add_address_page.dart](lib/pages/add_address_page.dart)
- **Updated**: [edit_address_page.dart](lib/pages/edit_address_page.dart)
- **New Dependencies**: google_maps_flutter, geocoding, geolocator

## 📦 Data Structure

Addresses now include coordinates:
```dart
{
  'label': 'Home',
  'name': 'John Doe',
  'phone': '+60123456789',
  'address': 'Full address string',
  'latitude': 1.8631,      // NEW
  'longitude': 103.0900,   // NEW
  'isDefault': false,
  'updatedAt': Timestamp
}
```

## 🧪 Testing

### Test on Web:
```bash
flutter run -d edge  # or chrome
```

### Test on Android:
1. Connect device or start emulator
2. `flutter run`
3. Go to Delivery Address → Add New Address
4. Click "Pin Location"
5. Select location on map
6. Address should auto-fill

## ⚠️ Common Issues

**Maps not showing?**
- ✅ Check API key is correct
- ✅ Enable billing on Google Cloud (free tier is generous)
- ✅ Enable Maps SDK for Android

**Permission denied?**
- ✅ Grant location permission when prompted
- ✅ Check app settings if denied

**Address not loading?**
- ✅ Enable Geocoding API
- ✅ Check internet connection

## 💰 Costs

**Free tier includes:**
- 28,500 map loads/month (Android)
- 28,500 map loads/month (Web)
- 40,000 geocoding requests/month

Most small-medium apps stay free! 🎉

## 📚 Full Documentation

See [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) for detailed setup instructions.

## 🔒 Security Reminder

⚠️ **Never commit your API key to Git!**

Add to `.gitignore`:
```
# API Keys
**/AndroidManifest.xml
web/index.html
.env
```

Or use environment variables for production.

---

**Need help?** Check [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) for troubleshooting.
