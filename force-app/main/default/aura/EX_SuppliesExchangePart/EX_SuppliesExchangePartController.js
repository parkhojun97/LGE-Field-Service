/**
 * Created by I2MAX.SEOKHOLEE on 2023-02-24.
 */

({
    fnInit: function (component, event, helper) {
        component.set('v.showSpinner', true);

        //component.set('v.objCont', null);
        component.set('v.contactId', null)
        helper.fnSetExchangeColumns(component, event, helper);
        // 소모품 교환 요청 데이터 재조회
        //helper.fnGetExchangeOrderData(component, event, helper);
        var action = component.get("c.doGetExchangeOrderData");
        action.setParams({
            'exchangeOrderData': component.get('v.exchangeReturnOrderData')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.showSpinner', false);
                component.set('v.exchangeReturnOrderData', result['itemTables']);
                component.set('v.ChannelTypeCode', result['ChannelTypeCode']);
                component.set('v.hasPointAmount', result['hasPointAmount']);
                component.set('v.hasOBSCHNL', result['hasOBSCHNL']);

                var exchangeReturnOrderData = component.get('v.exchangeReturnOrderData');

                var hasPointAmount = component.get('v.hasPointAmount');
                var hasOBSCHNL = component.get('v.hasOBSCHNL');

                var wijmoName = 'wijmo_EXexchangeReturnOrder';
                if (hasPointAmount || hasOBSCHNL) {
                    wijmoName = 'wijmo_EXexchangeDisabledReturnOrder';
                } else {
                    exchangeReturnOrderData.forEach(data => {
                        data.RequestedReturnQuantity = 0;
                    })
                }

                setTimeout(function(){
                    helper.sendMessage(component, {type:'items', items: exchangeReturnOrderData}, wijmoName);
                }, 1000);
                if(result['contact'] == undefined) {
                    component.set('v.objCont', null);
                } else {
                    component.set('v.objCont', result['contact']);
                }
                console.log('objCont '+ result['contact']);
                component.set('v.productRequestId', result['productRequestId']);
                helper.fnSetExchangeColumns(component);
            } else {
                var errors = response.getError();
                component.set('v.showSpinner', false);

                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
            }

        });
        $A.enqueueAction(action);

        // var hasPointAmount = component.get('v.hasPointAmount');
        // var exchagneReturnData = component.get('v.exchangeReturnOrderData');
        // console.log(exchagneReturnData[0].RequestedReturnQuantity);
        // console.log(exchagneReturnData[0].QuantityRequested);
        // var wijmoName = 'wijmo_EXexchangeReturnOrder';
        // if (hasPointAmount) {
        //     wijmoName = 'wijmo_EXexchangeDisabledReturnOrder';
        // } 

        // setTimeout(function(){
        //     var exchangeOrder = component.get('v.exchangeReturnOrderData');
        //     if (hasPointAmount) {
        //         exchangeOrder.forEach(data => {
        //             data.requestedReturnQuantity = 0;
        //         })
        //     }
        //     helper.sendMessage(component, {type:'items', items: component.get('v.exchangeReturnOrderData')}, wijmoName);
        // },1000);
    },

    fnSelected: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');

        if (selectedRows[0] == null || selectedRows[0] == undefined) {
            return;
        }
        component.set('v.listSelectRows', selectedRows);
        console.log('Start====================');
        console.log('선택한 회수부품정보의 값 : ');
        console.log(JSON.stringify(component.get('v.listSelectRows')));
        console.log('End====================');


        let objPartInfo = {};
        objPartInfo.productCode = selectedRows[0].ProductCode;
        objPartInfo.modelProdId = selectedRows[0].ModelId;
        objPartInfo.divCode = selectedRows[0].DIVCODE;
        objPartInfo.partId = selectedRows[0].sProductId;
        objPartInfo.productRequestLineItemId = selectedRows[0].productRequestLineItemId;
        objPartInfo.RequestedReturnQuantity = selectedRows[0].RequestedReturnQuantity;

        component.set('v.objPartInfo', objPartInfo);

        // 교환 제한 수량 주문수량 - (교환반품요청수량 + 반품수량 + 반품예정수량)
        let exchangeLimitedQuantity = 0;

        console.log('SalesQuantity -> ' + selectedRows[0].SalesQuantity);
        console.log('RequestedReturnQuantity -> ' + selectedRows[0].RequestedReturnQuantity);
        console.log('ReturnQuantity -> ' + selectedRows[0].ReturnQuantity);
        console.log('ExpectedReturnQuantity -> ' + selectedRows[0].ExpectedReturnQuantity);

        exchangeLimitedQuantity = parseInt(selectedRows[0].SalesQuantity) - (parseInt(selectedRows[0].RequestedReturnQuantity) + parseInt(selectedRows[0].ReturnQuantity) + parseInt(selectedRows[0].ExpectedReturnQuantity));

        // 소비자가 세팅
        component.set('v.customerPrice', selectedRows[0].Price);
        // 원 주문 단가 세팅
        component.set('v.originConsumerPrice', selectedRows[0].originConsumerPrice);

        // 회수부품정보 선택 시
        console.log('EX_SuppliesExchangePart_evt start @')
        var evt = $A.get("e.c:EX_SuppliesExchangePart_evt");
        evt.setParam('evtType', 'selected');
        evt.setParam('itemId', selectedRows[0].productRequestLineItemId);
        evt.setParam('productId', selectedRows[0].sProductId);
        evt.setParam("productCode", selectedRows[0].ProductCode);
        evt.setParam("divCode", selectedRows[0].DIVCODE);
        var requestedReturnQuantity = hasPointAmount || hasOBSCHNL ? selectedRows[0].RequestedReturnQuantity : 0;
        evt.setParam('requestedReturnQuantity', requestedReturnQuantity);
        evt.setParam('customerPrice', selectedRows[0].Price);
        evt.setParam('originConsumerPrice', selectedRows[0].originConsumerPrice);

        evt.setParam('ChannelTypeCode', component.get('v.ChannelTypeCode'));
        evt.setParam('originProductId', selectedRows[0].sProductId);

        // 교환 제한 수량 Event fire
        evt.setParam('exchangeLimitedQuantity', exchangeLimitedQuantity);
        selectedRows=[];
        component.set('v.listSelectRows',selectedRows);


        console.log('EX_SuppliesExchangePart_evt fire @');
        evt.fire();

    },

    fnHandleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        var deleteProductId;
        var productCode;
        var divCode;
        var ItemId;
        switch (action.name) {
            case 'remove':
                var data = component.get('v.exchangeReturnOrderData');

                var newData = [];

                data.forEach((item => {
                    if (item.sProductId != row.sProductId) {
                        newData.push(item);
                    } else {
                        deleteProductId = item.Id;
                        productCode = item.ProductCode;
                        divCode = item.DIVCODE;
                        ItemId = item.productRequestLineItemId;
                    }
                }));
                component.set('v.exchangeReturnOrderData', newData);

                var evt = $A.get("e.c:EX_SuppliesExchangePart_evt");
                evt.setParam('evtType', 'remove');
                evt.setParam("productCode", productCode);
                evt.setParam("divCode", divCode);
                evt.setParam('itemId', ItemId);
                evt.fire();

                break;

            default:
                break;
        }
    },

    // 교환 요청의 반품 수량 수정시
    fnChkReturnVal: function (component, event, helper) {

        
        //변경 데이터
        let draftValues = event.getParam('draftValues');
        //데이터테이블 데이터
        let exchangeReturnOrderData = component.get("v.exchangeReturnOrderData");

        let isValidQuantity = true;

        isValidQuantity = helper.fnChkReturnQuantity(component, exchangeReturnOrderData, draftValues);
        console.log('draftValues Check :::: ' + draftValues);
        console.log('isValidQuantity => ' + isValidQuantity);
        if (!isValidQuantity) {
            helper.showToast('info', '반품 수량과 주문 수량을 다시 확인 해주세요.');
            component.find('returnDataTable').set('v.draftValues', []);
        } else {

            var hasPointAmount = component.get('v.hasPointAmount');
            var requestedReturnQuantity;
            var productRequestLineItemId;
            var itemTable = component.get('v.exchangeReturnOrderData');
            itemTable.forEach((item) => {
                draftValues.forEach((draftItem) => {
                    if (item.Id == draftItem.Id) {
                        if (draftItem.RequestedReturnQuantity != null) {
                            item.RequestedReturnQuantity = draftItem.RequestedReturnQuantity;
                            
                            requestedReturnQuantity = item.RequestedReturnQuantity;
                            productRequestLineItemId = item.productRequestLineItemId;
                            console.log('RequestedReturnQuantity -> ' + requestedReturnQuantity);
                            console.log('productRequestLineItemId -> ' + productRequestLineItemId);

                        }
                    }
                })
            })
            component.set('v.exchangeReturnOrderData', itemTable);

            var customerPrice = component.get('v.customerPrice');
            console.log('customerPrice -> ' + customerPrice);
            var originConsumerPrice = component.get('v.originConsumerPrice');
            console.log('originConsumerPrice -> ' + originConsumerPrice);

            // 회수부품정보 선택 시
            var selectedRows = component.get('v.listSelectRows');
            console.log(selectedRows[0]);

            if($A.util.isEmpty(selectedRows)) {
                var evt = $A.get("e.c:EX_SuppliesExchangePart_evt");
                console.log('RequestedReturnQuantity -> ' + requestedReturnQuantity);

                evt.setParam('evtType', 'edited');
                evt.setParam('itemId', productRequestLineItemId);
                evt.setParam('requestedReturnQuantity', requestedReturnQuantity);
                evt.setParam('customerPrice', customerPrice);
                evt.setParam('originConsumerPrice', originConsumerPrice);

                evt.fire();

            } else {

                console.log('EX_SuppliesExchangePart_evt fire');

                var evt = $A.get("e.c:EX_SuppliesExchangePart_evt");

                let exchangeLimitedQuantity = 0;
                console.log('SalesQuantity -> ' + selectedRows[0].SalesQuantity);
                console.log('RequestedReturnQuantity -> ' + selectedRows[0].RequestedReturnQuantity);
                console.log('ReturnQuantity -> ' + selectedRows[0].ReturnQuantity);
                console.log('ExpectedReturnQuantity -> ' + selectedRows[0].ExpectedReturnQuantity);

                exchangeLimitedQuantity = parseInt(selectedRows[0].SalesQuantity) - (parseInt(selectedRows[0].RequestedReturnQuantity) + parseInt(selectedRows[0].ReturnQuantity) + parseInt(selectedRows[0].ExpectedReturnQuantity));
                component.set('v.customerPrice', selectedRows[0].Price);
                component.set('v.originConsumerPrice', selectedRows[0].originConsumerPrice);

                evt.setParam('evtType', 'selected');
                evt.setParam('itemId', selectedRows[0].productRequestLineItemId);
                evt.setParam("productCode", selectedRows[0].ProductCode);
                evt.setParam("divCode", selectedRows[0].DIVCODE);
                evt.setParam('customerPrice', selectedRows[0].Price);
                evt.setParam('originConsumerPrice', selectedRows[0].originConsumerPrice);

                evt.setParam('requestedReturnQuantity', selectedRows[0].RequestedReturnQuantity);
                // 교환 제한 수량 Event fire
                evt.setParam('exchangeLimitedQuantity', exchangeLimitedQuantity);
                evt.fire();
            }
        }
    },
    onWijmoMessage  : function(component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        switch (payload.type) {
            case 'rowSelection':
                // var selectedRows = payload.selectedRows;
                // helper.fnSelectedWijmo(component, event, helper, selectedRows);
                break;
            case 'rowAction':
                if ('Cancel' === actionName) {
                    const row = payload.row;
                    helper.fnCancelProduct(component, event, helper, row);
                }
                break;
            case 'dblclick':
                let selectedRow = [];
                selectedRow.push(JSON.parse(JSON.stringify(payload.item)));

                if (!Number.isInteger(selectedRow[0].RequestedReturnQuantity) && selectedRow[0].RequestedReturnQuantity != undefined) {
                    helper.showToast('warning', '소수점 수량지정 주문이 불가능합니다.');
    
                    return;
                } else if (parseInt(selectedRow[0].RequestedReturnQuantity) < 0) {
                    helper.showToast('warning', '음수일 경우, 주문이 불가능합니다.');
    
                    return;
                } else if (selectedRow[0].SalesQuantity < selectedRow[0].RequestedReturnQuantity) {
                    helper.showToast('warning', '교환수량이 주문수량보다 많을 경우, 교환이 불가능합니다.');
    
                    return;
                }
                
                helper.fnSelectedWijmo(component, event, helper, selectedRow);
                break;
            case 'editing':

                let selecteditems = [];
                let obj = JSON.parse(JSON.stringify(payload.item));
                selecteditems.push(obj);
                //23.11.02 gw.lee
                //요청 수량이 undefined일 경우, 0으로 조치
                var reqQty = selecteditems[0].RequestedReturnQuantity != undefined ? selecteditems[0].RequestedReturnQuantity : 0;
                if (!Number.isInteger(reqQty) && reqQty != undefined) {
                    helper.showToast('warning', '소수점 수량지정 주문이 불가능합니다.');
    
                    return;
                } else if (parseInt(reqQty) < 0) {
                    helper.showToast('warning', '음수일 경우, 주문이 불가능합니다.');
    
                    return;
                } else if (selecteditems[0].SalesQuantity < reqQty) {
                    helper.showToast('warning', '교환수량이 주문수량보다 많을 경우, 교환이 불가능합니다.');
    
                    return;
                }

                var evt = $A.get("e.c:EX_SuppliesExchangePart_evt");

                let exchangeLimitedQuantity = 0;
                console.log('SalesQuantity -> ' + selecteditems[0].SalesQuantity);
                console.log('RequestedReturnQuantity -> ' + reqQty);
                console.log('ReturnQuantity -> ' + selecteditems[0].ReturnQuantity);
                console.log('ExpectedReturnQuantity -> ' + selecteditems[0].ExpectedReturnQuantity);

                exchangeLimitedQuantity = parseInt(selecteditems[0].SalesQuantity) - (parseInt(reqQty) + parseInt(selecteditems[0].ReturnQuantity) + parseInt(selecteditems[0].ExpectedReturnQuantity));
                component.set('v.customerPrice', selecteditems[0].Price);
                component.set('v.originConsumerPrice', selecteditems[0].originConsumerPrice);

                evt.setParam('evtType', 'edited');
                evt.setParam('itemId', selecteditems[0].productRequestLineItemId);
                evt.setParam("productCode", selecteditems[0].ProductCode);
                evt.setParam("divCode", selecteditems[0].DIVCODE);
                evt.setParam('customerPrice', selecteditems[0].Price);
                evt.setParam('originConsumerPrice', selecteditems[0].originConsumerPrice);

                // 교환 제한 수량 Event fire
                evt.setParam('requestedReturnQuantity', reqQty);
                evt.setParam('exchangeLimitedQuantity', exchangeLimitedQuantity);
                
                evt.setParam('ChannelTypeCode', component.get('v.ChannelTypeCode'));
                evt.setParam('originProductId', selecteditems[0].sProductId);
                evt.fire();

                break;
        }
    },
});