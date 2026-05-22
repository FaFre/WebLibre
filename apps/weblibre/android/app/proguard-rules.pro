-dontobfuscate

####################################################################################################
# GeckoView built-ins
####################################################################################################

-dontwarn org.mozilla.geckoview.**

####################################################################################################
# Remove debug logs from release builds
####################################################################################################
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}

####################################################################################################
# Mozilla Application Services
####################################################################################################

-keep class mozilla.appservices.** { *; }

####################################################################################################
# Dependency annotations referenced from bundled ExoPlayer classes
####################################################################################################

-dontwarn org.checkerframework.checker.nullness.qual.EnsuresNonNull
-dontwarn org.checkerframework.checker.nullness.qual.EnsuresNonNullIf
-dontwarn org.checkerframework.checker.nullness.qual.RequiresNonNull
