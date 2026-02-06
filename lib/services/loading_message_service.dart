class LoadingMessageService {
  static const List<String> thinkingMessages = [
    'is thinking...',
    'is pondering...',
    'is analyzing...',
    'is considering...',
    'is processing...',
    'is working on it...',
    'is figuring it out...',
    'is contemplating...',
    'is reasoning...',
    'is crafting a response...',
  ];

  static const List<String> deepThinkingMessages = [
    'is deep reasoning...',
    'is thinking deeply...',
    'is analyzing in depth...',
    'is doing heavy lifting...',
    'is crunching the data...',
    'is exploring possibilities...',
    'is diving deep...',
    'is connecting the dots...',
    'is synthesizing insights...',
    'is reasoning step by step...',
  ];

  static const List<String> longWaitMessages = [
    'is still working...',
    'is almost there...',
    'just a bit longer...',
    'working hard on this...',
    'taking extra care...',
    'putting finishing touches...',
    'wrapping things up...',
    'hang tight...',
  ];

  static List<String> shuffledMessages({
    bool isDeepResearch = false,
    bool isLongWait = false,
  }) {
    final source = isLongWait
        ? longWaitMessages
        : (isDeepResearch ? deepThinkingMessages : thinkingMessages);
    return List<String>.from(source)..shuffle();
  }

  static String buildMessage({
    required String aiName,
    required List<String> shuffledMessages,
    required int index,
  }) {
    return '$aiName ${shuffledMessages[index]}';
  }
}
