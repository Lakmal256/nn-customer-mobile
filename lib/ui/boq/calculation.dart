import 'dart:math';

enum Unit {
  m,
  ltr,
  kg,
  foot,
  inch,
  celsius,
  fahrenheit,
  kmh,
  ms,
  mph,
  percent,
}

/// [symbol]
/// [displayName]
Map<String, String> getUnitInfo(Unit unit) {
  switch (unit) {
    case Unit.m:
      return {
        "symbol": "m",
        "displayName": "Meter",
      };
    case Unit.ltr:
      return {
        "symbol": "l",
        "displayName": "Liter",
      };
    case Unit.kg:
      return {
        "symbol": "kg",
        "displayName": "Kilogram",
      };
    case Unit.foot:
      return {
        "symbol": "foot",
        "displayName": "Foot",
      };
    case Unit.inch:
      return {
        "symbol": "″",
        "displayName": "Inch",
      };
    case Unit.celsius:
      return {
        "symbol": "°C",
        "displayName": "Celsius",
      };
    case Unit.fahrenheit:
      return {
        "symbol": "°F",
        "displayName": "Fahrenheit",
      };
    case Unit.kmh:
      return {
        "symbol": "km/h",
        "displayName": "Kilometers per hour",
      };
    case Unit.ms:
      return {
        "symbol": "m/s",
        "displayName": "Meters per second",
      };
    case Unit.mph:
      return {
        "symbol": "mph",
        "displayName": "Miles per hour",
      };
    case Unit.percent:
      return {
        "symbol": "%",
        "displayName": "Percentage",
      };
  }
}

/// Concrete Cracking Probability Calculation

double fahrenheitToCelsius(double value) => (value - 32) * 5 / 9;

class CrackingProbability {
  CrackingProbability();

  /// Concrete temperature in C
  late double tc;

  /// Ambient temperature in C
  late double ta;

  /// Relative humidity in %
  late double r;

  /// Wind velocity in km/h
  late double V;

  double calculate() => evaluate(tc, ta, r, V);

  /// [tc] Concrete temperature in 0C
  /// [ta] Ambient temperature in C
  /// [r] Relative humidity in % ex: 50%
  /// [V] Wind velocity in km/h
  static double evaluate(double tc, double ta, double r, double V) {
    var step1 = pow(tc + 18, 2.5);
    var step2 = r / 100;
    var step3 = pow(ta + 18, 2.5);

    double result = 5 * (step1 - step2 * step3) * (V + 4) / 1000000;
    return result;
  }
}

/// BOQ Calculations

enum UnitType { std, imperial }

String unitTypeToString(UnitType type) => type == UnitType.imperial ? "Cube" : "Cubic meter";
String unitTypeToStringSymbol(UnitType type) => type == UnitType.imperial ? "cube" : "m³";

double inchToMeter(double value) => value * 0.0254;
double footToMeter(double value) => value * 0.3048;

class ConcreteType {
  ConcreteType._();

  static const grade15 = "grade_15_concrete";
  static const grade20 = "grade_20_concrete";
  static const grade25 = "grade_25_concrete";
  static const grade30 = "grade_30_concrete";
}

class PlasterType {
  PlasterType._();

  static const plaster1t03 = "1t03_plaster";
  static const plaster1t05 = "1t05_plaster";
}

class BrickType {
  BrickType._();

  static const brick112P5 = "112P5_brick";
  static const brick225 = "225_brick";
}

double toMeter(Unit unit, double value) {
  switch (unit) {
    case Unit.foot:
      return footToMeter(value);
    case Unit.inch:
      return inchToMeter(value);
    default:
      return value;
  }
}

Map<String, dynamic> calculateConcreteEst({
  required String type,
  required UnitType unitType,
  required double length,
  required Unit lengthUnit,
  required double width,
  required Unit widthUnit,
  required double depth,
  required Unit depthUnit,
}) {
  double cementAmount = 0.0;
  double sandAmount = 0.0;
  double aggregateAmount = 0.0;
  double waterAmount = 0.0;

  /// This is for m3 (cubic meter)
  switch (type) {
    case ConcreteType.grade15:
      cementAmount = 4.750;
      waterAmount = 151.000;
      sandAmount = unitType == UnitType.imperial ? 0.067 : 0.190;
      aggregateAmount = unitType == UnitType.imperial ? 0.120 : 0.340;
      break;
    case ConcreteType.grade20:
      cementAmount = 6.550;
      waterAmount = 165.000;
      sandAmount = unitType == UnitType.imperial ? 0.064 : 0.180;
      aggregateAmount = unitType == UnitType.imperial ? 0.113 : 0.320;
      break;
    case ConcreteType.grade25:
      cementAmount = 8.370;
      waterAmount = 206.000;
      sandAmount = unitType == UnitType.imperial ? 0.053 : 0.150;
      aggregateAmount = unitType == UnitType.imperial ? 0.106 : 0.300;
      break;
    case ConcreteType.grade30:
      cementAmount = 11.280;
      waterAmount = 275.000;
      sandAmount = unitType == UnitType.imperial ? 0.057 : 0.160;
      aggregateAmount = unitType == UnitType.imperial ? 0.124 : 0.350;
      break;
  }

  double scale = toMeter(lengthUnit, length) * toMeter(widthUnit, width) * toMeter(depthUnit, depth);

  return {
    "volume": scale.toStringAsFixed(3),
    "volumeUnit": "m³",
    "values": [
      {
        "name": "Cement",
        "value": (cementAmount * scale).toStringAsFixed(3),
        "unit": "bags (50kg)",
      },
      {
        "name": "Sand",
        "value": (sandAmount * scale).toStringAsFixed(3),
        "unit": unitTypeToStringSymbol(unitType),
      },
      {
        "name": "Aggregate",
        "value": (aggregateAmount * scale).toStringAsFixed(3),
        "unit": unitTypeToStringSymbol(unitType),
      },
      {
        "name": "Water",
        "value": (waterAmount * scale).toStringAsFixed(3),
        "unit": "Ltr",
      }
    ],
  };
}

