
import 'package:dailycalc/data/models/home_item_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/input_model.dart';
import 'package:dailycalc/logic/blocs/blocs/home_bloc.dart';
import 'package:dailycalc/logic/blocs/events/home_event.dart';
import 'package:dailycalc/logic/blocs/states/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

class EditIndexScreen extends StatefulWidget {
  final HomeModel home;
  const EditIndexScreen({super.key, required this.home});

  @override
  State<EditIndexScreen> createState() => _EditIndexScreenState();
}

class _EditIndexScreenState extends State<EditIndexScreen> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.home.name);
  }

  double computeAggregate(HomeModel home) {
    if (home.items.isEmpty) return 0.0;
    switch (home.aggregateFunction.toLowerCase()) {
      case "sum":
        return home.items.fold(0.0, (prev, e) => prev + e.output);
      case "average":
        return home.items.fold(0.0, (prev, e) => prev + e.output) /
            home.items.length;
      case "max":
        return home.items.map((e) => e.output).reduce((a, b) => a > b ? a : b);
      case "min":
        return home.items.map((e) => e.output).reduce((a, b) => a < b ? a : b);
      default:
        return 0.0;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        // Can show SnackBars or toast on update success/failure
        if (state is HomeError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          HomeModel? currentHome;

          if (state is HomeLoaded) {
            currentHome =
                state.homes.firstWhere((h) => h.createdOn == widget.home.createdOn);
          } else {
            currentHome = widget.home;
          }
 
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Home Name",
                  hintStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                style: TextStyle(color: Theme.of(context).primaryColorDark),
                onSubmitted: (value) {
                  context.read<HomeBloc>().add(UpdateHome(
                      currentHome!.copyWith(name: value)));
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: currentHome.items.length,
                    itemBuilder: (context, index) {
                      final item = currentHome!.items[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          tileColor: Theme.of(context).primaryColorLight,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.note),
                              Text(item.output.toStringAsFixed(2)),
                            ],
                          ),
                          subtitle: Text(formatDate(item.date,context)),
                          onTap: () =>
                              _showAddEditItemDialog(context, currentHome!, item),
                          onLongPress: () {
                            // Delete confirmation dialog
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Item"),
                                content: const Text("Are you sure you want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final updatedItems = currentHome!.items
                                          .where((e) => e.createdOn != item.createdOn)
                                          .toList();
                                      setState(() {
                                        currentHome = currentHome!.copyWith(items: updatedItems);
                                      });
                                      context.read<HomeBloc>().add(UpdateHome(currentHome!));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  color: Theme.of(context).primaryColorLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Aggregate selector
                      InkWell(
                        onTap: () async {
                          final functions = ["Sum", "Average", "Max", "Min"];
                          final selected = await showDialog<String>(
                            context: context,
                            builder: (_) => SimpleDialog(
                              title: const Text("Select Aggregate Function"),
                              children: functions
                                  .map(
                                    (func) => SimpleDialogOption(
                                      onPressed: () => Navigator.pop(context, func),
                                      child: Text(func),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );

                          if (selected != null &&
                              selected != currentHome!.aggregateFunction) {
                            context.read<HomeBloc>().add(UpdateHome(
                                currentHome!.copyWith(aggregateFunction: selected)));
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "Aggregate: ${currentHome!.aggregateFunction}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ],
                        ),
                      ),
                      // Result
                      Text(computeAggregate(currentHome!).toStringAsFixed(2)),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showAddEditItemDialog(context, currentHome!),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
          );
        },
      ),
    );
  }

  void _showAddEditItemDialog(
      BuildContext context, HomeModel home, [HomeItemModel? item]) {
    final isEdit = item != null;

    final noteController =
        TextEditingController(text: isEdit ? item.note : '');
    final fieldControllers = <String, TextEditingController>{};
    final dateController = TextEditingController(
        text: isEdit
            ? formatDate(item.date, context)
            : formatDate(DateTime.now().millisecondsSinceEpoch, context));

    // initialize text controllers for each field
    for (var field in home.type.fields) {
      final value = isEdit
          ? item.inputs
              .firstWhere(
                  (i) => i.name == field.sym,
                  orElse: () => InputModel(name: field.sym, value: ""))
              .value
              .toString()
          : '';
      fieldControllers[field.sym] = TextEditingController(text: value);
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Item" : "Add Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: "Note"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Date"),
                  readOnly: true,
                  onTap: () => Localizations.localeOf(context).languageCode == "en" ? pickDate(controller: dateController) : pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: dateController),
                ),
                const SizedBox(height: 8),
                ...home.type.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: fieldControllers[field.sym],
                      decoration: InputDecoration(labelText: field.sym),
                      keyboardType: field.type == "number"
                          ? TextInputType.number
                          : TextInputType.text,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final inputs = home.type.fields.map((f) {
                  final val = fieldControllers[f.sym]!.text;
                  return InputModel(name: f.sym, value: val);
                }).toList();

                double output = 0.0;
                try {
                  final parser = Parser();
                  final cm = ContextModel();

                  for (final input in inputs) {
                    final numValue = double.tryParse(input.value.toString()) ?? 0;
                    cm.bindVariable(Variable(input.name), Number(numValue));
                  }

                  String lastOutput = '';

                  final formulas = List.from(home.type.formulas)
                    ..sort((a, b) => a.pos.compareTo(b.pos));

                  for (final formula in formulas) {
                    final exp = parser.parse(formula.expression);
                    final value = exp.evaluate(EvaluationType.REAL, cm);
                    cm.bindVariable(Variable(formula.sym), Number(value));
                    lastOutput = value.toString();
                  }

                  output = double.tryParse(lastOutput) ?? 0.0;
                } catch (_) {
                  output = 0.0;
                }

                final newItem = HomeItemModel(
                  note: noteController.text,
                  createdOn: isEdit ? item.createdOn : DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  date: Localizations.localeOf(context).languageCode == "en" ? DateFormat('d MMM yyyy').parse(dateController.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(dateController.text)!,
                  inputs: inputs,
                  output: output,
                );

                final updatedItems = isEdit
                    ? home.items
                        .map((e) => e.createdOn == item.createdOn ? newItem : e)
                        .toList()
                    : [...home.items, newItem];

                context.read<HomeBloc>().add(UpdateHome(home.copyWith(items: updatedItems)));
                Navigator.pop(context);
              },
              child: Text(isEdit ? "Save" : "Add"),
            ),
          ],
        );
      }),
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
}
