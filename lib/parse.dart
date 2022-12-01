import 'package:cookbook/model/data.dart';
import 'package:markdown/markdown.dart' as md;

enum ParseFlags {
  skip,
  before,
  category,
}

typedef CookItem = List<Map<String, String>>;

class CoreParse {
  final String _cookBeforeSyb = "## 做菜之前";
  final String _cookStartSyb = "## 菜谱";

  ParseFlags _nowParseFlag = ParseFlags.skip;

  CookParseDataModel? cookParseDataModel;

  String _categoryCache = '';

  Map<String, CookItem> eachData = {};
  CookItem beforeData = [];

  md.Document document = md.Document();

  Map<String, String> _getLineTitleAndLink(String line) {
    List<md.Node> nodes = document.parseInline(line);
    md.Element node = nodes[1] as md.Element;
    String link = node.attributes['href'] ?? "";
    String title = (node.children?[0] as md.Text).text;
    return {
      "title": title,
      "link": link,
    };
  }

  _putData() {
    List<Before> before = beforeData.map((e) {
      return Before(
        link: e['link'] ?? "",
        title: e['title'] ?? "",
      );
    }).toList();
    Map<String, List<Before>> data = {};
    eachData.forEach((key, value) {
      data[key] = value.map((e) {
        return Before(
          link: e['link'] ?? "",
          title: e['title'] ?? "",
        );
      }).toList();
    });
    cookParseDataModel = CookParseDataModel(before: before, data: data);
  }

  CookParseDataModel get data {
    return cookParseDataModel as CookParseDataModel;
  }

  parseMetaData(String data) {
    List<String> list = data.split("\n").where((element) {
      var text = element.trim();
      return text.isNotEmpty;
    }).toList();
    for (var i = 0; i < list.length; i++) {
      var curr = list[i].trim();
      if (curr == _cookBeforeSyb) {
        _nowParseFlag = ParseFlags.before;
        continue;
      } else if (curr == _cookStartSyb) {
        _nowParseFlag = ParseFlags.skip;
        continue;
      }

      if (curr.startsWith("### ")) {
        _categoryCache = curr;
        _nowParseFlag = ParseFlags.category;
        continue;
      } else if (curr.startsWith("##")) {
        _nowParseFlag = ParseFlags.skip;
        continue;
      }

      Map<String, String>? instance;
      if (_nowParseFlag != ParseFlags.skip) {
        instance = _getLineTitleAndLink(curr);
      }

      switch (_nowParseFlag) {
        case ParseFlags.skip:
          continue;
        case ParseFlags.before:
          beforeData.add(instance!);
          break;
        case ParseFlags.category:
          if (eachData[_categoryCache] == null) {
            eachData[_categoryCache] = [];
          }
          eachData[_categoryCache]!.add(instance!);
          break;
      }
    }
    _putData();
  }
}
