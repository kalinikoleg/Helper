    if ($(".filter_date_from").length && $(".filter_date_to").length) {
        $(".filter_date_from").each(function (index, value) {
            var dateFrom = $(this);
            var groupId = $(this).attr("date-group");//should set this attr

            $(".filter_date_to").each(function (index, value) {
                var dateTo = $(this);
                if (dateTo.attr("date-group") == groupId) {
                    initializeDataPicker(dateFrom, dateTo); //from js file
                }
            });
        });
    }



var initializeDataPicker = function (dateFrom, dateTo) {
    dateFrom.filter_input({ regex: '^[0-9/]$' });
    dateTo.filter_input({ regex: '^[0-9/]$' });

    dateFrom.datepicker(
     {
         dateFormat: 'mm/dd/yy',
         defaultDate: dateFrom.val(),
         maxDate: dateTo.val(),
         changeMonth: true,
         changeYear: true,
         onSelect: function () {
             dateTo.datepicker("option", "minDate", dateFrom.datepicker("getDate"));
         },
         onClose: function () {
             dateFrom.change();
         }
     });
    dateTo.datepicker(
    {
        dateFormat: 'mm/dd/yy',
        defaultDate: dateTo.val(),
        minDate: dateFrom.val(),
        changeMonth: true,
        changeYear: true,
        onSelect: function () {
            dateFrom.datepicker("option", "maxDate", dateTo.datepicker("getDate"));
        },
        onClose: function () {
            dateTo.change();
        }
    });
};