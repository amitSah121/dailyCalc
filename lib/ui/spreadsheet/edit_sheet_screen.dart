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
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

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
  bool showAggregateRow = true;

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

  

  String formatDate(int timestamp, context){
    if(Localizations.localeOf(context).languageCode == "ne"){

      final adDate =
          DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);

      final bsDate = NepaliDateTime.fromDateTime(adDate);
      return NepaliDateFormat("MMMM d, y").format(bsDate);
    }else{
      return DateFormat.yMMMMd(
              Localizations.localeOf(context).toString(),
            ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    }
  }

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

          final int _from = int.parse(sheet.name.split("__%*%__")[1]);
          final int _to = int.parse(sheet.name.split("__%*%__")[2]);

          final dates = homes
              .expand((h) => h.items)
              .map((i) => i.date)
              .where((d) => d >= _from && d <= _to)
              .toSet()
              .toList()
            ..sort();

          List<String> nameSplit = sheet.name.split("__%*%__");
          String justname = nameSplit[0];
          String afterJustName = '${nameSplit[1]}__%*%__${nameSplit[2]}';
          final justnameController = TextEditingController(text: justname);

          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: justnameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Home Name",
                  hintStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                style: TextStyle(color: Theme.of(context).primaryColorDark),
                onSubmitted: (value) {
                  context.read<SpreadsheetBloc>().add(UpdateSheetName(
                      '${value}__%*%__$afterJustName', sheet));
                },
              ),
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
                      value: 'daterange',
                      child: Text('Change Date Range'),
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
              onPressed: ()=>_addDateColumn(sheet),
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(150),
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
              child: Text(formatDate(d, context),
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
                  subtitle: Text(formatDate(home.createdOn*1000, context)),
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
        list.sort((a, b) => (a.name.split("__%*%__")[0]).toLowerCase().compareTo((b.name.split("__%*%__")[0]).toLowerCase()));
        break;
      case SheetSort.nameDesc:
        list.sort((a, b) => (b.name.split("__%*%__")[0]).toLowerCase().compareTo((a.name.split("__%*%__")[0]).toLowerCase()));
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



  Future<void> _addDateColumn(SpreadSheetModel sheet) async {
    final bloc = context.read<SpreadsheetBloc>();
    final homeRepo = context.read<HomeRepository>();
    final card = context.read<CardRepository>().getCardById(widget.sheet.cardId)!;

    int? pickedTimestamp;

    // Choose picker based on locale
    if (Localizations.localeOf(context).languageCode == "ne") {
      // Nepali (BS) date picker
      pickedTimestamp = await pickNepaliDateRaw(
        context: context,
        initialTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      // English / Gregorian date picker
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        pickedTimestamp = picked.millisecondsSinceEpoch;
      }
    }

    // If user canceled picker
    if (pickedTimestamp == null) return;

    // This is the AD timestamp (milliseconds since epoch)
    final date = pickedTimestamp;

    // Check if a date already exists
    bool alreadyExists = false;

    for (final homeId in sheet.homeCardIds) {
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
    for (final homeId in sheet.homeCardIds) {
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
    }else if (value == 'daterange') {
      _selectDateRange(sheet);
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

  Future<void> pickDate({
    required TextEditingController controller,
  }) async {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('d MMM yyyy').parse(controller.text);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);

    if (parsedDate.isBefore(firstDate)) parsedDate = firstDate;
    if (parsedDate.isAfter(lastDate)) parsedDate = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: parsedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      controller.text = formatDate(picked.millisecondsSinceEpoch, context);
    }
  }
  
  void _selectDateRange(SpreadSheetModel sheet) {
    int from = int.parse(sheet.name.split("__%*%__")[1]);
    int to = int.parse(sheet.name.split("__%*%__")[2]);

    final fromDateController = TextEditingController(
      text: formatDate(from, context),
    );

    final toDateController = TextEditingController(
      text: formatDate(to, context),
    );

    

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fromDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                ),
                onTap: () => Localizations.localeOf(context).languageCode == "en" ? pickDate(controller: fromDateController) : pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: fromDateController),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
                onTap: () => Localizations.localeOf(context).languageCode == "en" ? pickDate(controller: toDateController) : pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: toDateController),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // final fromDate =
                //     DateFormat('d MMM yyyy').parse(fromDateController.text);
                // final toDate =
                //     DateFormat('d MMM yyyy').parse(toDateController.text);
                
                final nameSplit = sheet.name.split("__%*%__");
                final justName = nameSplit[0];
                final afterJustName = '${Localizations.localeOf(context).languageCode == "en" ? DateFormat('d MMM yyyy').parse(fromDateController.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(fromDateController.text)}__%*%__${Localizations.localeOf(context).languageCode == "en" ? DateFormat('d MMM yyyy').parse(toDateController.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(toDateController.text)}';
                context.read<SpreadsheetBloc>().add(UpdateSheetName('${justName}__%*%__$afterJustName', sheet));

                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  /// Converts a Nepali date string like "फाल्गुन ६, २०८२" into
  /// AD milliseconds (millisecondsSinceEpoch).
  /// Returns null if the string is invalid.
  int? nepaliStringToMilliseconds(String bsText) {
    // Map Nepali month names to month numbers
    const nepaliMonthMap = {
      "baisakh": 1,
      "jestha": 2,
      "asar": 3,
      "shrawan": 4,
      "bhadra": 5,
      "ashwin": 6,
      "kartik": 7,
      "mangsir": 8,
      "poush": 9,
      "magh": 10,
      "falgun": 11,
      "chaitra": 12,
    };

    try {
      // Split the string: "फाल्गुन 6, 2082"
      final parts = bsText.trim().split(" ");
      if (parts.length < 3) return null;

      final monthName = parts[0].trim().toLowerCase();
      final day = int.parse(parts[1].replaceAll(",", "").trim());
      final year = int.parse(parts[2].trim());

      final month = nepaliMonthMap[monthName];
      if (month == null) return null;

      // Create NepaliDateTime
      final bsDate = NepaliDateTime(year, month, day);

      // Convert to AD DateTime and return milliseconds
      return bsDate.toDateTime().millisecondsSinceEpoch;
    } catch (e) {
      return null;
    }
  }


  void pickNepaliDate({
    required BuildContext context,
    required int initialTimestamp,
    required TextEditingController pick,
  }) async {
    final NepaliDateTime initialDate =
        NepaliDateTime.fromDateTime(
            DateTime.fromMillisecondsSinceEpoch(initialTimestamp),
        );

    final NepaliDateTime? picked = await showNepaliDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: NepaliDateTime(2000, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 30),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      // Convert BS back to Gregorian timestamp for storage
      pick.text = formatDate(picked.millisecondsSinceEpoch, context);
    }
    // return null;
  }

  Future<int?> pickNepaliDateRaw({
    required BuildContext context,
    int? initialTimestamp,
  }) async {
    // Set NepaliUtils language
    // NepaliUtils().language =
    //     Localizations.localeOf(context).languageCode == 'ne'
    //         ? Language.nepali
    //         : Language.english;

    // Convert initial timestamp to NepaliDateTime
    final NepaliDateTime initialDate = initialTimestamp != null
        ? NepaliDateTime.fromDateTime(
            DateTime.fromMillisecondsSinceEpoch(initialTimestamp),
          )
        : NepaliDateTime.now();

    // Show Nepali date picker
    final NepaliDateTime? picked = await showNepaliDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: NepaliDateTime(2070, 1, 1),
      lastDate: NepaliDateTime(2090, 12, 30),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      // Convert BS → AD and return milliseconds
      return picked.toDateTime().millisecondsSinceEpoch;
    }

    return null; // user canceled
  }


}
