/**
 * Created by A78916 on 2022-12-29.
 */

({
    onInit: function (component, event, helper) {
        helper.reset(component);
    },
    onChangePhone: function (component, event, helper) {
        //23.10.22 gw.lee
        //발급번호 <-> 주문자 정보 Phone 정보 미연동 조치
        // const value = component.get('v.phone'); // event.getParam('value'); 오브젝트 속성을 지정했는데 오브젝트 전체가 전달된다.
        // component.set('v.param.proofNo', value);
    },

    handleChange: function (component, event, helper) {
        component.set('v.param', component.get('v.param')); // for binding
        //23 10 19 hyungho.chun
        helper.fireReceiptInfoEvent(component);
    },

    handleChangeType: function (component, event, helper) {
        component.set('v.param', component.get('v.param')); // for binding

        const value = component.get('v.param.proofType');
        if ('A' === value && !component.get('v.containerId')) { // 세금 계산서 선택 시 파일 첨부를 위한 Id 발급
            helper.requestContainer(component);
        }
    },
    handleChangeCashType: function (component, event, helper) {
        const value = component.get('v.param.proofCashType');
        const param = component.get('v.param');
        if ('CA' === value) {
            param.proofCashNoType = 'B'; // 폰번호
            if (!param.proofNo || '010-000-1234' === param.proofNo) {
                param.proofNo = component.get('v.phone');
            }
        } else if ('CB' === value) {
            param.proofCashNoType = 'B'; // 폰번호
            param.proofNo = '010-000-1234';
        } else if ('CC' === value) {
            param.proofCashNoType = 'F'; // 사업자 번호
            param.proofNo = '';
        }

        const proofNo = component.find('proofNo');
        if (proofNo) {
            helper.report(proofNo, '');
        }

        component.set('v.param', param);
        component.set('v.param', component.get('v.param')); // for binding
        //23 10 19 hyungho.chun
        helper.fireReceiptInfoEvent(component);
    },
    handleChangeCashNoType: function (component, event, helper) {
        // 휴대폰번호 기본값 설정
        const value = component.get('v.param.proofCashNoType');
        const param = component.get('v.param');
        if ('B' === value) {
            if (!param.proofNo || '010-000-1234' === param.proofNo) {
                component.set('v.param.proofNo', component.get('v.phone'));
            }
        } else {
            component.set('v.param.proofNo', '');
        }

        const proofNo = component.find('proofNo');
        if (proofNo) {
            helper.report(proofNo, '');
        }

        component.set('v.param', component.get('v.param')); // for binding

        //23 10 19 hyungho.chun
        helper.fireReceiptInfoEvent(component);        
    },
    handleBlur: function (component, event, helper) {
        const type = component.get('v.param.proofCashNoType');
        const value = component.get('v.param.proofNo');
        if ('A' === type) {
            component.set('v.param.proofNo', helper.formatCitizenNo(value));
        } else if ('B' === type) {
            component.set('v.param.proofNo', helper.formatPhoneNum(value));
        } else if ('C' === type) {
            component.set('v.param.proofNo', helper.formatCashReceiptCardNo(value));
        } else if ('F' === type) {
            component.set('v.param.proofNo', helper.formatBizNo(value));
        }
    },
    getCashData: function (component, event, helper) {
        /*
        발급번호 CERTIFY_KEY__c: 핸드폰번호 (주민번호,사업자번호)
        현금영수증인증유형	CERTIFY_CLASS__c: A:주민번호, B:핸드폰, C:현금영수증카드번호, F:사업자번호, E:취소
        입력유형	INPUT_TYPE__c: 수기입력 Y
        자진발급여부	VOLUNTARY_YN__c: boolean

        증빙유형 INVOICE_ISSUE_TYPE__c: A:세금계산서, B:현금영수증, C:미발행, D:카드
        결제유형 DEPOSIT_TYPE__c A:현금, B:카드, C:쿠폰, D:포인트, E:미수

        승인번호	APPR_NUM__c
        승인일자	APPR_DT__c
        현금영수증 거래번호	TID_CASH__c:
         */
        const param = component.get('v.param');
        const data = {};
        data.INVOICE_ISSUE_TYPE__c = param.proofType;

        if (param.proofType === 'B') {   // 현금 영수증
            data.VOLUNTARY_YN__c = 'CB' === param.proofCashType;
            data.CERTIFY_KEY__c = data.VOLUNTARY_YN__c ? '010-000-1234' : param.proofNo;
            data.CERTIFY_CLASS__c = param.proofCashNoType;
            if ('CA' === param.proofCashType) {
                data.CERTIFY_TYPE__c = '1';
            } else if ('CC' === param.proofCashType) {
                data.CERTIFY_TYPE__c = '2';
            }
        } else { // 세금 계산서
            data.ACCOUNT_ID__c = component.find('cash_account_id').get('v.value');
        }
        return data;
    },
    setCashData: function (component, event, helper) {
        const params = event.getParam('arguments');
        if (params) {
            const data = params.data;
            component.set('v.status', data.status);
            if (data.INVOICE_ISSUE_TYPE__c) {
                component.set('v.param.proofType', data.INVOICE_ISSUE_TYPE__c);
                component.set('v.fileId', data.fileId);
                component.set('v.containerId', data.containerId);
                if (data.INVOICE_ISSUE_TYPE__c === 'B') {   // 현금 영수증
                    if (data.VOLUNTARY_YN__c) {
                        component.set('v.param.proofCashType', 'CB');
                    } else if ('1' === data.CERTIFY_TYPE__c) {
                        component.set('v.param.proofCashType', 'CA');
                    } else if ('2' === data.CERTIFY_TYPE__c) {
                        component.set('v.param.proofCashType', 'CC');
                    }
                    component.set('v.param.proofCashNoType', data.CERTIFY_CLASS__c);
                    component.set('v.param.proofNo', data.CERTIFY_KEY__c);
                } else { // 세금 계산서
                    component.find('cash_account_id').set('v.value', data.ACCOUNT_ID__c);
                    if (!data.containerId) { // 세금 계산서 선택 시 파일 첨부를 위한 Id 발급
                        helper.requestContainer(component);
                    }
                }
            }
            component.set('v.param', component.get('v.param'));
        }
    },
    reset: function (component, event, helper) {
        helper.reset(component);
    },
    validate: function (component, event, helper) {
        const params = event.getParam('arguments');
        if (params) {
            const callback = params.callback;
            const param = component.get('v.param');
            const type = param.proofCashNoType;
            const value = param.proofNo;
            if ('B' === param.proofType) {
                const proofNo = component.find('proofNo');
                if ('A' === type) {
                    if (!helper.isCitizenNo(value)) {
                        helper.report(proofNo, '_');
                        return helper.toast('올바른 주민등록번호 형식이 아닙니다.');
                    }
                } else if ('B' === type) {
                    if (!helper.isMobilePhone(value)) {
                        helper.report(proofNo, '_');
                        return helper.toast('올바른 핸드폰번호 형식이 아닙니다.');
                    }
                } else if ('C' === type) {
                    if (!helper.isCashReceiptCardNo(value)) {
                        helper.report(proofNo, '_');
                        return helper.toast('올바른 현금영수증카드번호 형식이 아닙니다.');
                    }
                } else if ('F' === type) {
                    if (!helper.isBizNo(value)) {
                        helper.report(proofNo, '_');
                        return helper.toast('올바른 사업자번호 형식이 아닙니다.');
                    }
                }
                helper.report(proofNo, '');
            }
            if (callback) {
                callback();
            }
        }
    },
    handleUploadFinished: function (component, event, helper) {
        const uploadedFiles = event.getParam('files');
        // alert("Files uploaded : " + uploadedFiles.length);

        // uploadedFiles.forEach(file => console.log(file.documentId));
        const documentId = uploadedFiles[0].documentId;
        component.set('v.fileId', documentId);
    },
    handleClickPreview: function (component, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: [component.get('v.fileId')]
        });
    },
    handleClickDelete: function (component, event, helper) {
        helper.confirm('확인', '삭제하시겠습니까?')
            .then(() => {
                helper.removeDocument(component);
            });
    },
});