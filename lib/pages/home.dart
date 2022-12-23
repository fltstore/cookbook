import 'package:cookbook/model/data.dart';
import 'package:cookbook/parse.dart';
import 'package:cookbook/shared/helper.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  CoreParse coreParse = CoreParse();

  Future<CookParseDataModel> loadReadme() async {
    // await Future.delayed(Duration(seconds: 2));
    String raw = await rootBundle.loadString(joinMarkdownPath('README.md'));
    var data = tryParse(raw);
    return data;
  }

  tryParse(String raw) {
    coreParse.parseMetaData(raw);
    return coreParse.data;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("程序员做饭指南"),
      ),
      child: SafeArea(
        child: FutureBuilder<CookParseDataModel>(
          future: loadReadme(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "load fail!",
                  style: TextStyle(color: CupertinoColors.systemPink),
                ),
              );
            }
            var data = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),
                  const CupertinoSearchTextField(),
                  const SizedBox(height: 6.0),
                  Expanded(
                    child: OverflowBox(
                      child: SingleChildScrollView(
                        child: Column(
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
                                  data!.before.length,
                                  (index) => CupertinoListTile(
                                    onTap: () {
                                      var curr = data.before[index];
                                      var link = curr.link;
                                      context.push('/detail?link=$link');
                                    },
                                    dense: true,
                                    title: Text(
                                      data.before[index].title,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: data.data.entries.map((e) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.2,
                                        vertical: 12.0,
                                      ),
                                      child: Text(
                                        e.key,
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
