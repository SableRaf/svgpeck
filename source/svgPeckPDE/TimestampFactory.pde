class TimestampFactory
{

  TimestampFactory() {

  }

  String getString() {
    
    int days = day();
    int months = month();
    int years = year();
    int hours = hour();
    int minutes = minute();
    int seconds = second(); 
    int millis = millis();
    
    String dayFormat = nf(days, 2);
    String monthFormat = nf(months, 2);
    String yearFormat = nf(years, 4);
    String hoursFormat = nf(hours, 2);
    String minutesFormat = nf(minutes, 2);
    String secondsFormat = nf(seconds, 2);
    String millisFormat = nf(millis, 2);
    
    String stamp =  yearFormat + monthFormat + dayFormat
                    + "_" 
                    + hoursFormat + minutesFormat + secondsFormat 
                    + "_" 
                    + millisFormat 
                    ;
    
    return stamp;
  }
}