Map<String, dynamic> calculatePlasterEst({
  required String type,
  required UnitType unitType,
  required double length,
  required Unit lengthUnit,
  required double width,
  required Unit widthUnit,
}) {
  double cementAmount = 0.0;
  double sandAmount = 0.0;

  double scale = toMeter(lengthUnit, length) * toMeter(widthUnit, width);

  /// This is for m3 (cubic meter)
  switch (type) {
    case PlasterType.plaster1t03:
      cementAmount = 0.134;
      sandAmount = unitType == UnitType.imperial ? 0.002 : 0.006;
      break;
    case PlasterType.plaster1t05:
      cementAmount = 0.080;
      sandAmount = unitType == UnitType.imperial ? 0.002 : 0.007;
      break;
  }

  return {
    "volume": scale.toStringAsFixed(3),
    "volumeUnit": "m²",
    "values": [
      {
        "name": "Cement",
        "value": (cementAmount * scale).toStringAsFixed(3),
        "unit": "bags (50kg)",
      },
      {
        "name": "Sand",
        "value": (sandAmount * scale).toStringAsFixed(3),
        "unit": unitTypeToStringSymbol(unitType),
      },
    ],
  };
}

Map<String, dynamic> calculateBrickWorkEst({
  required String type,
  required UnitType unitType,
  required double length,
  required Unit lengthUnit,
  required double width,
  required Unit widthUnit,
}) {
  double cementAmount = 0.0;
  double sandAmount = 0.0;
  double brickAmount = 0.0;

  double scale = toMeter(lengthUnit, length) * toMeter(widthUnit, width);

  /// This is for m3 (cubic meter)
  switch (type) {
    case BrickType.brick112P5:
      cementAmount = 0.130;
      brickAmount = 54.000;
      sandAmount = unitType == UnitType.imperial ? 0.004 : 0.010;
      break;
    case BrickType.brick225:
      cementAmount = 0.290;
      brickAmount = 106.000;
      sandAmount = unitType == UnitType.imperial ? 0.007 : 0.020;
      break;
  }

  return {
    "volume": scale.toStringAsFixed(3),
    "volumeUnit": "m²",
    "values": [
      {
        "name": "Cement",
        "value": (cementAmount * scale).toStringAsFixed(3),
        "unit": "bags (50kg)",
      },
      {
        "name": "Sand",
        "value": (sandAmount * scale).toStringAsFixed(3),
        "unit": unitTypeToStringSymbol(unitType),
      },
      {
        "name": "Bricks",
        "value": (brickAmount * scale).toStringAsFixed(3),
        "unit": "Nr.",
      },
    ],
  };
}

Map<String, dynamic> calculateFlooringEst({
  required UnitType unitType,
  required double length,
  required Unit lengthUnit,
  required double width,
  required Unit widthUnit,
}) {
  double cementAmount = 0.134;
  double sandAmount = unitType == UnitType.imperial ? 0.002 : 0.006;
  double tileAmount = 9.570;
  double adhesiveAmount = 0.300;

  double scale = toMeter(lengthUnit, length) * toMeter(widthUnit, width);

  return {
    "volume": scale.toStringAsFixed(3),
    "volumeUnit": "m²",
    "values": [
      {
        "name": "Cement",
        "value": (cementAmount * scale).toStringAsFixed(3),
        "unit": "bags (50kg)",
      },
      {
        "name": "Sand",
        "value": (sandAmount * scale).toStringAsFixed(3),
        "unit": unitTypeToStringSymbol(unitType),
      },
      {
        "name": "Tiles",
        "value": (tileAmount * scale).toStringAsFixed(3),
        "unit": "Nr.",
      },
      {
        "name": "Adhesive",
        "value": (adhesiveAmount * scale).toStringAsFixed(3),
        "unit": "(20kg)",
      },
    ],
  };
}

Map<String, dynamic> calculatePaintEst({
  required double length,
  required Unit lengthUnit,
  required double width,
  required Unit widthUnit,
}) {
  double skimCoatAmount = 0.037;
  double primerAmount = 0.086;
  double paintAmount = 0.130;

  double scale = toMeter(lengthUnit, length) * toMeter(widthUnit, width);

  return {
    "volume": scale.toStringAsFixed(3),
    "volumeUnit": "m²",
    "values": [
      {
        "name": "Skim Coat",
        "value": (skimCoatAmount * scale).toStringAsFixed(3),
        "unit": "(20kg)",
      },
      {
        "name": "Primer",
        "value": (primerAmount * scale).toStringAsFixed(3),
        "unit": "ltr",
      },
      {
        "name": "Paint",
        "value": (paintAmount * scale).toStringAsFixed(3),
        "unit": "ltr",
      },
    ],
  };
}
