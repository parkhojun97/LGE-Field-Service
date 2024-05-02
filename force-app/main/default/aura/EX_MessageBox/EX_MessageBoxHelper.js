/**
 * Created by I2MAX.SEUNGHUNAN on 2023-02-04.
 */
({
    fn_initialize : function(component, event, helper) {
        component.set('v.message',null);
        component.set('v.callback',null);
        component.set('v.isOpen',false);
        component.set('v.showSpinner', false);
        component.set('v.resendType', null);
    }
})