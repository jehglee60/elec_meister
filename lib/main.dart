import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:test_rendering/data/content_repository.dart';
import 'package:test_rendering/models/content.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '전기기사 실기 기출 문제',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// BottomNavigationBar를 사용하는 메인 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 각 BottomNavigationBar 탭에 대응하는 위젯들
  final List<Widget> _pages = [
    const SplashScreen(), // 홈 페이지
    const YearRoundSearchPage(), // 연도검색 페이지
    const SubjectSearchPage(), // 주제검색 페이지 (새로 추가)
    const ReviewPage(), // 복습 페이지 (새로 추가)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // 현재 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // 고정된 아이템과 라벨의 위치
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '연도검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '주제검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            label: '복습',
          ),
        ],
        selectedItemColor: Colors.blue, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        backgroundColor: Colors.white, // BottomNavigationBar 배경 색상
        showUnselectedLabels: true, // 선택되지 않은 항목에도 label을 표시
      ),
    );
  }
}

// 스플래시 스크린 -> 홈 페이지로 사용
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전기 마이스터',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // 가로로 중앙 정렬
          children: [
            Image.asset('assets/logo.png', height: 150), // 로고 추가
            const SizedBox(height: 20),
            const Text(
              '전기기사 실기 기출 문제',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('● 연도/회차 별 학습\n ● 주제 별 학습',
                style: TextStyle(fontSize: 24)),
            const SizedBox(height: 30),

            const Text(
              '아래 탭에서 원하는 기능을 선택하세요.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// 기존 ContentRenderer를 "연도검색" 페이지로 변경
class YearRoundSearchPage extends StatefulWidget {
  const YearRoundSearchPage({super.key});

  @override
  _YearRoundSearchPageState createState() => _YearRoundSearchPageState();
}

class _YearRoundSearchPageState extends State<YearRoundSearchPage> {
  int? selectedYear = 2024; // 기본값: 2024년
  int? selectedRound = 1; // 기본값: 1회차
  late Future<List<Content>> contents;

  @override
  void initState() {
    super.initState();
    contents = ContentRepository().fetchContents();
  }

  void _onYearChanged(int? newYear) {
    setState(() {
      selectedYear = newYear;
      _filterContents();
    });
  }

  void _onRoundChanged(int? newRound) {
    setState(() {
      selectedRound = newRound;
      _filterContents();
    });
  }

  void _filterContents() {
    contents = ContentRepository().fetchContents().then((data) {
      return data.where((content) {
        final nrString = content.nr.toString();
        final year = int.tryParse(nrString.substring(0, 4));
        final round = int.tryParse(nrString.substring(4, 6));
        return year == selectedYear && round == selectedRound;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연도/회차 검색',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연도와 회차 선택
          Row(
            children: [
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16), // '연도: '에 가로축 패딩 추가
                child: Text(
                  '연도: ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<int>(
                value: selectedYear,
                onChanged: _onYearChanged,
                items: List.generate(2025 - 2020, (index) {
                  int year = 2024 - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: const TextStyle(fontSize: 22),
                    ),
                  );
                }),
              ),
            ],
          ),
          Row(
            children: [
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16), // '회차: '에 가로축 패딩 추가
                child: Text(
                  '회차: ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              for (int round = 1; round <= 3; round++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: CircleAvatar(
                    child: TextButton(
                      onPressed: () => _onRoundChanged(round),
                      child:
                          Text("$round", style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '문제 목록',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),

          // 문제 목록 부분
          Expanded(
            child: Container(
              color: Colors.blue[50], // 배경색 지정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  const SizedBox(height: 10),

                  // 문제 목록 내용
                  Expanded(
                    child: FutureBuilder<List<Content>>(
                      future: contents,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No content available.'));
                        }

                        final List<Content> contentList = snapshot.data!;
                        return ListView.builder(
                          itemCount: contentList.length,
                          itemExtent: 50,
                          itemBuilder: (context, index) {
                            final content = contentList[index];
                            String questionNumber = content.nr
                                        .toString()
                                        .length >=
                                    8
                                ? int.parse(
                                        content.nr.toString().substring(6, 8))
                                    .toString()
                                : (index + 1).toString();

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Transform.scale(
                                scale: 0.95,
                                child: Text(
                                  "$questionNumber. ${content.title}",
                                  style: const TextStyle(
                                      fontSize: 20, height: 0.8),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProblemDetailPage(content: content),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
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

// "주제검색" 페이지

const Map<String, List<String>> topicSubtopics = {
  '송전선로': ['송전선로', '유도장해'],
  '수전설비': ['수전방식', '변압기', '차단기', '보호계전기', '전력퓨즈', '서지흡수기'],
  '배전선로': ['배전선로', '간선설비', '접지설비', '옥내배선', '절연내력'],
  '부하설비': ['조명', '동력', '전력용콘덴서', '예비전원'],
  '감리 및 규정': ['피뢰기', '감리', 'KEC'],
  '시퀀스 제어': ['무접점', '유접점', '전동기', 'PLC', '전선 가닥수'],
  '고장해석 및 접지': ['고장해석', '접지'],
  '기타': ['기타1', '기타2', '기타3'],
};

class SubjectSearchPage extends StatefulWidget {
  const SubjectSearchPage({super.key});

  @override
  State<SubjectSearchPage> createState() => _SubjectSearchPageState();
}

class _SubjectSearchPageState extends State<SubjectSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주제 검색',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
        child: SingleChildScrollView(
          // 스크롤 가능하도록 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: topicSubtopics.keys.map((topic) {
              List<String> subtopics = topicSubtopics[topic]!;
              int topicIndex = topicSubtopics.keys.toList().indexOf(topic);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (subtopic) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $subtopic')),
                      );
                    },
                    itemBuilder: (context) => subtopics
                        .map((subtopic) => PopupMenuItem(
                              value: subtopic,
                              child: Text(subtopic,
                                  style: const TextStyle(fontSize: 20)),
                            ))
                        .toList(),
                    offset: const Offset(150, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.55, // 가로 길이 반으로 줄임
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, // 모든 박스의 가로 여백 조정
                        vertical: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: topicIndex >= 4
                            ? Colors.grey[300]
                            : Colors.blue[100],
                        border: Border.all(
                            color: topicIndex >= 4 ? Colors.grey : Colors.blue,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  if (topicIndex < 4) // 화살표를 위에서 3개까지만 표시
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Icon(Icons.arrow_downward,
                          size: 27, color: Colors.grey),
                    ),
                  if (topicIndex >= 4) // 화살표 없는 경우 세로 간격 추가
                    const SizedBox(height: 5.0),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// "복습" 페이지
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복습',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('복습 기능을 구현하세요!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// ProblemDetailPage 및 기타 코드는 기존과 동일 (생략 가능)

class ProblemDetailPage extends StatelessWidget {
  final Content content;

  const ProblemDetailPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    String nr = content.nr.toString();
    String questionNumber =
        nr.length >= 8 ? int.parse(nr.substring(6, 8)).toString() : '??';

    String title = content.title;
    final List<InlineSpan> questionSpans = _parseMixedContent(content.ques);
    final List<InlineSpan> answerSpans = _parseMixedContent(content.ans);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$questionNumber. $title",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: questionSpans,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  if (content.qImgPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(content.qImgPath!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.teal[50],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: answerSpans,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  if (content.aImgPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(content.aImgPath!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _parseMixedContent(String? content) {
    final regex = RegExp(r'(\$.*?\$|\\.*?\b|P_a=.*?\[kVA\])');
    final matches = regex.allMatches(content ?? '');

    int lastIndex = 0;
    final List<InlineSpan> spans = [];

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: content!.substring(lastIndex, match.start)));
      }

      final equation = match.group(0);
      if (equation != null) {
        spans.add(_buildMathWidget(equation));
      }

      lastIndex = match.end;
    }

    if (lastIndex < content!.length) {
      spans.add(TextSpan(text: content.substring(lastIndex)));
    }

    return spans;
  }

  InlineSpan _buildMathWidget(String equation) {
    if (equation.startsWith(r'$') && equation.endsWith(r'$')) {
      equation = equation.substring(1, equation.length - 1);
    }

    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Math.tex(
          equation,
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
    );
  }
  // 문제 목록
// 문제 목록 제목
}