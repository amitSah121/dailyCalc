import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/logic/blocs/blocs/calculator_bloc.dart';
import 'package:dailycalc/logic/blocs/events/calculator_events.dart';
import 'package:dailycalc/logic/blocs/states/calculator_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/ui/calculator/calculator_keypad_ui.dart';
import 'package:dailycalc/ui/calculator/card_inputs_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController expressionController = TextEditingController();
  bool is_evaluating = false;

  double lastOutput = 0;

  @override
  void initState() {
    super.initState();
    context.read<CalculatorBloc>().add(LoadHistory());
  }

  @override
  void dispose() {
    searchController.dispose();
    expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (context, state) {
        if(state.isCalculatorMode && is_evaluating){
          expressionController.text = state.output;
          context.read<CalculatorBloc>().add(
                              CalculatorInputChanged(state.output),
                            );
          is_evaluating = false;
        }
      },
      child: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          final isCalculatorMode = state.isCalculatorMode;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Calculator"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final bloc = context.read<CalculatorBloc>();
                    final cardRepository = context.read<CardRepository>();
                    final allCards = cardRepository.getAllCards();

                    // Open dialog
                    final CardModel? selectedCard = await showDialog<CardModel>(
                      context: context,
                      builder: (context) {
                        TextEditingController dialogSearchController =
                            TextEditingController();
                        List<CardModel> filtered = allCards;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('Search Cards'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 400,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: dialogSearchController,
                                      decoration: const InputDecoration(
                                        hintText: 'Type to search...',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          filtered = allCards
                                              .where(
                                                (card) => card.name
                                                    .toLowerCase()
                                                    .contains(
                                                      value.toLowerCase(),
                                                    ),
                                              )
                                              .toList();
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: filtered.isEmpty
                                          ? const Center(
                                              child: Text('No results'),
                                            )
                                          : ListView.builder(
                                              itemCount: filtered.length,
                                              itemBuilder: (context, index) {
                                                final card = filtered[index];
                                                return ListTile(
                                                  title: Text(card.name),
                                                  onTap: () {
                                                    Navigator.pop(
                                                      context,
                                                      card,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );

                    if (selectedCard != null) {
                      bloc.add(SwitchMode(card: selectedCard));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calculate),
                  onPressed: () {
                    context.read<CalculatorBloc>().add(SwitchMode(card: null));
                  },
                ),
              ],
            ),

            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------- History Area ----------
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    scrollDirection: Axis.vertical,
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final item =
                          state.history[state.history.length - 1 - index];
                      final isLastItem = (index == 0);
                      return ListTile(
                        // bor: isLastItem ? Theme.of(context).primaryColorLight : Colors.white,
                        dense: true,
                        title: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.type?.name ?? 'Calculator',
                              style: TextStyle(
                                fontSize: 18,
                                color: (isLastItem
                                    ? Theme.of(context).primaryColorDark
                                    : Colors.black),
                              ),
                            ),
                            Text(
                              formatNumberSmart(item.output),
                              style: isLastItem
                                  ? TextStyle(
                                      fontSize: 24,
                                      color: Theme.of(context).primaryColorDark,
                                    )
                                  : TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        subtitle: item.type == null
                            ? SizedBox(
                                width: 140, // 👈 restrict width only
                                child: Text(
                                  item.inputs[0].value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            : const Text("param"),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      state.history.remove(item);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: const Text("Delete"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final bloc = context
                                          .read<CalculatorBloc>();
                                      // if (history == null) return;

                                      if (item.cardId == null) {
                                        expressionController.text =
                                            item.inputs[0].value;
                                        bloc.add(
                                          OpenCardFromHistory(
                                            card: null,
                                            inputs: item.inputs,
                                          ),
                                        );
                                        Navigator.pop(context, null);
                                      } else {
                                        final selectedCard =
                                            (context.read<CardRepository>())
                                                .getAllCards()
                                                .where(
                                                  (card) =>
                                                      card.createdOn ==
                                                      item.type!.createdOn,
                                                )
                                                .cast<CardModel?>()
                                                .firstWhere(
                                                  (c) => c != null,
                                                  orElse: () => null,
                                                );
                                        bloc.add(
                                          OpenCardFromHistory(
                                            card: selectedCard,
                                            inputs: item.inputs,
                                          ),
                                        );
                                        Navigator.pop(context, selectedCard);
                                      }
                                    },
                                    child: const Text("Stack"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // ---------- Expression Input (Calculator Only) ----------
                if (isCalculatorMode)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: expressionController,
                          minLines: 1,        // starts with 1 line
                          maxLines: null,     // grows automatically
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter expression',
                          ),
                          onChanged: (value) {
                            context.read<CalculatorBloc>().add(
                              CalculatorInputChanged(value),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_calculateExpression(expressionController.text), style: const TextStyle(fontSize: 20),),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                // ---------- Active Area ----------
                SizedBox(
                  height: 340,
                  child: isCalculatorMode
                      ? CalculatorKeypad(
                          onKeyPressed: (key) {
                            final newExp = expressionController.text + key;
                            expressionController.text = newExp;
                            context.read<CalculatorBloc>().add(
                              CalculatorInputChanged(newExp),
                            );
                          },
                          onDeletePressed: () {
                            expressionController.text = "";
                            // lastOutput = 0;
                          },
                          onBackspacePresed: () {
                            if (expressionController.text != "") {
                              expressionController.text = expressionController
                                  .text
                                  .substring(
                                    0,
                                    expressionController.text.length - 1,
                                  );
                            }
                          },
                        )
                      : CardInputs(
                          card: state.activeCard!,
                          values: state.cardValues,
                          onChanged: (sym, value) {
                            context.read<CalculatorBloc>().add(
                              CardFieldUpdated(fieldSym: sym, value: value),
                            );
                          },
                        ),
                ),
              ],
            ),

            floatingActionButton: FloatingActionButton(
              child: const Text("=", style: TextStyle(fontSize: 24)),
              onPressed: () {
                context.read<CalculatorBloc>().add(Evaluate());
                context.read<CalculatorBloc>().add(SaveToHistory());
                if (isCalculatorMode) {
                  is_evaluating = true;
                  expressionController.clear();
                }
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  String formatNumberSmart(
    double value, {
    int maxTotalDigits = 14,
    int maxDecimalDigits = 4,
  }) {
    if (value.isNaN || value.isInfinite) return value.toString();

    // final abs = value.abs();

    // 1️⃣ Try normal formatting first
    String normal = value
        .toStringAsFixed(maxDecimalDigits)
        .replaceFirst(RegExp(r'\.?0+$'), '');

    final digitsOnly = normal.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length <= maxTotalDigits) {
      return normal;
    }

    // 2️⃣ Fall back to scientific notation
    // Keep total length small and readable
    String sci = value.toStringAsExponential(4);

    // Remove unnecessary + and leading zeros in exponent
    sci = sci
        .replaceAll('e+', 'e')
        .replaceAllMapped(
          RegExp(r'e(-?)0+(\d+)'),
          (m) => 'e${m.group(1)}${m.group(2)}',
        );

    return sci;
  }

  String _calculateExpression(String text){
    try{
      String result = '';

      final parser = Parser();
      final cm = ContextModel();

      final exp = parser.parse(text);
      final value = exp.evaluate(EvaluationType.REAL, cm);
      lastOutput = value;
      
      result = value.toString();

      return result;
    }catch (e){
      return lastOutput.toString();
    }
  }
}


