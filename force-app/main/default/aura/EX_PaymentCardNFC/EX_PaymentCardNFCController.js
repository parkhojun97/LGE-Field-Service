/**
 * Created by A78916 on 2023-06-02.
 */

({
    onInit: function (component, event, helper) {
        const attr = component.get('v.attr');
        if (attr) {
            const uuid = crypto.randomUUID();
            component.set('v.uuid', uuid);
            /*
            '{"ContactId":"0036D00000jBA1E","recordId":"0WO0k00000034X9GAI","DEPT_CODE_ID":"a0q6D000002GV4oQAG","BIZ_ORIGIN_TYPE":"B",
            "BASIS_NO":"N5041434KC","BASIS_DT":"2023-06-01","REPAIR_AMT":null,"REPAIR_PART_AMT":null,"ACCESSORY_AMT":null,
            "ACCESSORY_DELI_AMT":null,"SPECIAL_INCOME_AMT":null,"EXTRA_PROFIT_AMT":null,"SALE_AMT":null,"SETTLE_AMT":80000,
            "BUNDLE":false,"BUNDLE_Id":null,"GOODS_NAME":"상품명","GOODS_CNT":1,"CRD_MANUAL_INPUT_YN":"Y","uuid":"c7def7f2-d233-4b6c-a869-cf2b336e94c5"}'
             */
            let json = JSON.stringify({
                recordId: attr.recordId,
                area: component.get('v.area'),
                userId: $A.get('$SObjectType.CurrentUser.Id'),
                uuid: uuid,
                installment: attr.installment,
            });
            json = encodeURIComponent(btoa(encodeURIComponent(json)));
            component.set('v.json', json);

            const empApi = component.find('empApi');

            // Uncomment below line to enable debug logging (optional)
            // empApi.setDebugFlag(true);

            // Register error listener and pass in the error handler function
            empApi.onError($A.getCallback(error => {
                // Error can be any type of error (subscribe, unsubscribe...)
                console.error('EMP API error: ', JSON.stringify(error));
            }));

            helper.subscribe(component);
        }
    },
    handleClose: function (component, event, helper) {
        helper.closeWithUnsubscribe(component, 'close');
    }
});