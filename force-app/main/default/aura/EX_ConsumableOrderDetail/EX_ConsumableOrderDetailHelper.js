/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    gfnChgTelFormat: function (component, event, strTel) {

        var strLen = '';
        var strSetValue = '';

        if (!strTel) return strTel;

        strTel = strTel.replace(/[^0-9]/g, '');
        strLen = String(strTel.length);

        switch (strLen) {
            case '8' :
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4); //"###-####";
                break;

            case '9' :
                strSetValue = strTel.substr(0, 2);
                strSetValue += '-' + strTel.substr(2, 3);
                strSetValue += '-' + strTel.substr(5); //"##-###-####";
                break;

            case '10' :

                if (strTel.substr(0, 2) == "02") {
                    strSetValue = strTel.substr(0, 2);
                    strSetValue += '-' + strTel.substr(2, 4);
                    strSetValue += '-' + strTel.substr(6); //"##-####-####";
                } else {
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 3);
                    strSetValue += '-' + strTel.substr(6); //"###-###-####";
                }
                break;

            case '11' :

                strSetValue = strTel.substr(0, 3);
                strSetValue += '-' + strTel.substr(3, 4);
                strSetValue += '-' + strTel.substr(7); //"###-####-####";
                break;


            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
    fnOrderLineItemData : function(component, event, helper) {
        console.log('fnOrderLineItemData');
        var consumableOrderNumber = component.get('v.consumableOrderNumber');
        // Record Id 변경 시 호출
        var action = component.get('c.doGetConsumableOrderData');
        action.setParams({
            'consumableOrderNumber': consumableOrderNumber
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.productRequest', result['productRequest']);
                component.set('v.isEditDeliveryInfo', result['isEditDeliveryInfo']);
                component.set('v.parent', result['parent']);
                
                //gw.lee 23.10.01
                //CaseDescription 오류 수정 조치
                var caseDescription = component.get('v.parent').caseDescription;
                if (caseDescription != undefined && caseDescription != '') {
                    caseDescription = (component.get('v.parent').caseDescription).replace('null','');
                } else {
                    caseDescription = '';
                }
                component.set('v.getRemark', caseDescription);
                // component.set('v.getRemark', (component.get('v.parent').caseDescription).replace('null',''));

                console.log('aaaaaaaaa : '+ result['isEditDeliveryInfo']);
                console.log(result['parent']);
                console.log(JSON.stringify(component.get("v.productRequest")));
                console.log('fnOrderLineItemData 호출 성공 ! ');
            } else {
                console.log('fnOrderLineItemData 호출 실패 ! ');
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

    },
});