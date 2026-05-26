####################################################################################################
# tor-android JNI
####################################################################################################

# libtor accesses these fields and native methods by their Java names/signatures.
# Release R8 shrinking can otherwise remove private fields that are only used from JNI.
-keep class org.torproject.jni.TorService {
    long torConfiguration;
    int torControlFd;
    native <methods>;
}
