import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/home_item_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/input_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/logic/blocs/blocs/spreadsheet_bloc.dart';
import 'package:dailycalc/logic/blocs/events/spreadsheet_events.dart';
import 'package:dailycalc/logic/blocs/states/spreadsheet_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

enum AggregateType { sum, avg, min, max }
enum ParameterSelection { field, output }



class EditSheetScreen extends StatefulWidget {
  final SpreadSheetModel sheet;
  const EditSheetScreen({super.key, required this.sheet});

  @override
  State<EditSheetScreen> createState() => _EditSheetScreenState();
}

class _EditSheetScreenState extends State<EditSheetScreen> {
  late CardModel card;

  bool showAggregateColumn = true;
  bool showAggregateRow = false;

  String? activeFieldSym;
  ParameterSelection selectedParam = ParameterSelection.field;
  bool showOutput = false;

  AggregateType aggregateType = AggregateType.sum;
  SheetSort currentSort = SheetSort.nameAsc;


  @override
  void initState() {
    super.initState();
    card = context.read<CardRepository>().getCardById(widget.sheet.cardId)!;
    activeFieldSym = card.fields.first.sym;
  }

  // --------------------------------------------------
  // Helpers
  // --------------------------------------------------

  

  String formatDate(int ts) =>
      DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(ts));

  double aggregate(List<double> values) {
    if (values.isEmpty) return 0;
    switch (aggregateType) {
      case AggregateType.sum:
        return values.reduce((a, b) => a + b);
      case AggregateType.avg:
        return values.reduce((a, b) => a + b) / values.length;
      case AggregateType.min:
        return values.reduce((a, b) => a < b ? a : b);
      case AggregateType.max:
        return values.reduce((a, b) => a > b ? a : b);
    }
  }

  String resolveCell(HomeModel home, int date) {
    final item = home.items
        .where((i) => i.date == date)
        .cast<HomeItemModel?>()
        .firstWhere((i) => i != null, orElse: () => null);

    if (item == null) return '';

    if (showOutput) return item.output.toString();

    final input = item.inputs
        .where((i) => i.name == activeFieldSym)
        .cast<InputModel?>()
        .firstWhere((i) => i != null, orElse: () => null);

    return input?.value.toString() ?? '';
  }

  // --------------------------------------------------
  // Build
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpreadsheetBloc, SpreadSheetState>(
      listenWhen: (_, s) => s is SheetLoading,
      listener: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully')),
        );
      },
      child: BlocBuilder<SpreadsheetBloc, SpreadSheetState>(
        builder: (context, state) {
          if (state is! SheetLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final sheet = state.sheets.firstWhere(
            (s) => s.createdOn == widget.sheet.createdOn,
          );

          final homes = sheet.homeCardIds
              .map((id) =>
                  context.read<HomeRepository>().getHomeById(id))
              .whereType<HomeModel>()
              .toList();

          final dates = homes
              .expand((h) => h.items)
              .map((i) => i.date)
              .toSet()
              .toList()
            ..sort();

          return Scaffold(
            appBar: AppBar(
              title: Text(sheet.name),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (v) => _handleMenu(v, sheet),
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    CheckedPopupMenuItem(
                      value: 'agg_col',
                      checked: showAggregateColumn,
                      child: const Text('Aggregate Column'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'agg_row',
                      checked: showAggregateRow,
                      child: const Text('Aggregate Row'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'param',
                      child: Text('Select Parameter'),
                    ),
                    const PopupMenuItem(
                      value: 'agg_type',
                      child: Text('Aggregate Type'),
                    ),
                    const PopupMenuItem(
                      value: 'sort',
                      child: Text('Sort / Filter'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'homes',
                      child: Text('Add / Remove Homes'),
                    ),
                  ],
                ),

              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: const Icon(Icons.add),
              onPressed: _addDateColumn,
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(120),
                  border: TableBorder.all(),
                  children: [
                    _buildHeader(dates, aggregateType.toString().replaceAll("AggregateType.", "")),
                    ..._sortedHomes(homes).map((h) => _buildRow(h, dates)),
                    if (showAggregateRow) _buildAggregateRow(homes, dates, aggregateType.toString().replaceAll("AggregateType.", "")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // Table
  // --------------------------------------------------

  TableRow _buildHeader(List<int> dates, String aggregateType) {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (showAggregateColumn)
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(aggregateType, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ...dates.map((d) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(formatDate(d),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }

  void _selectSort() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sort Rows'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SheetSort.values.map(
            (s) => RadioListTile<SheetSort>(
              title: Text(
                switch (s) {
                  SheetSort.nameAsc => 'Name ↑',
                  SheetSort.nameDesc => 'Name ↓',
                  SheetSort.dateAsc => 'Date ↑',
                  SheetSort.dateDesc => 'Date ↓',
                },
              ),
              value: s,
              groupValue: currentSort,
              onChanged: (v) {
                setState(() => currentSort = v!);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }


  TableRow _buildRow(HomeModel home, List<int> dates) {
    final rowValues = dates
        .map((d) => double.tryParse(resolveCell(home, d)) ?? 0)
        .toList();

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(home.name)),
        if (showAggregateColumn)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(aggregate(rowValues).toStringAsFixed(2)),
          ),
        ...dates.map(
          (d) => GestureDetector(
            onTap: showOutput ? null : () => _editCell(home, d),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(resolveCell(home, d)),
            ),
          ),
        ),
      ],
    );
  }

  

  Future<void> _manageHomes(SpreadSheetModel sheet) async {
    final homeRepo = context.read<HomeRepository>();

    // all homes of same card
    var allHomes = homeRepo
        .getAll()
        .where((h) => h.type.createdOn == sheet.cardId)
        .toList();
    allHomes.sort((a,b) => b.createdOn - a.createdOn);

    // current selection
    final selected = <int>{...sheet.homeCardIds};

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Homes'),
        content: StatefulBuilder(
          builder: (context, setLocal) => SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: allHomes.map((home) {
                return CheckboxListTile(
                  title: Text(home.name),
                  subtitle: Text(formatDate(home.createdOn*1000)),
                  value: selected.contains(home.createdOn),
                  onChanged: (v) {
                    setLocal(() {
                      if (v == true) {
                        selected.add(home.createdOn);
                      } else {
                        selected.remove(home.createdOn);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              context.read<SpreadsheetBloc>().add(
                    UpdateSheetHomes(
                      sheet: sheet,
                      homeIds: selected.toList(),
                    ),
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  List<HomeModel> _sortedHomes(List<HomeModel> homes) {
    final list = [...homes];

    switch (currentSort) {
      case SheetSort.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SheetSort.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SheetSort.dateAsc:
        list.sort((a, b) => a.createdOn.compareTo(b.createdOn));
        break;
      case SheetSort.dateDesc:
        list.sort((a, b) => b.createdOn.compareTo(a.createdOn));
        break;
    }
    return list;
  }



  Future<void> _addDateColumn() async {
    final bloc = context.read<SpreadsheetBloc>();

    final homeRepo = context.read<HomeRepository>();
    final card = context.read<CardRepository>().getCardById(widget.sheet.cardId)!;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    final date = DateTime(
      picked.year,
      picked.month,
      picked.day,
    ).millisecondsSinceEpoch;


    bool alreadyExists = false;

    for (final homeId in widget.sheet.homeCardIds) {
      final home = homeRepo.getHomeById(homeId);
      if (home == null) continue;

      if (home.items.any((i) => i.createdOn == date)) {
        alreadyExists = true;
        break;
      }
    }

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date already exists')),
      );
      return;
    }

    // Add empty item for each home
    for (final homeId in widget.sheet.homeCardIds) {
      final home = homeRepo.getHomeById(homeId);
      if (home == null) continue;

      final newItem = HomeItemModel(
        note: "",
        createdOn: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        date: date,
        inputs: card.fields
            .map(
              (f) => InputModel(
                name: f.sym,
                value: '',
              ),
            )
            .toList(),
        output: 0.0,
      );

      homeRepo.updateHome(
        home.copyWith(items: [...home.items, newItem]),
      );
    }

    // Force spreadsheet reload
    bloc.add(LoadSheets());
  }


  TableRow _buildAggregateRow(List<HomeModel> homes, List<int> dates, String aggregateType) {
    return TableRow(
      children: [
        Padding(padding: EdgeInsets.all(8), child: Text(aggregateType)),
        if (showAggregateColumn)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              aggregate(homes.map((h) {
                return aggregate(dates
                    .map((d) =>
                        double.tryParse(resolveCell(h, d)) ?? 0)
                    .toList());
              }).toList()).toStringAsFixed(2),
            ),
          ),
        ...dates.map((d) {
          final values = homes
              .map((h) => double.tryParse(resolveCell(h, d)) ?? 0)
              .toList();
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(aggregate(values).toStringAsFixed(2)),
          );
        }),
      ],
    );
  }

  // --------------------------------------------------
  // Cell editing
  // --------------------------------------------------

  void _editCell(HomeModel home, int date) {
    final controller = TextEditingController(text: resolveCell(home, date));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${home.name} • ${activeFieldSym ?? "Output"}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveCell(home, date, controller.text);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveCell(HomeModel home, int date, String value) {
    final repo = context.read<HomeRepository>();

    final item = home.items
        .where((i) => i.date == date)
        .cast<HomeItemModel?>()
        .firstWhere((i) => i != null, orElse: () => null);

    // update existing
    if (item != null) {
      final updatedInputs = item.inputs.map((i) {
        return i.name == activeFieldSym ? i.copyWith(value: value) : i;
      }).toList();

      context
          .read<SpreadsheetBloc>()
          .add(UpdateSheetItem(home, item, updatedInputs));
      return;
    }


    String result = '';

    try {
      final parser = Parser();
      final cm = ContextModel();
      // Bind input values
      card.fields.forEach((f) {
        final numValue = double.tryParse(f.sym == activeFieldSym ? value : '') ?? 0.0;
        cm.bindVariable(Variable(f.sym), Number(numValue));
      });

      String lastOutput = '';

      final formulas = [...card.formulas]
        ..sort((a, b) => a.pos.compareTo(b.pos));

      for (final formula in formulas) {
        final exp = parser.parse(formula.expression);
        final value = exp.evaluate(EvaluationType.REAL, cm);

        // Store computed variable for next formulas
        cm.bindVariable(Variable(formula.sym), Number(value));
        lastOutput = value.toString();
      }

      result = lastOutput;
    } catch (e) {
      result = 'Error';
    }

    // create new item
    final newItem = HomeItemModel(
      note: "",
      createdOn: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      date: date,
      inputs: card.fields
          .map((f) => InputModel(
                name: f.sym,
                value: f.sym == activeFieldSym ? value : '',
              ))
          .toList(),
      output: double.tryParse(result) ?? 0.0,
    );

    repo.updateHome(home.copyWith(items: [...home.items, newItem]));
    context.read<SpreadsheetBloc>().add(LoadSheets());
  }

  // --------------------------------------------------
  // Menus
  // --------------------------------------------------

  void _handleMenu(String value, SpreadSheetModel sheet) {
    if (value == 'agg_col') {
      setState(() => showAggregateColumn = !showAggregateColumn);
    } else if (value == 'agg_row') {
      setState(() {
        showAggregateRow = !showAggregateRow;
        showAggregateColumn = true;
      });
    } else if (value == 'param') {
      _selectParameter();
    } else if (value == 'agg_type') {
      _selectAggregateType();
    } else if (value == 'sort') {
      _selectSort();
    } else if (value == 'homes') {
      _manageHomes(sheet);
    }
  }


  void _selectParameter() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Parameter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...card.fields.map(
              (f) => RadioListTile<String>(
                title: Text(f.sym),
                value: f.sym,
                groupValue:
                    selectedParam == ParameterSelection.field ? activeFieldSym : null,
                onChanged: (v) {
                  setState(() {
                    selectedParam = ParameterSelection.field;
                    activeFieldSym = v!;
                    showOutput = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            RadioListTile<ParameterSelection>(
              title: const Text('Output (read only)'),
              value: ParameterSelection.output,
              groupValue: selectedParam,
              onChanged: (_) {
                setState(() {
                  selectedParam = ParameterSelection.output;
                  showOutput = true;
                  activeFieldSym = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectAggregateType() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aggregate Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AggregateType.values
              .map(
                (t) => RadioListTile(
                  title: Text(t.name.toUpperCase()),
                  value: t,
                  groupValue: aggregateType,
                  onChanged: (v) {
                    setState(() => aggregateType = v!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
