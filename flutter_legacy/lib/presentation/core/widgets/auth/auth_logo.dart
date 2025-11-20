import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final fontSize = screenWidth < 400
                ? 16.0
                : screenWidth < 600
                    ? 18.0
                    : screenWidth < 900
                        ? 20.0
                        : 24.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 48.0,
                  width: 48.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'GameMaster Hub',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Optimisez vos équipes, dominez vos jeux',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
