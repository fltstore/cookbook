import 'package:async/async.dart';
import 'package:cookbook/model/data.dart';
import 'package:cookbook/parse.dart';
import 'package:cookbook/shared/helper.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

typedef ColCookList = Map<String, List<Before>>;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CookParseDataModel? data;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final TextEditingController _textEditingController = TextEditingController();

  bool showLoading = true;

  String searchText = "";

  @override
  void initState() {
    beforeHook();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(handleSearch);
    _textEditingController.dispose();
    super.dispose();
  }

  beforeHook() async {
    _textEditingController.addListener(handleSearch);
    await loadReadme();
    showLoading = false;
    setState(() {});
  }

  handleSearch() {
    var text = _textEditingController.text;
    searchText = text;
    setState(() {});
  }

  loadReadme() async {
    await Future.delayed(const Duration(seconds: 2));
    String raw = await _memoizer.runOnce(() async {
      return await rootBundle.loadString(joinMarkdownPath('README.md'));
    });
    data = tryParse(raw);
    setState(() {});
  }

  tryParse(String raw) {
    CoreParse coreParse = CoreParse();
    coreParse.parseMetaData(raw);
    return coreParse.data;
  }

  List<Before> easyFilterWithBefore(List<Before> old) {
    if (searchText.isEmpty) return old;
    return old.where((element) {
      return element.title.contains(searchText);
    }).toList();
  }

  ColCookList easyFilterWithColData(ColCookList old) {
    if (searchText.isEmpty) return old;
    ColCookList output = {};
    for (var element in old.entries) {
      var K = element.key;
      var V = element.value;
      if (output[K] == null) {
        output[K] = [];
      }
      var matchResult = V.where((element) {
        return element.title.contains(searchText);
      }).toList();
      output[K]!.addAll(matchResult);
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("程序员做饭指南"),
      ),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            if (showLoading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            var before = easyFilterWithBefore(data!.before);
            var colData = easyFilterWithColData(data!.data);
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),
                  CupertinoSearchTextField(
                    controller: _textEditingController,
                  ),
                  const SizedBox(height: 6.0),
                  Expanded(
                    child: OverflowBox(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (before.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.2,
                                      vertical: 12.0,
                                    ),
                                    child: Text(
                                      "做菜之前",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoTheme.of(context)
                                          .barBackgroundColor,
                                      borderRadius: BorderRadius.circular(7.2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9.0,
                                      horizontal: 3.0,
                                    ),
                                    child: Column(
                                      children: List.generate(
                                        before.length,
                                        (index) => CupertinoListTile(
                                          onTap: () {
                                            var curr = before[index];
                                            var link = curr.link;
                                            context.push('/detail?link=$link');
                                          },
                                          dense: true,
                                          title: Text(
                                            before[index].title,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: colData.entries.map((e) {
                                if (e.value.isEmpty) return const SizedBox();
                                String category =
                                    e.key.replaceFirst('### ', '');
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.2,
                                        vertical: 12.0,
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: CupertinoTheme.of(context)
                                            .barBackgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(7.2),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 9.0,
                                        horizontal: 3.0,
                                      ),
                                      child: Column(
                                        children: e.value.map((sub) {
                                          return CupertinoListTile(
                                            dense: true,
                                            onTap: () {
                                              var link = sub.link;
                                              context
                                                  .push('/detail?link=$link');
                                            },
                                            title: Text(sub.title),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
