import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            border: Border(),
            largeTitle: Text('程序员做饭指南'),
            trailing: Icon(CupertinoIcons.info),
          ),
          SliverFillRemaining(
            child: Padding(
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
                                "菜谱",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.2),
                              ),
                              child: Column(
                                children: List.generate(
                                  12,
                                  (index) => const CupertinoListTile(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: CupertinoColors
                                            .systemGroupedBackground,
                                      ),
                                    ),
                                    dense: true,
                                    title: Text("你好世界"),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
