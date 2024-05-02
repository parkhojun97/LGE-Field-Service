/**
 * Created by sm.yang on 2022-11-13.
 */

({
    fnInit: function (component, event, helper) {
        //helper.getInitData(component);
    },

    fnSelectRow: function (component, event, helper) {
        console.log('selected Rows ');

        var selectedRows = event.getParam("selectedRows");
        console.log(selectedRows);
        console.log(JSON.stringify(selectedRows));
        if (selectedRows[0] == null || selectedRows[0] == undefined) {
            return;
        }
        component.set('v.selectedObject', selectedRows[0]);

        if (selectedRows[0].SUBSTITUTE == '원') {
            component.set("v.objOrigin", selectedRows[0]);
        } else {
            component.set("v.objCrossPart", selectedRows[0]);
        }


//        console.log('선택됨');
//        var selectedRows = event.getParam('selectedRows');
//        console.log('selectedRows :: '  + JSON.stringify(selectedRows));
//        // var listSelectRows = component.get('v.listSelectRows');
//        // listSelectRows.push(selectedRows);
//         component.set('v.listSelectRows', selectedRows[0]);
//
//        var objOrigin ;
//        var objCrossPart ;
//
//        for(var i in selectedRows){
//            if(selectedRows[i].SUBSTITUTE == '원'){
//                objOrigin = selectedRows[i];
//            } else {
//                objCrossPart = selectedRows[i];
//            }
//        }
//
//        component.set("v.objOrigin", objOrigin);
//        component.set("v.objCrossPart", objCrossPart);


    },

    //header 클릭 시 sort 처리
    fnColumnSorting: function (component, event, helper) {
        var sFieldName = event.getParam("fieldName");
        var sSortDirection = event.getParam("sortDirection");

        component.set("v.sSortBy", sFieldName);
        component.set("v.sSortDirection", sSortDirection);
        helper.doSorting(component, sFieldName, sSortDirection);
    },

    fnHandleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        var objOrigin = component.get("v.objOrigin");
        var objCrossPart = component.get("v.objCrossPart");


        component.set('v.listSelectRows', row);

        console.log('Start====================');
        console.log('row @@@@@@@@@@@');
        console.log(JSON.stringify(row));
        console.log('End====================');


        if (row.SUBSTITUTE == '원') {
            objOrigin = row;
        } else {
            objCrossPart = row;
        }

        var isExchangeOrder = component.get('v.isExchangeOrder');

        if (isExchangeOrder) {
            row.productRequestLineItemId = component.get('v.productRequestLineItemId');
        }


        component.set("v.objOrigin", objOrigin);
        component.set("v.objCrossPart", objCrossPart);

        // standard record page 로 이동 record action 이 여러개 일때 typeAttributes 로 구분해서 이벤트 처리가 가능
        switch (action.name) {
            case 'addOrder':
                console.log(JSON.stringify(row));
                //TODO : 230418 테스트를 위한 임시 주석처리
                if (!isExchangeOrder) { // 24 01 08 PHJ
                    if (row.PART_TYPE != 'Y') {
                        return helper.showToast('warning', '소모품만 주문가능합니다.');
                    }
                }
                if (row.fm_Available_Quantity == 0 && row.DISABLED_TYPE == 'Y') {
                    var evt = $A.get("e.force:showToast");
                    evt.setParams({
                        type: 'warning',
                        message: '단종된 상품은 구매할 수 없습니다.'
                    });
                    evt.fire();
                    return;
                }
                if (row.PARCEL_YN != 'Y') {
                    return helper.showToast('warning', '현장 판매 상품입니다.');
                }
                if (isExchangeOrder) {
                    var customerPrice = component.get('v.customerPrice');
                    var originConsumerPrice = component.get('v.originConsumerPrice');

                    console.log('customerPrice -> ' + customerPrice);
                    console.log('originConsumerPrice -> ' + originConsumerPrice);
                    console.log('row.Price ' + row.Price);
                    if (customerPrice == undefined) {
                        return helper.showToast('warning', '회수 부품 정보를 선택 하여야 합니다.');
                    }

                    var ChannelTypeCode = component.get('v.ChannelTypeCode');
                    console.log('ChannelTypeCode -> ' + ChannelTypeCode);
                    console.log('originProductId => ' + component.get('v.originProductId'));

                    // 소모품 택배 주문인 경우
                    if (ChannelTypeCode == 'V') {
                        // 타부품 && 가격동일
                        if (component.get('v.originProductId') != row.sProductId) {
                            if (originConsumerPrice != row.Price) {
                                return helper.showToast('warning', '해당 부품의 가격이 동일하지 않은 경우 교환 요청을 진행 할 수 없습니다.');
                            }
                        } else {
                            // 원부품 && 가격상이
                        }

                    } else {
                        // 원부품 && 가격동일
                        if (component.get('v.originProductId') != row.sProductId) {
                            return helper.showToast('warning', '원 부품만 교환요청이 가능 합니다.');
                        }

                        // if (originConsumerPrice != row.Price) {
                        //     return helper.showToast('warning', '해당 부품의 가격이 동일하지 않은 경우 교환 요청을 진행 할 수 없습니다.');
                        // }
                    }


                    row.originConsumerPrice = originConsumerPrice;

                    console.log('row.originConsumerPrice -> ' + row.originConsumerPrice);
                }
                if (row.fm_Available_Quantity > 0) {
                    var appEvt = $A.get("e.c:EX_Supplies_evt");

                    appEvt.setParams({
                        'delimiter': component.get("v.strTabId")
                        , 'data': row
                        , 'type': 'add'
                        , 'purchaseType': 'standard'
                    });
                    appEvt.fire();

                } else {
                    if (!isExchangeOrder) {
                        var appEvt = $A.get("e.c:EX_Supplies_evt");
                        appEvt.setParams({
                            'delimiter': component.get("v.strTabId")
                            , 'data': row
                            , 'type': 'add'
                            , 'purchaseType': 'soldOut'
                        });
                        appEvt.fire();
                    } else {
                        return helper.showToast('warning', '교환 주문 시 품절 주문은 불가능 합니다.');
                    }
                }
                break;

            default:
                break;
        }
    },

    fnPartChange: function (component, event, helper) {
        // todo : 제거 필요
        // component.set("v.isSpinner", true);
        // helper.getInitData(component);
    },

    fnImgClick: function (component, event, helper) {
        console.log("image click event");
        var imgSrc = event.target.dataset.src;
        console.log(">>" + event.target.dataset.src);

    },

    /**
     * @description 소모품 택배 주문 화면에서 고객 대상 Kakao 알림톡 발송 기능
     * @param component
     * @param event
     * @param helper
     * @author 22.12.22 / I2MAX.SEOKHOLEE
     */
    fnOpenKakao: function (component, event, helper) {
        var selectedObject = component.get("v.selectedObject");
        var evt = $A.get("e.force:showToast");
        if (selectedObject === null) {
            evt.setParams({
                type: 'error',
                message: '부품을 선택해주세요.'
            });
            evt.fire();
            return;
        }
        if (selectedObject.OBS_ITEM_YN === 'N') {
            evt.setParams({
                type: 'error',
                message: '온라인 판매 상품이 아닙니다.'
            });
            evt.fire();
            return;
        }

        var objCont = component.get("v.objCont");
        console.log('contact : ' + JSON.stringify(objCont));

        component.set("v.kakaoModal", true);
    },

    /**
     * @description 소모품 택배 주문 화면에서 고객 대상 Kakao 알림톡 발송 기능
     * @param component
     * @param event
     * @param helper
     * @author 22.12.28 / I2MAX.SEUNGHUNAN
     */
    fnCloseKakao: function (component, event, helper) {
        console.log('fn Close Kakao');
        component.set("v.kakaoModal", false);
    },

    /**
     * @description 카카오 모달 종료시 다음 사용을 위해 Content initialize
     * @param component
     * @author 23.01.16 / I2MAX.SEUNGHUNAN
     */
    fnKaKaoModalInit: function (component) {
        var kakaoModal = component.get("v.kakaoModal");
        if (!kakaoModal) {
            component.set("v.templateContent", "");
        }
    },
    onclickOBS: function (component, event, helper) {
        var auraId = event.getSource().getLocalId();
        var part = '';
        console.log('auraId => ' + auraId)
        if (auraId == 'originPart') {
            part = component.get('v.objOrigin');
        } else {
            part = component.get('v.objCrossPart');
        }
        var obsSalesUrl = part.ObsSalesURL;

        console.log(JSON.stringify(part))

        if (!$A.util.isEmpty(obsSalesUrl)) {
            window.open(obsSalesUrl, '_blank');
        } else {
            helper.showToast('info', '온라인 사이트 상품 구매 페이지가 존재하지 않습니다.');
        }
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

    saveMessageObjAndCheck: function (component) {

    },

    /**
     * @description 소모품 알림톡 발송 전 사용자 Confirm 및 Preview
     * @param component
     * @param event
     * @param helper
     * author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    dmlBeforeKaKao: function (component, event, helper) {
        var selectedRows = component.get('v.selectedObject');
        var dialog = component.find('dialog');
        // var templateCode = 'SVC_LGE_MACN_014';
        var templateCode = 'SVC_LGE_MACN_014_03'; //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가
        var param = {
            message: '알림톡을 전송하시겠습니까?'
        };

        helper.saveMessageObj(component, selectedRows, templateCode);

        dialog.confirm(param, function (response) {
            console.log('dialog confirm : ' + component.get('v.messageObjectId'));

        }, 'OBS');
    },

    fnReceiveEvt: function (component, event, helper) {
        // 회수부품정보에서 삭제 이벤트 Fire
        // 삭제 이벤트 fire
        console.log('fnReceiveEvt -> 부품확인');
        console.log(event.getParam('evtType'));

        // 회수부품정보에서 삭제 이벤트 Fire
        // 삭제 이벤트 fire
        console.log('fnReceiveEvt -> 부품확인');
        console.log(event.getParam('evtType'));

        if (event.getParam('evtType') == 'remove') {
            component.set('v.listSelectRows', []);
            component.set('v.listData', []);
        } else {
            console.log('교환주문 소모품 Part No Set start');
            var partId = event.getParam('productId');
            var divCode = event.getParam('divCode');
            var partNo = event.getParam('productCode');
            var productRequestLineItemId = event.getParam('itemId');
            var customerPrice = event.getParam('customerPrice');
            var originConsumerPrice = event.getParam('originConsumerPrice');
            var ChannelTypeCode = event.getParam('ChannelTypeCode');
            var originProductId = event.getParam('originProductId');
            var requestedReturnQuantity = event.getParam('requestedReturnQuantity');
            var curPartNo = component.find('PART_NO').get('v.value');

            component.set("v.PARTID", partId);
            component.set("v.DIVCODE", divCode);
            component.set("v.partNo", partNo);
            component.set('v.productRequestLineItemId', productRequestLineItemId);
            component.set('v.customerPrice', customerPrice);
            component.set('v.originConsumerPrice', originConsumerPrice);
            component.set('v.originProductId', originProductId);
            component.set('v.requestedReturnQuantity', requestedReturnQuantity);

            if (event.getParam('ChannelTypeCode') != undefined && event.getParam('ChannelTypeCode') != null && event.getParam('ChannelTypeCode') != '') {
                component.set('v.ChannelTypeCode', ChannelTypeCode);
            }
            console.log('customerPrice -> ');
            console.log(component.get('v.customerPrice'));

            console.log('originConsumerPrice -> ');
            console.log(component.get('v.originConsumerPrice'))

            console.log('ChannelTypeCode -> ');
            console.log(event.getParam('ChannelTypeCode'));

            console.log('curPartNo :: ' + curPartNo);
            component.find("PART_NO").set("v.value", partNo);

            //this.clickSearch(component, event, helper);
            if (event.getParam('evtType') != 'edited') {
                var partNo = component.find("PART_NO").get("v.value");
                component.set('v.PARTID', '');
                component.set("v.partNo", partNo);
                component.set('v.isSBOM', false);
                component.set('v.DIVCODE', '');
                component.find("PART_NO").set("v.value", partNo);
                if (!helper.isNull(partNo)) {
                    helper.getInitData(component, event);
                } else {
                    helper.showToast('warning', '부품번호를 입력해 주세요.');
                }
            }
        }

    },

    /**
     * @description 알림톡 종류 선택 모달
     * @param component
     * author 23.04.19 / I2MAX.SEUNGHUNAN
     */
    openBranchModal: function (component) {
        component.set('v.alarmOption', []);
        var alarmOption = component.get('v.alarmOption');
        var selectedObject = component.get('v.selectedObject');
        if (selectedObject != null) {
            if (selectedObject.ObsSalesURL != null && selectedObject.ObsSalesURL != '') {
                alarmOption.push({'label': '제품페이지', 'value': 'ObsSalesURL'});
            }
            if (selectedObject.ObsImageUrl != null && selectedObject.ObsImageUrl != '') {
                alarmOption.push({'label': '대표이미지', 'value': 'ObsImageUrl'});
            }
        }
        component.set('v.branchModal', true);
    },

    /**
     * @description Branch Modal Close
     * @param component
     * @param event
     * @param helper
     * @author 23.04.19 / I2MAX.SEUNGHUNAN
     */
    fnCloseBranch: function (component, event, helper) {
        var btnLabel = event.getSource().get('v.label');
        var selectedObject = component.get('v.selectedObject');
        var selectedAlarm = component.get('v.selectedAlarm');

        if (btnLabel == '선택') {
            if (selectedAlarm == null || selectedAlarm == '') {
                helper.showToast('error', '알림톡 종류를 선택해주세요.');
                return;
            }
            if (selectedObject == null || selectedObject == undefined) {
                helper.showToast('error', '선택된 부품이 없습니다.');
                return;
            }
            helper.saveTmpMessageObj(component);
            // spinner
            component.set('v.branchModal', false);
            component.set('v.kakaoModal', true);
        } else {
            component.set('v.branchModal', false);
        }
        component.set('v.selectedAlarm', null);
    },


    fnEnter: function (component, event, helper) {
        if (event.which == 13) {
            var partNo = component.find("PART_NO").get("v.value").replaceAll(' ', '');

            component.set('v.PARTID', '');
            component.set("v.partNo", partNo);
            component.set('v.isSBOM', false);
            component.set('v.DIVCODE', '');
            component.find("PART_NO").set("v.value", partNo);
            if (!helper.isNull(partNo)) {
                helper.getInitData(component, event);
            } else {
                helper.showToast('warning', '부품번호를 입력해 주세요.');
            }
        }
    },
    clickSearch: function (component, event, helper) {
        var partNo = component.find("PART_NO").get("v.value");
        // 2024.03.08 seung yoon heo 여백 제거 후 부품조회
        partNo = partNo.trim();
        
        var workspaceAPI = component.find("workspace");
        var evt = $A.get("e.c:EX_disabledMaterial_evt");
        component.set('v.PARTID', '');
        component.set("v.partNo", partNo);
        component.set('v.isSBOM', false);
        component.set('v.DIVCODE', '');
        component.find("PART_NO").set("v.value", partNo);
        if (!helper.isNull(partNo)) {
            helper.getInitData(component, event);
            var isSubMaterial = true;
            var originTabId = '';
            var forcusTabId = '';
            var isSubtab = false;
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                if (response.hasOwnProperty('tabId')) {
                    originTabId = response.tabId;
                    forcusTabId = originTabId.substring(0,originTabId.indexOf('_') != -1 ? originTabId.indexOf('_') : originTabId.length);
                    isSubtab = response.isSubtab;
                }
            });
            workspaceAPI.getAllTabInfo().then(function(response) {
                console.log('workSpacelogic  ?? ' , JSON.stringify(response));
                if (isSubtab) {
                    for (let i = 0; i < response.length; i++) {
                        if (forcusTabId == response[i].tabId) {
                            console.log(response[i].subtabs);  
                            var tabInfo = response[i].subtabs;
                        if (response[i].subtabs.length > 0) {
                            var existingTab = tabInfo.find(function(tab) {
                                console.log('tab' , tab);
                                return tab.url.includes('c__FS_MaterialPortal');
                            });
                            console.log('existingSubTab ?? ' , existingTab);
                        
                            if (existingTab == undefined) {
                                evt.setParam('isMaterialDisable' , false);
                                evt.fire();
                            } else {
                                evt.setParam('isMaterialDisable' , true);
                                evt.fire();
                            }
                        }
                    }
                }
                     
                } else {
                    
                    var existingTab = response.find(function(tab) {
                        return tab.url.includes('c__FS_MaterialPortal') || tab.url.includes('MaterialPortal');
                    });
                    console.log('existingTab ?? ' , existingTab);
                    if (existingTab == undefined) {
                        evt.setParam('isMaterialDisable' , false);
                        evt.fire();
                    } else {
                        evt.setParam('isMaterialDisable' , true);
                        evt.fire();
                    }
                }
            });
        } else {
            helper.showToast('warning', '부품번호를 입력해 주세요.');
        }

    },
    fnPartNoSetEvt: function (component, event, helper) {
        console.log('소모품 Part No Set start');
        var partId = event.getParam('pPartId');
        var divCode = event.getParam('pDivCode');
        var partNo = event.getParam('pPartNo');
        var modelName = event.getParam('pModelName');
        var partDesc = event.getParam('pPartDesc');
        var partSpec = event.getParam('pPartSpec');

        component.set("v.PARTID", partId);
        component.set("v.DIVCODE", divCode);
        component.set("v.modelName", modelName);
        component.set("v.PARTDESC", partDesc);
        component.set("v.PARTSPEC", partSpec);
        component.set("v.partNo", partNo);
        //24.02.02 gw.lee 중복 event발생 방지
        //component.set('v.isSBOM', event.getParam('pisSBOM'));
        helper.getInitData(component);

        component.find("PART_NO").set("v.value", component.get("v.partNo"));
    },

    partNoChange: function (component, event, helper) {
        // component.set("v.partNo", event.getParam("value"));
        component.find("PART_NO").set("v.value", component.get("v.partNo"));

        console.log("old value: ", event.getParam("oldValue"));
        console.log("current value: ", event.getParam("value"));
        console.log("partNo " + component.get("v.partNo"));
        if (component.get("v.partNo") != undefined && component.get("v.partNo") != null && component.get("v.partNo") != '') {
            console.log('getInitData Start@@@')
            // component.set('v.isSBOM', true);
            console.log('isSBOM ' + component.get('v.isSBOM'));
            helper.getInitData(component);
        }
    },


    /**
     * @description 알림톡 발송 버튼 Validation
     * @param component
     * @author 23.04.18 / I2MAX.SEUNGHUNAN
     */
    fnKaKaoBtnValidate: function (component) {
        var objCont = component.get('v.objCont');
        var selectedObject = component.get('v.selectedObject');
        var isExchangeOrder = component.get('v.isExchangeOrder');

        if (!isExchangeOrder) {
            if (objCont == null || selectedObject == null) {
                component.set('v.kakaoBtnDisabled', true);
                return;
            }

            component.set('v.kakaoBtnDisabled', selectedObject.OBS_ITEM_YN == 'N' ? true : false);
        }
    },

    /**
     * @description kakaoBtnDisabled 변경 시 Action
     * @param component
     * @author 23.04.18 / I2MAX.SEUNGHUNAN
     */
    fnKakaoBtnDisabledChange: function (component) {
        var kakaoBtn = component.find('kakaoBtn');
        var kakaoBtnDisabled = component.get('v.kakaoBtnDisabled');

        if (kakaoBtnDisabled == false) {
            kakaoBtn.set('v.class', 'gridSlaveBtn grid_height_100');
        } else {
            kakaoBtn.set('v.class', 'gridSlaveBtnDisabled grid_height_100');
        }
    },

    /**
     * @description 주문 고객이 바뀔 때 알림톡 번호 Setting
     * @param component
     * @param event
     * @param helper
     * @author 23.04.20 / I2MAX.SEUNGHUNAN
     */
    objContChg: function (component) {
        console.log('objContChg start@@@');
        var objCont = component.get('v.objCont');
        var receiverNumber = objCont.MobilePhone != null ? objCont.MobilePhone : objCont.Phone;
        component.set('v.receiverNumber', receiverNumber);
        console.log('objContChg end@@@');
    },

    fnPhoneChg: function (component, event, helper) {
        var IbCallNo = component.get("v.receiverNumber");
        IbCallNo = helper.gfnChgTelFormat(component, event, IbCallNo);
        component.set("v.receiverNumber", IbCallNo);
    },
    /**
     * @description 카카오 알림톡 발송
     * @param component
     * @param event
     * @param helper
     * @author 23.04.20 / I2MAX.SEUNGHUNAN
     */
    fnSendKakao: function (component, event, helper) {
        var exObjId = component.get('v.exObjId');
        var receiverNumber = component.get('v.receiverNumber');

        console.log('exObjId ::: ' + exObjId);
        helper.sendKaKaoMessage(component, exObjId, receiverNumber);
    },
    onWijmoMessage: function (component, event, helper) {
        //2023.12.11 seung yoon heo 위즈모 이벤트에 부품포탈 적용
        var workspaceAPI = component.find("workspace");
        var evt = $A.get("e.c:EX_disabledMaterial_evt");
        var originTabId = '';
        var forcusTabId = '';
        var isSubtab = false;
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;
        const selectedRow = payload.selectedRows;
        const item = payload.item;

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            if (response.hasOwnProperty('tabId')) {
                originTabId = response.tabId;
                forcusTabId = originTabId.substring(0,originTabId.indexOf('_') != -1 ? originTabId.indexOf('_') : originTabId.length);
                isSubtab = response.isSubtab;
            }
        }).catch(function(error) {
            console.log('error');
        });
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('workSpacelogic  ?? ' , JSON.stringify(response));
            if (isSubtab) {
                for (let i = 0; i < response.length; i++) {
                    if (forcusTabId == response[i].tabId) {
                        console.log(response[i].subtabs);  
                        var tabInfo = response[i].subtabs;
                    if (response[i].subtabs.length > 0) {
                        var existingTab = tabInfo.find(function(tab) {
                            console.log('tab' , tab);
                            return tab.url.includes('c__FS_MaterialPortal');
                        });
                        console.log('existingSubTab ?? ' , existingTab);
                    
                        if (existingTab == undefined) {
                            evt.setParam('isMaterialDisable' , false);
                            evt.fire();
                        } else {
                            evt.setParam('isMaterialDisable' , true);
                            evt.fire();
                        }
                    }
                }
            }
            } else {   
                var existingTab = response.find(function(tab) {
                    return tab.url.includes('c__FS_MaterialPortal') || tab.url.includes('MaterialPortal');
                });
                console.log('existingTab ?? ' , existingTab);
                if (existingTab == undefined) {
                    evt.setParam('isMaterialDisable' , false);
                    evt.fire();
                } else {
                    evt.setParam('isMaterialDisable' , true);
                    evt.fire();
                }
            }
        }).catch(function(error) {
            console.log('위error');
        });

        switch (payload.type) {
            case 'rowSelection':
                helper.fnWijmoSelectRow(component, event, helper, selectedRow);
                break;
            case 'rowAction':
                if ('Add' === actionName) {
                    helper.fnWijmoHandleRowAction(component, event, helper, row, 1);
                }
                break;
            case 'dblclick':
                if (component.get('v.isExchangeOrder') == true) {
                    helper.fnWijmoHandleRowAction(component, event, helper, item, 1);
                } else {
                    // 2024.01.12 seung yoon heo 더블클릭시에도 장바구니와 같은 이벤트 발생
                    // helper.fnWijmoHandleRowAction(component, event, helper, item, 0);
                    helper.fnWijmoHandleRowAction(component, event, helper, item, 1);
                }
                break;

        }
    },
});