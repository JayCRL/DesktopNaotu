import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/sm2_algorithm.dart';

class FlashcardView extends StatefulWidget {
  final List<Flashcard> cards;
  final VoidCallback onFinished;

  const FlashcardView({
    Key? key,
    required this.cards,
    required this.onFinished,
  }) : super(key: key);

  @override
  _FlashcardViewState createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _revealAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _submitGrade(int grade) {
    if (_currentIndex >= widget.cards.length) return;

    final card = widget.cards[_currentIndex];
    
    // Calculate new SM-2 intervals (spaced repetition)
    card.history = SM2Algorithm.calculateNextReview(card.history, grade);

    // Dynamic transition to the next card
    setState(() {
      _showAnswer = false;
      if (_currentIndex < widget.cards.length - 1) {
        _currentIndex++;
        _fadeController.reset();
        _fadeController.forward();
      } else {
        _currentIndex++; // Complete review
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Finished Review State
    if (_currentIndex >= widget.cards.length) {
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '恭喜！复习完成',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '当前分支的所有待复习记忆卡已全部完成，您的脑图叶子已全部恢复生机！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

    final card = widget.cards[_currentIndex];

    // 2. Card Reviewing State
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('深度记忆卡片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
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
            children: [
              // Spacing indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '复习进度: ${_currentIndex + 1}/${widget.cards.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '稳健度: ${card.history.ease.toStringAsFixed(1)}x',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ),
              ),

              // The Glassmorphic Flashcard Card container
              Expanded(
                child: GestureDetector(
                  onTap: _showAnswer ? null : _revealAnswer,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _showAnswer ? '💡 解答与备注' : '❓ 概念检索提问',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Front content (always visible)
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                card.front,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          if (_showAnswer) const Divider(height: 1, color: Color(0xFFE2E8F0)),

                          // Back content (shown when user clicks)
                          Expanded(
                            flex: 4,
                            child: Center(
                              child: _showAnswer
                                  ? Text(
                                      card.back,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF475569),
                                        height: 1.6,
                                      ),
                                    )
                                  : const Text(
                                      '点击卡片揭晓答案',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Control Spaced Repetition Buttons panel
              _showAnswer
                  ? Column(
                      children: [
                        const Text(
                          '刚才的瞬间回忆感觉如何？',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Again
                            _buildReviewButton(
                              label: '不记得',
                              score: 1,
                              color: const Color(0xFFEF4444),
                            ),
                            // Hard
                            _buildReviewButton(
                              label: '模糊',
                              score: 3,
                              color: const Color(0xFFF59E0B),
                            ),
                            // Good
                            _buildReviewButton(
                              label: '记住',
                              score: 4,
                              color: const Color(0xFF10B981),
                            ),
                            // Easy
                            _buildReviewButton(
                              label: '秒懂',
                              score: 5,
                              color: const Color(0xFF6366F1),
                            ),
                          ],
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _revealAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                      ),
                      child: const Text(
                        '翻面揭晓答案',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewButton({required String label, required int score, required Color color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _submitGrade(score),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.08),
            foregroundColor: color,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            side: BorderSide(color: color.withOpacity(0.2), width: 1),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
