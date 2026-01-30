String rewriteCalculatorPercent(String input) {
    
    
  input = input.replaceAll(' ', '');

  final buffer = StringBuffer();
  String lastExpr = '';
  int i = 0;

  while (i < input.length) {
    final char = input[i];

    // Handle parentheses
    if (char == '(') {
      int depth = 1;
      int start = i + 1;
      i++;
      while (i < input.length && depth > 0) {
        if (input[i] == '(') depth++;
        if (input[i] == ')') depth--;
        i++;
      }
      final inner = input.substring(start, i - 1);
      final rewritten = rewriteCalculatorPercent(inner);
      buffer.write('($rewritten)');
      lastExpr = '($rewritten)';
      continue;
    }

    // Detect + Y% or - Y%
    if ((char == '+' || char == '-') && _isNextPercent(input, i)) {
      final sign = char;
      i++; // skip + or -

      final percentStart = i;
      while (i < input.length &&
          (isDigit(input[i]) || input[i] == '.')) {
        i++;
      }

      final percentValue = input.substring(percentStart, i);

      // skip %
      if (i < input.length && input[i] == '%') {
        i++;
      }

      // Rewrite: X ± Y%  →  X * (100 ± Y) / 100
      buffer.clear();
      buffer.write('($lastExpr)*(${sign == '+' ? '100+$percentValue' : '100-$percentValue'})/100');

      lastExpr = buffer.toString();
      continue;
    }

    // Handle % after * or /
    if (char == '%' && lastExpr.isNotEmpty) {
      buffer.write('/100');
      lastExpr = '$lastExpr/100';
      i++;
      continue;
    }

    // Normal characters
    buffer.write(char);
    lastExpr += char;
    i++;
  }

  return buffer.toString();
}

bool _isNextPercent(String input, int index) {
  index++; // after + or -
  while (index < input.length &&
      (isDigit(input[index]) || input[index] == '.')) {
    index++;
  }
  return index < input.length && input[index] == '%';
}

bool isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

