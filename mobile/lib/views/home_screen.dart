import 'package:flutter/material.dart';
import '../models/mind_map_node.dart';
import '../services/mind_map_parser.dart';
import 'flashcard_view.dart';
import 'quiz_view.dart';

class HomeScreen extends StatefulWidget {
  final MindMapNode rootNode;

  const HomeScreen({Key? key, required this.rootNode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeMode = 'hub'; // 'hub', 'flashcards', 'quizzes'

  @override
  Widget build(BuildContext context) {
    // Collect all data recursively
    final allCards = MindMapParser.extractAllFlashcards(widget.rootNode);
    final dueCards = MindMapParser.extractDueFlashcards(widget.rootNode);
    final allQuizzes = MindMapParser.extractAllQuizzes(widget.rootNode);

    // Dynamic view routing based on active mode
    if (_activeMode == 'flashcards') {
      return FlashcardView(
        cards: dueCards.isNotEmpty ? dueCards : allCards, // Prioritize due cards
        onFinished: () {
          setState(() {
            _activeMode = 'hub';
          });
        },
      );
    }

    if (_activeMode == 'quizzes') {
      return QuizView(
        quizzes: allQuizzes,
        onFinished: () {
          setState(() {
            _activeMode = 'hub';
          });
        },
      );
    }

    // Default Hub View (Day Glassmorphism Hub)
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '桌面版脑图 · 移动助手',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF6366F1)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('正在从 WebDAV 云端下载并增量同步最新脑图树文件...'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Loaded Mind Map overview card (Indigo Gradient Card)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bubble_chart, color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '当前载入思维导图',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.rootNode.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.rootNode.notes ?? '脑图节点大纲已完美编排，移动卡片就绪。',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. Active Recall & Quizzes Metrics Row (Grid)
              const Text(
                '知识点复习统计',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    title: '待复习卡片',
                    count: dueCards.length.toString(),
                    subtext: '基于SM-2算法推荐',
                    icon: Icons.timer,
                    iconColor: const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    title: '总知识闪卡',
                    count: allCards.length.toString(),
                    subtext: '节点关联卡片总数',
                    icon: Icons.style,
                    iconColor: const Color(0xFF6366F1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    title: '概念题库',
                    count: allQuizzes.length.toString(),
                    subtext: '单选与判断测试题',
                    icon: Icons.assignment,
                    iconColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    title: '大纲分支数',
                    count: _countTotalNodes(widget.rootNode).toString(),
                    subtext: '结构化思维总节点',
                    icon: Icons.account_tree,
                    iconColor: const Color(0xFF64748B),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Spaced Repetition Flashcard Action Button
              ElevatedButton(
                onPressed: allCards.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _activeMode = 'flashcards';
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.style),
                    const SizedBox(width: 8),
                    Text(
                      dueCards.isNotEmpty ? '开始今日闪卡复习 (${dueCards.length})' : '开始全量闪卡学习 (${allCards.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Quick quiz taking Action Button (Secondary white button)
              ElevatedButton(
                onPressed: allQuizzes.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _activeMode = 'quizzes';
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  disabledBackgroundColor: const Color(0xFFF1F5F9),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment),
                    const SizedBox(width: 8),
                    Text(
                      '进行概念答题评测 (${allQuizzes.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildStatCard({
    required String title,
    required String count,
    required String subtext,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 22),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  int _countTotalNodes(MindMapNode node) {
    int count = 1;
    for (var child in node.children) {
      count += _countTotalNodes(child);
    }
    return count;
  }
}
