import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizView extends StatefulWidget {
  final List<Quiz> quizzes;
  final VoidCallback onFinished;

  const QuizView({
    Key? key,
    required this.quizzes,
    required this.onFinished,
  }) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _currentIndex = 0;
  String? _selectedChoice; // "A", "B", "C", "D"
  bool _isAnswered = false;
  int _correctCount = 0;

  void _selectOption(String optionPrefix) {
    if (_isAnswered) return;

    setState(() {
      _selectedChoice = optionPrefix;
      _isAnswered = true;
      if (optionPrefix == widget.quizzes[_currentIndex].answer) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedChoice = null;
      _isAnswered = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Finished Quiz State
    if (_currentIndex >= widget.quizzes.length) {
      final scorePercentage = widget.quizzes.isNotEmpty
          ? (_correctCount / widget.quizzes.length * 100).round()
          : 0;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score badge ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _correctCount / (widget.quizzes.isEmpty ? 1 : widget.quizzes.length),
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: scorePercentage >= 60 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$scorePercentage%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '正确率',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  '测试通关！',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '共答对 $_correctCount / ${widget.quizzes.length} 题！\n'
                  '${scorePercentage >= 80 ? "太棒了，这部分概念已经被你彻底吃透！" : "干得不错！如果能重做错题就更完美啦。"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: widget.onFinished,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('返回主页', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final quiz = widget.quizzes[_currentIndex];

    // 2. Active Quiz State
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('概念闯关测试', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
          onPressed: widget.onFinished,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '题目进度: ${_currentIndex + 1}/${widget.quizzes.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '得分率: $_correctCount/${_currentIndex + (_isAnswered ? 1 : 0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),

              // Question Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '单选题',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      quiz.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Choice Options List
              Expanded(
                child: ListView.builder(
                  itemCount: quiz.options.length,
                  itemBuilder: (context, index) {
                    final option = quiz.options[index];
                    // Options usually start with prefix e.g. "A. ..."
                    final prefix = option.isNotEmpty ? option[0] : '';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      // Styled option card
                      child: _buildOptionCard(prefix, option),
                    );
                  },
                ),
              ),

              // Explanations Card appearing when answered
              if (_isAnswered) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedChoice == quiz.answer
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedChoice == quiz.answer ? Icons.check_circle : Icons.cancel,
                            color: _selectedChoice == quiz.answer ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedChoice == quiz.answer ? '回答正确！' : '回答错误！正确答案为 ${quiz.answer}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedChoice == quiz.answer ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '解析: ${quiz.explanation}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('下一题', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String prefix, String text) {
    final quiz = widget.quizzes[_currentIndex];
    
    Color cardBgColor = Colors.white;
    Color borderStrokeColor = Colors.transparent;
    Color prefixBgColor = const Color(0xFFF3F4F6);
    Color prefixTextColor = const Color(0xFF4B5563);
    Color bodyTextColor = const Color(0xFF1E293B);

    if (_isAnswered) {
      if (prefix == quiz.answer) {
        // Correct answer option (turns green)
        cardBgColor = const Color(0xFFECFDF5);
        borderStrokeColor = const Color(0xFF10B981);
        prefixBgColor = const Color(0xFF10B981);
        prefixTextColor = Colors.white;
        bodyTextColor = const Color(0xFF065F46);
      } else if (prefix == _selectedChoice) {
        // User selected incorrect answer option (turns red)
        cardBgColor = const Color(0xFFFEF2F2);
        borderStrokeColor = const Color(0xFFEF4444);
        prefixBgColor = const Color(0xFFEF4444);
        prefixTextColor = Colors.white;
        bodyTextColor = const Color(0xFF991B1B);
      } else {
        // Unselected neutral options during answer view (grayed out)
        cardBgColor = Colors.white.withOpacity(0.5);
      }
    } else {
      // Normal interactive state
      borderStrokeColor = Colors.white.withOpacity(0.8);
    }

    return InkWell(
      onTap: () => _selectOption(prefix),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderStrokeColor, width: _isAnswered ? 1.5 : 1),
          boxShadow: [
            if (!_isAnswered)
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Option prefix bubble (e.g. "A")
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: prefixBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                prefix,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: prefixTextColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Option text (without the prefix letter e.g. "A. ")
            Expanded(
              child: Text(
                text.length > 3 ? text.substring(3) : text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _isAnswered && (prefix == quiz.answer || prefix == _selectedChoice)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: bodyTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
