import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:test_rendering/data/content_repository.dart';
import 'package:test_rendering/models/content.dart';

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
                      // 부주제를 선택하면 SubtopicDetailPage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubtopicDetailPage(subtopic: subtopic),
                        ),
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
                      width: MediaQuery.of(context).size.width * 0.55,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
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
                  if (topicIndex < 4)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Icon(Icons.arrow_downward,
                          size: 27, color: Colors.grey),
                    ),
                  if (topicIndex >= 4) const SizedBox(height: 5.0),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class SubtopicDetailPage extends StatelessWidget {
  final String subtopic;

  const SubtopicDetailPage({super.key, required this.subtopic});

  @override
  Widget build(BuildContext context) {
    // ContentRepository에서 데이터 가져오기
    final ContentRepository contentRepository = ContentRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details for $subtopic',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Content>>(
        future: contentRepository.fetchContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No content available.'));
          }

          // 데이터 필터링: 부주제(sTopic)가 선택한 subtopic과 일치하는 항목만 추출
          final List<Content> filteredContentList = snapshot.data!
              .where((content) => content.sTopic == subtopic)
              .toList();

          // 필터링된 데이터를 목록으로 표시
          return ListView.builder(
            itemCount: filteredContentList.length,
            itemExtent: 50,
            itemBuilder: (context, index) {
              final content = filteredContentList[index];
              return ListTile(
                title: Text(
                  "${content.nr}. ${content.title}",
                  style: const TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // 각 문제 클릭 시 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemDetailPage(content: content),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// 복습 페이지
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복습',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text('복습 페이지')),
    );
  }
}

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
        title: const Text(
          '문제 상세',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: true, // 드래그로 이동 가능
        boundaryMargin: const EdgeInsets.all(50), // 이동 범위 설정
        minScale: 0.1, // 최소 스케일
        maxScale: 4.0, // 최대 스케일
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$questionNumber. $title",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    if (content.qImgPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.asset(
                          content.qImgPath!,
                          fit: BoxFit.contain,
                        ),
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
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
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
}
