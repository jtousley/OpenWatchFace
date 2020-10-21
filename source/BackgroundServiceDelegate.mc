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

using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time as Time;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
( : background) class BackgroundServiceDelegate extends Sys.ServiceDelegate {
 public
  var _received = null;
  var _lastLocation = [];
  var _appid = null;
  var _city = "unk";

  // Duplicated from Enumerations.mc because
  // :background services don't have access
  enum {
    WVAL_CURR_TEMP = 0,
    WVAL_FEEL_TEMP = 1,
    WVAL_PRESS = 2,
    WVAL_HUM = 3,
    WVAL_WIND_S = 4,
    WVAL_WIND_D = 5,
    WVAL_UV = 6,
    WVAL_SUNRISE = 7,
    WVAL_SUNSET = 8,
    WVAL_N_SUNRISE = 9,
    WVAL_DEW = 10,
    WVAL_CURR_ID = 11,
    WVAL_DT = 12,
    WVAL_T_MIN = 13,
    WVAL_T_MAX = 14,
    WVAL_T_ID = 15,
    WVAL_T_POP = 16,
    WVAL_N_MIN = 17,
    WVAL_N_MAX = 18,
    WVAL_N_ID = 19,
    WVAL_N_POP = 20,
    WVAL_NN_MIN = 21,
    WVAL_NN_MAX = 22,
    WVAL_NN_ID = 23,
    WVAL_NN_POP = 24,
    WVAL_TRD_ID = 25,
    WVAL_TRD_MIN = 26,
    WVAL_TRD_MAX = 27,
    WVAL_RAIN_DPT = 28,
    WVAL_SNOW_DPT = 29,
    WVAL_WIND_GUST = 30,
    WVAL_ALRT = 31,
    WVAL_CITY_NAME = 32,
    WVAL_ALERT_NAME = 33,
    WVAL_ERROR = 34,
    WVAL_SIZE = 35
  }

  function
  initialize() {
    Sys.ServiceDelegate.initialize();
  }

  // ( : debug) function printMessage(msg) { Sys.println(msg); }

  // ( : production) function printMessage(msg) {}

  function onTemporalEvent() {
    _received = null;

    var connected = true;
    var sSettings = Sys.getDeviceSettings();
    if (sSettings has : connectionAvailable) {
      connected = sSettings.connectionAvailable;
    }
    // Sys.println("onTemporalEvent - Memory: " +
    // Sys.getSystemStats().freeMemory +
    //             "/" + Sys.getSystemStats().totalMemory);
    var doUpdate = false;

    var now = new Time.Moment(Time.now().value());
    var lastEventTime = Setting.GetLastEventTime();
    var lastWeather = Setting.GetWeatherStorage();
    var frequency = Setting.GetWeatherUpdateTime();
    if (lastEventTime == null || lastWeather == null || frequency == null ||
        (lastWeather has
         : size && lastWeather.size() == 0)) {
      doUpdate = true;
    } else {
      var waitTime = new Time.Duration(frequency * 60);
      var lastEvent = new Time.Moment(lastEventTime);
      if (lastEvent.add(waitTime).lessThan(now)) {
        doUpdate = true;
      }
    }
    lastEventTime = null;
    lastWeather = null;
    var location = Setting.GetLastKnownLocation();
    _appid = Setting.GetOpenWeatherToken();

    if (connected && doUpdate && location != null && _appid != null &&
        (_appid has
         : length && _appid.length() != 0)) {
      _lastLocation = location;
      var url = "https://api.openweathermap.org/data/2.5/weather";

      Comm.makeWebRequest(
            url,
            // PARAMS
            {"lat" => _lastLocation[0], 
            "lon" => _lastLocation[1],
            "units" => "metric", 
            "appid" => _appid},
            // OPTIONS
            {
            :method => Comm.HTTP_REQUEST_METHOD_GET,
            :headers => {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON},
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            method(:OnReceiveOpenLocationUpdate));
    } else {
      // printMessage("No update");
      _received = new[WVAL_SIZE];
      _received[WVAL_ERROR] = 0;
      _received[WVAL_CITY_NAME] = _city;
      Background.exit(_received);
    }
  }

  function OnReceiveOpenLocationUpdate(responseCode, data) {
    if (responseCode != 200) {
      // printMessage("API calls exceeded : " + responseCode);
      _received = new[WVAL_SIZE];
      _received[WVAL_ERROR] = responseCode;
      _received[WVAL_CITY_NAME] = _city;
      Background.exit(_received);
    } else {
      if (data != null) {
        _city = data["name"];
        data = null;
      }
    }

    var url = "https://api.openweathermap.org/data/2.5/onecall";

    Comm.makeWebRequest(
        url,
        // PARAMS
        {
        "lat" => _lastLocation[0],
        "lon" => _lastLocation[1],
        "exclude" => "minutely,hourly",
        "units" => "metric",
        "appid" => _appid
        },
        // OPTIONS
        {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        },
        method(:OnReceiveOpenWeatherUpdate));
  }

  function OnReceiveOpenWeatherUpdate(responseCode, data) {
    // printMessage("OnReceiveOpenWeatherUpdate - Memory: " +
    //              Sys.getSystemStats().freeMemory);
    // Sys.println("OnReceiveOpenWeatherUpdate : " + responseCode);

    // initReceived();
    _received = new[WVAL_SIZE];
    var success = false;
    if (responseCode == 200) {
      // ParseReceivedData(data);
      var current = "current";
      var daily = "daily";
      var temp = "temp";
      var weather = "weather";

      if (data != null) {
        // printMessage("Data: " + data.toString());
        _received[WVAL_CITY_NAME] = _city;

        _received[WVAL_CURR_TEMP] =
            getValFromDict(data, current, temp, -1, -1, -1);

        _received[WVAL_FEEL_TEMP] =
            getValFromDict(data, current, "feels_like", -1, -1, -1);

        _received[WVAL_PRESS] =
            getValFromDict(data, current, "pressure", -1, -1, -1);

        _received[WVAL_HUM] =
            getValFromDict(data, current, "humidity", -1, -1, -1);

        _received[WVAL_WIND_S] =
            getValFromDict(data, current, "wind_speed", -1, -1, -1);

        _received[WVAL_WIND_D] =
            getValFromDict(data, current, "wind_deg", -1, -1, -1);

        _received[WVAL_UV] = getValFromDict(data, current, "uvi", -1, -1, -1);

        _received[WVAL_SUNRISE] =
            getValFromDict(data, daily, 0, "sunrise", -1, -1);

        _received[WVAL_SUNSET] =
            getValFromDict(data, daily, 0, "sunset", -1, -1);

        _received[WVAL_DEW] =
            getValFromDict(data, current, "dew_point", -1, -1, -1);

        _received[WVAL_CURR_ID] =
            getValFromDict(data, current, weather, 0, "id", -1);

        _received[WVAL_DT] = getValFromDict(data, current, "dt", -1, -1, -1);

        _received[WVAL_T_MIN] =
            getValFromDict(data, daily, 0, "temp", "min", -1);

        _received[WVAL_T_MAX] =
            getValFromDict(data, daily, 0, "temp", "max", -1);

        _received[WVAL_T_ID] =
            getValFromDict(data, daily, 0, "weather", 0, "id");

        // probability of precipitation
        _received[WVAL_T_POP] = getValFromDict(data, daily, 0, "pop", -1, -1);

        _received[WVAL_RAIN_DPT] =
            getValFromDict(data, daily, 0, "rain", -1, -1);

        _received[WVAL_SNOW_DPT] =
            getValFromDict(data, daily, 0, "snow", -1, -1);

        _received[WVAL_WIND_GUST] =
            getValFromDict(data, daily, 0, "wind_gust", -1, -1);

        _received[WVAL_N_MIN] =
            getValFromDict(data, daily, 1, "temp", "min", -1);

        _received[WVAL_N_MAX] =
            getValFromDict(data, daily, 1, "temp", "max", -1);

        _received[WVAL_N_ID] = getValFromDict(data, daily, 1, weather, 0, "id");

        // probability of precipitation
        _received[WVAL_N_POP] = getValFromDict(data, daily, 1, "pop", -1, -1);

        _received[WVAL_N_SUNRISE] =
            getValFromDict(data, daily, 1, "sunrise", -1, -1);

        // NEXT NEXT DAY

        _received[WVAL_NN_MIN] =
            getValFromDict(data, daily, 2, temp, "min", -1);

        _received[WVAL_NN_MAX] =
            getValFromDict(data, daily, 2, temp, "max", -1);

        _received[WVAL_NN_ID] =
            getValFromDict(data, daily, 2, weather, 0, "id");

        // probability of precipitation
        _received[WVAL_NN_POP] = getValFromDict(data, daily, 2, "pop", -1, -1);

        // THIRD DAY

        _received[WVAL_TRD_MIN] =
            getValFromDict(data, daily, 3, temp, "min", -1);

        _received[WVAL_TRD_MAX] =
            getValFromDict(data, daily, 3, temp, "max", -1);

        _received[WVAL_TRD_ID] =
            getValFromDict(data, daily, 3, weather, 0, "id");

        var alert = getValFromDict(data, "alerts", 0, "event", -1, -1);

        _received[WVAL_ALRT] = 0;
        _received[WVAL_ALERT_NAME] = "unk alrt";
        if (alert instanceof Toybox.Lang.String) {
          _received[WVAL_ALRT] = 1;
          _received[WVAL_ALERT_NAME] = alert;
          // printMessage("Alert : " + alert);
        }
        _received[WVAL_ERROR] = responseCode;
        success = true;
      }
      data = null;
    }
    if (success) {
      /*
      HOURLY data
      var url = "https://api.openweathermap.org/data/2.5/forecast";

      Comm.makeWebRequest(
        url,
        // PARAMS
        {
        "lat" => _lastLocation[0],
        "lon" => _lastLocation[1],
        "cnt" => 3,
        "units" => "metric",
        "appid" => _appid
        },
        // OPTIONS
        {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        },
        method(:OnReceiveOpenWeatherUpdate));
      */
      Background.exit(_received);
    } else {
      _received = new[WVAL_SIZE];
      _received[WVAL_ERROR] = responseCode;
      _received[WVAL_CITY_NAME] = _city;
      Background.exit(_received);
    }
  }

  function getValFromDict(parseObj, firstKey, secondKey, thirdKey, fourthKey,
                          fifthKey) {
    // Allowed types:
    // data["key"][0]["key2"][1]["key3"]
    // data["key"]["key2"]
    // data["key"]["key2"][0]["key3"]
    var val = 0;
    if (parseObj != null) {
      // No need to check this since we always pass -1
      // if((firstKey instanceof String && parseObj has: hasKey)){}
      if (firstKey instanceof Number && firstKey < 0) {
        return parseObj;
      }
      val = getValFromDict(parseObj[firstKey], secondKey, thirdKey, fourthKey,
                           fifthKey, -1);  // recursion
    }
    return val;
  }
}