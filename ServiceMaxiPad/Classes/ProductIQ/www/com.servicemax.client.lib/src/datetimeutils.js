(function () {

    var datetimeutil = SVMX.Package("com.servicemax.client.lib.datetimeutils");

    /**
     * @class           com.servicemax.client.lib.datetimeutils.DatetimeUtil
     * @extends         com.servicemax.client.lib.api.Object
     * @description
     * Class to provide all the utility methods for Datetime.
     * Currently contains util functions for datetime(format, renderer)
     */
    datetimeutil.Class("DatetimeUtil", com.servicemax.client.lib.api.Object, {
        __constructor: function () {
            //TODO :
        }
    }, {
        timeZone: "",
        dateFormat: "",
        timeFormat: "",
        setTimezoneOffset: function(timezoneOffset) {datetimeutil.DatetimeUtil.timeZone = timezoneOffset;},
        setDateFormat: function(format) {datetimeutil.DatetimeUtil.dateFormat = format;},
        setTimeFormat: function(format) {datetimeutil.DatetimeUtil.timeFormat = format;},
        getDefaultDateFormat: function() {return datetimeutil.DatetimeUtil.dateFormat || "MM/DD/YYYY";},
        getDefaultTimeFormat: function() {return datetimeutil.DatetimeUtil.timeFormat || "HH:mm i";},
        /**
         * Takes a date/datetime in various formats and returns a server formated date/datetime string.
         * To go the other way, see renderer methods.
         * @public
         * @method
         * @param   {String}    value A string representing a date or datetime some format described below
         * @param   {String}    displayMode One of dateTime or dateOnly.  Sigh.  Should have been date, time, datetime.
         * @param   {String}    format Date format; one of the values returned by getDateFormatTypes(), with time stripped out
         * @param   {String}    timeFormat 12 or 24 for 12 hour time or 24 hour time.
         * @param   {String}    todPlacement This is the REAL timeFormat; "H:s"
         *
         * @return  String      Server time formated date or datetime: "YYYY-MM-DD hh:mm:ss"
         */
        formatDatetime: function (value, displayMode, format, timeFormat, todPlacementFormat) {
            if (!value) return;
            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            if (displayMode == "dateTime") {
                if (timeFormat == '12') {
                    var tod = this.getTOD(value);

                    if (value.indexOf(amText) > -1 || value.indexOf(pmText) > -1) {
                        value = this.trimDatetimeTOD(value, tod);
                        if (value.indexOf(":") > -1) {
                            var ind = value.indexOf(":");
                            var hrValue = value.substr((ind - 2), 2);

                            var dtValueArray = value.match(/\d+/g);

                            value = this.__formatDatetimeValue(tod, hrValue, dtValueArray, format);
                        }
                    }
                } else {
                    if (value.indexOf(":") > -1) {
                        var ind = value.indexOf(":");
                        var hrValue = value.substr((ind - 2), 2);

                        var dtValueArray = value.match(/\d+/g);

                        value = this.__formatDatetimeValue(tod, hrValue, dtValueArray, format);
                    } else if (todPlacementFormat == "H.mm") {
                        var ind = value.indexOf(".");
                        var hrValue = value.substr((ind - 2), 2);

                        var dtValueArray = value.match(/\d+/g);

                        value = this.__formatDatetimeValue(tod, hrValue, dtValueArray, format);
                    }
                }
            } else if (displayMode == "dateOnly") {
                value = this.__formatDate(value, format);
            }

            return value;
        },

        //Engineer the value to save format
        __formatDatetimeValue: function (tod, hrValue, value, format) {
            var year = "",
                month = "",
                day = "",
                hour = "",
                mins = "";

            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            if (format != undefined) {
                if (format == 'm/d/Y' || format == 'm-d-Y' || format == 'm.d.Y') {
                    year = value[2], month = value[0];
                    day = value[1], hour = value[3], mins = value[4];
                }

                if (format == 'd/m/Y' || format == 'd-m-Y' || format == 'd.m.Y') {
                    year = value[2], month = value[1];
                    day = value[0], hour = value[3], mins = value[4];
                }

                if (format == 'Y/m/d' || format == 'Y-m-d' || format == 'Y.m.d' || format == "Y年m月d日") {
                    year = value[0], month = value[1];
                    day = value[2], hour = value[3], mins = value[4];
                }

                if (parseInt(hrValue, 10) < 12 && tod == pmText)
                    hour = (parseInt(hrValue, 10) + 12).toString();

                if (parseInt(hrValue, 10) == 12 && tod == amText)
                    hour = "00";

            } else { //for detail format is always undefined
                year = value[2];
                month = value[1];
                day = value[0];
            }

            //save format is YYYY-MM-DD Hr:mins:00
            return value = year + '-' + month + '-' + day + " " + hour + ":" + mins + ':' + "00";
        },

        //If dateOnly engineer the value to the corresponding save format(YYYY-MM-DD)
        __formatDate: function (dateValue, format) {
            if (!dateValue) return;

            var year = "",
                month = "",
                day = "";
            var value = dateValue.match(/\d+/g);

            if (format != undefined) {
                if (format == 'm/d/Y' || format == 'm-d-Y' || format == 'm.d.Y') {
                    year = value[2];
                    month = value[0];
                    day = value[1];
                }

                if (format == 'd/m/Y' || format == 'd-m-Y' || format == 'd.m.Y') {
                    year = value[2];
                    month = value[1];
                    day = value[0];
                }

                if (format == 'Y/m/d' || format == 'Y-m-d' || format == 'Y.m.d' || format == "Y年m月d日") {
                    year = value[0];
                    month = value[1];
                    day = value[2];
                    hour = value[3];
                    mins = value[4];
                }

                //TODO : revisit these conditions
                //this condition is required when save was trigerred and formatting of date was done but
                //save did not go through cause of other validations, on triggering save again the
                //formatted value is returned and hence these conditions.
                if (year.length != 4) {
                    year = value[0];
                    day = value[2];
                    month = value[1];
                }
            } else {
                //for detail format is always undefined
                year = value[2];
                month = value[0];
                day = value[1];
                //TODO : revisit these conditions
                if (year.length != 4) {
                    year = value[0];
                    day = value[2];
                }
            }

            //save format is YYYY-MM-DD
            return dateValue = year + '-' + month + '-' + day;
        },

        // Returns the format in which save happens, as per the current
        // flex delivery data model
        getDatetimeSaveFormat: function (mode) {
            var savedFormat;
            if (mode == "dateTime") {
                savedFormat = "Y-m-d H:i:s";
            } else {
                savedFormat = "Y-m-d";
            }

            return savedFormat;
        },

        //To be used to add all the different date format types
        getDateFormatTypes: function () {
            return {
                "MM/DD/YYYY": {
                    "format": "m/d/Y H:i",
                    value: "{1}/{0}/{2} {3}:{4}"
                },
                "YYYY/MM/DD": {
                    "format": "Y/m/d H:i",
                    value: "{2}/{1}/{0} {3}:{4}"
                },
                "DD/MM/YYYY": {
                    "format": "d/m/Y H:i",
                    value: "{0}/{1}/{2} {3}:{4}"
                },
                "DD.MM.YYYY": {
                    "format": "d.m.Y H:i",
                    value: "{0}.{1}.{2} {3}:{4}"
                },
                "MM.DD.YYYY": {
                    "format": "m.d.Y H:i",
                    value: "{1}.{0}.{2} {3}:{4}"
                },
                "YYYY.MM.DD": {
                    "format": "Y.m.d H:i",
                    value: "{2}.{1}.{0} {3}:{4}"
                },
                "YYYY-MM-DD": {
                    "format": "Y-m-d H:i",
                    value: "{2}-{1}-{0} {3}:{4}"
                },
                "MM-DD-YYYY": {
                    "format": "m-d-Y H:i",
                    value: "{1}-{0}-{2} {3}:{4}"
                },
                "DD-MM-YYYY": {
                    "format": "d-m-Y H:i",
                    value: "{0}-{1}-{2} {3}:{4}"
                },
                "YYYY. MM. DD": {
                    "format": "Y.m.d H:i",
                    value: "{2}.{1}.{0} {3}:{4}"
                },
                "YYYY年MM月DD日": {
                    "format": "Y年m月d日 H:i",
                    value: "{2}年{1}月{0}日 {3}:{4}"
                }
            };
        },

        getDatetimeDisplayValue: function (format, value, timeFormat) {
            var todInCenter = this.isTODInCenter(format, timeFormat);
            if (todInCenter) {
                var fmtDTVal = value.split(" "),
                    tod = this.getTOD(value);
                if (tod != "" && tod != null && tod != undefined) {
                    value = fmtDTVal[0] + " " + tod + " " + fmtDTVal[1];
                } else {
                    value = fmtDTVal[0] + " " + fmtDTVal[1];
                }
            }

            if (timeFormat == "H.mm") {
                var val = value.replace(":", "."); //replace : with . for italian locale
                value = val;
            }

            return value;
        },

        //find out where to place AM/PM based on format
        isTODInCenter: function (dateFormat, timeFormat) {
            var inCenter = false;
            if (dateFormat == "YYYY. MM. DD" || dateFormat == "YYYY年MM月DD日" ||
                dateFormat == "YYYY. MM. DD H:i:s" || dateFormat == "YYYY年MM月DD日 H:i:s" ||
                timeFormat == "a h:mm" || timeFormat == "ah:mm" || timeFormat == "a hh:mm") {
                inCenter = true;
            }

            return inCenter;
        },

        // Engineer the value in a format as to be read by Ext.date.parse i.e remove AM or PM
        // if PM convert the hour value to 24 hr format.
        setDatetimeValue: function (value, timeFormat) {
            if (value == null || value == undefined || value == '') return;

            var tod = this.getTOD(value);
            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            //Need to remove AM and PM if present;cause the
            //Ext.Date.parse(value, format) will return undefined
            if (value.indexOf(amText) > -1 || value.indexOf(pmText) > -1) {
                value = this.trimDatetimeTOD(value, tod);

                if (value.indexOf(":") > -1) {
                    var ind = value.indexOf(":");
                    var hrValue = value.substr((ind - 2), 2);
                    if (parseInt(hrValue, 10) < 12 && tod == pmText) {
                        hour = (parseInt(hrValue, 10) + 12).toString();
                        value = this._replaceHourValue(value, ind - 2, hour);
                    }
                }
            }

            if (timeFormat == "H.mm") {
                var val = value.replace(".", ":");
                value = val;
            }
            value = value + ":" + "00";

            return value;
        },

        //If 24 hr format convert the hour value if the tod is PM
        _replaceHourValue: function (value, index, strToReplace) {
            if (index > value.length - 1) return value;
            var displayValue = value.substr(0, index) + strToReplace + value.substr(index + 2);
            return displayValue;
        },


        /**
         * Takes a datetime in server formats and returns a datetime string in requested format
         *
         * @public
         * @method
         * @param   {String}    value A string representing a date or datetime using the server format YYYY-MM-DD hh:mm:ss
         * @param   {String}    dateFormat Date format; "MM/DD/YYYY"
         * @param   {String}    twentyFourHrTime 12 or 24 for 12 hour time or 24 hour time.
         * @param   {String}    todPlacementFormat This is the REAL timeFormat; "H:s"
         *
         * @return  String      Server time formated date or datetime: "YYYY-MM-DD hh:mm:ss"
         */
        datetimeRenderer: function (datetimeValue, dateFormat, twentyFourHrTime, todPlacementFormat) {
            if (!datetimeValue) return;
            if (!dateFormat) dateFormat = this.getDefaultDateFormat() || "YYYY-MM-DD";
            if (!twentyFourHrTime) twentyFourHrTime = this.getTimeFormat(this.getDefaultTimeFormat());
            if (!todPlacementFormat) todPlacementFormat = this.getDefaultTimeFormat();


            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";
            var formatValue = this.getDateFormatTypes()[dateFormat].value;
            dateFormat = dateFormat + " " + "H:i:s";

            if (datetimeValue.indexOf(amText) == -1 || datetimeValue.indexOf(pmText) == -1) {
                var tod;
                datetimeValue = datetimeValue.substring(0, datetimeValue.length - 3);
                if (datetimeValue.indexOf(":") > -1) {
                    var ind = datetimeValue.indexOf(":");
                    var hrValue = datetimeValue.substr((ind - 2), 2);
                    var arr = datetimeValue.match(/\d+/g);
                    var year = arr[0],
                        month = arr[1],
                        day = arr[2],
                        hour = arr[3],
                        mins = arr[4];
                    if (twentyFourHrTime == '12') {
                        if (parseInt(hrValue, 10) <= 12) {
                            if (parseInt(hrValue, 10) == 00) { // for 12 hr format only
                                hour = "12";
                            }
                            tod = amText;

                            if (parseInt(hrValue, 10) == 12) { // if hr is 12 then it is PM
                                tod = pmText;
                            }
                        } else {
                            tod = pmText;
                            hour = (parseInt(hrValue, 10) - 12).toString();
                            if (hour.toString().length == 1) {
                                hour = "0".concat(hour.toString());
                            }
                        }

                        datetimeValue = this.__formatDateStr(formatValue, day, month, year, hour, mins);
                        var todInCenter = this.isTODInCenter(dateFormat, todPlacementFormat);
                        if (todInCenter) {
                            var fmtDTVal = datetimeValue.split(" ");
                            return fmtDTVal[0] + " " + tod + " " + fmtDTVal[1];
                            //Need to revisit, cannot have so many return statements.
                        }
                        return datetimeValue + " " + tod;
                    } else {
                        datetimeValue = this.__formatDateStr(formatValue, day, month, year, hour, mins);
                        //if italian replace : with .
                        if (todPlacementFormat == "H.mm") {
                            var val = datetimeValue.replace(":", ".");
                            datetimeValue = val;
                        }

                        return datetimeValue;
                    }
                }
            }

            return datetimeValue;
        },

        dateRenderer: function (dateValue, format) {
            if (!dateValue) return;
            if (!format) format = this.getDefaultDateFormat();
            var formatValue = this.getDateFormatTypes()[format].value.split(" ")[0];
            var value = dateValue.match(/\d+/g);
            var year = value[0],
                month = value[1],
                day = value[2];

            return this.__formatDateStr(formatValue, day, month, year);
        },

        //engineer the renderer's value
        __formatDateStr: function () {
            var format = arguments[0];
            for (var i = 1; i < arguments.length; i++) {
                format = format.split("{" + (i - 1) + "}").join(arguments[i]);
            }
            return format;
        },

        //TOD == time of the day, possible values AM/PM
        getTOD: function (value) {
            var tod = '';
            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            if (value != null && value != undefined) {
                if (value.indexOf(amText) > -1 || value.indexOf(pmText) > -1) {
                    if (value.indexOf(amText) > -1) {
                        tod = amText;
                    } else if (value.indexOf(pmText) > -1) {
                        tod = pmText;
                    }
                }
            }

            return tod;
        },

        //check if datetime value has AM/PM
        valueHasTOD: function (value) {
            var bool;
            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            if (value.indexOf(amText) > -1 || value.indexOf(pmText) > -1) {
                bool = true;
            } else {
                bool = false;
            }

            return bool;
        },

        //check if tod is the last 2 chars or in between in datetime as in korean/vietnam locale.
        trimDatetimeTOD: function (value, tod) {
            var amText = SVMX.getClientProperty("amText") || "AM";
            var pmText = SVMX.getClientProperty("pmText") || "PM";

            if (value.slice(-2) == amText || value.slice(-2) == pmText) {
                value = value.substring(0, value.length - 3);
            } else {
                var val = value.replace(tod, ""); //remove tod - AM/PM from string
                val = val.replace(/\s+/g, ' '); //Since replace introduced extra whitespace remove it
                value = val;
            }

            return value;
        },

        // returns the hour format, possible values 12hr and 24 hr
        getTimeFormat: function (hoursFormat) {
            if (hoursFormat == "h:mm a" || hoursFormat == "a h:mm" || hoursFormat == "ah:mm" || hoursFormat == "a hh:mm" || hoursFormat == "hh:mm a") {
                hoursFormat = '12';
            } else {
                hoursFormat = '24'; // if hoursFormat = H.mm or h:mm
            }

            return hoursFormat;
        },

        // TODO: This should take a date object as input
        getTimestampWithSaveFormat: function () {
            return this.macroDrivenDatetime("Now", "YYYY-MM-DD", "hh:mm:ss");
        },

        // Note that this method may be called before Ext has loaded;
        // example: The logger uses this before Ext loads.
        // NOTE: This seems to be the only method to take an actual Date object.
        dateObjFormatter: function (inDate, dateOnly) {
            if (!inDate) return "";
            if ("Ext" in window) {
                return Ext.Date.format(inDate, dateOnly ? 'Y-m-d' : 'Y-m-d H:i:s')
            } else {
                var result =  inDate.getFullYear() + "-" + (1 + inDate.getMonth()) + "-" + inDate.getDate();
                if (!dateOnly) result += " " + inDate.getHours() + ":" + inDate.getMinutes() + ":" + inDate.getSeconds();
                return result;
            }
        },

        //Used to build the datetime value based on macro's(yesterday, now, today, tomorrow)
        macroDrivenDatetime: function (macro, dateFormat, timeFormat, displayMode, dtValue) {

            var yesterday = this.getDateYesterday();
            var yesDtValue = this.dateObjFormatter(yesterday);

            var dt = this.getDateTimeNow(),
                value;
            var nowDtValue = this.dateObjFormatter(dt);

            var today = this.getDateToday();
            var todayDtValue = this.dateObjFormatter(today);

            var tomorrow = this.getDateTomorrow();
            var tomDtValue = this.dateObjFormatter(tomorrow);

            switch (macro) {
            case "Yesterday":
                value = yesDtValue;
                break;
            case "Now":
                value = nowDtValue;
                break;
            case "Today":
                value = todayDtValue;
                break;
            case "Tomorrow":
                value = tomDtValue;
                break;
            }

            timeFormat = this.getTimeFormat(timeFormat);
            //For fields which are not on screen displayMode is null
            //hence use the value's length to differentiate
            if (displayMode != null && displayMode != undefined) {
                if (displayMode == "datetime") {
                    value = this.datetimeRenderer(value, dateFormat, timeFormat);
                } else if (displayMode == "date") {
                    value = this.dateRenderer(value, dateFormat);
                }
            } else if (dtValue != null && dtValue != undefined) {
                if (dtValue.length > 12) {
                    value = this.datetimeRenderer(value, dateFormat, timeFormat);
                } else {
                    value = this.dateRenderer(value, dateFormat);
                }
            }

            return value;
        },

        /* We ignore any settings the browser and OS may provide on the current timezone and use the salesforce timezone setting */
        __convertTimeToSalesforceTimezone : function(d) {
            if (datetimeutil.DatetimeUtil.timeZone) {

                d.setMinutes(d.getMinutes() + d.getTimezoneOffset()); // Remove the browser's timezone offset to reset to GMT
                var isNegative = datetimeutil.DatetimeUtil.timeZone.match(/^-/);
                var hours = Number(datetimeutil.DatetimeUtil.timeZone.match(/^-?\+?(\d+)/)[1]);
                var minutes = Number(datetimeutil.DatetimeUtil.timeZone.match(/:(\d+)/)[1]);
                if (isNegative) {
                    d.setHours(d.getHours() - hours, d.getMinutes() - minutes);
                } else {
                    d.setHours(d.getHours() + hours, d.getMinutes() + minutes);
                }
            }
        },

        getDateToday: function () {
            var d = new Date();
            this.__convertTimeToSalesforceTimezone(d);
            d.setHours(0, 0, 0, 0);
            return d;
        },

        getDateYesterday: function () {
            var d = new Date();
            this.__convertTimeToSalesforceTimezone(d);
            d.setDate(d.getDate() - 1);
            d.setHours(0, 0, 0, 0);
            return d;
        },

        getDateTomorrow: function () {
            var d = new Date();
            this.__convertTimeToSalesforceTimezone(d);
            d.setDate(d.getDate() + 1);
            d.setHours(0, 0, 0, 0);
            return d;
        },

        getDateTimeNow: function () {
            var d = new Date();
            this.__convertTimeToSalesforceTimezone(d);
            return d;
        },

        /* There are two datetime formats used in the data model:
         * "2013-04-17T23:38:18.000+0000"
         * "2013-04-01 00:00:00"
         * It may also be possible to have just "2013-04-01"
         * Determine which format is being used and return a Date object
         * TODO: Does not handle the +-xxxx (in the case of all data I've seen +0000)
         */
        getDateObjFromDataModel: function (inDateString) {
            if (inDateString instanceof Date) return inDateString;
            var d = new Date();
            d.setHours(0, 0, 0, 0);

            var dateSubstr = inDateString.substring(0, 10);

            var indexOfT = inDateString.indexOf("T");
            var timeSubstr = indexOfT == -1 ? inDateString.substring(11) : inDateString.substr(11, 8);

            var parts = dateSubstr.split(/-/);
            d.setFullYear(parts[0]);
            d.setMonth(parts[1] - 1);
            d.setDate(parts[2]);

            if (timeSubstr) {
                timeSubstr = timeSubstr.replace(/\..*$/, "");
                parts = timeSubstr.split(/:/);
                d.setHours(parts[0], parts[1], parts[2], 0);
            }
            return d;
        },
        
        /**
         *
         * returns a date diff engine         
         */                 
        getDateDiff: function (){
            return {
                inDays: function(d1, d2) {
                    var t2 = d2.getTime();
                    var t1 = d1.getTime();
            
                    return parseInt((t2-t1)/(24*3600*1000));
                },
            
                inWeeks: function(d1, d2) {
                    var t2 = d2.getTime();
                    var t1 = d1.getTime();
            
                    return parseInt((t2-t1)/(24*3600*1000*7));
                },
            
                inMonths: function(d1, d2) {
                    var d1Y = d1.getFullYear();
                    var d2Y = d2.getFullYear();
                    var d1M = d1.getMonth();
                    var d2M = d2.getMonth();
            
                    return (d2M+12*d2Y)-(d1M+12*d1Y);
                },
            
                inYears: function(d1, d2) {
                    return d2.getFullYear()-d1.getFullYear();
                }
            };
        }
    });
})();
// end of file