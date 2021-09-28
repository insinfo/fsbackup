import 'dart:io';

import 'package:fsbackup/services/command_line_pipe_options.dart';

class CommandLineSwitchServer {
  /// The defaults are appropriate for most needs, but can also be created or modified through code,
  /// or populated from any of the standard .NET configuration extension packages.
  static CommandLinePipeOptions options = CommandLinePipeOptions();

  /// Populated when TrySendArgs is invoked with the waitForReply flag set to true.
  static String queryResponse = '';

  /// <summary>
  /// Attempt to send any command-line switches to an already-running instance. If another
  /// instance is found but this instance was started without switches, the application will
  /// terminate. Leave the argument list null unless Program.Main needs to pre-process that
  /// data. When null, the command line will be retrieved from the system environment.
  static Future<bool> trySendArgs(List<String> arguments) async {
    if (options == null || options.advanced == null)
      throwOutput(Exception(
          "{nameof(CommandLineSwitchServer)}.{nameof(Options)} property must be configured before invoking {nameof(TrySendArgs)}"));

    queryResponse = '';

    // Use the provided arguments, or environment array 1+ (array 0 is the program name and/or pathname)
    /*var arguments = args ?? Environment.GetCommandLineArgs();
            if(args == null)
                arguments = arguments.Length == 1 ? new string[0] : arguments[1..];*/

    output("Switch list has {arguments.Length} elements, checking for a running instance on pipe \"{PipeName()}\"");

    // Is another instance already running?
    /* var client = new NamedPipeClientStream(".", PipeName(), PipeDirection.InOut);

    try {
      client.Connect(options.advanced.pipeConnectionTimeout);
    } catch (e) {
      output("No running instance found");
      return false;
    }*/

    output("Connected to switch pipe server");

    // Connected, abort if we don't have arguments to pass
    if (arguments.length == 0) {
      String err = "No arguments were provided to pass to the already-running instance";

      if (options.advanced.throwIfRunning) throwOutput(new Exception(err));

      outputLog('Error', err);
      exit(-1);
    }

    output("Sending switches to running instance");

    // Send argument list with control-code separators
    /* var message = '';
    for (var arg in arguments) message += arg + options.advanced.separatorControlCode;
    await writeString(client, message);

    output("Waiting for reply");
    queryResponse = await readString(client);*/

    output("Switches sent, this instance can terminate normally");
    return true;
  }

  //PipeStream
  static Future<String> readString(dynamic stream) async {
    return '';
  }

  //PipeStream
  static Future writeString(dynamic stream, String message) async {
    try {
      /*var messageBuffer = Encoding.ASCII.GetBytes(message);
                output("Sending {messageBuffer.Length} bytes");

                var sizeBuffer = BitConverter.GetBytes(messageBuffer.Length);
                await stream.WriteAsync(sizeBuffer, 0, sizeBuffer.Length);

                if (message.length > 0)
                    await stream.WriteAsync(messageBuffer, 0, messageBuffer.Length);

                stream.WaitForPipeDrain();*/
    } catch (ex) {
      outputLog('Warning', "$ex while writing stream");
    }
  }

  static void throwOutput(Exception ex) {
    //Output(LogLevel.Error, ex.Message);
    throw ex;
  }

  static void output(String message) {
    outputLog(options.advanced.messageLogLevel, message);
  }

  static void outputLog(dynamic level, String message) {
    //if (Options.LogToConsole || level > LogLevel.Warning)
    print(message);

    /*if (Options.Logger != null)
                Options.Logger.Log(level, message);*/
  }
}
