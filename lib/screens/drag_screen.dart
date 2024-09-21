import 'package:flutter/material.dart';

class DragScreen extends StatefulWidget {
  const DragScreen({super.key});

  @override
  State<DragScreen> createState() => _DragScreenState();
}

class _DragScreenState extends State<DragScreen> {
  final List<String> codeLines = [
    "n = int(input())",
    "",
    "fibo = []",
    "fibo.append(0)",
    "fibo.append(1)",
    "",
    "for i in range(2, ___):",
    "    fibo.append(fibo[i-1]+fibo[i-2])",
    "",
    "print(___)"
  ];

  final List<String> correctAnswers = ['n+1', 'fibo[n]'];
  List<String> availableBlocks = ['n+1', 'fibo[n]'];
  List<String?> filledBlanks = List.filled(2, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          "Drag and Drop",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: codeLines.length,
              itemBuilder: (context, index) {
                if (codeLines[index].contains("___")) {
                  int blankIndex = codeLines
                      .take(index + 1)
                      .where((line) => line.contains("___"))
                      .toList()
                      .indexOf(codeLines[index]);
                  return CodeLineWithBlank(
                    line: codeLines[index],
                    blankContent: filledBlanks[blankIndex],
                    blankIndex: blankIndex,
                    onAccept: (data) {
                      setState(() {
                        filledBlanks[blankIndex] = data;
                        availableBlocks.remove(data);
                        if (!filledBlanks.contains(null)) {
                          checkCompletion();
                        }
                      });
                    },
                    onRemove: (data) {
                      setState(() {
                        filledBlanks[data['blankIndex']] = null;
                        availableBlocks.add(data['block']);
                      });
                    },
                  );
                } else {
                  return CodeLine(line: codeLines[index]);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 10,
                children: availableBlocks.map((block) {
                  return Draggable<String>(
                    data: block,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          block,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    childWhenDragging: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Dragging...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        block,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkCompletion() {
    bool isCorrect = true;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (filledBlanks[i] != correctAnswers[i]) {
        isCorrect = false;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "축하합니다!" : "틀렸습니다!"),
          content: SingleChildScrollView(
            child: Text(
              isCorrect ? "모든 코드가 정확합니다." : "코드에 틀린 부분이 있습니다. 다시 시도해 보세요.",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("다시하기"),
              onPressed: () {
                // 다이얼로그를 닫고 페이지를 새로고침
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const DragScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class CodeLine extends StatelessWidget {
  final String line;

  const CodeLine({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        line,
        style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
        softWrap: true,
      ),
    );
  }
}

class CodeLineWithBlank extends StatelessWidget {
  final String line;
  final String? blankContent;
  final int blankIndex;
  final Function(String) onAccept;
  final Function(Map<String, dynamic>) onRemove;

  const CodeLineWithBlank({
    super.key,
    required this.line,
    this.blankContent,
    required this.blankIndex,
    required this.onAccept,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    List<String> parts = line.split('___');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 최소 크기만 차지하도록 설정
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            parts[0],
            style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            softWrap: true,
          ),
          const SizedBox(width: 4), // 약간의 간격 추가
          GestureDetector(
            onTap: () {
              if (blankContent != null) {
                onRemove({
                  'blankIndex': blankIndex,
                  'block': blankContent!,
                });
              }
            },
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: blankContent != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.blue, // 배경색을 명시적으로 설정
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    blankContent ?? '___',
                    style: TextStyle(
                      color: blankContent != null
                          ? Theme.of(context).colorScheme.onPrimary
                          : Colors.white, // 가독성을 위해 기본 텍스트 색상을 흰색으로 변경
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              onAcceptWithDetails: (details) => onAccept,
            ),
          ),
          const SizedBox(width: 4), // 약간의 간격 추가
          Text(
            parts.length > 1 ? parts[1] : '',
            style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
