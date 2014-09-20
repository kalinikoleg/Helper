
var homeViewModel = function () {
    self = this;

    self.feature1Visible = ko.observable(true);
    self.feature3Visible = ko.observable(false);
    self.feature2Visible = ko.observable(false);

    self.chanheVisible = function (id) {
        switch (id) {
            case 1:
                self.feature1Visible(true);
                self.feature3Visible(false);
                self.feature2Visible(false);
                break;
            case 2:
                self.feature1Visible(false);
                self.feature3Visible(false);
                self.feature2Visible(true);
                break;
            case 3:
                self.feature1Visible(false);
                self.feature3Visible(true);
                self.feature2Visible(false);
                break;
        }
    };
}

$(function () {
    var viewModel = new homeViewModel();

    ko.applyBindings(viewModel);
});
