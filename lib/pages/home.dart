import 'dart:async';

import 'package:async/async.dart';
import 'package:cookbook/model/data.dart';
import 'package:cookbook/parse.dart';
import 'package:cookbook/shared/helper.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

typedef ColCookList = Map<String, List<Before>>;
typedef ValueChanged2<T, T1> = void Function(T value, T1 value2);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CookParseDataModel? data;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final TextEditingController _textEditingController = TextEditingController();

  List<String> ignoreCookBookItem = [];

  bool showLoading = true;

  bool showBefore = true;

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
    String raw = await _memoizer.runOnce(() async {
      return await rootBundle.loadString(joinMarkdownPath('README.md'));
    });
    data = tryParse(raw);
    setState(() {});
  }

  List<String> notInclude = [];

  tryParse(String raw) {
    CoreParse coreParse = CoreParse();
    coreParse.parseMetaData(raw);
    return coreParse.data;
  }

  handleShowFilter() async {
    ColCookList raw = data!.data;
    var ctx = await showCookBookModal(raw, ignoreCookBookItem);
    showBefore = ctx['before'];
    ignoreCookBookItem = ctx['undo'] as List<String>;
    setState(() {});
  }

  List<Before> easyFilterWithBefore(List<Before> old) {
    if (!showBefore) return [];
    if (searchText.isEmpty) return old;
    return old.where((element) {
      return element.title.contains(searchText);
    }).toList();
  }

  ColCookList easyFilterWithColData(ColCookList old) {
    if (ignoreCookBookItem.isNotEmpty) {
      old = easyPutColCookList(old, isIgnore: true);
    }
    if (searchText.isEmpty) return old;
    return easyPutColCookList(old);
  }

  ColCookList easyPutColCookList(ColCookList data, {bool isIgnore = false}) {
    ColCookList output = {};
    for (var element in data.entries) {
      var K = element.key;
      var V = element.value;
      if (output[K] == null) {
        output[K] = [];
      }
      if (isIgnore) {
        if (!ignoreCookBookItem.contains(K)) {
          output[K] = V;
        } else {
          continue;
        }
      } else {
        var matchResult = V.where((element) {
          return element.title.contains(searchText);
        }).toList();
        output[K]!.addAll(matchResult);
      }
    }
    return output;
  }

  Future<Map<String, dynamic>> showCookBookModal(
    ColCookList data,
    List<String> undo,
  ) {
    Completer<Map<String, dynamic>> completer = Completer();
    showCupertinoModalPopup(
      useRootNavigator: true,
      context: context,
      builder: (_) => CookBookPopup(
        showBefore: showBefore,
        data: data,
        undoInitValue: undo,
        onConfirm: (undo, showBefore) {
          completer.complete({"undo": undo, "before": showBefore});
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoSearchTextField(
                          controller: _textEditingController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Builder(builder: (context) {
                        var file = 'wan';
                        if (!isDarkMode) {
                          file += '_black';
                        }
                        file += '.png';
                        return GestureDetector(
                          onTap: handleShowFilter,
                          child: Image.asset(
                            "assets/$file",
                            width: 32,
                            height: 32,
                          ),
                        );
                      }),
                    ],
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

class CookBookPopup extends StatefulWidget {
  const CookBookPopup({
    super.key,
    this.undoInitValue = const [],
    this.showBefore = false,
    required this.data,
    required this.onConfirm,
  });

  final ColCookList data;
  final ValueChanged2<List<String>, bool> onConfirm;
  final List<String> undoInitValue;
  final bool showBefore;

  @override
  State<CookBookPopup> createState() => _CookBookPopupState();
}

class _CookBookPopupState extends State<CookBookPopup> {
  ColCookList data = {};

  List<String> undo = [];

  bool showBefore = true;

  List<String> get doing {
    var raw = data.entries.map((e) => e.key).toList().where((element) {
      return !undo.any((sub) => element == sub);
    }).toList();
    return raw;
  }

  @override
  void initState() {
    data = widget.data;
    undo = widget.undoInitValue;
    showBefore = widget.showBefore;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 320,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.scale(
                      scale: .72,
                      child: CupertinoSwitch(
                        value: showBefore,
                        onChanged: (value) {
                          showBefore = value;
                          setState(() {});
                        },
                      ),
                    ),
                    Text(
                      "做菜之前",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: CupertinoTheme.of(context)
                            .primaryColor
                            .withOpacity(.72),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () {
                        widget.onConfirm(undo, showBefore);
                        Navigator.of(context).pop(-2);
                      },
                      child: Text(
                        "确定",
                        style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "已选菜系",
                style: TextStyle(color: CupertinoColors.systemPink),
              ),
              const SizedBox(height: 9.0),
              if (doing.isEmpty) const CookBookTableEmpty(),
              if (doing.isNotEmpty)
                CookBookTable(
                  data: doing,
                  onTap: (value) {
                    undo.add(value);
                    setState(() {});
                  },
                ),
              const SizedBox(height: 9.0),
              const Text(
                "未选菜系",
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 9.0),
              if (undo.isEmpty) const CookBookTableEmpty(),
              if (undo.isNotEmpty)
                CookBookTable(
                  data: undo,
                  onTap: (value) {
                    undo.remove(value);
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CookBookTable extends StatelessWidget {
  const CookBookTable({
    super.key,
    this.onTap,
    required this.data,
    this.color,
  });

  final ValueChanged<String>? onTap;
  final List<String> data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    late Color reColor;
    if (color != null) {
      reColor = color as Color;
    } else {
      reColor = CupertinoTheme.of(context).primaryColor;
    }
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: data
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    onTap!(e);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: reColor,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      e.replaceFirst("### ", ""),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CookBookTableEmpty extends StatelessWidget {
  const CookBookTableEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "暂无~",
      style: TextStyle(
        fontSize: 12.0,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}
