var PagerHandler = (function() {
    // class instance
    var _instance = null;

    //private
    var _options = {};
    var _pager = null;

    // constructor
    function Init(o) {
        _options = $.extend(true, _options, o || {});
    }

    // public
    Init.prototype = {
        getOptions: function() {
            return _options;
        },
        setDataloadCallBack: function(dataLoadCallBack, pager) {
            // pager - override default pager 
            if (pager) {
                _pager = new Pager(pager, dataLoadCallBack);
            } else {
                // default pager
                _pager = new Pager({
                    page: 1,
                    totalPages: 1,
                    totalRecords: 1,
                    recordsPerPage: 12
                }, dataLoadCallBack);
            }
        },
        getPageState: function() {
            return _pager.pageState;
        },
        updatePager: function(pager, renderPagerSelector) {
            _pager.UpdatePagerState(pager);
            if (renderPagerSelector) {
                _pager.RenderPager([renderPagerSelector]);
            } else {
                _pager.RenderPager([".pagination"]);
            }
        },
        setPage: function (number) {

            _pager.pageState.page = number;
        }
    };

    return function(args) {
        if (!_instance) {
            _instance = new Init(args);
        }
        return _instance;
    };
}());

var pagerHandler = new PagerHandler();