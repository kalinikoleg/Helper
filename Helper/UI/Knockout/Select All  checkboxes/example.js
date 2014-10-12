
	self.selectedAllcheckboxes = ko.computed({
		read: function () {
				ko.utils.arrayForEach(self.deviceStatisticList(), function (item) {
				item.selected(self.selectedAll());
			});
			return self.selectedAll();
		},
		owner: self
	});

	$.each(data.list, function (index, value) {
		value.selected = ko.observable(value.selected);
		self.deviceStatisticList.push(value);
	});
