/// <reference path="../knockout.validation.debug.js" />
/// <reference path="../knockout-3.1.0.debug.js" />
/// <reference path="../ko.extenders.js" />
/// <reference path="../jquery-1.10.2.intellisense.js" />

$(document).ready(function () {
    var viewModel = ko.validatedObservable(new CartViewModel());
    viewModel().bindModel(initialData);
    ko.applyBindings(viewModel);

    $('body').popover({
        selector: '.hint-popover',
        trigger: 'hover',
        content: "You can find out what's your PC identifier by clicking the info button in Forensic wiping system interface",
        container: 'body'
    });
});


function PriceListItem(data) {
    var self = this;

    self.id = data.id;
    self.priceId = data.priceId;
    self.name = data.name;
    self.type = data.type;
    self.price = data.price;
    self.priceFormatted = ko.computed(function () {
        return self.price.toFixed(2);
    });
}

function OrderItem(data) {
    var self = this;

    self.id = data.id;
    self.quantity = ko.observable(data.quantity).extend({ length: 5, isNum: true, withPrevious: 1, rateLimit: 50, notify: 'always' });
    self.isActive = ko.observable(data.isActive).watch(false);
    self.priceListItem = new PriceListItem(data.priceListItem);

    //explicitly state that we are NOT watching for changes for these elements to prevent unnecessary refreshes
    self.additionalInfo = ko.observable(data.additionalInfo)
                            .extend({
                                validation: {//custom validator for element
                                    validator: function (value, self) {
                                        if (self.priceListItem.type != 1 || !self.isActive())
                                        {
                                            return true;
                                        }
                                        return (value != null && $.trim(value) != "");
                                    },
                                    message: "Please enter the PC identifier",
                                    params: self
                                }
                            })
                            .watch(false);
}

function CartViewModel() {
    var self = this;

    self.orderItems = ko.observableArray([]).extend({ validArray: true });
    self.priceList = ko.observableArray([]);

    self.total = ko.observable(0);

    self.totalFormatted = ko.computed(function () {
        return self.total().toFixed(2);
    });

    self.isSubmitDisabled = ko.computed(function () {
        if (self.total() == 0) {
            return true;
        }
        else {

            return false;
        }
    });

    self.bindModel = function (data) {
        var mappedOrderItems = $.map(data.orderItems, function (item) {
            return new OrderItem(item);
        });
        var mappedPriceList = $.map(data.priceList, function (item) {
            return new PriceListItem(item);
        });

        self.orderItems.push.apply(self.orderItems, mappedOrderItems);
        self.priceList.push.apply(self.priceList, mappedPriceList);
        self.total(data.total);

        //watch out for change of observable in orderItem array
        ko.watch(self.orderItems, {}, function (parent, child, item) {
            if (parent[0].isActive() && parent[0].priceListItem.type == 2 && child.changed()) {
                self.updateTotals();
            }
        });

        //we need to refresh totals in case getting device details or wipes were pre-selected
        self.updateTotals();
    }

    self.updateTotals = function () {
        $.ajax({
            type: 'POST',
            url: "/Billing/CalculateTotals",
            contentType: "application/json; charset=utf-8",
            data: ko.toJSON(self.orderItems),
            error: function (jqXHR, textStatus, errorThrown) {
                var error = new PNotify({
                    title: 'Oh No!',
                    text: 'Error establishing connection to server',
                    type: 'error'
                });
            },
            success: function (result) {
                self.total(result.totals);
            }
        });

        //for observable value to be set on click event (by default it blocks default behavior)
        return true;
    }

    self.submit = function () {
        // we need to simulate change for validation to be triggered for each orderItem element
        $('.validatable').trigger("change"); 
        if (!self.isSubmitDisabled() && self.isValid()) {
            $.ajax({
                type: 'POST',
                url: "/Billing/SaveOrder",
                contentType: "application/json; charset=utf-8",
                data: ko.toJSON({
                    orderItems: self.orderItems,
                    payMethod: $('input[name=paymentType]:checked').val()
                }),
                error: function (jqXHR, textStatus, errorThrown) {
                    var error = new PNotify({
                        title: 'Oh No!',
                        text: 'Error establishing connection to server',
                        type: 'error'
                    });
                },
                success: function (result) {
                    switch (result.Type) {
                        case 0:
                            document.location.href = "/Billing/PaymentDetails";
                            break;
                        case 1:
                            var warning = new PNotify({
                                title: 'Warning',
                                text: result.Text,
                                type: 'warning'
                            });
                            break;
                    }
                }
            });
        }
    }
}