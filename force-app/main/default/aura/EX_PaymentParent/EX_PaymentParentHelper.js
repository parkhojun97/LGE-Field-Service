/**
 * Created by A78916 on 2023-02-09.
 */


({
    initialize: function (component, data) {
        // 항상 콤포넌트 파라메터로 갱신
        // B카, A캐, D포, E미
        let slotDataList = [];
        component.set('v.contact', data.contact); // Name, MobilePhone
        component.set('v.dept', data.dept); // SM_VIRTUAL_ACCOUNTS__r[0].VIRTUAL_ACCOUNT__c
        component.set('v.isLocked', !!data.isLocked);
        if (data.header) {
            component.set('v.isPaymentCompleted', 'completed' === data.header.PROGRESS_STATE__c);
        }
        if (data && data.slots && data.slots.length) {
            // data.isLocked
            // data.contact
            // data.header
            // data.slots
            // data.files
            // data.dept
            // data.requests
            const slots = data.slots;
            slotDataList = this.populateSlot(slots);

            if (slotDataList.find(s => !s.PAYMENT_AREA_NO__c)) {
                return this.toast('처리할 수 없는 결제 내역입니다.');
            }
            slotDataList.forEach((slot) => {
                slot.status = data.header ? data.header.PROGRESS_STATE__c : 'progressing';
                if (data.files && data.files.length) { // file mapping
                    const file = data.files.find(e => e.slotNo === slot.PAYMENT_AREA_NO__c);
                    if (file && file.documentId) {
                        slot.fileId = file.documentId;
                        slot.containerId = file.containerId;
                    }
                }
                if (data.requests && data.requests.length) { // requests mapping
                    const request = data.requests.find(e => e.slotNo === slot.PAYMENT_AREA_NO__c);
                    if (request) {
                        slot.request = request; // 슬롯 별 레코드는 1개, 현금영수증은 기본 필드(Certify...)
                    }
                }
            });
        } else {
            slotDataList = this.populateSlot([]);
        }
        // 묶음 결제인 경우 1개 슬롯만 활성화
        const isBundled = data.header && data.header.OBJECT_NAME__c === 'SR_PAYMENT_BUNDLE__c';
        slotDataList.forEach((slot) => {
            if (data.isLocked) {
                slot.isLocked = true;
            } else {
                slot.isLocked = false;
                if (isBundled) {
                    // 묶음이면 1번만 활성화
                    slot.isBundled = 1 !== slot.PAYMENT_AREA_NO__c;
                }
            }
        });
        this.update(component,this.getSlots(component), '', 'initialized', slotDataList);
    },
    populateSlot: function (slots) {
        let slotDataList = [];
        if (slots.length < 4) {
            // 포인트는 1개만 사용, 기본 순서 B A D E
            const typeOf = ((d) => {
                const position = {1: 'D', 2: 'E', 3: 'B', 4: 'A'};
                const replace = (slot, code) => {
                    if (slot) {
                        const prev = position[slot.PAYMENT_AREA_NO__c]; // 이전 코드
                        position[slot.PAYMENT_AREA_NO__c] = code; // 슬롯 자리 차지
                        // 중복 검사
                        const old = Object.keys(position).find(e => +e !== slot.PAYMENT_AREA_NO__c && position[e] === code);
                        if (null != old) {
                            position[old] = prev; // 이전 코드 복원
                        }
                    }
                }

                const point = d.find(e => 'D' === e.DEPOSIT_TYPE__c); // 포인트 위치
                replace(point, 'D');

                const credit = d.find(e => 'E' === e.DEPOSIT_TYPE__c); // 미수 위치
                replace(credit, 'E');

                return (no) => position[no];
            })(slots);

            for (const i of Array(4).keys()) {
                const slotNo = i + 1;
                let slot = slots.find(e => slotNo === e.PAYMENT_AREA_NO__c);
                if (!slot) {
                    slot = {PAYMENT_AREA_NO__c: slotNo, DEPOSIT_TYPE__c: typeOf(slotNo)};
                }
                slotDataList.push(slot); // 슬롯 번호 순서대로 담기
            }
        } else {
            slotDataList = slots;
        }
        return slotDataList;
    },
    calcBalance: function (total, slotAmount) {
        return total - this.sumAmount(slotAmount);
    },
    sumAmount: function (amounts) {
        return Object.keys(amounts).map(k => amounts[k]).reduce((acc, e) => {
            return (e && e > 0) ? acc + +e : acc; // 양수만 계산
        }, 0);
    },
    updateBalance: function (component) {
        /*
결제 완료 금액: 각 슬롯에 '완료'된 금액의 합
남은 금액: 완료되지않은 금액
유효성 검사를 위해 입력한 금액은 별도 저장
         */
        this.displayBalance(component);
        this.displayPaidAmount(component);

        this.dispatchBalance(component);
    },
    dispatchBalance: function (component) {
        let balance = this.getSlotBalance(component);
        if (!balance) {
            balance = 0;
        }
        // 미결제 금액이 아닌 입력 금액 기준으로 잔액 전파
        this.update(component, this.getSlots(component), '', 'balance', {balance});
    },
    displayBalance: function (component) {
        const total = component.get('v.totalAmount');
        const paidAmount = component.get('v.slotPaidAmount');
        component.set('v.balance', this.calcBalance(total, paidAmount));
    },
    displayPaidAmount: function (component) {
        const paidAmount = component.get('v.slotPaidAmount');
        component.set('v.paidAmount', this.sumAmount(paidAmount));
    },
    getSlotBalance: function (component) {
        const total = component.get('v.totalAmount');
        const slotAmount = component.get('v.slotAmount');
        return this.calcBalance(total, slotAmount);
    },
    validateBalance: function (component) {
        return 0 === this.getSlotBalance(component) ? '' : '남은 금액을 확인하세요.';
    },
    validateBalanceNegative: function (component) {
        if (this.getSlotBalance(component) < 0) {
            return '입력한 금액이 초과되었습니다, 다시 확인하세요.';
        }
        return '';
    },
    validateCompletableStatus: function (component) {
        // 하나 이상 완료, 나머지 완료 또는 묶음 비활성
        const slots = this.getSlots(component);
        return slots
            .map(e => e.getStatus())
            .filter(e => 'disabled' !== e)
            .map(e => 'completed' === e || 'bundled' === e)
            .reduce((acc, b) => acc && b, slots.find(e => 'completed' === e.getStatus())) ? '' : '결제 상태를 확인하세요.';
    },
    validateMethod: function (component, method) {
        const slotMethod = component.get('v.slotMethod');
        const copy = this.deepCopy(slotMethod);
        copy.candidate = method;    // 임의로 1개 추가해서 2개인지 확인

        // 번들은 비교하지 않음
        const valid = (type) => Object.keys(copy)
            .map(k => {
                const slot = component.find('slot_' + k);
                return {type: copy[k], status: slot ? slot.getStatus() : null};
            })
            .filter(e => e.type && e.type === e.type.toLowerCase() && 'bundled' !== e.status);

        const result = valid('point');
        if (result && result.length > 1) {
            return '포인트 결제는 1개만 선택하세요.';
        }
        const result2 = valid('credit');
        if (result2 && result2.length > 1) {
            return '미수 결제는 1개만 선택하세요.';
        }
    },
    validateAll: function (component) {
        // 저장 전 모든 유효성 검사 실행
        let msg = this.validateBalance(component);
        if (msg) {
            return msg;
        }
        msg = this.validateCompletableStatus(component);
        if (msg) {
            return msg;
        }
        msg = this.validateMethod(component, 'anything');
        if (msg) {
            return msg;
        }
        return '';
    },
    validateEach: function (component) {
        // 개별 저장 전 유효성 검사 실행
        return this.validateBalanceNegative(component) || '';
    },
    applyCanComplete: function (component) {
        const isPaymentCompleted = component.get('v.isPaymentCompleted');
        // 결제 완료 가능 조건, 모두 수기 입력이거나, 완료 슬롯
        if(component.get('v.isCancel') == false){
            const b = !this.validateCompletableStatus(component) && 0 === component.get('v.balance');
            component.set('v.canComplete', b && !isPaymentCompleted); // 결제 완료를 할 수 있는 상태이고, 아직 결제를 안했다면.
        }
        else{
            component.set('v.canComplete', true);
        }
    },
    completeWithValidation: function (component) {
        let msg = this.validateAll(component);
        if (msg) {
            return this.toast(msg);
        }
        this.complete(component);
    },
    request: function (component, slotNo, type, detail) {
        /*
        금액 0원 초과, 실행 슬롯과 수기입력(미완료) 가능한 슬롯 저장
         */
        const slotAmounts = component.get('v.slotAmount');
        detail.type = type;
        if (detail.body) {
            detail.body.GOODS_NAME = component.get('v.GOODS_NAME');  // 상품명/수 추가
            detail.body.GOODS_CNT = component.get('v.GOODS_CNT');
            detail.body.slotAmount = slotAmounts[slotNo];   // 슬롯 금액
            if(detail.body.payment == 'PG_VBANK1'){
                detail.body.payment = 'PG_VBANK';
            }
        }

        const data = this.getBaseData(component, slotNo, detail,
            [component.find('slot_' + slotNo).getData()]
                );
        this.saveAll(component, data, $A.getCallback((response) => {
            detail.isSuccess = true;
            detail.response = response;
            this.update(component, this.getSlots(component), slotNo, type, detail);
            // 'fetch' !== type && this.toast('요청 성공', 's');
            // 결제 완료 버튼 누를 상황이라면 알려줌
            this.applyCanComplete(component);

            if ('cancel' === type) { // 취소 성공 시 결제 완료 해제
                component.set('v.isPaymentCompleted', false);
            }

            let offset =  new Date().getTimezoneOffset() * 60000;
            let dateOffset = new Date(new Date().getTime() - offset);
            console.log('속도측정 -------------------------------------------------- EX_PaymentParent.cmp.saveAll - end:' + dateOffset.toISOString());
            console.log('this.getSlots :: ', this.getSlots(component));
            console.log('slotNo :: ',slotNo);
            console.log('type :: ',type);
            console.log('detail :: ',JSON.stringify(detail));
            console.log('detail :: ', detail);

            //24 01 02 hyungho.chun 포인트전액으로 주문생성시 결제완료되었습니다 토스트 메세지
            if(
                (detail.method == 'point' && detail.action == 'save' && detail.type =='save' && detail.isSuccess == true && detail.body.amount == detail.body.slotAmount)
                && component.get('v.canComplete')){ 
                    this.toast('결제가 완료되었습니다.','s');
            }

            //23 10 20 hyungho.chun 포인트 MBS cust id 미리 받아서 쏴주기
            if(detail.method =='point' && detail.action == 'retrieve_point' && detail.type =='fetch' && detail.isSuccess == true){
                console.log('포인트 지나간다~');
                var evt = $A.get("e.c:EX_PaymentPointMBSidSend_evt");
                evt.setParam('mbsCustId', detail.response.MBS_CUST_ID);
                evt.fire();
            }            

            //23 09 05 hyungho.chun 결제완료할땐(현장카드만적용) 바로 완료되게
            console.log('canComplete :: ',component.get('v.canComplete'));
            //23 10 20 hyungho.chun 결제완료가능여부 체크 이벤트
            //23 12 09 hyungho.chun 포인트에관련된 detail로는 canComplete을 보낼수가없다(전액포인트면 자동으로 닫히고 부분포인트면 아직안끝난거임)
            var canCompleteTemp = component.get('v.canComplete');
            if(canCompleteTemp!=null && detail.method !='point'){
                var evt2 = $A.get("e.c:EX_PaymentCompleted_evt");
                evt2.setParam('isReadyToGo', true);
                evt2.fire();
            }
            

            if(component.get('v.canComplete') && type == 'save' && detail.method == 'card' && detail.action == 'card'){
                this.toast('결제가 완료되었습니다.','s'); //24 01 02 hyungho.chun 현장카드 주문생성시 결제완료되었습니다 토스트 메세지
                var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
                evt.setParams({"complete" : true});
                evt.fire();
                component.destroy();
            }

            //24 01 11 hyungho.chun 결제URL알림톡받자마자 '결제예약'버튼누르지않고 자동으로 창닫힘
            if(component.get('v.canComplete') && type == 'fetch' && detail.method == 'credit' && detail.action == 'kakao-send'){     
                var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
               evt.setParams({"complete" : true});
               evt.fire();
               component.destroy();
           }            

        }), $A.getCallback((response) => {
            detail.isSuccess = false;
            detail.response = response;
            this.update(component, this.getSlots(component), slotNo, type, detail);
            //데이터 업데이트 후 이 지점에서 취소 이벤트 발생
        }));
    },
    complete: function (component) {
        // 결제 완료: 금액이 1원 이상인 결제 모두 저장
        const slotAmount = component.get('v.slotAmount');
        const slot = Object.keys(slotAmount).find(k => slotAmount[k] > 0);
        const detail = {method: 'main', type: 'complete', action: 'complete'};
        const requestData = this.getBaseData(component, 0, detail,
            Object.keys(slotAmount)
                .filter(k => slotAmount[k] > 0)
                .map(k => component.find('slot_' + k))
                .map((slot) => {
                    return slot.getData();
                }));
        if (slot) {
            this.showSpinner(component, true);
            this.apex(component, 'complete', {aData: requestData})
                .then(({data}) => {
                    this.showSpinner(component, false); // handler 보다 먼저 실행해야 연속 request 시 스피너가 사라지지 않는다.
                    const evt = component.getEvent('onCompleted');
                    evt.setParam('name', 'completed');
                    evt.setParam('type', 'completed');
                    evt.setParam('detail', {Id: data.Id}); // todo 처리 결과를 함께 보낼 수 있음
                    evt.fire();
                })
                .catch(e => {
                    this.showSpinner(component, false);
                    this.alert(e.error || this.parseErrorMessage(e));
                });
        } else {
            console.log(' empty... ');
        }

    },
    getBaseData: function (component, slotNo, detail, slots) {
        const totalAmount = component.get('v.totalAmount');
        return {
            platform: this.getPlatform(),
            originId: component.get('v.recordId'),
            contactId: component.get('v.ContactId'),
            totalAmount: totalAmount,
            slotNo: slotNo,
            payload: detail,
            header: this.getHeader(component),
            slots,
        };
    },
    saveAll: function (component, requestData, successFn, failFN) {
        this.showSpinner(component, true);
        console.log('requestData :: ',requestData);
        console.log('JSON.stringify(requestData) :: ',JSON.stringify(requestData));
        this.apex(component, 'request', {aData: requestData})
            .then(({data}) => {
                this.showSpinner(component, false); // handler 보다 먼저 실행해야 연속 request 시 스피너가 사라지지 않는다.
                successFn(data);
            })
            .catch(e => {
                this.showSpinner(component, false);
                failFN();
                //23 12 15 hyungho.chun 최소 결제 금액 오류 -> 최소 결제 금액 (300원) 오류
                if(e.error && e.error == '최소 결제 금액 오류'){
                    e.error = '최소 결제 금액 (300원) 오류';
                }
                if(e.error && e.error.includes('포인트 적용 실패')){
                    //24 01 09 hyungho.chun 
                    var total = component.get('v.totalAmount');
                    var evt = $A.get("e.c:EX_PaymentAmountReset_evt");
                    evt.setParam('amount', total);
                    evt.fire();                    
                }                                
                this.alert(e.error || this.parseErrorMessage(e));
            });
    },
    //24 01 16 hyungho.chun nfc 결제용 데이터 묶어주기
    getAttrParams: function (component) {
        return {
            ContactId: component.get('v.ContactId'),
            recordId: component.get('v.recordId'),
            DEPT_CODE_ID: component.get('v.DEPT_CODE_ID'),
            BIZ_ORIGIN_TYPE: component.get('v.BIZ_ORIGIN_TYPE'),
            BASIS_NO: component.get('v.BASIS_NO'),
            BASIS_DT: component.get('v.BASIS_DT'),
            REPAIR_AMT: component.get('v.REPAIR_AMT'),
            REPAIR_PART_AMT: component.get('v.REPAIR_PART_AMT'),
            ACCESSORY_AMT: component.get('v.ACCESSORY_AMT'),
            ACCESSORY_DELI_AMT: component.get('v.ACCESSORY_DELI_AMT'),
            SPECIAL_INCOME_AMT: component.get('v.SPECIAL_INCOME_AMT'),
            EXTRA_PROFIT_AMT: component.get('v.EXTRA_PROFIT_AMT'),
            SALE_AMT: component.get('v.SALE_AMT'),
            SETTLE_AMT: component.get('v.SETTLE_AMT'),
            BUNDLE: component.get('v.BUNDLE'),
            BUNDLE_Id: component.get('v.BUNDLE_Id'),
            GOODS_NAME: component.get('v.GOODS_NAME'),
            GOODS_CNT: component.get('v.GOODS_CNT'),
            CRD_MANUAL_INPUT_YN: component.get('v.CRD_MANUAL_INPUT_YN'),
        };
    },    
    retrieve: function (component, originId, contactId, deptId, platform) {
        this.showSpinner(component, true);
        this.apex(component, 'retrieve', {
            aOriginId: originId,
            aContactId: contactId,
            aDeptId: deptId,
            aPlatform: platform
        })
            .then(({data}) => {
                this.showSpinner(component, false);
                this.initialize(component, data);
            })
            .catch(e => {
                this.showSpinner(component, false);
                this.alert(e.error || this.parseErrorMessage(e));
            });
    },
    getSlots: function (component) {
        return [
            component.find('slot_1'),
            component.find('slot_2'),
            component.find('slot_3'),
            component.find('slot_4'),
        ];
    },
    getHeader: function (component) {
        return {
            SM_DEPT_CODE_ID__c: component.get('v.DEPT_CODE_ID'),
            BIZ_ORIGIN_TYPE__c: component.get('v.BIZ_ORIGIN_TYPE'),
            BASIS_NO__c: component.get('v.BASIS_NO'),
            BASIS_DT__c: component.get('v.BASIS_DT'),
            REPAIR_AMT__c: component.get('v.REPAIR_AMT'),
            REPAIR_PART_AMT__c: component.get('v.REPAIR_PART_AMT'),
            ACCESSORY_AMT__c: component.get('v.ACCESSORY_AMT'),
            ACCESSORY_DELI_AMT__c: component.get('v.ACCESSORY_DELI_AMT'),
            SPECIAL_INCOME_AMT__c: component.get('v.SPECIAL_INCOME_AMT'),
            EXTRA_PROFIT_AMT__c: component.get('v.EXTRA_PROFIT_AMT'),
            SALE_AMT__c: component.get('v.SALE_AMT'),
            SETTLE_AMT__c: component.get('v.SETTLE_AMT'),
            BUNDLE__c: component.get('v.BUNDLE'),
            BUNDLE_Id__c: component.get('v.BUNDLE_Id'),
            ContactId__c: component.get('v.ContactId'),
            ATTR_RECORD_ID__c: component.get('v.recordId'),
        };
    },

    /**
     * 각 slot 에 이벤트 전파
     *
     * @param slots slots
     * @param name 이벤트 처리 대상, '' 이면 모두 대상
     * @param type 이벤트 타입
     * @param payload payload
     */
    update: function (component, slots, name, type, payload) {
        // slots.forEach(e => e.onObserved(name, type, payload));
        console.log('========= update => ', name, type, JSON.stringify(payload));
        if(type == 'initialized'){

            if(payload[1].CERTIFY_KEY__c != payload[1].PAY_CUST_PHONE__c && payload[1].CERTIFY_KEY__c != null){
                payload[1].request.paymentType = 'PG_VBANK1';
                payload[1].UPAD_DETAIL_TYPE__c  = 'PG_VBANK1';
            }
        }
        console.log('========= update => ', name, type, JSON.stringify(payload));

        if (typeof slots != 'number') {
            for (const slot of slots) {
                slot && slot.onObserved(name, type, payload);
            }
        }
        
        
        if(name == 2 && type == 'fetch' && component.get('v.isCancel')){
            if(component.get('v.cashFlag')){
                console.log('캐쉬 취소 ' + component.get('v.cashFlag'));
                var evt = $A.get("e.c:EX_PaymentCancelEvent_evt");
                evt.setParam("isCancelPayment" ,true);
                evt.setParam("CancelStatus" ,'취소');
                evt.fire();
            }
        }

        console.log('component.get(slot) :::: ' + component.get('v.slotAmount'));
        const slotAmount = component.get('v.slotAmount');

        console.log(name);
        console.log(type);

        if(name == 1 && type == 'delete' && component.get('v.cashFlag') == true && component.get('v.pointFlag') && (slotAmount[2] == component.get('v.totalAmount'))){
            if(payload.method == 'PG_URL' || payload.method == 'point'){
               var evt = $A.get("e.c:EX_PaymentCancelEvent_evt");
               evt.setParam("isCancelPayment" ,true);
               evt.setParam("CancelStatus" ,'취소');
               evt.fire();
           }
        }
        if(name == 2 && type == 'cancel' ){
            component.set('v.cashFlag',true);
            component.set('v.isCancel',true);
            this.showSpinner(component, true);
        }
        if(name == 1 && type == 'cancel'){
            component.set('v.pointFlag',true);
            component.set('v.isCancel',true);
            this.showSpinner(component, true);
        }
        if(type == 'cancel' && name == 1 && component.get('v.cashFlag')){
            if((slotAmount[2] == 0) && component.get('v.paidAmount') == component.get('v.totalAmount')){
                const total = component.get('v.totalAmount');
                console.log('total : '+ total + ' slot : '+ slotAmount[1]);
                console.log('포인트 취소' + component.get('v.pointFlag') + ' ' + component.get('v.cashFlag'));
                var evt = $A.get("e.c:EX_PaymentCancelEvent_evt");
                evt.setParam("isCancelPayment" ,true);
                evt.setParam("CancelStatus" ,'취소');
                evt.fire();
            }
        }

        if(type == 'save' && name == 1 && slotAmount[1] == component.get('v.totalAmount')){
            var evt = component.getEvent("EX_PaymentCompleteEvent_evt");
            evt.setParams({"complete" : true});
            evt.fire();
        }
    },
    // slot 으로 부터 전달되는 이벤트
    onEvent: function (component, event) {
        const name = event.getParam('name');    // slot no
        const type = event.getParam('type');    // event type
        const detail = event.getParam('detail');    // detail

        console.log('_____________ =>', name, type, JSON.stringify(detail));
        let offset =  new Date().getTimezoneOffset() * 60000;
        let dateOffset = new Date(new Date().getTime() - offset);
        console.log('속도측정 -------------------------------------------------- EX_PaymentParent.cmp.onEvent - 시작:' + dateOffset.toISOString());
        if(name == 1){
                console.log('to :' + component.get('v.totalAmount'));
        }
        if (this.onObserved(component, name, type, detail)) {
            // event consumed by subComponent
        } else if ('component' === type) {  // 콤포넌트 생성 시 초기 값 전파
            this.update(component, this.getSlots(component), name, 'component', {
                totalAmount: component.get('v.totalAmount'),
                contact: component.get('v.contact'),
                dept: component.get('v.dept'),
                cardManualYn: component.get('v.CRD_MANUAL_INPUT_YN'),
            });
        } else if ('amount' === type) { // 각 결제액 입력 시 저장
            component.set('v.slotAmount.' + name, +detail.amount);
            this.dispatchBalance(component);
            if(name == 1){
                component.set('v.slotAmount.' + 2 , (component.get('v.totalAmount') - detail.amount) > 0 ? (component.get('v.totalAmount') - detail.amount) : 0);
                detail.amount = (component.get('v.totalAmount') - detail.amount) > 0 ? (component.get('v.totalAmount') - detail.amount) : 0;
                this.update(component, this.getSlots(component), 2 , type, detail);
            }
        } else if ('status' === type) { // 각 슬롯 상태에 따라서 남은 금액과 완료 금액을 계산한다.
            const status = detail.status;
            if (status === 'completed') {
                component.set('v.slotPaidAmount.' + name, +detail.amount);
                this.updateBalance(component);
                this.applyCanComplete(component);
            } else if (status === 'holding' || status === 'pending' || status === 'disabled') {
                component.set('v.slotPaidAmount.' + name, 0);
                this.updateBalance(component);
                this.applyCanComplete(component);
            }
        } else if ('manual' === type) { // 수기 입력 상태가 변경 됐을 때
            this.applyCanComplete(component);
        } else if ('reset' === type) { // 슬롯 초기화를
            component.set('v.isPaymentCompleted', false);
        } else if ('focused' === type) { // 헤더에서 포커스 처리했음
            component.set('v.isFocused', true);
            this.update(component, this.getSlots(component), '', '', {}); // 나머지 슬롯에게도 전달
        }else if ('attribute' === type) {  //24 01 16 hyungho.chun NFC용 분기처리 추가
            
            detail.callback(this.getAttrParams(component));
        } else if ('method' === type) {  // 결제 방법 변경
            const msg = this.validateMethod(component, detail.method);
            if (msg) {
                this.toast(msg);
            } else {
                component.set('v.slotMethod.' + name, detail.method);
            }
            detail.isValid = !msg;
            this.update(component, this.getSlots(component), name, type, detail);
        } else if ('validation' === type) { // 유효 데이터 생성을 위해서 가능성 확인
            const msg = this.validateBalanceNegative(component);
            if (msg) {
                return this.toast(msg);
            }
            detail.isValid = !msg;
            this.update(component, this.getSlots(component), name, type, detail);
        } else if ('save' === type) {   // 개별 결제 방법 저장
            const msg = this.validateEach(component);
            if (msg) {
                detail.isSuccess = false;
                this.update(this.getSlots(component), name, type, detail);
                return this.toast(msg);
            }
            this.request(component, name, type, detail);
        } else if ('fetch' === type || 'delete' === type || 'cancel' === type) {
            console.log('fecth!!!!');
            this.request(component, name, type, detail);
        }
    },
    // ----------------------- //
    // abstract
    // ----------------------- //
    /**
     * Event Hook. 부모로부터 전달되는 이벤트를 후킹한다.
     * @param component
     * @param name 이벤트 이름
     * @param type 이벤트 타입
     * @param detail 이벤트 데이터
     * @returns {boolean} true 를 반환하면 이벤트 처리를 중단한다.
     */
    onObserved: function (component, name, type, detail) {
        return false;
    },
    /**
     * 실행 플랫폼 구분 (desktop, mobile)
     * @returns {string}
     */
    getPlatform: function () {
        return '';
    },
});