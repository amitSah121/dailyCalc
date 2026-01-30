import 'package:flutter/material.dart';

class CalculatorKeypad extends StatefulWidget {
  final void Function(String value) onKeyPressed;
  final void Function() onDeletePressed;
  final void Function() onBackspacePresed;
  const CalculatorKeypad({super.key, required this.onKeyPressed, required this.onDeletePressed, required this.onBackspacePresed});

  @override
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad> {
  late final List<List<CalcButton>> expandedButtons;

  @override
  void initState() {
    super.initState();

    expandedButtons = [
      [CalcButton('log',secondary: 'ln'), CalcButton('π',secondary: 'e'), CalcButton('sin', secondary: 'sin⁻¹'), CalcButton('cos', secondary: 'cos⁻¹'), CalcButton('tan', secondary: 'tan⁻¹')],
      [CalcButton('C'), CalcButton('✖️'), CalcButton('1/x'), CalcButton('('), CalcButton(')')],
      [CalcButton('7'), CalcButton('8'), CalcButton('9'), CalcButton('√'),  CalcButton('%')],
      [CalcButton('4'), CalcButton('5'), CalcButton('6'), CalcButton('X'), CalcButton('÷')],
      [CalcButton('1'), CalcButton('2'), CalcButton('3'), CalcButton('+'),CalcButton('-')],
      [CalcButton(''), CalcButton('0'), CalcButton('.'), CalcButton('^')],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final buttons = expandedButtons;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: buttons.expand((row) => row).length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final flatList = buttons.expand((row) => row).toList();
        final btn = flatList[index];

        return GestureDetector(
          onTap: () {
            if(btn.label == "✖️"){
              widget.onBackspacePresed();
              return;
            }else if(btn.label == "C"){
              widget.onDeletePressed();
              return;
            }else if(btn.label == "X"){
              widget.onKeyPressed("*");
              return;
            }else if(btn.label == "÷"){
              widget.onKeyPressed("/");
              return;
            }else if(btn.label == "√"){
              widget.onKeyPressed("sqrt(");
              return;
            }else if(btn.label == "log"){
              widget.onKeyPressed("log(10,");
              return;
            }else if(btn.label == "π"){
              widget.onKeyPressed("3.142857");
              return;
            }else if(btn.label == "e"){
              widget.onKeyPressed("2.71828");
              return;
            }
            // else if(btn.label == "mod"){
            //   widget.onKeyPressed("%");
            //   return;
            // }
            else if(btn.label == "1/x"){
              widget.onKeyPressed("1/");
              return;
            }
            widget.onKeyPressed(btn.label);
            
          },
          onLongPress: () {
            // Long press = secondary value if exists
            if (btn.secondary != null) {
              widget.onKeyPressed(btn.secondary!);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColorDark),
            ),
            child: Text(
              btn.secondary== null ? btn.label : btn.label+"\n"+btn.secondary!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark),
            ),
          ),
        );
      },
    );
  }
}

// Helper class for button info
class CalcButton {
  final String label;
  final String? secondary; // long press value
  CalcButton(this.label, {this.secondary});
}
