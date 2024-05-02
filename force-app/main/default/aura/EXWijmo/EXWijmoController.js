/**
 * Created by I2MAX.JAEYEONLEE on 2023-07-05.
 */

({
    onInit: function (component, event, helper) {
        component.set('v.gid', component.getGlobalId());
        console.log('isControler :::: ' + component.get('v.isControl'));
        helper.addWijmoListener(component);
    },
    onDestroy: function (component, event, helper) {
        helper.removeWijmoListener(component);
    },
    message: function (component, event, helper){
        const params = event.getParam('arguments');
        if (params) {
            helper.sendMessage(component, params.payload);
        }
    },
});