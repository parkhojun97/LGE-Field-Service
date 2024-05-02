/**
 * Created by pttc on 12/15/22.
 */

({

    onFocus: function (component, event, helper) {
        // 결제 내역이 있고 '결제 완료' 버튼이 활성화되는 경우 여기에 포커스가 주어진다.
        if (false === component.get('v.isFocused') && false === component.get('v.isLocked')) {
            component.set('v.isFocused', true);
            component.find('slot_1').setFocus();
            helper.update(helper.getSlots(component), '', 'focused', {});
        }
    },
    handleOk: function (component, event, helper) {
        helper.completeWithValidation(component);
    },

    handleClose:function (component, event, helper) {
        const evt = component.getEvent('onClose');
        evt.fire();
    },

    handlePrint:function (component, event, helper) {

        helper.reprintAll(component);
    },
    fnPaymentComplete: function(component, event, helper){
        // var soldOutOrderData = component.get('v.SoldOutOrderData');
        // // 품절주문의 결제요청은 품절주문건들 결제와 동시에 결제 후 데이터 삽입
        // if (component.get('v.isManagement') && soldOutOrderData.length !== 0) {
        //     console.log('soldOutOrderSize :: ' + soldOutOrderData.length);
        //     helper.updateSoldOutOrder(component, soldOutOrderData);
        // }

        //23 12 04 hyungho.chun 결제예약버튼 누르자마자 일단 비활성화
        component.set('v.isReadyToGo',false);
        //24.01.18 gw.lee 결제약버튼 누를 시, 닫기 버튼 비활성화
        component.set('v.cancelFlag', true);
        console.log('fnPaymentComplete event call');
        var emId = component.get('v.emId');
        console.log('emId :: ',emId);
        var emType = component.get('v.emType');
        console.log('emType :: ',emType);
        var receiverNumber = component.get('v.receiverNumber');
        console.log('receiverNumber :: ',receiverNumber);
        var prId = component.get('v.prId');
        let offset =  new Date().getTimezoneOffset() * 60000;
        let dateOffset = new Date(new Date().getTime() - offset);
        console.log('속도측정 -------------------------------------------------- EX_Payment.cmp.fnPaymentComplete - start(카카오메세지직전):' + dateOffset.toISOString());
        if (emId != null && emId != undefined) {
            return new Promise((resolve,reject)=>{
                // if (emId != null && emId != undefined) {
                    var action = component.get('c.sendExMessage');
        
                    action.setParams({
                        'emId': emId,
                        'templateType': emType,
                        'receiverNumber': receiverNumber,
                        'prId': prId
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
        
        
                            //23 11 16 hyungho.chun
                            if(result.isSuccess){
                                console.log('카카오톡 송신 성공');
                            }else{
                                console.log('카카오톡 송신 실패');
                                helper.toast("화이트리스트 대상 번호가 아닙니다. (MsgWhitelist__mdt 데이터 등록 바람.");
        
                            }
                            // if (result.STATUS == 'SUCCESS') {
                            //     console.log('SUCCESS MESSAGE');
                            // } else {
                            //     console.log('state success , 결과겂 fail ');
                            //     console.log(result.MESSAGE);
                            // }
                            console.log('속도측정 -------------------------------------------------- EX_Payment.cmp.fnPaymentComplete - 성공(카카오메세지):' + dateOffset.toISOString());
                            resolve(result);
                        }else{
                            var errors = response.getError();
                            console.log('state 값 자체가 fail');
                            helper.toast("화이트리스트 대상 번호가 아닙니다. (MsgWhitelist__mdt 데이터 등록 바람.");
                            var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
                            evt.setParams({"complete" : true});
                            evt.fire();
                            component.destroy()
                            reject(errors);
                        } 
                        //23 12 04 hyungho.chun 결제예약버튼 리턴값후에 다시 활성화
                        component.set('v.isReadyToGo',true);
                        component.set('v.cancelFlag', false);
                    });
        
                    $A.enqueueAction(action);
                    
                // }            
                    
            }).then(()=>{
                var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
                evt.setParams({"complete" : true});
                evt.fire();
                component.destroy();
            })
        }
        var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
        evt.setParams({"complete" : true});
        evt.fire();
        component.destroy();        


//        helper.showToast("Success",'결제가 완료되었습니다.');
    },
//    onEvent : function(component, event, helper){
//        helper.onEvent(component, event);
//    }
    fnClose: function (component, event, helper) {
        helper.toast("결제가 중단 되었습니다");
        component.set('v.isCancel',true);
        if(component.get('v.isReset')){
            component.destroy();
        }
        if(component.get('v.isEXOpen') == false){
            var evt = $A.get("e.c:EX_PaymentCancelEvent_evt");
			evt.setParams({
				"isCancelPayment" : true,
				"CancelStatus" : '초기화'
			});
            evt.fire();

            // 24 01 02 PHJ
            var evt = $A.get("e.c:EX_PaymentModalCancelEvt_evt");
            evt.setParam('cancelModal', true);
            evt.fire();
        }

    },
    dmlBeforeResend : function(component, event, helper) {
        var orderData = component.get('v.OrderData');
        var soldOutOrderData = component.get('v.SoldOutOrderData');
        console.log('orderData :: ' + JSON.stringify(orderData));
        console.log('soldOutOrderData :: ' + JSON.stringify(soldOutOrderData));
        // todo : Multi ProductRequestLine Case
        var resendType = event.getSource().get('v.label');
        var dialog = component.find('dialog');
        console.log('resendType :' +resendType);
        var param = {
            message : '결제요청이 완료되지 않았습니다. \n' +
                       '결제 종료를 하면 진행되었던 모든 결제처리 및 요청 건이 취소 됩니다. \n' +
                       '종료하시겠습니까?'
        };

        dialog.confirm(param, function(response) {
            console.log('response :' + response.result);
            if (response == null || response == undefined) {
                helper.showToast('error', '사용자 응답 오류');
                return;
            }
            if(response.result == true){
                return new Promise((resolve,reject)=>{
                    //23 12 04 hyungho.chun pr.point_amount 초기화 필요(포인트사용했다가 닫기버튼누를시)
                    var action = component.get('c.resetPointAmount');
                    var prIds =[];
                    if(orderData.length>0 && orderData[0].ParentId != undefined){
                        prIds.push(orderData[0].ParentId);
                    }
                    if(soldOutOrderData.length>0 && soldOutOrderData[0].ParentId != undefined){
                        prIds.push(soldOutOrderData[0].ParentId);
                    }
                    
                    action.setParams({
                        'prIds': prIds
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            console.log('return :: ',result['isSuccess']);
                            console.log('하하 포인트 초기화성공');
                            resolve(result);
                        }else{
                            var errors = response.getError();
                            console.log('return :: ',result['isSuccess']);
                            console.log('하하 포인트 실패');
                            reject(errors);
                            
                        }    
                    });
                    $A.enqueueAction(action);   
                }).then(()=>{
                    component.set('v.isEXOpen',false);
                    component.set('v.isLoadingForCommonSpinner', true);
                
                })
             
                // component.set('v.isEXOpen',false);
                // component.set('v.isLoadingForCommonSpinner', true);
            }
        }, resendType);
    },
        fnCancel: function (component, event, helper) {
            console.log('이벤트 !!!!!' + event.getParam('CancelStatus'));
            if(event.getParam('CancelStatus') == '취소'){
                component.destroy();
            }
        },
        fnComplete: function (component, event, helper) {
            component.set('v.isLoadingForCommonSpinner', true);
            if(event.getParam('complete') == true){
                component.destroy();
            }
        },

    //23 10 20 hyungho.chun 결제완료가능여부 이벤트 추가
    getReadyToGo: function(component,event,helper){
        component.set('v.isReadyToGo',event.getParam('isReadyToGo'));

        component.set('v.balance',0);
        
        var temp = component.get('v.isReadyToGo');
        var temp2 = component.get('v.balance');
        var temp3 = component.get('v.isLocked');
        var temp4 = component.get('v.paidAmount');
        var temp5 = component.get('v.totalAmount');

        
        console.log('isReadyToGo 탔음 :: ',temp);
        console.log('isReadyToGo 탔음 balance:: ',temp2);
        console.log('isReadyToGo 탔음 isLocked:: ',temp3);
        console.log('isReadyToGo 탔음 paidAmount:: ',temp4);
        console.log('isReadyToGo 탔음 totalAmount:: ',temp5);
        let offset =  new Date().getTimezoneOffset() * 60000;
        let dateOffset = new Date(new Date().getTime() - offset);
        console.log('속도측정 -------------------------------------------------- EX_Payment.cmp.getReadyToGo - start(카카오메세지생성직전):' + dateOffset.toISOString());
        //23.10.20 gw.lee
        //해당 Action이 없을 경우, evt 발송 후 수신부에서 발송되는 인자값이 전달이 안되어 해당 event 살림
        var apexAction = component.get('c.createExMessage');
        var params = {
            'Pass' : 'Y'
        }
        apexAction.setParams({
            'paramMap': params
        });
        apexAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('속도측정 -------------------------------------------------- EX_Payment.cmp.getReadyToGo - start(카카오메세지생성직후):' + dateOffset.toISOString());        
            } 
        });

        $A.enqueueAction(apexAction);
        
        var evt = $A.get("e.c:EX_PaymentExMessage_evt");
        evt.setParam("exMessage" , "true");

        evt.fire();
    },

    getExMessage: function(component,event,helper){
        if(event.getParam('emId') != null && event.getParam('emId') != undefined){
            component.set('v.emId', event.getParam('emId'));
            component.set('v.emType', event.getParam('emType'));
            component.set('v.receiverNumber', event.getParam('receiverNumber'));
        }
    }
});