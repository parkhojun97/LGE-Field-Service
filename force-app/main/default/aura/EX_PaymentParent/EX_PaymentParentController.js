/**
 * Created by A78916 on 2023-02-09.
 */


({

    onInit: function (component, event, helper) {
        component.set('v.totalAmount', component.get('v.SETTLE_AMT'));
        console.log(component.get('v.recordId'));
        helper.retrieve(component, component.get('v.recordId'), component.get('v.ContactId'), component.get('v.DEPT_CODE_ID'));
    },
    onAfterScriptLoaded: function (component, event, helper) {
    },
    onDestroy: function (component, event, helper) {
        // fixme 이미 저정했다면 무시한다.
        // if (!helper.validateAll(component)) {
        //     helper.complete(component);
        // }
    },
    onEvent: function (component, event, helper) {
        helper.onEvent(component, event);
    },

});