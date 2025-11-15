import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JSONDateTimeField extends StatefulWidget {
  final AstorComponente schema;
  final ValueChanged<String>? onSaved;

  const JSONDateTimeField({
    Key? key,
    required this.schema,
    this.onSaved,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JSONDateTimeFieldState();
  }
}

class _JSONDateTimeFieldState extends State<JSONDateTimeField> {
  TextEditingController? _controller;
  DateTime? dateTime;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  TimeOfDay? time;
  bool bugSuffixOpen = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(JSONDateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void init() {
    _controller?.dispose();
    _controller = null;

    final String format = widget.schema.formatDate;
    if (!isEdited()) {
      return;
    }

    final String value = widget.schema.value?.toString() ?? '';
    final String dateType = getDateType();

    if (dateType == 'JHOUR') {
      final DateTime parsedDate =
          value.isEmpty ? DateTime.now() : DateFormat(format).parse(value);
      final TimeOfDay? initialTime =
          value.isEmpty ? null : TimeOfDay.fromDateTime(parsedDate);
      dateTime = parsedDate;
      time = initialTime;
      final controller = TextEditingController(
        text: initialTime == null ? '' : _timeToString(initialTime),
      );
      controller.addListener(() {
        final TimeOfDay? currentTime = time;
        controller.text = currentTime == null ? '' : _timeToString(currentTime);
      });
      _controller = controller;
      return;
    }

    if (dateType == 'JDATETIME') {
      final DateTime? parsedDate =
          value.isEmpty ? null : DateFormat(format).parse(value);
      dateTime = parsedDate;
      time = parsedDate == null ? null : TimeOfDay.fromDateTime(parsedDate);
      final controller = TextEditingController(text: value);
      controller.addListener(() {
        final DateTime? currentDate = dateTime;
        controller.text = currentDate == null
            ? ''
            : DateFormat(format).format(currentDate);
      });
      _controller = controller;
      return;
    }

    if (dateType == 'JINTERVALDATE') {
      final controller = TextEditingController(text: '');
      if (value.isNotEmpty) {
        final List<String> values = value.split(' - ');
        if (values.length != 2 || values[0].isEmpty || values[1].isEmpty) {
          _controller = controller;
          return;
        }
        dateTimeFrom = DateFormat(format).parse(values[0]);
        dateTimeTo = DateFormat(format).parse(values[1]);
        controller.text = value;
      }
      controller.addListener(() {
        final DateTime? from = dateTimeFrom;
        final DateTime? to = dateTimeTo;
        controller.text = from == null || to == null
            ? ''
            : '${DateFormat(format).format(from)} - ${DateFormat(format).format(to)}';
      });
      _controller = controller;
      return;
    }

    final DateTime? parsedDate =
        value.isEmpty ? null : DateFormat(format).parse(value);
    dateTime = parsedDate;
    final controller = TextEditingController(text: value);
    controller.addListener(() {
      final DateTime? currentDate = dateTime;
      controller.text = currentDate == null
          ? ''
          : DateFormat(format).format(currentDate);
    });
    _controller = controller;
  }

  Widget addReadonly(bool visible, String format) {
    return Visibility(
      visible: visible,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            key: Key('textfield-${widget.schema.name}'),
            maxLines: 1,
            enabled: false,
            initialValue: widget.schema.value?.toString() ?? '',
            decoration: InputDecoration(
              filled: false,
              labelText: widget.schema.label,
            ),
          ),
        ),
      ),
    );
  }

  Widget addDateTimePicker(bool visible, String format) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: TextFormField(
          onTap: () async {
            if (bugSuffixOpen) return;
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: dateTime ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2077),
            );
            TimeOfDay? selectedTime;
            if (selectedDate != null) {
              selectedTime = await showTimePicker(
                context: context,
                initialTime: time ?? TimeOfDay.now(),
              );
            }
            if (selectedDate != null && selectedTime != null) {
              final DateTime confirmedDate = selectedDate;
              final TimeOfDay confirmedTime = selectedTime;
              setState(() {
                final DateTime combinedDate = confirmedDate.add(
                  Duration(
                    hours: confirmedTime.hour,
                    minutes: confirmedTime.minute,
                  ),
                );
                dateTime = combinedDate;
                time = TimeOfDay.fromDateTime(combinedDate);
                controller.text = DateFormat(format).format(combinedDate);
              });
            }
          },
          enabled: true,
          key: const Key('datetimefield'),
          controller: controller,
          decoration: InputDecoration(
            filled: false,
            labelText: widget.schema.label,
            prefixIcon: widget.schema.icon != null
                ? Icon(widget.schema.icon.iconData)
                : null,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                bugSuffixOpen = true;
                clear();
                Future.delayed(const Duration(milliseconds: 100), () {
                  bugSuffixOpen = false;
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ),
          onSaved: (v) {
            final DateTime? currentDate = dateTime;
            widget.onSaved?.call(
              currentDate == null
                  ? ''
                  : DateFormat(format).format(currentDate),
            );
          },
        ),
      ),
    );
  }

  Widget addIntervalDatePicker(bool visible, String format) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Visibility(
      visible: visible,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            onTap: () async {
              if (bugSuffixOpen) return;
              final DateTime? selectedDateFrom = await showDatePicker(
                context: context,
                initialDate: dateTimeFrom ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2077),
              );
              DateTime? selectedDateTo;
              if (selectedDateFrom != null) {
                final DateTime? currentTo = dateTimeTo;
                final DateTime initialEndDate =
                    currentTo == null || currentTo.isBefore(selectedDateFrom)
                        ? selectedDateFrom
                        : currentTo;
                selectedDateTo = await showDatePicker(
                  context: context,
                  initialDate: initialEndDate,
                  firstDate: selectedDateFrom,
                  lastDate: DateTime(2077),
                );
              }
              if (selectedDateFrom != null && selectedDateTo != null) {
                final DateTime confirmedFrom = selectedDateFrom;
                final DateTime confirmedTo = selectedDateTo;
                setState(() {
                  dateTimeFrom = confirmedFrom;
                  dateTimeTo = confirmedTo;
                  controller.text =
                      '${DateFormat(format).format(confirmedFrom)} - ${DateFormat(format).format(confirmedTo)}';
                });
              }
            },
            enabled: true,
            key: const Key('intervaldatetimefield'),
            controller: controller,
            decoration: InputDecoration(
              filled: false,
              labelText: widget.schema.label,
              prefixIcon: widget.schema.icon != null
                  ? Icon(widget.schema.icon.iconData)
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  bugSuffixOpen = true;
                  clear();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    bugSuffixOpen = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSaved: (v) {
              final DateTime? from = dateTimeFrom;
              final DateTime? to = dateTimeTo;
              widget.onSaved?.call(
                from == null || to == null
                    ? ''
                    : '${DateFormat(format).format(from)} - ${DateFormat(format).format(to)}',
              );
            },
          ),
        ),
      ),
    );
  }

  void clear() {
    dateTime = null;
    time = null;
    _controller?.clear();
  }

  Widget addDatePicker(bool visible, String format) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Visibility(
      visible: visible,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            onTap: () async {
              if (bugSuffixOpen) return;
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: dateTime ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2077),
              );
              if (selectedDate != null) {
                setState(() {
                  dateTime = selectedDate;
                  controller.text = DateFormat(format).format(selectedDate);
                });
              }
            },
            enabled: true,
            key: const Key('datetimefield'),
            controller: controller,
            decoration: InputDecoration(
              filled: false,
              labelText: widget.schema.label,
              prefixIcon: widget.schema.icon != null
                  ? Icon(widget.schema.icon.iconData)
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  bugSuffixOpen = true;
                  clear();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    bugSuffixOpen = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSaved: (v) {
              final DateTime? currentDate = dateTime;
              widget.onSaved?.call(
                currentDate == null
                    ? ''
                    : DateFormat(format).format(currentDate),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget addTimePicker(bool visible, String format) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Visibility(
      visible: visible,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: TextFormField(
            onTap: () async {
              if (bugSuffixOpen) return;
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: time ?? TimeOfDay.now(),
              );
              if (selectedTime != null) {
                setState(() {
                  time = selectedTime;
                  controller.text = _timeToString(selectedTime);
                });
              }
            },
            enabled: true,
            key: const Key('datetimefield'),
            controller: controller,
            decoration: InputDecoration(
              filled: false,
              labelText: widget.schema.label,
              prefixIcon: widget.schema.icon != null
                  ? Icon(widget.schema.icon.iconData)
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  bugSuffixOpen = true;
                  clear();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    bugSuffixOpen = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSaved: (v) {
              final TimeOfDay? currentTime = time;
              widget.onSaved?.call(
                currentTime == null ? '' : '${_timeToString(currentTime)}:00',
              );
            },
          ),
        ),
      ),
    );
  }

  String _timeToString(TimeOfDay currentTime) {
    return '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
  }

  String getDateType() {
    return widget.schema.constraintTypeForDate;
  }

  bool isEdited() {
    return widget.schema.edited;
  }

  bool isVisible() {
    return widget.schema.visible;
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = isVisible();
    final bool edited = isEdited();
    final String dateType = getDateType();

    final String format = widget.schema.formatDate;
    if (!edited) {
      return addReadonly(visible, format);
    }
    if (dateType == 'JHOUR') {
      return addTimePicker(visible, format);
    }
    if (dateType == 'JDATETIME') {
      return addDateTimePicker(visible, format);
    }
    if (dateType == 'JINTERVALDATE') {
      return addIntervalDatePicker(visible, format);
    }
    return addDatePicker(visible, format);
  }
}
