import 'package:cookbook/shared/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.link,
  });

  final String link;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String get link => joinMarkdownPath(widget.link);

  String data = "";

  @override
  void initState() {
    beforeHook();
    super.initState();
  }

  beforeHook() async {
    var $data = await rootBundle.loadString(link);
    data = $data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: SafeArea(
        child: Markdown(
          data: data,
          styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
          imageBuilder: (uri, title, alt) {
            var absFile = uri.path;
            var target = Uri.decodeComponent(absFile);
            debugPrint(target);
            var path = join('assets/HowToCook', widget.link, "..", target);
            return Image.asset(path);
          },
        ),
      ),
    );
  }
}
