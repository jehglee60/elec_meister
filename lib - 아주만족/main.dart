import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto Text and LaTeX Renderer',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auto Text and LaTeX Renderer'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: ContentRenderer(),
          ),
        ),
      ),
    );
  }
}

class ContentRenderer extends StatelessWidget {
  const ContentRenderer({super.key});

  final String mixedContent = r"""
V결선 2대로 공급하면 최대 용량 공급 가능
P_a=2\cdot\sqrt{3}\cdot500=1,732.05[kVA]

(1) 역률 $cos\theta=\frac{P}{P_a}\cdot100 [\%]$   
피상전력 $P_a=\sqrt{3}VI=\sqrt{3}\cdot200\cdot30\cdot10^{-3}$
유효전력 $P=W_1+W_2=6+2.9$
역률 $cos\theta$
$=\frac{6+2.9}{\sqrt{3}\cdot200\cdot30\cdot10^{-3}}\cdot100=86.54\%$

(2) 콘덴서 용량 $Q_C=P(tan\theta_1-tan\theta_2)$
$Q_C=8.9\left(\frac{\sqrt{1-0.8564^2}}{0.8564}-\frac{\sqrt{1-0.9^2}}{0.9}\right)$

(3) 권상기의 출력 $P=\frac{Wnk}{6.12h}$ → $W=2.18[ton]$
""";

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = _parseMixedContent(mixedContent);

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }

  List<InlineSpan> _parseMixedContent(String content) {
    // 수식을 찾기 위한 정규표현식 확장
    final regex = RegExp(r'(\$.*?\$|\\.*?\b|P_a=.*?\[kVA\])');
    final matches = regex.allMatches(content);

    int lastIndex = 0;
    final List<InlineSpan> spans = [];

    for (final match in matches) {
      // Add preceding text
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: content.substring(lastIndex, match.start)));
      }

      // Add matched LaTeX equation or special text
      final equation = match.group(0);
      if (equation != null) {
        if (equation.startsWith(r'$') && equation.endsWith(r'$')) {
          // Case: LaTeX wrapped in $...$
          spans.add(_buildMathWidget(
            equation.substring(1, equation.length - 1),
          ));
        } else {
          // Case: Inline LaTeX not wrapped in $...$
          spans.add(_buildMathWidget(equation));
        }
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(TextSpan(text: content.substring(lastIndex)));
    }

    return spans;
  }

  InlineSpan _buildMathWidget(String equation) {
    // Adjust style based on presence of \frac or \sqrt
    final bool hasFraction =
        equation.contains(r'\frac') || equation.contains(r'\sqrt');

    return WidgetSpan(
      child: Container(
        padding: hasFraction
            ? const EdgeInsets.only(bottom: 4.0)
            : EdgeInsets.zero, // 추가 여백
        child: Math.tex(
          equation,
          textStyle: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
    );
  }
}
