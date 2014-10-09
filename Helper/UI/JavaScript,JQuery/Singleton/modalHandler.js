var ModalHandler = (function() {
    // class instance
    var _instance = null;

    //private
    var _options = {};

    // constructor
    function Init(o) {
        _options = $.extend(true, _options, o || {});
    }

    // public
    Init.prototype = {
        getOptions: function () {
            return _options;
        },
        blockUI: function (popupId) {
            $.blockUI.defaults.css.cursor = 'default';
            $.blockUI.defaults.overlayCSS.cursor = 'default';
            $.blockUI({ message: $('#' + popupId) });
        }
    }

    return function (args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    }

}());

var modalHandler = new ModalHandler();