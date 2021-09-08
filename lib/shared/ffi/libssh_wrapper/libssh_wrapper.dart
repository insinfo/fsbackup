import 'dart:ffi';

typedef TemperatureFunction = Double Function();
typedef TemperatureFunctionDart = double Function();

class LibSSHWrapper {
  TemperatureFunctionDart _getTemperature;
  int Function(int x, int y) nativeAdd;
  LibSSHWrapper() {
    final dll = DynamicLibrary.open('ssh.dll');
    //_getTemperature = dll.lookupFunction<TemperatureFunction, TemperatureFunctionDart>('get_temperature');

    nativeAdd = dll.lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add").asFunction();
  }

  double getTemperature() => _getTemperature();
}
