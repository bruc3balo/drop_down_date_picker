import 'dart:async';

import 'package:flutter/material.dart';

///Options to show on date picker
enum DateOptions { d, m, y }

///Days of the week mapped by their numbers
enum DaysOfWeek {
  monday(number: 1),
  tuesday(number: 2),
  wednesday(number: 3),
  thursday(number: 4),
  friday(number: 5),
  saturday(number: 6),
  sunday(number: 7);

  const DaysOfWeek({required this.number});

  final int number;

  String get dayName => name[0].toUpperCase() + name.substring(1).toLowerCase();

  static DaysOfWeek? findByNumber(int n) {
    return DaysOfWeek.values.where((e) => e.number == n).firstOrNull;
  }
}

///Months mapped by their numbers
enum MonthsOfYear {
  january(number: 1),
  february(number: 2),
  march(number: 3),
  april(number: 4),
  may(number: 5),
  june(number: 6),
  july(number: 7),
  august(number: 8),
  september(number: 9),
  october(number: 10),
  november(number: 11),
  december(number: 12);

  const MonthsOfYear({required this.number});

  final int number;

  String get monthName =>
      name[0].toUpperCase() + name.substring(1).toLowerCase();

  static MonthsOfYear? findByNumber(int n) {
    return MonthsOfYear.values.where((e) => e.number == n).firstOrNull;
  }
}

///Default itemStyle
const itemStyle = TextStyle(
  letterSpacing: 0,
  color: Colors.black,
  fontWeight: FontWeight.bold,
);

///Default itemUnderline
Container get itemUnderline => Container(
      height: 0,
      color: Colors.transparent,
    );

///Default borderRadius
const itemBorderRadius = BorderRadius.all(Radius.circular(20.0));

/// Get the last day in a [year] and [month]
int getLastDayOfMonth({required int year, required int month}) =>
    DateUtils.getDaysInMonth(
      year,
      month,
    );

/// Get the number of days in a [year] and [month]
int getNoOfDaysInMonth({required int year, required int month}) =>
    getLastDayOfMonth(year: year, month: month);

///Get the list of days in [getLastDayOfMonth]
List<T> limitList<T>({
  required int size,
  required List<T> originalList,
}) =>
    originalList.sublist(0, size - 1);

List<int> fullDays() => List.generate(31, (index) => index + 1);

///Get all [MonthsOfYear] in a year
List<MonthsOfYear> get getAllMonths => MonthsOfYear.values;

///Get DropDown items
List<DropdownMenuItem<T>> getItems<T>({
  required List<T> items,
  required String Function(T) label,
}) =>
    items
        .map(
          (e) => DropdownMenuItem<T>(
            value: e,
            alignment: Alignment.center,
            child: Text(label(e)),
          ),
        )
        .toList();

///Generate range of from [minYear] upto [totalYears]
List<int> years({
  required int totalYears,
  required int minYear,
}) =>
    List.generate(
      totalYears,
      (index) => index + minYear,
    );

///Get The number of years in a range from [minYear] to [maxYear]
int totalYears({required int maxYear, required int minYear}) =>
    maxYear - minYear + 1;

///Callback for when any dropdown changes a date
///Handling date conflicts
void onChangeDate({
  required DateTime currentDate,
  required StreamController<DateTime> dateStreamController,
  int? day,
  int? month,
  int? year,
}) {
  if (!dateStreamController.isClosed) {
    int lastDayOfMonth = getNoOfDaysInMonth(
      year: year ?? currentDate.year,
      month: month ?? currentDate.month,
    );

    day ??= currentDate.day;

    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    currentDate = currentDate.copyWith(day: day, month: month, year: year);
    dateStreamController.sink.add(currentDate);
  }
}

///Actual date picker widget

class SpinnerDatePicker extends StatefulWidget {
  SpinnerDatePicker({
    required this.onDateChanged,
    required this.dateOptions,
    this.maxYear,
    this.minYear,
    this.dayText,
    this.textStyle = itemStyle,
    this.borderRadius = itemBorderRadius,
    DateTime? initialDate,
    super.key,
  }) : initialDate = initialDate ?? DateTime.now();

  final List<DateOptions> dateOptions;
  final DateTime initialDate;
  final TextStyle textStyle;
  final BorderRadius borderRadius;
  final int? minYear;
  final int? maxYear;
  final Widget Function(String)? dayText;
  final void Function(DateTime) onDateChanged;

  @override
  State<SpinnerDatePicker> createState() => _SpinnerDatePickerState();
}

