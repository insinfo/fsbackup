class CommandLinePipeOptions {
  /// The pipe name used to communicate command line switches. If this is not provided,
  /// the application name (and possibly the path, depending on OS) will be used.
  String pipeName;

  /// Optional log writer.
  dynamic logger;

  /// Messages are written to stdout when true. Default is false.
  bool logToConsole = false;

  /// Settings for which the defaults are normally adequate.
  AdvancedOptions advanced = AdvancedOptions();
}

class AdvancedOptions {
  /// Typically, running an application with no switches is used to start the application with
  /// default settings. In that case, if an instance is already running, the new instance should
  /// exit. This is true by default, which generates an exception. If false, no exception is thrown,
  /// but there will be console and/or log output, depending on the configuration.
  bool throwIfRunning = true;

  /// Milliseconds to wait for the attempt to connect to a running instance. Defaults to 100ms.
  int pipeConnectionTimeout = 100;

  /// Can be specified in code, if necessary. Defaults to the RS (record separator) control code, 0x0E or ASCII 14.
  String separatorControlCode = "\u0014";

  /// If the server thread encounters a fatal exception, it can auto-restart if this is true. Default is false,
  /// an exception will be logged and the process will be forcibly terminated.
  bool autoRestartServer = false;

  /// When a logger is provided, this determines the level of messages logged during normal operation. Options are
  /// Information, Debug, or Trace (aka Verbose in most logger systems). This setting is ignored for events logged
  /// as Warning, Error, or Critical (aka Fatal) level messages.
  // LogLevel messageLogLevel  = LogLevel.Debug;
  dynamic messageLogLevel = 'LogLevel.Debug';
}
