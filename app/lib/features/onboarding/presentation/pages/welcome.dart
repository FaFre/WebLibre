import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        FractionallySizedBox(
          widthFactor: 0.5,
          child: SvgPicture.asset('assets/icon/icon.svg'),
        ),
        const SizedBox(height: 24),
        Text(
          'The Privacy-Focused Browser',
          softWrap: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