class _SpinnerDatePickerState extends State<SpinnerDatePicker> {
  late final StreamController<DateTime> _dateStreamController =
      StreamController.broadcast()..stream.listen(widget.onDateChanged);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _dateStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.dayText != null,
          child: StreamBuilder(
            initialData: widget.initialDate,
            stream: _dateStreamController.stream,
            builder: (c, sb) {
              DateTime date = sb.requireData;
              DaysOfWeek dayOfWeek = DaysOfWeek.findByNumber(date.weekday)!;

              return widget.dayText?.call(dayOfWeek.dayName) ??
                  const SizedBox.shrink();
            },
          ),
        ),
        Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: widget.dateOptions
              .map(
                (e) => Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: switch (e) {
                      DateOptions.d => _DayPicker(
                          dateStreamController: _dateStreamController,
                          initialDate: widget.initialDate,
                          textStyle: widget.textStyle,
                          borderRadius: widget.borderRadius,
                        ),
                      DateOptions.m => _MonthPicker(
                          dateStreamController: _dateStreamController,
                          initialDate: widget.initialDate,
                          textStyle: widget.textStyle,
                          borderRadius: widget.borderRadius,
                        ),
                      DateOptions.y => _YearPicker(
                          dateStreamController: _dateStreamController,
                          initialDate: widget.initialDate,
                          textStyle: widget.textStyle,
                          borderRadius: widget.borderRadius,
                          minYear: widget.minYear,
                          maxYear: widget.maxYear,
                        ),
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

///Day date picker
class _DayPicker extends StatelessWidget {
  _DayPicker({
    required this.dateStreamController,
    required this.initialDate,
    required this.textStyle,
    required this.borderRadius,
  });

  final StreamController<DateTime> dateStreamController;
  final DateTime initialDate;
  final TextStyle textStyle;
  final BorderRadius borderRadius;
  final List<int> fullDayz = fullDays();
  late final List<DropdownMenuItem<int>> dropDownDayItems = getItems(
    items: fullDayz,
    label: (e) => e.toString(),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialDate,
      stream: dateStreamController.stream,
      builder: (context, snap) {
        DateTime newDate = snap.requireData;

        int noOfDays = getNoOfDaysInMonth(
          year: newDate.year,
          month: newDate.month,
        );

        List<DropdownMenuItem<int>> items = limitList(
          size: noOfDays + 1,
          originalList: dropDownDayItems,
        );

        return DropdownButton<int>(
          // isExpanded: true,
          alignment: Alignment.center,
          borderRadius: itemBorderRadius,
          hint: const Text("Select day"),
          dropdownColor: Colors.white,
          style: itemStyle,
          underline: itemUnderline,
          value: newDate.day,
          onChanged: (newDay) {
            if (newDay == null) return;

            onChangeDate(
              currentDate: newDate,
              dateStreamController: dateStreamController,
              day: newDay,
            );
          },
          items: items,
        );
      },
    );
  }
}

///Month date picker
class _MonthPicker extends StatelessWidget {
  _MonthPicker({
    required this.dateStreamController,
    required this.initialDate,
    required this.textStyle,
    required this.borderRadius,
  });

  final StreamController<DateTime> dateStreamController;
  final DateTime initialDate;
  final TextStyle textStyle;
  final BorderRadius borderRadius;

  final List<DropdownMenuItem<MonthsOfYear>> dropDownMothItems = getItems(
    items: getAllMonths,
    label: (e) => e.monthName,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialDate,
      stream: dateStreamController.stream,
      builder: (context, snap) {
        DateTime newDate = snap.requireData;

        return DropdownButton<MonthsOfYear>(
          // isExpanded: true,
          alignment: Alignment.center,
          borderRadius: itemBorderRadius,
          hint: const Text("Select month"),
          dropdownColor: Colors.white,
          style: itemStyle,
          underline: itemUnderline,
          value: MonthsOfYear.findByNumber(newDate.month),
          onChanged: (newMonth) {
            if (newMonth == null) return;

            onChangeDate(
              currentDate: newDate,
              dateStreamController: dateStreamController,
              month: newMonth.number,
            );
          },
          items: dropDownMothItems,
        );
      },
    );
  }
}

///Year date picker
class _YearPicker extends StatelessWidget {
  _YearPicker({
    required this.dateStreamController,
    required this.initialDate,
    required this.textStyle,
    required this.borderRadius,
    int? minYear,
    int? maxYear,
  })  : maxYear = maxYear ?? DateTime.now().year,
        minYear = minYear ?? 1800;

  final int minYear;
  final int maxYear;

  final StreamController<DateTime> dateStreamController;
  final DateTime initialDate;

  final TextStyle textStyle;
  final BorderRadius borderRadius;

  late final List<int> yearItems = years(
    minYear: minYear,
    totalYears: totalYears(maxYear: maxYear, minYear: minYear),
  );

  late final List<DropdownMenuItem<int>> dropDownYearItems = getItems(
    items: yearItems,
    label: (e) => e.toString(),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialDate,
      stream: dateStreamController.stream,
      builder: (context, snap) {
        DateTime newDate = snap.requireData;

        return DropdownButton<int>(
          // isExpanded: true,
          alignment: Alignment.center,
          borderRadius: itemBorderRadius,
          hint: const Text("Select year"),
          dropdownColor: Colors.white,
          style: itemStyle,
          underline: itemUnderline,
          value: newDate.year,
          onChanged: (newYear) {
            if (newYear == null) return;

            onChangeDate(
              currentDate: newDate,
              dateStreamController: dateStreamController,
              year: newYear,
            );
          },
          items: dropDownYearItems,
        );
      },
    );
  }
}
