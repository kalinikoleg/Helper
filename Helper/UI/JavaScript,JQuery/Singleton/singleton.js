
var Singleton = (function () {
    //Class instance
    var _instance = null;

    //Private
    var test1 = 1;
    var options = {};
    var loader = new Loader();

    var getError = function() {
        return new PNotify({
            title: 'Oh No!',
            text: 'An error occurred while processing your request. Please try again.',
            type: 'error'
        });
    }
    var getSuccess = function() {
        return new PNotify({
            title: 'Success',
            text: 'The information about selected devices was deleted successful.',
            type: 'success'
        });
    }

    //Constructor
    function Init(o) {
        options = $.extend(true, options, o || {});
    }

    //Public
    Init.prototype = {
        getVar: function () {
            return test1;
        },
        getOptions: function () {
            return options;
        },
        getSuccessMessage: function () {
            getSuccess();
        },
        getErrorMessage: function () {
            getError();
        },
        sendAjax: function (url, requestData, currentObject, type) {
            if (!type) {
                type = 'POST';
            }
            $.ajax({
                type: type,
                url: url,
                contentType: "application/json; charset=utf-8",
                data: ko.toJSON(requestData),
                error: function (jqXHR, textStatus, errorThrown) {
                    getError();
                },
                success: function (result) {
                    if (requestData.onSuccess) {
                        requestData.onSuccess(result);
                    } else {
                        getError();
                    }
                },
                complete: function (XMLHttpRequest, textStatus) {
                    loader.HideLoading('mainContent');
                },
                beforeSend: function () {
                    loader.ShowLoading('mainContent');
                }
            });
        }
    }

    return function (args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    }
}());

var ob = new Singleton({ x: 1 });

