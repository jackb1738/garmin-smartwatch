import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class TestingCadenceMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :set_min_cadence) {
            // Push a number picker to set minimum cadence
            var picker = new WatchUi.NumberPicker(WatchUi.NUMBER_PICKER_NUMBER);
            var app = Application.getApp();
            var currentMin = app.getProperty("minCadence");
            if (currentMin == null) {
                currentMin = 160;
            }
            picker.setTitle(new WatchUi.Text({:text=>"Min Cadence", :color=>Graphics.COLOR_WHITE}));
            picker.setValue(currentMin);
            picker.setRange(120, 220);
            WatchUi.pushView(picker, new MinCadencePickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (item == :set_max_cadence) {
            // Push a number picker to set maximum cadence
            var picker = new WatchUi.NumberPicker(WatchUi.NUMBER_PICKER_NUMBER);
            var app = Application.getApp();
            var currentMax = app.getProperty("maxCadence");
            if (currentMax == null) {
                currentMax = 180;
            }
            picker.setTitle(new WatchUi.Text({:text=>"Max Cadence", :color=>Graphics.COLOR_WHITE}));
            picker.setValue(currentMax);
            picker.setRange(120, 220);
            WatchUi.pushView(picker, new MaxCadencePickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }

}

class MinCadencePickerDelegate extends WatchUi.NumberPickerDelegate {
    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        var app = Application.getApp();
        app.setProperty("minCadence", value);
        System.println("Min cadence set to: " + value);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class MaxCadencePickerDelegate extends WatchUi.NumberPickerDelegate {
    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        var app = Application.getApp();
        app.setProperty("maxCadence", value);
        System.println("Max cadence set to: " + value);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
