
var Singleton = (function () {
    //Class instance
    var _instance = null;

    //Private

    var test1 = 1;
    var options = {};

    var fnPrivate = function () {
        //some code   
    }

    //Constructor
    function Init(o) {
        options = $.extend(true, options, o || {});
    }

    //Public
    Init.prototype = {
        pub: 0,
        fnTest: function() {
            return test1;
        },
        getOptions: function() {
            return options;
        }
    }

    return function(args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    }
}());

var ob = new Singleton({ x: 1 });

