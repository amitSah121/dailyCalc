
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
                    title: Text(sheet.name),
                    leading: Text(sheet.homeCardIds.length.toString()),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(sheet.cardName),
                        Text(formatDate(sheet.createdOn*1000))
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
                    onLongPress: () {
                      _showDeleteDialog(context, sheet);
                    },
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
          content: Text("Are you sure you want to delete '${sheet.name}'?"),
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


  String formatDate(int timestamp) =>
        DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  void _showAddSheetDialog(BuildContext context) {
    final nameController = TextEditingController();

    CardModel? selectedCard;

    final Set<HomeModel> selectedHomes = {};

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
                                subtitle: Text(formatDate(home.createdOn*1000)),
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

                    context.read<SpreadsheetBloc>().add(
                          CreateSheet(
                            nameController.text.trim(),
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
}
