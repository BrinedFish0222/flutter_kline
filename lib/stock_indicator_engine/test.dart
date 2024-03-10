import 'package:flutter_kline/stock_indicator_engine/formula/formula.dart';


void main() {
  print(Formula.parse(' 3 / 2'));
  print(Formula.parse(' (3 / 2)'));
  print(Formula.parse('(2+4)+123'));
  print(Formula.parse('((1+3)*j)+(2+4)'));
  print(Formula.parse('(2+4)+123'));
  print(Formula.parse('((1+3)*j)*(2+4)'));
  print(Formula.parse('((1+3)*j)*(2+4)*3/4+123'));
  print(Formula.parse('((1+3)*j)*(2+4)+123*23'));
  print(Formula.parse('((1+3)*j)*(2+4)*123*23'));
}
