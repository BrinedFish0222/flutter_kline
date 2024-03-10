import 'package:flutter_kline/stock_indicator_engine/constants/stock_indicator_operator.dart';
import 'package:flutter_kline/stock_indicator_engine/formula/formula.dart';

/// 公式引擎
class FormulaEngine {
  final String formula;

  FormulaEngine({required this.formula});

  double get result {
    return _parse(formula);
  }

  double _parse(String formula) {
    Formula formulaParse = Formula.parse(formula);
    if (formulaParse.isAtomLeft && formulaParse.isAtomRight) {
      return _compute(formulaParse);
    }

    if (!formulaParse.isAtomLeft) {
      double result = _parse(formulaParse.left);
      formulaParse = formulaParse.copyWith(left: result.toString());
    }

    if (!formulaParse.isAtomRight) {
      double result = _parse(formulaParse.right);
      formulaParse = formulaParse.copyWith(right: result.toString());
    }

    return _compute(formulaParse);
  }

  /// 计算
  double _compute(Formula formula) {
    double left = double.parse(formula.left);
    double right = double.parse(formula.right);

    if (formula.operator == StockIndicatorOperator.add) {
      return left + right;
    } else if (formula.operator == StockIndicatorOperator.sub) {
      return left - right;
    } else if (formula.operator == StockIndicatorOperator.mul) {
      return left * right;
    }

    return left / right;
  }


}
