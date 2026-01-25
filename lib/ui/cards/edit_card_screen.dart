import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
import 'package:dailycalc/logic/blocs/blocs/card_bloc.dart';
import 'package:dailycalc/logic/blocs/events/card_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;
  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController nameController;
  // late List<TextEditingController> fieldControllers;
  late List<TextEditingController> formulaControllers;
  late TextEditingController outputController;


  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.card.name);

    // Create controllers for fields
    // fieldControllers = widget.card.fields
    //     .map((f) => TextEditingController(text: f.type)) // or f.value if exists
    //     .toList();

    // Create controllers for formulas
    formulaControllers = widget.card.formulas
        .map((f) => TextEditingController(text: f.expression))
        .toList();

    outputController = TextEditingController(text: widget.card.output);
  }

  @override
  void dispose() {
    nameController.dispose();
    // for (var c in fieldControllers) {
    //   c.dispose();
    // }
    for (var c in formulaControllers) {
      c.dispose();
    }

    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Card Name',
          ),
          style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // update fields
              // final updatedFields = List.generate(widget.card.fields.length,
              //     (i) => widget.card.fields[i].copyWith(
              //           type:  
              //         ));

              final updatedFormulas = List.generate(widget.card.formulas.length,
                  (i) => widget.card.formulas[i].copyWith(
                        expression: formulaControllers[i].text,
                      ));

              final updatedCard = widget.card.copyWith(
                name: nameController.text,
                formulas: updatedFormulas,
                output: outputController.text,
              );

              context.read<CardBloc>().add(SaveCard(updatedCard));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inputs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(widget.card.fields.length, (i) {
                final field = widget.card.fields[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text(field.sym, style: const TextStyle(fontSize: 16))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: field.type, // current type: 'number', 'date', 'string'
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'number', child: Text('Number')),
                            // DropdownMenuItem(value: 'date', child: Text('Date')),
                            // DropdownMenuItem(value: 'string', child: Text('String')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                widget.card.fields[i] = widget.card.fields[i].copyWith(type: value);
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(onPressed: (){
                        showDialog(context: context, builder: (BuildContext context){
                          return SimpleDialog(
                            title: Text(field.sym),
                            children: [
                              TextButton(onPressed: (){
                                widget.card.fields.remove(field);
                                Navigator.pop(context);
                                setState(() {
                                  
                                });
                              }, 
                              child: const Text("Okay",)),
                              TextButton(onPressed: (){

                                Navigator.pop(context);
                              }, 
                              child: const Text("Cancel")),
                            ],
                          );
                        });
                      }, icon: Icon(Icons.delete, color: Theme.of(context).primaryColorLight,))

                    ],
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: (){
                  showDialog(context: context, builder: (BuildContext context){
                    final c1 = TextEditingController();
                    c1.text = "new";
                    return SimpleDialog(
                      title: const Text("Add Input"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: c1,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        TextButton(onPressed: (){
                          final f1 = FieldModel(sym: c1.text, type: "number");
                          widget.card.fields.add(f1);
                          Navigator.pop(context);
                          setState(() {
                            
                          });
                        }, child: const Text("Okay"))
                      ],
                    );
                  });
                }, child: const Text("Add")),
              ),
              const Divider(height: 32),
              const Text('Formulas', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(widget.card.formulas.length, (i) {
                final formula = widget.card.formulas[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 40,
                          child: Text(formula.sym, style: const TextStyle(fontSize: 16))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: formulaControllers[i],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                      IconButton(onPressed: (){
                        showDialog(context: context, builder: (BuildContext context){
                          return SimpleDialog(
                            title: Text(formula.sym),
                            children: [
                              TextButton(onPressed: (){
                                widget.card.formulas.remove(formula);
                                formulaControllers.removeAt(i);
                                Navigator.pop(context);
                                setState(() {
                                  
                                });
                              }, 
                              child: const Text("Okay",)),
                              TextButton(onPressed: (){

                                Navigator.pop(context);
                              }, 
                              child: const Text("Cancel")),
                            ],
                          );
                        });
                      }, icon: Icon(Icons.delete, color: Theme.of(context).primaryColorLight,))
                    ],
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: (){
                  showDialog(context: context, builder: (BuildContext context){
                    final c1 = TextEditingController();
                    c1.text = "new";
                    return SimpleDialog(
                      title: const Text("Add Formula"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: c1,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        TextButton(onPressed: (){
                          final maxPos = widget.card.formulas.isEmpty
                            ? 0
                            : widget.card.formulas
                                .map((f) => f.pos)
                                .reduce((a, b) => a > b ? a : b);
                          final f1 = FormulaModel(pos: maxPos+1,sym: c1.text, expression: "");
                          widget.card.formulas.add(f1);
                          formulaControllers.add(TextEditingController());
                          Navigator.pop(context);
                          setState(() {
                            
                          });
                        }, child: const Text("Okay"))
                      ],
                    );
                  });
                }, child: const Text("Add")),
              ),
              const SizedBox(height: 16),
              const Text('Output', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: outputController,
                maxLines: null, // allows multiple lines
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
