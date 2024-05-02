/**
 * Created by sm.yang on 2022-11-13.
 */

({
    getInitData: function (component, helper) {
        component.set('v.isSpinner', true);
       
        console.log('getInitData Start!');
        var objPart = component.get("v.objPartInfo");

        var partId = component.get("v.PARTID");
        var divCode = component.get("v.DIVCODE");
        var modelName = component.get("v.modelName");
        var partDesc = component.get("v.PARTDESC");
        var partSpec = component.get("v.PARTSPEC");
        var partNo = component.get("v.partNo");
        var isSBOM = component.get('v.isSBOM');

        console.log("PARTID : : : ", partId);
        console.log("DIVCODE ::", divCode);
        console.log("partNo :: ", partNo);
        console.log("modelName :: ", modelName);
        console.log("PARTDESC ::", partDesc);
        console.log("PARTSPEC ::", partSpec);
        console.log("isSBOM ::", isSBOM);


        // 교환 주문 분기처리
        var isExchangeOrder = component.get('v.isExchangeOrder');
        console.log('isExchangeOrder => ' + isExchangeOrder);
        // 소모품 주문 일 때
        if (!isExchangeOrder) {
            var objParam;
            if (partDesc == 'fromIsMaterial' || objPart == undefined || objPart == "") {
                objParam = {
                    partId: partId,
                    productCode: partNo,
//                    divCode: divCode,
                    isSBOM: isSBOM
                }
            } else {
                objParam = {
                    partId: partId,
                    productCode: partNo,
//                    divCode: divCode,
                    isSBOM: isSBOM
                }
            }


        } else {
            // 소모품 교환 주문 일 때
            // console.log('소모품 교환 주문 ');
            //
            // var partId = component.get("v.PARTID");
            // var divCode = component.get("v.DIVCODE");
            // var modelName = component.get("v.modelName");
            // var partDesc = component.get("v.PARTDESC");
            // var partSpec = component.get("v.PARTSPEC");
            // var partNo = component.get("v.partNo");
            // var isSBOM = component.get('v.isSBOM');
            //
            // console.log("PARTID : : : ", partId);
            // console.log("DIVCODE ::" , divCode);
            // console.log("partNo :: ", partNo);
            // console.log("modelName :: ", modelName);
            // console.log("PARTDESC ::" , partDesc);
            // console.log("PARTSPEC ::" , partSpec);
            // console.log("isSBOM ::" , isSBOM);
            // console.log("productRequestLineItemId ::", component.get('v.productRequestLineItemId'));
            //
            //
            // if (objPart == null || objPart == undefined) {
            //     component.set('v.isSpinner', false);
            //     return;
            // }
            // // SBOM 으로 조회 시
            // if (objPart.productRequestLineItemId == undefined) {
            //     var objParam = {
            //         productCode: objPart.PART_NAME__r.ProductCode,
            //         modelProdId: objPart.MODEL_CODE__c,
            //         partDesc: objPart.fm_PART_DESC__c,
            //         divCode: objPart.DIV_CODE__c,
            //         mapNo: objPart.MAP_NO__c,
            //         partSpec: objPart.fm_PART_SPEC__c,
            //         locationId: '1310p0000001lRoAAI' //동대문서비스센터 임시.
            //     };
            //     if (objPart.PART_NAME__r) {
            //         objParam.partId = objPart.PART_NAME__r.Id;
            //     }
            // } else {
            //     component.set('v.RequestedReturnQuantity', objPart.RequestedReturnQuantity);
            //     component.set('v.productRequestLineItemId', objPart.productRequestLineItemId);
            //     var objParam = {
            //         productCode: objPart.productCode,
            //         modelProdId: objPart.modelProdId,
            //         partDesc: objPart.fm_PART_DESC__c,
            //         divCode: objPart.divCode,
            //         partId: objPart.partId
            //     };
            // }
            // 소모품 교환 주문 일 때
            console.log('소모품 교환 주문 ');

            var partId = component.get("v.PARTID");
            var divCode = component.get("v.DIVCODE");
            var modelName = component.get("v.modelName");
            var partDesc = component.get("v.PARTDESC");
            var partSpec = component.get("v.PARTSPEC");
            var partNo = component.get("v.partNo");
            var isSBOM = component.get('v.isSBOM');

            console.log("PARTID : : : ", partId);
            console.log("DIVCODE ::", divCode);
            console.log("partNo :: ", partNo);
            console.log("modelName :: ", modelName);
            console.log("PARTDESC ::", partDesc);
            console.log("PARTSPEC ::", partSpec);
            console.log("isSBOM ::", isSBOM);
            console.log("productRequestLineItemId ::", component.get('v.productRequestLineItemId'));

            var objParam = {
                partId: partId,
                productCode: partNo,
//                divCode: divCode,
                isSBOM: isSBOM
            }
        }


        var helperInstance = this;

        console.log('init objParam :: ' + JSON.stringify(objParam));


        
            var action = component.get("c.getInitData");
            action.setParams({
                params: JSON.stringify(objParam)
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
    
                if (state === "SUCCESS") {
    
                    var result = response.getReturnValue();
                    console.log(result);
                    console.log('JSONresult',JSON.stringify(result));
                    var ShipmentName = result.shipMentName;
                    if (result.listResult == null) {
                        component.set("v.isSpinner", false);
                        component.set("v.objOrigin", {});
                        component.set("v.objCrossPart", {});
                        return;
                    }
                    if (result.listResult && result["listResult"].length > 0) {
    //                    component.set("v.listSelectRows", result["listResult"][0].key);
                        component.set("v.objOrigin", result["listResult"][0]);
                        component.set("v.objCrossPart", {});
                    }
    
                    // 택배 제한 금액
                    var limitParseFee = component.get('v.parseFee');
    
                    var listData = result["listResult"];
                    listData.forEach((item) => {
    //                    if(isExchangeOrder) {
    //                        console.log('objPart.itemId -> ');
    //                        console.log(objPart.itemId);
    //                        item.Id = objPart.itemId;
    //                    }
    
                        if (item.DISABLED_TYPE == 'Y') {
                            item.DISABLED_YN_FONT_COLOR_RED = "font-color-red"
                            console.log('item.DISABLED_YN_FONT_COLOR_RED => ' + item.DISABLED_YN_FONT_COLOR_RED);
                        }
                        if (item.OBS_ITEM_YN == 'N') {
                            item.OBS_YN_FONT_COLOR_RED = "font-color-red"
                        }
                        if (item.PARCEL_YN == 'N') {
                            item.PARCEL_YN_FONT_COLOR_RED = "font-color-red"
                        }
                        if (item.Price < limitParseFee) {
                            item.PRICE_YN_FONT_COLOR_RED = "font-color-red"
                        }
                        if (item.DISABLED_TYPE == 'Y') {
                            item.All_Cell_Color = "font-color-red";
                            item.DISABLED_YN_FONT_COLOR_RED = "font-color-red";
                            item.OBS_YN_FONT_COLOR_RED = "font-color-red";
                            item.PARCEL_YN_FONT_COLOR_RED = "font-color-red";
                            item.PRICE_YN_FONT_COLOR_RED = "font-color-red";
                            component.set('v.DISABLED', true);
                        } else {
                            component.set('v.DISABLED', false)
                        }
                    });
                    helperInstance.setCol(component);

                    //24.01.09 gw.lee
                    //단종일 경우, 사업부 가용 == 0으로 표시
                    //전산, 가용수량 - 사업부 가용
                    for (let i = 0; i < listData.length; i++) {
                        listData[i].ShipmentName = ShipmentName[listData[i].DIVCODE] == undefined ? '부서정보없음' : ShipmentName[listData[i].DIVCODE];

                        if (listData[i].DIVQuantity > 0 && listData[i].DISABLED_TYPE == 'Y') {
                            listData[i].Computerized_Quantity = listData[i].Computerized_Quantity - listData[i].DIVQuantity;
                            listData[i].fm_Available_Quantity = listData[i].fm_Available_Quantity - listData[i].DIVQuantity;
                            listData[i].DIVQuantity = 0;

                            if (listData[i].Computerized_Quantity < 0) {
                                listData[i].Computerized_Quantity = 0;
                            }

                            if (listData[i].fm_Available_Quantity < 0) {
                                listData[i].fm_Available_Quantity = 0;
                            }
                        }

                        //24.03.14 gw.lee
                        //센터가용수량 표기 로직 추가 (이용석 책임님 요청)
                        listData[i].centerQuantity = listData[i].fm_Available_Quantity - listData[i].DIVQuantity < 0 ? 0 : listData[i].fm_Available_Quantity - listData[i].DIVQuantity;
                    }
    
                    if (!isExchangeOrder) {
                        component.set("v.selectedObject", listData[0]);
                    //23.10.19 gw.lee
                    //회수부품정보 => 교환부품 정보 바로 이동
                    } 
                    else if (isExchangeOrder) {
                        var passCheck = false;
                        for (var i = 0; i < listData.length; i++) {
                            if (listData[i] != undefined) {
                                passCheck = helperInstance.sendOrderData(component, helper, 'addOrder', listData[i]);
    
                                if (passCheck) {
                                    var appEvt = $A.get("e.c:EX_Supplies_evt");
    
                                    var ChannelTypeCode = component.get('v.ChannelTypeCode');
                                    listData[i].ChannelTypeCode = ChannelTypeCode == 'V' ? 'V' : 'X';
                                    listData[i].reqQty = component.get('v.requestedReturnQuantity');
                
                                    
                                    appEvt.setParams({
                                        'delimiter': component.get("v.strTabId")
                                        , 'data': listData[i]
                                        , 'type': 'add'
                                        , 'purchaseType': 'standard'
                                    });
                                    appEvt.fire();
        
                                    break;
                                }
                            }
                            
                        }
    
                        if (passCheck == false && listData.length != 0) {
                            helperInstance.showToast('warning', '교환 가능한 소모품이 존재하지 않습니다.');
                        }
                    }
    
                    //23.11.16 gw.lee
                    //부품확인 정렬 조치
                    //1. 유형 (원), 2. 단종여부 (N, Y), 3. 수량
                    if (listData.length > 0) {
                        console.log('buttonCheckForWijmo');
                        
                        // const orderBy = ['원', '일방대치', '쌍방대치']; 
                        const orderBy = ['원', '쌍방대치', '일방대치']; //24 01 02 hyungho.chun 일방대치가 쌍방대치보다 우선순위로 들어가게
                        
    
                        listData = listData.sort(function(a, b) {
                            var s1 = a['SUBSTITUTE']; 
                            var s2 = b['SUBSTITUTE'];
                            var d1 = a['DISABLED_TYPE']; 
                            var d2 = b['DISABLED_TYPE'];
                            var f1 = a['fm_Available_Quantity']; 
                            var f2 = b['fm_Available_Quantity'];
    
                            if (orderBy.indexOf(s2) != '-1' && orderBy.indexOf(s1) == '-1') {
                                return 1;
                            } else if (orderBy.indexOf(s2) == '-1' && orderBy.indexOf(s1) == '-1') {
                                if (s1 < s2) {
                                    return -1;
                                } else if (s1 > s2) {
                                    return 1;
                                }
                            } else if (orderBy.indexOf(s2) == '-1') {
                                return -1;
                            }
                            
                            if (orderBy.indexOf(s1) < orderBy.indexOf(s2)) {
                                return -1;   
                            } else if (orderBy.indexOf(s1) > orderBy.indexOf(s2)) {
                                return 1;
                            }
    
                            if (d1 < d2) {
                                return -1;   
                            } else if (d1 > d2) {
                                return 1;
                            }
                            
                            if (f1 < f2) {
                                return 1;   
                            } else if (f1 > f2) {
                                return -1;
                            }
                            return 0;
                        });
                    }
                    
                    console.log('promisAll ?? ' , listData);
                    helperInstance.sendMessage(component, {type: 'items', items: listData});
                    component.set("v.listData", listData);
                    component.set("v.isSpinner", false);

                    console.log('mainDataPrimis ?? ' , listData);

                    // sung yoon heo 값 인입시 sbom 초기화
                    component.set('v.isSBOM', false);
                    
                    // component.set("v.listData", listData);
                    // this.sendMessage(component, {type: 'items', items: listData});
                    // component.set("v.isSpinner", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helperInstance.showToast('error', errors[0].message);
                            console.log("Error message: " + errors[0].message);
                            component.set("v.isSpinner", false);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    
                }
    
                // component.set("v.isSpinner", false);
            });
            $A.enqueueAction(action);
       

        // return mainDataPromois.then(function(mainData){
        //     return new Promise(function(resolve, reject){
        //         console.log('제대로 오는지 확인', mainData);
        //         if (mainData.length > 0) {
             
        //             var action = component.get('c.getShipmentName');
        //             action.setParams({
        //                 divCodeList : divCodeList
        //             });
        //             action.setCallback(this, function (response) {
        //                 var state = response.getState();
        //                 if (state === "SUCCESS") {
        //                     var result = response.getReturnValue();
        //                     console.log('출고부서 값  ?? ' , result);


                        
                
        //                     resolve(result);

        //                 } else if (state === "ERROR") {
                            
        //                 }

        //             });
        //             $A.enqueueAction(action);
        //         }
        //     });
        // });

        // Promise.all([mainDataPromois, ShipmentName]).then(function(result){
       
        // });
      
    },

    //23.10.19 gw.lee
    //교환 시 바로 호출하도록
    sendOrderData: function (component, helper, actionName, row) {
        var isExchangeOrder = component.get('v.isExchangeOrder');

        switch (actionName) {
            case 'addOrder':
                // console.log(JSON.stringify(row));
                //TODO : 230418 테스트를 위한 임시 주석처리
                if (!isExchangeOrder) { // 24 01 08 PHJ
                    //24.01.09 gw.lee
                    //교환 가능
                    // if (row.PART_TYPE != 'Y') {
                    //     // return this.showToast('warning', '소모품만 주문가능합니다.');
                    //     return false;
                    // }
                }
                if (row.fm_Available_Quantity == 0 && row.DISABLED_TYPE == 'Y') {
                    // var evt = $A.get("e.force:showToast");
                    // evt.setParams({
                    //     type: 'warning',
                    //     message: '단종된 상품은 구매할 수 없습니다.'
                    // });
                    // evt.fire();
                    return false;
                }
                if (row.PARCEL_YN != 'Y') {
                    //return this.showToast('warning', '현장 판매 상품입니다.');
                    return false;
                }
                if (isExchangeOrder) {
                    var customerPrice = component.get('v.customerPrice');
                    var originConsumerPrice = component.get('v.originConsumerPrice');

                    console.log('customerPrice -> ' + customerPrice);
                    console.log('originConsumerPrice -> ' + originConsumerPrice);
                    console.log('row.Price ' + row.Price);
                    if (customerPrice == undefined) {
                        //return this.showToast('warning', '회수 부품 정보를 선택 하여야 합니다.');
                        return false;
                    }


                    //23.11.15 gw.lee
                    //채널 상관없이 금액이 같다면 대치품으로 교환 가능
                    // var ChannelTypeCode = component.get('v.ChannelTypeCode');
                    // console.log('ChannelTypeCode -> ' + ChannelTypeCode);
                    console.log('originProductId => ' + component.get('v.originProductId'));
                    if (component.get('v.originProductId') != row.sProductId) {
                        if (originConsumerPrice != row.Price) {
                            //return this.showToast('warning', '해당 부품의 가격이 동일하지 않은 경우 교환 요청을 진행 할 수 없습니다.');
                            return false;
                        }
                    }

                    row.originConsumerPrice = originConsumerPrice;

                    console.log('row.originConsumerPrice -> ' + row.originConsumerPrice);
                }
                if (row.fm_Available_Quantity > 0) {
                    //24.01.09 gw.lee
                    //단종일 경우, 요청수량이 가용 수량보다 클때 주문 불가
                    if (component.get('v.requestedReturnQuantity') > row.fm_Available_Quantity && row.DISABLED_TYPE == 'Y') {
                        return false;
                    } else {
                        component.set('v.selectedObject', row);
                
                        var objOrigin = component.get("v.objOrigin");
                        var objCrossPart = component.get("v.objCrossPart");
                
                        component.set('v.listSelectRows', row);
                
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
    
                        return true;
                    }
                } else {
                    if (!isExchangeOrder) {
                        component.set('v.selectedObject', row);
            
                    var objOrigin = component.get("v.objOrigin");
                    var objCrossPart = component.get("v.objCrossPart");
            
                    component.set('v.listSelectRows', row);
            
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
                        
                        return true;
                    } else {
                        // return helper.showToast('warning', '교환 주문 시 품절 주문은 불가능 합니다.');
                        return false;
                    }
                }
                break;

            default:
            break;
        }
    },
    // 조회 된 결과 값 내 sorting
    doSorting: function (component, sFieldName, sSortDirection) {
        var listData = component.get("v.listData");
        var reverse = sSortDirection !== "asc";

        listData.sort(this.doSortBy(sFieldName, reverse));

        component.set("v.selectedObject", listData[0]);
        component.set("v.listData", listData);


    },

    // javascript list (compareFunction) 활용한 sorting
    doSortBy: function (sFieldName, reverse, primer) {
        var key = primer ? function (x) {
            return primer(x[sFieldName])
        } : function (x) {
            return x[sFieldName]
        };
        reverse = !reverse ? 1 : -1;

        return function (a, b) {
            return a = key(a) ? key(a) : '', b = key(b) ? key(b) : '', reverse * ((a > b) - (b > a));
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
    setCol: function (component) {
        var cols = [
            {
                label: '',
                type: 'button-icon',
                initialWidth: 50

                ,
                typeAttributes: {
                    alternativeText: '장바구니 담기',
                    name: 'addOrder',
                    iconName: 'utility:cart',
                    disabled: {fieldName: 'actionDisabled'}
                }
            },
            {
                label: '유형',
                fieldName: 'SUBSTITUTE',
                type: 'text', initialWidth: 80,
                cellAttributes: {
                    class: {fieldName: 'All_Cell_Color'},
                    alignment: 'left'
                },
                typeAttributes: {
                    label: {fieldName: 'SUBSTITUTE'},
                    title: {fieldName: 'SUBSTITUTE'},
                    variant: 'base',
                    class: component.get('v.DISABLED') == true ? 'text-button' : 'text-button-black'
                }
            },
            {
                label: '사업부',
                fieldName: 'DIVCODE',
                type: 'text',
                initialWidth: 70,
                cellAttributes: {
                    class: {fieldName: 'All_Cell_Color'},
                    alignment: 'left'
                },
                typeAttributes: {
                    label: {fieldName: 'DIVCODE'},
                    title: {fieldName: 'DIVCODE'},
                    variant: 'base',
                    class: component.get('v.DISABLED') == true ? 'text-button' : 'text-button-black'
                }
            },
            {
                label: 'Part No.',
                fieldName: 'ProductCode',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'left'}
                ,
                typeAttributes: {
                    label: {fieldName: 'ProductCode'},
                    title: {fieldName: 'ProductCode'},
                    variant: 'base',
                    class: component.get('v.DISABLED') == true ? 'text-button' : 'text-button-black'
                }
            },

            {
                label: '품명',
                fieldName: 'ProductName',
                type: 'text',
                initialWidth: 200,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'left'},
                typeAttributes: {
                    label: {fieldName: 'ProductName'},
                    title: {fieldName: 'ProductName'},
                    variant: 'base',
                    class: component.get('v.DISABLED') == true ? 'text-button' : 'text-button-black'
                }
            },

            {
                label: '전산',
                fieldName: 'Computerized_Quantity',
                type: 'number',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'}
            },
            {
                label: '가용',
                fieldName: 'fm_Available_Quantity',
                type: 'number',
                initialWidth: 80,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'},
                typeAttributes: {
                    label: {fieldName: 'fm_Available_Quantity'},
                    title: {fieldName: 'fm_Available_Quantity'},
                    variant: 'base',
                    class: component.get('v.DISABLED') == true ? 'text-button' : 'text-button-black'
                }
            },
            {
                label: '할당',
                fieldName: 'RESRV_QTY',
                type: 'number',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'}
            },
//            {label: '미입고', fieldName: '', type: 'number', initialWidth: 110, cellAttributes : {class: { fieldName: ''}, alignment: 'right'}},
            {
                label: '지점총재고',
                fieldName: 'Total_Quantity',
                type: 'number',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'}
            },

            {
                label: '소비자가',
                fieldName: 'Price',
                type: 'number',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'PRICE_YN_FONT_COLOR_RED'}, alignment: 'right'}
            },
            {
                label: '지정점가',
                fieldName: 'ASCPrice',
                type: 'number',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'}
            },
            {
                label: '온라인 전시 여부',
                fieldName: 'OBS_ITEM_YN',
                type: 'text',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'left'}
            },
            {
                label: '택배 가능 여부',
                fieldName: 'PARCEL_YN',
                type: 'text',
                initialWidth: 110,
                cellAttributes: {class: {fieldName: 'PARCEL_YN_FONT_COLOR_RED'}, alignment: 'left'}
            },
            {
                label: '소모품 여부',
                fieldName: 'PART_TYPE',
                type: 'text',
                initialWidth: 100,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'left'}
            },
            {
                label: '단종 여부',
                fieldName: 'DISABLED_TYPE',
                type: 'text',
                initialWidth: 100,
                cellAttributes: {class: {fieldName: 'DISABLED_YN_FONT_COLOR_RED'}, alignment: 'left'}
            }
            // {label: 'Care', fieldName: 'SUB_SYMP_NAME__c', type: 'text', initialWidth: 70}

        ];
        component.set("v.listColumns", cols);
    },

    /**
     * @description 소모품 알림톡 발송 전 소모품 메시지 Object Insert
     * @param component
     * @param event
     * @param helper
     * author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    saveMessageObj: function (component, selectedObject, templateCode) {
        var action = component.get('c.insertExMessageObj');
        var dialog = component.find('dialog');

        action.setParams({
            'selectedObjectStr': JSON.stringify(selectedObject),
            'templateCode': templateCode
        });

        dialog.set('v.showSpinner', true);
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.messageObjectId', returnValue);
                console.log('return Value : ' + returnValue);
                if (returnValue != undefined && returnValue.includes('ERROR')) {
                    this.showToast('error', '알림톡 ' + returnValue);
                    dialog.set('v.showSpinner', false);
                    dialog.set('v.isOpen', false);
                }
                component.set('v.isSpinner', false);
                dialog.set('v.showSpinner', false);
            } else if (response.getState() === 'ERROR') {
                this.showToast('error', '알림톡 초기화 실패');
                component.set('v.messageObjectId', null);
                dialog.set('v.showSpinner', false);
                dialog.set('v.isOpen', false);
            }
        });

        $A.enqueueAction(action);
    },

    // Null 체크
    isNull: function (sValue) {
        if (new String(sValue).valueOf() == "undefined")
            return true;
        if (sValue == null)
            return true;
        if (("x" + sValue == "xNaN") && (new String(sValue.length).valueOf() == "undefined"))
            return true;
        if (sValue.length == 0)
            return true;

        return false;
    },

    getItem: function (component, event) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getItemListByConsumable");
        action.setParams({
            // "sortingField": component.get("v.selectedSortingField"),
            // "isSortAsc": component.get("v.isSortAsc"),
            "DIVCODE": component.get("v.DIVCODE"),
            "partNo": component.get("v.partNo"),
            "ModelName": component.get("v.modelName"),
            "PARTID": component.get("v.PARTID"),
            "PARTDESC": component.get("v.PARTDESC"),
            "locationId": component.get("v.locationId"),
            "isSBOM": component.get("v.isSBOM")
        });
        console.log('[getItem] PARTID :: ::', component.get("v.PARTID"));
        console.log('[getItem] DIVCODE :: ::', component.get("v.DIVCODE"));
        console.log('[getItem] partNo :: ::', component.get("v.partNo"));
        console.log('[getItem] PARTDESC :: ::', component.get("v.PARTDESC"));
        console.log('[getItem] isSBOM :: ::', component.get("v.isSBOM"));
        // var locationId = component.get("v.locationId");
        action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var resultData = JSON.parse(result);

                    // component.set("v.item", resultData.item);

                    component.set("v.partlist", resultData.partitem);
                    component.set("v.sublist", resultData.subitem);

                    var item = resultData.partitem;
                    resultData.subitem.forEach(value => {
                        item.push(value);
                    });
                    item.forEach(item => {
                        switch (item.PartType) {
                            case 'A':
                                item.PartType = '핵심부품';
                                break;
                            case 'B':
                                item.PartType = '수리부품';
                                break;
                            case 'C':
                                item.PartType = '일반부품';
                                break;
                            case 'D':
                                item.PartType = '소모품';
                                break;
                            default:
                                item.PartType = '';
                        }
                        item.isSBOM = component.get('v.isSBOM');

                    })

                    component.set("v.item", item);

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    this.toastError(errors);
                }
                console.log('result', result);
                component.set("v.showSpinner", false);
            }
        );
        // if(locationId ==null) component.set("v.item",null);
        $A.enqueueAction(action);
    },

    /**
     * @description 소모품 알림(알림톡, SMS) 재전송 전 소모품 임시 메시지 Object 저장
     * @param component
     * @param selectedObject
     * @param selectedAlarm
     * author 23.02.04 / I2MAX.SEUNGHUNAN
     */
    saveTmpMessageObj: function (component) {
        var selectedObject = component.get('v.selectedObject');
        var selectedAlarm = component.get('v.selectedAlarm');
        if (selectedObject == null) {
            this.showToast('error', '선택된 부품이 없습니다.');
            return;
        }
        /**
         * selectedAlarm은 'ObsSalesURL', 'ObsImageURL' 둘 중 하나이다.
         * URL 분기(대표이미지, 제품페이지)에 사용한다.
         */
        //23.10.13 PHJ
        var contName = component.get('v.objCont').Name;
        
        var action = component.get('c.saveMessageObject');
        action.setParams({
            'jsonString': JSON.stringify(selectedObject),
            'urlBranch': selectedAlarm,
            //23.10.13 PHJ
            'contName': contName
        });
        component.set('v.isSpinner', true);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.exObjId', returnValue['exObjId']);
                component.set('v.receiverMsg', returnValue['receiverMsg']);
                component.set('v.branchModal', false);
                component.set('v.kakaoModal', true);
                component.set('v.isSpinner', false);

                console.log('exObjId :: ' + component.get('v.exObjId'));
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
                component.set('v.branchModal', false);
                component.set('v.exObjId', null);
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * @description 택배주문화면 KaKao 알림톡 발송(대표이미지, 제품페이지)
     * @param component
     * @param exObjId
     * @param receiverNumber
     * author 23.04.20 / I2MAX.SEUNGHUNAHN
     */
    sendKaKaoMessage: function (component, exObjId, receiverNumber) {
        //23.10.17 PHJ modify
        // var templateCode = 'SVC_LGE_MACN_014_02';
        var templateCode = 'SVC_LGE_MACN_014_03'; //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가
        var action = component.get('c.sendKaKao');
        var objCont = component.get('v.objCont');
        var objContNumber = objCont.MobilePhone != null ? objCont.MobilePhone : objCont.Phone;
        action.setParams({
            'templateCode': templateCode,
            'objectId': exObjId,
            'phoneNumber': receiverNumber
        });

        component.set('v.isSpinner', true);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isSpinner', false);
                var result = response.getReturnValue();
                console.log(result['isSuccess']);

                if (result['isSuccess'] == true) {
                    this.showToast('success', '알림톡 발송 성공');
                } else {
                    this.showToast('error', '알림톡 발송 실패');
                }
                component.set('v.kakaoModal', false);
                component.set('v.receiverMsg', '');
                component.set('v.receiverNumber', objContNumber);
            } else if (state === 'ERROR') {
                this.showToast('error', '알림톡 발송 실패');
                component.set('v.isSpinner', false);
                component.set('v.kakaoModal', false);
                component.set('v.receiverMsg', '')
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Phone Number 정제 함수
     * @param component, event, helper
     * author 23.02.15 / I2MAX.SEOKHOLEE
     */
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

            //23.11.21 PHJ modify '010'이 들어가지 않으면 "####-###-####" 형식으로 변환
            case '11' :
                if(strTel.includes('010')){
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 4);
                    strSetValue += '-' + strTel.substr(7); //"###-####-####";
                } else {
                    strSetValue = strTel.substr(0, 4);
                    strSetValue += '-' + strTel.substr(4, 3);
                    strSetValue += '-' + strTel.substr(7); //"####-###-####";
                }
                break;
            //23.11.21 PHJ modify 12자리이면 "####-####-####" 형식으로 변환
            case '12':
                // strSetValue = strTel.substr(0, 3);
                // strSetValue += '-' + strTel.substr(3, 4);
                // strSetValue += '-' + strTel.substr(7, 4);
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4, 4);
                strSetValue += '-' + strTel.substr(8, 4);
                break;

            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },
    fnWijmoHandleRowAction: function (component, event, helper, row, count) {

        var selectedRows = [];
        selectedRows.push(row);

        console.log(selectedRows);
        console.log(JSON.stringify(selectedRows));
        if (selectedRows[0] == null || selectedRows[0] == undefined) {
            component.set('v.selectedObject', null);
            component.set('v.kakaoBtnDisabled', true);
            return;
        }
        component.set('v.selectedObject', selectedRows[0]);

        if (selectedRows[0].SUBSTITUTE == '원') {
            component.set("v.objOrigin", selectedRows[0]);
        } else {
            component.set("v.objCrossPart", selectedRows[0]);
        }



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


        console.log(JSON.stringify(row));
        //TODO : 230418 테스트를 위한 임시 주석처리
        if (row.PART_TYPE != 'Y') {
            // return helper.showToast('warning', '소모품만 택배주문 가능합니다.');
            // helper.showToast('warning', '소모품만 택배주문 가능합니다.');  // 23 12 27 hyungho.chun return만 일단 뺴보고 테스트 //23 12 28 hyungho.chun 토스트메시지도 제거
        }
     
        var objPassCheck = false;

            
        //todo 가용재고관련 이벤트
        var appEvt = $A.get("e.c:EX_Supplies_evt");
        var listData = component.get('v.listData');
        var reqQuantity = component.get('v.requestedReturnQuantity');
        var strTabId = component.get("v.strTabId");
        var sendData = {};
        var crossPartCheck = false;


        // 현장 판매 상품 Note는 다 들어감
        if (row.PARCEL_YN != 'Y') {
            //24.03.08 PHJ
            // row.Note = '현장 판매 상품';
            row.Note = '택배 불가 상품';
        }
        // 클릭한 row에 가용재고가 존재
        if (row.fm_Available_Quantity > 0 ) { 
            // 쌍방이든 원이든 우선 단종여부와는 별개로 재고가 존재하면 event 발생하는게 맞음
            // 클릭한 row가 원이든 쌍방이든 일반이든 단종이면서 재고가 존재하면 밑(orderList)으로 내림

            listData.forEach((item) => {
                if (row.Id == item.Id) {
                    row.ObsImageUrl = item.ObsImageUrl;
                    row.ObsSalesURL = item.ObsSalesURL;
                    row.PartNameKor = item.PartNameKor;
                    row.ObsMemberPrice = item.ObsMemberPrice;
                }
                //선택한 row가 원이 아닌 대치 품목이며 list의 item이 원인경우 원부품 번호 및 crossPartCheck를 true로 이벤트 전송
                //orderlist에 data가 있는경우 원부품을 대치품으로 바꾼다는 모달 발생해야함
                if (row.SUBSTITUTE != '원' && item.SUBSTITUTE == '원') {
                    row.wonPartNum = item.ProductCode;
                    crossPartCheck = true;
                }

            });
            
            appEvt.setParams({
                'delimiter': strTabId
                , 'data': row
                , 'type': count == 0 ? 'click' : 'add'
                , 'purchaseType': 'standard'
                , 'requestedReturnQuantity' : reqQuantity
                , 'crossPartCheck' : crossPartCheck
            });

        } else {
            // 품절주문의 경우
            if (!isExchangeOrder) {
                // 교환주문 분기
                if (row.DISABLED_TYPE == 'Y') {
                    if (row.SUBSTITUTE == '원') {
                        // 선택한 row가 원이며 재고가 가용재고가 없는 경우 list에 원이나 쌍방 혹은 일방중 재고가 있는 가장 가까운 데이터 검색
                        // list의 데이터가 가용재고가 0이며 원인경우 또는 가용재고가 존재하는 원,쌍방,일방대치가 있는경우 return
                        sendData = listData.find(val => (val.DISABLED_TYPE != 'Y' && val.fm_Available_Quantity == 0 && (val.SUBSTITUTE == '원' || val.SUBSTITUTE == '쌍방대치' || val.SUBSTITUTE == '일방대치')) || (val.fm_Available_Quantity > 0 && (val.SUBSTITUTE == '원' || val.SUBSTITUTE == '쌍방대치' || val.SUBSTITUTE == '일방대치' )));
                        // 데이터가 존재한다면 해당 데이터의 원부품번호 넘겨줌
                        if (sendData) {
                            if (sendData.PARCEL_YN != 'Y') {
                                // 20240309 seung yoon heo 분해도 part 추가
                                // sendData.Note = '현장 판매 상품';
                                sendData.Note = '택배 불가 상품';
                            }
                            sendData.wonPartNum = row.ProductCode;
                            crossPartCheck = true;
                            // list에서 찾은 데이터의 가용재고가 0보다 큰경우 일반주문으로 작은경우엔 품절주문으로 내린다.
                            if (sendData.fm_Available_Quantity > 0) {
                                appEvt.setParams({
                                    'delimiter': strTabId
                                    , 'data': sendData
                                    , 'type': count == 0 ? 'click' : 'add'
                                    , 'purchaseType': 'standard'
                                    , 'requestedReturnQuantity' : reqQuantity
                                    , 'crossPartCheck' : crossPartCheck
                                });
                            } else {
                                appEvt.setParams({
                                    'delimiter': strTabId
                                    , 'data': sendData
                                    , 'type': count == 0 ? 'click' : 'add'
                                    , 'purchaseType': 'soldOut'
                                    , 'crossPartCheck' : crossPartCheck
                                });
                            }
                        } else {
                            // 클릭한 row데이터가 원이면서 sendData를 찾지 못한 경우 모든 품목이 해당 조건에 적절하지 않은경우
                            sendData = listData.find(val => val.SUBSTITUTE == '원');
                            sendData.wonPartNum = sendData.ProductCode;
                            appEvt.setParams({
                                'delimiter': strTabId
                                , 'data': sendData
                                , 'disabledCheck': true 
                            });
                        }
                    } else {
                        // 단종이면서 원 외의 부품 선택시
                        // list의 원부품은 없을수 없으므로 예외처리 불필요 해당 부품의 원부품을 보냄
                        sendData = listData.find(val => val.SUBSTITUTE == '원');
                        //만약 원부품이 없는 경우가 있다면 여기 예외처리
                        sendData.wonPartNum = 'errorToast';
                        //! 밑에 재고 원data가 있더라도 토스트만 표출 orderlist에서 에러나는지 확인 필요

                        appEvt.setParams({
                            'delimiter': strTabId
                            , 'data': sendData
                            , 'disabledCheck': true 
                        });
                    }
                } else {
                    // 단종이 아니면서 품절일 경우
                    appEvt.setParams({
                        'delimiter': strTabId
                        , 'data': row
                        , 'type': count == 0 ? 'click' : 'add'
                        , 'purchaseType': 'soldOut'
                    });
                }

            } else {
                return helper.showToast('warning', '교환 주문 시 품절 주문은 불가능 합니다.');
            }
        }

        // appEvt.fire(); //24 02 21 hyungho.chun 교환주문인경우 가능여부까지 체크 한 후 이벤트 송신으로 위치 isExchangeorder 조건문 이후로 내림
            

       
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

            //23.11.15 gw.lee
            //채널 상관없이 금액이 같다면 대치품으로 교환 가능
            // var ChannelTypeCode = component.get('v.ChannelTypeCode');
            // console.log('ChannelTypeCode -> ' + ChannelTypeCode);
            console.log('originProductId => ' + component.get('v.originProductId'));
            if (component.get('v.originProductId') != row.sProductId) {
                if (originConsumerPrice != row.Price) {
                    return this.showToast('warning', '해당 부품의 가격이 동일하지 않은 경우 교환 요청을 진행 할 수 없습니다.'); // 24 01 08 PHJ
                    // return false;
                }
                // 24 01 08 PHJ
                if (row.PARCEL_YN == 'N'){
                    return this.showToast('warning', '택배 가능 부품이 아닙니다.');
                }
            }

            row.originConsumerPrice = originConsumerPrice;


            console.log('row.originConsumerPrice -> ' + row.originConsumerPrice);
        }

        appEvt.fire(); //24 02 21 hyungho.chun 교환주문인경우 가능여부까지 체크 한 후 이벤트 송신으로 위치 isExchangeorder 조건문 이후로 내림
     

    },
    fnWijmoSelectRow: function (component, event, helper, row) {
        console.log('selected Rows ');

        var selectedRows = row;
        console.log(selectedRows);
        console.log(JSON.stringify(selectedRows));
        if (selectedRows[0] == null || selectedRows[0] == undefined) {
            component.set('v.selectedObject', null);
            return;
        }
        component.set('v.selectedObject', selectedRows[0]);

        if (selectedRows[0].SUBSTITUTE == '원') {
            component.set("v.objOrigin", selectedRows[0]);
        } else {
            component.set("v.objCrossPart", selectedRows[0]);
        }


    },
    sendMessage: function (component, msg) {
        console.log('위즈모');
        var isExchangeOrder = component.get('v.isExchangeOrder');

        if (isExchangeOrder) {
            component.find('wijmo_EXSuppliesPartTabLogisticsDisabled').message(msg);
        } else {
            component.find('wijmo_EXSuppliesPartTabLogistics').message(msg);
        }
    },
});