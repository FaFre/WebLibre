-dontobfuscate

####################################################################################################
# Android and GeckoView built-ins
####################################################################################################

-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn org.mozilla.geckoview.**

# Raptor now writes a *-config.yaml file to specify Gecko runtime settings (e.g. the profile dir). This
# file gets deserialized into a DebugConfig object, which is why we need to keep this class
# and its members.
-keep class org.mozilla.gecko.util.DebugConfig { *; }

####################################################################################################
# kotlinx.coroutines: use the fast service loader to init MainDispatcherLoader by including a rule
# to rewrite this property to return true:
# https://github.com/Kotlin/kotlinx.coroutines/blob/8c98180f177bbe4b26f1ed9685a9280fea648b9c/kotlinx-coroutines-core/jvm/src/internal/MainDispatchers.kt#L19
#
# R8 is expected to optimize the default implementation to avoid a performance issue but a bug in R8
# as bundled with AGP v7.0.0 causes this optimization to fail so we use the fast service loader instead. See:
# https://github.com/mozilla-mobile/focus-android/issues/5102#issuecomment-897854121
#
# The fast service loader appears to be as performant as the R8 optimization so it's not worth the
# churn to later remove this workaround. If needed, the upstream fix is being handled in
# https://issuetracker.google.com/issues/196302685
####################################################################################################
-assumenosideeffects class kotlinx.coroutines.internal.MainDispatcherLoader {
    boolean FAST_SERVICE_LOADER_ENABLED return true;
}

####################################################################################################
# REMOVE all Log messages except warnings and errors
####################################################################################################
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int d(...);
}

####################################################################################################
# Mozilla Application Services
####################################################################################################

-keep class mozilla.appservices.** { *; }

####################################################################################################
# ViewModels
####################################################################################################

-keep class org.mozilla.fenix.**ViewModel { *; }

# Keep Android Lifecycle methods
# https://bugzilla.mozilla.org/show_bug.cgi?id=1596302
-keep class androidx.lifecycle.** { *; }

-dontwarn java.beans.BeanInfo
-dontwarn java.beans.FeatureDescriptor
-dontwarn java.beans.IntrospectionException
-dontwarn java.beans.Introspector
-dontwarn java.beans.PropertyDescriptor

####################################################################################################
# Checker Framework
####################################################################################################

-dontwarn org.checkerframework.checker.nullness.qual.EnsuresNonNull
-dontwarn org.checkerframework.checker.nullness.qual.EnsuresNonNullIf
-dontwarn org.checkerframework.checker.nullness.qual.RequiresNonNull
