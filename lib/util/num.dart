import 'package:intl/intl.dart';

var _curr = NumberFormat("#,##0.00", "en_US");

extension Currency on double{
  String toCurrency() => _curr.format(this);
}