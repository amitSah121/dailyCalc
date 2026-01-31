
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // 5 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manual Page"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Calculator"),
              Tab(text: "Home"),
              Tab(text: "Sheet"),
              Tab(text: "Card"),
              Tab(text: "Settings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TabThis(video:  'assets/videos/calc_output.mp4', text: "Calculator Overview\n\n"
          "This calculator helps you quickly perform accurate calculations "
          "using predefined formulas and unit conversions. You can enter "
          "values, select options, and instantly see results without needing "
          "to remember complex equations.\n\n"
          "It is designed to be simple, fast, and flexible—ideal for everyday "
          "calculations, conversions, and learning how formulas work behind "
          "the scenes."
          "\n\n"
          "You can also use formulas section to extend your calculations. "
          "There are many pre defined formulas, and there are also"
          " many formulas you can make yourself."
          "\n\n"
          "It adapts dynamically to each card, supports multiple input types, and updates results in real time. This eliminates manual calculations and reduces errors during daily financial tasks.",),
          TabThis(video:  'assets/videos/home_output.mp4', text: "Home Overview\n\n"
          "Home is the central place where all your calculation cards live. "
          "\n\n"
          "Here you can quickly access your saved calculation cards such as interest, percentage, savings, or any custom formula you’ve created. Favorite cards appear at the top, making repetitive daily calculations faster and easier."
          "\n\n"
          "This screen is designed for speed—open the app, pick a card, and start calculating immediately.",),
          TabThis(video:  'assets/videos/sheets_output.mp4', text: "Sheets Overview\n\n"
          "The Sheet screen helps you organize and reuse your calculations in a structured way. "
          "\n\n"
          "It allows you to work with multiple inputs and results together, making it useful for tracking daily collections, expenses, or repeated numeric entries. Sheets act as a lightweight workspace where values can be reviewed and reused without re-entering everything again."
          "\n\n"
          "This is especially useful for shopkeepers, collectors, and students working with tabular data.",),
          TabThis(video:  'assets/videos/formulas_output.mp4', text: "Formulas Overview\n\n"
          "The Formulas screen is where the real power of DailyCalc lives. "
          "\n\n"
          "Here you can create, view, and manage custom formulas using simple variables and expressions. These formulas drive your calculation cards and allow you to adapt the app to your exact needs—whether it’s interest calculation, unit conversion, or project-specific math."
          "\n\n"
          "It’s built for flexibility, giving you control without forcing you into complex tools.",),
          TabThis(video:  'assets/videos/settings_output.mp4', text: "Settings Overview\n\n"
          "The Settings screen provides information and configuration options for DailyCalc. "
          "\n\n"
          "Here you can learn more about the app, check version details, and explore future features as they become available. This section is designed to stay simple while leaving room for upcoming enhancements such as backups, exports, and customization options.",),
          ],
        ),
      ),
    );
  }
}


class TabThis extends StatefulWidget {
  final String video;
  final String text;
  const TabThis({this.video="", this.text="",super.key});

  @override
  State<TabThis> createState() => _TabThisState();
}

class _TabThisState extends State<TabThis> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.video,
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /// 🎥 Video Section
        if (_controller.value.isInitialized)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 600,
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),

              if (!_controller.value.isPlaying)
                IconButton(
                  iconSize: 56,
                  icon: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.play();
                    });
                  },
                ),
            ],
          )

        else
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),

        const SizedBox(height: 20),

        /// 📝 Text Section
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );

  }
}

