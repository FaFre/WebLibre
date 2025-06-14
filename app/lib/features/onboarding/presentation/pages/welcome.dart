import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FractionallySizedBox(
          widthFactor: 0.5,
          child: Image.asset('assets/icon/icon.png'),
        ),
        Text(
          'The Privacy-Focused Browser',
          softWrap: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }
}
