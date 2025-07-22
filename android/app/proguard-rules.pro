# 広告SDKクラスの保護 Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }

# 内部SDKクラスの保護 Keep all internal ads SDK classes
-keep class com.google.android.gms.internal.ads.** { *; }

# 	Kotlinメタデータ保護 Prevent stripping of Kotlin metadata (重要)
#-keep class kotlin.Metadata { *; }

# Keep annotations
#-keep @interface com.google.android.gms.common.annotation.KeepName
#-keep @com.google.android.gms.common.annotation.KeepName class *

# 警告非表示 Don't warn about missing parts of the Ads SDK
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.android.gms.internal.ads.**