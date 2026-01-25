
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/logic/blocs/blocs/spreadsheet_bloc.dart';
import 'package:dailycalc/logic/blocs/events/spreadsheet_events.dart';
import 'package:dailycalc/logic/blocs/states/spreadsheet_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:dailycalc/ui/spreadsheet/edit_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the load event
    context.read<SpreadsheetBloc>().add(LoadSheets());
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SpreadsheetBloc, SpreadSheetState>(
      listener: (context, state) {
        if (state is SheetCreated) {
          context.read<SpreadsheetBloc>().add(LoadSheets());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SpreadsheetBloc>(),
                child: EditSheetScreen(sheet: state.sheet),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sheets'),
          actions: [
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<SpreadsheetBloc>().add(SearchSheets(query));
                },
              ),
            ),
            PopupMenuButton<SheetSort>(
              icon: const Icon(Icons.filter_list),
              onSelected: (sort) {
                context.read<SpreadsheetBloc>().add(SortSheets(sort));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: SheetSort.nameAsc, child: Text('Name ↑')),
                PopupMenuItem(value: SheetSort.nameDesc, child: Text('Name ↓')),
                PopupMenuItem(value: SheetSort.dateAsc, child: Text('Date ↑')),
                PopupMenuItem(value: SheetSort.dateDesc, child: Text('Date ↓')),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddSheetDialog(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<SpreadsheetBloc, SpreadSheetState>(
          builder: (context, state) {
            if (state is SheetLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SheetError) {
              return Center(child: Text("Error: ${state.message}"));
            }

          if (state is SheetLoaded) {
            if (state.sheets.isEmpty) {
              return const Center(child: Text("No entries yet"));
            }
            return ListView.builder(
              itemCount: state.sheets.length,
              itemBuilder: (context, index) {
                final sheet = state.sheets[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(sheet.name.split("__%*%__")[0]),
                    leading: Text(sheet.homeCardIds.length.toString()),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(sheet.cardName),
                        Text(formatDate(sheet.createdOn*1000, context))
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Duplicate'),
                          onTap: () {
                            
                            context.read<SpreadsheetBloc>().add(DuplicateSheet(sheet));
                            // Navigator.pop(context);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            _showDeleteDialog(context, sheet);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<SpreadsheetBloc>(),
                            child: EditSheetScreen(sheet: sheet),
                          ),
                        ),
                      );
                    },
                    // onLongPress: () {
                    //   _showDeleteDialog(context, sheet);
                    // },
                  ),
                );
              },
            );
          }
            return const SizedBox();
          }
        )
      )
    );
  }


  void _showDeleteDialog(BuildContext context, SpreadSheetModel sheet) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Home"),
          content: Text("Are you sure you want to delete '${sheet.name.split("__%*%__")[0]}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SpreadsheetBloc>().add(DeleteSheet(sheet.createdOn));
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
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

  void _showAddSheetDialog(BuildContext context) {
    final nameController = TextEditingController();

    CardModel? selectedCard;

    final Set<HomeModel> selectedHomes = {};

    final fromDateController = TextEditingController(
        text: formatDate(DateTime.now().millisecondsSinceEpoch, context));

    final toDateController = TextEditingController(
        text: formatDate(DateTime.now().millisecondsSinceEpoch, context));

    final cards = context.read<CardRepository>().getAllCards();
    final homes = context.read<HomeRepository>().getAll();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // filter homes based on selected card
            final filteredHomes = selectedCard == null
                ? <HomeModel>[]
                : homes
                    .where(
                      (h) => h.type.createdOn == selectedCard!.createdOn,
                    )
                    .toList();
            filteredHomes.sort((a,b) => b.createdOn - a.createdOn);

            return AlertDialog(
              title: const Text("Add Sheet"),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Sheet name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Sheet name",
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: fromDateController,
                        decoration: const InputDecoration(labelText: "From Date"),
                        readOnly: true,
                        onTap: () => Localizations.localeOf(context).languageCode == "en" ? pickDate(controller: fromDateController) : pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: fromDateController),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: toDateController,
                        decoration: const InputDecoration(labelText: "To Date"),
                        readOnly: true,
                        onTap: () => Localizations.localeOf(context).languageCode == "en" ? pickDate(controller: toDateController) : pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: toDateController),
                      ),
                      const SizedBox(height: 8),

                      /// Card select (single)
                      DropdownButtonFormField<CardModel>(
                        value: selectedCard,
                        decoration: const InputDecoration(
                          labelText: "Select Card",
                        ),
                        items: cards
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCard = value;
                            selectedHomes.clear();
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Homes multi select
                      if (selectedCard != null) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Homes",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: filteredHomes.length,
                            itemBuilder: (_, index) {
                              final home = filteredHomes[index];
                              final isSelected =
                                  selectedHomes.contains(home);

                              return CheckboxListTile(
                                dense: true,
                                title: Text(home.name),
                                subtitle: Text(formatDate(home.createdOn*1000, context)),
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedHomes.add(home);
                                    } else {
                                      selectedHomes.remove(home);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        selectedCard == null) {
                      return;
                    }

                    final msfrom = Localizations.localeOf(context).languageCode == "en" ? DateFormat('d MMM yyyy').parse(fromDateController.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(fromDateController.text);


                    final msto = Localizations.localeOf(context).languageCode == "en" ? DateFormat('d MMM yyyy').parse(toDateController.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(toDateController.text);

                    context.read<SpreadsheetBloc>().add(
                          CreateSheet(
                            '${nameController.text.trim()}__%*%__${msfrom}__%*%__$msto',
                            selectedCard!.createdOn,
                            selectedCard!.name,
                            selectedHomes
                                .map((h) => h.createdOn)
                                .toList(),
                          ),
                        );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
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
