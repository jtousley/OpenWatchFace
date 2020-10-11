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

// Handle power budget events
//
class PowerBudgetDelegate extends Toybox.WatchUi.WatchFaceDelegate
{
	function initialize()
	{
		WatchFaceDelegate.initialize();
	}
	
	function onPowerBudgetExceeded(powerInfo)
	{
		// Sys.println("Average : " + powerInfo.executionTimeAverage);
		// Sys.println("Allowed : " + powerInfo.executionTimeLimit);
	}
}