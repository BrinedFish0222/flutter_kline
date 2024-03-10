import 'package:flutter_kline/stock_indicator_engine/common/string_ext.dart';
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

  Formula.empty({
    this.left = '',
    this.right = '',
    this.operator = StockIndicatorOperator.unknown,
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

      StockIndicatorOperator? indicatorOperator =
          StockIndicatorOperator.operator(word);
      if (indicatorOperator != null &&
          leftBracketNumber == rightBracketNumber) {
        // 到关键运算符位置
        String left = stack.join();
        String right = words.join();
        if (indicatorOperator.isDiv || indicatorOperator.isMul) {
          // 如果是乘除，还需要加多一步来正确区分左右公式
          Formula next = _next(right);
          if (next.left.isNotEmpty) {
            left += indicatorOperator.value;
            left += next.left;
            indicatorOperator = next.operator;
          }

          if (next.right.isNotEmpty) {
            right = next.right;
          }
        }

        result = result.copyWith(
          left: left,
          right: right,
          operator: indicatorOperator,
        );
        break;
      }

      stack.add(word);
    }

    return result;
  }

  bool get isAtomLeft {
    return _isAtom(left);
  }

  bool get isAtomRight {
    return _isAtom(right);
  }

  /// 是否是原子项
  static bool _isAtom(String formulaStr) {
    if (formulaStr.isNumber) {
      return true;
    }
    return false;
  }

  /// 如果是乘除，还需要加多一步来正确区分左右公式
  static Formula _next(String formulaStr) {
    bool hasOuterBrackets = _hasOuterBrackets(formulaStr.split(''));
    if (hasOuterBrackets) {
      // 如果是最后一块就没必要进行再次区分了
      return Formula.empty();
    }

    Formula formula = Formula.parse(formulaStr);
    if (formula.operator.isMul || formula.operator.isDiv) {
      // 如果运算符还是乘除，需要再进一步区分
      Formula nextFormula = _next(formula.right);
      String left = formula.left;
      String right = formula.right;

      if (nextFormula.left.isNotEmpty) {
        left += formula.operator.value;
        left += nextFormula.left;
      }

      if (nextFormula.right.isNotEmpty) {
        right = nextFormula.right;
      }

      formula = formula.copyWith(
        left: left,
        right: right,
      );
    }

    return formula;
  }

  /// 是否包含外层括号
  static bool _hasOuterBrackets(List<String> formulaWords) {
    int originLength = formulaWords.length;
    int newLength = _removeOuterBrackets(formulaWords).length;
    return !(originLength == newLength);
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
