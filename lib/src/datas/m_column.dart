part of merge_table;

abstract class BaseMColumn {
  final Widget header;
  final List<Widget>? columns;

  bool get isMergedColumn => columns != null;

  BaseMColumn({
    required this.header,
    this.columns,
  });
}

class MColumn extends BaseMColumn {
  MColumn({
    required Widget header,
  }) : super(header: header, columns: null);
}

class MMergedColumns extends BaseMColumn {
  @override
  List<Widget> get columns => super.columns!;

  MMergedColumns({
    required Widget header,
    required List<Widget> columns,
  }) : super(columns: columns, header: header);
}
