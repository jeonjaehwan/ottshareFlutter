class InfoOfLeaderAndOtt {

  final bool isLeader;
  final int selectedOtt;

  InfoOfLeaderAndOtt({
    required this.isLeader,
    required this.selectedOtt,
  });

  factory InfoOfLeaderAndOtt.fromJson(Map<String, dynamic> json) {
    int ottIndex = 0;

    switch (json['ottType']) {
      case "NETFLIX":
        ottIndex = 0;
        break;
      case "TVING":
        ottIndex = 1;
        break;
      case "WAVVE":
        ottIndex = 2;
        break;
    }

    return InfoOfLeaderAndOtt(
        isLeader: json['isLeader'] as bool? ?? false,
        selectedOtt: ottIndex
    );
  }
}