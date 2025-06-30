import 'package:logger/logger.dart';

class _DebugLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    //Log all events
    return true;
  }
}

final loggerMemory = MemoryOutput(
  bufferSize: 255,
  secondOutput: ConsoleOutput(),
);
final logger = Logger(filter: _DebugLogFilter(), output: loggerMemory);
