import 'package:flutter/material.dart';
import 'models/mind_map_node.dart';
import 'services/mind_map_parser.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const DesktopNaotuMobileApp());
}

class DesktopNaotuMobileApp extends StatelessWidget {
  const DesktopNaotuMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Premium Slate-Indigo Day Theme
    return MaterialApp(
      title: '桌面版脑图移动端',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF4F46E5),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF4B5563)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainLoader(),
    );
  }
}

class MainLoader extends StatelessWidget {
  const MainLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Ready-to-test mock JSON representing a complete mind-mapping file
    // that conforms exactly to our KityMinder + Mobile Active Recall extended schema!
    const String mockKityMinderJson = '''
    {
      "root": {
        "data": {
          "id": "root_node_01",
          "text": "✨ Electron 无边框与毛玻璃重构",
          "notes": "这是第二阶段美化重构的核心总结大纲，包含了无边框窗口、毛玻璃工具栏、矢量图标和 Canvas 节点样式覆盖的所有核心知识点。",
          "flashcards": [
            {
              "id": "fc_001",
              "front": "在 Electron 中，如何将窗口配置为隐藏原生标题栏和边框的“无边框窗口”？",
              "back": "在主进程 `BrowserWindow` 实例化参数中，传入 `frame: false` 属性即可实现无边框模式。",
              "type": "qa"
            },
            {
              "id": "fc_002",
              "front": "在 CSS 中，开启高阶毛玻璃磨砂滤镜效果（Glassmorphism）的核心属性是什么？",
              "back": "使用 `backdrop-filter: blur(12px);` 搭配带透明度的白底 `background: rgba(255, 255, 255, 0.78);`。",
              "type": "qa"
            }
          ]
        },
        "children": [
          {
            "data": {
              "id": "child_node_01",
              "text": "🎨 SVG 矢量图标升级",
              "notes": "将 2015 版的 PNG 拼合图彻底移除，全面替换为 Feather 风格 of SVG 矢量图。",
              "flashcards": [
                {
                  "id": "fc_003",
                  "front": "为什么在高清或 Retina 屏下要用 SVG 矢量 Data-URI 替换传统的 PNG 雪碧图？",
                  "back": "因为传统的 PNG 放大时会出现像素化与毛边锯齿，而 SVG 矢量图基于数学路径渲染，在任何分辨率下都能保持绝对锐利。",
                  "type": "qa"
                }
              ],
              "quizzes": [
                {
                  "id": "qz_001",
                  "question": "使用 CSS 加载 SVG 矢量图标时，为了防止在大屏上模糊，我们使用哪种图片格式来进行高效率的内联加载？",
                  "type": "single_choice",
                  "options": [
                    "A. Base64 编码的 PNG",
                    "B. WebP 静态图片",
                    "C. SVG 矢量 Data-URI (url('data:image/svg+xml;...'))",
                    "D. Webfont 字体包"
                  ],
                  "answer": "C",
                  "explanation": "使用内联 SVG 矢量 Data-URI 能在大屏上保持 100% 矢量清晰度，且免去了额外的网络 HTTP 请求，加载速度极快。"
                }
              ]
            },
            "children": []
          },
          {
            "data": {
              "id": "child_node_02",
              "text": "🧠 节点样式穿透与高亮",
              "notes": "通过动态在渲染器中向 SVG DOM 注入 level 与 selected 类实现定制。",
              "flashcards": [
                {
                  "id": "fc_004",
                  "front": "KityMinder 的 Canvas 节点是由 SVG 组成的，为什么我们在 CSS 中直接写类名无法生效？如何穿透限制？",
                  "back": "因为 KityMinder 默认不给 SVG group 挂载 level 和 selected 类。我们可以通过在 `app/src/index.ts` 中监听 `layoutallfinish` 事件，并在此时遍历节点动态往 `rc.node` 添加 `level-X` 和 `selected` 类名来进行样式穿透。",
                  "type": "qa"
                }
              ],
              "quizzes": [
                {
                  "id": "qz_002",
                  "question": "以下哪种 CSS 属性用于设置 SVG `rect` 元素的圆角半径，以便呈现出高品味的毛玻璃卡片节点？",
                  "type": "single_choice",
                  "options": [
                    "A. border-radius",
                    "B. corner-radius",
                    "C. rx 与 ry (如 rx: 12px; ry: 12px;)",
                    "D. stroke-radius"
                  ],
                  "answer": "C",
                  "explanation": "在 SVG 中，`<rect>` 元素的圆角半径由 `rx`（X轴半径）和 `ry`（Y轴半径）控制。在现代浏览器下支持直接在 CSS 中通过 `rx` / `ry` 进行覆盖。"
                }
              ]
            },
            "children": []
          }
        ]
      }
    }
    ''';

    try {
      // 2. Parse the extended JSON string into tree structures
      final MindMapNode root = MindMapParser.parseJson(mockKityMinderJson);
      
      // 3. Render home screen
      return HomeScreen(rootNode: root);
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text('载入脑图出错: $e'),
        ),
      );
    }
  }
}
