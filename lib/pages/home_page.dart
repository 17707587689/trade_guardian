import 'package:flutter/material.dart';

import 'rules_manage_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TradeGuardian")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "交易纪律守护",

              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("记录计划，而不是预测市场", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 40),

            ElevatedButton(onPressed: () {}, child: const Text("新建交易计划")),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RulesManagePage()),
                );
              },
              child: const Text("管理交易纪律"),
            ),
          ],
        ),
      ),
    );
  }
}
