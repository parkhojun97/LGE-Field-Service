/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    fnInit: function (component, event, helper) {

    },

    fnGetOrderData  : function (component, event, helper) {
        var selectedRows = event.getParam('data');
        console.log('selectedRows');
        console.log(selectedRows);
        //component.set('v.consumableOrderNumber', selectedRows[0].Order_Number__c);
        var lightningCard = component.find('cardTitle');
        lightningCard.set('v.title', '주문 번호 : ' + selectedRows[0].Order_Number__c);


    },

    fnOrderLineItemData  : function (component, event, helper) {
            console.log('fnOrderLineItemData');

            var consumableOrderNumber = component.get('v.consumableOrderNumber');
            // Record Id 변경 시 호출
            var action = component.get('c.doGetConsumableOrderData');
            action.setParams({
                'consumableOrderNumber' : consumableOrderNumber
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('Start====================');
                    console.log(result);
                    console.log('End====================');
                    component.set('v.productRequest', result['productRequest']);
                    component.set('v.parent', result['parent']);

                } else {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                }
                component.set('v.showSpinner', false);
            });
            $A.enqueueAction(action);
        }

});