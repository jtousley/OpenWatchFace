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
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;

// Main WatchFaace view
// ToDo::
//        -- 1. Create Wrapper around ObjectStore
//        -- 2. Move UI logic to functions
//        -- 3. Fix Timezone Issue
//		  -- 4. Add option to show city name
//		  -- 5. Adjust exchange rate output
//        6. Refactor backround process (error handling)
//        -- 7. Option to Show weather
//        8. Refactor resources, name conventions, etc..
//
class WatchFaceView extends Ui.WatchFace {
 protected
  var _layouts = [];
 protected
  var _fonts = [
    Ui.loadResource(Rez.Fonts.latoBlack_tiny),
    Ui.loadResource(Rez.Fonts.latoBlack_small),
    Ui.loadResource(Rez.Fonts.latoBlack_medium),
    Ui.loadResource(Rez.Fonts.latoBlack_large),
    Ui.loadResource(Rez.Fonts.small_icons),
    Ui.loadResource(Rez.Fonts.large_icons)
  ];

 protected
  var _funcs = [:DisplayLocation               // = 0
                , :DisplayDate                 // = 1
                , :DisplayTime                 // = 2
                , :DisplayPmAm                 // = 3
                , :DisplaySeconds              // = 4
                , :DisplayCurrentTemp          // = 5
                , :DisplayFeelsTemp            // = 6
                , :DisplayTodayMaxTemp         // = 7
                , :DisplayTodayMinTemp         // = 8
                , :DisplayNextMaxTemp          // = 9
                , :DisplayNextMinTemp          // = 10
                , :DisplayNextNextMaxTemp      // = 11
                , :DisplayNextNextMinTemp      // = 12
                , :DisplayWeatherOption1       // = 13
                , :DisplayWeatherOption2       // = 14
                , :DisplayWeatherOption3       // = 15
                , :DisplayTodayWeatherIcon     // = 16
                , :DisplayNextWeatherIcon      // = 17
                , :DisplayNextNextWeatherIcon  // = 18
                , :DisplayCurrWeatherIcon      // = 19
                , :LoadField3                  // = 20
                , :LoadField4                  // = 21
                , :LoadField5                  // = 22
                , :DisplayWatchStatus          // = 23
                , :DisplayBottomLine           // = 24
                , :DisplayTopLine              // = 25
  ];

 protected
  var _wfApp;
  //  protected
  //   var _secDim;
  //  protected
  //   var _is90 = false;
 protected
  var _displayFunctions = new DisplayFunctions();
 protected
  var _colors;
 protected
  var _lastBg = null;
 protected
  var _bgInterval = new Toybox.Time.Duration(59 * 60);  // one hour
 protected
  var _settingsCache = new SettingsCache();

  function initialize() {
    WatchFace.initialize();
    _wfApp = OpenWatchFaceApp.getOpenWatchFaceApp();

    _wfApp.setSettings(_settingsCache);
    _displayFunctions.setSettings(_settingsCache);

    Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
    // Setting.SetWatchServerToken(Ui.loadResource(Rez.Strings.WatchServerTokenValue));
    // Setting.SetExchangeApiKey(Ui.loadResource(Rez.Strings.ExchangeApiKeyValue));
    Setting.SetIsTest(Ui.loadResource(Rez.Strings.IsTest).toNumber() == 1);

    var openWeatherToken = Ui.loadResource(Rez.Strings.OpenWeatherApiKeyValue);
    if (openWeatherToken != null && openWeatherToken has
        : length && openWeatherToken.length() > 0) {
      Setting.SetOpenWeatherToken(openWeatherToken);
    }
    // Setting.SetAccuWeatherToken(
    //     Ui.loadResource(Rez.Strings.AccuWeatherApiKeyValue));
    Setting.SetDeviceName(Ui.loadResource(Rez.Strings.DeviceName));
  }

