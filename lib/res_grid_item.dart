import 'package:flutter/widgets.dart';

import 'enums.dart';

class ResGridItem extends StatelessWidget {
  final int col;
  final int? colSm;
  final int? colMd;
  final int? colLg;
  final Widget child;
  final bool canGrow;

  const ResGridItem(
      {required this.child,
      required this.col,
      this.colSm,
      this.colMd,
      this.colLg,
      this.canGrow = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  int getColumnSizeByCategory(ScreenCategory category, int rowSize) {
    int selectedCol = col;
    switch (category) {
      case ScreenCategory.extraSmall:
        selectedCol = col;
        break;
      case ScreenCategory.small:
        selectedCol = colSm != null ? colSm! : col;
        break;

      case ScreenCategory.medium:
        selectedCol = colMd != null
            ? colMd!
            : colSm != null
                ? colSm!
                : col;
        break;

      case ScreenCategory.large:
        selectedCol = colLg != null
            ? colLg!
            : colMd != null
                ? colMd!
                : colSm != null
                    ? colSm!
                    : col;
        break;
    }

    // if accidentally column span is greater than rowSize, span is set to rowSize
    if (selectedCol > rowSize) return rowSize;

    // if accidentally column span is lower than 1, span is set to 1
    if (selectedCol < 1) return 1;

    return selectedCol;
  }
}
