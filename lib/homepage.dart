import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Directory downloadsDirectory;
  String givenText = "";
  List<String> listOfWords = [];
  bool fabIsClosed = true;
  int currentIndex = 0;
  List<Widget> currentIndexWidget = [];
  double fontSizeSliderValue = 25;
  double wordsSpacingSliderValue = 2;
  Color selectedColor = Colors.indigo[900];
  Color selectedMarginColor = Colors.redAccent;
  String selectedPaper = "A4";
  double marginTop = 15;
  var fontData;
  var ttf;
  String selectedFont = "Caveat-Regular.ttf";
  bool isPaperStyle = true;
  bool isPaperMargin = false;
  double paperMargin = 50;
  final controller = TextEditingController();

  Random random = Random();

  void initState() {
    super.initState();
    controller.text = givenText;
  }

  Future createPDF(listOfWidgets) async {
    Directory downloadsDirectoryTemp;
    downloadsDirectoryTemp = await getExternalStorageDirectory();
    setState(() {
      downloadsDirectory = downloadsDirectoryTemp;
    });
    var pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: (selectedPaper == "A4")
              ? PdfPageFormat.a4
              : (selectedPaper == "A3")
                  ? PdfPageFormat.a3
                  : (selectedPaper == "A5")
                      ? PdfPageFormat.a5
                      : PdfPageFormat.letter,
          margin: (isPaperMargin)
              ? pw.EdgeInsets.only(top: (marginTop + paperMargin), left: 65)
              : pw.EdgeInsets.fromLTRB(25, marginTop, 20, 20),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Container(
                    decoration: (isPaperStyle)
                        ? pw.BoxDecoration(
                            gradient: pw.LinearGradient(
                              begin: pw.Alignment.centerLeft,
                              end: pw.Alignment.centerRight,
                              colors: [
                                PdfColor.fromHex('eeeeee'),
                                PdfColor.fromHex('dddddd'),
                              ],
                            ),
                          )
                        : null,
                  ),
                  pw.Opacity(
                    opacity: 0.2,
                    child: pw.Container(
                      decoration: (isPaperStyle)
                          ? pw.BoxDecoration(
                              gradient: pw.RadialGradient(
                                colors: [
                                  PdfColor.fromHex('#777777'),
                                  PdfColor.fromHex('#ffffff'),
                                ],
                                center: pw.Alignment(
                                  random.nextDouble(),
                                  random.nextDouble(),
                                ),
                                radius: 2,
                              ),
                            )
                          : null,
                    ),
                  ),
                  (isPaperMargin)
                      ? pw.Padding(
                          padding: pw.EdgeInsets.only(left: paperMargin),
                          child: pw.VerticalDivider(
                            color: (selectedMarginColor == Colors.redAccent)
                                ? PdfColors.redAccent
                                : (selectedMarginColor == Colors.black)
                                    ? PdfColors.black
                                    : PdfColors.indigo900,
                            thickness: 1,
                          ),
                        )
                      : pw.Container(height: 0, width: 0),
                  (isPaperMargin)
                      ? pw.Padding(
                          padding: pw.EdgeInsets.only(top: paperMargin),
                          child: pw.Divider(
                            color: (selectedMarginColor == Colors.redAccent)
                                ? PdfColors.redAccent
                                : (selectedMarginColor == Colors.black)
                                    ? PdfColors.black
                                    : PdfColors.indigo900,
                            thickness: 1,
                          ),
                        )
                      : pw.Container(height: 0, width: 0),
                ],
              ),
            );
          },
        ),
        build: (pw.Context context) {
          return [
            pw.Wrap(
              children: listOfWidgets,
            ),
          ];
        },
      ),
    );
    final file = File("${downloadsDirectory.path}/example.pdf");
    await file.writeAsBytes(pdf.save());
  }

  void createListofWidgets() async {
    List<pw.Widget> listOfWidgets = [];
    fontData = await rootBundle.load("assets/$selectedFont");
    setState(() {
      ttf = pw.Font.ttf(fontData);
    });
    givenText = givenText.replaceAll("\n", " \n ");
    listOfWords = givenText.split(" ");
    for (var item in listOfWords) {
      listOfWidgets.add(
        pw.Text(
          """$item """,
          style: pw.TextStyle(
            font: ttf,
            color: (selectedColor == Colors.black)
                ? PdfColors.black
                : PdfColors.indigo900,
            fontSize: fontSizeSliderValue,
            wordSpacing: wordsSpacingSliderValue,
          ),
        ),
      );
    }
    createPDF(listOfWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "H A N D Y",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          if (currentIndex == 0) {
            currentIndexWidget = [];
          }
        },
        elevation: 16,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open), title: Text("Files")),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Customize")),
          BottomNavigationBarItem(
              icon: Icon(Icons.font_download), title: Text("Font")),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon:
            fabIsClosed ? AnimatedIcons.add_event : AnimatedIcons.menu_close,
        onOpen: () {
          setState(() {
            fabIsClosed = false;
          });
        },
        onClose: () {
          setState(() {
            fabIsClosed = true;
          });
        },
        children: [
          SpeedDialChild(
            child: Icon(Icons.content_copy),
            label: "Copy Paste",
          ),
          SpeedDialChild(
            child: Icon(Icons.insert_drive_file),
            label: "Add from .txt",
          ),
          SpeedDialChild(
            child: Icon(Icons.text_format),
            label: "Add from .docx",
          ),
        ],
      ),
      body: (currentIndex == 0)
          ? SafeArea(
              child: Center(
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "H A N D Y !",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Enter the text here",
                            ),
                            maxLines: null,
                            onChanged: (value) {
                              givenText = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      color: Colors.red,
                      child: Text("Submit"),
                      onPressed: () {
                        controller.clear();
                        createListofWidgets();
                      },
                    ),
                  ],
                ),
              ),
            )
          : (currentIndex == 1)
              ? SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Text(
                            "Font Size : ${fontSizeSliderValue.round()}",
                          ),
                          Slider(
                            value: fontSizeSliderValue,
                            min: 15,
                            max: 35,
                            onChanged: (value) {
                              setState(() {
                                fontSizeSliderValue = value.roundToDouble();
                              });
                            },
                          ),
                          Text(
                            "Word Spacing : ${wordsSpacingSliderValue.round()}",
                          ),
                          Slider(
                            value: wordsSpacingSliderValue,
                            min: -2,
                            max: 8,
                            onChanged: (value) {
                              setState(() {
                                wordsSpacingSliderValue = value.roundToDouble();
                              });
                            },
                          ),
                          Text(
                              "Vertical Position of Text : ${marginTop.round()}"),
                          Slider(
                            value: marginTop,
                            min: 0,
                            max: 50,
                            onChanged: (value) {
                              setState(() {
                                marginTop = value.roundToDouble();
                              });
                            },
                          ),
                          ExpansionTile(
                            key: GlobalKey(),
                            title: Text("Paper Size"),
                            trailing: Text(selectedPaper),
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPaper = "LETTER";
                                      });
                                    },
                                    child: Text(
                                      "Letter",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPaper = "A3";
                                      });
                                    },
                                    child: Text(
                                      "A3",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPaper = "A4";
                                      });
                                    },
                                    child: Text(
                                      "A4",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPaper = "A5";
                                      });
                                    },
                                    child: Text(
                                      "A5",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "Paper Style",
                              ),
                              Switch(
                                value: isPaperStyle,
                                onChanged: (value) {
                                  setState(() {
                                    isPaperStyle = value;
                                  });
                                  print(isPaperStyle);
                                },
                              ),
                              Text(
                                "Paper Margin",
                              ),
                              Switch(
                                value: isPaperMargin,
                                onChanged: (value) {
                                  setState(() {
                                    isPaperMargin = value;
                                  });
                                  print(isPaperMargin);
                                },
                              ),
                            ],
                          ),
                          ExpansionTile(
                            key: GlobalKey(),
                            title: Text("Text Color"),
                            trailing: Container(
                              color: selectedColor,
                              height: 20,
                              width: 20,
                            ),
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = Colors.black;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = Colors.indigo[900];
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.indigo[900],
                                ),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            key: GlobalKey(),
                            title: Text("Margin Color"),
                            trailing: Container(
                              color: selectedMarginColor,
                              height: 20,
                              width: 20,
                            ),
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMarginColor = Colors.black;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMarginColor = Colors.indigo[900];
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMarginColor = Colors.redAccent;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          color: (selectedFont == "Caveat-Regular.ttf")
                              ? Colors.lightBlueAccent
                              : null,
                          child: Text(
                            "The quick brown fox jumps over the lazy dog",
                            style: TextStyle(
                              fontFamily: 'Caveat',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedFont = "Caveat-Regular.ttf";
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          color: (selectedFont == "HomemadeApple-Regular.ttf")
                              ? Colors.lightBlueAccent
                              : null,
                          child: Text(
                            "The quick brown fox jumps over the lazy dog",
                            style: TextStyle(
                              fontFamily: 'HomemadeApple',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedFont = "HomemadeApple-Regular.ttf";
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          color: (selectedFont == "Kalam-Light.ttf")
                              ? Colors.lightBlueAccent
                              : null,
                          child: Text(
                            "The quick brown fox jumps over the lazy dog",
                            style: TextStyle(
                              fontFamily: 'Kalam',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedFont = "Kalam-Light.ttf";
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          color: (selectedFont == "Kristi-Regular.ttf")
                              ? Colors.lightBlueAccent
                              : null,
                          child: Text(
                            "The quick brown fox jumps over the lazy dog",
                            style: TextStyle(
                              fontFamily: 'Kristi',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedFont = "Kristi-Regular.ttf";
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          color:
                              (selectedFont == "NothingYouCouldDo-Regular.ttf")
                                  ? Colors.lightBlueAccent
                                  : null,
                          child: Text(
                            "The quick brown fox jumps over the lazy dog",
                            style: TextStyle(
                              fontFamily: 'NothingYouCouldDo',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedFont = "NothingYouCouldDo-Regular.ttf";
                          });
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
