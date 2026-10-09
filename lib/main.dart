
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101827),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C9CFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class Calculation {
  final String expression;
  final String result;

  const Calculation(this.expression, this.result);
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String expression = '';
  String? selectedOperator;
  double? firstOperand;

  bool waitingForSecond = false;
  bool resultShown = false;
  String? errorMessage;

  final List<Calculation> history = [];

  final List<List<String>> buttonRows = [
    ['AC', '⌫', '±', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  String formatNumber(double value) {
    if (!value.isFinite) {
      throw const FormatException('Result is too large.');
    }

    if (value == 0) return '0';

    String result = value.toString();

    if (!result.contains('e') && result.endsWith('.0')) {
      result = result.substring(0, result.length - 2);
    }

    if (result.length > 16) {
      result = value.toStringAsPrecision(10);
    }

    return result;
  }

  void clearAll() {
    setState(() {
      display = '0';
      expression = '';
      selectedOperator = null;
      firstOperand = null;
      waitingForSecond = false;
      resultShown = false;
      errorMessage = null;
    });
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
      display = 'Error';
      expression = '';
      firstOperand = null;
      selectedOperator = null;
      waitingForSecond = false;
      resultShown = false;
    });
  }

  void enterDigit(String digit) {
    setState(() {
      if (errorMessage != null) {
        errorMessage = null;
        display = '0';
      }

      if (waitingForSecond || resultShown) {
        display = digit;
        waitingForSecond = false;
        resultShown = false;
        if (selectedOperator == null) expression = '';
      } else if (display == '0') {
        display = digit;
      } else if (display == '-0') {
        display = '-$digit';
      } else if (display.replaceAll(RegExp(r'[^0-9]'), '').length < 15) {
        display += digit;
      }
    });
  }

  void enterDecimal() {
    setState(() {
      if (errorMessage != null) {
        errorMessage = null;
        display = '0';
      }

      if (waitingForSecond || resultShown) {
        display = '0.';
        waitingForSecond = false;
        resultShown = false;
        if (selectedOperator == null) expression = '';
      } else if (!display.contains('.')) {
        display += '.';
      }
    });
  }

  void chooseOperator(String operator) {
    if (errorMessage != null) return;

    final value = double.tryParse(display);
    if (value == null || !value.isFinite) {
      showError('Enter a valid number.');
      return;
    }

    setState(() {
      firstOperand = value;
      selectedOperator = operator;
      expression = '$display $operator';
      waitingForSecond = true;
      resultShown = false;
    });
  }

  void calculate() {
    if (errorMessage != null) return;

    if (selectedOperator == null || firstOperand == null) {
      showError('Choose an operation first.');
      return;
    }

    if (waitingForSecond) {
      showError('Enter the second number.');
      return;
    }

    final secondOperand = double.tryParse(display);

    if (secondOperand == null || !secondOperand.isFinite) {
      showError('Enter a valid second number.');
      return;
    }

    final first = firstOperand!;
    final operator = selectedOperator!;
    double answer;

    switch (operator) {
      case '+':
        answer = first + secondOperand;
        break;
      case '−':
        answer = first - secondOperand;
        break;
      case '×':
        answer = first * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          showError('Cannot divide by zero.');
          return;
        }
        answer = first / secondOperand;
        break;
      default:
        showError('Unknown operator.');
        return;
    }

    if (!answer.isFinite) {
      showError('Result is too large.');
      return;
    }

    try {
      final result = formatNumber(answer);
      final calculation =
          Calculation('$expression $display =', result);

      setState(() {
        history.insert(0, calculation);
        display = result;
        expression = calculation.expression;
        firstOperand = null;
        selectedOperator = null;
        waitingForSecond = false;
        resultShown = true;
      });
    } on FormatException {
      showError('Result is too large.');
    }
  }

  void backspace() {
    if (errorMessage != null) {
      clearAll();
      return;
    }

    setState(() {
      if (waitingForSecond) {
        selectedOperator = null;
        firstOperand = null;
        expression = '';
        waitingForSecond = false;
        return;
      }

      if (resultShown) {
        resultShown = false;
        expression = '';
      }

      if (display.length <= 1 ||
          (display.length == 2 && display.startsWith('-'))) {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
      }
    });
  }

  void toggleSign() {
    if (errorMessage != null) return;

    setState(() {
      if (waitingForSecond) {
        display = '0';
        waitingForSecond = false;
      }

      if (display == '0') return;

      if (display.startsWith('-')) {
        display = display.substring(1);
      } else {
        display = '-$display';
      }

      resultShown = false;
    });
  }

  void onButtonPressed(String value) {
    if (RegExp(r'^[0-9]$').hasMatch(value)) {
      enterDigit(value);
    } else if (value == '.') {
      enterDecimal();
    } else if (['+', '−', '×', '÷'].contains(value)) {
      chooseOperator(value);
    } else if (value == '=') {
      calculate();
    } else if (value == 'AC') {
      clearAll();
    } else if (value == '⌫') {
      backspace();
    } else if (value == '±') {
      toggleSign();
    }
  }

  void showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1D293B),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, updateSheet) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.65,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Calculation History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() => history.clear());
                          updateSheet(() {});
                        },
                        child: const Text('Clear History'),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(
                              child: Text('No calculations yet'),
                            )
                          : ListView.builder(
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                final item = history[index];
                                return ListTile(
                                  title: Text(item.expression),
                                  subtitle: Text(
                                    item.result,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFF9DB5FF),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      display = item.result;
                                      expression = '';
                                      firstOperand = null;
                                      selectedOperator = null;
                                      waitingForSecond = false;
                                      resultShown = true;
                                      errorMessage = null;
                                    });
                                    Navigator.pop(sheetContext);
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
  }

  Widget buildButton(String label) {
    final isOperator = ['+', '−', '×', '÷'].contains(label);
    final isEquals = label == '=';
    final isUtility = ['AC', '⌫', '±'].contains(label);

    Color background = const Color(0xFF263449);

    if (isOperator) {
      background = const Color(0xFF3D4F72);
    } else if (isEquals) {
      background = const Color(0xFF587DF2);
    } else if (isUtility) {
      background = const Color(0xFF364459);
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onButtonPressed(label),
          onLongPress: label == '⌫' ? clearAll : null,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        title: const Text('Calculator'),
        actions: [
          IconButton(
            tooltip: 'Calculation history',
            onPressed: showHistory,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            expression,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFFB2BBD0),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              display,
                              style: const TextStyle(
                                fontSize: 54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: buttonRows.map((row) {
                        return Expanded(
                          child: Row(
                            children: row.map((label) {
                              return Expanded(
                                flex: label == '0' ? 2 : 1,
                                child: buildButton(label),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
