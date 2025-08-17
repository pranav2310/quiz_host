import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget{
  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabels,
    required this.buttonOnPressed,
    required this.buttonIcon,
  });
  final String title;
  final String subtitle;
  final List<String> buttonLabels;
  final List<VoidCallback> buttonOnPressed;
  final List<IconData> buttonIcon;
    
  Widget _cardButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required BuildContext context
  }) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        onPressed: onPressed,
        label: Text(label),
        icon: Icon(icon, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                buttonLabels.length,
                (i)=>_cardButton(icon: buttonIcon[i], label: buttonLabels[i], onPressed: buttonOnPressed[i],context: context)
                )
            ),
          ],
        ),
      ),
    );
  }
}