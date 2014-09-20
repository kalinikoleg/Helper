$(function () {
    var viewModel = new ajaxViewModel();
    viewModel.getUserList();

    ko.applyBindings(viewModel);
});

function ajaxViewModel() {
    var self = this;

    //functions
    self.getUserList = function (data, event) {
        var parameters = {
            id: 5
        }

        $.ajax({
            type: 'POST',
            contentType: 'application/json; charset=utf-8', //this type will be send to the server
            dataType: 'json', //this type back from the server
            url: "/Ajax/GetUserList",
            data: ko.toJSON(parameters),
            error: function (jqXHR, textStatus, errorThrown) {
                alert(jqXHR.responseText);
            },
            success: function (result) {
                //return in json format
                var res = result;
            },
            complete: function (XMLHttpRequest, textStatus) {
                //self.loader.HideLoading('mainContent');
            },
            beforeSend: function (xhr) {
                var securityToken = $('[name=__RequestVerificationToken]').val();
                xhr.setRequestHeader('__RequestVerificationToken', securityToken);
                //self.loader.ShowLoading('mainContent');
            }
        });
    };
}