import 'formula/formula.dart';
import 'formula/formula_engine.dart';


void main() {
  /*var formula = Formula.parse(' 3 / 2');
  print('formula $formula, isAtomLeft ${formula.isAtomLeft}');
  print(Formula.parse(' (3 / 2)'));

  var formula2 = Formula.parse('(2+4)+123');
  print('formula2 $formula2, isAtomLeft ${formula2.isAtomLeft}, isAtomRight ${formula2.isAtomRight}');
  print(Formula.parse('((1+3)*j)+(2+4)'));
  print(Formula.parse('(2+4)+123'));
  print(Formula.parse('((1+3)*j)*(2+4)'));
  print(Formula.parse('((1+3)*j)*(2+4)*3/4+123'));
  print(Formula.parse('((1+3)*j)*(2+4)+123*23'));*/
  print(Formula.parse('((1+3)*j)*(2+4)*123*23'));

  print(FormulaEngine(formula: '(123+2)*2').result);
  print(FormulaEngine(formula: '((1+3)*1)*(2+4)*123*(23+1)').result);
}