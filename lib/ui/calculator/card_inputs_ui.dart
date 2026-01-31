import 'package:dailycalc/data/models/card_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

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
  late final Map<String, TextEditingController> _controllers = {};
  late final Map<String, TextEditingController> _dateControllers = {};
  late final Map<String, TextEditingController> _optionsControllers = {};
  late final Map<String,List<String>> options = {};
  double lastOutput = 0;

  int millisecondsSinceEpochDays() {
    DateTime now = DateTime.now();
    // Create a DateTime at start of today (00:00:00)
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    // Convert to milliseconds
    return startOfDay.millisecondsSinceEpoch;
  }

  @override
  void initState() {
    super.initState();

    

    for (final field in widget.card.fields){
      if(field.type == "number"){
        _controllers.addAll({field.sym : TextEditingController(
          text: widget.values[field.sym]?.toString() ?? '')});
      }else if(field.type == "date"){
        _dateControllers.addAll({field.sym: TextEditingController(
          text: widget.values[field.sym]?.toString() ?? '')});
        widget.onChanged(field.sym, widget.values[field.sym] ?? millisecondsSinceEpochDays());
      }else if(field.type == "options"){
        _optionsControllers.addAll({field.sym: TextEditingController(
          text: widget.values[field.sym]?.toString() ?? '')});
      }
    }

    for(final sym in _optionsControllers.keys){
      for(final formula in widget.card.formulas){
        if(formula.sym == sym){
          final val = formula.expression.split(",");
          options.addAll({formula.sym: val});
          _optionsControllers[formula.sym]!.text = val[0];
          widget.onChanged(formula.sym, val[0]);
          break;
        }
      }
    }

    // _optionControllers = buildOptionControllers(widget.options);
  }

  @override
  void didUpdateWidget(covariant CardInputs oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Card changed → rebuild controllers
    if (oldWidget.card.createdOn != widget.card.createdOn) {
      // for (final c in _controllers.values) {
      //   c.dispose();
      // }
      _controllers.clear();
      _dateControllers.clear();
      _optionsControllers.clear();

      for (final field in widget.card.fields){
        if(field.type == "number"){
          _controllers.addAll({field.sym : TextEditingController(
            text: widget.values[field.sym]?.toString() ?? '')});
        }else if(field.type == "date"){
          _dateControllers.addAll({field.sym: TextEditingController(
            text: widget.values[field.sym]?.toString() ?? '')});
          widget.onChanged(field.sym, widget.values[field.sym] ?? millisecondsSinceEpochDays());
        }else if(field.type == "options"){
          _optionsControllers.addAll({field.sym: TextEditingController(
            text: widget.values[field.sym]?.toString() ?? '')});
        }
      }

        options.clear();

        for(final sym in _optionsControllers.keys){
          for(final formula in widget.card.formulas){
            if(formula.sym == sym){
              final val = formula.expression.split(",");
              options.addAll({formula.sym: val});
              _optionsControllers[formula.sym]!.text = val[0];
              widget.onChanged(formula.sym, val[0]);
              break;
            }
          }
        }
    } else {
      // Same card → just sync text if needed
      for (final field in widget.card.fields) {
        late TextEditingController? controller;
        if(field.type == "number"){
          controller = _controllers[field.sym];
        }else if(field.type == "date"){
          controller = _dateControllers[field.sym];
        }else if(field.type == "options"){
          controller = _optionsControllers[field.sym];
        }
        final newValue;
        
        if(field.type == "date"){
          final value = widget.values[field.sym];
          final timestamp = value is int ? value : int.parse(value.toString());
          newValue = formatDate(timestamp, context);
        }else{
          newValue = widget.values[field.sym]?.toString() ?? '';
        }

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
                _calculateFormula(_controllers, _dateControllers, _optionsControllers),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          );
        }
    
        final field = widget.card.fields[index - 2];
        final type = widget.card.fields[index-2].type;
    
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
          type == "number" ?
            TextField(
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
            )
          :(
            type == "date"
            ?
            // const Text("Fello")
             TextField(
                controller: _dateControllers[field.sym],
                decoration: const InputDecoration(labelText: "Date"),
                readOnly: true,
                onTap: () async{
                  Localizations.localeOf(context).languageCode == "en" ? await pickDate(controller: _dateControllers[field.sym]!) : await pickNepaliDate(context: context, initialTimestamp: DateTime.now().millisecondsSinceEpoch, pick: _dateControllers[field.sym]!);
                  widget.onChanged(field.sym, Localizations.localeOf(context).languageCode == "en" ? DateFormat('MMMM d, yyyy').parse(_dateControllers[field.sym]!.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(_dateControllers[field.sym]!.text)!);
                  setState(() {
                    
                  });
                }
              ) 
            :
              // const Text("Hello")
            DropdownButtonFormField<String>(
              initialValue: _optionsControllers[field.sym]!.text,
              value: _optionsControllers[field.sym]!.text,
              decoration: InputDecoration(
                labelText: field.sym,
                border: const OutlineInputBorder(),
              ),
              items: options[field.sym]!
                  .map(
                    (v) => DropdownMenuItem(
                      value: v.trim(),
                      child: Text(v.trim()),
                    ),
                  )
                  .toList(),
              onChanged: (v){
                widget.onChanged(field.sym, v);
                setState(() {});
              },
            )
          ) 
        );
      },
    );
  }
  
  String _calculateFormula(Map<String, TextEditingController> controllers,Map<String, TextEditingController> dateContrllers, Map<String, TextEditingController> optionControllers) {
    String result = ""; 
    try {
      final parser = Parser();
      final cm = ContextModel();
      // Bind input values
      controllers.forEach((key, val) {
        final numValue = double.tryParse(val.text) ?? 0.0;
        cm.bindVariable(Variable(key), Number(numValue));
      });

      

      dateContrllers.forEach((key, val) {
        int value = Localizations.localeOf(context).languageCode == "en" ? DateFormat('MMMM d, yyyy').parse(val.text).millisecondsSinceEpoch : nepaliStringToMilliseconds(val.text)!;
        final numValue = value.toDouble();
        cm.bindVariable(Variable(key), Number(numValue));
      });

      String _lastOutput = '';
      lastOutput = 0;

      var formulas = [...widget.card.formulas];
      for(final i in widget.card.fields){
        if(i.type == "options"){
          formulas = formulas.where((e) => e.sym != i.sym).toList();
        }
      }

      for (final entry in options.entries) {
        final selectedSym = optionControllers[entry.key.trim()]!.text;

        final item = formulas.firstWhere(
          (f) => f.sym == selectedSym
        );

        formulas = formulas.map((e) {
          return e.copyWith(
            expression:
                e.expression.replaceAll(entry.key.trim(), item.expression),
          );
        }).toList();
      }


      formulas.sort((a, b) => a.pos.compareTo(b.pos));


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


  Future<void> pickDate({
    required TextEditingController controller,
  }) async {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('MMMM d, yyyy').parse(controller.text);
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

  Future<void> pickNepaliDate({
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

