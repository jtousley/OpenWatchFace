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
using Toybox.Background as Background;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.StringUtil;

( : background) class OpenWatchFaceApp extends App.AppBase {
 protected
  var _watchFaceView;
 protected
  var _settingsCache;
  static protected var _singleton;
 protected
  var _lastLocation = [];
 protected
  var _appid = null;
  var _received = null;

  function initialize() {
    AppBase.initialize();
    _singleton = self;
  }

  // One does not simply make subroutines in this class

  function setSettings(settings) { _settingsCache = settings; }

  static public function getOpenWatchFaceApp() { return _singleton; }

  // Return the initial view of your application here
  //
  function getInitialView() {
    _watchFaceView = new WatchFaceView();

    baseInitApp();

    InitBackgroundEvents();

    return [ _watchFaceView, new PowerBudgetDelegate() ];
  }

  // New app settings have been received so trigger a UI update
  //
  function onSettingsChanged() {
    baseInitApp();
    InitBackgroundEvents();
    _watchFaceView.InvalidateLayout();
    Toybox.WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    // Sys.println("onBackgroundData");
    try {
      if (data != null && data has
          : size && data.size() == Enumerations.WVAL_SIZE) {
        if (data instanceof
            Toybox.Lang.Array && data[Enumerations.WVAL_ERROR] instanceof
            Toybox.Lang.Number && data[Enumerations.WVAL_ERROR] == 200) {
          // Make city name international
          var cityStr = data[Enumerations.WVAL_CITY_NAME].toString();
          if (cityStr instanceof Toybox.Lang.String) {
            var cityArray = cityStr.toCharArray();
            var internationalName = new[cityArray.size()];
            for (var i = 0; i < cityArray.size(); i++) {
              var num = cityArray[i].toNumber();
              if (num > 255) {
                num = 95;  // Underscore '_'
              }
              internationalName[i] = num.toChar();
            }
            data[Enumerations.WVAL_CITY_NAME] =
                StringUtil.charArrayToString(internationalName);
          }

          // Save data
          _settingsCache.UpdateWeather(data);
          _settingsCache.InitializeWeather();
          // Update time
          var now = Time.now().value();
          Setting.SetLastEventTime(now);

          // Sys.println("Got new weather data");
        }
        //  else {
        //   _settingsCache.weather._errorCode = data[Enumerations.WVAL_ERROR];
        // }
      }
    } catch (ex) {
      // _settingsCache.weather._errorCode = ex.getErrorMessage();
    }
  }

  function getServiceDelegate() { return [new BackgroundServiceDelegate()]; }

  function InitBackgroundEvents() {
    var FIVE_MINUTES = new Toybox.Time.Duration(5 * 60);

    var lastTime = Background.getLastTemporalEventTime();
    if (lastTime != null) {
      var nextTime = lastTime.add(FIVE_MINUTES);
      Background.registerForTemporalEvent(nextTime);
    } else {
      Background.registerForTemporalEvent(Time.now());
    }
  }

  function baseInitApp() {
    // Set base configuraton for displayed fiels
    //
    Setting.SetPulseField(4);
    // Setting.SetIsShowExchangeRate(false);
    for (var i = 0; i < 3; i++) {
      if (Setting.GetField(i) == 0) {  // DisplayPulse is 0
        Setting.SetPulseField(i);
      }
    }

    _settingsCache.initialize();

    // if DarkSky API key wrong switch back to OpenWeather
    //
    // if (Setting.GetWeatherApiKey().length() != 32) {
    //   Setting.SetWeatherProvider(0);
    // }

    // update weather
    //
    // var token = Setting.GetOpenWeatherToken() +
    // Setting.GetWeatherProvider(); if
    // (!token.equals(Setting.GetWeatherRefreshToken())) {
    //   Setting.SetWeatherRefreshToken(token);
    // }
  }
}