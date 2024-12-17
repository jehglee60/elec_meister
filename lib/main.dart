import 'package:flutter/material.dart';
import 'package:test_rendering/pages.dart'; // Import pages.dart

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
