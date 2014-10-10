
function PageState(data) {
    var self = this;

    self.page = data.page;
    self.totalRecords = data.totalRecords;
    self.totalPages = data.totalPages;
    self.recordsPerPage = data.recordsPerPage;
}

function Pager(pager, dataLoadCallback) {
    var self = this;

    self.pageState = new PageState(pager);
    self.dataLoadCallback = dataLoadCallback;

    self.pagerSettings = {
        leaps: false,
        currentPage: pager.page,
        totalPages: pager.totalPages,
        bootstrapMajorVersion: 3,
        onPageClicked: function (e, originalEvent, type, page) {
            self.pageState.page = self.pagerSettings.currentPage = page;
            self.dataLoadCallback();
        },
        itemContainerClass: function (type, page, current) {
            return (page === current) ? "active" : "";
        }
    };

    self.UpdatePagerState = function (data) {
        self.pageState.page = data.page;
        self.pagerSettings.currentPage = data.page;
        self.pageState.totalPages = self.pagerSettings.totalPages = data.totalPages;
        self.pageState.totalRecords = data.totalRecords;
        self.pageState.recordsPerPage = data.recordsPerPage;
    };

    self.RenderPager = function (selectors) {
        for (var i = 0; i < selectors.length; i++) {
            if (self.pageState.totalPages > 1) {
                $(selectors[i]).bootstrapPaginator(self.pagerSettings);
                $(selectors[i]).show();
                $('.pagination').removeClass('hide');
                $('.pagination-part').removeClass('hide');

            } else {
                $('.pagination').addClass('hide');
                $('.pagination-part').addClass('hide');
            }
        }
    };
}