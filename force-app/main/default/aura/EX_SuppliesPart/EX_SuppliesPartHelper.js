/**
 * Created by I2MAX.SEOKHOLEE on 2022/12/25.
 */

({

    getContactInfo: function (component, recordId) {
        var action = component.get("c.doGetContactInfoByCaseId");
        if(recordId == null){
            recordId = component.get('v.contactId');
        }
        action.setParams({
            "strCaseId": recordId
        });
        console.log('getContactInfo Start!');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var resultMap = response.getReturnValue();
                var result = resultMap.objCon;
                var evt = $A.get("e.c:EX_SuppliesPartContact_evt");
                if (result) {
                    var isContactSame = component.get("v.isContactSame");


                    component.set('v.ContactVIP',resultMap.contactVIP);
                    // component.set("v.isFromCase", true);

                    // 수취인 정보 set (checkbox default true)
                    console.log(JSON.stringify(result));
                    if (result.Name) component.set("v.consigneeName", isContactSame ? result.Name : null);
                    if (result.Phone) component.set("v.IbCallNo", isContactSame ? result.MobilePhone : null);

                    //23.10.31 PHJ
                    if(result.Cases != null) component.set("v.isFromCase2", true);

                    // if (result.ADDRESS_NEW__c) component.set("v.newAddress", isContactSame ? result.ADDRESS_NEW__c : null);
                    // if (result.ADDRESS_OLD__c) component.set("v.oldAddress", result.ADDRESS_OLD__c);
                    if (result.ADDRESS_NEW__c) component.set("v.newAddress", isContactSame ? result.fm_ADDRESS_NEW__c : null);
                    else component.set('v.newAddress', null);
                    if (result.ADDRESS_OLD__c) {
                        component.set("v.oldAddress", isContactSame ? result.fm_ADDRESS_OLD__c : null);
                        // 23.02.01 추가
                        if (component.get('v.newAddress') == null) {
                            component.set('v.newAddress', result.fm_ADDRESS_OLD__c);
                        }
                    }
                    if (result.ADDRESS_DETAIL__c) component.set("v.detailAddress", isContactSame ? result.ADDRESS_DETAIL__c : null);
                    if (result.POSTAL_CODE__c) component.set("v.zoneCode", result.POSTAL_CODE__c);
                    if (result.LATITUDE__c) component.set("v.latitude", result.LATITUDE__c);
                    if (result.LONGITUDE__c) component.set("v.longitude", result.LONGITUDE__c);
                    component.set("v.contactId", result.Id);
                    component.set("v.objCont", result);
                    component.set("v.objCase", result.Cases[0]);
                    component.set("v.caseNumber", result.Cases[0].CaseNumber);
                    // 2023.09.20 seung yoon heo Case에 Description을 TRANSFER_REASON2__c로 변경
                    // component.set('v.caseDescription', result.Cases[0].Description);
                    // 23.09.22 PHJ null 제거
                    // 24.01.24 seung yoon heo undefined 예외처리
                    component.set('v.caseDescription', result.Cases[0].TRANSFER_REASON2__c != undefined ? (result.Cases[0].TRANSFER_REASON2__c).replace('null','') : '');
                    
                    component.set('v.caseModelId', result.Cases[0].ModelName__c);
                    try {
                        component.set('v.caseModelLabel', result.Cases[0].ModelName__r.Name);
                    } catch (error) {
                        console.log(error);
                    }
                    

                    evt.setParam("contactId", result.Id);
                    evt.setParam("isCreateOrder", false);
                    evt.fire();

                }

        

                // 23.03.23 소모품택배주문 -> 고객조회 전달용 Contact info
                let objCont = component.get("v.objCont");
                component.set('v.IbCallNo_SC', objCont.MobilePhone);
                component.set('v.searchName_SC', objCont.Name);
                //////////////////////////////////////////

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('##########Error!!!!!');
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getContactInfoByContactId: function (component, recordId, isCustomerSearch) {
        var action = component.get("c.doGetContactInfoByContactId");
        var fsContactId = component.get('v.FSContactId');
        var isFsCheck = component.get('v.FSIsMaterialPortal');
        

        var isCusteomrCheck = isCustomerSearch != null ? isCustomerSearch : false;
        var sendContactId;

        //23.07.31 gw.lee
        //자재 포탈에서 넘어 왔을때, Coantct 정보가 없을 경우 현재 검색한 Contact정보를 사용하게끔 변경 처리
        //23.09.16 gw.lee
        //자재 포탈에서 넘어 왔으며, 고객정보를 다시 수정 할 경우 조치
        if (isFsCheck && !isCusteomrCheck) {
            sendContactId = fsContactId ? fsContactId : recordId;
        } else {
            sendContactId = recordId;
        }

        console.log('contact : ' +recordId );
        console.log('contact : ' , JSON.stringify(recordId));
        console.log('fsContactId : ' + fsContactId);
        console.log('fsContactId : ' , JSON.stringify(fsContactId));
        console.log('sendContactId : ',sendContactId);
        console.log('sendContactId : ',JSON.stringify(sendContactId));

        console.log('typeof sendContactId' , typeof(sendContactId));
        console.log('typeof sendContactId 22 : ' , typeof(typeof(sendContactId)));
        console.log('id !! : ',sendContactId.Id);


        //23 08 21 hyungho.chun  contactId가 object형태로들어는경우 id값만 넣어줌
        if(typeof(sendContactId) == 'object'){
            sendContactId = sendContactId.Id;
        }

        action.setParams({
            "strContactId": sendContactId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state getInitData >>>>>>>  ' + state);


            if (state === "SUCCESS") {

                var resultMap = response.getReturnValue();
                var result = resultMap.objCon;
                console.log(result);
                if (result) {
                    if (isCusteomrCheck) {
                        component.set("v.consertConId", result.Id);
                        component.set("v.consertObjCont", result);
                    }

                    component.set("v.ContactVIP", resultMap.contactVIP);
                    component.set("v.contactId", result.Id);
                    component.set("v.objCont", result);
                    // 230410 케이스 인입 고객에서 고객 검색을 했을 때
                    // 케이스와 다른 고객이라는 정보 알림
                    var objCase = component.get('v.objCase');
                    if (objCase != null && objCase != undefined) {
                        if (objCase.ContactId != null && objCase.ContactId != result.Id) {
                            var toastStr = '상담이력의 고객과 다릅니다.\n상담이력 고객 : ' + objCase.Contact.Name + ', 번호 : ' + objCase.Contact.MobilePhone;
                            this.showToast('error', toastStr);
                        }
                    }

                    console.log('objCase : ' + JSON.stringify(component.get("v.objCase")));
                }

                // 23.03.23 소모품택배주문 -> 고객조회 전달용 Contact info
                let objCont = component.get("v.objCont");
                component.set('v.IbCallNo_SC', objCont.MobilePhone);
                component.set('v.searchName_SC', objCont.Name);
                //////////////////////////////////////////

                // 수취인 정보 set (checkbox default true)
                var isContactSame = component.get("v.isContactSame");
                if (result.Name) component.set("v.consigneeName", isContactSame ? result.Name : null);
                if (result.MobilePhone) component.set("v.IbCallNo", isContactSame ? result.MobilePhone : null);

                if (result.ADDRESS_NEW__c) component.set("v.newAddress", isContactSame ? result.fm_ADDRESS_NEW__c : null);
                else component.set("v.newAddress", null);
                if (result.ADDRESS_OLD__c) {
                    component.set("v.oldAddress", result.fm_ADDRESS_OLD__c);
                    // 23.02.01 추가
                    if (component.get('v.newAddress') == null) {
                        component.set('v.newAddress', result.fm_ADDRESS_OLD__c);
                    }
                }
                if (result.ADDRESS_DETAIL__c) component.set("v.detailAddress", isContactSame ? result.ADDRESS_DETAIL__c : null);
                if (result.POSTAL_CODE__c) component.set("v.zoneCode", result.POSTAL_CODE__c);
                if (result.LATITUDE__c) component.set("v.latitude", result.LATITUDE__c);
                if (result.LONGITUDE__c) component.set("v.longitude", result.LONGITUDE__c);

                // seung yoon heo 1.우선 고객 조회시 고객정보 set
                var evt = $A.get("e.c:EX_SuppliesPartContact_evt");

                evt.setParam("contactId",component.get('v.consertConId') != null || component.get('v.consertConId') != undefined ?component.get('v.consertConId') : component.get('v.contactId'));
                evt.setParam("objCont", component.get('v.consertObjCont') != undefined ? component.get('v.consertObjCont') : component.get('v.objCont'));
                evt.setParam("consigneeName", component.get('v.consigneeName'));
                evt.setParam("IbCallNo", component.get('v.IbCallNo'));
               
                if (component.get('v.newAddress') == null || component.get('v.newAddress') == '') {
                    evt.setParam("newAddress", component.get('v.oldAddress'));
                } else {
                    evt.setParam("newAddress", component.get('v.newAddress'));
                }
                evt.setParam("newAddress", component.get('v.newAddress'));
                evt.setParam("detailAddress", component.get('v.detailAddress'));
                
                // evt.setParam("requestedTerm", component.get('v.requestedTerm'));
                // evt.setParam("remark", component.get('v.remark'));
                evt.setParam("isContactSame", component.get('v.isContactSame'));
                evt.setParam('phoneCol', component.get('v.phoneCol'));
                // evt.setParam('zoneCode', component.get('v.zoneCode'));
                // evt.setParam('managerNote', component.get('v.managerNote'));
                evt.setParam('ContactVIP', resultMap.contactVIP);
                evt.setParam("isCreateOrder", false);
                console.log('ContactVIP : ' + component.get('v.ContactVIP'));
        
                evt.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    gfnChgTelFormat: function (component, event, strTel) {

        var strLen = '';
        var strSetValue = '';

        if (!strTel) return strTel;

        strTel = strTel.replace(/[^0-9]/g, '');
        strLen = String(strTel.length);

        switch (strLen) {
            case '8' :
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4); //"###-####";
                break;

            case '9' :
                strSetValue = strTel.substr(0, 2);
                strSetValue += '-' + strTel.substr(2, 3);
                strSetValue += '-' + strTel.substr(5); //"##-###-####";
                break;

            case '10' :

                if (strTel.substr(0, 2) == "02") {
                    strSetValue = strTel.substr(0, 2);
                    strSetValue += '-' + strTel.substr(2, 4);
                    strSetValue += '-' + strTel.substr(6); //"##-####-####";
                } else {
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 3);
                    strSetValue += '-' + strTel.substr(6); //"###-###-####";
                }
                break;

            case '11':
                //23.11.21 gw.lee
                //사업장일 경우 추가
                if (strTel.substr(0, 3) == '010') {
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 4);
                    strSetValue += '-' + strTel.substr(7); //"###-####-####";
                } else {
                    strSetValue = strTel.substr(0, 4);
                    strSetValue += '-' + strTel.substr(3, 3);
                    strSetValue += '-' + strTel.substr(7); //"####-###-####";
                }
                break;
            case '12':
                //23.11.21 gw.lee
                //12자리일 경우, 추가
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4, 4);
                strSetValue += '-' + strTel.substr(8, 4);
                break;

            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },
    fnContactConsigneeChange: function (component, event, helper) {
        console.log('fnContactConsigneeChange @');
        var workspaceAPI = component.find("workspace");
        var evt = $A.get("e.c:EX_SuppliesConsigneeEvt");

        // 탭이 없는 경우에만 넘기면 됨.
        workspaceAPI.getTabInfo().then(function (response) {
            var isSubTab = response.isSubTab;
            if (!isSubTab) {
                if (Boolean(component.find('sameAddress').get("v.value"))) {
                    evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                    //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                    if(!component.get('v.isFromCase2')){
                        evt.setParam('managerNote',  component.find('managerNote').get("v.value"));
                    }
                    evt.setParam("requestedTerm",  component.find('requestedTerm').get("v.value"));
                    evt.setParam("consigneeName", component.get('v.consigneeName'));
                    evt.setParam("IbCallNo", component.get('v.IbCallNo'));
                    evt.setParam("newAddress", component.get('v.newAddress'));
                    evt.setParam("detailAddress", component.get('v.detailAddress'));
                    evt.setParam('phoneCol', component.get('v.phoneCol'));     

                } else {
                    evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                    evt.setParam("consigneeName", component.find('consigneeName').get("v.value"));
                    evt.setParam("IbCallNo", component.find('IbCallNo').get("v.value"));
                    evt.setParam("newAddress", component.find('newAddress').get("v.value"));
                    evt.setParam("detailAddress", component.find('detailAddress').get("v.value"));
                    evt.setParam('phoneCol', component.get('v.phoneCol'));
                    //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                    if(!component.get('v.isFromCase2')){
                        evt.setParam('managerNote',  component.find('managerNote').get("v.value"));
                    }                         
                    evt.setParam("requestedTerm",  component.find('requestedTerm').get("v.value"));
                    evt.setParam('zoneCode', component.get('v.zoneCode'));
                }
                evt.fire();
            }
        }).catch(function (error) {
            if (Boolean(component.find('sameAddress').get("v.value"))) {
                evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                if(!component.get('v.isFromCase2')){
                    evt.setParam('managerNote',  component.find('managerNote').get("v.value"));
                }
                evt.setParam("requestedTerm",  component.find('requestedTerm').get("v.value"));
                evt.setParam("consigneeName", component.get('v.consigneeName'));
                evt.setParam("IbCallNo", component.get('v.IbCallNo'));
                evt.setParam("newAddress", component.get('v.newAddress'));
                evt.setParam("detailAddress", component.get('v.detailAddress'));
                evt.setParam('phoneCol', component.get('v.phoneCol'));     

            } else {
                evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                evt.setParam("consigneeName", component.find('consigneeName').get("v.value"));
                evt.setParam("IbCallNo", component.find('IbCallNo').get("v.value"));
                evt.setParam("newAddress", component.find('newAddress').get("v.value"));
                evt.setParam("detailAddress", component.find('detailAddress').get("v.value"));
                evt.setParam('phoneCol', component.get('v.phoneCol'));
                //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                if(!component.get('v.isFromCase2')){
                    evt.setParam('managerNote',  component.find('managerNote').get("v.value"));
                }                     
                evt.setParam("requestedTerm",  component.find('requestedTerm').get("v.value"));
                evt.setParam('zoneCode', component.get('v.zoneCode'));
            }
            // evt.setParam('contactId', component.get('v.contactId') != undefined ? component.get('v.contactId') : '');
            // evt.setParam('consigneeName', component.get('v.consigneeName') != undefined ? component.get('v.consigneeName') : '');
            // evt.setParam('IbCallNo', component.get('v.IbCallNo') != undefined ? component.get('v.IbCallNo') : '');
            // evt.setParam('newAddress', component.get('v.newAddress') != undefined ? component.get('v.newAddress') : '');
            // evt.setParam('detailAddress', component.get('v.detailAddress') != undefined ? component.get('v.detailAddress') : '');
            // evt.setParam('requestedTerm', component.get('v.requestedTerm') != undefined ? component.get('v.requestedTerm') : '');
            // evt.setParam('remark', component.get('v.remark') != undefined ? component.get('v.remark') : '');
            // evt.setParam('isContactSame', component.get('v.isContactSame'));
            // evt.setParam('phoneCol', component.get('v.phoneCol') != undefined ? component.get('v.phoneCol') : '');
            // evt.setParam('managerNote', component.get('v.managerNote') != undefined ? component.get('v.managerNote') : '');
            // evt.setParam('ContactVIP', component.get('v.ContactVIP') != undefined ? component.get('v.ContactVIP') : 0);
           
            evt.fire();
        });

       
    },

    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    },
    // fnGetContactVIP : function (component, event, helper, contactId) {

    //     var action = component.get('c.doGetContactVIP');
    //     console.log('contactId :  ' + contactId);
    //      action.setParams({
    //          'contactId': contactId
    //      });
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('result >>> ' + result);
    //             if(result!=null)
    //                 component.set('v.ContactVIP',result);

    //         } else {

    //         }


    //     });
    //     $A.enqueueAction(action);
    // },
});