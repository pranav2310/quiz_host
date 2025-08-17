import 'dart:html' as html;

Future<void> downloadLeaderboard(String quizTitle, String sessionId, String csvData)async{
  final blob = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'leaderboard_${quizTitle}_$sessionId.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
}