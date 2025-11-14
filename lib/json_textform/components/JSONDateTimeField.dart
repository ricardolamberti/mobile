// @dart=2.9
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class JSONDateTimeField extends StatefulWidget {
  final AstorComponente schema;
  final Function onSaved;

  JSONDateTimeField({
    @required this.schema,
    this.onSaved,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JSONDateTimeFieldState();
  }
}

class _JSONDateTimeFieldState extends State<JSONDateTimeField> {
  TextEditingController _controller;
  DateTime dateTime;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  TimeOfDay time;

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

  void init() {
    String format = widget.schema.formatDate;
    if (!isEdited()) return;
    if (getDateType()=="JHOUR" ) {
      String value = widget.schema.value;
      dateTime = value==""?DateTime.now():DateFormat(format).parse(value);
      time = value==""?null:TimeOfDay.fromDateTime(dateTime);
      _controller = TextEditingController(
          text: value==""?"":"${time.hour}:${time.minute}");
      _controller.addListener(() {
        _controller.text = time==null?"":"${time.hour}:${time.minute}";
      });
    } else if (getDateType()=="JDATETIME" ) {
      String value = widget.schema.value;
      dateTime = value==""?null:DateFormat(format).parse(value);
      time = value==""?"":TimeOfDay.fromDateTime(dateTime);
      _controller = TextEditingController(text: value);
      _controller.addListener(() {_controller.text = dateTime==null?"":DateFormat(format).format(dateTime);});
    } else if (getDateType()=="JINTERVALDATE" ) {
      if (widget.schema.value=="") {
        _controller = TextEditingController(text: "");
      } else {
        List<String> values = widget.schema.value.toString().split(" - ");
        if (values.length!=2||(values.length==2&&(values[0]==""||values[1]==""))) {
          _controller = TextEditingController(text: "");
          return;
        }
        dateTimeFrom= DateFormat(format).parse(values[0]);
        dateTimeTo= DateFormat(format).parse(values[1]);
        _controller = TextEditingController(text: widget.schema.value);

      }
   _controller.addListener(() {_controller.text = dateTimeFrom==null?"":DateFormat(format).format(dateTimeFrom)+" - "+DateFormat(format).format(dateTimeTo);});
    }else {
      String value = widget.schema.value;
      dateTime = value==""?null:DateFormat(format).parse(value);
      _controller = TextEditingController(text: value);
      _controller.addListener(() {_controller.text = dateTime==null?"":DateFormat(format).format(dateTime);});

      }

  }
  Widget addReadonly(bool visible,String format) {
    return Visibility(
        visible: visible,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              key: Key("textfield-${widget.schema.name}"),
              maxLines: 1,
              enabled: false,
              initialValue: widget.schema.value,
              decoration: InputDecoration(
                filled: false,
                labelText: widget.schema.label,
              ),

            ),
          ),
        )
    );
  }
  bool bugSuffixOpen=false;
  Widget addDateTimePicker(bool visible,String format) {
    return Visibility(
        visible: visible,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              onTap: () async {
                if (bugSuffixOpen==true) return;
                DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate:  dateTime==null?DateTime.now():dateTime,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2077),
                );
                TimeOfDay selectedTime=null;
                if (selectedDate!=null) {
                    selectedTime = await showTimePicker(
                    context: context,
                    initialTime: time==null?TimeOfDay.now():time,
                  );
                }
                if (selectedTime != null) {
                  setState(() {
                    selectedDate=selectedDate.add(Duration(hours:selectedTime.hour,minutes:selectedTime.minute));
                    dateTime = selectedDate;
                    time = TimeOfDay.fromDateTime(dateTime);
                    _controller.text =  DateFormat(format).format(selectedDate);
                  });
                }
              },
              enabled: true,
              key: Key("datetimefield"),
              controller: _controller,
              decoration: InputDecoration(
                filled: false,
               // helperText: widget.schema.help,
                labelText: widget.schema.label,
                prefixIcon: widget.schema.icon != null
                    ? Icon(widget.schema.icon.iconData)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    bugSuffixOpen=true;
                    clear();
                    Future.delayed(Duration(milliseconds: 100), () { bugSuffixOpen = false; });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onSaved: (v) {
                this.widget.onSaved(dateTime==null?"":DateFormat(format).format(dateTime));
              },
            ),

        )
    );
  }
  Widget addIntervalDatePicker(bool visible,String format) {
    return Visibility(
        visible: visible,
        child:  Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              onTap: () async {
                if (bugSuffixOpen==true) return;
                DateTime selectedDateFrom = await showDatePicker(
                  context: context,
                  initialDate:  dateTimeFrom==null?DateTime.now():dateTimeFrom,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2077),
                );
                DateTime selectedDateTo=null;
                if (selectedDateFrom!=null) {
                  selectedDateTo = await showDatePicker(
                    context: context,
                    initialDate: dateTimeTo==null||dateTimeTo.isBefore(selectedDateFrom)?selectedDateFrom:dateTimeTo,
                    firstDate: selectedDateFrom,
                    lastDate: DateTime(2077),
                  );
                }
                if (selectedDateTo != null) {
                  setState(() {
                    dateTimeFrom=selectedDateFrom;
                    dateTimeTo=selectedDateTo;
                    _controller.text =  DateFormat(format).format(selectedDateFrom)+" - "+DateFormat(format).format(selectedDateTo);
                  });
                }
              },
              enabled: true,
              key: Key("intervaldatetimefield"),
              controller: _controller,
              decoration: InputDecoration(
                filled: false,
                // helperText: widget.schema.help,
                labelText: widget.schema.label,
                prefixIcon: widget.schema.icon != null
                    ? Icon(widget.schema.icon.iconData)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    bugSuffixOpen=true;
                    clear();
                    Future.delayed(Duration(milliseconds: 100), () { bugSuffixOpen = false; });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onSaved: (v) {
                this.widget.onSaved(dateTimeFrom==null?"":DateFormat(format).format(dateTimeFrom)+" - "+DateFormat(format).format(dateTimeTo));
              },
            ),
          ),
        )
    );
  }
  void clear() {
    dateTime =null;
    time=null;
    _controller.clear();
  }
  Widget addDatePicker(bool visible,String format) {
    return Visibility(
        visible: visible,
        child:  Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              onTap: () async {
                if (bugSuffixOpen==true) return;
                DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: dateTime==null?DateTime.now():dateTime,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2077),
                );
                if (selectedDate!=null) {
                  setState(() {
                    dateTime = selectedDate;
                    _controller.text = DateFormat(format).format(selectedDate);
                  });
                }
              },
              enabled: true,
              key: Key("datetimefield"),
              controller: _controller,
              decoration: InputDecoration(
                filled: false,
                // helperText: widget.schema.help,
                labelText: widget.schema.label,
                prefixIcon: widget.schema.icon != null
                    ? Icon(widget.schema.icon.iconData)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    bugSuffixOpen=true;
                    clear();
                    Future.delayed(Duration(milliseconds: 100), () { bugSuffixOpen = false; });
                  },
                  icon: Icon(Icons.clear),
                ),

              ),
              onSaved: (v) {
                this.widget.onSaved(dateTime==null?"":DateFormat(format).format(dateTime));
              },
            ),
          ),
        )
    );
  }
    Widget addTimePicker(bool visible,String format) {
    return Visibility(
        visible: visible,
        child:  Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextFormField(
              onTap: () async {
                if (bugSuffixOpen==true) return;
                TimeOfDay selectedTime = await showTimePicker(
                  context: context,
                  initialTime: time==null?TimeOfDay.now():time,
                );
                if (selectedTime != null) {
                  setState(() {
                    time = selectedTime;
                    _controller.text = time.hour.toString().padLeft(2, "0")+":"+time.minute.toString().padLeft(2, "0");
                  });
                }
              },
              enabled: true,
              key: Key("datetimefield"),
              controller: _controller,
              decoration: InputDecoration(
                filled: false,
                // helperText: widget.schema.help,
                labelText: widget.schema.label,
                prefixIcon: widget.schema.icon != null
                    ? Icon(widget.schema.icon.iconData)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon:  IconButton(
                  onPressed: () {
                    bugSuffixOpen=true;
                    clear();
                    Future.delayed(Duration(milliseconds: 100), () { bugSuffixOpen = false; });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onSaved: (v) {
                this.widget.onSaved(time==null?"":time.hour.toString().padLeft(2, "0")+":"+time.minute.toString().padLeft(2, "0")+":00");
              },
            ),
          ),
        )
    );
  }
  String getOptions() {
    return widget.schema.dateOptions;
  }
  String getDateType() {
    return widget.schema.constraintTypeForDate;
  }
  bool isEdited() {
    return widget.schema.edited;
  }
  bool isVisible() {
    return  widget.schema.visible;
  }

  @override
  Widget build(BuildContext context) {
    bool visible = isVisible();
    bool edited = isEdited();
    String datetype = getDateType();
    String options = getOptions();

    String format = widget.schema.formatDate;
    if (!edited) {
      return addReadonly(visible,format);
    }
    if (datetype=="JHOUR" )
      return addTimePicker(visible, format);
    if (datetype=="JDATETIME" )
      return addDateTimePicker(visible, format);
    if (datetype=="JINTERVALDATE" )
      return addIntervalDatePicker(visible, format);
    return addDatePicker(visible, format);
  }
}
