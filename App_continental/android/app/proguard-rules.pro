# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep annotation
-keepattributes *Annotation*

# Keep Dart generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Suppress R8 warnings for missing Google Play Core classes
# These are referenced by Flutter's deferred components but not used in this app
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
