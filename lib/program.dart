
final DateTime _date = DateTime.now();
var startDay = DateTime(_date.year,_date.month,1);
int weekNumber = startDay.weekday;
var calendarStartDay = startDay.add(Duration(days: weekNumber -1 ));