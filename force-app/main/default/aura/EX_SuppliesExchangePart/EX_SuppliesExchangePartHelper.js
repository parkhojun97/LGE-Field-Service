/**
 * Created by I2MAX.SEOKHOLEE on 2023-02-27.
 */

({
    fnSetExchangeColumns: function (component, event, helper) {
        var isQtyEditable = false;

        console.log('ChannelTypeCode -> ' + component.get('v.ChannelTypeCode'));
        console.log('hasPointAmount -> ' + component.get('v.hasPointAmount'));
        console.log('hasOBSCHNL -> ' + component.get('v.hasOBSCHNL'));

        if((component.get('v.ChannelTypeCode') == 'V' && component.get('v.hasPointAmount') == false && component.get('v.hasPointAmount') == false)) {
            isQtyEditable = true;
        }

        let columns = [
            {
                label: '',
                type: 'button-icon',
                initialWidth: 50
                ,
                typeAttributes: {
                    alternativeText: '휴지통',
                    name: 'remove',
                    iconName: 'utility:recycle_bin_empty',
                    disabled: {fieldName: 'actionDisabled'}
                }
            },
            {
                label: '유형',
                fieldName: 'SUBSTITUTE',
                type: 'text',
                initialWidth: 100,
                cellAttributes: {alignment: 'left'},
                sortable: true
            },
            {
                label: '사업부',
                fieldName: 'DIVCODE',
                type: 'text',
                initialWidth: 100,
                cellAttributes: {alignment: 'left'},
                hideDefaultActions: true
            },
            {
                label: 'Part No.',
                fieldName: 'ProductCode',
                type: 'text',
                initialWidth: 150,
                cellAttributes: {alignment: 'left'},
                hideDefaultActions: true
            },
            {
                label: '대표모델',
                fieldName: 'Model',
                type: 'text',
                initialWidth: 150,
                cellAttributes: {alignment: 'left'},
                hideDefaultActions: true
            },
            {
                label: '품명',
                fieldName: 'ProductName',
                type: 'text',
                initialWidth: 200,
                cellAttributes: {alignment: 'left'}
            },

            {
                label: '주문수량',
                fieldName: 'SalesQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true,
                cellAttributes: {alignment: 'right'}
            },
            {
                label: '요청수량',
                fieldName: 'RequestedReturnQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true,
                editable: isQtyEditable,
                cellAttributes: {alignment: 'right', class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품수량',
                fieldName: 'ReturnQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true,
                cellAttributes: {alignment: 'right'}
            },

            {
                label: '반품예정수량',
                fieldName: 'ExpectedReturnQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true,
                cellAttributes: {alignment: 'right'}
            },

            {
                label: '소비자가',
                fieldName: 'Price',
                type: 'number',
                initialWidth: 100,
                sortable: true,
                cellAttributes: {alignment: 'right'}
            },
            // {
            //     label: 'OBS 가격',
            //     fieldName: 'OBS_Price',
            //     type: 'text',
            //     initialWidth: 100,
            //     hideDefaultActions: true,
            //     cellAttributes: {alignment: 'right'}
            // },
            // {
            //     label: '지정점가',
            //     fieldName: 'ASCPrice',
            //     type: 'number',
            //     sortable: true,
            //     initialWidth: 100,
            //     cellAttributes: {alignment: 'right'}
            // },
            // {
            //     label: '출고부서',
            //     fieldName: 'DIV_CODE__c',
            //     type: 'text',
            //     initialWidth: 100,
            //     sortable: true,
            //     cellAttributes: {alignment: 'left'}
            // },
            {
                label: '비고',
                fieldName: 'Note',
                type: 'text',
                initialWidth: 100,
                sortable: false,
                cellAttributes: {alignment: 'left'}
            }

        ];
        component.set("v.columns", columns);
    },
    /**
     * @description 소모품 통합주문관리 교환 주문 Data 조회
     * @param component
     * @param event
     * @author 23.02.27 / I2MAX.SEOKHOLEE
     */
    // fnGetExchangeOrderData: function (component, event, helper) {

       
    // },

    // 반품 수량 validation
    fnChkReturnQuantity: function (component, objSelected, draftValues) {
        let isValidQuantity = true;
        let totalQty;

        draftValues.forEach(function (draftData) {
            objSelected.forEach(function (selectData) {
                if (draftData.Id == selectData.Id) {
                    totalQty = parseInt(draftData.RequestedReturnQuantity) + parseInt(selectData.ExpectedReturnQuantity) + parseInt(selectData.ReturnQuantity);
                    if (totalQty > parseInt(selectData.SalesQuantity)) {
                        isValidQuantity = false;
                    }
                }
            });
        });
        return isValidQuantity;
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
    fnSelectedWijmo: function (component, event, helper, selectedRows) {

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
        evt.setParam('requestedReturnQuantity', selectedRows[0].RequestedReturnQuantity);
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
    fnHandleRowActionWijmo: function (component, event, helper, row) {


        var newData;
        var data = component.get('v.exchangeReturnOrderData');
        var rowIndex = data.findIndex(function (item) {
            return item.Id === row.Id;
        });

        if (rowIndex > -1) {
            data.splice(rowIndex, 1);
            newData = data;
        }

        var deleteProductId;
        var productCode;
        var divCode;
        var ItemId;
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

        var hasPointAmount = component.get('v.hasPointAmount');
        var hasOBSCHNL = component.get('v.hasOBSCHNL');

        var wijmoName = 'wijmo_EXexchangeReturnOrder';
        if (hasPointAmount || hasOBSCHNL) {
            wijmoName = 'wijmo_EXexchangeDisabledReturnOrder';
        }

        this.sendMessage(component, {type:'items', items: newData}, wijmoName);

    },
    sendMessage: function(component, msg, type) {
        console.log('msg -> ' + msg);
        component.find(type).message(msg);
    },

});