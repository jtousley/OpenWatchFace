/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;

class DisplayFunctions {
 protected
  var _heartRate = 0;
 protected
  var _heartRateText = "-- ";
 protected
  var _gTimeNow;
 protected
  var _utcTime;
 protected
  var _settings;
 protected
  var _isInit = false;
 protected
  var _dc = null;
 protected
  var _fonts = null;
  var _sSettings = Sys.getDeviceSettings();

 protected
  var _methods = [//
                    :DisplayPulse
                   , :DisplayDistance
                   , :DisplaySteps
                   , :DisplayFloors
                   , :DisplayAltitude
                   , :DisplayCalories
                   , :DisplaySunEvent
                   , :DisplaySensorPressureAmbient
                   , :DisplaySensorPressureRaw
                   , :DisplaySensorPressureMsl
                   , :DisplayWeatherUpdateTime
                   , :HideFunction];

 protected
  var _weatherFuncs = [//
                         :DisplayHumidity
                        , :DisplayDewPoint
                        , :DisplayWeatherPressure
                        , :DisplayWind
                        , :DisplayWindDirection
                        , :DisplayUVI
                        , :DisplayTodayPrecipitation
                        , :DisplayNextPrecipitation
                        , :DisplayNextNextPrecipitation
                        , :DisplaySmartWeather
                        , :HideFunction];

  function setTime(time) {
    _utcTime = time.value();
    _gTimeNow = Gregorian.info(time, Time.FORMAT_MEDIUM);
    _sSettings = Sys.getDeviceSettings();
  }

  function setSettings(settings) {
    if (settings == null) {
      throw new Lang.InvalidValueException("settings is null");
    }
    _settings = settings;
  }

  function setFonts(fonts) { _fonts = fonts; }

  function setDisplayContext(dc) { _dc = dc; }

  function DisplayTopLine(layout) {
    var data = [ "", "", "" ];

    var moonData = GetMoonPhase(Time.now());
    data[0] = moonData[0];

    data[1] = Enumerations.BLUETOOTH_NOT_CONNECTED;
    // layout["col"][1] = Enumerations.ColorRed;
    if (_sSettings != null && _sSettings.phoneConnected) {
      data[1] = Enumerations.BLUETOOTH_CONNECTED;
      // layout["col"][1] = Enumerations.ColorBlue;
    }

    if (_sSettings != null && _sSettings has : doNotDisturb) {
      layout["col"][2] = (_sSettings.doNotDisturb ? _settings.disturbColor
                                                  : Enumerations.ColorWhite);
      data[2] = Enumerations.WEATHER_NIGHT;
    }

    return data;
  }

  function DisplayBottomLine(layout) {
    var data = [ "", "", "", "", "", "" ];

    if (_sSettings != null && _sSettings has
        : alarmCount && _sSettings.alarmCount != null) {
      data[0] = (_sSettings.alarmCount > 0) ? Enumerations.ALARM_RINGING
                                            : Enumerations.ALARM_NOT_RINGING;
      data[1] = _sSettings.alarmCount.format("%d");
    }

    if (_sSettings != null && _sSettings has
        : notificationCount && _sSettings.notificationCount != null) {
      data[2] = Enumerations.NOTIFICATIONS;
      data[3] = _sSettings.notificationCount.format("%d");
    }

    return data;
  }

