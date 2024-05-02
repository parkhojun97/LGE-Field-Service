/**
 * Created by pttc on 12/15/22.
 */

({
    onFocus: function (component, event, helper) {
        if (false === component.get('v.isFocused')) {
            component.set('v.isFocused', true);
            component.find('amount').focus();
            helper.dispatch(component, 'focused', {});
        }
    },
    handleChange: function (component, event, helper) {
        helper.dispatch(component, 'method', {method: component.get('v.paymentMethod')});
    },
    handleClickInput: function (component, event, helper) {
        const value = component.get('v.amount');
        if (component.get('v.isLocked') == false) {
            if ((!value || 0 > value)) {
                if (!component.get('v.isAmountDisabled') && component.get('v.balance') >= 0) {
                    component.set('v.amount', component.get('v.balance'));
                }
            }else{
               component.set('v.amount', 0);
            }
        }
    },
    //24 01 08 hyungho.chun 포인트 승인 실패시 총 밸런스 초기화
    totalPaymentReset: function (component, event, helper) {
        
        component.set('v.amount', event.getParam('amount'));
    },

    //23 08 23 hyungho.chun blur쓰지않음
    // handleBlurAmount: function (component, event, helper) {
    //     const value = component.get('v.amount');
    //     if(value == null || value ==''){
    //         value = 0;
    //     }

    //     component.set('v.amount', +value < 0 ? -value : +value);
    //     component.find('amount').reportValidity();
    // },
    handleReset: function (component, event, helper) {
        helper.confirm('확인', '취소 진행하시겠습니까?')
            .then(() => {
                console.log('slot :' + component.get('v.slot'));
                component.get('v.slot').onObserved(component.get('v.slotNo'), 'reset', {});
            });
    },
    handleKeyDown: function (component, event, helper) {
        helper.restrictCharacter(event);
    },
    fnCancel: function (component, event, helper) {
        if(event.getParam('isCancelPayment') == true && event.getParam('CancelStatus') == '취소'){
            component.set('v.amount',0);
        }
        component.get('v.slot').onObserved(2, 'reset', {});
    },
    //23 08 22 hyungho.chun serviceResource 정보 받음
    getContactInfo: function(component, event, helper) {

        // console.log('event init!!!');
        // component.set('v.objCont',event.getParam('objCont'));
        // component.set('v.objEmp', event.getParam('objEmp'));
        // component.set('v.isManagement',event.getParam('isManagement'));
        // console.log(event.getParam('isManagement'));
        // const emp = component.get('v.objEmp');

        // const cash = component.get('v.cashParam');
        // const cont = component.get('v.objCont');
        // console.log('eeeeee '+ emp.Phone);
        // if(emp.Phone == null || emp.Phone == undefined){
        //     console.log('eeeeee '+ component.get('v.PhoneNumber'));
        //     emp.Phone = component.get('v.PhoneNumber');
        // }
        // if(event.getParam('isManagement')){
        //     component.set('v.param.receiverName', cont.Name);
        //     component.set('v.param.receiverMobile', cont.MobilePhone);
        // }
        // component.set('v.objEmp',emp);

        component.set('v.serviceResource',event.getParam('ServiceResource'));
        // component.set('v.prId',event.getParam('prId'));

        console.log(component.get('v.serviceResource') +'!!!!!');
    },

    handleLocked: function(component, event, helper) {
        component.set('v.isLocked', true);
    },
});