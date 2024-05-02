/**
 * Created by I2MAX.SEOKHOLEE on 2022/12/25.
 */

({
    fnInit: function (component, event, helper) {

        //23 09 08 hyungho.chun serviceResource 상위 컴포넌트에서 받는거로 수정
        // var action = component.get('c.doGetServiceResource');
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     if (state === 'SUCCESS') {
        //         var result = response.getReturnValue();
        //         component.set('v.isCNSL', result=='CNSL');
        //         console.log('visCnsl : ' + component.get('v.isCNSL'));
        //     }
        // });

        // $A.enqueueAction(action);




//        var hostname = window.location.hostname;
//        console.log('hn : ' + hostname);
//
//        var vfHost = hostname.split(".")[0] + "--c.sandbox.vf.force.com";
//        component.set("v.vfHost", vfHost);
//
//        window.addEventListener("message", function(event) {
//           console.log('event data : ' + JSON.stringify(event.data));
//           if (event.data.target === 'DAUMADDR') {
//               switch(event.data.userSelectedType) {
//                   case "R":
//                       var roadAddress = event.data.roadAddress;
//                       roadAddress += (event.data.buildingName === "" ? "" : (" (" + event.data.buildingName + ")"));
//
//                       component.set("v.newAddress", roadAddress);
//                       var address = component.get('v.productRequest').CONSIGNEE_Address__c;
//                       address = roadAddress;
//                       var addressDetail = component.get('v.productRequest').CONSIGNEE_Address_DETAIL__c;
//                       addressDetail = '';
//
//                       component.set('v.productRequest.CONSIGNEE_Address__c', address);
//                       component.set('v.productRequest.CONSIGNEE_Address_DETAIL__c', addressDetail);
//                       break;
//                   case "J":
//                       component.set("v.newAddress", event.data.jibunAddress);
//                       var address = component.get('v.productRequest').CONSIGNEE_Address__c;
//                       address = event.data.jibunAddress;
//
//                       var addressDetail = component.get('v.productRequest').CONSIGNEE_Address_DETAIL__c;
//                       addressDetail = '';
//
//                       component.set('v.productRequest.CONSIGNEE_Address__c', address);
//                       component.set('v.productRequest.CONSIGNEE_Address_DETAIL__c', addressDetail);
//
//                       break;
//               }
//           }
//
//
//        });

    },

    fnGetOrderData: function (component, event, helper) {
        console.log('TTTTTTTTTTTTTTTTTTTTTTTT');
        var selectedRows = event.getParam('data');
        console.log('selectedRows[0].OrderNumber');
        console.log(selectedRows[0].OrderNumber);
        component.set('v.consumableOrderNumber', selectedRows[0].OrderNumber);
        var lightningCard = component.find('cardTitle');
        lightningCard.set('v.label', '주문 번호 : ' + selectedRows[0].OrderNumber);


    },

    getOrderLineItemData: function (component, event, helper) {
        var consumableOrderNumber = component.get('v.consumableOrderNumber');
        console.log('getOrderLineItemData : ' + consumableOrderNumber);
        if (consumableOrderNumber == null || consumableOrderNumber == undefined) return;
        helper.fnOrderLineItemData(component, event, helper);
    },

    fnSave: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var isConsigneeNameValid = component.get('v.isConsigneeNameValid');
        var isConsigneePhoneValid = component.get('v.isConsigneePhoneValid');

        var appendRemark = component.get('v.appendRemark');

        if(!isConsigneeNameValid || !isConsigneePhoneValid) {
            helper.showToast('warning', '수취인 명과 수취인 번호가 유효하지 않습니다.');
            component.set('v.showSpinner', false);
            return;
        }

        var productRequest = component.get('v.productRequest');
        //24.01.31 gw.lee
        //수취인 상세주소 값이 없을 경우, "( )" 자동 표기 추가 => CJ인터페이스 필수값
        if (!productRequest.CONSIGNEE_Address_DETAIL__c) {
            productRequest.CONSIGNEE_Address_DETAIL__c = '( )';
        }

        var action = component.get('c.doUpdateConsumableOrderData');

        action.setParams({
            'productRequest': productRequest,
            'appendRemark' : appendRemark

        });

        action.setCallback(this, function (response) {

            console.log('fnSave!!!');
            console.log('1');


            var state = response.getState();

            if((response.getReturnValue()['caseUpdateFail']!=null)){
                    helper.showToast('warning', '상담이력 : '+response.getReturnValue()['caseUpdateFail'] );
                    console.log('2');
                    component.set('v.showSpinner', false);
            }


            if (state === "SUCCESS") {
                console.log('6123');
                var result = response.getReturnValue();
                console.log('6123dd' , JSON.stringify(result));                
                console.log('6123ddresult.resultState' , result.resultState);                
                if(result['isSuccess']) {
                    helper.showToast('success', '소모품 주문이 성공적으로 수정 되었습니다');
                    component.set('v.showSpinner', false);
                    component.set('v.appendRemark', '');
                    helper.fnOrderLineItemData(component, event, helper);
                      console.log('8');
                      
                    //23 12 06 hyungho.chun isSuccess false인경우 추가
                }else{
                        helper.showToast("error", result['resultMessage']);
                        component.set('v.showSpinner', false);
                        component.set('v.appendRemark', '');
                        console.log('61');
                }
 
                //23 12 06 hyungho.chun resultState안받고 전부 isSuccess로만 체크하게 컨트롤러에 수정함
                // if(result.resultState == 'ERROR') {
                //     helper.showToast("error", result.resultMessage);
                //     component.set('v.showSpinner', false);
                //     console.log('61');
                // }else if (result.resultState != 'ERROR' && result['isSuccess']) {
                //     helper.showToast("error", "Unknown error");
                //     component.set('v.showSpinner', false);
                //      console.log('6');
               
                // } 
                    

            } else {
                console.log('64124');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                    console.log('2');

                } else {
                    helper.showToast("error", "Unknown error");
                    console.log('5');
                }
            }
            component.set('v.showSpinner', false);
        });
                      console.log('7');

        $A.enqueueAction(action);

    },

    fnInitialize: function (component, event, helper) {
        // 데이터 초기화
        component.set('v.consumableOrderNumber', null);
        component.set('v.productRequest', null);
        component.set('v.parent', null);
        component.set('v.objCase', null);
        component.set('v.productRequestDescription', null);
        var lightningCard = component.find('cardTitle');
        lightningCard.set('v.title', '주문 번호');

        var serviceResource = event.getParam('serviceResource');
        component.set('v.serviceResource', serviceResource);
        if(serviceResource == 'CNSL'){
            component.set('v.isCNSL', true);
        }

    },

//주소검색 모듈 => 현재는 사용 하지 않음
//     fnAddressSearch: function (component) {
//         console.log('fnAddressSearch start');
//         var vfOrigin = "https://" + component.get("v.vfHost");
//         var vfWindow = component.find("vfFrame").getElement().contentWindow;
//         var data = {
//             target: "DAUMAPICALL"
//         };
//         vfWindow.postMessage(data, vfOrigin);
//     },

    fnSearch : function(component, event, helper){
            console.log(' 주소 검색 ');

            $A.createComponent(
                "c:SC_Address",
                {
                    "confirmType" : 'confirm'
                    , "strSearchAddr" : ''
                },
                function(newComponent, status, errorMessage) {
                    if (component.isValid()) {
                        if(status ==="SUCCESS") {
                            component.set("v.modalContent", []);
                            var body = component.get("v.modalContent");
                            body.push(newComponent);
                            component.set("v.modalContent", body);
                        } else {
                            console.log('Error :'  + status + ' /' + errorMessage);
                        }
                    }
                }
            );
        },

        fnGetAddress : function(component, event){

            let strUniqueId = component.get("v.strUniqueId");
            let strTargetId = event.getParam('strUniqueId');
            console.log('주소 이벤트 받음 !');
            console.log('strUniqueId :: ' + strUniqueId + ' / strUniqueId  :: '  +strUniqueId);
                //zip id로 검색 해도 될듯?
                let objData = event.getParam('objData');
                let selectedRows = objData.selectedRows;
                console.log(selectedRows);
                console.log(JSON.stringify(selectedRows));

                // let objContact = component.get("v.objContact");
                // objContact.ADDRESS_NEW__c = selectedRows.newAddr;
                // objContact.ADDRESS_OLD__c = selectedRows.oldAddr;
                // objContact.ADDRESS_DETAIL__c = selectedRows.NADR3S;
                // objContact.LATITUDE__c = selectedRows.LATITUDE__c;
                // objContact.LONGITUDE__c = selectedRows.LONGITUDE__c;
                // objContact.POSTAL_CODE__c = selectedRows.ZIPB;
                // objContact.NNMZ = selectedRows.NNMZ;//NNMZ 230321
                // objContact.ADDRESS_REFINE_YN__c = selectedRows.isRefine; // 230425 추가
                // objContact.ADDRESS_ROAD_ETC__c = selectedRows.ADDRESS_ROAD_ETC__c; // 230425 추가
                //
                // /* 수지원넷 api사용이 아닌 데이터내 조회시 들어가는 필드 */
                // objContact.SM_ZIP__c = selectedRows.Id;
                // objContact.ZIP_ID__c = String(selectedRows.ZIP_ID__c);


                //2024.03.11 seung yoon heo 주소 이벤트 매핑
                if(component.get('v.isEditDeliveryInfo')){ //24 01 17 hyungho.chun detailist에서도 똑같은이벤트쏴서 detail에서 바로 받은 이벤트만 효과있게끔 분기처리
                    component.set('v.productRequest.CONSIGNEE_Address__c', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
                    component.set('v.productRequest.CONSIGNEE_Address_DETAIL__c', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
                    component.set('v.productRequest.CONSIGNEE_PostalCode__c', selectedRows.postalCode);
                }
 

                console.log(' 끝');

        },

    fnPhoneChg: function (component, event, helper) {
        var productRequest = component.get('v.productRequest');
        productRequest.CONSIGNEE_TPNO_1__c = helper.gfnChgTelFormat(component, event, productRequest.CONSIGNEE_TPNO_1__c);
        component.set("v.productRequest", productRequest);

        if (/^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}/.test(productRequest.CONSIGNEE_TPNO_1__c)) {
            component.set('v.isConsigneePhoneValid', true);
        } else {
            component.set('v.isConsigneePhoneValid', false);
        }
        console.log('isConsigneePhoneValid -> ' + component.get('v.isConsigneePhoneValid'));

    },
    contactConsigneeChange  : function (component, event, helper) {
        var productRequest = component.get('v.productRequest');
        //23 12 05 0-9| 추가 번호입력도가능하게
        if (!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9| |]+$/.test(productRequest.CONSIGNEE_Name__c))) {
            productRequest.CONSIGNEE_Name__c = '';
            component.set('v.isConsigneeNameValid', false);
        } else {
            component.set('v.isConsigneeNameValid', true);
        }
        component.set('v.productRequest', productRequest);
    },

    fnGetPrDescription : function(component) {
        console.log('fgpd : ' + JSON.stringify(component.get("v.objCase")));
        return 'hello';
    }
});