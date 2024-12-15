class Content {
  final int nr;
  final String title;
  final String ques;
  final String ans;
  final String topic;
  final String sTopic;
  final String? qImgPath; // 질문 이미지 파일명
  final String? aImgPath; // 답변 이미지 파일명

  Content({
    required this.nr,
    required this.title,
    required this.ques,
    required this.ans,
    required this.topic,
    required this.sTopic,
    this.qImgPath,
    this.aImgPath,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    const basePath = 'assets/images/'; // 경로 자동 추가
    return Content(
      nr: json['Nr'],
      title: json['Title'],
      ques: json['Ques'],
      ans: json['Ans'],
      topic: json['Topic'],
      sTopic: json['S_Topic'],
      qImgPath:
          json['Q_Img_path'] != null ? basePath + json['Q_Img_path'] : null,
      aImgPath:
          json['A_Img_path'] != null ? basePath + json['A_Img_path'] : null,
    );
  }
}
