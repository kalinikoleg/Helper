/// <reference path="knockout-3.1.0.debug.js" />

ko.extenders.numeric = function (target, precision) {
    //create a writeable computed observable to intercept writes to our observable
    var result = ko.computed({
        read: target,  //always return the original observables value
        write: function (newValue) {
            var current = target(),
                roundingMultiplier = Math.pow(10, precision),
                newValueAsNum = isNaN(newValue) ? 0 : parseFloat(+newValue),
                valueToWrite = Math.round(newValueAsNum * roundingMultiplier) / roundingMultiplier;

            //only write if it changed
            if (valueToWrite !== current) {
                target(valueToWrite);
            } else {
                //if the rounded value is the same, but a different value was written, force a notification for the current field
                if (newValue !== current) {
                    target.notifySubscribers(valueToWrite);
                }
            }
        }
    });

    //initialize with current value to make sure it is rounded appropriately
    result(target());

    //return the new computed observable
    return result;
};

ko.extenders.length = function (target, length) {
    //create a writeable computed observable to intercept writes to our observable
    var result = ko.computed({
        read: target,  //always return the original observables value
        write: function (newValue) {
            var current = target(),
                valueToWrite = newValue;
            if (newValue.toString().length > length) {
                valueToWrite = parseInt(newValue.toString().substring(0, length));
            }
            //only write if it changed
            if (valueToWrite !== current) {
                target(valueToWrite);
            } else {
                if (newValue !== current) {
                    //we refresh target value, otherwise subscribers won't be notified
                    //target.notifySubscribers doesn't work for some reason
                    target(newValue);
                    target(valueToWrite);
                }
            }
        }
    });

    //initialize with current value to make sure it is appropriate
    result(target());

    //return the new computed observable
    return result;
};

ko.extenders.isNum = function (target, isNum) {
    //create a writeable computed observable to intercept writes to our observable
    var result = ko.computed({
        read: target,  //always return the original observables value
        write: function (newValue) {
            var current = target(),
                valueToWrite = parseInt(newValue);
            if (typeof newValue == 'string' && isNaN(parseInt(newValue))) {
                valueToWrite = 1;
            }
            //only write if it changed
            if (valueToWrite !== current) {
                target(valueToWrite);
            } else {
                //if the rounded value is the same, but a different value was written, force a notification for the current field
                if (newValue !== current) {
                    target.notifySubscribers(valueToWrite);
                }
            }
        }
    });

    //initialize with current value to make sure it is appropriate
    result(target());

    //return the new computed observable
    return result;
};

ko.extenders.minValue = function (target, minValue) {
    //create a writeable computed observable to intercept writes to our observable
    var result = ko.computed({
        read: target,  //always return the original observables value
        write: function (newValue) {
            var current = target();
            var valueToWrite = parseInt(newValue);
            if (valueToWrite < minValue) {
                valueToWrite = minValue;
            }
            if (typeof newValue == 'string' && isNaN(parseInt(newValue))) {
                valueToWrite = minValue;
            }
            //only write if it changed
            if (valueToWrite !== current) {
                target(valueToWrite);
            } else {
                //if the rounded value is the same, but a different value was written, force a notification for the current field
                if (newValue !== current) {
                    target.notifySubscribers(valueToWrite);
                }
            }
        }
    });

    //initialize with current value to make sure it is appropriate
    result(target());

    //return the new computed observable
    return result;
};

ko.extenders.withPrevious = function (target) {
    // Define new properties for previous value and whether it's changed
    target.previous = ko.observable();
    target.changed = ko.computed(function () { return target() !== target.previous(); });

    // Subscribe to observable to update previous, before change.
    target.subscribe(function (v) {
        target.previous(v);
    }, null, 'beforeChange');

    // Return modified observable
    return target;
}

/*
 * Aggregate validation of all the validated elements within an array
 * Parameter: true|false
 * Example
 *
 * viewModel = {
 *    person: ko.observableArray([{
 *       name: ko.observable().extend({ required: true }),
 *       age: ko.observable().extend({ min: 0, max: 120 })
 *    }, {
 *       name: ko.observable().extend({ required: true }),
 *       age: ko.observable().extend({ min:0, max:120 })
 *    }].extend({ validArray: true })
 * }   
*/
ko.validation.rules["validArray"] = {
    validator: function (arr, bool) {
        if (!arr || typeof arr !== "object" || !(arr instanceof Array)) {
            throw "[validArray] Parameter must be an array";
        }
        return bool === (arr.filter(function (element) {
            return ko.validation.group(ko.utils.unwrapObservable(element))().length !== 0;
        }).length === 0);
    },
    message: "Every element in the array must validate to '{0}'"
};

ko.validation.registerExtenders();