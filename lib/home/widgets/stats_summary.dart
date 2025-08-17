import 'package:flutter/material.dart';

class StatsSummary extends StatelessWidget{
  const StatsSummary({
    super.key,
    required this.quizCount,
    required this.sessionCount,
    required this.playerCount,
    required this.activeSession
  });

  final int quizCount;
  final int sessionCount;
  final int playerCount;
  final int activeSession;

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Wrap(
            runSpacing: 8,
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              StatsCard(
                title: 'Total Quizes',
                value: quizCount,
                icon: Icons.question_answer,
              ),
              StatsCard(
                title: 'Total Quizes Hosted',
                value: sessionCount,
                icon: Icons.event,
              ),
              StatsCard(
                title: 'Total Players joined',
                value: playerCount,
                
                icon: Icons.people,
              ),
              StatsCard(
                title: 'Active Sessions',
                value: activeSession,
                
                icon: Icons.event,
              ),
            ],
          ),
        );
  }
}

class StatsCard extends StatelessWidget{
  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon
  });
  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}