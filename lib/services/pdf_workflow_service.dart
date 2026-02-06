import 'dart:async';

class PdfWorkflowService {
  static Timer startAutoConversionTimer({
    required int countdownSeconds,
    required void Function(int nextCountdown) onTick,
    required void Function() onComplete,
  }) {
    var countdown = countdownSeconds;
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      onTick(countdown);

      if (countdown <= 0) {
        timer.cancel();
        onComplete();
      }
    });
  }
}
