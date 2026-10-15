// Which CPU flavour of the APK is running — dart:ffi doesn't exist on the
// web build, hence the conditional import.
export 'build_abi_stub.dart' if (dart.library.ffi) 'build_abi_native.dart';
