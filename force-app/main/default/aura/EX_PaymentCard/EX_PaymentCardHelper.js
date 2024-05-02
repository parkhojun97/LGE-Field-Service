/**
 * Created by A78916 on 2022-12-21.
 */

// == validateion

//== save
//request_card_confirm : 카드 승인 요청
//save_card:카드 데이타 저장
//

//== cancel
//cancel_card

({

    /**
     * Event Hook. 부모에서 전달하는 이벤트 선처리
     * @param component component
     * @param target 이벤트 처리 대상 슬롯
     * @param type 이벤트 타입
     * @param payload payload
     * @returns {boolean} true 를 반환하면 이벤트 처리를 중단한다.
     */
    onObservedBefore: function (component, target, type, payload) {
        if ('component' === type) {

            // N 으로 정확히 지정하지 않으면 수기 가능
            let kIsManual = ('N' !== payload.cardManualYn);
            component.set('v.isCardManual', kIsManual);
            // 이벤트 처리를 끊지 않는다.

        }
        return false;
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
        if ('card' === purpose) {
            // 5만원 미만이면 바로 승인 시작
            const amount = component.get('v.amount');
            if (amount < 50000) {
                this.showSpinner(component, true);
                this.setStatus(component, 'progressing')
                this.startTrade(component, '00');
            } else {
                component.set('v.isOpenInstallment', true);
            }
        } else if ('nfc' === purpose) {
            const amount = component.get('v.amount');
            if (amount < 50000) {
                this.startNfc(component, '00');
            } else {
                component.set('v.isOpenInstallment', true);
            }
        }
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
        this.showSpinner(component, false);
        this.showCardReaderSpinner(component, false);
        console.log('FN_PaymentCard onMessage received From VF : ', JSON.stringify(response));
        // vf 와 통신을 결과
        component.set('v.isOpenInstallment', false);
        if ('card' === action) {
            if (!isSuccess) {
                this.setStatus(component, 'pending');
                this.toast(response.resultMsg, 'f');
                return;
            }
            this.toast('정상적으로 승인되었습니다.', 's');

            // 결제 정보에는 한국지역 시간으로 출력되므로 utc 로 변경한다.
            const dateStr = response.APPR_DT + response.APPR_TIME;
            const kDatetime = moment(dateStr, 'YYYYMMDDHHmmss').utc().format('YYYY-MM-DDTHH:mm:ss[Z]');
            // 문자열 일시는 GMT 0 적용해서 입력한다.
            component.set('v.authDate', kDatetime);
            component.set('v.installment', response.ALLOC_MONTH);
            component.set('v.cardType', response.ISSUE_CARD_NAME);//ex:신한카드
            component.set('v.authNum', response.APPR_NUM);
            component.set('v.TIDNum', response.TID);
            component.set('v.cardNum', response.CARD_NUM);

            this.save(component, 'card', {
                ALLOC_MONTH: response.ALLOC_MONTH,
                MOID: response.MOID,
                TID: response.TID,
                CARD_NUM: response.CARD_NUM,
                ISSUE_CARD_INFO: response.ISSUE_CARD_INFO,
                ISSUE_CARD_NAME: response.ISSUE_CARD_NAME,
                APPR_NUM: response.APPR_NUM,
                APPR_DTTM: kDatetime,   // 서버와 통신은 GMT 0 으로 한다.
                APPR_AMT: component.get('v.amount'),
            });

            const obj = {
                title: '카드 승인',
                amount: component.get('v.amount'),
                authDate: moment(component.get('v.authDate')).format('YYYY-MM-DD HH:mm:ss'),
                authNum: component.get('v.authNum'),
                cardType: component.get('v.cardType'),
                TID: component.get('v.TIDNum'),
                CARD_NUM: component.get('v.cardNum'),
                installment: component.get('v.installment'),
            };
            this.paper(component, 'B', 'A', obj);
            this.dispatch(component, 'printable', {});
        } else if ('print' === action) {
            if (false === isSuccess) {
                // this.toast('카드 영수증을 출력하지 못했습니다.')
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
        if ('nfc' === action) {
            if (isSuccess) {
                this.setData(component, response);
                component.set('v.isApproved', true); // 결제 완료 했을 때만 true
            }
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
        this.showSpinner(component, false);
        if ('card' === action) {
            // card 완료, 홀딩 상태
            if (isSuccess) {
                component.set('v.isApproved', true); // 결제 완료 표시
                this.setStatus(component, 'completed');
            } else {
                this.setStatus(component, 'pending');
            }
        } else if ('store' === action) {
            if (isSuccess) {
                this.setStatus(component, 'completed');
            } else {
                this.setStatus(component, 'pending');
            }
            this.dispatch(component, 'printable', {});
        } else if ('nfc' === action) {
            if (isSuccess) {
                this.dispatch(component, 'attribute', {
                    callback: (attr) => {
                        attr.installment = component.get('v.installment');
                        component.set('v.nfcAttr', attr);
                        component.set('v.isOpenNfc', true); 
                    }
                });
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
        if ('card' === action) {
            if (isSuccess) {
                component.set('v.isApproved', false); // 결제 완료 표시

                this.setStatus(component, 'pending');
                //reset이전에 꼭 호출 - 그래야 front에 아직 값이 남아 있음
                if (component.get('v.TIDNum')) {
                    this.printAfterCancel(component, action, body, response);
                }

                this.clearUi(component);

                this.dispatch(component, 'printable', {});
                this.toast('정상적으로 취소되었습니다.', 's');
            } else {
                this.toast('취소가 실패되었습니다.', 'f');
            }
        }

        if (component.get('v.isReset') && isSuccess) {
            this.cancelAll(component);
        }
    },

    printAfterCancel: function (component, action, body, response) {
        let kAuthDate = moment(component.get('v.authDate')).format('YYYY-MM-DD HH:mm:ss');
        let obj = {
            amount: component.get('v.amount'),
            title: '카드취소',
            authDate: kAuthDate,
            authNum: component.get('v.authNum'),
            cardType: component.get('v.cardType'),
            TID: component.get('v.TIDNum'),
            CARD_NUM: component.get('v.cardNum'),
            isCancel: true,
            installment: component.get('v.installment'),
        };

        this.message(component, 'print', obj);
        this.paper(component, 'B', 'B', obj);
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
            this.cancelAll(component);
        }
    },

    /**
     * 해당 슬롯의 결제 방식
     * @returns {string} card, credit, cash, point
     */
    getMethod: function () {
        return 'card';
    },
    /**
     * AR_CONFIRM 에 저장할 데이터 반환
     * @param component component
     * @returns {object} {lorem:'ipsum'}
     * @deprecated
     */
    getData: function (component) {
        return {};
    },
    /**
     * '재인쇄' 요청 시 필요 데이터 반환
     * @param component component
     * @return '{}' or null
     */
    getPrintData: function (component) {
        const tid = component.get('v.TIDNum');
        const authNum = component.get('v.authNum');
        let paper = component.get('v.paper');
        // tid 가 없어도 수기 결재 저장일 수 있으므로 저장된 상태라면 인쇄는 할 수 없도록 설정
        if (authNum) {
            paper = null;
        }
        return tid ? {
            title: '카드 승인',
            amount: component.get('v.amount'),
            authDate: moment(component.get('v.authDate')).format('YYYY-MM-DD HH:mm:ss'),
            authNum: component.get('v.authNum'),
            cardType: component.get('v.cardType'),
            TID: component.get('v.TIDNum'),
            CARD_NUM: component.get('v.cardNum'),
            installment: component.get('v.installment'),
        } : paper;
    },
    /**
     * SM_DEPT__c 데이터, component.get('v.dept') 을 통해서도 접근 가능.
     * setData() 이전에 실행된다.
     * @param component component
     * @param dept SM_DEPT__c
     */
    setDept: function (component, dept) {
        if (dept.PG__r && dept.PG__r.length) {
            component.set('v.MID', dept.PG__r[0].MID__c);
        }
    },
    /**
     * 슬롯에 표시할 SR_PRE_PAYMENT_DETAIL__c
     * 다음 변수 포함: status[progressing, completed], isLocked
     * @param component component
     * @param data SR_PRE_PAYMENT_DETAIL__c
     */
    setData: function (component, data) {
        component.set('v.isApproved', false); // 결제 완료 했을 때만 true

        // data.INPUT_TYPE__c: 수기 완료 Y, 승인 완료 N, 취소 null
        if (data.INPUT_TYPE__c) {
            this.setStatus(component, 'completed');
        } else {
            this.setStatus(component, 'pending');
        }


        let kDatetime = data.APPR_DTTM__c;
        component.set('v.authDate', kDatetime);
        component.set('v.installment', data.ALLOC_MONTH__c);

        component.set('v.cardType', data.ISSUE_CARD_NAME__c);
        component.set('v.authNum', data.APPR_NUM__c);
        component.set('v.TIDNum', data.TID__c);
        component.set('v.cardNum', data.CERTIFY_KEY__c);

        this.dispatch(component, 'printable', {});
    },
    /**
     * Contact 데이터, component.get('v.contact') 을 통해서도 접근 가능.
     * setData() 이전에 실행된다. contact 데이터로 초기값을 설정하는 용도.
     * @param component component
     * @param contact Contact
     */
    setContact: function (component, contact) {
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
        if (component.get('v.isCompleted')) {
            this.cancel(component, 'card', {});
        } else if (component.get('v.id')) {
            this.delete(component);
        } else {
            this.resetValues(component);
        }
    },
    clearUi: function (component) {
        component.set('v.cardType', '');
        component.set('v.authNum', '');
        component.set('v.authDate', '');
        component.set('v.TIDNum', '');
        component.set('v.cardNum', '');
        component.set('v.installment', '');
        this.resetAmount(component);

        // clear required
        component.set('v.isCleared', false);
        component.set('v.isCleared', true);
    },
    resetValues: function (component) {
        component.set('v.isReset', false);
        this.clearUi(component);
        this.dispatch(component, 'reset', {});
    },

    startTrade: function (component, installment) {
        this.message(component, 'card', {
            catid: component.get('v.MID'),
            amount: component.get('v.amount'),
            installment: installment
        });
    },

    startNfc: function (component, installment) {
        component.set('v.installment', installment);
        this.save(component, 'nfc', {});
    },

    //중앙에 나타나지 않아 이 뷰에만 부착된 스피너
    showCardReaderSpinner: function (component, visible) {
        component.set('v.showCardReaderSpinner', visible);
    },
    vaidateAnd: function (component, callback) {
        if(component.get('v.amount') < 10){
            return this.toast('10원 이상부터 카드 결제가 가능합니다.', 'f');
        }
        callback();
    }
});