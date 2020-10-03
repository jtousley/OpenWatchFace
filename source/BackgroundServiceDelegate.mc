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
using Toybox.Application as App;
using Toybox.Time as Time;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
( : background) class BackgroundServiceDelegate extends Sys.ServiceDelegate {
 protected
  var _received = null;
  var _lastLocation = [];
  var _lastLocationData = null;
  var _locationKey = null;
  var _appid = null;
  var _isErr = false;

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
    initReceived();
  }

  function initReceived() {
    _received = [
      0,  //   WVAL_CURR_TEMP = 0,
      0,  // WVAL_FEEL_TEMP = 1,
      0,  // WVAL_PRESS = 2,
      0,  // WVAL_HUM = 3,
      0,  // WVAL_WIND_S = 4,
      0,  // WVAL_WIND_D = 5,
      0,  // WVAL_UV = 6,
      0,  // WVAL_SUNRISE = 7,
      0,  // WVAL_SUNSET = 8,
      0,  // WVAL_N_SUNRISE = 9,
      0,  // WVAL_DEW = 10,
      0,  // WVAL_CURR_ID = 11,
      0,  // WVAL_DT = 12,
      0,  // WVAL_T_MIN = 13,
      0,  // WVAL_T_MAX = 14,
      0,  // WVAL_T_ID = 15,
      0,  // WVAL_T_POP = 16,
      0,  // WVAL_N_MIN = 17,
      0,  // WVAL_N_MAX = 18,
      0,  // WVAL_N_ID = 19,
      0,  // WVAL_N_POP = 20,
      0,  // WVAL_NN_MIN = 21,
      0,  // WVAL_NN_MAX = 22,
      0,  // WVAL_NN_ID = 23,
      0,  // WVAL_NN_POP = 24,
      0,  // WVAL_TRD_ID = 25,
      0,  // WVAL_TRD_MIN = 26,
      0,  // WVAL_TRD_MAX = 27,
      0,  // WVAL_RAIN_DPT = 28,
      0,  // WVAL_SNOW_DPT = 29,
      0,  // WVAL_WIND_GUST = 30,
      0,  // WVAL_ALRT = 31,
      "Unknown city",  // WVAL_CITY_NAME = 32,
      "Unknown alert",  // WVAL_ALERT_NAME = 33,
      0  // WVAL_ERROR = 34,
         // WVAL_SIZE = 35
    ];
  }

  ( : debug) function printMessage(msg) { Sys.println(msg); }

  ( : production) function printMessage(msg) {}

  function onTemporalEvent() {
    var doUpdate = false;
    try {
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
        } else {
          printMessage("Not enough time elapsed");
        }
      }
      lastEventTime = null;
      lastWeather = null;

    } catch (ex) {
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
    initReceived();
    if (doUpdate) {
      RequestUpdate();
    }
  }

  // function RequestAccuWeatherLocation() {
  //   var apiParam =
  //       Lang.format("apikey=$1$", [Setting.GetAccuWeatherToken()
  //                                     // Setting.GetOpenWeatherToken()
  //   ]);
  //   var url = Lang.format(
  //       "https://dataservice.accuweather.com/locations/v1/cities/geoposition/"
  //       +
  //           "search?$3$&q=$1$%2C%20$2$",
  //       [ _lastLocation[0], _lastLocation[1], apiParam ]);
  //   printMessage("URL : " + url);
  //   var options = {
  //       :method => Comm.HTTP_REQUEST_METHOD_GET,
  //       :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
  //     };

  //   Comm.makeWebRequest(url, {}, options, method( : RequestAccuWeatherData));
  // }

  // function RequestAccuWeatherData(responseCode, data) {
  //   if (responseCode == 200) {
  //     if (data != null && data has : hasKey && data.hasKey("Key")) {
  //       _locationKey = data.get("Key");
  //       _lastLocationData = data;
  //     }

  //     if (_locationKey != null) {
  //       var apiParam =
  //           Lang.format("apikey=$1$", [Setting.GetAccuWeatherToken()
  //                                         // Setting.GetOpenWeatherToken()
  //       ]);
  //       var url = Lang.format(
  //           "https://dataservice.accuweather.com/currentconditions/v1/" +
  //               "$1$?$2$&details=true",
  //           [ _locationKey, apiParam ]);
  //       printMessage("URL2 : " + url);
  //       var options = {
  //       :method => Comm.HTTP_REQUEST_METHOD_GET,
  //       :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
  //     };

  //       Comm.makeWebRequest(url, {}, options,
  //                           method(
  //                               : OnReceiveOpenWeatherUpdate));
  //     }
  //   } else {
  //     _isErr = true;
  //   }
  // }

  function RequestOpenWeather() {
    var url = "https://api.openweathermap.org/data/2.5/weather";

    Comm.makeWebRequest(url, 
      // PARAMS
      {     "lat" => _lastLocation[0],
            "lon" => _lastLocation[1],
            "units" => "metric",
            "cnt" => 1,
            "appid" =>  _appid
      },
      // OPTIONS
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
      method( : OnReceiveOpenLocationUpdate));
  }

  function RequestOpenWeatherData() {
    var url = "https://api.openweathermap.org/data/2.5/onecall";

    Comm.makeWebRequest(url, 
    // PARAMS
    {     "lat" => _lastLocation[0],
          "lon" => _lastLocation[1],
          "exclude" => "minutely,hourly",
          "cnt" => 3,
          "units" => "metric",
          "appid" =>  _appid
    },
    // OPTIONS
     {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
       method( : OnReceiveOpenWeatherUpdate));
  }

  function RequestUpdate() {
    // printMessage("RequestUpdate - Memory: " + Sys.getSystemStats().usedMemory
    // +
    //             "/" + Sys.getSystemStats().totalMemory + ":" +
    //             Sys.getSystemStats().freeMemory);
    var data = {};
    try {
      // var weatherProviders = ["OpenWeather", "DarkSky"];
      // var weatherApiKey = Setting.GetWeatherApiKey();
      // var weatherProvider = Setting.GetWeatherProvider();
      var location = Setting.GetLastKnownLocation();
      _appid = Setting.GetOpenWeatherToken();
      printMessage("Appid : " + _appid);
      if (location == null) {
        printMessage("Could not get location");
      } else if (_appid == null || (_appid has
                                    : length && _appid.length() == 0)) {
        printMessage("Invalid key");
      }
      // else if (false) {  // Accuweather
      //   if (location != _lastLocation) {
      //     _lastLocation = location;
      //     RequestAccuWeatherLocation();
      //   } else {
      //     RequestAccuWeatherData(200, _lastLocationData);
      //   }
      // }
      else {
        _lastLocation = location;
        RequestOpenWeather();
      }
    } catch (ex) {
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
  }

  function OnReceiveOpenLocationUpdate(responseCode, data) {
    printMessage("OnReceiveOpenLocationUpdate - Memory: " +
                 Sys.getSystemStats().usedMemory + "/" +
                 Sys.getSystemStats().totalMemory + ":" +
                 Sys.getSystemStats().freeMemory);
    try {
      if (responseCode != 200) {
        _isErr = true;
        printMessage("API calls exceeded : " + responseCode);
      } else {
        if (data == null) {
          printMessage("Failed to get response from weather service");
        }
        _received[WVAL_CITY_NAME] = data["name"];
      }
    } catch (ex) {
      _isErr = true;
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
    if (_isErr) {
      Background.exit(_received);
    } else {
      RequestOpenWeatherData();
    }
  }

  function OnReceiveOpenWeatherUpdate(responseCode, data) {
    printMessage("OnReceiveOpenWeatherUpdate : " + responseCode);
    _received[WVAL_ERROR] = responseCode;
    try {
      if (responseCode != 200) {
        _isErr = true;
        printMessage("API calls exceeded : " + responseCode);
      } else {
        ParseReceivedData(data);
        data = null;
      }
    } catch (ex) {
      _isErr = true;
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
    try {
      Background.exit(_received);
    } catch (ex) {
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
  }

  function ParseReceivedData(data) {
    try {
      if (data != null) {
        // printMessage("Data: " + data.toString());

        _received[WVAL_CURR_TEMP] = ((data has
                                      : hasKey) &&
                                             (data["current"] != null) &&
                                             (data["current"]["temp"] != null)
                                         ? data["current"]["temp"]
                                         : 0);

        _received[WVAL_FEEL_TEMP] =
            ((data has
              : hasKey) &&
                     (data["current"] != null) &&
                     (data["current"]["feels_like"] != null)
                 ? data["current"]["feels_like"]
                 : 0);

        _received[WVAL_PRESS] = ((data has
                                  : hasKey) &&
                                         (data["current"] != null) &&
                                         (data["current"]["pressure"] != null)
                                     ? data["current"]["pressure"]
                                     : 0);

        _received[WVAL_HUM] = ((data has
                                : hasKey) &&
                                       (data["current"] != null) &&
                                       (data["current"]["humidity"] != null)
                                   ? data["current"]["humidity"]
                                   : 0);

        _received[WVAL_WIND_S] =
            ((data has
              : hasKey) &&
                     (data["current"] != null) &&
                     (data["current"]["wind_speed"] != null)
                 ? data["current"]["wind_speed"]
                 : 0);

        _received[WVAL_WIND_D] = ((data has
                                   : hasKey) &&
                                          (data["current"] != null) &&
                                          (data["current"]["wind_deg"] != null)
                                      ? data["current"]["wind_deg"]
                                      : 0);

        _received[WVAL_UV] = ((data has
                               : hasKey) &&
                                      (data["current"] != null) &&
                                      (data["current"]["uvi"] != null)
                                  ? data["current"]["uvi"]
                                  : 0);

        _received[WVAL_SUNRISE] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["sunrise"] != null)
                 ? data["daily"][0]["sunrise"]
                 : 0);

        _received[WVAL_SUNSET] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["sunset"] != null)
                 ? data["daily"][0]["sunset"]
                 : 0);

        _received[WVAL_DEW] = ((data has
                                : hasKey) &&
                                       (data["current"] != null) &&
                                       (data["current"]["dew_point"] != null)
                                   ? data["current"]["dew_point"]
                                   : 0);

        _received[WVAL_CURR_ID] =
            ((data has
              : hasKey) &&
                     (data["current"] != null) &&
                     (data["current"]["weather"] != null) &&
                     (data["current"]["weather"].size() > 0) &&
                     (data["current"]["weather"][0]["id"] != null)
                 ? data["current"]["weather"][0]["id"].toNumber()
                 : 0);

        _received[WVAL_DT] = ((data has
                               : hasKey) &&
                                      (data["current"] != null) &&
                                      (data["current"]["dt"] != null)
                                  ? data["current"]["dt"]
                                  : 0);

        _received[WVAL_T_MIN] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["temp"] != null) &&
                     (data["daily"][0]["temp"]["min"] != null)
                 ? data["daily"][0]["temp"]["min"]
                 : 0);

        _received[WVAL_T_MAX] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["temp"] != null) &&
                     (data["daily"][0]["temp"]["max"] != null)
                 ? data["daily"][0]["temp"]["max"]
                 : 0);

        _received[WVAL_T_ID] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["weather"] != null) &&
                     (data["daily"][0]["weather"].size() > 0) &&
                     (data["daily"][0]["weather"][0]["id"] != null)
                 ? data["daily"][0]["weather"][0]["id"].toNumber()
                 : 0);

        _received[WVAL_T_POP] =  // probability of precipitation
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["pop"] != null)
                 ? data["daily"][0]["pop"]
                 : 0);

        _received[WVAL_RAIN_DPT] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["rain"] != null)
                 ? data["daily"][0]["rain"]
                 : 0);

        _received[WVAL_SNOW_DPT] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["snow"] != null)
                 ? data["daily"][0]["snow"]
                 : 0);

        _received[WVAL_WIND_GUST] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 0) &&
                     (data["daily"][0]["wind_gust"] != null)
                 ? data["daily"][0]["wind_gust"]
                 : 0);

        _received[WVAL_N_MIN] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) &&
                     (data["daily"].size() > 1 &&
                      data["daily"][1]["temp"] != null &&
                      data["daily"][1]["temp"]["min"] != null)
                 ? data["daily"][1]["temp"]["min"]
                 : 0);

        _received[WVAL_N_MAX] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) &&
                     (data["daily"].size() > 1 &&
                      data["daily"][1]["temp"] != null &&
                      data["daily"][1]["temp"]["max"] != null)
                 ? data["daily"][1]["temp"]["max"]
                 : 0);

        _received[WVAL_N_ID] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 1) &&
                     (data["daily"][1]["weather"] != null) &&
                     (data["daily"][1]["weather"].size() > 0) &&
                     (data["daily"][1]["weather"][0]["id"] != null)
                 ? data["daily"][1]["weather"][0]["id"].toNumber()
                 : 0);

        _received[WVAL_N_POP] =  // probability of precipitation
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 1) &&
                     (data["daily"][1]["pop"] != null)
                 ? data["daily"][1]["pop"]
                 : 0);

        _received[WVAL_N_SUNRISE] =  // tomorrow sunrise
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 1) &&
                     (data["daily"][1]["sunrise"] != null)
                 ? data["daily"][1]["sunrise"]
                 : 0);

        // NEXT NEXT DAY

        _received[WVAL_NN_MIN] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 2) &&
                     (data["daily"][2]["temp"] != null) &&
                     (data["daily"][2]["temp"]["min"] != null)
                 ? data["daily"][2]["temp"]["min"]
                 : 0);

        _received[WVAL_NN_MAX] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 2) &&
                     (data["daily"][2]["temp"] != null) &&
                     (data["daily"][2]["temp"]["max"] != null)
                 ? data["daily"][2]["temp"]["max"]
                 : 0);

        _received[WVAL_NN_ID] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 2) &&
                     (data["daily"][2]["weather"] != null) &&
                     (data["daily"][2]["weather"].size() > 0) &&
                     (data["daily"][2]["weather"][0]["id"] != null)
                 ? data["daily"][2]["weather"][0]["id"].toNumber()
                 : 0);

        _received[WVAL_NN_POP] =  // probability of precipitation
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 2) &&
                     (data["daily"][2]["pop"] != null)
                 ? data["daily"][2]["pop"]
                 : 0);

        // THIRD DAY

        _received[WVAL_TRD_MIN] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 3) &&
                     (data["daily"][3]["temp"] != null) &&
                     (data["daily"][3]["temp"]["min"] != null)
                 ? data["daily"][3]["temp"]["min"]
                 : 0);

        _received[WVAL_TRD_MAX] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 3) &&
                     (data["daily"][3]["temp"] != null) &&
                     (data["daily"][3]["temp"]["max"] != null)
                 ? data["daily"][3]["temp"]["max"]
                 : 0);

        _received[WVAL_TRD_ID] =
            ((data has
              : hasKey) &&
                     (data["daily"] != null) && (data["daily"].size() > 3) &&
                     (data["daily"][3]["weather"] != null) &&
                     (data["daily"][3]["weather"].size() > 0) &&
                     (data["daily"][3]["weather"][0]["id"] != null)
                 ? data["daily"][3]["weather"][0]["id"].toNumber()
                 : 0);

        _received[WVAL_ALRT] =
            ((data has
              : hasKey) &&
                     (data["alerts"] != null) && (data["alerts"].size() > 0) &&
                     (data["alerts"][0]["event"] != null)
                 ? 1
                 : 0);

        _received[WVAL_ALERT_NAME] =
            ((data has
              : hasKey) &&
                     (data["alerts"] != null) && (data["alerts"].size() > 0) &&
                     (data["alerts"][0]["event"] != null)
                 ? data["alerts"][0]["event"]
                 : "Unknown");
      }
    } catch (ex) {
      _isErr = true;
      if (ex has : getErrorMessage) {
        printMessage(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        printMessage(ex.printStackTrace());
      }
    }
  }
}