import 'package:dailycalc/logic/blocs/blocs/card_bloc.dart';
import 'package:dailycalc/logic/blocs/events/card_events.dart';
import 'package:dailycalc/logic/blocs/states/card_state.dart';
import 'package:dailycalc/ui/cards/edit_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the load event
    context.read<CardBloc>().add(LoadCards());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardBloc, CardState>(
      listener: (context, state) {
        if (state is CardCreated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditCardScreen(card: state.card),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cards'),
          actions: [
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<CardBloc>().add(SearchCards(query));
                },
              ),
            ),
            PopupMenuButton<CardSort>(
              icon: const Icon(Icons.filter_list),
              onSelected: (sort) {
                context.read<CardBloc>().add(SortCards(sort));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: CardSort.nameAsc, child: Text('Name ↑')),
                PopupMenuItem(value: CardSort.nameDesc, child: Text('Name ↓')),
                PopupMenuItem(value: CardSort.dateAsc, child: Text('Date ↑')),
                PopupMenuItem(value: CardSort.dateDesc, child: Text('Date ↓')),
              ],
            ),
          ],
        ),
        body: BlocBuilder<CardBloc, CardState>(
          builder: (context, state) {
            if (state is CardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CardLoaded) {
              return ListView.builder(
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  final card = state.cards[index];
                  return ListTile(
                    title: Text(card.name),
                    subtitle: Text(
                      'Created: ${DateTime.fromMillisecondsSinceEpoch(card.createdOn*1000)}',
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            Future.microtask(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCardScreen(card: card),
                                ),
                              ).then((_) {
                                context.read<CardBloc>().add(LoadCards());
                              });
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            context.read<CardBloc>().add(
                              DeleteCard(card.createdOn),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is CardError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            context.read<CardBloc>().add(const CreateCard());
          },
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
