var NotificationHandler = (function () {
    // class instance
    var _instance = null;

    //private
    var _options = {};

    var _showSuccessMessage = function(message) {
        if (message) {
            alertify.success(message);
        } 
    }

    var _showErrorMessage = function (message) {
        if (message) {
            alertify.error(message);
        } else {
            alertify.error(NO_RESPONSE);
        }
    }

    // constructor
    function Init(o) {
        _options = $.extend(true, _options, o || {});
    }

    // public
    Init.prototype = {
        getOptions: function () {
            return _options;
        },
        showSuccessMessage: function(message) {
            _showSuccessMessage(message);
        },
        showErrorMessage: function(message) {
            _showErrorMessage(message);
        }
    }

    return function (args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    }
}());

var notificationHandler = new NotificationHandler();
