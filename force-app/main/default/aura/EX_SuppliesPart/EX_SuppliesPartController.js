/**
 * Created by I2MAX.SEOKHOLEE on 2022/12/25.
 */

({
    fnInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");


        console.log('isContactSameStr ?? ' , component.get('v.isContactSameStr'));
        // 상담 Console에서
        // 채팅 쪽에서 부품주문 인입시 url을 LCT로 잡는 이슈로 시간차
        setTimeout(function () {
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                console.log('response >>> ' + JSON.stringify(response));
                // console.log('isSubtab' , response.isSubtab);
             

                    console.log('check1');
                    //2023 1011 seung yoon heo 상담포탈시 고객조회 조건 변경 12.15 소모품 프로모션 tab에서 넘어올 경우 예외처리 추가
                    if (response.recordId && response.recordId != undefined && !response.url.includes('EX_Promotion__c')) {
                        helper.getContactInfo(component, response.recordId);
                        console.log('check2');
                        // helper.fnContactConsigneeChange(component, event, helper);
                    } else {
                        console.log('check3');
                        if (!component.get('v.FSIsMaterialPortal') && !component.get('v.isExchangeOrder') && response.pageReference != undefined) {
                            var recordId = response.pageReference.state.c__strCaseId;
                            if (recordId != undefined) {
                                console.log('check4');
                                helper.getContactInfo(component, recordId);
                                    
                            } else{
                                component.set("v.isFromCase", false);
                            }
                        } else {
                            console.log('check5');
                            if (component.get('v.FSIsMaterialPortal') && !$A.util.isEmpty(component.get('v.FSContactId'))) {
                                // 2024.01.10 seung yoon heo 부품포탈에서 넘어올 경우에도 vip 할인 적용
                                // helper.fnGetContactVIP(component, event, helper, component.get('v.FSContactId'));

                                helper.getContactInfoByContactId(component, component.get('v.FSContactId'));
                                console.log('check6');
                                //2023 1011 seung yoon heo 자재포탈 인입시 상담포탈의 subtab에서 오는 경우에 조회불가
                                if (response.isSubtab == true) {
                                    component.set("v.isFromCase", true);
                                } else {
                                    component.set("v.isFromCase", false);
                                }
                                // helper.fnContactConsigneeChange(component, event, helper);
                            } else if(response.pageReference != undefined){
                                console.log('check7');
                                console.log('response.pageReference' ,response.pageReference);
                                var recordId = response.pageReference.state.c__strCaseId;
                                console.log('recordId' , recordId);
                                if (recordId != undefined) {
                                    helper.getContactInfoByContactId(component, recordId);
                                    // helper.fnGetContactVIP(component, event, helper, recordId);
                                    // helper.fnContactConsigneeChange(component, event, helper);
                                }else { 
                                     //2023 1011 seung yoon heo 자재포탈 인입시 상담포탈의 subtab에서 오는 경우에 조회불가
                                    if (response.isSubtab == true) {
                                        component.set("v.isFromCase", true);
                                    } else {
                                        component.set("v.isFromCase", false);
                                    }
                                    // component.set("v.isFromCase", false);    
                                }
                            } else{
                                component.set("v.isFromCase", false);
                            }
                        }
                    }
            }).catch(function (error) {
                
            });

            workspaceAPI.getEnclosingTabId().then(function (tabId) {
                   
                //23.09.18 PHJ
                if (tabId) {
                    console.log('response.tabId ' , tabId);
                    var focusedTabId = tabId;
                    console.log('focusedTabId' , focusedTabId);
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "소모품택배주문"
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,        
                        icon: 'custom:custom18'
                    });
            
                }
                
                console.log('current Tab Id ' + tabId);
            }).catch(function (error) {
                console.log(error);
            });

            var navigationItemAPI = component.find("navigationItemAPI");
            navigationItemAPI.getNavigationItems().then(function (response) {
                console.log('current getNavigationItems ');
                console.log(response);
            }).catch(function (error) {
                console.log(error);
            });

            var utilityAPI = component.find('utilitybar');
    
            utilityAPI.getAllUtilityInfo().then(function (response) {
                console.log(' response : '+ JSON.stringify(response));
                var utilityItems = response.utilityItems;
               
            });

            // var hostname = window.location.hostname;
            //
            // var vfHost = hostname.split(".")[0] + "--c.sandbox.vf.force.com";
            // component.set("v.vfHost", vfHost);
            //
            // window.addEventListener("message", function (event) {
            //     console.log('event data : ' + JSON.stringify(event.data));
            //     if (event.data.target === 'DAUMADDR') {
            //         switch (event.data.userSelectedType) {
            //             case "R":
            //                 var roadAddress = event.data.roadAddress;
            //                 var zoneCode = event.data.zonecode;
            //                 roadAddress += (event.data.buildingName === "" ? "" : (" (" + event.data.buildingName + ")"));
            //                 component.set("v.newAddress", roadAddress);
            //                 component.set('v.zoneCode', zoneCode);
            //                 break;
            //             case "J":
            //                 component.set("v.newAddress", event.data.jibunAddress);
            //                 component.set('v.zoneCode', zoneCode);
            //                 break;
            //         }
            //     }
            // });
        }, 0);

    },

    fnSameAddress: function (component, event, helper) {
        console.log('fn Same Address func');
        // 2023.12.20 seung yoon heo checkbox Text 변환
        component.set('v.isContactSameStr', String(event.getParam("checked")));
        console.log('isContactSameStr ?? ' , component.get('v.isContactSameStr'));
        if (event.getParam("checked")) {
            console.log('fn Same Address func if ');
            let objCont = component.get("v.objCont");

            // 선택된 고객이 없을 때는 Return -> NPE validation
            if (objCont === null) return;
            component.set('v.phoneCol', 'color:black');

            // 수취인 정보 update
            if (objCont.Name) component.set("v.consigneeName", objCont.Name);
            if (objCont.MobilePhone) component.set("v.IbCallNo", objCont.MobilePhone);

            // if(objCont.ADDRESS_NEW__c) component.set("v.newAddress", objCont.ADDRESS_NEW__c);
            // if(objCont.ADDRESS_OLD__c) component.set("v.oldAddress", objCont.ADDRESS_OLD__c);

            //23 12 06 hyungho.chun if 조건엔 ADDRESS_NEW__c로 걸고 넣는건 fm_ADDRESS_NEW__c이였음 -> 둘다 fm_ADDRESS_NEW__c이였음 체크후 fm_ADDRESS_NEW__c이였음 값 넣는거로 수정
            if (objCont.fm_ADDRESS_NEW__c) component.set("v.newAddress", objCont.fm_ADDRESS_NEW__c);
            if (objCont.fm_ADDRESS_NEW__c) component.set("v.oldAddress", objCont.fm_ADDRESS_OLD__c);

            if (objCont.ADDRESS_DETAIL__c) component.set("v.detailAddress", objCont.ADDRESS_DETAIL__c);
            if (objCont.POSTAL_CODE__c) component.set("v.zoneCode", objCont.POSTAL_CODE__c);
            if (objCont.LATITUDE__c) component.set("v.latitude", objCont.LATITUDE__c);
            if (objCont.LONGITUDE__c) component.set("v.longitude", objCont.LONGITUDE__c);

        } else {
            component.set('v.phoneCol', '');

            console.log('fn Same Address func else ');
            component.set("v.newAddress", "");
            component.set("v.oldAddress", "");
            component.set("v.detailAddress", "");
            component.set("v.zoneCode", "");
            component.set("v.latitude", "");
            component.set("v.longitude", "");

            // 수취인 정보
            component.set("v.consigneeName", '');
            component.set("v.IbCallNo", '');

        }
        helper.fnContactConsigneeChange(component, event, helper);
    },

    fnTabSelect: function (component, event, helper) {
        console.log(component.get("v.currTabId"));
    },

    fnSearchCenter: function (component, event, helper) {
        console.log('fnSearchCenter ');

    },


    /**
     * @description 소모품 택배 주문 화면에서 고객 미 식별시 고객 조회 화면으로 이동
     *              소모품 택배 화면의 경우 URL 파라미터인 c__strCaller 별도 정의 필요
     *              현재 임의 값 Consumable 부여
     * @param component
     * @param event
     * @param helper
     * @author 22.12.19 / I2MAX.SEOKHOLEE
     */
    fnCustomerSearch: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find('navService');
        var preTabIdx = null;

        var searchName_SC = component.get('v.searchName_SC');
        var IbCallNo_SC = component.get('v.IbCallNo_SC');
        var url = '/lightning/n/CustomerSearch?c__strCaller=' + 'Consumable';

        if (!$A.util.isEmpty(searchName_SC)) {
            url += '&c__searchName=' + searchName_SC
        }

        if (!$A.util.isEmpty(IbCallNo_SC)) {
            url += '&c__IbCallNo=' + IbCallNo_SC
        }

        //2023.09.11 gw.lee
        //enClosingTab => FocusedTabInfo 형태 변경
        //기존 ConsumableSearch Tab을 여는 구조 => 해당 Component 이동 구조
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            
            console.log('response ??? ' , JSON.stringify(response));
            
            var objParam = {};

            objParam.c__IbCallNo = searchName_SC;
            objParam.c__strCaller = 'Consumable';
            if (response.tabId != undefined) {
                var focusedTabId = response.tabId;
                objParam.c__ptId = focusedTabId;  
            }

            var pageReference = {
                type: 'standard__component',
                 attributes: {
                     componentName: 'c__CustomerSearch'
                 },
                 state: objParam
            };

            navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                workspaceAPI.openTab({
                    url: url,
                    focus: true
                });
            }), $A.getCallback(function(error) {
                console.log(error);
            }));
        }).catch(function (error) {
            console.log('error');
        });
    },

    /**
     * @description 고객 조회에서 조회한 데이터를 인입하여 처리하는 Handler
     *              소모품 택배 주문 화면에서 고객을 식별하지 못한 경우
     *              고객 조회 Tab 에서 선택한 고객 정보를 해당 컴포넌트에서 처리
     * @param component
     * @param event
     * @param helper
     * @author 22.12.19 / I2MAX.SEOKHOLEE
     */
    fnGetCustomerSearchResult: function (component, event, helper) {
        console.log('고객 조회에서 조회한 데이터를 인입하여 처리하는 Handler');

        var workspaceAPI = component.find("workspace");
        
        let contactId = event.getParams().objData;
        console.log('contactId : ' + contactId);
        var currentUrl = String(window.location.pathname + window.location.search);
        console.log('currentUrl? ' , currentUrl);
         if (!currentUrl.includes('c__ptId')) {
                workspaceAPI.getTabInfo().then(function (response) {
                console.log('콘솔일 경우');
            }).catch(function(error) {
                 helper.getContactInfoByContactId(component, contactId, true);
            });
         } else {
            workspaceAPI.getTabInfo().then(function (response) {
                helper.getContactInfoByContactId(component, contactId, true);
            }).catch(function(error) {
                console.log('탭이 없는 경우 맞음');    
            }); 
         }
        
        // if (component.get('v.caseNumber') == undefined) {
        //     // Contact RecordId
        //     let contactId = event.getParams().objData;
        //     console.log('contactId : ' + contactId);
        //     // helper.fnGetContactVIP(component, event, helper, contactId);
        //     helper.getContactInfoByContactId(component, contactId, true);
           
        // }
    },

    /**
     * @description 식별한 고객(Contact)가 변경 된 경우 타 컴포넌트로 소모품 저장을 위한 Event fire
     * @param component
     * @param event
     * @param helper
     * author 22.12.22 / I2MAX.SEOKHOLEE
     */
    // fnContactChange: function (component, event, helper) {
    //     console.log('고객 정보 변경');

    //     var evt = $A.get("e.c:EX_SuppliesPartContact_evt");
    //     evt.setParam("contactId",component.get('v.consertConId') != null || component.get('v.consertConId') != undefined ?component.get('v.consertConId') : component.get('v.contactId'));
    //     evt.setParam("objCont", component.get('v.objCont'));
    //     evt.setParam("consigneeName", component.get('v.consigneeName'));
    //     evt.setParam("IbCallNo", component.get('v.IbCallNo'));
    //     if (component.get('v.newAddress') == null || component.get('v.newAddress') == '') {
    //         evt.setParam("newAddress", component.get('v.oldAddress'));
    //     } else {
    //         evt.setParam("newAddress", component.get('v.newAddress'));
    //     }
    //     evt.setParam("newAddress", component.get('v.newAddress'));
    //     evt.setParam("detailAddress", component.get('v.detailAddress'));
    //     evt.setParam("requestedTerm", component.get('v.requestedTerm'));
    //     evt.setParam("remark", component.get('v.remark'));
    //     evt.setParam("isContactSame", component.get('v.isContactSame'));
    //     evt.setParam('phoneCol', component.get('v.phoneCol'));
    //     evt.setParam('managerNote', component.get('v.managerNote'));
    //     evt.setParam('ContactVIP', component.get('v.ContactVIP'));
    //     console.log('ContactVIP : ' + component.get('v.ContactVIP'));

    //     evt.fire();

    // },
    getconsignee: function (component, event, helper) {
        console.log('고객 정보 재 설정 및 전송');
        var workspaceAPI = component.find("workspace");
        var orderListTabIdMain = event.getParam('tabId');
        var orderListTabId = orderListTabIdMain.substring(0,orderListTabIdMain.indexOf('_') != -1 ? orderListTabIdMain.indexOf('_') : orderListTabIdMain.length);
        var FSIsMaterialPortal = event.getParam('FSIsMaterialPortal');
        var evt = $A.get("e.c:EX_SuppliesPartContact_evt");
        //2024.01.05 seung yoon heo 일반주문도 화면에서 가지고 오게 변경
        // if (orderListTabId != '일반주문') {
            workspaceAPI.getTabInfo().then(function (response) {
                if (orderListTabId == response.parentTabId) {
                    console.log('orderListTabId ?? ' , orderListTabId);
                    console.log('tabId ?? ' , JSON.stringify(response));
    
    
                    if (component.get('v.conOpen')) {
                        evt.setParam("contactId", component.get('v.contactId'));
                        evt.setParam("objCont", component.get('v.objCont'));
                        evt.setParam('phoneCol', component.get('v.phoneCol'));
                        evt.setParam('zoneCode', component.get('v.zoneCode'));
                        var isSame = Boolean(component.find('sameAddress').get("v.value"));
                        if (!isSame) {
                            evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                            evt.setParam("consigneeName", component.find('consigneeName').get("v.value"));
                            evt.setParam("IbCallNo", component.find('IbCallNo').get("v.value"));
                            evt.setParam("newAddress", component.find('newAddress').get("v.value"));
                            evt.setParam("detailAddress", component.find('detailAddress').get("v.value"));
                        } else {
                            evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
                            evt.setParam("consigneeName", component.get('v.consigneeName'));
                            evt.setParam("IbCallNo", component.get('v.IbCallNo'));
                            evt.setParam("newAddress", component.get('v.newAddress'));
                            evt.setParam("detailAddress", component.get('v.detailAddress'));
                        }
                        if (!FSIsMaterialPortal) {
                            evt.setParam("remark", component.find('remark').get("v.value") != undefined ? component.find('remark').get("v.value") : '');
                            
                        }
                        //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                        if(!component.get('v.isFromCase2')){
                            evt.setParam('managerNote', component.find('managerNote').get("v.value") != undefined ? component.find('managerNote').get("v.value") : '');
                        }
                        
                        evt.setParam("requestedTerm", component.find('requestedTerm').get("v.value") != undefined ? component.find('requestedTerm').get("v.value") : '');
                        evt.setParam('ContactVIP', component.get('v.ContactVIP'));
                        evt.setParam('partTabId', response.tabId);
                        evt.setParam("isCreateOrder", true);
                        
                    } else {
                        evt.setParam("contactId", component.get('v.contactId'));
                        evt.setParam("objCont", component.get('v.objCont'));
                        evt.setParam('phoneCol', component.get('v.phoneCol'));
                        evt.setParam('zoneCode', component.get('v.zoneCode'));

                        var isSame = Boolean(component.find('sameAddressStr').get("v.value"));
                        if (!isSame) {
                            evt.setParam("isContactSame", Boolean(component.find('sameAddressStr').get("v.value")));
                            evt.setParam("consigneeName", component.find('consigneeNameStr').get("v.value"));
                            evt.setParam("IbCallNo", component.find('IbCallNoStr').get("v.value"));
                            evt.setParam("newAddress", component.find('newAddressStr').get("v.value"));
                            evt.setParam("detailAddress", component.find('detailAddressStr').get("v.value"));
                        } else {
                            evt.setParam("isContactSame", Boolean(component.find('sameAddressStr').get("v.value")));
                            evt.setParam("consigneeName", component.get('v.consigneeName'));
                            evt.setParam("IbCallNo", component.get('v.IbCallNo'));
                            evt.setParam("newAddress", component.get('v.newAddress'));
                            evt.setParam("detailAddress", component.get('v.detailAddress'));
                        }
                        if (!FSIsMaterialPortal) {
                            evt.setParam("remark", component.find('remarkStr').get("v.value") != undefined ? component.find('remarkStr').get("v.value") : '');
                            
                        }
                        //24 02 27 hyungho.chun 화면에서 숨길때 대비 분기처리
                        if(!component.get('v.isFromCase2')){
                            evt.setParam('managerNote', component.find('managerNoteStr').get("v.value") != undefined ? component.find('managerNoteStr').get("v.value") : '');
                        }
                        
                        evt.setParam("requestedTerm", component.find('requestedTermStr').get("v.value") != undefined ? component.find('requestedTermStr').get("v.value") : '');
                        evt.setParam('ContactVIP', component.get('v.ContactVIP'));
                        evt.setParam('partTabId', response.tabId);
                        evt.setParam("isCreateOrder", true);
                        
                    }
                    evt.fire();
                }
    
            });
            
        // } else {
        //     if (component.get('v.conOpen')) {
        //         evt.setParam("contactId", component.get('v.contactId'));
        //         evt.setParam("objCont", component.get('v.objCont'));
        //         evt.setParam('phoneCol', component.get('v.phoneCol'));
        //         var isSame = Boolean(component.find('sameAddress').get("v.value"));
        //         if (!isSame) {
        //             evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
        //             evt.setParam("consigneeName", component.find('consigneeName').get("v.value"));
        //             evt.setParam("IbCallNo", component.find('IbCallNo').get("v.value"));
        //             evt.setParam("newAddress", component.find('newAddress').get("v.value"));
        //             evt.setParam("detailAddress", component.find('detailAddress').get("v.value"));
        //         } else {
        //             evt.setParam("isContactSame", Boolean(component.find('sameAddress').get("v.value")));
        //             evt.setParam("consigneeName", component.get('v.consigneeName'));
        //             evt.setParam("IbCallNo", component.get('v.IbCallNo'));
        //             evt.setParam("newAddress", component.get('v.newAddress'));
        //             evt.setParam("detailAddress", component.get('v.detailAddress'));
        //         }
        //         //어차피 콘솔에서 할땐 항상 상담이력이 없음
        //         // if (!FSIsMaterialPortal) {
        //         //     evt.setParam("remark", component.find('remark').get("v.value") != undefined ? component.find('remark').get("v.value") : '');
                    
        //         // }
        //         evt.setParam('managerNote', component.find('managerNote').get("v.value") != undefined ? component.find('managerNote').get("v.value") : '');
        //         evt.setParam("requestedTerm", component.find('requestedTerm').get("v.value") != undefined ? component.find('requestedTerm').get("v.value") : '');
        //         // tabId대신 일반주문 분기값
        //         evt.setParam('ContactVIP', component.get('v.ContactVIP'));
        //         evt.setParam('partTabId', '일반주문');
        //         evt.setParam("isCreateOrder", true);
                
        //     } else {
        //         evt.setParam("contactId", component.get('v.contactId'));
        //         evt.setParam("objCont", component.get('v.objCont'));
        //         evt.setParam('phoneCol', component.get('v.phoneCol'));
        //         var isSame = Boolean(component.find('sameAddressStr').get("v.value"));
        //         if (!isSame) {
        //             evt.setParam("isContactSame", Boolean(component.find('sameAddressStr').get("v.value")));
        //             evt.setParam("consigneeName", component.find('consigneeNameStr').get("v.value"));
        //             evt.setParam("IbCallNo", component.find('IbCallNoStr').get("v.value"));
        //             evt.setParam("newAddress", component.find('newAddressStr').get("v.value"));
        //             evt.setParam("detailAddress", component.find('detailAddressStr').get("v.value"));
        //         } else {
        //             evt.setParam("isContactSame", Boolean(component.find('sameAddressStr').get("v.value")));
        //             evt.setParam("consigneeName", component.get('v.consigneeName'));
        //             evt.setParam("IbCallNo", component.get('v.IbCallNo'));
        //             evt.setParam("newAddress", component.get('v.newAddress'));
        //             evt.setParam("detailAddress", component.get('v.detailAddress'));
        //         }
                
        //         evt.setParam('managerNote', component.find('managerNoteStr').get("v.value") != undefined ? component.find('managerNoteStr').get("v.value") : '');
        //         evt.setParam("requestedTerm", component.find('requestedTermStr').get("v.value") != undefined ? component.find('requestedTermStr').get("v.value") : '');
        //         evt.setParam('ContactVIP', component.get('v.ContactVIP'));
        //         evt.setParam('partTabId', '일반주문');
        //         evt.setParam("isCreateOrder", true);
                
        //     }
        //     evt.fire();
        // }


    },
    

    /**
     * @description 식별한 고객(Contact)가 변경 된 경우 타 컴포넌트로 소모품 저장을 위한 Event fire / 교환 주문
     * @param component
     * @param event
     * @param helper
     * author 23.05.19 / I2MAX.SEOKHOLEE
     */
    fnContactChangeFromExchangeOrder: function (component, event, helper) {
        console.log('타 채널의 교환시 Contact 정보가 없는 경우 재 조회가 필요');
        // 타 채널의 교환시 Contact 정보가 없는 경우 재 조회가 필요
        console.log('productRequestId -> ' + component.get('v.productRequestId'));

        var action = component.get('c.doGetProductRequestCustInfo');
        action.setParams({
            "productRequestId": component.get('v.productRequestId')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                var consigneeObj = result['consigneeInfo'];
                var objCont = {};
                objCont.Name = result['orderCustName'];
                objCont.MobilePhone = result['orderCustPhone'];
                objCont.fm_ADDRESS_NEW__c = result['orderCustAddress'] + ' ' + result['orderCustAddressDetail'];
                objCont.POSTAL_CODE__c = result['orderCustPostalCode'];
                component.set('v.consigneeName',objCont.Name);
                component.set('v.newAddress',objCont.fm_ADDRESS_NEW__c);
                console.log('objCont => ' + JSON.stringify(objCont));
                component.set('v.objCont', objCont);
                component.set('v.excgConsAddress', consigneeObj.CONSIGNEE_Address__c);
                component.set('v.excgConsdetail', consigneeObj.CONSIGNEE_Address_DETAIL__c);
                component.set('v.excgConsName', consigneeObj.CONSIGNEE_Name__c);
                component.set('v.excgConsPhone', consigneeObj.CONSIGNEE_TPNO_1__c != null || consigneeObj.CONSIGNEE_TPNO_1__c != undefined ? consigneeObj.CONSIGNEE_TPNO_1__c : consigneeObj.CONSIGNEE_TPNO_2__c);

                // component.set('v.IbCallNo', result['orderCustPhone']);
                // component.set('v.zoneCode', result['orderCustPostalCode']);
                // component.set('v.newAddress', result['orderCustAddress']);
                // component.set('v.detailAddress', result['orderCustAddressDetail']);
                // component.set('v.objCont', objCont);

                var evt = $A.get("e.c:EX_SuppliesPartContact_evt");
                evt.setParam("contactId", component.get('v.contactId'));
                evt.setParam("objCont", component.get('v.objCont'));
                evt.setParam("consigneeName", consigneeObj.CONSIGNEE_Name__c);
                evt.setParam("IbCallNo", consigneeObj.CONSIGNEE_TPNO_1__c != null || consigneeObj.CONSIGNEE_TPNO_1__c != undefined ? consigneeObj.CONSIGNEE_TPNO_1__c : consigneeObj.CONSIGNEE_TPNO_2__c);
                evt.setParam("newAddress", consigneeObj.CONSIGNEE_Address__c);
                evt.setParam("detailAddress", consigneeObj.CONSIGNEE_Address_DETAIL__c);
                evt.setParam('zoneCode', consigneeObj.CONSIGNEE_PostalCode__c);
                evt.setParam("requestedTerm", component.get('v.requestedTerm'));
                evt.setParam("remark", component.get('v.remark'));
                evt.setParam("isContactSame", false);
                evt.setParam('phoneCol', component.get('v.phoneCol'));
                evt.setParam('managerNote', component.get('v.managerNote'));
                evt.setParam('isExchangeConInfo', true);
                //evt.setParam('ContactVIP', component.get('v.ContactVIP'));
                //console.log('ContactVIP : '+ component.get('v.ContactVIP'));

                evt.fire();
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast('error', errors[0].message);
                    }
                } else {
                    helper.showToast('error', 'Unknown error');
                }
            }
            //component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    fnHandleSplitViewEvent: function (component, event, helper) {
        var isSplitOpened = event.getParam("isSplitOpened");
        var mainLayoutItem = component.find('Main_layoutItem');
        var subLayoutItem = component.find('Sub_layoutItem');
        if (isSplitOpened === false) {
            $A.util.removeClass(mainLayoutItem, 'slds-size_11-of-12');
            $A.util.removeClass(subLayoutItem, 'slds-size_1-of-12');
            $A.util.addClass(mainLayoutItem, 'slds-size_9-of-12');
            $A.util.addClass(subLayoutItem, 'slds-size_3-of-12');
            //component.set('v.isSplitOpened', true);
        } else {
            $A.util.removeClass(mainLayoutItem, 'slds-size_9-of-12');
            $A.util.removeClass(subLayoutItem, 'slds-size_3-of-12');
            $A.util.addClass(mainLayoutItem, 'slds-size_11-of-12');
            $A.util.addClass(subLayoutItem, 'slds-size_1-of-12');
            //component.set('v.isSplitOpened', false);
        }
    },
    /**
     * @description 고객 정보(Contact, 수취인 정보) 변경 시 주문 실행하는 컴포넌트로 데이터 바인딩
     * @param component
     * @param event
     * @param helper
     * @author 22.12.26 / I2MAX.SEOKHOLEE
     */
    contactConsigneeChange: function (component, event, helper) {
        var inputName = component.get('v.consigneeName');
        if (!(/^[ㄱ-ㅎ()|가-힣|a-z|A-Z| |0-9|]+$/.test(inputName))) {
            component.set('v.consigneeName', '');
        }

        
        if (!Boolean(component.find('sameAddress').get("v.value"))) {
            helper.fnContactConsigneeChange(component, event, helper);
        }

    },
    fnDetailAddressChg: function (component, event, helper) {
        var detailAddress = component.get('v.detailAddress');
        if (!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |0-9|\-|ㅏ-ㅣ]+$/.test(detailAddress))) {
            component.set('v.detailAddress', '');
        }
        helper.fnContactConsigneeChange(component, event, helper);
    },
    fnTermChg: function (component, event, helper) {
        helper.fnContactConsigneeChange(component, event, helper);

    },
    fnPhoneChg: function (component, event, helper) {
        var IbCallNo = component.get("v.IbCallNo");

        IbCallNo = helper.gfnChgTelFormat(component, event, IbCallNo);
        component.set("v.IbCallNo", IbCallNo);


        if (/^[0-9]{2,4}-[0-9]{3,4}-[0-9]{4}/.test(IbCallNo)) {
            component.set('v.phoneCol', 'color:black');
        } else {
            component.set('v.phoneCol', 'color:red');
        }

        if(IbCallNo == null || IbCallNo == ''){
            component.set('v.phoneCol', '');
        }

        helper.fnContactConsigneeChange(component, event, helper);

    },

    /**
     * @description 수취인 직접 입력 시 주소 검색 버튼
     * @param component
     * @author 23.01.12 / I2MAX.SEUNGHUNAN
     */
