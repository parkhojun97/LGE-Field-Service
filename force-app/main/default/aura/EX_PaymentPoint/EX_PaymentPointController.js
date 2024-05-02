/**
 * Created by pttc on 12/20/22.
 */

//== Save
//save:포인트 사용+저장
//cancel:포인트 사용 취소

// ===  fetch
//retrieve_point:포인트조회
//request_auth_num :인증번호 요청
//confirm_auth_num :인증번호 승인

({
    onInit: function (component, event, helper) {
//        this.getProductAmount(component, event, helper);
        helper.dispatch(component, 'amount-disabled', {disabled: true});

    },

    handleRetrievePoint: function (component, event, helper) {
        //테스트 - 이승현/01031447479
        const kName = component.get('v.name');
        const kPhone = component.get('v.phone');

        if (!kName) {
            return helper.toast('고객명을 입력하세요.');
        }
        if (!helper.isPhoneNum(kPhone) || !helper.isMobilePhone(kPhone)) {
            return helper.toast('올바른 전화번호를 입력하세요.');
        }
        helper.fetch(component, 'retrieve_point', {name: kName, phone: kPhone});
    },

    //인증번호 발송 클릭
    handleRequestAuthNum: function (component, event, helper) {
        let kRemainingPoint = component.get('v.remainingPoint');
        if (kRemainingPoint <= 0) {
            helper.toast('포인트 잔액이 0원입니다.', 'w');
        } else {
            component.set('v.authNum', '');
            helper.validate(component, 'validation_request_auth_num');
        }

    },

    handleFullUseChange: function (component, event, helper) {
        const kChecked = component.get('v.isFullUse');
        if (kChecked) {
            let kAmount = helper.getProperFullAmount(component);
            component.set('v.amount', kAmount);
            helper.dispatch(component, 'amount', {amount: kAmount});
        } else {
            component.set('v.amount', 0);
            helper.dispatch(component, 'amount', {amount: 0});
        }
    },

    handleAmountChange: function (component, event, helper) {
        let kAmount = component.get('v.amount');
        let paidAmount = helper.getProperFullAmount(component);

        if(kAmount != paidAmount){
            component.set('v.isFullUse', false);
        }else{
            component.set('v.isFullUse', true);
        }

        if(kAmount == null || kAmount == ''){
            kAmount =0;
        }
        if (kAmount < 0) {
            kAmount = -kAmount;
            component.set('v.amount', kAmount);
        }
        helper.dispatch(component, 'amount', {amount: kAmount});
    },

    handleKeyDown: function (component, event, helper) {
        helper.restrictCharacter(event);
    },

    handleConfirmAuthNum: function (component, event, helper) {
		let offset =  new Date().getTimezoneOffset() * 60000;
		let dateOffset = new Date(new Date().getTime() - offset);
		console.log('속도측정 -------------------------------------------------- EX_PaymentPoint.cmp.handleConfirmAuthNum - start:' + dateOffset.toISOString());
		//

        let kRemainingSecs = component.get('v.tickerInfo.remainingSeconds');
        let kInput = component.find('authNumInput');
        if (kRemainingSecs <= 0) {
            kInput.setCustomValidity('인증번호를 다시 발송하세요.');
            helper.toast('인증번호를 다시 발송하세요.');
        } else {
            let kAuthNum = component.get('v.authNum');
            if (kAuthNum.length !== 6) {
                kInput.setCustomValidity('인증번호는 6자리입니다.');
                helper.toast('인증번호는 6자리입니다.');
            } else {
                kInput.setCustomValidity('');
                //helper.validate(component, 'validation_confirm_auth_num');
                let kAuthNum = component.get('v.authNum');
                let kCorrectAuthNum = component.get('v.correctAuthNum');
                if(kAuthNum === kCorrectAuthNum){
                    helper.stopTicker(component);
                    component.set('v.isAuthConfirmed', true);
                    helper.toast('인증번호가 승인되었습니다.', 's');
                    let amount = component.get('v.amount');
                    const name = component.get('v.name');
                    const phone = component.get('v.phone');
                    //23 10 20 hyungho.chun mbsid보내기용
                    var mbsCustId = component.get('v.mbsCustId');
                    console.log('쏘기직전 mbsCustId :: ',mbsCustId);
                    component.set('v.balance',amount);
                    var evt = $A.get("e.c:EX_PaymentBalance_evt");
                    evt.setParams({
                        balance: component.get('v.balance')
                    });
                    evt.fire();

                    helper.save(component, 'save', {amount, name, phone, mbsCustId});

                }else{
                    helper.toast('인증번호가 맞지 않습니다.', 'f');
                }
            }
        }

        kInput.reportValidity();
    },

    handleCancel: function (component, event, helper) {
        let kMessage = '포인트를 취소하시겠습니까?';
        helper.confirm('확인', kMessage).then(confirmed => {
            if (confirmed) {
                let kAmount = component.get('v.amount');
                const kName = component.get('v.name');
                const kPhone = component.get('v.phone');
                helper.cancel(component, 'cancel', {amount: kAmount, name: kName, phone: kPhone});
            }
        });
    },

    handlePhoneBlur: function (component, event, helper) {
        let kTarget = event.getSource();
        kTarget.set('v.value', helper.formatPhoneNum(kTarget.get('v.value')));
    },

    //gw.lee 23.09.25
    //가상계좌 발행 시, 포인트 조회 잠금
    handleLocked: function (component, event, helper) {
        var pointLocked = event.getParam('isLocked');
        if (component.get('v.isLocked') == false ) {
            component.set('v.isLocked', pointLocked);
        }
    },

    //23 10 20 hyungho.chun mbsCustId이벤트 수신 처리
    getMbsCustId: function (component,event,helper){
        var mbsCustId = event.getParam('mbsCustId');
        component.set('v.mbsCustId',mbsCustId);
        console.log( 'mbsCustId 받았다! :: ', mbsCustId);
    },

    handleLocked: function (component, event, helper) {
        component.set('v.isLocked', true);
    }
});