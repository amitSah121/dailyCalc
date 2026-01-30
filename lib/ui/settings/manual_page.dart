
import 'package:flutter/material.dart';

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
            CalculatorTab(),
            HomeTab(),
            SheetTab(),
            CardTab(),
            SettingsTab(),
          ],
        ),
      ),
    );
  }
}

/// Template for Calculator Tab
class CalculatorTab extends StatelessWidget {
  const CalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Video Section
        Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(child: Text("Video Placeholder")),
        ),
        const SizedBox(height: 12),
        // Text Section
        const Text(
          "This is some explanatory text about the calculator.",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        // Another video
        Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(child: Text("Video Placeholder")),
        ),
        const SizedBox(height: 12),
        // Another text
        const Text(
          "More detailed description and tips for using the calculator.",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home Tab Content"));
  }
}

/// Template for Sheet Tab
class SheetTab extends StatelessWidget {
  const SheetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Sheet Tab Content"));
  }
}

/// Template for Card Tab
class CardTab extends StatelessWidget {
  const CardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Card Tab Content"));
  }
}

/// Template for Settings Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Settings Tab Content"));
  }
}
