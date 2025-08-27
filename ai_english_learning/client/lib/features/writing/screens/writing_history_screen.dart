import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/writing_submission.dart';
import '../providers/writing_provider.dart';

class WritingHistoryScreen extends StatefulWidget {
  const WritingHistoryScreen({super.key});

  @override
  State<WritingHistoryScreen> createState() => _WritingHistoryScreenState();
}

class _WritingHistoryScreenState extends State<WritingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WritingProvider>(context, listen: false).loadSubmissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写作历史'),
      ),
      body: Consumer<WritingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.loadSubmissions(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (provider.submissions.isEmpty) {
            return const Center(
              child: Text('暂无写作记录'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.submissions.length,
            itemBuilder: (context, index) {
              final submission = provider.submissions[index];
              return Card(
                child: ListTile(
                  title: Text('写作任务 ${index + 1}'),
                  subtitle: Text(
                    '状态: ${submission.status.displayName}\n'
                    '字数: ${submission.wordCount}\n'
                    '时间: ${_formatDateTime(submission.submittedAt)}',
                  ),
                  trailing: submission.score != null
                      ? Text(
                          '${submission.score!.totalScore.toStringAsFixed(1)}分',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}