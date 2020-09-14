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

using Toybox.Application as App;
using Toybox.Application.Storage as Storage;

/// Wrapper class for stored properties
///
( : background) class Setting {
  static protected var _lastKnownLocation = "lastKnownLocation";
  // static protected var _etz = "etz";
  static protected var _isTest = "isTest";
  static protected var _pulseField = "pulse-field";
  static protected var _appVersion = "appVersion";
  static protected var _conError = "conError";
  static protected var _authError = "authError";
  static protected var _deviceName = "device-name";
  static protected var _weather = "weather-v2";
  static protected var _weatherCity = "city-v1";
  static protected var _openWeatherApiToken = "Open-Weather-API-Token";
  static protected var _accuWeatherApiToken = "accu-weather-api-token";
  static protected var _weatherProvider = "weather-provider";
  static protected var _dateOrder = "date-order";
  static protected var _textColor = "TextColor";
  static protected var _lastTemporalEventTime = "LastEventTime";
  static protected var _windSystem = "windSystem";
  static protected var _tempSystem = "tempSystem";
  static protected var _distSystem = "distSystem";
  static protected var _altimeterSystem = "altimeter-system";
  static protected var _barometricSystem = "barometric-system";
  static protected var _field0 = "field-0";
  static protected var _field1 = "field-1";
  static protected var _field2 = "field-2";
  static protected var _wfield0 = "wfield-0";
  static protected var _wfield1 = "wfield-1";
  static protected var _wfield2 = "wfield-2";
  static protected var _hourColor = "HourColor";
  static protected var _minColor = "MinColor";
  static protected var _backgroundColor = "BackgroundColor";
  static protected var _showTimeOptions = "ShowTimeOptions";

 public
  static function GetDateOrder() {
    var val = App.getApp().getProperty(_dateOrder);
    return (val != null ? val : "");
  }

 public
  static function GetWeatherStorage() {
    var val = App.getApp().getProperty(_weather);
    // return (val != null ? val : null);
    return val;
  }

 public
  static function SetWeatherStorage(weather) {
    App.getApp().setProperty(_weather, weather);
  }

 public
  static function GetWeatherCityStorage() {
    var val = App.getApp().getProperty(_weatherCity);
    return (val != null ? val : "UNKNOWN_CITY");
  }

 public
  static function SetWeatherCityStorage(city) {
    App.getApp().setProperty(_weatherCity, city);
  }

  //  public
  //   static function GetWeatherProvider() {
  //     var tmp = App.getApp().getProperty(_weatherProvider);
  //     return tmp != null ? tmp : 0;
  //   }

  //  public
  //   static function SetWeatherProvider(weatherProvider) {
  //     App.getApp().setProperty(_weatherProvider, weatherProvider);
  //   }

 public
  static function SetDeviceName(deviceNme) {
    // Storage.setValue(_deviceName, deviceNme);
    App.getApp().setProperty(_deviceName, deviceNme);
  }

 public
  static function GetDeviceName() {
    // return Storage.getValue(_deviceName);
    var tmp = App.getApp().getProperty(_deviceName);
    return tmp != null ? tmp : "unknown";
  }

 public
  static function GetOpenWeatherToken() {
    var val = App.getApp().getProperty(_openWeatherApiToken);
    // return (val != null ? val : "");
    return val;
  }

 public
  static function SetOpenWeatherToken(openWeatherApiToken) {
    return App.getApp().setProperty(_openWeatherApiToken, openWeatherApiToken);
  }

 public
  static function GetAccuWeatherToken() {
    var val = App.getApp().getProperty(_accuWeatherApiToken);
    return (val != null ? val : "");
  }

 public
  static function SetAccuWeatherToken(accuWeatherApiToken) {
    return App.getApp().setProperty(_accuWeatherApiToken, accuWeatherApiToken);
  }

 public
  static function GetConError() {
    // return Storage.getValue(_conError);
    var val = App.getApp().getProperty(_conError);
    return (val != null ? val : "");
  }

 public
  static function SetConError(conError) {
    // Storage.setValue(_conError, conError);
    var val = App.getApp().setProperty(_conError, conError);
  }

 public
  static function SetTextColor(color) {
    var val = App.getApp().setProperty(_textColor, color);
  }

 public
  static function SetLastEventTime(time) {
    App.getApp().setProperty(_lastTemporalEventTime, time);
  }

 public
  static function GetLastEventTime() {
    return App.getApp().getProperty(_lastTemporalEventTime);
  }

 public
  static function GetTextColor() {
    var val = App.getApp().getProperty(_textColor);
    return (val != null ? val : 3);
  }

 public
  static function GetHourColor() {
    var val = App.getApp().getProperty(_hourColor);
    return (val != null ? val : GetTextColor());
  }

 public
  static function GetMinuteColor() {
    var val = App.getApp().getProperty(_minColor);
    return (val != null ? val : GetTextColor());
  }

 public
  static function GetBackgroundColor() {
    var val = App.getApp().getProperty(_backgroundColor);
    return (val != null ? val : 0);
  }

  //  public
  //   static function GetWeatherApiKey() {
  //     var waKey = App.getApp().getProperty("WeatherApiKey");
  //     return waKey != null ? waKey : "";
  //   }

 public
  static function GetLastKnownLocation() {
    var val = App.getApp().getProperty(_lastKnownLocation);
    return val;
  }

 public
  static function SetLastKnownLocation(lastKnownLocation) {
    App.getApp().setProperty(_lastKnownLocation, lastKnownLocation);
    // Storage.setValue(_lastKnownLocation, lastKnownLocation);
  }

 public
  static function SetAppVersion(appVersionValue) {
    // Storage.setValue(_appVersion, appVersionValue);
    App.getApp().setProperty(_appVersion, appVersionValue);
  }

 public
  static function GetAppVersion() {
    // return Storage.getValue(_appVersion); //, appVersionValue
    var appVersion = App.getApp().getProperty(_appVersion);
    return appVersion != null ? appVersion : "0.0";
  }

 public
  static function GetWindSystem() {
    var val = App.getApp().getProperty(_windSystem);
    return (val != null ? val : 0);
  }

 public
  static function SetTempSystem(system) {
    App.getApp().setProperty(_tempSystem, system);
  }

 public
  static function GetTempSystem() {
    var val = App.getApp().getProperty(_tempSystem);
    return (val != null ? val : 0);
  }

 public
  static function GetDistSystem() {
    var val = App.getApp().getProperty(_distSystem);
    return (val != null ? val : 0);
  }

 public
  static function GetAltimeterSystem() {
    var val = App.getApp().getProperty(_altimeterSystem);
    return (val != null ? val : 0);
  }

 public
  static function GetBarometricSystem() {
    var val = App.getApp().getProperty(_barometricSystem);
    return (val != null ? val : 0);
  }

 public
  static function GetIsTest() {
    var isTest = App.getApp().getProperty(_isTest);
    return isTest != null ? isTest : false;
  }

 public
  static function SetIsTest(isTest) {
    return App.getApp().setProperty(_isTest, isTest);
  }

 public
  static function GetPulseField() {
    var val = App.getApp().getProperty(_pulseField);
    return (val != null ? val : "");
  }

 public
  static function SetPulseField(pulseField) {
    App.getApp().setProperty(_pulseField, pulseField);
  }

 public
  static function GetIsShowSeconds() {
    var val = App.getApp().getProperty(_showTimeOptions) == 0;
    return (val != null ? val : false);
  }

 public
  static function GetIsShowAmPm() {
    var val = App.getApp().getProperty(_showTimeOptions) == 1;
    return (val != null ? val : false);
  }

 public
  static function GetField(id) {
    var val = App.getApp().getProperty("field-" + id).toNumber();
    return (val != null ? val : "");
  }

 public
  static function GetWField(id) {
    var val = App.getApp().getProperty("wfield-" + id).toNumber();
    return (val != null ? val : "");
  }
}