
var AjaxHandler = (function () {
    // class instance
    var _instance = null;

    // private variables
    var _options = {};

    if (typeof Loader != "undefined") {
        var loader = new Loader();
        loader.InitLoader();
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
        sendAjaxPost: function (url, requestData) {
            var request = $.ajax({
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                url: url,
                data: ko.toJSON(requestData),
                dataType: 'json',
                beforeSend: function () {
                    if (loader) {
                        loader.ShowLoading(MAIN_SELECTOR);
                    }
                }
            });
            request.done(function (data) {
                if (requestData.onSuccess) {
                    requestData.onSuccess(data);
                }
            });
            request.fail(function (xhr, textStatus, errorThrown) {
                switch (xhr.status) {
                    case 401:
                        // Unauthorized 
                        window.location.reload(true);
                        break;
                    case 500:
                        // Server is unavailable
                        notificationHandler.showErrorMessage(INTERNAL_SERVER_ERROR);
                        return;
                }
                notificationHandler.showErrorMessage(NO_RESPONSE);
            });
            request.always(function () {
                if (loader) {
                    loader.HideLoading(MAIN_SELECTOR);
                }
            });
        }//end sendAjax
    }

    return function (args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    }
}());

var ajaxHandler = new AjaxHandler();

