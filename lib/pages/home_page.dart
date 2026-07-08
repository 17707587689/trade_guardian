import 'package:flutter/material.dart';

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

            ElevatedButton(
              onPressed: () {
                // 下一版本实现
              },

              child: const Text("新建交易计划"),
            ),
          ],
        ),
      ),
    );
  }
}
