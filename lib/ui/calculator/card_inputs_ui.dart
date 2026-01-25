import 'package:dailycalc/data/models/card_model.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CardInputs extends StatefulWidget {
  final CardModel card;
  final Map<String, dynamic> values;
  final void Function(String sym, dynamic value) onChanged;

  const CardInputs({
    super.key,
    required this.card,
    required this.values,
    required this.onChanged,
  });

  @override
  State<CardInputs> createState() => _CardInputsState();
}

class _CardInputsState extends State<CardInputs> {
  late final Map<String, TextEditingController> _controllers;
  double lastOutput = 0;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.card.fields)
        field.sym: TextEditingController(
          text: widget.values[field.sym]?.toString() ?? '',
        ),
    };
  }

  @override
  void didUpdateWidget(covariant CardInputs oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Card changed → rebuild controllers
    if (oldWidget.card.createdOn != widget.card.createdOn) {
      for (final c in _controllers.values) {
        c.dispose();
      }

      _controllers
        ..clear()
        ..addEntries(
          widget.card.fields.map(
            (field) => MapEntry(
              field.sym,
              TextEditingController(
                text: widget.values[field.sym]?.toString() ?? '',
              ),
            ),
          ),
        );
    } else {
      // Same card → just sync text if needed
      for (final field in widget.card.fields) {
        final controller = _controllers[field.sym];
        final newValue = widget.values[field.sym]?.toString() ?? '';

        if (controller != null && controller.text != newValue) {
          controller.text = newValue;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      }
    }
  }


  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.card.fields.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            widget.card.name,
            style: const TextStyle(fontSize: 24),
          );
        }else if (index == 1) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
              Text(
                _calculateFormula(_controllers),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          );
        }
    
        final field = widget.card.fields[index - 2];
    
        return Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controllers[field.sym],
            decoration: InputDecoration(
              labelText: field.sym,
              border: const OutlineInputBorder(),
            ),
            keyboardType: field.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (v){
              widget.onChanged(field.sym, v);
              setState(() {});
            },
          ),
        );
      },
    );
  }
  
  String _calculateFormula(Map<String, TextEditingController> controllers) {
    String result = ""; 
    try {
      final parser = Parser();
      final cm = ContextModel();
      // Bind input values
      controllers.forEach((key, val) {
        final numValue = double.tryParse(val.text) ?? 0.0;
        cm.bindVariable(Variable(key), Number(numValue));
      });

      String _lastOutput = '';
      lastOutput = 0;

      final formulas = [...widget.card.formulas]
        ..sort((a, b) => a.pos.compareTo(b.pos));

      for (final formula in formulas) {
        final exp = parser.parse(formula.expression);
        final value = exp.evaluate(EvaluationType.REAL, cm);

        // Store computed variable for next formulas
        cm.bindVariable(Variable(formula.sym), Number(value));
        lastOutput = value;
        _lastOutput = value.toString();
      }

      result = _lastOutput;
      return result.toString();
    }
    catch (e){
      return lastOutput.toString(); 
    }
  }
}