  // Load your resources here
  //
  function onLayout(dc) {
    // _secDim = [
    //   dc.getTextWidthInPixels("000", _fonts[Enumerations.FONT_SMALL]),
    //   dc.getFontHeight(_fonts[Enumerations.FONT_SMALL])
    // ];  // Font latoBlack_small

    InvalidateLayout();
  }

  // calls every second for partial update
  //
  function onPartialUpdate(dc) {
    // Sys.println("On partial update");
    if (Setting.GetIsShowSeconds()) {
      // dc.setClip(_layouts[Enumerations.LAYOUT_SEC]["x"][0] - _secDim[0],
      //            _layouts[Enumerations.LAYOUT_SEC]["y"][0],
      //            _layouts[Enumerations.LAYOUT_SEC]["x"][0] + 1, _secDim[1]);
      dc.setColor(_colors[Setting.GetTextColor()],
                  _colors[Setting.GetBackgroundColor()]);
      var font = _fonts[Enumerations.FONT_SMALL];
      // var font = _layouts[Enumerations.LAYOUT_SEC]["font"][0];
      // font = ((font > 100) ? _fonts[font - 100] : _fonts[font]);
      dc.drawText(_layouts[Enumerations.LAYOUT_SEC]["x"][0],
                  _layouts[Enumerations.LAYOUT_SEC]["y"][0], font,
                  Sys.getClockTime().sec.format("%02d"),
                  _layouts[Enumerations.LAYOUT_SEC]["jus"][0]);
    }

    if (Setting.GetPulseField() < 3) {
      var layout =
          _layouts[Enumerations.LAYOUT_FIELD_3 + Setting.GetPulseField()];
      var pulseData = _displayFunctions.DisplayPulse(layout);

      if (pulseData[2]) {
        // dc.setClip(layout["x"][1], layout["y"][1], _secDim[0], _secDim[1]);
        dc.setColor(_colors[Setting.GetTextColor()],
                    _colors[Setting.GetBackgroundColor()]);
        var font = _fonts[Enumerations.FONT_SMALL];
        dc.drawText(layout["x"][1], layout["y"][1],
                    // layout["font"][1],
                    font, pulseData[1], layout["jus"][1]);
      }
    }
  }

  // Update the view
  //
  function onUpdate(dc) {
    onPartialUpdate(dc);  // No preprocessor???
    // return;

    _displayFunctions.setTime(Time.now());

    var info = Activity.getActivityInfo();

    if (info != null && info.currentLocation != null) {
      var location = info.currentLocation.toDegrees();
      if (location[0] != 0.0 && location[1] != 0.0) {
        Setting.SetLastKnownLocation(location);
      }
    }

    /// fire background process if needed
    ///
    if (_lastBg == null) {
      _lastBg = new Time.Moment(Time.now().value());
    } else if (_lastBg.add(_bgInterval)
                   .lessThan(new Time.Moment(Time.now().value()))) {
      _lastBg = new Time.Moment(Time.now().value());
      _wfApp.InitBackgroundEvents();
    }

    dc.clearClip();
    dc.setColor(Gfx.COLOR_TRANSPARENT, _colors[Setting.GetBackgroundColor()]);
    dc.clear();

    for (var i = 0; i < _layouts.size(); i++) {
      var funcs = null;
      if (_displayFunctions has _funcs[_layouts[i]["func"]]) {
        funcs = _displayFunctions.method(_funcs[_layouts[i]["func"]])
                    .invoke(_layouts[i]);
      } else {
        funcs = [ "", "", "", "", "" ];
      }

      for (var j = 0; j < _layouts[i]["x"].size(); j++) {
        // Sys.println("Setting color for: " + _layouts[i]["x"]);
        var color = _colors[_layouts[i]["col"][j]];
        if (_layouts[i] has :hasKey && _layouts[i].hasKey("type")) {
          if (_layouts[i]["type"][j] == Enumerations.TYPE_TEXT) {  // text color
            color = _colors[Setting.GetTextColor()];
          } else if (_layouts[i]["type"][j] == Enumerations.TYPE_ICON) { // icon color
            color = _colors[Setting.GetIconColor()];
          }
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);

        var font = _layouts[i]["font"][j] < 100
                       ? _layouts[i]["font"][j]
                       : _fonts[_layouts[i]["font"][j] - 100];
        var text = funcs[j];
        var justification = _layouts[i]["jus"][j];

        dc.drawText(_layouts[i]["x"][j], _layouts[i]["y"][j], font, text,
                    justification);
      }
    }

    dc.setPenWidth(2);
    dc.setColor(_colors[Setting.GetTextColor()], Gfx.COLOR_TRANSPARENT);
    var horiz_line = Ui.loadResource(Rez.JsonData.l_horiz_line);
    dc.drawLine(horiz_line["x"][0], horiz_line["y"][0], horiz_line["x"][1],
                horiz_line["y"][1]);
    var vert_line = Ui.loadResource(Rez.JsonData.l_vert_line);
    dc.drawLine(vert_line["x"][0], vert_line["y"][0], vert_line["x"][1],
                vert_line["y"][1]);

    if (Setting.GetIsTest()) {
      dc.setColor(_colors[Setting.GetTextColor()], Gfx.COLOR_TRANSPARENT);
      dc.drawText(dc.getWidth() / 2, dc.getHeight() - 20, _fonts[0],
                  Setting.GetAppVersion(), Gfx.TEXT_JUSTIFY_CENTER);
    }
  }

