// file: merge_table.dart
part of merge_table;

class MergeTable extends StatelessWidget {
  MergeTable({
    Key? key,
    required this.rows,
    required this.columns,
    required this.borderColor,
    required this.rowHeight,
    required this.headerColor,
    required this.columnsColor,
    required this.rowsColor,
    this.alignment = MergeTableAlignment.center,
  }) : super(key: key) {
    assert(columns.isNotEmpty);
    assert(rows.isNotEmpty);

    // تحقق أن كل صف له نفس عدد الأعمدة
    for (final row in rows) {
      assert(row.length == columns.length);
    }

    columnWidths = _buildColumnWidths(columns);
  }

  final Color headerColor;
  final Color columnsColor;
  final Color rowsColor;
  final Color borderColor;
  final List<BaseMColumn> columns;
  final List<List<BaseMRow>> rows;
  final MergeTableAlignment alignment;
  final double rowHeight;

  late final Map<int, TableColumnWidth> columnWidths;

  TableCellVerticalAlignment get defaultVerticalAlignment =>
      alignment.tableAlignment;
  AlignmentGeometry get alignmentGeometry => alignment.geometry;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: borderColor),
      columnWidths: columnWidths,
      defaultVerticalAlignment: defaultVerticalAlignment,
      children: [
        _buildHeader(),
        ..._buildRows(),
      ],
    );
  }

  /// Header row
  TableRow _buildHeader() {
    return TableRow(
      children: List.generate(columns.length, (i) {
        final column = columns[i];

        if (column.isMergedColumn) {
          return _buildMergedColumn(column);
        }
        return _buildSingleCell(column.header, headerColor);
      }),
    );
  }

  /// Data rows
  List<TableRow> _buildRows() {
    return List.generate(rows.length, (rowIndex) {
      final items = rows[rowIndex];

      return TableRow(
        children: List.generate(items.length, (colIndex) {
          final item = items[colIndex];

          if (item.inlineRow.length > 1) {
            return _buildMultiColumns(
              item.inlineRow,
              rowsColor,
            );
          }

          return _buildSingleCell(item.inlineRow.first, rowsColor);
        }),
      );
    });
  }

  /// Column with sub-columns under it
  Widget _buildMergedColumn(BaseMColumn column) {
    return Column(
      children: [
        _buildSingleCell(column.header, headerColor),
        Divider(color: borderColor, height: 1, thickness: 1),
        _buildMultiColumns(
          List.generate(
            column.columns!.length,
            (i) => column.columns![i],
          ),
          columnsColor,
        ),
      ],
    );
  }

  /// Multi-column builder for merged rows/headers
  Widget _buildMultiColumns(List<Widget> values, Color background) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double colWidth = constraints.maxWidth / values.length;

        final children = List.generate(values.length, (i) {
          return SizedBox(
            width: colWidth,
            child: _buildSingleCell(values[i], background),
          );
        });

        return Container(
          height: rowHeight,
          decoration: BoxDecoration(color: background),
          child: IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < children.length - 1; i++) ...[
                  children[i],
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: borderColor,
                  ),
                ],
                children.last,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Basic cell
  Widget _buildSingleCell(Widget child, Color color) {
    return Container(
      alignment: alignmentGeometry,
      decoration: BoxDecoration(color: color),
      child: child,
    );
  }

  /// Calculate table column widths
  Map<int, TableColumnWidth> _buildColumnWidths(List<BaseMColumn> columns) {
    final widths = <int, TableColumnWidth>{};

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];

      /// why: نمنح الأعمدة المدموجة flex أكبر لأنها تحتوي أكثر من حقل
      widths[i] = FlexColumnWidth(
        col.isMergedColumn ? col.columns!.length.toDouble() : 1,
      );
    }
    return widths;
  }
}
