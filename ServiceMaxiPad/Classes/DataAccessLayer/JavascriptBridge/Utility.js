
/*************************************** 19-04-13 **************************************/
/******************************** Author Shravya Shridhar *********************************************/

(function(){
 
 if(window.$UTILITY == undefined || window.$UTILITY == null) window.$UTILITY = {};
 
    $UTILITY.isStringEmpty = function (stringToBeChecked){
        if(stringToBeChecked != null && stringToBeChecked != 'null' && stringToBeChecked.length > 0){
                return true;
        }
        return false;
    }
 
    $UTILITY.base64Decode = function (objectValue){
            var decodedValue = null;
            if(objectValue != null) {
                        decodedValue = atob(objectValue);
            }
            return decodedValue;
    }

/* Get zero prefixed , if string is single digit
 */

 $UTILITY.getTwoDigits = function (dateDigit) {
 
 var dateDigitStr = dateDigit + "";
 if(dateDigit < 10 && dateDigitStr.length < 2) {
 
 return "0" + dateDigit;
 }
 return dateDigit;
 }

 
/* get date in (dd/M/yyyy) format.
 param : any date which requires to be formatted to (dd/M/yyyy)
 return : formatted date string
 */
 
 $UTILITY.dateStringFordate = function(Date) {
 
 var temp_date = Date.getDate();
 var temp_month = Date.getMonth() + 1;
 var temp_year = Date.getFullYear();
 
 var tempDateString =  temp_year + "/" + temp_month + "/" + temp_date;
 
//019534: changed to yyyy/MM/dd format from  var tempDateString =  temp_year + "-" + temp_month + "-" + temp_date;
 
//8584: changed to yyyy-MM-dd format from temp_date + "/" + temp_month + "/" + temp_year;
 return tempDateString;
 
 }
 
/* get tomorrows date in (dd/M/yyyy) format.
 param : any date which requires to be formatted to (dd/M/yyyy)
 return : formatted date string
 */
 //Kri Modified OPDOC-CR
 $UTILITY.nextDateForDate = function(DateStr) {
 
 var d = new Date(DateStr.getTime() + 24 * 60 * 60 * 1000);
 
 var temp_date = d.getDate();
 var temp_month = d.getMonth() + 1;
 var temp_year = d.getFullYear();
 
 var tempDateString = temp_year + "/" + temp_month + "/" + temp_date;
 
 //019534: changed to yyyy/MM/dd format from  var tempDateString = temp_year + "-" + temp_month + "-" + temp_date;
 
 //8584: changed to yyyy-MM-dd format from temp_date + "/" + temp_month + "/" + temp_year;

 return tempDateString;
 }
 
/* get yesterdays date in (dd/M/yyyy) format.
 param : any date which requires to be formatted to (dd/M/yyyy)
 return : formatted date string
 */
 //Kri Modified OPDOC-CR
 $UTILITY.previousDateForDate = function(DateSt) {
 
 var d = new Date(DateSt.getTime() - 24 * 60 * 60 * 1000);
 
 var temp_date = d.getDate();
 var temp_month = d.getMonth() + 1;
 var temp_year = d.getFullYear();
 
 var tempDateString =  temp_year + "/" + temp_month + "/" + temp_date;
 
 //019534: changed to yyyy/MM/dd from var tempDateString =  temp_year + "-" + temp_month + "-" + temp_date;
 
  //8584: changed to yyyy-MM-dd format from temp_date + "/" + temp_month + "/" + temp_year;
 
 return tempDateString;
 
 }
 /* get the date string based on locale
  param: string in GMT / UTC format
  return : string in date format
  */
 $UTILITY.dateForGMTString = function(DateString) {
 
 var requiredString = DateString.split("+"); //+000 needs to be removed
 var string = requiredString[0];
 var localeDate = new Date(string);
 var localDateStringWithTime = $UTILITY.dateStringFordate(localeDate);
 return localDateStringWithTime;
 
 }
 
/* get the date and time string based on locale
 param: string in GMT / UTC format
 return : string in date and time format
*/
 $UTILITY.dateAndTimeForGMTString = function(DateString) {
 
 var requiredString = DateString.split("+"); //+000 needs to be removed
 var string = requiredString[0];
 var localeDate = new Date(string);
 var localDateStringWithTime =  $UTILITY.localeDateWithTimeStringForDate(localeDate);
 return localDateStringWithTime;
 
 }
 /* get the date and time string
  param: string in GMT / UTC format
  return : string in date and time format (yyyy-mm-dd HH:MM:ss)
  */

 $UTILITY.localeDateWithTimeStringForDate = function (localeDate) {
  
 var curr_date = localeDate.getDate();
 curr_date = $UTILITY.getTwoDigits(curr_date);
 
 var curr_month = localeDate.getMonth() + 1;
 curr_month = $UTILITY.getTwoDigits(curr_month);
 
 var curr_year = localeDate.getFullYear();
 
 var hours = localeDate.getHours();
 hours = $UTILITY.getTwoDigits(hours);
 
 var minutes = localeDate.getMinutes();
 minutes = $UTILITY.getTwoDigits(minutes);
 
 var seconds = localeDate.getSeconds();
 seconds = $UTILITY.getTwoDigits(seconds);
 
 var todayDate = curr_year + "-" + curr_month + "-" + curr_date + " " + hours + ":" + minutes + ":" + seconds;
 
 return todayDate;
 }

 
/* get yesterdays date in (dd/M/yyyy hh:mm a) format.
 param : any date which requires to be formatted to (dd/M/yyyy)
 return : formatted date string
 */
$UTILITY.dateWithTimeStringForDate = function (Date) {
 
 var curr_date = Date.getDate();
 var curr_month = Date.getMonth() + 1;
 var curr_year = Date.getFullYear();
 
 var hours = Date.getHours();
 var minutes = Date.getMinutes();
 //var seconds = Date.getSeconds();
 
 var ampm = hours >= 12 ? "PM" : "AM";
 //hours = hours % 12;
 //hours = hours ? hours : 12; // the hour '0' should be '12'
 minutes = minutes < 10 ? "0"+minutes : minutes;
 
 var todayDate =  curr_year + "/" + curr_month + "/" + curr_date + " " + hours + ":" + minutes;
 
 //019534: changed to yyyy/MM/dd HH:mm var todayDate =  curr_year + "-" + curr_month + "-" + curr_date + " " + hours + ":" + minutes +" " + ampm;
 
//8584: changed to yyyy-MM-dd hh:mm a format from curr_date + "/" + curr_month + "/" + curr_year + " " + hours + ":" + minutes + " " + ampm;
 
 return todayDate;
 }
 
 })();
