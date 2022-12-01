class CookParseDataModel {

  CookParseDataModel({
    required this.before,
    required this.data,
  });

  final List<Before> before;
  final Map<String, List<Before>> data;

}

class Before {
  Before({
    required this.title,
    required this.link,
  });

  final String title;
  final String link;

  factory Before.fromMap(Map<String, dynamic> json) => Before(
        title: json["title"],
        link: json["link"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "link": link,
      };
}