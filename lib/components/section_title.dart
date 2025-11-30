import 'package:agrosig_app/components/responsive.dart';
import 'package:agrosig_app/components/theme/colors_agroSig.dart';
import 'package:flutter/material.dart';
import 'constants/defaults.dart';
import 'constants/ghaps.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.color = ColorsAgrosig.textColor2,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
                Radius.circular(AppDefaults.borderRadius / 3)),
          ),
        ),
        gapW8,
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: Responsive.isDesktop(context) ? null : 20,
          ),
        )
      ],
    );
  }
}
