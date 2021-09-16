import 'dart:ffi';
import 'dart:io';
import 'package:libssh_binding/src/extensions/exec_command_extension.dart';
import 'package:libssh_binding/src/extensions/scp_extension.dart';
import 'package:libssh_binding/src/extensions/sftp_extension.dart';
import 'package:libssh_binding/src/models/directory_item.dart';
import 'package:libssh_binding/src/utils.dart';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/libssh_binding.dart';
import 'package:libssh_binding/src/sftp_binding.dart';

/// high-level wrapper on top of libssh binding - The SSH library!
/// libssh is a multiplatform C library implementing the SSHv2 protocol on client and server side.
/// With libssh, you can remotely execute programs, transfer files, use a secure and transparent tunnel
/// https://www.libssh.org/
class LibsshWrapper {
  late ssh_session my_ssh_session;
  late LibsshBinding libsshBinding;
  String host;
  String? username;
  String? password;
  int port = 22;
  bool isConnected = false;
  bool verbosity = false;

  /// if defaultDllPath == true get ddl from default sytem folder Exemple: in windows c:\windows\Sytem32
  /// else get dll from Directory.current.path
  LibsshWrapper(this.host,
      {this.username,
      this.password,
      this.port = 22,
      bool defaultDllPath = true,
      DynamicLibrary? inDll,
      String ddlname = 'ssh.dll',
      this.verbosity = false}) {
    var libraryPath = defaultDllPath ? ddlname : path.join(Directory.current.path, ddlname); //'libssh_compiled',
    final dll = inDll == null ? DynamicLibrary.open(libraryPath) : inDll;
    libsshBinding = LibsshBinding(dll);
    my_ssh_session = initSsh();
  }

  /// initialize ssh - Open the session and set the options
  ssh_session initSsh() {
    // Open the session and set the options
    var my_session = libsshBinding.ssh_new();
    libsshBinding.ssh_options_set(my_session, ssh_options_e.SSH_OPTIONS_HOST, stringToNativeVoid(host));
    libsshBinding.ssh_options_set(my_session, ssh_options_e.SSH_OPTIONS_PORT, intToNativeVoid(port));
    if (verbosity == true) {
      libsshBinding.ssh_options_set(
          my_session, ssh_options_e.SSH_OPTIONS_LOG_VERBOSITY, intToNativeVoid(SSH_LOG_PROTOCOL));
    }
    libsshBinding.ssh_options_set(my_session, ssh_options_e.SSH_OPTIONS_USER, stringToNativeVoid(username!));
    return my_session;
  }

  /// Connect to SSH server
  void connect() {
    var rc = libsshBinding.ssh_connect(my_ssh_session);
    if (rc != SSH_OK) {
      isConnected = false;
      throw Exception('Error connecting to host: $host \n');
    }
    rc = libsshBinding.ssh_userauth_password(
        my_ssh_session, stringToNativeInt8(username!), stringToNativeInt8(password!));
    if (rc != ssh_auth_e.SSH_AUTH_SUCCESS) {
      isConnected = false;
      throw Exception(
          "Error authenticating with password: ${libsshBinding.ssh_get_error(my_ssh_session.cast()).cast<Utf8>().toDartString()}\n");
    }
    isConnected = true;
  }

  /// check if session started and connection is open
  void isReady() {
    if (my_ssh_session.address == nullptr) {
      throw Exception('SSH session is not initialized');
    }
    if (isConnected == false) {
      throw Exception('SSH is not connected');
    }
  }

  /// downloads a file from an SFTP/SCP server
  Future<void> scpDownloadFileTo(String fullRemotePathSource, String fullLocalPathTarget,
      {void Function(int, int)? callbackStats}) async {
    isReady();
    await libsshBinding.scpDownloadFileTo(my_ssh_session, fullRemotePathSource, fullLocalPathTarget,
        callbackStats: callbackStats);
  }

  /// download one file via SFTP of remote server
  Future<void> sftpDownloadFileTo(String fullRemotePath, String fullLocalPath,
      {Pointer<sftp_session_struct>? inSftp}) async {
    isReady();
    await libsshBinding.sftpDownloadFileTo(my_ssh_session, fullRemotePath, fullLocalPath, inSftp: inSftp);
  }

  /// execute only one command
  /// to execute several commands
  /// start a scripting language
  /// example:
  /// execCommandSync(session,"cd /tmp; mkdir mytest; cd mytest; touch mytest");
  String execCommandSync(
    String command, {
    Allocator allocator = malloc,
  }) {
    isReady();
    return libsshBinding.execCommandSync(my_ssh_session, command, allocator: allocator);
  }

  /// experimental as it may not be able to detect the prompt
  /// execute commands in the interactive shell the order of execution is based on the order of the command list
  /// and return a list with the response of each command in the order of execution
  List<String> execCommandsInShell(List<String> commands) {
    return libsshBinding.execCommandsInShell(my_ssh_session, commands);
  }

  /// Listing the contents of a directory
  List<DirectoryItem> sftpListDir(String fullRemotePath) {
    return libsshBinding.sftpListDir(my_ssh_session, fullRemotePath);
  }

  Future<void> scpDownloadDirectory(String remoteDirectoryPath, String fullLocalDirectoryPathTarget) async {
    await libsshBinding.scpDownloadDirectory(my_ssh_session, remoteDirectoryPath, fullLocalDirectoryPathTarget);
  }

  void disconnect() {
    libsshBinding.ssh_disconnect(my_ssh_session);
  }

  void dispose() {
    disconnect();
    libsshBinding.ssh_free(my_ssh_session);
  }
}
