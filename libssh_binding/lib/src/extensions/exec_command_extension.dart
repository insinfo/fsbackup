import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/libssh.dart';

extension ExecSshCommandExtension on Libssh {
  String execCommand(ssh_session session, String command) {
    var cmd = command.toNativeUtf8();
    ssh_channel channel = ssh_channel_new(session);
    if (channel.address == nullptr.address) {
      throw Exception(
          'Error allocating ssh_channel session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var receive = "";
    var rc = ssh_channel_open_session(channel);
    if (rc != SSH_OK) {
      this.ssh_channel_free(channel);
      throw Exception(
          'Error on ssh_channel_open_session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    rc = ssh_channel_request_exec(channel, cmd.cast<Int8>());
    if (rc != SSH_OK) {
      ssh_channel_close(channel);
      ssh_channel_free(channel);
      throw Exception(
          'Error on ssh_channel_request_exec: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var bufferLength = 256;
    final buffer = malloc<Int8>(bufferLength); //	char buffer[256];
    int nbytes = 0;

    //ssh_channel_is_open : Retorna 0 se o canal estiver fechado, diferente de zero caso contrário.
    while ((ssh_channel_is_open(channel) != 0) && !(ssh_channel_is_eof(channel) != 0)) {
      var size = sizeOf<Int8>() * bufferLength;
      nbytes = ssh_channel_read(channel, buffer.cast(), size, 0);
      if (nbytes < 0) {
        break;
      }

      if (nbytes > 0) {
        receive += utf8.decode(buffer.asTypedList(nbytes));
      }
    }
    malloc.free(buffer);
    ssh_channel_send_eof(channel);
    ssh_channel_close(channel);
    ssh_channel_free(channel);

    return receive;
  }
}

/*extension StringUtf8Pointer on String {
  
  Pointer<Utf8> toNativeUtf8({Allocator allocator = malloc}) {
    final units = utf8.encode(this);
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}*/
