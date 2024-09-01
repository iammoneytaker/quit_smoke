class HealthBenefits {
  static String getBenefitForDuration(Duration duration) {
    if (duration.inMinutes < 20) {
      return '20분 이내: 혈압과 맥박이 정상으로 돌아가기 시작합니다.';
    } else if (duration.inHours < 8) {
      return '8시간 이내: 혈중 일산화탄소 수치가 정상으로 돌아갑니다.';
    } else if (duration.inHours < 24) {
      return '24시간 이내: 심장마비의 위험이 감소하기 시작합니다.';
    } else if (duration.inHours < 48) {
      return '48시간 이내: 후각과 미각이 회복되기 시작합니다.';
    } else if (duration.inDays < 3) {
      return '72시간 이내: 기관지가 이완되어 호흡이 더 쉬워집니다.';
    } else if (duration.inDays < 14) {
      return '2주 이내: 폐 기능이 향상되어 운동이 더 쉬워집니다.';
    } else if (duration.inDays < 90) {
      return '3개월 이내: 순환이 개선되고 폐 기능이 30% 향상됩니다.';
    } else {
      return '1년 이상: 심장병 위험이 흡연자의 절반으로 감소합니다.';
    }
  }
}
