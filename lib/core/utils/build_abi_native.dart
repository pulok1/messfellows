import 'dart:ffi';

/// True when this copy is the 32-bit ARM build (messfellows-32bit.apk), so
/// an in-app update downloads the same flavour instead of a 64-bit APK the
/// phone can't run.
bool get isArm32Android => Abi.current() == Abi.androidArm;
