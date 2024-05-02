/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-02.
 */
({
    fnSetHistoryData : function(component , event, helper){
            component.set("v.listSelectRows", []);
            component.set("v.data", []);

            //23.09.12 PHJ
            component.set("v.showSpinner", true);

            let action =component.get("c.getHistoryData");
            var params = {
                            orderNumber : component.get('v.orderNumber'),
                          contactId : component.get('v.contactId'),
                          stdConsumableOrderId : component.get('v.stdConsumableOrderId'),
                          soldOutConsumableOrderId : component.get('v.soldOutConsumableOrderId')
                    };
                    action.setParams({
                        'paramMap' : params
                    });
            action.setCallback(this, function(response){
                let state = response.getState();
                console.log('state :: ' + state);
                if(state === "SUCCESS"){
                    let result = response.getReturnValue();
                    console.log('get returnValue' , response.getReturnValue());
                    component.set("v.data", result.listResult);
                    this.sendMessage(component, {type:'items', items: component.get('v.data')});

                    // ho 
                    this.sendMessage(component, {type:'singlechekcedData', items: component.get('v.data')});
                    component.set("v.RCVREmail", '');
                    component.set("v.Note", '');
                    
                    if(result.contactEmail && component.get('v.RCVREmail') == null){
                        component.set('v.RCVREmail', result.contactName);
                    }

                    if(component.get("v.data").length == 0){
                        component.set("v.emptyData", true);
                    } else {
                        component.set("v.emptyData", false);
                    }

                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                } else if (state === "ERROR"){
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.showToast("error", errors[0].message);
                        }
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);

        },
      sendPDF:function(component, event, helper){
            //현재는 생성이력에서 선택 후 이메일 발송 처리
            //            if(component.get('v.documentId')==''){
            //                return this.showToast('error','견적서가 생성되지 않았습니다');
            //            }
            
            //23.09.12 PHJ
            component.set("v.showSpinner", true);

            console.log(component.get("v.RCVRName") + '이름')
            console.log(component.get("v.RCVREmail") + '메일')
            if(component.get("v.RCVRName")=='' && component.get("v.value") == null){
                component.set("v.showSpinner", false);
                this.showToast('error','수신자명을 입력해주세요');
                return;
            }
            if(component.get("v.RCVREmail")=='' && component.get("v.value") == null){
                component.set("v.showSpinner", false);
                this.showToast('error','수신자 이메일을 입력해주세요');
                return;
            }
            console.log('sendPDF orderNumber > ', component.get('v.orderNumber'));
            console.log('sendPDF isManagement) > ',  component.get('v.isManagement'));
            console.log(' component.get(v.listSelectRows)[0].id  :' +  component.get('v.listSelectRows')[0].id);
            
            //23.09.02 PHJ
            if(component.get('v.listSelectRows')[0].id == undefined){
                component.set("v.showSpinner", false);
                this.showToast('warning','발송할 견적을 선택해주세요');
                return;
            }

            var action = component.get("c.doSendPDF");
            var params ={
//                 documentId :component.get('v.documentId'),
//                 invoiceTempId :component.get("v.invoiceTempId"),
                 contactId :component.get('v.contactId'),
                 value : JSON.stringify(component.get('v.value')) ,
                 RCVRName : component.get("v.RCVRName"),
                 RCVREmail : component.get("v.RCVREmail"),
                 stdConsumableOrderId : component.get('v.stdConsumableOrderId'),
                 soldOutConsumableOrderId : component.get('v.soldOutConsumableOrderId'),
                 Note : component.get('v.Note'),
                 orderNumber : component.get('v.orderNumber'),
                 isManagement : component.get('v.isManagement'),

                 historyId : component.get('v.listSelectRows')[0].id,
            };
            action.setParams({
                paramMap : params
             });
             action.setCallback(this, function(response) {
                             console.log('end-------------------------------');

                var sState = response.getState();
                if(sState === "SUCCESS") {
                    //23.12.06 gw.lee
                    //메일 발송 금지 셋팅으로 인한 행걸림 방지
                    if (response.getReturnValue() == 'Exception') {
                        this.showToast('warning','이메일 발송이 불가하도록 설정된 상태입니다.');
                        //23.09.12 PHJ
                        component.set("v.showSpinner", false);
                    } else if (response.getReturnValue() == 'Validation') {
                        //23.09.12 PHJ
                        component.set("v.showSpinner", false);
                        return this.showToast('warning','전송이 불가능한 이메일 주소입니다.');
                    } else {
                        this.showToast('success','메일이 발송되었습니다.');
                        component.set('v.documentId','');
                        component.set("v.listSelectRows", []);
                        component.set('v.objSelected',null);
                        //23.09.11 PHJ datatable 관련 현재 사용 x
                        // component.find("orderListDt").set("v.selectedRows", []);
    
                        this.fnSetHistoryData(component, event, helper);
                        this.fnGetOrderData(component , event, helper);
                        //23.09.12 PHJ
                        component.set("v.showSpinner", false);
                    }
                }
                else if(sState === "ERROR") {
                    var errors = response.getError();
                    console.log(JSON.stringify(errors));
                    console.table(errors);
                    self.gfnShowToast("error", errors[0].message);
                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                }
                else {
                    self.gfnShowToast("error", "System Error.");
                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
        },
        fnGetOrderData : function(component , event, helper){

            //23.09.12 PHJ
            component.set("v.showSpinner", true);

            let action =component.get("c.getOrderDataList");
            console.log('orderNumber : ' + component.get('v.orderNumber'));
            var params = {
                          orderNumber : component.get('v.orderNumber'),
                    };
                    action.setParams({
                        'paramMap' : params
//                           'orderNumber' :  params['orderNumber']
                    })


            console.log('params :: ' + params);
            action.setCallback(this, function(response){
                let state = response.getState();
                console.log('state :: ' + state);
                if(state === "SUCCESS"){
                    component.set('v.RCVREmail', '');
                    component.set('v.Note', '');
                    
                    let result = response.getReturnValue();
                    console.log('YEEEEE!!');
                    console.log(result.listResult);
                    

                    component.set("v.data", result.listResult);
                    this.sendMessage(component, {type:'items', items: component.get('v.data')});

                    //23.08.17 PHJ
                    this.sendMessage(component, {type:'singlechekcedData', items: component.get('v.data')});

                    if(component.get("v.data").length == 0){
                        component.set("v.emptyData", true);
                    } else {
                        component.set("v.emptyData", false);
                    }

                    //23.09.12 PHJ
            component.set("v.showSpinner", false);
                } else if (state === "ERROR"){
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.showToast("error", errors[0].message);
                        }
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                    //23.09.12 PHJ
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);


        },
            showToast : function(type, message) {
                var evt = $A.get("e.force:showToast");
                evt.setParams({
                    key     : "info_alt",
                    type    : type,
                    message : message
                });
                evt.fire();
            },
    sendMessage: function(component, msg) {
        console.log('위즈모');
        component.find('wijmo_EXSuppliesQuoteList').message(msg);
    },

    
    //23 09 02 hyungho.chun 견적서/명세서팝업 주소 자동기입
    doGetContactInfoByContactId: function(component , event, helper){
        let action = component.get("c.doGetContactInfoByContactId");
        console.log ( 'contact ID !!(at Helper) :: ',component.get('v.contactId'));

        action.setParams({
            'strContactId' : component.get('v.contactId')
        })


        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('state :: ' + state);
            if(state === "SUCCESS"){
                let result = response.getReturnValue();
                console.log('result ::: ',result);
                if(result.ADDRESS_NEW__c != null && result.ADDRESS_NEW__c != ''){
                    component.set('v.contactAddress',result.ADDRESS_NEW__c);
                }else if(result.ADDRESS_OLD__c != null && result.ADDRESS_OLD__c != ''){
                    component.set('v.contactAddress',result.ADDRESS_OLD__c);
                }else{
                    component.set('v.contactAddress','');
                }
            } else if (state === "ERROR"){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        

    },

    //23 09 04 hyungho.chun 견적서/명세서 팝업 주소 자동기입
    doGetAddressByOrderNumber: function(component , event, helper){
        let action = component.get("c.getAddressByOrderNumber");
        console.log ( 'getAddressByOrderNumber !!(at Helper) :: ',component.get('v.orderNumber'));

        action.setParams({
            'OrderNumber' : component.get('v.orderNumber')
        })


        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('state :: ' + state);
            if(state === "SUCCESS"){
                let result = response.getReturnValue();
                console.log('result ::: ',result);
                component.set('v.contactAddress',result);
            } else if (state === "ERROR"){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        

    },
});