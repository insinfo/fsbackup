import 'package:fsbackup_shared/src/utils/windows/process_helper.dart';

///
/// EXPERIMENTAL
///
/// This class is likely to change/replaced.
class ProcessHelper {
  /// returns the name of the process for the given pid.
  static String getProcessName(int pid) {
    return getWindowsProcessName(pid);
  }

  /// Returns true a the process with the given [name]
  /// is currently running.
  ///
  static bool isProcessRunning(String name) {
    for (final pd in getProcesses()) {
      if (pd.name == name) {
        return true;
      }
    }

    return false;
  }

  static int countProcessInstance(String name) {
    var count = 0;
    for (final pd in getProcesses()) {
      if (pd.name == name) {
        count++;
      }
    }
    return count;
  }

  /// Returns a list of running processes.
  ///
  /// Currently this is only supported on Windows and Linux.
  static List<ProcessDetails> getProcesses() {
    return getWindowsProcesses();
  }
}

/// Represents a running Process.
/// As processes are transitory by the time you access
/// these details the process may no longer be running.
//@immutable
class ProcessDetails {
  /// Create a ProcessDetails object that represents
  /// a running process.
  ProcessDetails(this.pid, this.name, String memory) {
    _memory = int.tryParse(memory) ?? 0;
  }

  /// The process id (pid) of this process
  int pid;

  /// The process name.
  String name;

  /// The amount of virtual memory the process is currently consuming
  int _memory;

  /// The units the [memory] is defined in the process is currently consuming
  String memoryUnits;

  /// Get the virtual memory used by the processes.
  /// May return zero if we are unable to determine the memory used.
  int get memory => _memory;

  /// Compares to [ProcessDetails] via their pid.
  int compareTo(ProcessDetails other) => pid - other.pid;

  @override
  bool operator ==(covariant ProcessDetails other) => pid == other.pid;

  @override
  int get hashCode => pid.hashCode;
}
