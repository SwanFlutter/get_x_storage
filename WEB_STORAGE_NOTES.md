# ⚠️ Web Storage Important Notes

## مشکل localStorage در Flutter Web (Development Mode)

### 🔴 مشکل:
وقتی در **حالت debug** (`flutter run -d chrome`) کار می‌کنید، localStorage بعد از بستن مرورگر **پاک میشه**.

### 🤔 چرا؟
این رفتار **عادی Chrome در development mode** هست:
- Chrome در debug mode یک **session موقت** می‌سازه
- localStorage به این session وابسته هست
- وقتی app بسته میشه، session پاک میشه
- localStorage هم با session پاک میشه

### ✅ راه حل:

#### 1. **Production Build** (توصیه میشه):
```bash
flutter build web --release
cd build/web
python -m http.server 8000
```
بعد برو به `http://localhost:8000`

در production mode، localStorage **کاملاً کار می‌کنه** و داده‌ها persist میشن.

#### 2. **استفاده از Profile Mode**:
```bash
flutter run -d chrome --profile
```

#### 3. **Deploy کردن**:
وقتی app رو deploy می‌کنی (Firebase Hosting, Netlify, etc.), localStorage **بدون مشکل** کار می‌کنه.

### 📊 تست با سایر پکیج‌ها:

تست شده با:
- ✅ `get_storage` - همین مشکل رو داره
- ✅ `shared_preferences` - همین مشکل رو داره  
- ✅ `hive` - همین مشکل رو داره

**نتیجه:** این مشکل از **Chrome development mode** هست، نه از پکیج!

### 🧪 چطور تست کنیم؟

#### ❌ اشتباه (کار نمی‌کنه):
```
1. flutter run -d chrome
2. تم رو Dark کن
3. مرورگر رو ببند
4. دوباره flutter run -d chrome
5. تم Light هست ❌
```

#### ✅ درست (کار می‌کنه):
```
1. flutter build web --release
2. cd build/web
3. python -m http.server 8000
4. برو به http://localhost:8000
5. تم رو Dark کن
6. مرورگر رو ببند
7. دوباره باز کن
8. تم Dark هست ✅
```

### 🔍 چک کردن localStorage در DevTools:

1. F12 بزن
2. برو به **Application** > **Local Storage** > **localhost**
3. باید `GetStorage` key رو ببینی
4. value اش باید `{"isDarkMode":true}` باشه

### 📝 خلاصه:

- ❌ Debug mode: localStorage پاک میشه
- ✅ Production mode: localStorage persist میشه
- ✅ Deployed app: localStorage کاملاً کار می‌کنه
- این رفتار **عادی** Chrome هست
- همه پکیج‌های localStorage همین مشکل رو دارن
- پکیج `get_x_storage` **مشکلی نداره**!

### 🚀 نتیجه نهایی:

**پکیج کاملاً کار می‌کنه!** فقط باید در production mode تست کنی.
