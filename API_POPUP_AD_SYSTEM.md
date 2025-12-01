# API-Based Popup Ad System 🎯

The Medicare app now features a dynamic popup ad system that fetches advertisements from the API and displays them on the homescreen with full tracking capabilities.

## 🚀 Features Implemented

### ✅ **Dynamic Ad Loading**
- Fetches active advertisements from `/api/v1/ads/active` endpoint
- Displays the first active ad as a popup on dashboard load
- Validates ad expiry dates and active status before display
- Graceful fallback when no ads are available

### ✅ **Complete Tracking System**
- **Impression Tracking**: Automatically tracks when ad is displayed
- **Click Tracking**: Records user interactions with ads
- **API Integration**: Uses `/api/v1/ads/{id}/impression` and `/api/v1/ads/{id}/click` endpoints

### ✅ **Rich Ad Content Support**
- **Dynamic Titles**: API-driven ad titles with fallback
- **Descriptions**: Flexible ad descriptions from backend
- **Images**: Support for ad images with error handling
- **Custom Buttons**: Configurable button text and actions
- **Target URLs**: Support for click-through actions

### ✅ **Professional UI/UX**
- Modern popup design with backdrop blur
- Responsive image loading with error states
- Clean close button functionality
- Loading states and error handling

## 📊 API Integration Details

### **Ad Data Structure**
The API returns ads in the following format:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Special Medicare Enrollment",
      "description": "Save up to $500/year on Medicare premiums!",
      "image_url": "/uploads/ads/medicare-special-offer.jpg",
      "target_url": "https://medicare.gov/special-enrollment",
      "button_text": "Learn More",
      "is_active": true,
      "expires_at": "2025-12-31T23:59:59Z",
      "created_at": "2025-12-01T10:00:00Z",
      "updated_at": "2025-12-01T10:00:00Z"
    }
  ]
}
```

### **Tracking Endpoints**
1. **Impression Tracking**
   ```
   POST /api/v1/ads/{id}/impression
   ```
   - Called automatically when ad is displayed
   - No request body required
   - Returns success confirmation

2. **Click Tracking**
   ```
   POST /api/v1/ads/{id}/click
   ```
   - Called when user clicks ad button
   - No request body required
   - Returns success confirmation

## 🏗️ Implementation Details

### **AdModel Class**
```dart
class AdModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? targetUrl;
  final String buttonText;
  final bool isActive;
  final DateTime? expiresAt;
  
  // Helper methods
  bool get isCurrentlyActive;
  String? get displayImageUrl;
  String get safeButtonText;
  bool get hasValidContent;
}
```

### **Dashboard Integration**
```dart
class _DashboardScreenState extends State<DashboardScreen> {
  final _api = MedicareApiService.instance;
  AdModel? _currentAd;
  bool _showPopupAd = false;

  @override
  void initState() {
    super.initState();
    _loadAds(); // Load ads from API
  }

  void _loadAds() async {
    // Fetch ads from API
    // Convert to AdModel
    // Display popup if valid ad exists
    // Track impression automatically
  }
}
```

## 🎨 Visual Features

### **Popup Ad Layout**
- **Header**: Close button (top-right)
- **Image**: Optional ad image with fallback handling
- **Title**: Bold, prominent ad title
- **Description**: Supporting text with proper styling
- **Action Button**: Customizable button with tracking

### **Image Handling**
- Automatic base URL resolution for relative paths
- Error state with placeholder icon
- Responsive sizing (120px height, full width)
- Rounded corners for modern appearance

### **Interaction Flow**
1. User opens dashboard
2. App fetches active ads from API
3. First valid ad displays as popup
4. Impression is automatically tracked
5. User sees rich ad content
6. User can close ad or click action button
7. Click tracking is recorded
8. Target URL action is handled (future enhancement)

## 🔄 Workflow Integration

### **MedicareApiService Integration**
The popup ad system leverages the centralized API service:
```dart
final _api = MedicareApiService.instance;

// Get active ads
final adsResponse = await _api.ads.getActiveAds();

// Track impression
await _api.ads.trackAdImpression(adId);

// Track click
await _api.ads.trackAdClick(adId);
```

## 🛡️ Error Handling

### **API Failures**
- Network errors are caught and logged
- App continues to function without ads if API fails
- No user-facing errors for ad loading failures

### **Image Loading**
- Broken images show placeholder icon
- No app crashes from image loading failures
- Graceful degradation to text-only ads

### **Data Validation**
- Checks ad expiry dates before display
- Validates required fields (title, description)
- Filters inactive or expired ads automatically

## 📱 Usage Examples

### **Basic Ad Display**
```dart
// In dashboard initState
_loadAds(); // Automatically handles everything

// Ad will appear if:
// - API returns active ads
// - Ad is not expired
// - Ad has valid content
// - No previous errors occurred
```

### **Manual Ad Management**
```dart
// Close ad programmatically
setState(() => _showPopupAd = false);

// Check if ad should display
if (ad.isCurrentlyActive && ad.hasValidContent) {
  // Display ad
}

// Handle ad click with tracking
await _api.ads.trackAdClick(ad.id);
```

## 🚀 Future Enhancements

### **Planned Features**
1. **Multiple Ad Formats**: Banner ads, interstitial ads
2. **Ad Scheduling**: Time-based ad display rules
3. **User Targeting**: Personalized ads based on user profile
4. **A/B Testing**: Multiple ad variants with performance tracking
5. **Rich Media**: Video ads, interactive content
6. **Frequency Capping**: Limit ad display frequency per user

### **Integration Opportunities**
1. **Deep Linking**: Navigate to specific app screens from ads
2. **Plan Recommendations**: Ads for relevant Medicare plans
3. **Callback Integration**: Ads that trigger callback requests
4. **Questionnaire Promotion**: Ads encouraging questionnaire completion

## 🎯 Business Benefits

### **For Medicare Providers**
- **Targeted Promotion**: Reach users actively browsing Medicare options
- **Performance Tracking**: Detailed impression and click analytics
- **Cost Effective**: Direct integration without third-party ad networks
- **Brand Control**: Full control over ad content and presentation

### **For Users**
- **Relevant Content**: Ads tailored to Medicare needs
- **Non-Intrusive**: Single popup per session
- **Valuable Offers**: Special enrollment periods and savings opportunities
- **Easy Dismissal**: Simple close functionality

## 📊 Analytics & Reporting

### **Available Metrics**
- **Impression Count**: How many times ads are displayed
- **Click-Through Rate**: Percentage of impressions that result in clicks
- **Ad Performance**: Individual ad effectiveness tracking
- **User Engagement**: Time spent viewing ads

### **Data Flow**
1. Ad displayed → Impression tracked in database
2. User clicks → Click tracked in database
3. Analytics dashboard shows performance metrics
4. Ad campaigns can be optimized based on data

The popup ad system is now fully integrated with the API and provides a professional, trackable advertising platform for the Medicare app! 🎉