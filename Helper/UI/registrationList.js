$(document).ready(function()
{
    var viewModel = new RegistrationListViewModel();
    ko.applyBindings(viewModel);
    viewModel.init();
});

function Track(id, name, price, isBundle)
{
    var self = this;

    self.id = id;
    self.price = parseFloat(price);
    self.priceFormatted = ko.computed(function()
    {
        try
        {
            return self.price.toFixed(2);
        }
        catch (e)
        {
            return '0.00';
        }
    })
    self.trackName = name;
    self.isBundle = isBundle;
}

function Group(id, groupName, threshold, enrollmentType)
{
    var self = this;

    self.id = id;
    self.groupName = groupName;
    self.threshold = threshold;
    self.enrollmentType = enrollmentType;

}

function EnrollmentType(id, name)
{
    var self = this;

    self.id = id;
    self.name = name;
}

function PaymentStatus(id, name)
{
    var self = this;

    self.id = id;
    self.name = name;
}

function RegistrationListFilter()
{
    var self = this;

    self.registrationId = ko.observable('');
    self.email = ko.observable('');
    self.firstName = ko.observable('');
    self.lastName = ko.observable('');
    self.organization = ko.observable('');
    self.city = ko.observable('');
    self.state = ko.observable('');
    self.country = ko.observable('');
    self.zip = ko.observable('');
    self.discountCode = ko.observable('');
    self.enrollmentId = ko.observable('');
    self.groupId = ko.observable('');
    self.badgeReceived = ko.observable('');
    self.registrationDateFrom = ko.observable('');
    self.registrationDateTo = ko.observable('');
    self.paymentTypeId = ko.observable('');
    self.paymentStatusId = ko.observable('');
}

function RegistrationListEntry(data)
{
    var self = this;

    self.registrationId = data.registrationId;
    self.attendeeId = data.attendeeId;
    self.email = data.email;
    self.firstName = data.firstName;
    self.lastName = data.lastName;
    self.organization = data.organization;
    self.address = data.address;
    self.city = data.city;
    self.state = data.state;
    self.country = data.country;
    self.phone = data.phone;
    self.zip = data.zip;
    self.phoneEmergency = data.phoneEmergency;
    self.nameEmergency = data.nameEmergency;
    self.discountCodeId = data.discountCodeId;
    self.discountCode = data.discountCode;
    self.enrollmentTypeId = data.enrollmentTypeId;
    self.enrollmentTypeName = data.enrollmentTypeName;
    self.groupId = data.groupId;
    self.groupName = data.groupName;
    self.badgeReceived = data.badgeReceived;
    self.badgeReceiveDate = data.badgeReceiveDate;
    self.paymentTypeId = data.paymentTypeId;
    self.paymentTypeName = data.paymentTypeName;
    self.paymentStatusId = data.paymentStatusId;
    self.paymentStatusName = data.paymentStatusName;
    self.serviceId = data.serviceId;
    self.serviceName = data.serviceName;
    self.registrationDate = data.registrationDate;
    self.transactionId = data.transactionId;
    self.checkinDate = data.checkinDate;
    self.checkoutDate = data.checkoutDate;
    self.comment = data.comment;
}

function RegistrationListViewModel()
{
    var self = this;

    self.filter = ko.observable(new RegistrationListFilter());
    self.registrationsList = ko.observableArray([]);
    
    self.tracks = ko.observableArray([]);
    self.enrollmentTypes = ko.observableArray([]);
    self.groups = ko.observableArray([]);
    self.paymentStatuses = ko.observableArray([]);
    
    //view options 
    self.showPersonalInfo = ko.observable(false);
    self.showPaymentInfo = ko.observable(false);
    self.showBadgeInfo = ko.observable(false);
    self.showTrackInfo = ko.observable(false);

    self.showAllInfo = function()
    {
        self.showBadgeInfo(true);
        self.showPaymentInfo(true);
        self.showPersonalInfo(true);
        self.showTrackInfo(true);
    }
    
    self.hideAllInfo = function()
    {
        self.showBadgeInfo(false);
        self.showPaymentInfo(false);
        self.showPersonalInfo(false);
        self.showTrackInfo(false);
    }

    self.loadRegistrations = function()
    {
        $.ajax({
            type: 'POST',
            url: "api/pfic/GetRegistrationsList",
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: self.filter(),
            error: function(jqXHR, textStatus, errorThrown) {
                
            },
            success: function(resultJson) {
                var result = $.parseJSON(resultJson);
                var registrationsList = $.map(result, function(value){
                    return new RegistrationListEntry(value);
                })
                self.registrationsList(registrationsList);
            }
        });
    }
    
    self.init = function()
    {
        var tracksReq = self.loadTracks();
        var groupsReq = self.loadGroups();
        var enrTypesReq = self.loadEnrollmentTypes();
        var paymStatuses = self.loadPaymentStatuses();
        $.when(tracksReq, groupsReq, enrTypesReq, paymStatuses).then(function()
        {
            //self.loader.HideLoading(self.settings.loaderSelector);
            self.loadRegistrations();
        })
    }
    
    self.loadTracks = function()
    {
        return $.ajax("api/pfic/getTracks", {
            data: {},
            type: "get",
            success: function(result) {
                var res = $.parseJSON(result);
                if (res != null)
                {
                    var tracks = $.map(res, function(item)
                    {
                        return new Track(item.id, item.trackName, item.price, item.isBundle);
                    });
                    self.tracks(tracks);
                   // self.selectedTrackId(tracks[0].id);
                }
            }
        });
    }

    self.loadGroups = function()
    {
        return $.ajax("api/pfic/getGroups", {
            data: {},
            type: "get",
            success: function(result) {
                var res = $.parseJSON(result);
                if (res != null)
                {
                    var groups = $.map(res, function(item)
                    {
                        return new Group(item.id, item.groupName, item.threshold, item.enrollmentType);
                    });
                    self.groups(groups);
                  //  self.selectedGroupId(groups[0].id);
                }
            }
        });
    }
    
    self.loadPaymentStatuses = function()
    {
        return $.ajax("api/pfic/getPaymentStatuses", {
            data: {},
            type: "get",
            success: function(result) {
                var res = $.parseJSON(result);
                if (res != null)
                {
                    var paymentStatuses = $.map(res, function(item)
                    {
                        return new PaymentStatus(item.id, item.statusName);
                    });
                    self.paymentStatuses(paymentStatuses);
                  //  self.selectedGroupId(groups[0].id);
                }
            }
        });
    }

    self.loadEnrollmentTypes = function()
    {
        return $.ajax("api/pfic/getEnrollmentTypes", {
            data: {},
            type: "get",
            success: function(result) {
                var res = $.parseJSON(result);
                if (res != null)
                {
                    var enrTypes = $.map(res, function(item)
                    {
                        return new EnrollmentType(item.id, item.name);
                    });
                    self.enrollmentTypes(enrTypes);
                 //   self.selectedEnrollmentTypeId(enrTypes[0].id);
                }
            }
        });
    }
    
    self.deleteRegistrationEntry = function()
    {
        
    }
}