  function LoadField3(layout) {
    if (_settings.field3 < _methods.size() && _settings.field3 >= 0 &&
        self has _methods[_settings.field3]) {
      var color = _settings.fieldcolor3;
      if (color >= Enumerations.ColorSize) {
        color = _settings.iconColor;
      }
      layout["col"][0] = color;
      return method(_methods[_settings.field3]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function LoadField4(layout) {
    if (_settings.field4 < _methods.size() && _settings.field4 >= 0 &&
        self has _methods[_settings.field4]) {
      var color = _settings.fieldcolor4;
      if (color >= Enumerations.ColorSize) {
        color = _settings.iconColor;
      }
      layout["col"][0] = color;
      return method(_methods[_settings.field4]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function LoadField5(layout) {
    if (_settings.field5 < _methods.size() && _settings.field5 >= 0 &&
        self has _methods[_settings.field5]) {
      var color = _settings.fieldcolor5;
      if (color >= Enumerations.ColorSize) {
        color = _settings.iconColor;
      }
      layout["col"][0] = color;
      return method(_methods[_settings.field5]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayDate(layout) {
    var day = _gTimeNow.day.format("%02d").toString();
    var month = _gTimeNow.month.toString();
    var week = _gTimeNow.day_of_week.toUpper().toString();
    if (week.length() > 3) {
      week = week.substring(0, 3);
    }
    var data = "";
    var order = _settings.dateOrder;
    if (order == 0) {  // WDM
      data = (week + " " + day + " " + month);
    } else if (order == 1) {  // WMD
      data = (week + " " + month + " " + day);
    } else if (order == 2) {  // DMW
      data = (day + " " + month + " " + week);
    } else if (order == 3) {  // MDW
      data = (month + " " + day + " " + week);
    }
    _isInit = true;

    return [data];
  }

  ///
  /// returns [Hour, Min]
  ///
  function DisplayTime(layout) {
    layout["col"][0] = _settings.hourColor;
    layout["col"][2] = _settings.minuteColor;
    var hour = (_sSettings != null && _sSettings.is24Hour)
                   ? _gTimeNow.hour.format("%02d")
                   : (_gTimeNow.hour % 12 == 0 ? 12 : _gTimeNow.hour % 12)
                         .format("%02d");
    var minute = _gTimeNow.min.format("%02d");
    return [ hour, ":", minute ];
  }

  ///
  /// returns [pm|am]
  ///
  function DisplayPmAm(layout) {
    if (_settings.showAmPm) {
      return [_gTimeNow.hour > 11 ? "pm" : "am"];
    } else {
      return [""];
    }
  }

  ///
  /// returns [seconds]
  ///
  function DisplaySeconds(layout) {
    if (_settings.showSeconds) {
      return [Sys.getClockTime().sec.format("%02d")];
    } else if (_settings.showWeekNumber) {
      // var testTime = Gregorian.moment({:year=>2020, :month=>12,:day=>19});
      var equalizedTime =
          new Time.Moment(_utcTime + Sys.getClockTime().timeZoneOffset);
      // testTime;
      var nowInfo = Gregorian.utcInfo(equalizedTime, Time.FORMAT_SHORT);

      var firstDayOfYear = Gregorian.moment({ :year => nowInfo.year, :month => 1, :day => 1}); // local time
      var firstDayInfo = Gregorian.utcInfo(firstDayOfYear, Time.FORMAT_SHORT);

      var thisYearsDuration =
          new Time.Duration(equalizedTime.value() - firstDayOfYear.value());
      var thisYearsDays = thisYearsDuration.value() / Gregorian.SECONDS_PER_DAY;
      var thisYearsWeeks = (thisYearsDays + 6) / 7;
      if (nowInfo.day_of_week <= firstDayInfo.day_of_week) {
        thisYearsWeeks = thisYearsWeeks + 1;
      }
      // Sys.println("Weeks : " + thisYearsWeeks);
      return [thisYearsWeeks.format("%02d")];
    } else {
      return [""];
    }
  }

  ///
  /// returns temperature
  ///
  function DisplayCurrentTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._tempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");
    // temperature = 123;

    return [temperature];
  }

  function DisplayFeelsTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._feelsTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");
    // temperature = 456;

    return [temperature];
  }

  function DisplayTodayMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._maxTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");
    // temperature = 345;

    return [temperature];
  }

  function DisplayTodayMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._minTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextMaxTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");
    // temperature = 234;

    return [temperature];
  }

  function DisplayNextMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextMinTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextNextMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMaxTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");
    // temperature = 789;

    return [temperature];
  }

  function DisplayNextNextMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMinTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayThirdMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMaxTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayThirdMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMinTempCelcius;
    if (_sSettings has
        : temperatureUnits &&
              _sSettings.temperatureUnits == Sys.UNIT_STATUTE) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayWeatherOption1(layout) {
    if (_settings.weatherField0 < _weatherFuncs.size() &&
        _settings.weatherField0 >= 0 &&
        self has _weatherFuncs[_settings.weatherField0]) {
      return method(_weatherFuncs[_settings.weatherField0]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayWeatherOption2(layout) {
    if (_settings.weatherField1 < _weatherFuncs.size() &&
        _settings.weatherField1 >= 0 &&
        self has _weatherFuncs[_settings.weatherField1]) {
      return method(_weatherFuncs[_settings.weatherField1]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayWeatherOption3(layout) {
    if (_settings.weatherField2 < _weatherFuncs.size() &&
        _settings.weatherField2 >= 0 &&
        self has _weatherFuncs[_settings.weatherField2]) {
      return method(_weatherFuncs[_settings.weatherField2]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayTodayWeatherIcon(layout) {
    var weather = _settings.weather;
    var data =
        Weather.convertOpenWeatherIdToIcon(weather._todayPrimaryId, false);

    return data;
  }
  function DisplayNextWeatherIcon(layout) {
    var weather = _settings.weather;
    var data =
        Weather.convertOpenWeatherIdToIcon(weather._nextPrimaryId, false);

    return data;
  }
  function DisplayNextNextWeatherIcon(layout) {
    var weather = _settings.weather;
    var data =
        Weather.convertOpenWeatherIdToIcon(weather._nextNextPrimaryId, false);

    return data;
  }
  function DisplayThirdWeatherIcon(layout) {
    var weather = _settings.weather;
    var data =
        Weather.convertOpenWeatherIdToIcon(weather._thirdPrimaryId, false);

    return data;
  }

  function DisplayCurrWeatherIcon(layout) {
    var weather = _settings.weather;

    var now = new Time.Moment(_utcTime);
    var weatherStaleTime = _settings.weatherStaleTime;
    var lastEventTime = weather._weatherDateTime;
    layout["col"][0] = _settings.alertColor;
    if (weatherStaleTime != null && lastEventTime != null) {
      var staleDuration = new Time.Duration(weatherStaleTime * 60);
      var lastEvent = new Time.Moment(lastEventTime);
      if (!lastEvent.add(staleDuration).lessThan(now)) {
        layout["col"][0] = _settings.weatherCurrentColor;
      }
    }

    var night = false;
    if ((_utcTime < weather._sunriseTime) || (_utcTime > weather._sunsetTime)) {
      night = true;
    }

    var data = Weather.convertOpenWeatherIdToIcon(weather._currentId, night);
    var icon = data[0];
    // var intensity = data[1];

    return [icon];
  }

  function DisplayWind(layout) {
    var weather = _settings.weather;

    var windTable = [ 3.6, 1.94384, 1, 2.23694 ];

    var windMultiplier = windTable[_settings.weatherWindSystem];
    var windSpeed = weather._windSpeedMeterSeconds * windMultiplier;
    var formattedWindSpeed = windSpeed.format("%2.1f");

    return [ Enumerations.WEATHER_WIND, formattedWindSpeed ];
  }

  function DisplaySunEvent(layout) {
    var weather = _settings.weather;

    if (weather._weatherDateTime == 0) {
      return [ Enumerations.REFRESH, "--:--" ];
    }

    var sunrise = weather._sunriseTime;
    var sunset = weather._sunsetTime;
    var nextSunrise = weather._nextSunriseTime;
    var currTimeOffset = Sys.getClockTime().timeZoneOffset;
    if (_utcTime < sunrise) {  // next is sunrise
      var equalizedSunrise = new Time.Moment(sunrise + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunrise, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNRISE, info.hour.format("%02u").toString() + ":" +
                                  info.min.format("%02u").toString()
      ];
    } else if (_utcTime < sunset) {  // next is sunset
      var equalizedSunset = new Time.Moment(sunset + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunset, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNSET, info.hour.format("%02u").toString() + ":" +
                                 info.min.format("%02u").toString()
      ];
    } else {  // tomorrow sunrise
      var equalizedSunrise = new Time.Moment(nextSunrise + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunrise, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNRISE, info.hour.format("%02u").toString() + ":" +
                                  info.min.format("%02u").toString()
      ];
    }
  }

  // Display activity (distance)
  //
  function DisplayDistance(layout) {
    var info = ActivityMonitor.getInfo();
    var distance =
        (info != null && info.distance != null) ? info.distance.toFloat() : 0;

    if (_sSettings has
        : distanceUnits && _sSettings.distanceUnits == Sys.UNIT_STATUTE) {
      distance = (distance / 100000).format("%2.1f");
    } else {
      distance = (distance / 160934.4).format("%2.1f");
    }

    return [ Enumerations.DISTANCE, distance ];
  }

  // Display the number of floors climbed for the current day.
  //
  function DisplayFloors(layout) {
    var info = ActivityMonitor.getInfo();
    var floors = 0;
    if (info != null && info has
        : floorsClimbed && info.floorsClimbed != null) {
      floors = info.floorsClimbed.format("%d");
    }
    return [ Enumerations.FLOORS, floors ];
  }

  function DisplaySteps(layout) {
    var info = ActivityMonitor.getInfo();
    var steps = 0;
    if (info != null && info has : steps && info.steps != null) {
      steps = info.steps;
      if (steps > 9999) {
        steps = (steps / 1000.0).format("%d") + "k";  // x.yk
      } else {
        steps.format("%d");
      }
    }
    return [ Enumerations.STEPS, steps ];
  }

  // display current pulse
  //
  function DisplayPulse(layout) {
    var isUpdate = false;
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : currentHeartRate && info.currentHeartRate != null &&
              _heartRate != info.currentHeartRate) {
      _heartRate = info.currentHeartRate;
      _heartRateText = _heartRate.toString();
      isUpdate = true;
    }

    return [ Enumerations.PULSE, _heartRateText, isUpdate ];
  }

  function DisplayAltitude(layout) {
    var altitude = null;
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : altitude && info.altitude != null && _sSettings has
        : elevationUnits) {
      altitude = info.altitude *
                 (_sSettings.elevationUnits == Sys.UNIT_STATUTE ? 3.28084 : 1);
    }

    return [
      Enumerations.ALTITUDE, (altitude != null) ? altitude.format("%d") : "---"
    ];
  }

  // Display the number of floors climbed for the current day.
  //
  function DisplayCalories(layout) {
    var info = ActivityMonitor.getInfo();
    var calories = "---";
    if (info != null && info.calories != null) {
      calories = info.calories.format("%d");
    }

    return [ Enumerations.CALORIES, calories ];
  }

  function formatPressure(pressure) {
    if (_sSettings has
        : distanceUnits && _sSettings.distanceUnits == Sys.UNIT_STATUTE) {
      pressure = pressure.format("%2.1f");
    } else {
      pressure = pressure.format("%d");
    }
    return pressure;
  }

  // Display the calculated barometric pressure ambient
  //
  function DisplaySensorPressureAmbient(layout) {
    var convTable = [ 0.01, 0.0002953 ];  // pascals to
    var pressure = "---";
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : ambientPressure && info.ambientPressure != null && _sSettings has
        : distanceUnits) {
      pressure = formatPressure(info.ambientPressure *
                                convTable[_sSettings.distanceUnits]);
    }

    return [ Enumerations.PRESSURE, pressure ];
  }

  // Display the calculated barometric pressure raw
  //
  function DisplaySensorPressureRaw(layout) {
    var convTable = [ 0.01, 0.0002953 ];  // pascals to
    var pressure = "---";
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : rawAmbientPressure && info.rawAmbientPressure != null &&
              _sSettings has
        : distanceUnits) {
      pressure = formatPressure(info.rawAmbientPressure *
                                convTable[_sSettings.distanceUnits]);
    }

    return [ Enumerations.PRESSURE, pressure ];
  }

  // Display the calculated barometric pressure msl
  //
  function DisplaySensorPressureMsl(layout) {
    var convTable = [ 0.01, 0.0002953 ];  // pascals to
    var pressure = "---";
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : meanSeaLevelPressure && info.meanSeaLevelPressure != null &&
              _sSettings has
        : distanceUnits) {
      pressure = formatPressure(info.meanSeaLevelPressure *
                                convTable[_sSettings.distanceUnits]);
    }

    return [ Enumerations.PRESSURE, pressure ];
  }

  // Display the time of the last weather update
  //
  function DisplayWeatherUpdateTime(layout) {
    var weather = _settings.weather;
    var updateTime = "--:--";

    var now = new Time.Moment(_utcTime);
    var lastEventTime = weather._weatherDateTime;
    if (lastEventTime != null && lastEventTime > 0) {
      var currTimeOffset = Sys.getClockTime().timeZoneOffset;
      var equalizedTime = new Time.Moment(lastEventTime + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedTime, Time.FORMAT_SHORT);
      updateTime = info.hour.format("%02u").toString() + ":" +
                   info.min.format("%02u").toString();
    }

    return [ Enumerations.REFRESH, updateTime ];
  }

  function HideFunction(layout) { return [ "", "" ]; }

  // function trimString(str, start, length) {
  //   if (str == null || !(str instanceof String)) {
  //     return "";
  //   }

  //   var ret = str.substring(start, start + length + 1);
  //   if (str.length() > (start + length + 1)) {
  //     ret = ret + "~";
  //   }
  //   return ret;
  // }

  function trimStringByWidth(str, startIndex, pixelWidth, fontIndex) {
    var width = 0;
    var charArray = str.toCharArray();
    var i = (startIndex > 0 ? startIndex : 0);
    for (; i < charArray.size(); i++) {
      var c = charArray[i];
      width = width + _dc.getTextWidthInPixels(c.toString(), _fonts[fontIndex]);
      if (width > pixelWidth) {
        break;
      }
    }
    var substr = str.substring(startIndex, i - 1);
    if ((startIndex + i) < str.length()) {
      substr = substr + "~";
    } else {
      substr = substr + str.toCharArray()[i - 1].toString();
    }

    return [ substr, i ];
  }
  // Display current city name based on known GPS location
  //
  function DisplayLocation(layout) {
    layout["col"][0] = _settings.textColor;
    layout["col"][1] = _settings.textColor;
    var MAX_ROW1_LENGTH = (layout["len"] != null ? layout["len"][0] : 12);
    var MAX_ROW2_LENGTH = (layout["len"] != null ? layout["len"][1] : 12);
    var fontIndex = (layout["font"][0] > 100 ? (layout["font"][0] - 100)
                                             : layout["font"][0]);

    var fullAlert = _settings.weather._alertName;
    var row1 = "";
    var row2 = trimStringByWidth(_settings.weather._city, 0, MAX_ROW2_LENGTH,
                                 fontIndex)[0];

    if (_settings.weather._alertExists == 1) {
      layout["col"][0] = _settings.alertColor;
      var row1data =
          trimStringByWidth(fullAlert, 0, MAX_ROW1_LENGTH, fontIndex);
      row1 = row1data[0];
      var trimIndex = row1data[1];
      // arbitarily must be 4 extra characters to make it worthwhile to not
      // show city
      if (fullAlert.length() > (trimIndex + 5)) {
        row2 = trimStringByWidth(fullAlert, trimIndex - 1, MAX_ROW2_LENGTH,
                                 fontIndex)[0];
        layout["col"][1] = _settings.alertColor;
      }
    }

    if (_settings.isTest == true) {
      row1 = _settings.weather._errorCode;
    }

    return [ row1, row2 ];
  }

  // Display current humidity
  //
  function DisplayHumidity(layout) {
    var weather = _settings.weather;
    var val = weather._humidityPercentage + "%";

    return [ Enumerations.HUMIDITY, val ];
  }

  // Display current dew point
  //
  function DisplayDewPoint(layout) {
    var weather = _settings.weather;
    var val = weather._dewPoint;

    return [ Enumerations.DEW_POINT, val.format("%2.1f") ];
  }

  // Display current pressure
  //
  function DisplayWeatherPressure(layout) {
    var weather = _settings.weather;
    var convTable = [ 1, 0.02953 ];  // millibars to

    var val = formatPressure(weather._baroPressureBars *
                             convTable[_sSettings.distanceUnits]);

    return [ Enumerations.PRESSURE, val ];
  }

  // Display wind direction
  //
  function DisplayWindDirection(layout) {
    var weather = _settings.weather;
    var val = weather._windDirection;

    return [ Enumerations.DIRECTION, val ];
  }
  // Display current UV index
  //
  function DisplayUVI(layout) {
    var weather = _settings.weather;
    var val = weather._uvIndex.format("%2.1f");

    return [ Enumerations.UV_INDEX, val ];
  }
  // Display today's precipitation probability
  //
  function DisplayTodayPrecipitation(layout) {
    var weather = _settings.weather;
    var val = (weather._todayPrecipitationPercent * 100).format("%d") + "%";
    // var val = "100%";

    return [ Enumerations.PRECIPITATION, val ];
  }

  // Display the next day's precipitation probability
  //
  function DisplayNextPrecipitation(layout) {
    var weather = _settings.weather;
    var val = (weather._nextPrecipitationPercent * 100).format("%d") + "%";

    return [ Enumerations.PRECIPITATION, val ];
  }

  // Display the day after next's precipitation probability
  //
  function DisplayNextNextPrecipitation(layout) {
    var weather = _settings.weather;
    var val = (weather._nextNextPrecipitationPercent * 100).format("%d") + "%";

    return [ Enumerations.PRECIPITATION, val ];
  }

  // Display the most important water value
  //
  function DisplaySmartWeather(layout) {
    var weather = _settings.weather;
    var rain = weather._rainDepth_mm;
    if (rain > 0) {
      // if the user like his distances in stupid, he probably likes his
      // precipitation the same way
      if (_sSettings has
          : distanceUnits && _sSettings.distanceUnits == Sys.UNIT_STATUTE) {
        rain = (rain / 25.4).format("%1.2f");
      } else {
        rain = rain.format("%2.1f");
      }
      return [ Enumerations.WEATHER_RAIN, rain ];
    }

    var snow = weather._snowDepth_mm;
    if (snow > 0) {
      // if the user like his distances in stupid, he probably likes his
      // precipitation the same way
      if (_sSettings has
          : distanceUnits && _sSettings.distanceUnits == Sys.UNIT_STATUTE) {
        snow = (snow / 25.4).format("%1.2f");
      } else {
        snow = snow.format("%2.1f");
      }
      return [ Enumerations.WEATHER_SNOW, snow ];
    }

    var wind = weather._windGust_meterSecs;
    if (wind > 0) {
      var windTable = [ 3.6, 1.94384, 1, 2.23694 ];
      var windMultiplier = windTable[_settings.weatherWindSystem];
      var windSpeed = wind * windMultiplier;
      var formattedWindSpeed = windSpeed.format("%2.1f");

      return [ Enumerations.WEATHER_WIND, formattedWindSpeed ];
    }

    var humidity = weather._humidityPercentage;
    if (humidity > 50) {
      return [ Enumerations.HUMIDITY, humidity + "%" ];
    }

    var uv = weather._uvIndex;

    return [ Enumerations.UV_INDEX, uv.format("%2.1f") ];
  }

  // Display battery
  //
  function DisplayWatchStatus(layout) {
    var stats = Sys.getSystemStats();
    var batteryLevel = (stats != null) ? (stats.battery).toNumber() : 0;

    // set alert color if battery level too low
    if (batteryLevel < 25) {
      layout["col"][0] = _settings.alertColor;
      layout["col"][1] = _settings.alertColor;
    } else {
      layout["col"][0] = _settings.iconColor;
      layout["col"][1] = _settings.textColor;
    }

    return [ Enumerations.ELECTRICITY, batteryLevel.format("%d") ];
  }

  function GetMoonPhase(timeNow) {
    var JD = timeNow.value().toDouble() / Gregorian.SECONDS_PER_DAY.toDouble() +
             2440587.500d;
    var IP = Normalize((JD.toDouble() - 2451550.1d) / 29.530588853d);
    var Age = IP * 29.53d;

    var phase = 0;
    if (Age < 1.84566) {
      phase = Enumerations.NEW_MOON;
    } else if (Age < 6.38264) {
      phase = Enumerations.EVENING_CRESCENT;
    } else if (Age < 8.38264) {
      phase = Enumerations.FIRST_QUARTER;
    } else if (Age < 13.76529) {
      phase = Enumerations.WAXING_GIBBOUS;
    } else if (Age < 15.76529) {
      phase = Enumerations.FULL_MOON;
    } else if (Age < 21.14794) {
      phase = Enumerations.WANING_GIBBOUS;
    } else if (Age < 23.14794077932) {
      phase = Enumerations.LAST_QUARTER;
    } else if (Age < 28.53058) {
      phase = Enumerations.MORNING_CRESCENT;
    } else {
      phase = Enumerations.NEW_MOON;
    }  // A new moon";

    IP = IP * 2d * Math.PI;  // Convert phase to radians

    // calculate moon's distance
    //
    var DP = 2d * Math.PI * Normalize((JD - 2451562.2d) / 27.55454988d);

    // calculate moon's ecliptic longitude
    //
    var RP = Normalize((JD - 2451555.8d) / 27.321582241d);
    var LO = 360d * RP + 6.3d * Math.sin(DP) + 1.3d * Math.sin(2d * IP - DP) +
             0.7d * Math.sin(2d * IP);

    var zodiac = 0;
    if (LO < 33.18) {
      zodiac = 0;
    }  // Pisces
    else if (LO < 51.16) {
      zodiac = 1;
    }  // Aries"
    else if (LO < 93.44) {
      zodiac = 2;
    }  // Taurus"
    else if (LO < 119.48) {
      zodiac = 3;
    }  // Gemini"
    else if (LO < 135.30) {
      zodiac = 4;
    }  // Cancer"
    else if (LO < 173.34) {
      zodiac = 5;
    }  // Leo"
    else if (LO < 224.17) {
      zodiac = 6;
    }  // Virgo"
    else if (LO < 242.57) {
      zodiac = 7;
    }  // Libra"
    else if (LO < 271.26) {
      zodiac = 8;
    }  // Scorpio"
    else if (LO < 302.49) {
      zodiac = 9;
    }  // Sagittarius"
    else if (LO < 311.72) {
      zodiac = 10;
    }  // Capricorn"
    else if (LO < 348.58) {
      zodiac = 11;
    }  // Aquarius"
    else {
      zodiac = 0;
    }  //  Pisces"

    return [ phase, zodiac ];
  }

  function Normalize(value) {
    var nValue = value - Math.floor(value);
    if (nValue < 0) {
      nValue = nValue + 1;
    }
    return nValue;
  }
}