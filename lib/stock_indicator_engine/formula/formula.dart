import 'package:flutter_kline/stock_indicator_engine/constants/stock_indicator_constants.dart';
import 'package:flutter_kline/stock_indicator_engine/constants/stock_indicator_operator.dart';

/// 公式
class Formula {
  final String left;
  final String right;
  final StockIndicatorOperator operator;

  const Formula({
    required this.left,
    required this.right,
    required this.operator,
  });

  Formula copyWith({
    String? left,
    String? right,
    StockIndicatorOperator? operator,
  }) {
    return Formula(
      left: left ?? this.left,
      right: right ?? this.right,
      operator: operator ?? this.operator,
    );
  }

  factory Formula.parse(String formula) {
    formula = formula.replaceAll(' ', '');
    List<String> words = formula.split('');
    words = _removeOuterBrackets(words);
    List<String> stack = [];

    Formula result = const Formula(
      left: '',
      right: '',
      operator: StockIndicatorOperator.add,
    );


    int length = words.length;
    int leftBracketNumber = 0;
    int rightBracketNumber = 0;
    for (int i = 0; i < length; ++i) {
      String word = words.removeAt(0);
      if (word == StockIndicatorKeys.leftBracket.value) {
        leftBracketNumber += 1;
      } else if (word == StockIndicatorKeys.rightBracket.value) {
        rightBracketNumber += 1;
      }

      var indicatorOperator = StockIndicatorOperator.operator(word);
      if (indicatorOperator != null && leftBracketNumber == rightBracketNumber) {
        // 到关键运算符位置
        result = result.copyWith(
          left: stack.join(),
          right: words.join(),
          operator: indicatorOperator,
        );
        break;
      }

      stack.add(word);
    }

    return result;
  }

  /// 删除最外层括号
  static List<String> _removeOuterBrackets(List<String> formulaWords) {
    if (formulaWords.isEmpty) {
      return formulaWords;
    }

    if (!(formulaWords[0] == StockIndicatorKeys.leftBracket.value &&
        formulaWords[formulaWords.length - 1] ==
            StockIndicatorKeys.rightBracket.value)) {
      return formulaWords;
    }

    List<String> leftBracketStack = [];

    int length = formulaWords.length;
    bool flag = false;
    for (int i = 0; i < length; ++i) {
      String word = formulaWords[i];

      if (word == StockIndicatorKeys.leftBracket.value) {
        leftBracketStack.add(word);
      }

      if (word == StockIndicatorKeys.rightBracket.value) {
        leftBracketStack.length = leftBracketStack.length - 1;
        if (leftBracketStack.isEmpty && i == length - 1) {
          flag = true;
        } else if (leftBracketStack.isEmpty) {
          break;
        }
      }
    }


    if (flag) {
      formulaWords.removeAt(0);
      formulaWords.removeAt(formulaWords.length - 1);
    }

    return formulaWords;
  }

  @override
  String toString() {
    return 'Formula{left: $left, right: $right, operator: $operator}';
  }
}
