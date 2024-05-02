/**
     * Created by A78916 on 2022-12-21.
     */

    ({
        persist: function (component, purpose) {
            const param = component.get('v.param');
            console.log('param ::: persis시작 ',param);
            console.log('param ::: persis시작 ',JSON.stringify(param));
            const emp = component.get('v.objEmp')
            const contact = component.get('v.objCont');
            if ('card' === purpose) {
                // 카드 URL 생성,
                // noinspection JSBitwiseOperatorUsage
                if (this.validateReceiver(component, 'name', 'phone')
                    & this.validateDueDate(component, param.depositDueDate)) {
                    param.amount = component.get('v.amount');
                    //23 10 20 hyungho.chun 포인트 조회 때 받은 mbsCustId 값 서버단 송신
                    var mbsCustId = component.get('v.mbsCustId');
                    console.log('서버 mbsCustId 송신 직전 :: mbsCustId :: ',mbsCustId);                    
                    var newParam = Object.assign({}, param);
                    newParam.mbsCustId = mbsCustId;
                    this.setStatus(component, 'progressing');
                    //23 10 20 hyungho.chun mbsCustId 추가 요소 때문에 param-> newParam
                    // this.save(component, 'card', param);
                    this.save(component, 'card', newParam);
                }
            } else if ('bank' === purpose) {
                // 가상 계좌 발급
                // noinspection JSBitwiseOperatorUsage
                if(component.get('v.isCashEmp')){
                    param.payment = 'PG_VBANK1';
                }
                this.setBankPaymentType(component);

                if (this.validateBank(component)
                    & this.validateReceiver(component, 'name', 'phone')
                    & this.validateDueDate(component, param.depositDueDate)) { // 입금 예정일 확인
                    param.amount = component.get('v.amount');
                    this.setStatus(component, 'progressing');

                    console.log('param ::: 가상계좌발행직전 ',param);
                    console.log('param ::: 가상계좌발행직전 ',JSON.stringify(param));
                    var newParam = Object.assign({}, param);
                    newParam.payment = 'PG_VBANK';
                    newParam.receiverMobile = component.get('v.isCashEmp') == true ? emp.Phone : contact.MobilePhone;
                    newParam.receiverName = component.get('v.isCashEmp') == true ? emp.Name : contact.Name;
                    //23 10 19 hyungho.chun 가상계좌 현금영수증 임시 파람
                    newParam.receiptIdentity = param.receiptIdentity;
                    // newParam.proofTypeTemp = param.prooreceiptIdentityfTypeTemp;
                    newParam.cashReceiptType = param.cashReceiptType;
                    //23 10 20 hyungho.chun 포인트 조회 때 받은 mbsCustId 값 서버단 송신
                    var mbsCustId = component.get('v.mbsCustId');
                    console.log('서버 mbsCustId 송신 직전 :: mbsCustId :: ',mbsCustId);
                    newParam.mbsCustId = mbsCustId;
                    // newParam.proofCashNoTypeTemp = param.proofCashNoTypeTemp;
                    this.save(component, 'bank', newParam);
                }

            } else if ('proof' === purpose) {
                // 현금 증빙 발급
                if (this.validateReceiver(component, 'name', 'phone')) {
                    const inner = component.find('inner');
                    //현금입금대상시 수신자가 아니라 사용자의 정보를 넘김
                    if(component.get('v.isCashEmp')){
                        inner.validate(() => {
                            const cashParam = inner.getCashData(); // 수기 spinner저장하는 값을 그대로 이용
                            cashParam.amount = component.get('v.amount');
                            cashParam.payment = 'PG_VBANK';
                            cashParam.receiverName = emp.Name;
                            cashParam.receiverMobile = emp.Phone;
                            console.log('newParam : ' + JSON.stringify(cashParam));
                            this.setStatus(component, 'progressing');
                            this.save(component, 'proof', cashParam);
                        });
                    }
                    else{
                        inner.validate(() => {
                            const cashParam = inner.getCashData(); // 수기 저장하는 값을 그대로 이용
                            cashParam.payment = param.payment;
                            cashParam.amount = component.get('v.amount');
                            cashParam.receiverMobile = contact.MobilePhone;
                            console.log('newParam : ' + JSON.stringify(cashParam));
                            this.setStatus(component, 'progressing');
                            this.save(component, 'proof', cashParam);
                        });
                    }
                }
            } else if ('store' === purpose) {
                // 알림톡 수신자 검증, 센터수금계좌는 검사 필수, 나머지는 이미 저장된 상태.
                // noinspection JSBitwiseOperatorUsage
                if (this.validateDueDate(component, param.depositDueDate)  // 입금 예정일 확인
                    & this.validateReceiver(component, 'name', 'phone')) {
                    var newParam = Object.assign({}, param);
                    if(component.get('v.isCashEmp')){
                        newParam.payment = 'PG_VBANK';
                    }
                    this.setStatus(component, 'progressing');
                    this.save(component, 'store', newParam);

                }
            }
            component.set('v.isLoadingForCommonSpinner', false);            
        },
        validateReceiver: function (component, name, phone) {
            const strip = (c) => Array.isArray(c) ? c[0] : c;
            const report = (c, v) => {
                c.setCustomValidity(v);
                c.reportValidity();
            };
            const nameComponent = strip(component.find(name));
            if (nameComponent) {
                const value = nameComponent.get('v.value');
                if (!value) {
                    report(nameComponent, '_');
                    this.toast('고객명을 입력하세요.');
                    return false;
                } else {
                    report(nameComponent, '');
                }
            }
            const phoneComponent = strip(component.find(phone));
            if (phoneComponent) {
                const value = phoneComponent.get('v.value');
                if (!this.isPhoneNum(value) || !this.isMobilePhone(value)) {
                    report(phoneComponent, '_');
                    this.toast('올바른 전화번호를 입력하세요.');
                    return false;
                } else {
                    report(phoneComponent, '');
                }
            }
            return true;
        },
        validateDueDate: function (component, dueDate) {
            if (!this.require(component, ['dueDate'])) {
                if (!dueDate) {
                    this.toast('입금예정일을 입력하세요.');
                } else {
                    this.toast('입금예정일은 오늘 이후의 날짜를 입력하세요.');
                }
                return false;
            }
            return true;
        },
        validateBank: function (component) {
            if (!this.require(component, ['bank'])) {
                this.toast('은행을 선택하세요.');
                return false;
            }
            return true;
        },
        clear: function (component, purpose) {
            const param = component.get('v.param');
            this.clearWithParam(component, purpose, param);
        },
        clearWithParam: function (component, purpose, param) {
            if ('card' === purpose) {
                // 카드 URL
                this.setStatus(component, 'progressing');
                this.cancel(component, 'card', param);
            } else if ('bank' === purpose) {
                // 가상 계좌
                this.setStatus(component, 'progressing');
                this.cancel(component, 'bank', param);
            } else if ('proof' === purpose) {
                // 현금 증빙
                const cashParam = {}; // component.find('inner').getCashData(); // 수기 저장하는 값을 그대로 이용
                if(component.get('v.isCashEmp'))
                    cashParam.payment = 'PG_VBANK';
                else
                    cashParam.payment = param.payment;
                this.setStatus(component, 'progressing');
                this.cancel(component, 'proof', cashParam);
            } else {
                // ok
                this.setStatus(component, 'progressing');
                this.cancel(component, 'store', param);
            }
        },
        /**
         * 부모에서 전달하는 이벤트 처리
         *
         * @param component component
         * @param target 이벤트 처리 대상 슬롯
         * @param type 이벤트 타입
         * @param payload payload
         */
        onObserved: function (component, target, type, payload) {
        },
        /**
         * 유효성 검사 성공
         * @param component component
         * @param purpose 검사 목적
         */
        onValidate: function (component, purpose) {
        },
        /**
         * message() 실행 응답 처리
         * @param component component
         * @param action 처리할 이름
         * @param body Object 데이터
         * @param isSuccess Boolean, 처리 결과
         * @param response 응답 데이터
         */
        onMessage: function (component, action, body, isSuccess, response) {
            var isCenterUser = helper.getUserProfile(component);
           
            if (!isCenterUser) {
                if ('print' === action) {
                    if (false === isSuccess) {
                        this.toast('현금영수증을 출력하지 못했습니다.');
                    }
                }
            }
        },
        /**
         * fetch() 실행 응답 처리
         * @param component component
         * @param action 처리할 이름
         * @param body Object 데이터
         * @param isSuccess Boolean, 처리 결과
         * @param response 응답 데이터
         */
        onFetch: function (component, action, body, isSuccess, response) {
            if ('bank' === action) {
                if (isSuccess) {
                    if (response.PAYMENT_YN__c) {    // 환불창 표시
                        this.setStatus(component, 'progressing');
                        this.fetchGlobalPickListValues(component, 'smartro_refund_bank')
                            .then(data => {
                                component.set('v.refundBankOptions', data);
                                component.set('v.isShowRefund', true);
                            })
                            .finally(() => this.applyStatus(component));
                    } else {
                        this.clear(component, 'bank');
                    }
                } else {
                    this.applyStatus(component);
                }
            } else if ('file' === action) {
                if (isSuccess) {
                    component.set('v.containerId', response.containerId);
                    component.set('v.fileId', response.documentId);
                }
            } else if ('file-delete' === action) {
                if (isSuccess) {
                    component.set('v.fileId', '');

                    if (isSuccess && component.get('v.isReset')) { // reset 실행했음
                        this.cancelAll(component);
                    }
                }
            } else if ('kakao-send' === action) {
                if (isSuccess) {
                    this.toast('알림톡을 발송했습니다.', 's');
                }

            } else if ('kakao' === action) {
                if (isSuccess) {
                    const type = body.type;
                    if ('pgUrl' === type) {
                        component.set('v.kakao.pgUrl', response);
                    } else if ('pgVBank' === type) {
                        component.set('v.kakao.pgVBank', response);
                    } else if ('cmVBank' === type) {
                        component.set('v.kakao.cmVBank', response);
                    }
                }
//                var balance = component.get('v.balance');
//
//                if(balance == 0 && ((component.get('v.paidAmount') == component.get('v.totalAmount')))){
//                    var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
//                        evt.setParams({"complete" : true});
//                        evt.fire();
//                }
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
            const param = component.get('v.param');
            const emp = component.get('v.objEmp');

            if ('card' === action) { // 카드 URL 취소 결과
                if (isSuccess) {
                    param.cardRequestStatus = '요청취소';
                    component.set('v.isIssuedCardUrl', false);
                    component.set('v.isKakaoSent', false);
                    this.fetch(component, 'kakao-send', {type: 'pgUrl-CANCEL', receiverMobile: param.receiverMobile});

                    component.set('v.isApproved', false);
                }
                this.applyStatus(component);
            } else if ('bank' === action || 'bank-refund' === action) {
                if (isSuccess) {
                    param.virtualBankAccountNo = null;
                    component.set('v.isIssuedBankAccountNo', false);
                    component.set('v.isKakaoSent', false);
                    this.fetch(component, 'kakao-send', {type: 'pgVBank-CANCEL', receiverMobile: component.get('v.isCashEmp') == false ? component.get('v.objCont').MobilePhone : emp.Phone});

                    ('bank-refund' === action) && component.set('v.isShowRefund', false);
                }
                this.applyStatus(component);
            } else if ('proof' === action) {
                if (isSuccess) {
                    // 사업자등록증 파일은 제거된다.
                    component.set('v.fileId', '');
                    component.set('v.isProofCompleted', false);

                    component.set('v.isApproved', false);

                    if ('CM_VBANK' === param.payment) { // 센터수금계좌는 증빙 취소하면 발송 안함 상태
                        component.set('v.isKakaoSent', false);
                    }

                    if ('B' === component.get('v.cashParam.proofType')) {
                        this.message(component, 'print', {
                            title: '현금영수증취소',
                            amount: component.get('v.amount'),
                            authDate: component.get('v.authDate'),
                            authNum: response.CancelNum,
                            certifyKey:component.get('v.certifyKey'),
                            isCancel: true,
                        });
                    }
                }
                this.applyStatus(component);
            } else if ('store' === action) {
                if (isSuccess) {
                    this.setStatus(component, 'holding');
                }
            }
            component.set('v.param', param);

            if (isSuccess && component.get('v.isReset')) { // reset 실행했음
                this.cancelAll(component);
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
         * save() 실행 응답 처리
         *
         * @param component component
         * @param action 처리할 이름
         * @param body Object 데이터
         * @param isSuccess Boolean, 처리 결과
         * @param response 응답 데이터
         */
        onSave: function (component, action, body, isSuccess, response) {
            // 저장 결과 확인
            const param = component.get('v.param');
            const emp = component.get('v.objEmp');
            if ('card' === action) {  // 카드 URL 생성 결과
                component.set('v.isIssuedCardUrl', isSuccess);
                this.applyStatus(component);

                if (isSuccess) {
                    param.cardRequestStatus = '요청완료';
                    this.persist(component, 'store');
                }

            } else if ('bank' === action) {
                if (isSuccess) {
                    param.virtualBankAccountNo = response.VbankNum;
                    this.fetch(component, 'kakao', {type: 'pgVBank'});
                }
                component.set('v.isIssuedBankAccountNo', isSuccess);
                this.applyStatus(component);
            } else if ('proof' === action) {
                component.set('v.isProofCompleted', isSuccess);
                this.applyStatus(component);
                if ('B' === component.get('v.cashParam.proofType')) {
                    // 현금영수증 발급하면 사업자등록증 파일은 제거된다.
                    component.set('v.fileId', '');
                    console.log('response : ' +response);
                    const date = moment('20' + response.AuthDate, 'YYYYMMDDHHmmss').format('YYYY-MM-DD');
                    component.set('v.authDate', date);
                    component.set('v.authNum', response.AuthCode);
                    component.set('v.certifyKey', response.ReceiptIdentity);

                    this.message(component, 'print', {
                        title: '현금영수증발급',
                        amount: component.get('v.amount'),
                        authDate: date,
                        authNum: response.AuthCode,
                        certifyKey:component.get('v.certifyKey'),
                    });
                }
                if (isSuccess) {
                    this.persist(component, 'store');
                }
            } else if ('store' === action) {
                if (isSuccess) {
                    const type = this.getTypeForMessage(param.payment);
                    var mobile = param.receiverMobile;
                    if(component.get('v.isCashEmp') == true){
                        mobile =emp.Phone;
                    }
                    else if(component.get('v.isCashEmp') == false){
                        mobile = component.get('v.objCont').MobilePhone;
                    }
                    this.fetch(component, 'kakao-send', {type, receiverMobile: mobile});
                    component.set('v.isKakaoSent', true); // 일단 발송 표시, 재발송 가능
                    component.set('v.isApproved', true); // 승인 완료
                    this.setStatus(component, 'completed');
                } else {
                    this.applyStatus(component);
                }
                if(component.get('v.isCashEmp'))
                    param.payment = 'PG_VBANK1';
            }
            component.set('v.param', param);
        },
        applyStatus: function (component) {
            if (!component.get('v.amount') || 0 >= component.get('v.amount')) {
                this.setStatus(component, 'disabled');
            } else if (component.get('v.isIssuedCardUrl') || component.get('v.isProofCompleted')) {
                this.setStatus(component, 'completed');
            } else if (component.get('v.isIssuedBankAccountNo')) {
                this.setStatus(component, 'holding');
            } else {
                this.setStatus(component, 'pending');
            }
        },
        getTypeForMessage: function (method) {
            let type;
            if ('PG_URL' === method) {
                type = 'pgUrl';
            } else if ('PG_VBANK' === method || 'PG_VBANK1' === method) {
                type = 'pgVBank';
            } else if ('CM_VBANK' === method) {
                type = 'cmVBank';
            }
            return type;
        },
        verifyMinAmount: function (component) {
            const param = component.get('v.param');
            const amount = component.get('v.amount');
            let max = 0;
            let method = ''
            if ('PG_URL' === param.payment) {
                max = 0;
                method = '카드URL';
            } else if ('PG_VBANK' === param.payment || 'PG_VBANK1' === param.payment) {
                max = 0;
                method = '카드계좌';
            }
            if (amount < max) {
                this.toast(`${max}원 이상부터 ${method} 결제가 가능합니다.`);
                component.set('v.isLoadingForCommonSpinner', false);
                return false;
            }
            return true;
        },
        /**
         * 해당 슬롯의 결제 방식
         * @returns {string} card, credit, cash, point
         */
        getMethod: function () {
            return 'credit';
        },
        /**
         * 수기 입력 가능 여부 반환
         * @param component component
         * @returns {boolean} true: 수기 입력 가능
         */
        canManual: function (component) {
            return false; // 센터수금계좌라도 현금영수증 발급해야함
        },
        /**
         * AR_CONFIRM 에 저장할 데이터 반환
         * @param component component
         * @returns {object} {lorem:'ipsum'}
         */
        getData: function (component) {
            /*
            입력유형	INPUT_TYPE__c: 수기입력 Y
            미수금 상세유형 UPAD_DETAIL_TYPE__c: PG_URL : 카드URL, PG_VBANK : 가상계좌, CM_VBANK : 수금형계좌
            입금예정일 DEPOSIT_DUE_DT__c

            가상계좌 => 현금영수증 정보 포함

             => 값 설정하지 않음, 서버에서 처리
            가상계좌 번호 VIRTUAL_ACCT_NUMBER__c
            URL결제 거래번호 TID__c

            증빙유형 INVOICE_ISSUE_TYPE__c: A:세금계산서, B:현금영수증, C:미발행, D:카드
            결제유형 DEPOSIT_TYPE__c A:현금, B:카드, C:쿠폰, D:포인트, E:미수

             */
            const param = component.get('v.param');
            let data = {};
            data.UPAD_DETAIL_TYPE__c = param.payment;

            if ('PG_URL' === param.payment) {
            } else if ('PG_VBANK' === param.payment) {
                data = component.find('inner').getCashData();
            } else if ('PG_VBANK1' === param.payment) {
                data = component.find('inner').getCashData();
                data.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
            }
            data.DEPOSIT_DUE_DT__c = param.depositDueDate;
            return data;
        },
        /**
         * '재인쇄' 요청 시 필요 데이터 반환
         * @param component component
         * @return '{}' or null
         */
        getPrintData: function (component) {
            const date = component.get('v.authDate');
            const code = component.get('v.authNum');
            return date && code ? {
                title: '현금영수증발급',
                amount: component.get('v.amount'),
                authDate: date,
                authNum: code,
                certifyKey:component.get('v.certifyKey'),
            } : null;
        },
        /**
         * 슬롯에 표시할 SR_PRE_PAYMENT_DETAIL__c
         * 다음 변수 포함: status[progressing, completed], isLocked
         * @param component component
         * @param data SR_PRE_PAYMENT_DETAIL__c
         */
        setData: function (component, data) {
            //23 10 25 hyungho.chun 잠깐 지워보자(굳이 여기서 받을필요가없다 새로 결제창 열면 새로 클릭하는게 맞음)
            // component.set('v.param.payment', data.UPAD_DETAIL_TYPE__c);
            component.set('v.isApproved', false);

            const param = component.get('v.param');
            param.depositDueDate = data.DEPOSIT_DUE_DT__c || moment().format('YYYY-MM-DD'); // 당일;

            if ('PG_URL' === param.payment) {
                if (data.request) { // 카드 URL 요청했다면 완료
                    param.cardRequestStatus = data.request.isPaid ? '결제완료' : '요청완료';
                    component.set('v.isIssuedCardUrl', true);
                    component.set('v.param.receiverName', data.PAY_CUST_NAME__c);
                    component.set('v.param.receiverMobile', data.PAY_CUST_PHONE__c);
                    this.fetch(component, 'kakao', {type: 'pgUrl'});
                    component.set('v.isKakaoSent', true);
                } else {
                    param.cardRequestStatus = '';
                    component.set('v.isIssuedCardUrl', false);
                }
            } else if ('PG_VBANK' === param.payment || 'PG_VBANK1' === param.payment) { // 가상계좌 수기 불가
                component.find('inner').setCashData(data);
                param.virtualBankAccountNo = data.VIRTUAL_ACCT_NUMBER__c;
                if (data.request) { // 가상계좌 요청
                    // todo 입금완료 표시할 필드 필요
                    component.set('v.virtualBankStatus', data.request.isPaid ? '결제완료' : '요청완료');
                    param.bank = data.request.bankCode;
                    component.set('v.param.receiverName', data.PAY_CUST_NAME__c);
                    component.set('v.param.receiverMobile', data.PAY_CUST_PHONE__c );
                    component.set('v.PhoneNumber',data.PAY_CUST_PHONE__c );
                    console.log('ddddd '+data.PAY_CUST_PHONE__c);
                    this.fetch(component, 'kakao', {type: 'pgVBank'});
                }
                component.set('v.isIssuedBankAccountNo', !!data.VIRTUAL_ACCT_NUMBER__c);
                component.set('v.isProofCompleted', !!data.INVOICE_ISSUE_TYPE__c); // 현금영수증 요청

                if (!!data.INVOICE_ISSUE_TYPE__c) { // 증빙 발급됨 => 완료
                    component.set('v.isKakaoSent', true);
                } else if (!!data.VIRTUAL_ACCT_NUMBER__c) { // 가상계좌 => 진행 중
                    component.set('v.isKakaoSent', true);
                }
            }

            if (!!data.INVOICE_ISSUE_TYPE__c) {
                component.set('v.authDate', data.APPR_DT__c);
                component.set('v.authNum', data.APPR_NUM__c);
                component.set('v.certifyKey', data.CERTIFY_KEY__c);
            }

            if (!data.CERTIFY_KEY__c && !data.TID_CASH__c) {
                component.set('v.cashParam.proofNo', component.get('v.contact').MobilePhone);
            }
            component.set('v.fileId', data.fileId);
            component.set('v.containerId', data.containerId);

            this.applyStatus(component);

            component.set('v.param', param);
        },
        /**
         * Contact 데이터, component.get('v.contact') 을 통해서도 접근 가능.
         * setData() 이전에 실행된다. contact 데이터로 초기값을 설정하는 용도.
         * @param component component
         * @param contact Contact
         */
        setContact: function (component, contact) {
            console.log('con :' + contact.Name);
            console.log('con :' + contact.MobilePhone);
            console.log('con :' + component.get('v.isManagement'));
            component.set('v.cashParam.proofNo', contact.MobilePhone);
            component.set('v.param.receiverName', contact.Name);
            component.set('v.param.receiverMobile', contact.MobilePhone);
            component.set('v.param.receiverMobile2', contact.MobilePhone);
            //23 10 19 hyungho.chun
            component.set('v.param.receiptIdentity', contact.MobilePhone);

        },
        /**
         * SM_DEPT__c 데이터, component.get('v.dept') 을 통해서도 접근 가능.
         * setData() 이전에 실행된다.
         * @param component component
         * @param dept SM_DEPT__c
         */
        setDept: function (component, dept) {
            if (dept.SM_VIRTUAL_ACCOUNTS__r && dept.SM_VIRTUAL_ACCOUNTS__r.length) {
                component.set('v.param.bankAccountNo', dept.SM_VIRTUAL_ACCOUNTS__r[0].VIRTUAL_ACCOUNT__c);
            }
        },
        /**
         * 초기화
         * @param component component
         * @param payload payload
         */
        reset: function (component, payload) {
            component.set('v.isReset', true);
            this.cancelAll(component);
        },
        cancelAll: function (component) {
            const param = component.get('v.param');
            if (component.get('v.isCompleted')) {
                this.clearWithParam(component, 'store', param);
            } else if (component.get('v.isProofCompleted')) {
                this.clearWithParam(component, 'proof', param);
            } else if (component.get('v.isIssuedCardUrl')) {
                this.clearWithParam(component, 'card', param);
            } else if (component.get('v.isIssuedBankAccountNo')) {
                this.clearWithParam(component, 'bank', param);
            } else if (component.get('v.fileId')) {
                this.fetch(component, 'file-delete', {containerId: component.get('v.containerId')});
            }  else if (component.get('v.id')) {
                this.delete(component);
            } else {
                this.resetValues(component);
            }
        },
        resetValues: function (component) {
            this.initValues(component);
            this.resetAmount(component);

            this.dispatch(component, 'reset', {});
        },
        initValues: function (component) {
            

            component.set('v.isReset', false);
            
            component.set('v.param', {
                payment: '',
                receiverName: '',
                receiverMobile: '',
                receiverMobile2: '',
                //23 10 19 hyungho.chun 가상계좌 현금영수증 임시 파람
                receiptIdentity: '',
                // proofTypeTemp: 'B',
                cashReceiptType: 'CA',
                // proofCashNoTypeTemp: 'B',
                //23 10 20 hyungho.chun mbsCustId값 포인트조회때 받은 서버단 송신
                mbsCustId: '',
                cardRequestStatus:'',
                depositDueDate: moment().format('YYYY-MM-DD'), // 당일
                bank: '',
                bankAccountNo: '',
                virtualBankAccountNo: '',
                kakaoMessage: '',
            });
            component.set('v.isIssuedCardUrl', false);
            component.set('v.isIssuedBankAccountNo', false);
            component.set('v.isProofCompleted', false);
            component.set('v.isKakaoSent', false);
            component.set('v.isKakaoSent', false);
            component.set('v.certifyKey', '');
            component.set('v.authDate', '');
            component.set('v.authNum', '');
            component.set('v.isCashEmp', null);

            const contact = component.get('v.contact');
            const emp = component.get('v.objEmp');
            if (contact) {
                component.set('v.param.receiverName', contact.Name );
                component.set('v.param.receiverMobile',contact.MobilePhone);
                component.set('v.param.receiverMobile2',contact.MobilePhone);
                //23 10 19 hyungho.chun 가상계좌 현금영수증 임시 파람
                component.set('v.param.receiptIdentity',contact.MobilePhone);
            }
            const dept = component.get('v.dept');
            if (dept) {
                this.setDept(component, dept);
            }
            component.set('v.isApproved', false);
        },
        setBankPaymentType : function (component) {
            var param = component.get('v.param');
            console.log('bank! + '+param.payment);
            var action = component.get('c.setBankPaymentType');
            var params = {
                'aType' : param.payment,
                'prId' : component.get('v.prId')
            };
            action.setParams({
                'paramMap': params
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('111111111111111111111111111');
                } else {
                    console.log('22222222222222222');
                }
            });
            $A.enqueueAction(action);
            console.log('bank!!');

        },

        getUserProfile: function (component) {
            var returnBoolean = true;
            var action = component.get('c.getUserProfile');
            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    returnBoolean = result;
                }
            });
            $A.enqueueAction(action);

            return returnBoolean;
        },
        checkPhoneVal : function (component, resolve, reject) {
            const strip = (c) => Array.isArray(c) ? c[0] : c;

            var action = component.get('c.checkPhoneVal');
            var phone = strip(component.find('phone'));
            var phoneNumber = phone.get('v.value');
            action.setParams({
                'phoneNumber': phoneNumber
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('result' , result);
                        component.set('v.isPhoneVal', true);
                        resolve(result);
                            // return true;    
                       
                } else {
                    this.toast('주문자 전화번호를 확인해주세요.');
                    component.set('v.isLoadingForCommonSpinner', false);
                    
                }
            });
            $A.enqueueAction(action);
            

        },

    });