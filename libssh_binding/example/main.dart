import 'package:ffi/ffi.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'dart:ffi' as ffi;
import 'dart:io';

/*dynamic exec_ssh_command(Libssh lib, ssh_session
	session, ffi.Pointer<Utf8> command) {
	var receive = "";
	int rc, nbytes;
	
	ssh_channel channel = lib.ssh_channel_new(session);
	if (channel == NULL)
		return NULL;

	rc = ssh_channel_open_session(channel);
	if (rc != SSH_OK) {
		ssh_channel_free(channel);
		return NULL;
	}

	rc = ssh_channel_request_exec(channel, command);
	if (rc != SSH_OK) {
		ssh_channel_close(channel);
		ssh_channel_free(channel);		
		return NULL;
	}

  char buffer[256];
	nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
	while (nbytes > 0)
	{
		if (fwrite(buffer, 1, nbytes, stdout) != nbytes)
		{
			ssh_channel_close(channel);
			ssh_channel_free(channel);
			return NULL;
		}
		nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0);
	}

	if (nbytes < 0)
	{
		ssh_channel_close(channel);
		ssh_channel_free(channel);
		return NULL;
	}

	ssh_channel_send_eof(channel);
	ssh_channel_close(channel);
	ssh_channel_free(channel);

	return receive;
}
*/
int main() {
  //final kernel32 = DynamicLibrary.open('kernel32.dll');
  //print(kernel32);
  final dll = ffi.DynamicLibrary.open("ssh.dll");
  var libssh = Libssh(dll);

  var host = "192.168.133.13";
  var port = 22;
  var password = "Ins257257";
  var username = "isaque.neves";

  // Abra a sessão e defina as opções
  var my_ssh_session = libssh.ssh_new();
  libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_HOST, stringToNativeVoid(host));
  libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_PORT, intToNativeVoid(port));
  // Conecte-se ao servidor
  var rc = libssh.ssh_connect(my_ssh_session);
  if (rc != SSH_OK) {
    print('Error connecting to host: $host\n');
  }

  rc = libssh.ssh_userauth_password(my_ssh_session, stringToNativeInt8(username), stringToNativeInt8(password));
  if (rc != ssh_auth_e.SSH_AUTH_SUCCESS) {
    var error = libssh.ssh_get_error(my_ssh_session.cast());
    print("Error authenticating with password:$error\n");
    //ssh_disconnect(my_ssh_session);
    //ssh_free(my_ssh_session);
  }

  print(rc);
  sleep(Duration(minutes: 50));

  return 0;
}
