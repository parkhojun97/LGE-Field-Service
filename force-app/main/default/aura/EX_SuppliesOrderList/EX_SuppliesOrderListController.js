/**
 * Created by A75685 on 2022-11-13.
 */

({

    fnInit: function (component, event, helper) {
        helper.gfinit(component, event, helper);
        helper.fnGetLocation(component, event, helper);

        if (component.get('v.data') != null) {
            setTimeout(function () {
                var data1 =  component.get('v.data');
                console.log('data1 :: ', data1);
                helper.sendMessage(component, {type: 'items', items: component.get('v.data')});
            }, 4000);
        }
        console.log('exchangeReturnOrderData ::',component.get('v.exchangeReturnOrderData'));

        if (JSON.parse(JSON.stringify(component.get('v.exchangeReturnOrderData'))) != '' && component.get('v.contactId') == undefined) {
            let orderData = component.get('v.exchangeReturnOrderData');
            component.set('v.contactId', orderData[0].ContactId);            
        }

        //2023.12.05 seung yoon heo 상담분기
        if (helper.gfnParsingUrl('c__strCaseId') != null) {
            let strCaseId = helper.gfnParsingUrl('c__strCaseId');
            component.set('v.strCaseId', strCaseId);
            console.log('case id 확인 ?? ' , component.get('v.strCaseId'));
        }         
    },


    fnChg: function (component, event, helper) {
        let sbom = component.get("v.sbom");
        let data = component.get("v.data");
        let listId = sbom.map(sbom => sbom.PART_NAME__c);
        helper.getParts(component, event, helper, listId);
    },
    fnAddWijmoHelper: function (component, event, helper) {
        helper.fnWijmoAddData(component, event, helper);

    },

    fnWholeInventoryPop: function (component, event, helper) {
        var objSelected = component.get("v.objSelected");

        /*partNo, pCenterId, pPartId, pSpec, pProductName, locationId*/
        console.log('v.currentLocation' + component.get('v.currentLocation'));
        $A.createComponent(
            "c:FS_WholeInventoryPop",
            {
                "partNo": objSelected.ProductCode
                , "pCenterId": component.get('v.currentLocation')
                , "pPartId": objSelected.sProductId
                , "pSpec": objSelected.PART_SPEC
                , "pProductName": objSelected.ProductName
                , "locationId": ''
                , "pChecked": true
            },
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set("v.modalContent", cmp);
                    // var body = component.get("v.modalContent");
                    // body.push(newComponent);
                    // component.set("v.modalContent", body);
                } else if (status === "INCOMPLETE") {
                    console.log('No response from server or client is offline.');
                } else if (status === "ERROR") {
                    console.log('Error :' + errorMessage);
                }
            });

    },

    fnSeleceted: function (component, event, helper) {
        let selectedRows = event.getParam('selectedRows');
        console.log(JSON.stringify(selectedRows));
        component.set("v.objSelected", selectedRows[0]);
    },

    /* 데이터테이블 수량 변경시  sProductItemId*/
    fnGetDraft: function (component, event, helper) {
        //let
        console.log('데이터테이블 수량 변경  ::: ');
        console.log(JSON.stringify(component.get("v.draftValues")));
        let currentDraft = component.get("v.draftValues");
        let draftValues = event.getParam('draftValues'); //현재 수정한 데이터테이블
        console.log(JSON.stringify(draftValues));

        let sProductItemId = draftValues[0].sProductItemId;
        let qty = parseInt(draftValues[0].QTY == null || draftValues[0].QTY < 0 ? 0 : draftValues[0].QTY);

        console.log('qty :: ' , qty);

//        let qty = parseInt(data.QTY__c);
        let dataDT = component.get("v.data");

        let unitPrice;
        let unitASCPrice;

        var maximumQuantity = component.get('v.maximumAmount');

        var quantityMap = component.get('v.quantityMap');
        console.log('qtyMap :::: ', quantityMap);

        dataDT.forEach(function (data) {
            //draftValues가 있을 때
            if (data.sProductItemId == sProductItemId) {


                unitPrice = parseInt(data.Price) / parseInt(data.QTY);
                unitASCPrice = parseInt(data.ASCPrice) / parseInt(data.QTY);

                data.QTY = qty;
                if (maximumQuantity <= qty && component.get('v.bulkOrderManager') == false) {
                    helper.showToast('error', '최대주문수량(50개) 초과');
                    //gw.lee 23.10.04
                    //최디재문 초과 시, 수량 1 -> 50변경
                    data.QTY = 50;
                } else {
                    if (data.QTY > data.fm_Available_Quantity) {
                        data.PurchaseType = '품절 주문';
                        data.ShipmentCode = data.DIVCODE;
                    } else {
                        if (data.EXQuantity >= data.QTY) {
                            data.ShipmentCode = 'PH8002';

                        } else if (data.DIVQuantity >= data.QTY) {
                            data.ShipmentCode = data.DIVCODE;

                        } else {
                            data.PurchaseType = '품절 주문';
                            data.ShipmentCode = data.DIVCODE;
                        }
                    }
                    // data.Price = qty * unitPrice;
                    // data.ASCPrice = qty * unitASCPrice;

                    //gw.lee 24.01.08
                    //단종된 상품 주문 가능 수정
                    // if (data.DISABLED_TYPE == 'Y' && data.QTY > data.fm_Available_Quantity) {
                    //     return helper.showToast('warning', '단종된 상품은 예약이 불가능합니다.');
                    // }

                    if (component.get('v.orderTotal') + data.Price * data.QTY < component.get('v.parseFee') && isExchangeOrder == false && component.get('v.costLimitManager') == false && data.PARCEL_YN == 'Y') { //23 12 28 hyungho.chun 현장판매상품은 비고에 최소주문금액넣지않는다                        helper.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                        data.Note = '최소주문금액 미달';

                    } else {
                        //23 12 19 hyungho.chun
                        if(data.Note != '택배 불가 상품'){
                            data.Note = null;
                        }                        
                    }
                    if (data.QTY > data.fm_Available_Quantity) {
                        data.PurchaseType = '품절 주문';
                        data.ShipmentCode = data.DIVCODE;
                    } else {
                        data.PurchaseType = '일반 주문';
                    }
                    if (data.EXQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                        data.ShipmentCode = 'PH8002';

                    } else if (data.DIVQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                        data.ShipmentCode = data.DIVCODE;

                    } else {
                        data.PurchaseType = '품절 주문';
                        data.ShipmentCode = data.DIVCODE;
                    }
                }
                var isDraftVal = false;
                currentDraft.forEach(function (draft) {
                    if (draft.sProductItemId == sProductItemId) {
                        draft.QTY = data.QTY;
                        draft.Price = data.Price;
                        draft.ASCPrice = data.ASCPrice;
                        draft.Note = data.Note;
                        draft.PurchaseType = data.PurchaseType;
                        draft.ShipmentCode = data.ShipmentCode;
                        draft.ObsMemberPrice = data.ObsMemberPrice;
                        isDraftVal = true;
                    }
                });

                if (!isDraftVal) {
                    currentDraft.push({
                        'QTY': data.QTY
                        , 'Price': data.Price
                        , 'ASCPrice': data.ASCPrice
                        , 'sProductItemId': data.sProductItemId
                        , 'PurchaseType': data.purchaseType
                        , 'Note': data.Note
                        , 'ObsMemberPrice': data.ObsMemberPrice
                    });
                }
            }
            component.set("v.draftValues", currentDraft);
            console.log( '123', JSON.stringify(component.get("v.draftValues")));
            console.log( '234' , JSON.stringify(component.get("v.data")));

            component.find('orderListDt').set("v.draftValues", currentDraft);
        });

        var standardOrderDataList = [];
        var soldOutOrderDataList = [];
        var totalSum = 0;

        //23 09 22 hyungho.chun 임시 판매금액 저장
        var totalTemp = 0;
                
        dataDT.forEach((item) => {
            totalSum += item.Price * item.QTY;
            if (item.PurchaseType == '일반 주문') {
                standardOrderDataList.push(item.data);
            } else {
                soldOutOrderDataList.push(item.data);
            }

            //23 09 22 hyungho.chun
            if(item.PromotionPrice != null){
                item.SaleAmount = item.PromotionPrice * (item.QTY);
            }else{
                item.SaleAmount = item.Price * (item.QTY);
            }
            if(item.SaleAmount != null && item.SaleAmount != 0){
                totalTemp += item.SaleAmount;
            }
        });
        console.log(totalSum);
        component.set('v.orderTotal', totalSum);

        //23 09 22 hyungho.chun
        component.set('v.orderTotalTemp', totalTemp);
        
        helper.getData(component, helper, standardOrderDataList, soldOutOrderDataList);
        component.set("v.data", dataDT);
        
        //23 09 22 hyungho.chun
        let wijimoName = 'wijmo_EXSuppliesOrderList';
        this.sendMessage(component, {type:'items', items: dataDT}, wijimoName);

    },

    fnClear: function (component, event, helper) {
        component.set("v.draftValues", null);
//        component.find('orderListDt').set("v.draftValues", null);
        component.set("v.data", []);
        component.set('v.purchaseType', 'None');
        component.set('v.orderTotal', 0);
        //2023-08-02 gw.lee
        //자재 포탈에서 넘어왔을 경우, 
        component.set('v.FSIsMaterialPortal', false);

        var isExchangeOrder = component.get('v.isExchangeOrder');
        var wijimoName = '';
        if (isExchangeOrder) {
            wijimoName = 'wijmo_EXSuppliesOrderDisabledList';
        }
        helper.sendMessage(component, {type: 'items', items: component.get('v.data')}, wijimoName);
    },

    getWholeItemList: function (component, event, helper) {
        console.log('getWholeItemList test ');
    },

    /**
     * @description 소모품 주문 저장
     * @param component
     * @param event
     * @param helper
     * @author 22.12.20 / I2MAX.SEOKHOLEE
     */
    fnSave: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault(); 
        var evt = $A.get("e.c:EX_SuppliesPartCaseContact_evt");
        var workspaceAPI = component.find("workspace");
            workspaceAPI.getTabInfo().then(function (response) {

                var isSubtab = response.isSubtab;
                if (isSubtab) {
                    evt.setParam('FSIsMaterialPortal' ,component.get('v.FSIsMaterialPortal'));
                    evt.setParam('tabId' , response.tabId);
                    evt.fire();
                } else {
                    helper.fnOrderSave(component, event, helper, false);
                } 
            }).catch(function (error) {
                helper.fnOrderSave(component, event, helper, false);
            });
          
        
        // if (component.get('v.strTabId') != null) {
        //     workspaceAPI.getTabInfo().then(function (response) {
        //         var strTabId = component.get('v.strTabId');
        //         strTabId = strTabId.substring(0,strTabId.indexOf('_') != -1 ? strTabId.indexOf('_') : strTabId.length);
        //         console.log('strTabId ?? ' , strTabId);
        //         console.log('response ?? ' , JSON.stringify(response));
        //         if (strTabId == response.parentTabId) {
                    
        //                 console.log('orderTabId ?? ' , strTabId);
        //                 evt.setParam('FSIsMaterialPortal' ,component.get('v.FSIsMaterialPortal'));
        //                 evt.setParam('tabId' , strTabId);
        //                 evt.fire();
                    
        //         } else {
        //             helper.fnOrderSave(component, event, helper, false);
        //         }
        //     }).catch(function (error) {
        //         helper.fnOrderSave(component, event, helper, false);
        //     });
        // } else {
        //     //2024.01.05 seung yoon heo 상담콘솔에서 소모품 택배 메인화면으로 띄었을 경우
        //     helper.fnOrderSave(component, event, helper, false);
        //     // evt.setParam('FSIsMaterialPortal' ,component.get('v.FSIsMaterialPortal'));
        //     // evt.setParam('tabId' , '일반주문');
        //     // evt.fire();
        // }
        
    
    },

    fnKeySave: function(component, event, helper) {
        console.log('test');
    },

    /**
     * @description 소모품 주문 저장을 위한 소모품 주문 정보 수신
     * @param component
     * @param event
     * @param helper
     * @author 22.12.22 / I2MAX.SEOKHOLEE
     */
    getContact: function (component, event, helper) {
        var isCreateOrder = event.getParam('isCreateOrder');
        var isExchangeConInfo = event.getParam('isExchangeConInfo');
        var partTabId = event.getParam('partTabId');
        var workspaceAPI = component.find("workspace");
        component.set('v.isCreateOrder', isCreateOrder);
        var currentUrl = String(window.location.pathname + window.location.search);
        if (!isCreateOrder) {
            if (isExchangeConInfo) {
                 var contactId = event.getParam('contactId');
                var objCont = event.getParam('objCont');
                var consigneeName = event.getParam('consigneeName');
                var IbCallNo = event.getParam('IbCallNo');
                var newAddress = event.getParam('newAddress');
                var detailAddress = event.getParam('detailAddress');
                var requestedTerm = event.getParam('requestedTerm');
                var remark = event.getParam('remark');
                var isContactSame = event.getParam('isContactSame');
                var zoneCode = event.getParam('zoneCode');
                var phoneCol = event.getParam('phoneCol');
                var managerNote = event.getParam('managerNote');

                component.set('v.consertContactId', contactId);
                component.set('v.consertObjCont', objCont);
                component.set('v.consertConsigneeName', consigneeName);
                component.set('v.consertIbCallNo', IbCallNo);
                component.set('v.consertIsContactSame', isContactSame);
                component.set('v.consertNewAddress', newAddress);
                component.set('v.consertDetailAddress', detailAddress);
                component.set('v.consertZoneCode', zoneCode);
                component.set('v.consertRemark' , remark);
                component.set('v.consertPhoneCol' , phoneCol);
                component.set('v.consertRequestedTerm', requestedTerm);
                component.set('v.consertManagerNote', managerNote);
            }

            if (currentUrl == '/lightning/n/ConsumablesOrder') {
                workspaceAPI.getTabInfo().then(function (response) {
                console.log('콘솔일 경우');
                // 소모품 택배주문을 열때 navigation에 소모품택배주문이 없을경우 url이 /lightning/n/ConsumablesOrder로 열리는 현상 예외처리
                if (response.url.includes('/lightning/n/ConsumablesOrder') && !response.url.includes('overrideNavRules')) {
                    var objCont = event.getParam('objCont');
                    var contactId = event.getParam('contactId');
                    var consigneeName = event.getParam('consigneeName');
                    var IbCallNo = event.getParam('IbCallNo');
                    var newAddress = event.getParam('newAddress');
                    var detailAddress = event.getParam('detailAddress');
                    // var requestedTerm = event.getParam('requestedTerm');
                    // var remark = event.getParam('remark');
                    var isContactSame = event.getParam('isContactSame');
                    // var zoneCode = event.getParam('zoneCode');
            
                    // var managerNote = event.getParam('managerNote');
            
                    component.set('v.consertObjCont', objCont);
                    component.set('v.consertContactId', contactId);
                    component.set('v.consertConsigneeName', consigneeName);
                    component.set('v.consertIbCallNo', IbCallNo);
                    component.set('v.consertNewAddress', newAddress);
                    component.set('v.consertDetailAddress', detailAddress);
                    // component.set('v.consertRequestedTerm', requestedTerm);
                    // component.set('v.consertRemark', remark);
                    component.set('v.consertIsContactSame', isContactSame);
                    component.set('v.consertPhoneCol', event.getParam('phoneCol'));
                    // component.set('v.consertZoneCode', zoneCode);
                    // component.set('v.consertManagerNote', managerNote);
                    component.set('v.consertContactVIP', event.getParam('ContactVIP'));
                }
            }).catch(function(error) {
                var objCont = event.getParam('objCont');
                var contactId = event.getParam('contactId');
                var consigneeName = event.getParam('consigneeName');
                var IbCallNo = event.getParam('IbCallNo');
                var newAddress = event.getParam('newAddress');
                var detailAddress = event.getParam('detailAddress');
                // var requestedTerm = event.getParam('requestedTerm');
                // var remark = event.getParam('remark');
                var isContactSame = event.getParam('isContactSame');
                // var zoneCode = event.getParam('zoneCode');
        
                // var managerNote = event.getParam('managerNote');
        
                component.set('v.consertObjCont', objCont);
                component.set('v.consertContactId', contactId);
                component.set('v.consertConsigneeName', consigneeName);
                component.set('v.consertIbCallNo', IbCallNo);
                component.set('v.consertNewAddress', newAddress);
                component.set('v.consertDetailAddress', detailAddress);
                // component.set('v.consertRequestedTerm', requestedTerm);
                // component.set('v.consertRemark', remark);
                component.set('v.consertIsContactSame', isContactSame);
                component.set('v.consertPhoneCol', event.getParam('phoneCol'));
                // component.set('v.consertZoneCode', zoneCode);
                // component.set('v.consertManagerNote', managerNote);
                component.set('v.consertContactVIP', event.getParam('ContactVIP'));
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
                    var objCont = event.getParam('objCont');
            var contactId = event.getParam('contactId');
            var consigneeName = event.getParam('consigneeName');
            var IbCallNo = event.getParam('IbCallNo');
            var newAddress = event.getParam('newAddress');
            var detailAddress = event.getParam('detailAddress');
            // var requestedTerm = event.getParam('requestedTerm');
            // var remark = event.getParam('remark');
            var isContactSame = event.getParam('isContactSame');
            // var zoneCode = event.getParam('zoneCode');
    
            // var managerNote = event.getParam('managerNote');
    
            component.set('v.consertObjCont', objCont);
            component.set('v.consertContactId', contactId);
            component.set('v.consertConsigneeName', consigneeName);
            component.set('v.consertIbCallNo', IbCallNo);
            component.set('v.consertNewAddress', newAddress);
            component.set('v.consertDetailAddress', detailAddress);
            // component.set('v.consertRequestedTerm', requestedTerm);
            // component.set('v.consertRemark', remark);
            component.set('v.consertIsContactSame', isContactSame);
            component.set('v.consertPhoneCol', event.getParam('phoneCol'));
            // component.set('v.consertZoneCode', zoneCode);
            // component.set('v.consertManagerNote', managerNote);
            component.set('v.consertContactVIP', event.getParam('ContactVIP'));
                }
            }).catch(function(error) {
                console.log('탭이 없는 경우 맞음');    
            }); 
         }
           
        } else {

            var contactId = event.getParam('contactId');
            var objCont = event.getParam('objCont');
            var consigneeName = event.getParam('consigneeName');
            var IbCallNo = event.getParam('IbCallNo');
            var newAddress = event.getParam('newAddress');
            var detailAddress = event.getParam('detailAddress');
            var isContactSame = event.getParam('isContactSame');
            var remark = event.getParam('remark');
            var requestedTerm = event.getParam('requestedTerm');
            var phoneCol = event.getParam('phoneCol');


            var managerNote = event.getParam('managerNote');

            
            component.set('v.contactId', contactId);
            component.set('v.objCont', objCont);
            component.set('v.consigneeName', consigneeName);
            component.set('v.isContactSame', isContactSame);
            component.set('v.IbCallNo', IbCallNo);
            component.set('v.newAddress', newAddress);
            component.set('v.detailAddress', detailAddress);
            component.set('v.remark' , remark);
            component.set('v.phoneCol' , phoneCol);
            component.set('v.requestedTerm', requestedTerm);
            component.set('v.ContactVIP', event.getParam('ContactVIP'));
            //2024.01.05 seung yoon heo 상담콘솔에서 소모품 일반 주문시 분기처리
          
                workspaceAPI.getTabInfo().then(function (response) {
                    if (partTabId == response.tabId) {
                        var zoneCode = event.getParam('zoneCode');

                        component.set('v.zoneCode' , zoneCode);

                        helper.fnOrderSave(component,event,helper);
                        
                    }
                });
            

        }
       
    },

    // 수취인 정보를 가져오기 위한 event
    getConsignee: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var currentUrl = String(window.location.pathname + window.location.search);
        var currentUrl2 = String(window.location.pathname);
        console.log('currentUrl? ' , currentUrl);
        var isContactSame = event.getParam('isContactSame');
        var consigneeName = event.getParam('consigneeName');
        var IbCallNo = event.getParam('IbCallNo');
        var newAddress = event.getParam('newAddress');
        var detailAddress = event.getParam('detailAddress');
        var requestedTerm = event.getParam('requestedTerm');
        var managerNote = event.getParam('managerNote');
        var zoneCode = event.getParam('zoneCode');

        if (currentUrl == '/lightning/n/ConsumablesOrder' || currentUrl2 == '/lightning/n/IntegrationOrderManagement') {
            workspaceAPI.getTabInfo().then(function (response) {
            console.log('콘솔일 경우');
            if (consigneeName != undefined) {
                component.set('v.consertConsigneeName', consigneeName);
            }
            if (IbCallNo != undefined) {
                component.set('v.consertIbCallNo', IbCallNo);
            }
            if (newAddress != undefined) {
                component.set('v.consertNewAddress', newAddress);
            }
            if (detailAddress != undefined) {
                component.set('v.consertDetailAddress', detailAddress);
            }
            if (requestedTerm != undefined) {
                component.set('v.consertRequestedTerm', requestedTerm);
            }
            if (event.getParam('phoneCol') != undefined) {
                component.set('v.consertPhoneCol', event.getParam('phoneCol'));
            }
            if (zoneCode != undefined) {
                component.set('v.consertZoneCode', event.getParam('zoneCode'));
            }
            if (managerNote != undefined) {
                component.set('v.consertManagerNote', managerNote);
            }
            // component.set('v.consertRemark', remark);
            component.set('v.consertIsContactSame', isContactSame);
        }).catch(function(error) {
            if (consigneeName != undefined) {
                component.set('v.consertConsigneeName', consigneeName);
            }
            if (IbCallNo != undefined) {
                component.set('v.consertIbCallNo', IbCallNo);
            }
            if (newAddress != undefined) {
                component.set('v.consertNewAddress', newAddress);
            }
            if (detailAddress != undefined) {
                component.set('v.consertDetailAddress', detailAddress);
            }
            if (requestedTerm != undefined) {
                component.set('v.consertRequestedTerm', requestedTerm);
            }
            if (event.getParam('phoneCol') != undefined) {
                component.set('v.consertPhoneCol', event.getParam('phoneCol'));
            }
            if (zoneCode != undefined) {
                component.set('v.consertZoneCode', event.getParam('zoneCode'));
            }
            if (managerNote != undefined) {
                component.set('v.consertManagerNote', managerNote);
            }
            // component.set('v.consertRemark', remark);
            component.set('v.consertIsContactSame', isContactSame);
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
                if (consigneeName != undefined) {
                    component.set('v.consertConsigneeName', consigneeName);
                }
                if (IbCallNo != undefined) {
                    component.set('v.consertIbCallNo', IbCallNo);
                }
                if (newAddress != undefined) {
                    component.set('v.consertNewAddress', newAddress);
                }
                if (detailAddress != undefined) {
                    component.set('v.consertDetailAddress', detailAddress);
                }
                if (requestedTerm != undefined) {
                    component.set('v.consertRequestedTerm', requestedTerm);
                }
                if (event.getParam('phoneCol') != undefined) {
                    component.set('v.consertPhoneCol', event.getParam('phoneCol'));
                }
                if (zoneCode != undefined) {
                    component.set('v.consertZoneCode', event.getParam('zoneCode'));
                }
                if (managerNote != undefined) {
                    component.set('v.consertManagerNote', managerNote);
                }
                // component.set('v.consertRemark', remark);
                component.set('v.consertIsContactSame', isContactSame);

            }
        }).catch(function(error) {
            console.log('탭이 없는 경우 맞음');    
        }); 
     }
        
     
      
       
    },

     /**
     * @description 자재포탈 disabled 처리
     * @param component
     * @param event
     * @param helper
     * @author 23.12.09 / seung yoon heo
     */
     getMaterialTab: function (component, event, helper) {
        var isMaterialTab = event.getParam('isMaterialDisable');
        console.log('isMaterialTab' , isMaterialTab);
        component.set('v.isMaterialTab' , isMaterialTab);
        
    },

    fnHandleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        // standard record page 로 이동 record action 이 여러개 일때 typeAttributes 로 구분해서 이벤트 처리가 가능
        switch (action.name) {
            case 'remove':
                var data = component.get('v.data');
                var total = component.get('v.orderTotal');
                total = total - row.QTY * row.Price;
                var newData = data.filter((item => {
                    return item.sProductId != row.sProductId;
                }));

                component.set('v.orderTotal', total);

                component.set('v.data', newData);
                break;

            case 'research':
                console.log('row => ' + JSON.stringify(row));
                console.log('JSON.stringify(data) => ' + JSON.stringify(component.get('v.data')));


                var evt = $A.get("e.c:EX_SearchSBOM_evt");

                evt.setParam("pPartId", row.sProductId);
                evt.setParam("pDivCode", row.DIVCODE);
                evt.setParam("pPartNo", row.ProductCode);
                evt.setParam("pModelName", null);
                evt.setParam("pPartDesc", null);
                evt.setParam("pPartSpec", null);
                evt.setParam("pisSBOM", true);
                evt.fire();

                break;

            default:
                break;
        }
    },

    /**
     * @description SuppliesPart에서 입력된 상담 이력 set
     * @param component
     * @param event
     * @author 23.01.17 / I2MAX.SEUNGHUNAN
     */
    fnSetRemark: function (component, event) {
        component.set("v.remark", event.getParam('remark'));
    },

    fnReceiveEvt: function (component, event, helper) {
        console.log('fnReceiveEvt -> 주문리스트');
        let wijimoName = 'wijmo_EXSuppliesOrderList';

        console.log(event.getParam('evtType'));
        // 삭제 이벤트 fire
        if (event.getParam('evtType') == 'remove') {
            let data = component.get('v.data');
            let newData = [];
            data.forEach((item) => {

                if (item.productRequestLineItemId == event.getParam('itemId')) {
                } else {
                    newData.push(item);
                }
            });
            helper.sendMessage(component, {type: 'items', items: data});
            component.set('v.data', newData);
        } else if (event.getParam('evtType') == 'selected') {
            // 회수 부품 선택 event fire
            var productCode = event.getParam('productCode');
            var divCode = event.getParam('divCode');
            var productRequestLineItemId = event.getParam('itemId');
            var exchangeLimitedQuantity = event.getParam('exchangeLimitedQuantity');
            var requestedReturnQuantity = event.getParam('requestedReturnQuantity');

            component.set('v.exchangeLimitedQuantity', exchangeLimitedQuantity);
            component.set('v.requestedReturnQuantity', requestedReturnQuantity);

            console.log('productCode -> ' + productCode);
            console.log('divCode -> ' + divCode);
            console.log('선택한 교환요청 할 원주문품목 Id -> ' + productRequestLineItemId);

            let data = component.get('v.data');
            let newData = [];

            data.forEach((item) => {
                console.log('item.productRequestLineItemId ->' + item.productRequestLineItemId);
                if (item.productRequestLineItemId == productRequestLineItemId) {
                    //if (item.ProductCode == event.getParam('productCode') && item.DIVCODE == event.getParam('divCode')) {

                    console.log('교환제한수량 -> ' + exchangeLimitedQuantity);
                    console.log('반품요청수량 -> ' + requestedReturnQuantity);
                    console.log('@@@ 선택된 부품 @@@');
                    console.log('item.QTY -> ' + item.QTY);

                    // 교환 제한 수량
                    if (parseInt(item.QTY) > exchangeLimitedQuantity) {
                        console.log('교환 제한 수량');
                        item.QTY = 0;
                        //helper.showToast('info', '교환 제한 수량' + '(' + exchangeLimitedQuantity + ')' + '을 초과 하였습니다.');
                    }

                    if (parseInt(item.QTY) != requestedReturnQuantity) {
                        console.log('반품 요청 수량');
                        // 반품 요청 수량
                        item.QTY = requestedReturnQuantity;
                        //helper.showToast('info', '수량을 다시 확인하세요.');

                    }

                    item.productRequestLineItemId = event.getParam('itemId');
                    console.log('item Id => ' + item.Id);
                    newData.push(item);
                }
            });

//            component.find('orderListDt').set("v.draftValues", newData);
            helper.sendMessage(component, {type: 'items', items: newData});

        } else if (event.getParam('evtType') == 'edited') {
            console.log('edited');
            var productRequestLineItemId = event.getParam('itemId');
            var requestedReturnQuantity = event.getParam('requestedReturnQuantity');
            var exchangeLimitedQuantity = event.getParam('exchangeLimitedQuantity');
            console.log('#####');
            console.log('requestedReturnQuantity ::: ' + requestedReturnQuantity);

            component.set('v.exchangeLimitedQuantity', exchangeLimitedQuantity);
            component.set('v.requestedReturnQuantity', requestedReturnQuantity);
            let data = component.get('v.data');
            let newData = [];

            data.forEach((item) => {
                console.log('item.productRequestLineItemId ->' + item.productRequestLineItemId);

                if (item.productRequestLineItemId == productRequestLineItemId) {
                    item.QTY = requestedReturnQuantity;
                    newData.push(item);
                }
            });
            //component.find('orderListDt').set("v.draftValues", newData);

            //23.10.26 gw.lee
            //금액 수정
            var totalSum = 0;
            var totalTemp = 0;
            newData.forEach((item) => {
                // totalSum += item.Price * item.QTY;
                if(item.PromotionPrice != null){
                    item.SaleAmount = item.PromotionPrice * (item.QTY);
                }else{
                    item.SaleAmount = item.Price * (item.QTY);
                }
                if(item.SaleAmount != null && item.SaleAmount != 0){
                    totalTemp += item.SaleAmount;
                }
            });
            console.log(totalSum);

            let listType = '';
            if (component.get('v.isExchangeOrder') == true) {
                listType = 'wijmo_EXSuppliesOrderDisabledList';
            }
            helper.sendMessage(component, {type: 'items', items: data}, listType);
            //helper.sendMessage(component, {type: 'items', items: data});
            component.set('v.orderTotal', totalSum);
            component.set('v.orderTotalTemp', totalTemp);
        }
    },

    /**
     * @description 소모품 교환 요청
     * @author 23.03.03 / I2MAX.SEOKHOLEE
     * @param component
     * @param event
     * @param helper
     */
    fnExchangeRequest: function (component, event, helper) {
			let offset =  new Date().getTimezoneOffset() * 60000;
	        let dateOffset = new Date(new Date().getTime() - offset);
	        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnExchangeRequest - start:' + dateOffset.toISOString());

        component.set('v.showSpinner', true);

        var isValid = true;
        // 교환요청 Validation
        var consumableLineItemValues = component.get('v.data');

        isValid = helper.fnConsumableOrderValidCheck(component, event, helper, consumableLineItemValues, false);

        if (!isValid) {
            component.set("v.showSpinner", false);
            return;
        }

        var exchangeOrderData = component.get('v.data');
        var standardOrderData = [];
        var soldOutOrderData = [];

        exchangeOrderData.forEach((item) => {
            if (item.PurchaseType == '일반 주문') {
                standardOrderData.push(item);
            } else {
                soldOutOrderData.push(item);
            }
        });

        var exchangeReturnData = component.get('v.exchangeReturnOrderData');

        var requestedReturnQuantity = component.get('v.requestedReturnQuantity');
        exchangeReturnData.forEach(item => {
           item.RequestedReturnQuantity =  requestedReturnQuantity;
        });
        console.log('Start====================');
        console.log('@@@ exchangeReturnData -> ' + JSON.stringify(exchangeReturnData));
        console.log('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        console.log('@@@ exchangeOrderData ->' + JSON.stringify(exchangeOrderData));
        console.log('End====================');
        console.log('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

        var objCont = component.get('v.consertObjCont');
        var contactId = component.get('v.consertContactId');
        var consigneeName = component.get('v.consertConsigneeName');
        var IbCallNo = component.get('v.consertIbCallNo');
        var newAddress = component.get('v.consertNewAddress');
        var detailAddress = component.get('v.consertDetailAddress');
        var requestedTerm = component.get('v.consertRequestedTerm');
        var remark = component.get('v.consertRemark');
        var isContactSame = component.get('v.consertIsContactSame');
        var strCaseId = component.get("v.strCaseId");
        var basisOrderNumber = component.get('v.basisOrderNumber');
        var zoneCode = component.get('v.consertZoneCode');
        var managerNote = component.get('v.consertManagerNote');

        console.log('############################');

        if (isContactSame) {
            consigneeName = objCont.Name;
            IbCallNo = objCont.Phone;
        }
        console.log('exchangeReturnData :::: ' + exchangeReturnData);

        if (contactId != null || contactId != undefined || contactId != '') {
            let orderData = component.get('v.exchangeReturnOrderData');
            contactId = orderData[0].ContactId;
        }

        var params = {
            'contactId': contactId,
            'consigneeName': consigneeName,
            'IbCallNo': IbCallNo,
            'newAddress': newAddress,
            'detailAddress': detailAddress,
            'requestedTerm': requestedTerm,
            'remark': remark,
            'isContactSame': isContactSame,
            'standardOrderData': JSON.stringify(standardOrderData),
            'soldOutOrderData': JSON.stringify(soldOutOrderData),
            'exchangeReturnData': exchangeReturnData,
            'strCaseId': strCaseId,
            'isExchangeOrder': true,
            'basisOrderNumber': basisOrderNumber,
            'zoneCode': zoneCode,
            'managerNote': managerNote
        };
        console.log(params);

        var action = component.get('c.createExchangeRequest');
        action.setParams({
            'paramMap': params
        });

        console.log('createExchangeRequest start!');

        var overlayLib = component.find('overlayLib');
			let offset1 =  new Date().getTimezoneOffset() * 60000;
	        let dateOffset1 = new Date(new Date().getTime() - offset1);
	        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnExchangeRequest - before createExchangeRequest:' + dateOffset1.toISOString());
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                helper.showToast('success', '교환요청이 성공적으로 저장되었습니다.');
                component.set('v.showSpinner', false);
                overlayLib.notifyClose();
            } else {
                var errors = response.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                    component.set('v.showSpinner', false);
                } else {
                    helper.showToast("error", "Unknown error");
                }
            }
			let offset2 =  new Date().getTimezoneOffset() * 60000;
	        let dateOffset2 = new Date(new Date().getTime() - offset2);
	        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnExchangeRequest - end:' + dateOffset2.toISOString());

        });

        $A.enqueueAction(action);

    },
    onWijmoMessage2: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;

        switch (payload.type) {
            case 'rowSelection':
                component.set("v.objSelected", payload.selectedRows[0]);
                this.fnGetDraft(component, event, helper);
                break;
            case 'rowAction':
                if ('Cancel' === actionName) {
                    helper.fnCancelProduct(component, event, helper, row);

                    let listType = '';
                    if (component.get('v.isExchangeOrder') == true) {
                        listType = 'wijmo_EXSuppliesOrderDisabledList';
                    }
                    
                    setTimeout(function () {
                        helper.sendMessage(component, {type: 'items', items: component.get('v.data')}), listType;
                    }, 2000);
                } else if ('research' === actionName) {
                    console.log('재조회');
                    console.log('row =>' + JSON.stringify(row));

                    var evt = $A.get("e.c:EX_SearchSBOM_evt");

                    evt.setParam("pPartId", row.sProductId);
                    evt.setParam("pDivCode", row.DIVCODE);
                    evt.setParam("pPartNo", row.ProductCode);
                    evt.setParam("pModelName", null);
                    evt.setParam("pPartDesc", null);
                    evt.setParam("pPartSpec", null);
                    evt.setParam("pisSBOM", true);
                    evt.fire();
                }

//                } else if ('collectionList' === actionName) {
//                } else if ('reconciledList' === actionName) {
//                }
                break;
            case 'editing':

                console.log('수량변경');
                console.log('payload.item : ' + JSON.stringify(payload.item));
                helper.fnGetWijmoDraft(component, event, helper, payload.item);
//                helper.fnWijmoAddData(component, event, helper , JSON.stringify(payload.item), 'add');
                break;

            case 'refresh':
                console.log('payload.item :' + payload.items);
                component.set('v.data', payload.items);
                console.log('초기화');
                break;
            case 'setData':
                component.set('v.draftValues', payload.items);
                // if (component.get('v.isExchangeOrder')) {
                // }
                var totalSum = 0;
                //23 09 21 hyungho.chun 임시 판매금액 저장
                var totalTemp = 0;
                var dataTemp = component.get('v.data');
                dataTemp.forEach((item) => {
                    totalSum += item.Price * item.QTY;        
                    if(item.PromotionPrice != null){
                        item.SaleAmount = item.PromotionPrice * (item.QTY);
                    }else{
                        item.SaleAmount = item.Price * (item.QTY);
                    }
                    if(item.SaleAmount != null && item.SaleAmount != 0){
                        totalTemp += item.SaleAmount;
                    }
                });
                component.set('v.orderTotal', totalSum);
                component.set('v.orderTotalTemp', totalTemp);
                break;


        }
    },

    onWijmoMessage: function (component, event, helper) {
        
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('v.data :: ',component.get('v.data'));
        //23 09 21 hyungho.chun 판매금액 미리계산해서 보여줌
        // var dataTemp = component.get('v.data');
        // dataTemp.forEach(item => {
        //     if(item.PromotionPrice != null){
        //         item.SaleAmount = item.PromotionPrice * (item.QTY);
        //     }else{
        //         item.SaleAmount = item.Price * (item.QTY);
        //     }

        // });
        // component.set('v.data', dataTemp);
        // component.set('orderTotalTemp',totalTemp);
        // console.log('data222 :: ',dataTemp);

        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;

        var totalSum = 0;
        //23 09 23 hyungho.chun 임시 판매금액 저장
        var totalTemp = 0;
        var dataTemp = component.get('v.data');
        dataTemp.forEach((item) => {
            totalSum += item.Price * item.QTY;        
            if(item.PromotionPrice != null){
                item.SaleAmount = item.PromotionPrice * (item.QTY);
            }else{
                item.SaleAmount = item.Price * (item.QTY);
            }
            if(item.SaleAmount != null && item.SaleAmount != 0){
                totalTemp += item.SaleAmount;
            }
        });
        component.set('v.orderTotal', totalSum);
        component.set('v.orderTotalTemp', totalTemp);

               

        switch (payload.type) {
            case 'rowSelection':
                component.set("v.objSelected", payload.selectedRows[0]);
                this.fnGetDraft(component, event, helper);
                break;
            case 'rowAction':
                if ('Cancel' === actionName) {
                    helper.fnCancelProduct(component, event, helper, row);

                    setTimeout(function () {
                        helper.sendMessage(component, {type: 'items', items: component.get('v.data')});
                    }, 2000);
                } else if ('research' === actionName) {
                    console.log('재조회');
                    console.log('row =>' + JSON.stringify(row));

                    var evt = $A.get("e.c:EX_SearchSBOM_evt");

                    evt.setParam("pPartId", row.sProductId);
                    evt.setParam("pDivCode", row.DIVCODE);
                    evt.setParam("pPartNo", row.ProductCode);
                    evt.setParam("pModelName", null);
                    evt.setParam("pPartDesc", null);
                    evt.setParam("pPartSpec", null);
                    evt.setParam("pisSBOM", true);
                    evt.fire();
                }

//                } else if ('collectionList' === actionName) {
//                } else if ('reconciledList' === actionName) {
//                }
                break;
            case 'editing':

                console.log('수량변경');
                console.log('payload.item : ' + JSON.stringify(payload.item));
                // var evt = $A.get("e.c:EX_ConsumableOrderList_evt");
                // evt.setParam("data",payload.item);
                // evt.fire();
                helper.fnGetWijmoDraft(component, event, helper, payload.item);
//                helper.fnWijmoAddData(component, event, helper , JSON.stringify(payload.item), 'add');
                break;

            case 'refresh':
                console.log('payload.item :' + payload.items);
                component.set('v.data', payload.items);
                console.log('초기화');
                break;
            case 'setData':
                var stoargeMap = component.get('v.stoargeMap');
                stoargeMap[payload.items.sProductId] = payload.items;
                stoargeMap[payload.items.sProductId].divShipmentName = payload.items['DIVCODE'];
                stoargeMap[payload.items.sProductId].divShipmentCode = payload.items['ShipmentName'];
                component.set('v.stoargeMap', stoargeMap);
                component.set('v.draftValues', payload.items);
                // if (component.get('v.isExchangeOrder')) {
                // }
                var totalSum = 0;
                //23 09 21 hyungho.chun 임시 판매금액 저장
                var totalTemp = 0;
                var dataTemp = component.get('v.data');
                dataTemp.forEach((item) => {
                    totalSum += item.Price * item.QTY;        
                    if(item.PromotionPrice != null){
                        item.SaleAmount = item.PromotionPrice * (item.QTY);
                    }else{
                        item.SaleAmount = item.Price * (item.QTY);
                    }
                    if(item.SaleAmount != null && item.SaleAmount != 0){
                        totalTemp += item.SaleAmount;
                    }
                });
                component.set('v.orderTotal', totalSum);
                component.set('v.orderTotalTemp', totalTemp);
                break;


        }
        
    },

    // fnGetWijmoDraftTemp: function (component, event, helper) {
    //     var dataTemp = event.getParam('data');
    //     console.log('이벤트로처리테스트');
    //     helper.fnGetWijmoDraft(component, event, helper, dataTemp);

    // },

    /**
     * @description 소모품택배주문 -> 부품Portal
     * @param compnent
     * @param event
     * @param helper
     */
    fnRedirectMaterialPortal: function (compnent, event, helper) {
        console.log('[fnNavigateToCmp] accesskey', 'c:FS_MaterialPortal');

        
        // 고객 Id
        var contactId = compnent.get('v.consertContactId') != undefined ? compnent.get('v.consertContactId') : compnent.get('v.contactId');

        // 선택한 부품 정보
        var data = compnent.get('v.data');

        var productIds = [];
        data.forEach(item => {
            productIds.push(item.sProductId);
        });

        // 센터 Id
        var serviceCenterId = compnent.get('v.serviceCenterId');


        if (serviceCenterId == null || serviceCenterId == undefined) {
            return helper.showToast('info', '부품Portal 로 이동하는 경우 서비스센터를 선택하여야 합니다.');
        }

        //seung yoon 부품탭 생성시 disable
        compnent.set('v.isMaterialTab' , true);

        var serviceCenterLabel = compnent.get('v.serviceCenterLabel');

        var materialEvent = $A.get("e.c:EXtomaterial_evt");
        materialEvent.setParams({
            'isConsumable': true,
            'contactId': contactId,
            'EXProductIds': productIds,
            'CustomerLocationId': serviceCenterId,
            'CustomerLocationLabel': serviceCenterLabel,
            'InitLocationId': serviceCenterId,
            'InitLocationLabel': serviceCenterLabel,
            'strTabId' : compnent.get('v.strTabId'),
            'strCaseId' : compnent.get('v.strCaseId')
        });
    
        materialEvent.fire();
        
        
      
    },

    getProductListFromExplodedPop: function (component, event, helper) {
        console.log('getProductListFromExplodedPop ### ');
        component.set('v.FSIsExplodedDrawingPop', true);
        component.set('v.showSpinner', true);

        var listItem = event.getParam('listItem');
        if (listItem.length > 0) {
            if (listItem.length == 0) {
                component.set('v.showSpinner', false);
                return;
            }

            var newDataList = [];
            var productSet = new Set();
            var productIds = [];

            listItem.forEach((item) => {
                productSet.add(item.PART_NAME__r.Id);
            });

            productSet.forEach((item) => {
                productIds.push(item);
            });

            var params = {
                'contactId': null,
                'productIds': productIds
            };
            console.log('doGetDataByMaterialPortal Start!');
            var action = component.get("c.doGetDataByMaterialPortal");
            action.setParams({
                'paramMap': params
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.showSpinner', false);
                    var result = response.getReturnValue();
                    var tempData = component.get('v.data') != undefined ? component.get('v.data') : [];

                    if (result['listResult'].length > 0) {
                        try {
                            var resultData = result['listResult'];
                        

                            // gw.lee 23.09.15
                            // 1. 이미 있는 대상이라면 추가 X
                            let prdList = [];

                            tempData.forEach(item => {
                                // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                                // prdList.push(item.ProductCode);
                                prdList.push(item.sProductId);
                            });

                            if (resultData.length > 0) {
                                for (let i = 0; i < resultData.length; i++) {
                                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                                    // if (!prdList.includes(resultData[i].ProductCode)) {
                                    if (!prdList.includes(resultData[i].sProductId)) {
                                        resultData.FSIsExplodedDrawingPopValid = 'N';
                                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                                    // } else if (prdList.includes(resultData[i].ProductCode)) {
                                    } else if (prdList.includes(resultData[i].sProductId)) {
                                        resultData.splice(i, 1);
                                        i--;
                                    }
                                }
                            }

                            tempData = tempData.concat(resultData);
                            component.set('v.data', tempData);

                            var data = component.get('v.data');
                            //23.08.24 gw.lee 
                            //분해도 -> 소모품 주문으로 넘어오는데, 넘어온 개수가 맞지 않을 경우 --> 백단에서 이미 처리하고 넘어옴
                            // if (resultData.length > 0) {
                            //     for (let i = 0; i < resultData.length; i++) {
                            //         if (resultData[i].PART_TYPE != 'Y') {
                            //             helper.showToast('warning', '소모품일 경우에만 주문내역에 포함 가능합니다.');

                            //             return false;
                            //         }
                            //     }
                            // }

                            helper.sendMessage(component, {type: 'items', items: data});
                        } catch (e) {
                            console.log('e :::: ', e);
                        }
                    }

                    // gw.lee 23.09.15
                    // 소모품일 경우만 주문 가능
                    //23 12 28 hyungho.chun 소모품아니여도 주문내역까진 내려오게 수정해서 메세지 따로 띄우지 않는다
                    // if (productIds.length > result['listResult'].length) {
                    //     helper.showToast('warning', '소모품일 경우 또는 주문내역에 존재하지않는 부품만 포함 가능합니다.', 'dismissible');
                    // }

                    // gw.lee 23.09.15
                    // 택배 주문이 가능한 경우만 주문 가능
                    //23 12 87 hyungho.chun 현장판매도 주문내역까진 내려오게  수정해서 메세지 따로 띄우지 않는다
                    // if (result['isDelivery'] == true) {
                    //     helper.showToast('warning', '택배 주문이 가능한 소모품만 주문내역에 포함 가능합니다.', 'dismissible');
                    // }


                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set('v.showSpinner', false);
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        component.set('v.showSpinner', false);
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    test: function (component, event, helper) {
        component.set('v.data', event.getParam('data'))
        setTimeout(function () {
            helper.sendMessage(component, {type: 'items', items: component.get('v.data')});
        }, 3000);
    }
});

// R-T852DBVTL.AKOR
// AFC73089601
// ACQ76008501
// ABQ73601201
// MAN42250003
// AEH73676301
// AEH33499106