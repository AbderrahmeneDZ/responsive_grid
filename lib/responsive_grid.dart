import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'enums.dart';
import 'res_grid_item.dart';

class ResGrid extends StatelessWidget {
  final int gridSize;
  final double colSpacing;
  final double rowSpacing;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;

  final List<ResGridItem> children;
  const ResGrid(
      {required this.children,
      this.gridSize = 12,
      this.colSpacing = 0,
      this.rowSpacing = 0,
      this.rowMainAxisAlignment = MainAxisAlignment.start,
      this.rowCrossAxisAlignment = CrossAxisAlignment.stretch,
      this.columnMainAxisAlignment = MainAxisAlignment.start,
      this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      final rows = buildRows(context, constraints.maxWidth);

      return Column(
        mainAxisAlignment: columnMainAxisAlignment,
        crossAxisAlignment: columnCrossAxisAlignment,
        children: rows,
      );
    }));
  }

  List<Widget> buildRows(BuildContext context, double parentWidth) {
    List<Widget> rows = [];

    double width = MediaQuery.of(context).size.width;
    ScreenCategory currentScreenCategory = getScreenCategory(width);

    int remainingCols = gridSize;
    List<ResGridItem> currentRow = [];

    for (int index = 0; index < children.length; index++) {
      final child = children[index];
      int span = child.getColumnSizeByCategory(currentScreenCategory, gridSize);

      // if the remaining span is not enough to contain the current child, new row is created
      if (span > remainingCols) {
        pushRow(currentRow, rows, parentWidth, remainingCols,
            currentScreenCategory);

        remainingCols = gridSize;
        currentRow = [];
      }

      currentRow.add(child);

      remainingCols -= span;

      if (index + 1 == children.length) {
        pushRow(currentRow, rows, parentWidth, remainingCols,
            currentScreenCategory);
      }
    }

    return rows;
  }

  void pushRow(
    List<ResGridItem> currentRow,
    List<Widget> rows,
    double width,
    int remainingCols,
    ScreenCategory category,
  ) {
    List<SizedBox> calculatedWidget = [];

    double adjustedWidth = 0;
    if (colSpacing > 0) {
      // int insertAt = 1;
      int spaceWidgetCount = currentRow.length - 1;
      adjustedWidth = (spaceWidgetCount * colSpacing) / currentRow.length;
    }

    double growBy = 0;
    if (remainingCols > 0) {
      int canGrowItemsCount =
          currentRow.where((elt) => elt.canGrow == true).toList().length;

      growBy = width / gridSize * remainingCols / canGrowItemsCount;
    }

    for (int index = 0; index < currentRow.length; index++) {
      ResGridItem item = currentRow[index];
      double colWidth =
          width / gridSize * item.getColumnSizeByCategory(category, gridSize);

      if (item.canGrow) {
        colWidth += growBy;
      }

      if (colSpacing == 0) {
        calculatedWidget.add(SizedBox(
          child: item,
          width: colWidth,
        ));
      } else {
        colWidth -= adjustedWidth;
        calculatedWidget.add(SizedBox(
          child: item,
          width: colWidth,
        ));

        if (index + 1 != currentRow.length && currentRow.length != 1) {
          calculatedWidget.add(SizedBox(
            width: colSpacing,
          ));
        }
      }
    }

    rows.add(Row(
      crossAxisAlignment: rowCrossAxisAlignment,
      mainAxisAlignment: rowMainAxisAlignment,
      children: calculatedWidget,
    ));

    if (rowSpacing > 0 &&
        columnMainAxisAlignment != MainAxisAlignment.spaceAround) {
      rows.add(SizedBox(
        height: rowSpacing / 2,
      ));
    }
  }

  ScreenCategory getScreenCategory(double width) {
    if (width < 576) {
      return ScreenCategory.extraSmall;
    }

    if (width >= 576 && width < 768) {
      return ScreenCategory.small;
    }

    if (width >= 768 && width < 992) {
      return ScreenCategory.medium;
    }

    return ScreenCategory.large;
  }
}
