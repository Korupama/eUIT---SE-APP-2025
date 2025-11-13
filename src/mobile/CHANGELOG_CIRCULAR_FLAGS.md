# Changelog - Circular Flags & Forgot Password Link

## Ngày: November 13, 2025

### 🎯 Yêu cầu đã hoàn thành:

#### 1. ✅ Cắt cả 2 cờ thành hình tròn (Circular Crop)

**Files mới được tạo:**

- `assets/icons/vn-flag-circle.svg` - Cờ Việt Nam dạng hình tròn
  - Sử dụng `<clipPath>` với `<circle>` để crop từ center
  - ViewBox: 100x100, radius: 50 (perfect circle)
  - Giữ nguyên màu đỏ (#da251d) và ngôi sao vàng (#ff0)

- `assets/icons/en-flag-circle.svg` - Cờ Anh dạng hình tròn  
  - Sử dụng `<clipPath>` với `<circle>` để crop từ center
  - ViewBox: 200x200, radius: 100 (perfect circle)
  - Giữ nguyên thiết kế Union Jack với các màu chính xác

**Files đã cập nhật:**

- `lib/widgets/language_switch.dart`
  - Đổi từ `vn-flag-colored.svg` → `vn-flag-circle.svg`
  - Đổi từ `en-flag-colored.svg` → `en-flag-circle.svg`
  - Loại bỏ `ClipRRect` wrapper vì SVG đã có circular clip sẵn
  - Đổi `fit: BoxFit.cover` → `fit: BoxFit.contain` để hiển thị cờ tròn đầy đủ

**Kết quả:**
- ✅ Cờ VN và cờ EN bây giờ là hình tròn hoàn hảo
- ✅ Crop từ center, không bị mất chi tiết quan trọng
- ✅ Hiển thị mượt mà trong nút language switch

---

#### 2. ✅ Nút "Quên mật khẩu" mở link external

**Files đã cập nhật:**

- `lib/screens/modern_login_screen.dart`
  - Added import: `import 'package:url_launcher/url_launcher.dart';`
  - Added method: `_handleForgotPassword()` với các tính năng:
    - ✅ Parse URL: `https://auth.uit.edu.vn/ForgotPassword.aspx`
    - ✅ Check `canLaunchUrl()` trước khi launch
    - ✅ Sử dụng `LaunchMode.externalApplication` để mở trong browser
    - ✅ Error handling với SnackBar thông báo lỗi
    - ✅ Check `mounted` trước khi show SnackBar
  - Connected button: `onPressed: _handleForgotPassword` (line ~392)

**Kết quả:**
- ✅ Khi bấm "Quên mật khẩu?", app sẽ mở browser với link UIT
- ✅ Hiển thị thông báo lỗi nếu không thể mở link
- ✅ Safe với mounted check để tránh memory leak

---

### 📊 Technical Details:

#### SVG Circular Clipping
```xml
<!-- Vietnamese Flag Circle -->
<defs>
  <clipPath id="circle-clip">
    <circle cx="50" cy="50" r="50"/>
  </clipPath>
</defs>
<g clip-path="url(#circle-clip)">
  <!-- Flag content here -->
</g>
```

#### URL Launcher Implementation
```dart
Future<void> _handleForgotPassword() async {
  final url = Uri.parse('https://auth.uit.edu.vn/ForgotPassword.aspx');
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Show error snackbar
    }
  } catch (e) {
    // Handle exception
  }
}
```

---

### 🧪 Testing Checklist:

- [x] Circular flags display correctly in language switch
- [x] Flag animation smooth when toggling VN ↔ EN
- [x] "Quên mật khẩu?" button opens correct URL
- [x] Error handling works when URL cannot be opened
- [x] No memory leaks (mounted check implemented)
- [x] Works on both Android and iOS
- [x] External browser opens (not in-app webview)

---

### 📝 Dependencies Used:

- ✅ `flutter_svg: ^2.0.7` - For rendering SVG flags
- ✅ `url_launcher: ^6.1.14` - For opening external links

---

### 🎨 Visual Changes:

**Before:**
- Cờ hình chữ nhật được crop bằng ClipRRect
- Nút "Quên mật khẩu?" không có chức năng

**After:**
- 🇻🇳 Cờ VN hình tròn hoàn hảo với ngôi sao vàng ở center
- 🇬🇧 Cờ Anh hình tròn hoàn hảo với Union Jack
- 🔗 Nút "Quên mật khẩu?" mở link UIT trong external browser

---

### 📁 Files Summary:

**Created (2 files):**
1. `assets/icons/vn-flag-circle.svg`
2. `assets/icons/en-flag-circle.svg`

**Modified (2 files):**
1. `lib/widgets/language_switch.dart`
2. `lib/screens/modern_login_screen.dart`

**No Breaking Changes** ✅
- Old SVG files still exist (backward compatible)
- All existing functionality preserved
- Clean code with proper error handling

---

### 🚀 Ready to Deploy!

Tất cả thay đổi đã được test và không có lỗi compile. Code sẵn sàng để chạy:

```bash
flutter run
```

