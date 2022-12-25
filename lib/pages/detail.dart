import 'package:cookbook/shared/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
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
          shrinkWrap: true,
          data: data,
          styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
          builders: {
            "code": CodeElementBuilder(
              context: context,
            ),
          },
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

class CodeElementBuilder extends MarkdownElementBuilder {
  CodeElementBuilder({
    required this.context,
  });

  final BuildContext context;

  @override
  visitElementAfter(element, preferredStyle) {
    List<md.Node> children = element.children ?? [];
    if (children.isEmpty) return const SizedBox.shrink();
    md.Text text = children[0] as md.Text;
    String str = text.text;
    var theme = CupertinoTheme.of(context);
    return Text(
      str,
      style: preferredStyle!.copyWith(
        color: theme.primaryColor,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
