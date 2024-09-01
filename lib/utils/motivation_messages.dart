import 'dart:math';

class MotivationMessages {
  static String getRandomMessage(String username) {
    final messages = [
      "$username님, 오늘 하루도 건강한 선택을 하고 계시네요!",
      "$username님의 의지력이 담배보다 강합니다.",
      "$username님, 금연은 어렵지만 그만큼 가치 있는 도전입니다.",
      "한 번에 하나씩, $username님은 변화를 만들어가고 있어요.",
      "$username님의 건강한 삶을 위한 선택을 응원합니다.",
      "매 순간 $username님은 더 나은 삶을 선택하고 있습니다.",
      "$username님, 담배 없는 생활, 당신은 해낼 수 있습니다!",
      "$username님의 노력이 더 나은 미래를 만들고 있어요.",
    ];

    final random = Random();
    return messages[random.nextInt(messages.length)];
  }
}
