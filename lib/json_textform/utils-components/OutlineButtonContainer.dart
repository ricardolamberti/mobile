import 'package:flutter/material.dart';

class OutlineButtonContainer extends StatelessWidget {
  final bool isOutlined;
  final bool isFilled;
  final Widget child;

  const OutlineButtonContainer({
    super.key,
    this.isOutlined = false,
    this.isFilled = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isOutlined
          ? null
          : isFilled
              ? Theme.of(context).inputDecorationTheme.fillColor
              : null,
      decoration: isOutlined
          ? BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
              color: isFilled
                  ? Theme.of(context).inputDecorationTheme.fillColor
                  : null,
            )
          : null,
      child: child,
    );
  }
}
