import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadLeaderboard(String quizTitle, String sessionId, String csvData)async{
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/leaderboard_${quizTitle}_$sessionId.csv';
  final file = File(path);
  await file.writeAsString(csvData);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}