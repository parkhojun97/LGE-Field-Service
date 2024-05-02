/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-19.
 */

({
    gfnDoGetUserInfo  : function (component, event, helper) {
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Start====================');
                console.log('return UserInfo');
                console.log(JSON.stringify(result, null, 2));
                console.log('End====================');
                console.log('result.IsConsultant : ' + result.IsConsultant);
                console.log('result.IsCenterPartsManager : ' + result.IsCenterPartsManager);
                console.log('result.IsConsumableManagementTeam : ' + result.IsConsumableManagementTeam);
                console.log('result.ServiceResource : ' + result.ServiceResource);
                component.set('v.IsConsultant' , result.IsConsultant);
                component.set('v.IsCenterPartsManager' , result.IsCenterPartsManager);
                component.set('v.IsConsumableManagementTeam' , result.IsConsumableManagementTeam);
                component.set('v.ServiceResource', result.ServiceResource);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});