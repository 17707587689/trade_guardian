import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../repositories/trade_plan_repository.dart';
import '../repositories/trading_rule_repository.dart';
import '../services/data_export_service.dart';
import '../services/data_import_service.dart';

class DataManagePage extends StatefulWidget {
  const DataManagePage({super.key});

  @override
  State<DataManagePage> createState() => _DataManagePageState();
}

class _DataManagePageState extends State<DataManagePage> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    // 选择导出格式
    final format = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择导出格式'),
          content: const Text('请选择要导出的文件格式：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('json'),
              child: const Text('JSON'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('csv'),
              child: const Text('CSV'),
            ),
          ],
        );
      },
    );

    if (format == null || !mounted) return;

    setState(() => _isExporting = true);
    try {
      final planRepo = TradePlanRepository();
      final ruleRepo = TradingRuleRepository();
      final plans = await planRepo.getAllPlans();
      final rules = await ruleRepo.getAllRules();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在导出数据...'),
          duration: Duration(seconds: 1),
        ),
      );

      String filePath;
      if (format == 'csv') {
        filePath = await DataExportService.saveCsvFile(
          tradePlans: plans,
          tradingRules: rules,
        );
      } else {
        filePath = await DataExportService.saveExportFile(
          tradePlans: plans,
          tradingRules: rules,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('数据已保存到: $filePath'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      // 选择 JSON 文件
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return;
      }

      // 读取文件内容
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // 询问是否覆盖现有数据
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('导入选项'),
            content: const Text(
              '是否覆盖现有数据？\n\n选择"覆盖"将先清空所有现有数据再导入。\n选择"追加"则保留现有数据，仅添加新的数据。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('追加（保留现有数据）'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('覆盖'),
              ),
            ],
          );
        },
      );

      if (!mounted || overwrite == null) return;

      final importService = DataImportService();
      final importResult = await importService.importFromJson(
        jsonString,
        overwrite: overwrite,
      );

      if (!mounted) return;

      // 显示导入结果
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  importResult.hasErrors
                      ? Icons.warning_amber
                      : Icons.check_circle,
                  color: importResult.hasErrors ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(importResult.hasErrors ? '导入完成（有错误）' : '导入成功'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow(
                  Icons.assignment,
                  '交易计划',
                  '${importResult.planCount} 条',
                ),
                const SizedBox(height: 8),
                _buildResultRow(
                  Icons.rule,
                  '交易原则',
                  '${importResult.ruleCount} 条',
                ),
                if (importResult.hasErrors) ...[
                  const Divider(height: 20),
                  const Text(
                    '错误详情：',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...importResult.errors.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导入失败: $e')));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          '数据管理',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 说明卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF667eea), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '导出备份可将所有交易计划和交易原则保存为 JSON 文件，以便在版本更新后导入恢复数据。',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 导出卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.file_upload_outlined,
                      size: 32,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '导出备份',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '将所有数据导出为 JSON 文件',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isExporting ? null : _exportData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '立即导出',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 导入卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.file_download_outlined,
                      size: 32,
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '导入备份',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '从 JSON 文件恢复数据',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : _importData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isImporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '选择文件导入',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
