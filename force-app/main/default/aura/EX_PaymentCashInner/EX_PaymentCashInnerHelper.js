/**
 * Created by A78916 on 2023-01-13.
 */

({
    reset: function (component) {
        component.set('v.param', {
            id: '',
            proofType: 'B',
            proofCashType: 'CA',
            proofCashNoType: 'B',
            proofNo: '',
            contact: null,
            bizDoc: '',
        });
    },
    requestContainer: function (component) {
        const evt = component.getEvent('onRequest');
        evt.setParam('type', 'file');
        evt.fire();
    },
    report: function(c, v) {
        c.setCustomValidity(v);
        c.reportValidity();
    },
    removeDocument: function (component) {
        const evt = component.getEvent('onRequest');
        evt.setParam('type', 'file-delete');
        evt.setParam('detail', {containerId: component.get('v.containerId')});
        evt.fire();
    },

    //23 10 19 hyungho.chun 현금영수증관련 정보 상위컴포넌트(ex_paymentURL)에보내주는용도
    fireReceiptInfoEvent: function(component){
        console.log('현금영수증 데이터 전송');
        var param = component.get('v.param');
        console.log('param :: ',param );
        console.log('param :: ', JSON.stringify(param) );

        var evt = $A.get("e.c:EX_ReceiptInfoEvent_evt");
        evt.setParam('cashReceiptMobile', String(param.proofNo));
        evt.setParam('proofType', String(param.proofType));
        evt.setParam('proofCashType', String(param.proofCashType));
        evt.setParam('proofCashNoType', String(param.proofCashNoType));
        console.log('evt before Fire :: ',evt);
        console.log('evt before Fire :: ',JSON.stringify(evt));
        evt.fire();

        // var evt = component.getEvent('receiptInfoEvent');
        // evt.setParam('cashReceiptMobile', String(param.proofNo));
        // evt.setParam('proofType', String(param.proofType));
        // evt.setParam('proofCashType', String(param.proofCashType));
        // evt.setParam('proofCashNoType', String(param.proofCashNoType));
        // console.log('evt before Fire :: ',evt);
        // console.log('evt before Fire :: ',JSON.stringify(evt));
        // evt.fire();

        console.log('evt :: ',evt);
        console.log('evt :: ',JSON.stringify(evt));
    }
});