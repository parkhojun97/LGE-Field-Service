/**
 * Created by pttc on 12/20/22.
 */

({
    /**
     * 부모에서 전달하는 이벤트 처리
     *
     * @param component component
     * @param target 이벤트 처리 대상 슬롯
     * @param type 이벤트 타입
     * @param payload payload
     */
    onObserved: function (component, target, type, payload) {
        console.log('--- point ', target, type, JSON.stringify(payload));
    },
    /**
     * 유효성 검사 성공
     * @param component component
     * @param purpose 검사 목적
     */
    onValidate: function (component, purpose) {
        if ('validation_request_auth_num' === purpose) {
            component.set('v.authBtnLabel', '재발송');
           //FNPaymentPoint.drive참조 - apex ctrl에 승인 번호 만들고, 알림 보내기
            var phoneNumber = component.get('v.phone');
            phoneNumber = phoneNumber.replaceAll('-', '');
            this.fetch(component, 'request_auth_num', {phone: phoneNumber});
//            this.fetch(component, 'request_auth_num', {phone: '01042879397'});
        }

//        else if ('validation_confirm_auth_num' === purpose) {
//            const kAuthNum = component.get('v.authNum');
//            this.fetch(component, 'confirm_auth_num', {authNum: kAuthNum});
//        }
    },

    /**
     * fetch() 실행 응답 처리
     *
     * @param component component
     * @param action 처리할 이름
     * @param body Object 데이터 - 이전에 요청한 데이타
     * @param isSuccess Boolean, 처리 결과
     * @param response 응답 데이터 - 새로이 리턴된 데이타
     */
    onFetch: function (component, action, body, isSuccess, response) {
        this.showSpinner(component, false);
        if (isSuccess) {
            if (action === 'retrieve_point') {
                if (response.message === 'Success') {
                    let kPoint = (response.point) || 0;
                    component.set('v.remainingPoint', parseInt(kPoint));

                    component.set('v.authAreaVisible', true);//한번 visible이 되면 invisible될 이유가 없다.
                    component.set('v.authBtnLabel', '인증번호발송');
                } else {
                    this.toast(response.message, 'f');
                }

            } else if (action === 'request_auth_num') {
                console.log('created auth num ==', response.authNum);
                //23 10 01 hyungho.chun 인증번호 운영환경 자동기입 제거
                //23 10 10 현업 테스트로 잠시 다시 열어둠
                // component.set('v.authNum',response.authNum);
                if(window.location.href.includes('sandbox')){ //24 02 28 hyungho.chun ps,fs에서만 자동으로 기입되게
                    component.set('v.authNum',response.authNum);
                }
                if(response.result == 's'){
                    component.set('v.correctAuthNum', response.authNum);
                    this.toast('인증번호가 발송되었습니다.', 's');
                }else{
                    this.toast('인증번호 발송이 실패하였습니다. 다시 시도해 주십시오.'+response.errorMsg, 'f');
                    return;
                }

                this.stopTicker(component);
                const kConstTotalSeconds = component.get('v.constTotalSeconds');
                component.set('v.tickerInfo.remainingSeconds', kConstTotalSeconds);
                component.set('v.tickerInfo.formattedRemainingTime', this.formatSeconds(kConstTotalSeconds));
                let kIntervalId = setInterval($A.getCallback(() => this.tick(component)), 1000);
                component.set('v.tickerInfo.intervalId', kIntervalId);
                component.set('v.isAuthNumRequested', true);
            }

//            else if (action === 'confirm_auth_num') {
//                let kAuthNum = component.get('v.authNum');
//                let kCorrectAuthNum = component.get('v.correctAuthNum');
//                if(kAuthNum == kCorrectAuthNum){
//                    this.stopTicker(component);
//                    component.set('v.isAuthConfirmed', true);
//                    this.toast('인증번호가 승인되었습니다.', 's');
//                }else{
//                    this.toast('인증번호가 맞지 않습니다.', 'f');
//                }
//
//            }

        }
    },

    /**
     * save() 실행 응답 처리
     *
     * @param component component
     * @param action 처리할 이름
     * @param body Object 데이터
     * @param isSuccess Boolean, 처리 결과
     * @param response 응답 데이터
     */
    onSave: function (component, action, body, isSuccess, response) {
//        console.log('-------------------------------------------------- EX_PaymentPoint.cmp.onSave - start');
        this.showSpinner(component, false);
        if (isSuccess) {
            if (action === 'save') {
                this.setStatus(component, 'completed');
                this.toast('성공적으로 포인트가 사용되었습니다.', 's');
                this.updatePointBalance(component, -1);
            }

        }
    },

    /**
     * cancel() 실행 응답 처리
     *
     * @param component component
     * @param action 처리할 이름
     * @param body Object 데이터
     * @param isSuccess Boolean, 처리 결과
     * @param response 응답 데이터
     */
    onCancel: function (component, action, body, isSuccess, response) {
        this.showSpinner(component, false);
        if (isSuccess) {
            this.setStatus(component, 'pending');
            this.toast('성공적으로 포인트가 취소되었습니다.', 's');
            if(component.get('v.authAreaVisible')) {
                this.updatePointBalance(component, +1);
            }
            component.set('v.authBtnLabel', '인증번호발송');
            component.set('v.authNum', '');
            component.set('v.isAuthConfirmed', false);
            component.set('v.isAuthNumRequested', false);
        }
        if (body.isReset && isSuccess) {
            this.delete(component);
        }
    },
    updatePointBalance: function (component, positiveNegative) {
        const amount = component.get('v.amount');
        const pointBalance = component.get('v.remainingPoint');
        if (null != pointBalance) {
            component.set('v.remainingPoint', parseInt(pointBalance) + (amount * positiveNegative));
        }
    },
    /**
     * delete() 실행 응답 처리
     * @param component component
     * @param action 처리할 이름
     * @param body Object 데이터
     * @param isSuccess Boolean, 처리 결과
     * @param response 응답 데이터
     */
    onDelete: function (component, action, body, isSuccess, response) {
        if (isSuccess) {
            this.resetValues(component);
        }
    },

    /**
     * 해당 슬롯의 결제 방식
     * @returns {string} card, credit, cash, point
     */
    getMethod: function () {
        return 'point';
    },
    /**
     * 수기 입력 가능 여부 반환
     * @param component component
     * @returns {boolean} true: 수기 입력 가능
     */
    canManual: function (component) {
        return false; // 포인트 수기 입력 불가
    },
    /**
     * AR_CONFIRM 에 저장할 데이터 반환
     * @param component component
     * @returns {object} {lorem:'ipsum'}
     */
    getData: function (component) {
        return {};
    },
    /**
     * 슬롯에 표시할 SR_PRE_PAYMENT_DETAIL__c
     * 다음 변수 포함: status[progressing, completed], isLocked
     * @param component component
     * @param data SR_PRE_PAYMENT_DETAIL__c
     */
    setData: function (component, data) {
        if (data.POINT_TRX_ID__c) {
            component.set('v.name', data.PAY_CUST_NAME__c);
            component.set('v.phone', this.formatPhoneNum(data.PAY_CUST_PHONE__c));
        }
        this.setStatus(component, !!data.POINT_TRX_ID__c ? 'completed' : 'pending');
    },
    /**
     * Contact 데이터, component.get('v.contact') 을 통해서도 접근 가능.
     * setData() 이전에 실행된다. contact 데이터로 초기값을 설정하는 용도.
     * @param component component
     * @param contact Contact
     */
    setContact: function (component, contact) {
        component.set('v.name', contact.Name);
        component.set('v.phone', this.formatPhoneNum(contact.MobilePhone));
    },
    /**
     * 초기화
     * @param component component
     * @param payload payload
     */
    reset: function (component, payload) {
        this.stopTicker(component);
        if (component.get('v.isCompleted')) {
            const amount = component.get('v.amount');
            const name = component.get('v.name');
            const phone = component.get('v.phone');
            this.cancel(component, 'cancel', {isReset: true, amount, name, phone});
        } else if (component.get('v.id')) {
            this.delete(component);
        } else {
            this.resetValues(component);
        }
    },
    resetValues: function (component) {
        component.set('v.authNum', '');
        component.set('v.authAreaVisible', false);
        // component.set('v.selectedAgreement', 'agree');
        component.set('v.isAgreed', true);
        component.set('v.remainingPoint', 0);
        component.set('v.isFullUse', false);
        component.set('v.isAuthConfirmed', false);
        component.set('v.isAuthNumRequested', false);
        component.set('v.tickerInfo', {formattedRemainingTime: '', remainingSeconds: 0});
        this.resetAmount(component);
    },


    tick: function (component) {

        let kRemainingSecs = component.get('v.tickerInfo.remainingSeconds');
        kRemainingSecs--;
        component.set('v.tickerInfo.formattedRemainingTime', this.formatSeconds(kRemainingSecs));
        component.set('v.tickerInfo.remainingSeconds', kRemainingSecs);

        if (kRemainingSecs <= 0) {
            this.stopTicker(component);
            component.set('v.authBtnLabel', '인증번호발송');
        }

    },


    stopTicker: function (component) {
        let kIntervalId = component.get('v.tickerInfo.intervalId');
        if (kIntervalId) {
            clearInterval(kIntervalId);
        }
//       component.set("v.tickerInfo.remainingSeconds", 180);
        component.set('v.tickerInfo.formattedRemainingTime', '00:00');
    },

    formatSeconds: function (aAlpha) {
        let m = Math.floor(aAlpha / 60);
        let s = Math.floor(aAlpha % 60);
        m = '0' + m;
        s = (s < 10) ? '0' + s : s;
        return m + ':' + s;
    },

    getProperFullAmount: function (component) {
        let kBalance = component.get('v.balance'); // 입력만으로 잔액이 갱신되지 않는다. + component.get('v.amount');
        let iAmount = component.get('v.amount');
//        let kBalance = component.get('v.totalAmount') - component.get('v.paidAmount');

//        if(kBalance + iAmount >= component.get('v.totalAmount')){
            kBalance = component.get('v.totalAmount');
//        }
//        else{
//        kBalance = kBalance + iAmount;
//        }
        let kRemainingPoint = component.get('v.remainingPoint');
        let kAmount;
        if (kRemainingPoint <= kBalance) {
            kAmount = kRemainingPoint;
        } else {
            kAmount = kBalance;
        }
        return kAmount;
    },

});