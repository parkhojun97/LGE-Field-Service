/**
 * Created by A78916 on 2022-12-21.
 */

({
    onInit: function (component, event, helper) {
        helper.initValues(component);

        helper.fetchGlobalPickListValues(component, 'smartro_virtual_bank')
            .then(data => {
                if (data) {
                    component.set('v.virtualBankOptions', data);
                    const bank = data.find(v => v.value === '020');
                    component.set('v.cmBank', bank);
                }
            });
    },
    handleBlurPhone: function (component, event, helper) {
        const value = event.getSource().get('v.value');
        event.getSource().set('v.value', helper.formatPhoneNum(value));
    },
    handleChangePayment: function (component, event, helper) {
        const value = event.getParam('value');
        var selectedOptionValue = event.getSource().get("v.value");
        var label = ''
        var options = component.get("v.paymentOptions");

        if ('PG_VBANK' === value ) {
            component.set('v.isCashEmp',false);
            component.find('inner').reset();
            component.set('v.cashParam.proofNo', component.get('v.contact').MobilePhone);
        }
        if('PG_VBANK1' === value){
            //현금대리입금
            component.set('v.isCashEmp',true);
            component.find('inner').reset();
            component.set('v.cashParam.proofNo', component.get('v.contact').MobilePhone);
        }
        if ('PG_URL' === value) {
            component.set('v.isCashEmp',null);
            //23 10 24 hyungho.chun 메세지 fetch 시점을 결제 URL 발급 버튼 누를때로 수정
            // helper.fetch(component, 'kakao', {type: 'pgUrl'});
        }
        helper.dispatch(component, 'manual', {});
    },
    handleSend: function (component, event, helper) {
        const param = component.get('v.param');
        const emp = component.get('v.objEmp');
        const contact = component.get('v.objCont');
        const type = helper.getTypeForMessage(param.payment);
        if(component.get('v.isCashEmp')){
            helper.fetch(component, 'kakao-send', {type, receiverMobile: emp.Phone});
        }
        else if(component.get('v.isCashEmp') == false){
            helper.fetch(component, 'kakao-send', {type, receiverMobile: contact.MobilePhone});
        }
        else{
            helper.fetch(component, 'kakao-send', {type, receiverMobile: param.receiverMobile});
        }
    },
    handleCreateCard: function (component, event, helper) {
         //gw.lee 23.09.25
        //가상계좌 발행 시, 포인트 조회 잠금
        var evt = $A.get("e.c:EX_PointDisabledEvent_evt");
        //var evt = component.getEvent("EX_PointDisabledEvent_evt");

        component.set('v.isLoadingForCommonSpinner', true);//24 01 11 hyungho.chun 결제URL누르자마자 스피너 작동

        new Promise((resolve,reject) =>{
            helper.checkPhoneVal(component, resolve, reject);
        }).then((data)=>{
            console.log('check ?? ' , data);
            if (data != null) {
                component.set('v.isLoadingForCommonSpinner', false);
                return helper.toast('주문자 전화번호를 확인해주세요.');
            } else {

                if((component.get('v.totalAmount') != (component.get('v.amount') + component.get('v.balanceAmount')))){
                    component.set('v.isLoadingForCommonSpinner', false); //24 01 12 hyungho.chun 
                    return helper.toast('포인트 결제 후 가능합니다.');
                }
                if (helper.verifyMinAmount(component)) {
                    //23 10 24 hyungho.chun 메세지 fetch 시점을 결제 URL 발급 버튼 누를때로 수정
                    helper.fetch(component, 'kakao', {type: 'pgUrl'});
                    
                    helper.persist(component, 'card');

                    evt.setParams({"isLocked" : true});
                    evt.fire();
                }
            }
        });


        

    },
    handleCancelCard: function (component, event, helper) {
        helper.setStatus(component, 'progressing');
        helper.clear(component, 'card');
    },
    handleCreateBank: function (component, event, helper) {
        //gw.lee 23.09.25
        //가상계좌 발행 시, 포인트 조회 잠금
        var evt = $A.get("e.c:EX_PointDisabledEvent_evt");
        //var evt = component.getEvent("EX_PointDisabledEvent_evt");
       
        new Promise((resolve,reject) =>{
            component.set('v.isProgressing', true);
            helper.checkPhoneVal(component, resolve, reject);
        }).then((data)=>{
            if (data != null) {
                component.set('v.isProgressing', false);
                return helper.toast('주문자 전화번호를 확인해주세요.');
            } else {
                const param = component.get('v.param');
                const emp = component.get('v.objEmp');

                //23.12.26 gw.lee
                //Validation 추가
                if(emp.Phone == param.receiverMobile && component.get('v.isCashEmp') == true){
                    component.set('v.isProgressing', false);
                    return helper.toast('주문하신 고객 전화번호로 해당 알림톡을 발송할 수 없습니다.');
                } else if (emp.Phone == undefined && param.payment == 'PG_VBANK1') {
                    component.set('v.isProgressing', false);
                    return helper.toast('수신자 정보를 입력해주세요.');
                } else if (param.bank == '') {
                    component.set('v.isProgressing', false);
                    return helper.toast('은행을 선택해주세요.');
                }
                if((component.get('v.totalAmount') != (component.get('v.amount') + component.get('v.balanceAmount')))){
                    component.set('v.isProgressing', false);
                    return helper.toast('포인트 결제 후 가능합니다.');
                }
                var virtualBankAccountNo = component.get('v.param.virtualBankAccountNo');
        
                if (helper.verifyMinAmount(component)) {
                    evt.setParams({"isLocked" : true});
                    evt.fire();

                    // component.set('v.isLocked', true); //23 12 27 hyungho.chun 발행실패시 풀어야함
                    // let promise = new Promise((resolve,reject)=>{
                    //     helper.persist(component, 'bank');
                    //     console.log('오잉1');
                    //     resolve('Success'); 
                    // });
                    // promise.then((value)=>{
                    //     if (value == 'Success') {
                    //         console.log('오잉2');
                    //         console.log('virtualBankAccountNo2 :: ',virtualBankAccountNo);
                    //         console.log('virtualBankAccountNo2 :: ',JSON.stringify(virtualBankAccountNo));
                    //     }
                    // })
                    
                    helper.persist(component, 'bank');
                }
            }
        });

        // Promise.all(promise).then(function(results){
        //     console.log('virtualBankAccountNo3 :: ',JSON.stringify(virtualBankAccountNo));
        // });


        
        console.log('virtualBankAccountNo1 :: ',virtualBankAccountNo);
        console.log('virtualBankAccountNo1 :: ',JSON.stringify(virtualBankAccountNo));

    },
    handleCancelBank: function (component, event, helper) {
        if (component.get('v.isProofCompleted') && 'B' === component.get('v.cashParam.proofType')) {
            return helper.toast('현금영수증을 먼저 취소해 주세요.');
        }
        helper.setStatus(component, 'progressing');
        helper.fetch(component, 'bank', {});
    },
    handleProofOk: function (component, event, helper) {
        if (helper.verifyMinAmount(component)) {
            // 가상계좌 먼저 발급해야한다.
            const param = component.get('v.param');
            if ('PG_VBANK' === param.payment || 'PG_VBANK1' === param.payment) {
                if (false === component.get('v.isIssuedBankAccountNo')) {
                    return helper.toast('우선 가상계좌를 발급하세요.');
                }
            }
            helper.persist(component, 'proof');

        }
    },
    handleProofCancel: function (component, event, helper) {
        helper.confirm('확인', '취소하시겠습니까?')
            .then(() => helper.clear(component, 'proof'));
    },
    handleOkRefund: function (component, event, helper) {
        if (helper.require(component, ['refund-bank', 'refund-name', 'refund-account'])) {
            helper.setStatus(component, 'progressing');
            const refund = component.get('v.refundParam');
            refund.payment = component.get('v.param').payment;
            helper.cancel(component, 'bank-refund', refund);
        }
    },
    handleCancelRefund: function (component, event, helper) {
        helper.applyStatus(component);
        component.set('v.isShowRefund', false);
    },
    onRequestInner: function (component, event, helper) {
        const type = event.getParam('type');
        if ('file' === type) {
            helper.fetch(component, 'file', {});
        } else if ('file-delete' === type) {
            helper.fetch(component, 'file-delete', event.getParam('detail'));
        }
    },
    getContactInfo: function(component, event, helper) {

        console.log('event init!!!');
        component.set('v.objCont',event.getParam('objCont'));
        component.set('v.objEmp', event.getParam('objEmp'));
        component.set('v.isManagement',event.getParam('isManagement'));
        console.log(event.getParam('isManagement'));
        const emp = component.get('v.objEmp');

        const cash = component.get('v.cashParam');
        const cont = component.get('v.objCont');
        console.log('eeeeee '+ emp.Phone);
        if(emp.Phone == null || emp.Phone == undefined){
            console.log('eeeeee '+ component.get('v.PhoneNumber'));
            emp.Phone = component.get('v.PhoneNumber');
        }
        if(event.getParam('isManagement')){
            component.set('v.param.receiverName', cont.Name);
            component.set('v.param.receiverMobile', cont.MobilePhone);
            component.set('v.param.receiverMobile2', cont.MobilePhone);
        }
        component.set('v.objEmp',emp);

        component.set('v.serviceResource',event.getParam('ServiceResource'));
        component.set('v.prId',event.getParam('prId'));

        console.log(component.get('v.serviceResource') +'!!!!!');
    },
    getBalance: function(component, event, helper) {
        component.set('v.balanceAmount',event.getParam('balance'));
        console.log('aaa :'+component.get('v.balanceAmount'));
    },

    //23 10 19 hyungho/chun
    //cashInner에서 현금영수증용 데이터 이벤트 핸들링
    getReceiptInfo: function(component, event, helper) {

        
        console.log('getReceiptInfo event :: ',event);
        console.log('getReceiptInfo event :: ',JSON.stringify(event));

        component.set('v.param.receiptIdentity',event.getParam('cashReceiptMobile'));
        component.set('v.param.proofTypeTemp',event.getParam('proofType'));
        component.set('v.param.cashReceiptType',event.getParam('proofCashType'));
        component.set('v.param.proofCashNoTypeTemp',event.getParam('proofCashNoType'));

        var param = component.get('v.param');
        console.log('param :: ',param);
        
    },

    //23 10 20 hyungho.chun mbsCustId이벤트 수신 처리
    getMbsCustId: function (component,event,helper){
        var mbsCustId = event.getParam('mbsCustId');
        component.set('v.mbsCustId',mbsCustId);
        console.log( 'mbsCustId 받았다! :: ', mbsCustId);
    },
    
    createExMessageObj: function (component) {
            
        var bankMap = component.get('v.virtualBankOptions');
        var param = component.get('v.param');
        //23 11 29 hyungho.chun 결제기한날짜가 당일로되어있어서 하루 +1
        console.log('param :: ',param);
        console.log('param :: ', JSON.stringify(param));
        const tomorrow = moment().add(1, 'days');
        console.log('tmr :: ' + tomorrow.format('YYYY-MM-DD'));
        param.depositDueDate = tomorrow.format('YYYY-MM-DD');
        var objCont = component.get('v.objCont');
        var prId = component.get('v.prId');

        if (param.payment == 'PG_VBANK1' || param.payment == 'PG_VBANK') {

            bankMap.forEach(item => {
                if (item.value == param.bank) {
                    param.bank = item.label;

                    return false;
                }
            });

            var apexAction = component.get('c.createExMessage');
            var params = {
                'param' : JSON.parse(JSON.stringify(param)),
                'prId' : prId,
                'Pass' : 'N'
            };
            apexAction.setParams({
                'paramMap': params
            });
            apexAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();

                    

                    if (result != 'Pass') {
                        var evt = $A.get("e.c:EX_ExMessageSend_evt");

                        var paymentType = param.payment == 'PG_VBANK1' ? '현금' : '가상계좌';

                        var objEmp = component.get('v.objEmp');
                        var receiverNumber = param.payment == 'PG_VBANK1' ? objEmp.Phone : objCont.MobilePhone;


                        evt.setParams({"emId" : result});
                        evt.setParams({"emType" : paymentType});
                        evt.setParams({"receiverNumber" : receiverNumber});
                        evt.fire();
                    }
                } 
            });

            $A.enqueueAction(apexAction);
        }
    }
    

});