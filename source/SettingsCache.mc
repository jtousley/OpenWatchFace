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
using Toybox.System as Sys;

class SettingsCache {
  function initialize() {
    isTest = Setting.GetIsTest();
    field3 = Setting.GetField(0);
    field4 = Setting.GetField(1);
    field5 = Setting.GetField(2);
    fieldcolor3 = Setting.GetFieldColor(0);
    fieldcolor4 = Setting.GetFieldColor(1);
    fieldcolor5 = Setting.GetFieldColor(2);
    weatherField0 = Setting.GetWField(0);
    weatherField1 = Setting.GetWField(1);
    weatherField2 = Setting.GetWField(2);
    lastKnownLocation = Setting.GetLastKnownLocation();
    // weatherProvider = Setting.GetWeatherProvider();
    // weatherApiKey = Setting.GetOpenWeatherToken();
    weatherWindSystem = Setting.GetWindSystem();
    dateOrder = Setting.GetDateOrder();
    backgroundColor = Setting.GetBackgroundColor();
    pulseField = Setting.GetPulseField();

    showSeconds = Setting.GetIsShowSeconds();
    showAmPm = Setting.GetIsShowAmPm();
    showWeekNumber = Setting.GetIsShowWeekNumber();
    iconColor = Setting.GetIconColor();
    textColor = Setting.GetTextColor();
    hourColor = Setting.GetHourColor();
    minuteColor = Setting.GetMinuteColor();
    alertColor = Setting.GetAlertColor();
    disturbColor = Setting.GetDoNotDisturbColor();
    weatherStaleTime = Setting.GetWeatherStaleTime();
    weatherCurrentColor = Setting.GetWeatherCurrentColor();

    showIntntnlDate = Setting.GetIntntlDate();

    InitializeWeather();
  }

 public
  function InitializeWeather() {
    var weatherArray = Setting.GetWeatherStorage();
    weather = new Weather();
    if (weatherArray != null && weatherArray has
        : size && weatherArray.size() == Enumerations.WVAL_SIZE) {
      InterpretWeatherData(weatherArray);
    }
  }

 public
  function UpdateWeather(data) { Setting.SetWeatherStorage(data); }

 protected
  function InterpretWeatherData(weatherArray) {
    weather._city = weatherArray[Enumerations.WVAL_CITY_NAME];
    weather._tempCelcius = weatherArray[Enumerations.WVAL_CURR_TEMP];
    weather._feelsTempCelcius = weatherArray[Enumerations.WVAL_FEEL_TEMP];
    weather._baroPressureBars = weatherArray[Enumerations.WVAL_PRESS];
    weather._humidityPercentage = weatherArray[Enumerations.WVAL_HUM];
    weather._windSpeedMeterSeconds = weatherArray[Enumerations.WVAL_WIND_S];
    weather._windDirection = weatherArray[Enumerations.WVAL_WIND_D];
    weather._uvIndex = weatherArray[Enumerations.WVAL_UV];
    weather._sunriseTime = weatherArray[Enumerations.WVAL_SUNRISE];
    weather._sunsetTime = weatherArray[Enumerations.WVAL_SUNSET];
    weather._nextSunriseTime = weatherArray[Enumerations.WVAL_N_SUNRISE];
    weather._dewPoint = weatherArray[Enumerations.WVAL_DEW];
    weather._currentId = weatherArray[Enumerations.WVAL_CURR_ID];
    weather._weatherDateTime = weatherArray[Enumerations.WVAL_DT];
    weather._minTempCelcius = weatherArray[Enumerations.WVAL_T_MIN];
    weather._maxTempCelcius = weatherArray[Enumerations.WVAL_T_MAX];
    weather._todayPrimaryId = weatherArray[Enumerations.WVAL_T_ID];
    weather._todayPrecipitationPercent = weatherArray[Enumerations.WVAL_T_POP];
    weather._nextMinTempCelcius = weatherArray[Enumerations.WVAL_N_MIN];
    weather._nextMaxTempCelcius = weatherArray[Enumerations.WVAL_N_MAX];
    weather._nextPrimaryId = weatherArray[Enumerations.WVAL_N_ID];
    weather._nextPrecipitationPercent = weatherArray[Enumerations.WVAL_N_POP];
    weather._nextNextMinTempCelcius = weatherArray[Enumerations.WVAL_NN_MIN];
    weather._nextNextMaxTempCelcius = weatherArray[Enumerations.WVAL_NN_MAX];
    weather._nextNextPrimaryId = weatherArray[Enumerations.WVAL_NN_ID];
    weather._nextNextPrecipitationPercent =
        weatherArray[Enumerations.WVAL_NN_POP];
    weather._thirdPrimaryId = weatherArray[Enumerations.WVAL_TRD_ID];
    weather._thirdMinTempCelcius = weatherArray[Enumerations.WVAL_TRD_MIN];
    weather._thirdMaxTempCelcius = weatherArray[Enumerations.WVAL_TRD_MAX];
    weather._rainDepth_mm = weatherArray[Enumerations.WVAL_RAIN_DPT];
    weather._snowDepth_mm = weatherArray[Enumerations.WVAL_SNOW_DPT];
    weather._windGust_meterSecs = weatherArray[Enumerations.WVAL_WIND_GUST];
    weather._alertExists = weatherArray[Enumerations.WVAL_ALRT];
    weather._alertName = weatherArray[Enumerations.WVAL_ALERT_NAME];
    weather._errorCode = weatherArray[Enumerations.WVAL_ERROR];
  }

 public
  var isTest;

 public
  var field3;
 public
  var field4;
 public
  var field5;
 public
  var fieldcolor3;
 public
  var fieldcolor4;
 public
  var fieldcolor5;
 public
  var weatherField0;
 public
  var weatherField1;
 public
  var weatherField2;
 public
  var connError;
 public
  var weather;
 public
  var lastKnownLocation;
  //  public
  //   var weatherProvider;
  //  public
  //   var weatherApiKey;
 public
  var weatherWindSystem;
 public
  var dateOrder;
 public
  var showSeconds;
 public
  var showAmPm;
 public
  var showWeekNumber;
 public
  var backgroundColor;
 public
  var iconColor;
 public
  var textColor;
 public
  var hourColor;
 public
  var minuteColor;
 public
  var alertColor;
 public
  var disturbColor;
 public
  var weatherStaleTime;
 public
  var weatherCurrentColor;
 public
  var pulseField;
 public 
  var showIntntnlDate;
}