//    fnAddressSearch: function (component) {
//        var vfOrigin = "https://" + component.get("v.vfHost");
//        var vfWindow = component.find("vfFrame").getElement().contentWindow;
//        var data = {
//            target: "DAUMAPICALL"
//        };
//        vfWindow.postMessage(data, vfOrigin);
//    },

    /**
     * @description 상담 이력 입력 후 포커스 아웃 시점에서 상담이력 저장
     * @param component
     * @author 23.01.17 / I2MAX.SEUNGHUNAN
     */
    fnSaveRemark: function (component) {
        var evt = $A.get("e.c:EX_SuppliesPartRemark_evt");
        evt.setParam('remark', component.get("v.remark"));

        evt.fire();
    },
    conInfoOpen: function (component) {
        component.set('v.conOpen', !component.get('v.conOpen'));
    },
    /*주소 검색 모듈 최신화*/
    fnAddressSearch: function (component, event, helper) {
        console.log(' 주소 검색 ');

        $A.createComponent(
            "c:SC_Address",
            {
                "confirmType": 'confirm'
                , "strSearchAddr": ''
            },
            function (newComponent, status, errorMessage) {
                if (component.isValid()) {
                    if (status === "SUCCESS") {
                        component.set("v.modalContent", []);
                        var body = component.get("v.modalContent");
                        body.push(newComponent);
                        component.set("v.modalContent", body);
                    } else {
                        console.log('Error :' + status + ' /' + errorMessage);
                    }
                }
            }
        );
    },

    fnGetAddress: function (component, event) {
        let strUniqueId = component.get("v.strUniqueId");
        let strTargetId = event.getParam('strUniqueId');
        console.log('주소 이벤트 받음 !');
        console.log('strUniqueId :: ' + strUniqueId + ' / strUniqueId  :: ' + strUniqueId);

        let objData = event.getParam('objData');
        let selectedRows = objData.selectedRows;
        var workspaceAPI = component.find("workspace");
        console.log(selectedRows);
        console.log(JSON.stringify(selectedRows));
        var currentUrl = String(window.location.pathname + window.location.search);
        var currentUrl2 = String(window.location.pathname);
        console.log('currentUrl? ' , currentUrl);
         if (currentUrl == '/lightning/n/ConsumablesOrder') {
                workspaceAPI.getTabInfo().then(function (response) {
                console.log('콘솔일 경우');
                if (response.url.includes('/lightning/n/ConsumablesOrder') && !response.url.includes('overrideNavRules')) {
                    // 2024.03.11 seung yoon heo 수동검색도 detailNew빈값으로 넘어옴 newAddr<< 통합주소 필드로 넘어오면 양쪽다 맞춰줌
                    component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
                    component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
                    component.set('v.zoneCode', selectedRows.postalCode); 
                }
            }).catch(function(error) {
                component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
                component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
                component.set('v.zoneCode', selectedRows.postalCode); 
            });
         } else {
             var currentTab = '';
             workspaceAPI.getFocusedTabInfo().then(function (response) {
                currentTab = response.tabId;
            }).catch(function(error) {
                console.log('탭이 없는 경우 맞음');    
            });

              workspaceAPI.getTabInfo().then(function (response) {
                if (currentTab == response.tabId) {
                    component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
                    component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
                    component.set('v.zoneCode', selectedRows.postalCode);

                }
            }).catch(function(error) {
                console.log('탭이 없는 경우 맞음');    
            }); 
            // seung yoon heo 교환주문의 경우
            if (currentUrl2 == '/lightning/n/IntegrationOrderManagement') {
                component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
                component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
                component.set('v.zoneCode', selectedRows.postalCode);
            }
         }
    
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

    },
});