/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-02.
 */

({

    fnInit: function (component, event, helper) {
        
        let columns = [
            {label: '번호', fieldName: 'Seq', type: 'number', initialWidth:80},
            {label: '주문번호', fieldName: 'OrderNUmber', type: 'text' , initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '수신자명', fieldName: 'RCVR_Name', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '수신자이메일', fieldName: 'RCVR_Email', type: 'text', initialWidth: 170, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
//            {label: '견적메모', fieldName: 'Quote_Memo', type: 'text', initialWidth: 180, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '견적메모', fieldName: 'Quote_Memo', type: 'text', cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},

            {label: '견적서', fieldName: 'Quote_YN', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '명세서', fieldName: 'Invoice_YN', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '사업자등록증', fieldName: 'Business_Registration_YN', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '통장사본', fieldName: 'BankBookCopy_YN', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
            {label: '발송여부', fieldName: 'Send_YN', type: 'text', initialWidth: 110, cellAttributes: {class: {fieldName: ''}, alignment: 'right'}},
             {
                label: '생성일시', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                },
                initialWidth: 200,
                hideDefaultActions: true,
            }
        ];
        console.log('component.get(\'v.isManagement\') > ', component.get('v.isManagement'));
        console.log('v.objCont.Name :: ',component.get('v.objCont.Name'));
        if(component.get('v.isManagement')){
            helper.fnGetOrderData(component, event, helper);
        }else{
            helper.fnSetHistoryData(component, event, helper);
        }
        // console.log('>>>>>>@>>>>>> ::: ' , component.get('v.standardOrderData'));
        // if(component.get('v.standardOrderData')[0].OrderStatus == '결제요청'){
        //     component.set('v.modalTitle', '견적서/명세서');
        // }
            
        setTimeout(function(){
            helper.sendMessage(component, {type:'items', items: component.get('v.data')});

            //23.08.17 PHJ
            helper.sendMessage(component, {type:'singlechekcedData', items: component.get('v.data')});
        },2000);
        component.set('v.optionsList', event.getParam("value").toString());
        component.set("v.columns", columns);

        if(component.get('v.objCont') !=null){
            console.log('objCont :: ',component.get('v.objCont'));
            component.set('v.RCVRName',component.get('v.objCont.Name'));
            component.set('v.RCVREmail',component.get('v.objCont.Email'));
        }
        if(component.get('v.orderStatus') != null){
            console.log('Ex_SuppliesQuoteList 1>> ' +  component.get('v.orderStatus'));
        }
        //todo 생성이력 이슈 확인 - 확인 후 지우기
        // component.set('v.listSelectRows', []);

        let testOptions = [
            {'label' : '견적서', 'value':'견적서'},
            {'label' : '명세서', 'value':'명세서'},
            {'label' : '사업자등록증', 'value':'사업자등록증'},
            {'label' : '통장사본', 'value':'통장사본'}
        ];
        component.set('v.options', testOptions);
        console.log('component.get(v.options) >> ' + component.get('v.options'));
        // if( component.get('v.orderStatus') =='배송중'||component.get('v.orderStatus') =='배송완료'){
        
        //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)
        if( component.get('v.isSpecificationValid')){
                let testOptions = [
                    {'label' : '견적서', 'value':'견적서'},
                    {'label' : '명세서', 'value':'명세서'},
                    {'label' : '사업자등록증', 'value':'사업자등록증'},
                    {'label' : '통장사본', 'value':'통장사본'}
                ];
                component.set('v.options', testOptions);
                console.log('component.get(v.options) >> ' + component.get('v.options'));
                component.set('v.isSpecificationChecked',true);
                console.log('isSpecificationChecked ::: ',component.get('v.isSpecificationChecked'));
                let testValue = ["명세서"];
                component.set('v.value', testValue);
        } else {
                let testOptions = [
                    {'label' : '견적서', 'value':'견적서'},
//                    {'label' : '명세서', 'value':'명세서'},
                    {'label' : '사업자등록증', 'value':'사업자등록증'},
                    {'label' : '통장사본', 'value':'통장사본'}
                ];
                component.set('v.options', testOptions);
                console.log('component.get(v.options) >> ' + component.get('v.options'));
                component.set('v.isSpecificationChecked',false);
                console.log('isSpecificationChecked ::: ',component.get('v.isSpecificationChecked'));
                let testValue = ["견적서"];
                component.set('v.value', testValue);
        }

        // 2023.08.15 PHJ
        if(component.get('v.value') != '견적서'){
            component.set('v.disabledNote', true);
        }

        console.log ( 'contact ID !! :: ',component.get('v.contactId'));

        //23 09 04 hyungho.chun 명세서 주소 부르는 기준 contact에서 pr으로 바꿈
        // if(component.get('v.contactId') != null){
        //     helper.doGetContactInfoByContactId(component, event, helper);
        //     console.log('contactAddress :: ',component.get('v.contactAddress'));
        // }
        if(component.get('v.orderNumber') != null){
            console.log('orderNumber is not null @@@@@');
            console.log(component.get('v.orderNumber'));
            helper.doGetAddressByOrderNumber(component, event, helper);
        }
        console.log('By the end of the fnInit orderNumber :: ',component.get('v.orderNumber'));
        
    },

    suppliesDocPreview : function(component, event, helper) {
        console.log('v.objCont :: ',component.get('v.objCont'));
        console.log('v.objCont.Name :: ',component.get('v.objCont.Name'));
        console.log('v.RCVRName ::',component.get('v.RCVRName'));

        console.log('component.get("v.orderNumber") >> '+component.get("v.orderNumber"));
        console.log('component.get(v.value) :: '+ component.get('v.value'));
        console.log('Ex_SuppliesQuoteList 의 SuppliesDocPreview');
        console.log('component.get(v.isEmployee)  : '+component.get('v.isEmployee'));
        console.log('component.get(v.discountType)  : '+component.get('v.discountType'));
        console.log('component.get(v.stdOrderTotalDiscountAmount)  : '+component.get('v.stdOrderTotalDiscountAmount'));


        //2023-07-12 gw.lee
        //pdf생성 이미 생성되어있는 경우, 상관없이 처리
        // if(component.get('v.documentId')!=''){
        //     helper.showToast('error','이미 생성된 pdf입니다');
        //     return;
        // }
        if(!component.get("v.RCVRName")){
                helper.showToast('error','수신자명을 입력해주세요');
                return;
            }
        if(!component.get("v.RCVREmail")){
            helper.showToast('error','수신자 이메일을 입력해주세요');
            return;
        }

        // PHJ
        var pattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if(!component.get("v.RCVREmail").match(pattern)){
            helper.showToast('error','수신자 이메일 형식을 확인해주세요');
            return;
        }

        //23.09.03 PHJ
        let optionVal = component.get('v.value');
        if(optionVal.includes('견적서') != true && optionVal.includes('명세서') != true){
            helper.showToast('warning','견적서/명세서 중 1개를 체크하셔야 합니다.');
            return;
        } 

        //23.09.12 PHJ
        component.set("v.showSpinner", true);

        $A.createComponent(

            "c:EX_DocPreview",
            {
                IsPrint : component.get('v.IsPrint'),
                latePayment : component.get('v.latePayment'),
                listSelectRows : component.get("v.objSelected"),
                standardOrderData : component.get("v.standardOrderData"),
                soldOutOrderData : component.get("v.soldOutOrderData"),
                orderNumber : component.get("v.orderNumber"),
                RCVRName : component.get("v.RCVRName"),
                contactId : component.get("v.contactId"),

                //23 09 02 hyungho.chun 주소 받기
                contactAddress :  component.get('v.contactAddress'),
                
                documentId : component.getReference("v.documentId"),
                invoiceId : component.getReference("v.invoiceTempId"),
                idList : component.getReference('v.idList'),
                stdConsumableOrderId : component.get('v.stdConsumableOrderId'),
                soldOutConsumableOrderId : component.get('v.soldOutConsumableOrderId'),
                RCVRName : component.get("v.RCVRName"),
                RCVREmail : component.get("v.RCVREmail"),
                Note : component.get('v.Note'),
                value : component.get("v.value"),
                //2023.04.13 
                contactId : component.get('v.contactId'),

                //23 09 02 hyungho.chun 주소 받기
                contactAddress :  component.get('v.contactAddress'),     

                isManagement : component.get('v.isManagement'),
                parentId : component.get('v.parentId'),

                //23.04.27 임직원 할인일 경우 할인금액이 적용된 가격을 견적서에 표시
                isEmployee : component.get('v.isEmployee'),
                discountType : component.get('v.discountType'),
                stdOrderTotalDiscountAmount : component.get('v.stdOrderTotalDiscountAmount')

            },
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log('성공');
                    console.log('doc :' +component.get('v.documentId'));
                    if(component.get('v.documentId')==''){
                        component.set('v.data',null);
                    }
                    component.set("v.modalContent", cmp);

                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                    
                } else if (status === "INCOMPLETE") {
                    console.log('No response from server or client is offline.');
                } else if (status === "ERROR") {
                    console.log('Error :' + errorMessage);
                }
            }
        );


    },

     // 이력보기
        suppliesPDFview : function(component, event, helper) {
//            console.log('선택됨 데이터 : ' + component.get("v.objSelected"));
//            console.log(json.stringify(component.get('v.objectSelected')))
//            console.log('quote'+component.get('v.listSelectRows.Quote_YN'));

            //23.09.12 PHJ
            component.set("v.showSpinner", true);
            //23.09.10 PHJ
            if(component.get('v.listSelectRows')[0] == '' && component.get('v.isAllChk') != false){
                let idx = component.get('v.data').length - 1;
                let defaultSelectRow = component.get('v.data')[idx];
                component.set('v.listSelectRows', defaultSelectRow);
            }



           console.log('suppliesPDFView 이력보기 !!');

           //23.09.03 PHJ
           var listSelectRows = component.get('v.listSelectRows');
           if(listSelectRows[0].id != undefined){
               console.log('is not empty!', component.get('v.listSelectRows'));
               
                $A.createComponent(
                    "c:EX_DocViewer",
                    {
                        selectedQuote   :  listSelectRows[0].Quote_YN,
                        selectedInvoice :  listSelectRows[0].Invoice_YN,
                        selectedBank    :  listSelectRows[0].BankBookCopy_YN,
                        selectedRegi    :  listSelectRows[0].Business_Registration_YN,

                        //23.09.04 PHJ
                        // value : component.get("v.value"),
                        
                        //listSelectRows : component.get("v.objSelected"),
                        listSelectRows : listSelectRows,
                        contactId : component.get("v.contactId"),

                        //23 09 02 hyungho.chun 주소 받기
                        contactAddress :  component.get('v.contactAddress'),

                        stdConsumableOrderId : component.get('v.stdConsumableOrderId'),
                        soldOutConsumableOrderId : component.get('v.soldOutConsumableOrderId'),

                        //2023.04.17
                        RCVRName : component.get("v.RCVRName"),
                        RCVREmail : component.get("v.RCVREmail"),
                        isManagement : component.get('v.isManagement'),
                        parentId : component.get('v.parentId'),
                        orderNumber : component.get('v.orderNumber'),

                        //23.04.29 추가
                        quoteHistoryId : listSelectRows[0].id,

                    },
                    function (cmp, status, errorMessage) {
                        if (status === "SUCCESS") {
                            console.log('성공');

                            component.set("v.modalContent", cmp);
                            component.set('v.objSelected',null);
    //                        helper.fnSetHistoryData(component , event, helper);

    //                        helper.fnGetOrderData(component , event, helper);
                            // var body = component.get("v.modalContent");
                            // body.push(newComponent);
                            // component.set("v.modalContent", body);

                            //23.09.12 PHJ
                            component.set("v.showSpinner", false);
                        } else if (status === "INCOMPLETE") {
                            console.log('No response from server or client is offline.');
                        } else if (status === "ERROR") {
                            console.log('Error :' + errorMessage);
                            component.set("v.showSpinner", false);
                        }
                    }
                );
            } else {
                component.set("v.showSpinner", false);
                return helper.showToast('info','조회할 이력을 선택해주세요');
            }


//            if(component.get("v.objSelected")==null){
//                return helper.showToast('error','조회할 이력을 선택해주세요');
//            }
//            if(component.get('v.documentId')== null && component.get('v.listSelectRows.Quote_YN')=='Y'){
//                return helper.showToast('error','견적서가 생성되지 않았습니다.');
//
//            }
//            if(component.get('v.invoiceId') == null && component.get('v.listSelectRows.Invoice_YN')=='Y'){
//                return helper.showToast('error','명세서가 생성되지 않았습니다.');
//
//            }

            console.log('suppliesPDFView 이력보기 에서 CreateComponent!!');
            console.log('component.get(v.stdConsumableOrderId) ' + component.get('v.stdConsumableOrderId'));
            console.log('component.get(v.soldOutConsumableOrderId) ' +component.get('v.soldOutConsumableOrderId'));
            console.log('0512 test');
            console.log('component.get(v.orderNumber) :: ' + component.get('v.orderNumber'));

        },

//아래는 기존것
//    // 이력보기
//    suppliesPDFview : function(component, event, helper) {
//        console.log('선택됨 데이터 : ' + component.get("v.objSelected"));
//        console.log(json.stringify(component.get('v.objectSelected')))
//        console.log('quote'+component.get('v.listSelectRows.Quote_YN'));
//
//
//        if(component.get("v.objSelected")==null){
//            return helper.showToast('error','조회할 이력을 선택해주세요');
//        }
//        if(component.get('v.documentId')== null && component.get('v.listSelectRows.Quote_YN')=='Y'){
//            return helper.showToast('error','견적서가 생성되지 않았습니다.');
//
//        }
//        if(component.get('v.invoiceId') == null && component.get('v.listSelectRows.Invoice_YN')=='Y'){
//            return helper.showToast('error','명세서가 생성되지 않았습니다.');
//
//        }
//
//        $A.createComponent(
//            "c:EX_DocViewer",
//            {
//                selectedQuote :  component.get('v.listSelectRows.Quote_YN'),
//                selectedInvoice :  component.get('v.listSelectRows.Invoice_YN'),
//                selectedBank :  component.get('v.listSelectRows.BankBookCopy_YN__c'),
//                selectedRegi :  component.get('v.listSelectRows.Business_Registration_YN__c'),
//                value : component.get("v.value"),
//                listSelectRows : component.get("v.objSelected"),
//                contactId : component.get("v.contactId"),
//                stdConsumableOrderId : component.get('v.stdConsumableOrderId'),
//                soldOutConsumableOrderId : component.get('v.soldOutConsumableOrderId'),
//
//                //2023.04.17
//                RCVRName : component.get("v.RCVRName"),
//                RCVREmail : component.get("v.RCVREmail"),
//                isManagement : component.get('v.isManagement'),
//                parentId : component.get('v.parentId'),
//                orderNumber : component.get('v.orderNumber'),
//                ////
//
//            },
//            function (cmp, status, errorMessage) {
//                if (status === "SUCCESS") {
//                    console.log('성공');
//                    component.set("v.modalContent", cmp);
//                    // var body = component.get("v.modalContent");
//                    // body.push(newComponent);
//                    // component.set("v.modalContent", body);
//                } else if (status === "INCOMPLETE") {
//                    console.log('No response from server or client is offline.');
//                } else if (status === "ERROR") {
//                    console.log('Error :' + errorMessage);
//                }
//            }
//        );
//    },

    sendPDF : function(component, event, helper) {
//        console.log('dco : '+component.get('v.documentId'));
//        console.log('invoice id :: ', component.get('v.invoiceTempId'));
        //helper.sendPDF(component);

        //23.09.03 PHJ
        if(component.get('v.listSelectRows')[0] == '' && component.get('v.isAllChk') != false){
            let idx = component.get('v.data').length - 1;
            let defaultSelectRow = component.get('v.data')[idx];
            component.set('v.listSelectRows', defaultSelectRow);
        }

        var listSelectRows = component.get('v.listSelectRows');
        console.log('Ex_SuppliesQuoteList 의 sendPDF ! ');
        console.log('listSelectRows : ', listSelectRows );
        
        if(listSelectRows!=null){
            helper.sendPDF(component);
        } else {
            console.log('listSelectelows 는 null');
            return helper.showToast('info','이력을 선택하세요.');
        }

    },

    // 주문번호와 seq를 가져가서 견적서및 이미지 뽑는방식 일단은 seq만
    fnHandleRowAction : function(component, event, helper) {
        console.log('fnHandleRowAction !');
        var action = event.getParam('action');

        console.log(action.name);
        console.log('row -> ' + row);
        console.log(JSON.stringify(row));
        console.log('선택됨');

        console.log('selectedRows :: ' + JSON.stringify(row));

        if(isEmpty(row)){
            helper.showToast('error','조회할 항목을 선택하세요');
            return;
        }


    },

    fnSelected: function (component, event, helper) {
        let selectedRows = event.getParam('selectedRows')
;
        console.log('sel : ' +selectedRows);
        component.set('v.listSelectRows',selectedRows);

        //23.04.29 지은추가
        console.log('생성 이력 fnselected !!');
        console.log()

        //아래는 기존것
//        console.log( 'JSON.stringify(selectedRows)  :: '+ JSON.stringify(selectedRows));
//         component.set('v.listSelectRows',selectedRows[0]);
//         console.log('component.get('v.listSelectRows.Quote_YN')' +component.get('v.listSelectRows.Quote_YN'));
//        component.set("v.objSelected", selectedRows[0]);
    },

    handleValueChange : function (component, event, helper) {
        if(component.get('v.isManagement')){
            helper.fnGetOrderData(component, event, helper);
        }else{
            helper.fnSetHistoryData(component, event, helper);
        }
    },
    fnCancel : function (component, event, helper) {
        component.destroy();
    },
    onWijmoMessage: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        
        switch (payload.type) {
            case 'rowSelection':
                component.set("v.selectedList", payload.selectedRows);
                
                //23.09.07 PHJ
                if(payload._isAllChecked == false){
                    component.set('v.createSuccessView', false);
                    component.set('v.createSuccessSend', false);
                    component.set('v.isAllChk', false);
                }
                else{
                    component.set('v.isAllChk', true);
                    component.set("v.listSelectRows", payload.selectedRows[0]); 
                }
                console.log('isAllChk', component.get('v.isAllChk'));
                
                //23.09.02 PHJ
                if(payload.selectedRows.length == 0){
                    console.log('no row');
                    component.set('v.listSelectRows', '');
                }

                // 23.09.03 PHJ
                console.log('v.selectedRows[0] :::'+  payload.selectedRows[0]);
                if(payload.selectedRows[0] != undefined) {
                    component.set("v.listSelectRows", payload.selectedRows[0]); 
                }
                else{
                    if(component.get('v.lastChkVal') == 0){
                        let idx = component.get('v.data').length - 1;
                        let defaultSelectRow = component.get('v.data')[idx];
                        component.set('v.listSelectRows', defaultSelectRow);
                        component.set('v.lastChkVal', 1);
                    }
                }

                break;
            case 'dblclick':
                component.set("v.selectedList", payload.item);
                component.set("v.listSelectRows", payload.item);
                break;
            case 'refresh':
                console.log('payload.item :'+payload.items);
                component.set('v.data',payload.items);
                console.log('초기화');
                break;
        }
    },


    //23 09 02 hyungho.chun 명세서 체크할때마다 변동
    isSpecificationCheckedChange: function (component, event, helper){
        console.log('v.value : ',component.get('v.value'));
        var pickedOptions = component.get('v.value');
        var SpecificationChecked = false;
        pickedOptions.forEach((element) =>{
            console.log('element ::',element);
            if(element == '명세서'){
                SpecificationChecked = true;
            }
        });
        component.set('v.isSpecificationChecked',SpecificationChecked);

        // if(component.get('v.isSpecificationChecked')){
        //     component.set('v.isSpecificationChecked',false);
        //     console.log('isSpecificationChecked ::: ',component.get('v.isSpecificationChecked'));
        // }else{
        //     component.set('v.isSpecificationChecked',true);
        //     console.log('isSpecificationChecked ::: ',component.get('v.isSpecificationChecked'));
        // }
    }
});