import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/logic/blocs/blocs/card_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/home_bloc.dart';
import 'package:dailycalc/logic/blocs/events/card_events.dart';
import 'package:dailycalc/logic/blocs/events/home_event.dart';
import 'package:dailycalc/logic/blocs/states/home_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/ui/home/edit_index_screen.dart';
import 'package:dailycalc/ui/home/graph_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    seedDefaultCards(context);
    // 🔹 fire once when screen is built
    context.read<HomeBloc>().add(LoadHomes());

    return Scaffold(
      appBar: AppBar(
        title: const Text("DailyCalc"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () => _showAddHomeDialog(context),
        //   ),
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHomeDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is HomeLoaded) {
            if (state.homes.isEmpty) {
              return const Center(child: Text("No entries yet"));
            }

            return ListView.builder(
              itemCount: state.homes.length,
              itemBuilder: (context, index) {
                final home = state.homes[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(home.name),
                    leading: Text(home.items.length.toString()),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(home.type.name),
                        Text(formatDate(home.createdOn*1000))
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.auto_graph_sharp),
                      onPressed: (){
                        Navigator.push( 
                          context, 
                          MaterialPageRoute( 
                            builder: (_) => GraphScreen(home: home), 
                          ), 
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditIndexScreen(home: home),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, home);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HomeModel home) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Home"),
          content: Text("Are you sure you want to delete '${home.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(DeleteHome(home));
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


  void _showAddHomeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final cards = context.read<CardRepository>().getAllCards();

    CardModel? selectedCard;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text("Add Home"),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: cards.length,
                        itemBuilder: (_, index) {
                          final card = cards[index];
                          final isSelected = card == selectedCard;

                          return ListTile(
                            dense: true,
                            title: Text(card.name),
                            selected: isSelected,
                            selectedTileColor:
                                Theme.of(context).primaryColorLight,
                            onTap: () {
                              setState(() {
                                selectedCard = card;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (cards.isEmpty) return;

                    final card = selectedCard ?? cards.first;

                    final home = HomeModel(
                      name: nameController.text.trim(),
                      createdOn:
                          DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      type: card,
                      cardId: card.createdOn,
                      items: const [],
                      aggregateFunction: "sum",
                      output: 0.0,
                    );

                    context.read<HomeBloc>().add(AddHome(home));
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



Future<void> seedDefaultCards(BuildContext context) async {
  const cards = [
    CardModel(
      name: "Interest",
      createdOn: 1704067200,
      isFavourite: false,
      fields: [
        FieldModel(sym: "Amount", type: "number"),
        FieldModel(sym: "From", type: "number"),
        FieldModel(sym: "To", type: "number"),
      ],
      formulas: [
        FormulaModel(pos: 0, sym: "res", expression: "Amount*(To-From)")
      ],
      output: "res",
    ),
    CardModel(
      name: "Percentage",
      createdOn: 1704067100,
      isFavourite: false,
      fields: [
        FieldModel(sym: "Amount", type: "number"),
        FieldModel(sym: "Percent", type: "number"),
      ],
      formulas: [
        FormulaModel(pos: 0, sym: "res", expression: "Amount*(100+Percent)/100")
      ],
      output: "res",
    ),
    CardModel(
      name: "Amount",
      createdOn: 1704067300,
      isFavourite: false,
      fields: [
        FieldModel(sym: "Amount", type: "number"),
      ],
      formulas: [
        FormulaModel(pos: 0, sym: "res", expression: "Amount")
      ],
      output: "res",
    ),
  ];

  final bloc = context.read<CardBloc>();

  for (final card in cards) {
    bloc.add(SaveCard(card));
  }
}

}
