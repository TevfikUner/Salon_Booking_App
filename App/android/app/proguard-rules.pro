# R8 kuralları — release derlemesinde (isMinifyEnabled = true) uygulanır.
# Flutter ve FlutterFire eklentileri çoğu kuralı kendi consumer-rules dosyalarıyla getirir;
# burada yalnızca yansıma (reflection) ile erişilen ve güvenli tarafta kalmak istediğimiz sınıflar var.

# Flutter motoru
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core (Flutter deferred components referansı; kullanılmıyor)
-dontwarn com.google.android.play.core.**

# Firebase / Google Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Crashlytics: okunabilir yığın izleri için satır numaraları ve özel istisnalar
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-renamesourcefileattribute SourceFile

# Konum (geolocator) ve dosya seçici eklentileri
-keep class com.baseflow.geolocator.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
