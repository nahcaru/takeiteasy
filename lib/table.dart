import 'package:flutter/material.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];
  List<String> tookClasses = [];
  List<double> tookCredits = [];
  List<String> weekdays = ['月', '火', '水', '木', '金', '土'];
  List<String> times = ['1', '2', '3', '4', '5', '6'];
  List<List<String>> formerClassNames = [];
  List<List<String>> latterClassNames = [];
  List<String> intensiveClassNames = [];
  List<List<String>> formerClasses = [];
  List<List<String>> latterClasses = [];
  List<String> intensiveClasses = [];
  List<bool> areDepartmentsSelected = [];
  final List<String> departments = ['共通', '情科', '知能'];
  List<bool> areGradesSelected = [];
  final List<String> grades = ['1', '2', '3', '4'];
  List<bool> areTermsSelected = [];
  final List<String> terms = ['後期前', '後期後', '後期', '後集中', '通年'];
  List<bool> areCategoriesSelected = [];
  final List<String> categories = [
    '教養',
    '体育',
    '外国語',
    'PBL',
    '情報工学基盤',
    '専門',
    '教職',
    'その他'
  ];
  List<bool> areCompulsoriesSelected = [];
  final List<String> compulsories = ['必修', '選択必修', '選択'];
  @override
  void initState() {
    super.initState();
    setTable();
  }

  void setTable() {
    formerClassNames = [];
    latterClassNames = [];
    formerClasses = [];
    latterClasses = [];
    for (int i = 0; i < times.length; i++) {
      List<String> formerNamesRow = [];
      List<String> latterNamesRow = [];
      List<String> formerRow = [];
      List<String> latterRow = [];
      for (int j = 0; j < weekdays.length; j++) {
        String formerNamesCell = '';
        String latterNamesCell = '';
        String formerCell = '';
        String latterCell = '';
        for (String id in tookClasses) {
          Map<String, dynamic> item =
              data.firstWhere((element) => element['講義コード'] == id);
          if (item['時限'].contains('${weekdays[j]}${times[i]}')) {
            switch (item['学期']) {
              case '後期':
                formerNamesCell += '${item['科目名']}\n';
                latterNamesCell += '${item['科目名']}\n';
                formerCell = item['講義コード'];
                latterCell = item['講義コード'];
                break;
              case '後期前':
                formerNamesCell += '${item['科目名']}\n';
                formerCell = item['講義コード'];
                break;
              case '後期後':
                latterNamesCell += '${item['科目名']}\n';
                latterCell = item['講義コード'];

                break;

              default:
            }
          }
        }
        formerNamesRow.add(formerNamesCell);
        latterNamesRow.add(latterNamesCell);
        formerRow.add(formerCell);
        latterRow.add(latterCell);
      }
      formerClassNames.add(formerNamesRow);
      latterClassNames.add(latterNamesRow);
      formerClasses.add(formerRow);
      latterClasses.add(latterRow);
    }
    intensiveClassNames = [];
    intensiveClasses = [];
    for (String id in tookClasses) {
      Map<String, dynamic> item =
          data.firstWhere((element) => element['講義コード'] == id);
      if (item['学期'] == '後集中') {
        intensiveClassNames.add(item['科目名']);
        intensiveClasses.add(item['講義コード']);
      }
    }
  }

  void setCredit() {
    tookCredits = List.filled(categories.length, 0);
    for (String id in tookClasses) {
      Map<String, dynamic> item =
          data.firstWhere((element) => element['講義コード'] == id);
      for (int i = 0; i < categories.length - 1; i++) {
        if (item['分類'].contains(categories[i])) {
          //tookCredits[i] += int.parse(item['単位数'].toString());
          tookCredits[i] += item['単位数'];
        }
      }
    }
    for (int i = 0; i < categories.length - 1; i++) {
      tookCredits.last += tookCredits[i];
    }
  }

  Table timeTable(String title, List<List<String>> nameData, bool isFormer) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          borderRadius: BorderRadius.circular(10)),
      children: [
        TableRow(children: [
          TableCell(
              child: Text(
            title,
            textAlign: TextAlign.center,
          )),
          for (int j = 0; j < weekdays.length; j++)
            TableCell(
                child: Text(
              weekdays[j],
              textAlign: TextAlign.center,
            )),
        ]),
        for (int i = 0; i < times.length; i++)
          TableRow(
            children: [
              TableCell(
                  child: Text(
                '${i + 1}限',
                textAlign: TextAlign.center,
              )),
              for (int j = 0; j < weekdays.length; j++)
                TableCell(
                  child: (nameData[i][j] == '')
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          height: 50,
                        )
                      : InkWell(
                          onTap: () {
                            Map<String, dynamic> item = data.firstWhere(
                                (element) => isFormer
                                    ? element['講義コード'] == formerClasses[i][j]
                                    : element['講義コード'] == latterClasses[i][j]);
                            String info =
                                (item['クラス'] + ' ' + item['備考']).trim();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return (nameData[i][j]
                                        .trimRight()
                                        .contains('\n'))
                                    ? AlertDialog(
                                        title: const Text('科目が重複しています'),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(nameData[i][j]),
                                          ],
                                        ),
                                        scrollable: true,
                                      )
                                    : AlertDialog(
                                        title: (info == '')
                                            ? Text(item['科目名'])
                                            : Text('($info) ${item['科目名']}'),
                                        content: SelectionArea(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                                            ],
                                          ),
                                        ),
                                        scrollable: true,
                                      );
                              },
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(5),
                            height: 50,
                            decoration: BoxDecoration(
                                color:
                                    (nameData[i][j].trimRight().contains('\n'))
                                        ? Colors.red.withAlpha(64)
                                        : Colors.lightBlue.withAlpha(64),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              nameData[i][j].trimRight(),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double ratio = (screenSize.width / screenSize.height);
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                (ratio < 1)
                    ? Column(
                        children: [
                          timeTable('前半', formerClassNames, true),
                          const SizedBox(
                            height: 20,
                          ),
                          timeTable('後半', latterClassNames, false),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: timeTable('前半', formerClassNames, true),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: timeTable('後半', latterClassNames, false),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 20,
                ),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  children: [
                    const TableRow(children: [
                      TableCell(
                          child: Text(
                        '集中',
                        textAlign: TextAlign.center,
                      )),
                    ]),
                    TableRow(
                      children: [
                        TableCell(
                          child: (intensiveClassNames.isEmpty)
                              ? Container(
                                  margin: const EdgeInsets.all(5),
                                  height: 50,
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (int i = 0;
                                          i < intensiveClassNames.length;
                                          i++)
                                        InkWell(
                                          onTap: () {
                                            Map<String, dynamic> item =
                                                data.firstWhere((element) =>
                                                    element['講義コード'] ==
                                                    intensiveClasses[i]);
                                            String info =
                                                (item['クラス'] + ' ' + item['備考'])
                                                    .trim();
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: SelectionArea(
                                                    child: (info == '')
                                                        ? Text(item['科目名'])
                                                        : Text(
                                                            '($info) ${item['科目名']}'),
                                                  ),
                                                  content: SelectionArea(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                                                      ],
                                                    ),
                                                  ),
                                                  scrollable: true,
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.lightBlue
                                                    .withAlpha(64),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Center(
                                              child: Text(
                                                intensiveClassNames[i],
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
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (1 <= ratio) Expanded(child: Container()),
                    Expanded(
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        children: [
                          TableRow(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor),
                              children: const [
                                TableCell(
                                    child: Text(
                                  '分類',
                                  textAlign: TextAlign.center,
                                )),
                                TableCell(
                                    child: Text(
                                  '単位数',
                                  textAlign: TextAlign.center,
                                )),
                              ]),
                          for (int i = 0; i < categories.length - 1; i++)
                            TableRow(
                              children: [
                                TableCell(
                                    child: Text(
                                  categories[i],
                                  textAlign: TextAlign.center,
                                )),
                                TableCell(
                                    child: Text(
                                  tookCredits[i].toString(),
                                  textAlign: TextAlign.center,
                                )),
                              ],
                            ),
                          TableRow(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor),
                            children: [
                              const TableCell(
                                  child: Text(
                                '合計',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              TableCell(
                                  child: Text(
                                tookCredits.last.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (1 <= ratio) Expanded(child: Container()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