  function InvalidateLayout() {
    _colors = [
      0x000000,  // 0 - Enumerations.ColorBlack
      0x555555,  // 1 - Enumerations.ColorDarkGray
      0xAAAAAA,  // 2 - Enumerations.ColorLightGray
      0xFFFFFF,  // 3 - Enumerations.ColorWhite
      0x0000FF,  // 4 - Enumerations.ColorBlue
      0xFF0000,  // 5 - Enumerations.ColorRed
      0x32CD32,  // 6 - Enumerations.ColorLimeGreen
      0x00FF00,  // 7 - Enumerations.ColorLime
      0xD2FF0C,  // 8 - Enumerations.ColorYellowGreen
      0xC8FFBF,  // 9 - Enumerations.ColorPaleGreen
      0xB5EBFF,  // 10 - Enumerations.ColorPaleBlue
      0xFFD3D9,  // 11 - Enumerations.ColorPink
      0x00F6FF,  // 12 - Enumerations.ColorAqua
      0xFFFF00,  // 13 - Enumerations.ColorYellow
      0xFFFF66,  // 14 - Enumerations.ColorPaleYellow
      0xFF422D,  // 15 - Enumerations.ColorYellowRed
      0xF88E46   // 16 - Enumerations.ColorOrange
    ];

    _layouts = [];

    _layouts.add(Ui.loadResource(Rez.JsonData.l_time));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_date));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_top_line));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_sec));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_pmam));

    // if (!Sys.getDeviceSettings().is24Hour) {
    //   _layouts.put("pmam", Ui.loadResource(
    //                            // _is90 ? Rez.JsonData.l_pmam_f90 :
    //                            Rez.JsonData.l_pmam));
    // }

    _layouts.add(Ui.loadResource(Rez.JsonData.l_currTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_currFeelsTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_todayMaxTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_todayMinTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextMaxTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextMinTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextNextMaxTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextNextMinTemp));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_weatherOption1));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_weatherOption2));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_weatherOption3));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_todayWeatherIcon));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_currWeatherIcon));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextWeatherIcon));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_nextNextWeatherIcon));

    _layouts.add(Ui.loadResource(Rez.JsonData.l_city_left));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_field3));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_field4));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_field5));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_battery));
    _layouts.add(Ui.loadResource(Rez.JsonData.l_bottom_line1));

    // _displayFunctions = new DisplayFunctions();
  }
}
