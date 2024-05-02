/**
 * Created by maru035 on 2023-01-09
 */

({
    fnInit: function (component, event, helper) {

        console.log('integrationOrderList fnInit 시작~');

        //23 11 02 hyungho.chun 탭 여러개 loading.. 결함 처리
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    
            if (tabId) {
                console.log('response.tabId ' , tabId);
                var focusedTabId = tabId;
                console.log('focusedTabId' , focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "소모품통합주문관리"
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


        // // 주문 리스트
        // let closeModalOrderColumns = [
        //     {
        //         label: '주문일시', fieldName: 'OrderDate', type: 'date', initialWidth: 120, typeAttributes: {
        //             day: 'numeric',
        //             month: 'short',
        //             year: 'numeric',
        //             hour: '2-digit',
        //             minute: '2-digit',
        //             second: '2-digit',
        //             hour12: true
        //         }, hideDefaultActions: true
        //     },
        //     {
        //         label: '결제일시', fieldName: 'PaymentDate', type: 'date', initialWidth: 120, typeAttributes: {
        //             day: 'numeric',
        //             month: 'short',
        //             year: 'numeric',
        //             hour: '2-digit',
        //             minute: '2-digit',
        //             second: '2-digit',
        //             hour12: true
        //         }, hideDefaultActions: true
        //     },
        //     {label: '주문채널', fieldName: 'OrderChannel', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문항번', fieldName: 'OrderSeq', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '고객명', fieldName: 'CustomerName', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '전화번호', fieldName: 'CustomerPhone', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '수취인명', fieldName: 'CONSIGNEE_Name', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: '수취인 전화번호',
        //         fieldName: 'CONSIGNEE_Phone',
        //         type: 'text',
        //         initialWidth: 100,
        //         hideDefaultActions: true
        //     },
        //     {
        //         label: '수취인 변경여부',
        //         fieldName: 'CONSIGNEE_CHANGE_YN',
        //         type: 'text',
        //         initialWidth: 100,
        //         hideDefaultActions: true
        //     },
        //     {label: '사업부', fieldName: 'DIV', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: 'PART_NO', fieldName: 'PART_NO', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '취소', fieldName: 'Cancel', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: '취소일시', fieldName: 'CancelDate', type: 'text', initialWidth: 120, typeAttributes: {
        //             day: 'numeric',
        //             month: 'short',
        //             year: 'numeric',
        //             hour: '2-digit',
        //             minute: '2-digit',
        //             second: '2-digit',
        //             hour12: true
        //         }, hideDefaultActions: true
        //     },
        //     {label: '요청파트', fieldName: 'RequestedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '요청금액', fieldName: 'RequestedAmount', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '입고파트', fieldName: 'ReceivedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '입고금액', fieldName: 'ReceivedAmount', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '대치', fieldName: '', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문수량', fieldName: 'QuantityRequested', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: '센터적치장소',
        //         fieldName: 'CenterLocatedPlace',
        //         type: 'text',
        //         initialWidth: 100,
        //         hideDefaultActions: true
        //     },
        //     {label: '사업부적치장소', fieldName: 'LocatedPlace', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: 'CJ전송여부', fieldName: 'CJOrderSendYN', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: 'CJ전송일시', fieldName: 'CJSendDate', type: 'date', initialWidth: 120, typeAttributes: {
        //             day: 'numeric',
        //             month: 'short',
        //             year: 'numeric',
        //             hour: '2-digit',
        //             minute: '2-digit',
        //             second: '2-digit',
        //             hour12: true
        //         }, hideDefaultActions: true
        //     },
        //     {label: 'CJ출고번호', fieldName: 'CJOrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '처리자', fieldName: 'RequestedUser', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주소', fieldName: 'CONSINEE_Address', type: 'text', initialWidth: 100, hideDefaultActions: true},
        // ];

        // component.set('v.closeModalOrderColumns', closeModalOrderColumns);

        // 반품 테이블 초기화
        // let returnOrderColumns = [
        //     {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '파트넘버', fieldName: 'PART_NO', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '소비자가', fieldName: 'UnitPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '반품수량', fieldName: 'ReturnQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '반품금액', fieldName: 'ReturnAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문수량', fieldName: 'QuantityRequested', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '반품사유', fieldName: 'ReturnReason', type: 'text', initialWidth: 100, hideDefaultActions: true}
        // ];

        //은행코드
        // component.set("v.bankOptions", [
        //     {label: '국민은행', value: '088'},
        //     {label: '신한은행', value: '089'},
        //     {label: '하나은행', value: '090'},
        //     {label: '토스은행', value: '091'},
        //     {label: '우리은행', value: '092'},
        // ]);

        // 교환 주문내역 테이블 초기화
        // let exchangeOrderListColumns = [
        //     {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '파트넘버', fieldName: 'PART_NO', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '소비자가', fieldName: 'UnitPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '교환수량', fieldName: 'ExchangeQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '교환금액', fieldName: 'ExchangeAmount', type: 'number', initialWidth: 100, hideDefaultActions: true}
        // ];


        // component.set('v.exchangeOrderListColumns', exchangeOrderListColumns);
    },

//     fnSeleceted: function (component, event, helper) {
//         console.log('### row fnSeleceted ###');
//         console.log(event.getParam('selectedRows'));
//         console.log(JSON.stringify(event.getParam('selectedRows')));

//         if (JSON.stringify(event.getParam('selectedRows')) == '[]') {
//             return;
//         }

//         component.set('v.showSpinner', true);

//         var selectedRows = event.getParam('selectedRows');
//         component.set('v.objSelected', selectedRows);

//         if (!selectedRows.length) {
//             component.set('v.mapInfo', []);
//             // component.set('v.showSpinner', false);
//             return;
//         }

//         component.set("v.mapInfo", event.getParam('selectedRows'));

//         var strOrderChannel = event.getParam('selectedRows')[0].OrderChannel;
//         var strOrderStatus = event.getParam('selectedRows')[0].OrderStatus;
//         var strSalesNumber = event.getParam('selectedRows')[0].SalesNumber;
//         var ConsumablesBusinessTypeCode = event.getParam('selectedRows')[0].ConsumablesBusinessTypeCode;

//         console.log('fields detail :', strOrderStatus + ', ' + strOrderChannel + ', ' + ConsumablesBusinessTypeCode);

//         // 주문상태변경 버튼 활성화 여부 배송준비중만 활성화
//         // if (strOrderStatus == '배송준비중' || strOrderStatus == '배송중' || strOrderStatus == '상품준비중') {
//         if (strOrderStatus == '배송준비중' && strOrderChannel == '소모품택배') {
//             component.set('v.orderStatusDisabled', false);
//         }
//         else {
//             component.set('v.orderStatusDisabled', true);
//         }
//         console.log('strSalesNumber'+strSalesNumber);

//         //판매번호 존재에 따른 판매저장 버튼 활성화처리
//         //if(strSalesNumber == null || strSalesNumber == ''){
//         // if((strSalesNumber == null || strSalesNumber == '') &&
//         //     (strOrderStatus=='배송중' || strOrderStatus=='배송완료')){
//             //component.set('v.salesSaveBtnDisabled', false);
//         //     component.set('v.salesSaveBtnDisabled', false);
//         // }else{
//         //     component.set('v.salesSaveBtnDisabled', true);
//         // }

// //        if (strOrderStatus == '결제요청' || strOrderStatus == '결제완료' || strOrderStatus == '상품준비중') {
// //            if (strOrderChannel == 'ThinQ') {
// //                component.set("v.orderCancel_disable", false);
// //                component.set("v.returnOrder_disable", true);
// //                component.set("v.exChange_disable", true);
// //                component.set("v.saleSave_disable", true);
// //            } else {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", true);
// //                component.set("v.exChange_disable", true);
// //                component.set("v.saleSave_disable", true);
// //            }
// //        }
// //
// //        else if (strOrderStatus == '배송완료') {
// //            if (strOrderChannel == 'ThinQ') {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", false);
// //                component.set("v.exChange_disable", false);
// //                component.set("v.saleSave_disable", false);
// //            } else if (strOrderChannel == 'CIC') {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", false);
// //                component.set("v.exChange_disable", false);
// //                component.set("v.saleSave_disable", false);
// //            } else {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", true);
// //                component.set("v.exChange_disable", true);
// //                component.set("v.saleSave_disable", true);
// //            }
// //        }
// //        else if (strOrderStatus == '배송중') {
// //            if ( //strSalesNumber == null && (
// //                strOrderChannel == 'ThinQ' || strOrderChannel == 'CIC') {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", false);
// //                component.set("v.exChange_disable", true);
// //                component.set("v.saleSave_disable", false);
// //            } else {
// //                component.set("v.orderCancel_disable", true);
// //                component.set("v.returnOrder_disable", true);
// //                component.set("v.exChange_disable", true);
// //                component.set("v.saleSave_disable", true);
// //            }
// //        }

//         var evt = $A.get("e.c:EX_ConsumableOrderList_evt");
//         evt.setParam("data", event.getParam('selectedRows'));
//         evt.fire();

//         // component.set('v.showSpinner', false);
//     },

    changeOrderData: function (component, event, helper) {
        //var data = component.get('v.data');

        // button 상태 초기화 todo: change가 아닌 재조회? 조회버튼으로
        component.set('v.orderStatusDisabled', true);

        console.log(':::: Send Wijmo orderList::::');
        var data = component.get('v.data');
        console.log('data :: ' + data);
        component.set('v.componentName','wijmo_EXIntegrationOrderList');
        helper.sendMessage(component, {type:'items', items: data});
    },

    // 주문 상태 변경 클릭할 시 실행
    fnOpenOrderStChangeModal: function (component, event, helper) {

        var dialog = component.find('dialog');
        
        var param = {
            message: 'CJ 주문확정여부 확인하였습니까 ? '
        };

        //24 01 03 hyungho.chun 교환주문 주문 상태 변경 방어로직 추가
        var listMapTemp = component.get("v.selectedRowsForStChg");
        if(listMapTemp[0].ConsumablesBusinessTypeCode == '교환주문'){
            helper.showToast('error', '교환주문은 주문 상태 변경 할 수 없습니다.');
            return;            
        }        

        dialog.confirm(param, function (response) {
            if (response.result) {
                // helper.fnUpdateOrderStatus(component);
                var listMap = component.get("v.selectedRowsForStChg");
                console.log('listMap : ' + listMap);
                console.log(JSON.stringify(listMap));

                if (listMap == null || listMap.length == 0) {
                    helper.showToast('error', '주문을 선택해주세요.');
                    return;
                }
                helper.doOpenOrderStChangeModal(component);

                listMap.forEach(function(prLi) {
                    prLi.UpdatedOrderStatus = '상품준비중';
                });

                component.set('v.componentName','wijmo_EXOrderStChange');
                setTimeout(function () {
                    helper.sendMessage(component, {type:'items', items: listMap});
                }, 1000);
                // if(listMap.length > 0){
                //     helper.doOpenOrderCancelModal(component);
                // }else{
                //     helper.showToast('error', '주문을 선택해주세요.');
                // var evt = $A.get("e.force:showToast");
                // evt.setParams({
                //     key: "info_alt",
                //     type: 'info',
                //     message: '주문을 선택해주세요.'
                // });
                // evt.fire();
                // }
            }
        }, null);


        
    },
    fnCloseOrderStChangeModal: function (component, event, helper) {
        helper.doCloseOrderStChangeModal(component);
    },
    // 반품 클릭할 시 실행
    fnOpenReturnOrderModal: function (component, event, helper) {
        var listMap = component.get("v.mapInfo");
        if (listMap.length > 0) {
            helper.doOpenReturnOrderModal(component);
        } else {
            var evt = $A.get("e.force:showToast");
            evt.setParams({
                key: "info_alt",
                type: 'info',
                message: '주문을 선택해주세요.'
            });
            evt.fire();
        }
    },
    /**
     * @description 소모품 통합주문관리 반품 모달 Open
     * @param component
     * @param event
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     */
    fnCloseReturnOrderModal: function (component, event, helper) {
        helper.doCloseReturnOrderModal(component);
    },

    // // 교환요청 클릭할 시 실행
    // fnOpenExchangeModal: function (component, event, helper) {
    //     var listMap = component.get("v.mapInfo");
    //     if (listMap.length > 0) {
    //         helper.doOpenExchangeModal(component);
    //     } else {
    //         var evt = $A.get("e.force:showToast");
    //         evt.setParams({
    //             key: "info_alt",
    //             type: 'info',
    //             message: '주문을 선택해주세요.'
    //         });
    //         evt.fire();
    //     }
    // },
    // fnCloseExchangeModal: function (component, event, helper) {
    //     helper.doCloseExchangeModal(component);
    // },


    downloadCSVFile: function (component, event) {
        var evt = $A.get("e.c:EX_DownloadCSV_evt");
        evt.setParam("data", component.get("v.data"));
        evt.setParam("columns", component.get("v.columns"));
        evt.setParam("title", "IntegrationOrderList");
        evt.fire();

        /*var selected = component.get("v.data");
        var column_label = component.get("v.columns");

        let rowEnd = '\n';
        let csvString = '\ufeff';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        let rowDataCol = new Set();

        selected.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                column_label.forEach(function (col) {
                    if(key == col.fieldName){
                        rowData.add(key);
                        rowDataCol.add(col.label);
                        //console.log('key:' + key);
                        //console.log('col.label:' + col.label);
                    }
                });
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        rowDataCol = Array.from(rowDataCol);

        // splitting using ','
        //csvString += rowData.join(',');
        csvString += rowDataCol.join(',');
        csvString += rowEnd;

        console.log('csvString:' + csvString);

        // main for loop to get the data based on key value
        for(let i=0; i < selected.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = selected[i][rowKey] === undefined ? '' : selected[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'CSVDownloadTest.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();*/
    },


    //23 09 06 hyungho.chun 현재안쓰는기능
    // // 주문 리스트 Modal
    // fnOpenOrderListModal: function (component, event, helper) {
    //     //init 데이터 가져오기
    //     console.log('### fnInit');
    //     var action = component.get('c.doGetInitData');
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             var mapSettingValueOrigin = result['mapSettingValueOrigin'];

    //             component.set('v.mapSettingValueOrigin', mapSettingValueOrigin);

    //             var mapSettingValue = mapSettingValueOrigin;
    //             component.set('v.mapSettingValue', mapSettingValue);
    //         } else {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
    //             } else {
    //                 helper.showToast("error", "Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);

    //     var mapSearchOrderParam = component.get('v.mapSearchOrderParam');

    //     var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    //     component.set('v.mapSearchOrderParam.baseDateStart', today);
    //     component.set('v.mapSearchOrderParam.baseDateEnd', today);
    //     component.set('v.mapSearchOrderParam', mapSearchOrderParam);

    //     helper.doOpenOrderListModal(component);
    // },

    // fnCloseOrderListModal: function (component, event, helper) {
    //     helper.doCloseOrderListModal(component);
    // },

    fnOrderListSearch: function (component, event, helper) {
        try {
            helper.fnDoOrderListSearch(component, event, helper);
        } catch (e) {
            console.error("Exception occurred while fnSearch:", e);
        }
    },

    fnOrderListSelected: function (component, event, helper) {
        console.log('### fnOrderListSelected! ');
        console.log(event.getParam('selectedRows'));
        console.log(JSON.stringify(event.getParam('selectedRows')));

        var orderNumber = event.getParam('selectedRows')[0].OrderNumber;
        console.log('OrderNumber: ' + orderNumber);
        component.set('v.orderNumber', event.getParam('selectedRows')[0].OrderNumber);
        component.set('v.selectedId', event.getParam('selectedRows')[0].Id);

    },

    // 수취인 변경 모달
    // fnOrderListUpdateModal: function (component, event, helper) {
    //     console.log('## Consignee Update Modal ###');
    //     var orderNumber = component.get('v.orderNumber');
    //     console.log('InModal orderNumber :' + orderNumber);

    //     if (orderNumber == undefined || orderNumber == null || orderNumber.length == 0) {
    //         helper.showToast('warning', '수취인 변경을 원하는 주문을 선택해주세요');
    //     } else {
    //         var action = component.get('c.doGetConsigneeDetail');
    //         action.setParams({
    //             'orderNumber': orderNumber
    //         });
    //         action.setCallback(this, function (response) {
    //             console.log('EX_IntegrationController');
    //             var state = response.getState();
    //             if (state == "SUCCESS") {
    //                 var result = response.getReturnValue();
    //                 console.log('SUCCESS: ' + JSON.stringify(result['productRequest']));

    //                 component.set('v.productRequestLineItem', result['productRequest'][0]);
    //                 console.log(component.get('v.productRequestLineItem'));


    //             } else {
    //                 var errors = response.getError();
    //                 if (errors) {
    //                     if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
    //                 } else {
    //                     helper.showToast("error", "Unknown error");
    //                 }
    //             }
    //         });
    //         $A.enqueueAction(action);
    //         component.set('v.showOrderListUpdateModal', true);
    //     }
    // },

    fnCloseOrderListUpModal: function (component, event, helper) {
        component.set('v.showOrderListUpdateModal', false);
    },

    fnOrderListEnter: function (component, event, helper) {
        if (event.keyCode == 13) {
            helper.fnDoOrderListSearch(component, event, helper);
        }
    },

    fnPhoneChg: function (component, event, helper) {
        var phoneNumber = event.getSource().get('v.value');
        phoneNumber = helper.fnPhoneChgFormat(component, event, phoneNumber);
        event.getSource().set('v.value', phoneNumber);
    },
    fnAddressSearch: function (component) {
        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        var data = {
            target: "DAUMAPICALL"
        };
        vfWindow.postMessage(data, vfOrigin);

    },
    fnchangeConsignee: function (component, event, helper) {
        var action = component.get('c.doChangeConsignee');

        var param = {
            newName: component.get('v.newName'),
            newPhone: component.get('v.newPhone'),
            newPostalCode: component.get('v.newPostalCode'),
            newAddress: component.get('v.newAddress'),
            newDetailAddress: component.get('v.newDetailAddress'),
            orderNumber: component.get('v.orderNumber'),
            id : component.get('v.selectedId')
        }
        console.log(param);
        action.setParams({
            'paramMap': param
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {

                helper.showToast('success', '수취인 정보가 변경되었습니다.');
                component.set('v.showOrderListUpdateModal', false);
                component.set('v.newName', '');
                component.set('v.newPhone', '');
                component.set('v.newPostalCode', '');
                component.set('v.newAddress', '');
                component.set('v.newDetailAddress', '');
                component.set('v.selectedId',null);

                helper.fnUpdateList(component, event, helper);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    // 반품 수량 수정
    fnChkReturnVal: function (component, event, helper) {
        //변경 데이터
        let draftValues = event.getParam('draftValues');
        //데이터테이블 데이터
        let productRequestLineItemsByReturnRequest = component.get("v.productRequestLineItemsByReturnRequest");

        let isValidQuantity = true;

        isValidQuantity = helper.fnChkReturnQuantity(productRequestLineItemsByReturnRequest, draftValues);
        console.log('isValidQuantity => ' + isValidQuantity);
        if (!isValidQuantity) {
            helper.showToast('error', '반품수량이 주문수량보다 큽니다.');
            component.find('returnDataTable').set('v.draftValues', []);
        } else {
            var itemTable = component.get('v.productRequestLineItemsByReturnRequest');
            itemTable.forEach((item) => {
                draftValues.forEach((draftItem) => {
                    if (item.Id == draftItem.Id) {
                        if(draftItem.RequestedReturnQuantity != null) {
                            item.RequestedReturnQuantity = draftItem.RequestedReturnQuantity;
                        }
                        if(draftItem.ReturnRequestReason != null) {
                            item.ReturnRequestReason = draftItem.ReturnRequestReason;
                        }
                    }
                })
            })
            component.set('v.productRequestLineItemsByReturnRequest', itemTable);

        }
    },



    /**
     * @description 관련 주문 내역 저장
     * @param component, event
     * author 23.02.08 / I2MAX.SEUNGHUNAN
     */
    fnGetRelatedOrderList: function (component, event) {
        var relatedOrderList = event.getParam('relatedOrderList');

        console.log('***event.getParam("relatedOrderList") :: ' + event.getParam('relatedOrderList'));

        var originRelatedOrderList = event.getParam('originRelatedOrderList');
        var originMap = component.get('v.originMap');
        var trackingNumberMap = {};
        var handWorkReasonMap = {};
        var salesValid = false;

        relatedOrderList.forEach(ro => {
            ro.After_Order_Status = 'font-color-red';
            // Id를 Key로 기존의 송장번호, 수작업사유 저장
            // 기존에 송장 번호, 수작업사유 존재 하지 않을 시 '' 처리해서 undefined 예방
            trackingNumberMap[ro.Id] = ro.TrackingNumber != undefined ? ro.TrackingNumber : '';
            handWorkReasonMap[ro.Id] = ro.HandWorkReason != undefined ? ro.HandWorkReason : '';
        });

        if (relatedOrderList == null || relatedOrderList == undefined) {
            component.set('v.relatedOrderList', null);
            return;
        }
        component.set('v.relatedOrderList', relatedOrderList);
        originMap['TrackingNumber'] = trackingNumberMap;
        originMap['HandWorkReason'] = handWorkReasonMap;
        component.set('v.originMap', originMap);

        // check
        console.log('relatedOrderList ::: ' + JSON.stringify(relatedOrderList));
        console.log('originRelatedOrderList ::: ' + JSON.stringify(originRelatedOrderList));

        /**
         * 판매저장 Validation 모든 품목(원주문) 들이 판매번호가 없이 배송중 or 배송완료
         */
        originRelatedOrderList.forEach(oro => {
            var SalesNumber = oro.SalesNumber;
            var OrderStatus = oro.OrderStatus;
            if (!((SalesNumber == null) && (OrderStatus == '배송중' || OrderStatus == '배송완료'))) {
                salesValid = true;
            }
        });
        console.log('salesValid :: ' + salesValid);
        component.set('v.salesSaveBtnDisabled', salesValid);
        component.set('v.showSpinner', false);
    },
    /**
     * @description 반품 요청
     * @param component, event, helper
     * author 23.02.08 / I2MAX.SEOKHOLEE
     */
    fnRequestReturnOrder: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.doRequestReturnOrder');
        var returnRequestItemTable = component.get('v.productRequestLineItemsByReturnRequest');

        var isValid = true;
        returnRequestItemTable.forEach((item) => {
            if ($A.util.isEmpty(item.ReturnRequestReason)){
                isValid = false;
                return;
            }
        });
        // if(!isValid){
        //     helper.showToast('error', '반품 사유를 입력하여야 합니다.');
        //     component.set('v.showSpinner', false);
        //
        //     return;
        // }

        var param = {
            'contactConsigneeInfo': component.get('v.contactConsigneeInfo'),
            'productRequestLineItemsByReturnRequest': JSON.stringify(returnRequestItemTable),
            'caseInfo' : component.get('v.caseInfo'),
            'appendRemarkByReturnRequest' : component.get('v.appendRemarkByReturnRequest')
        };

        console.log(param);
        action.setParams({
            'paramMap': param
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.showToast('success', '반품요청이 정상적으로 처리 되었습니다.');
                component.set('v.showReturnOrderModal', false);
                component.set('v.showSpinner', false);

            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
                component.set('v.showSpinner', false);

            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 상태를 변경할 주문 품목 선택
     * @param component, event, helper
     * @author 23.02.09 / I2MAX.SEUNGHUNAN
     */
    fnSelected : function(component, event, helper) {
        // var orderStChangeDT = component.find('orderStChangeDT');
        console.log('a');
        var selectedRows = event.getParam('selectedRows');
        if (!selectedRows) return;
        console.log('b');
        component.set('v.stChangeTargetObj', selectedRows[0]);
        console.log('c');
        console.log(JSON.stringify(selectedRows));
        console.log(JSON.stringify(component.get('v.stChangeTargetObj')));

        console.log('d');
        var targetObj = component.get('v.stChangeTargetObj');
        if (targetObj == null || targetObj == undefined) return;

        // 23.02.19 상품배송중으로 바로 변경되게 수정
        // var stChangeTargetObj = component.get('v.stChangeTargetObj');
        var prLiList = component.get('v.selectedRowsForStChg');
        var updatedOrderStatus = '상품준비중';
        var selectedId = [];

        for (var idx in prLiList) {
            if (prLiList[idx].Id == targetObj.Id) {
                prLiList[idx].UpdatedOrderStatus = updatedOrderStatus;
                selectedId.push(prLiList[idx].Id);
                break;
            }
        }
        component.set('v.saveReadOnly', false);
        component.set('v.changeReasonReadOnly', false);
        component.set('v.selectedRowsForStChg', prLiList);
        component.set('v.preSelectedRows', selectedId);


        // var orderStatus = targetObj.OrderStatus;
        // var orderChannel = targetObj.OrderChannel;
        // var orderStatusList = helper.fnOrderStatusListInit(component, orderStatus, orderChannel);
        // todo: test를 위해서 열어둠
        // component.set('v.trackingNumberReadOnly', false);
        // component.set('v.changeReasonReadOnly', false);

        // console.log('orderStatusList : ' + orderStatusList);
        // component.set('v.orderStatusList', orderStatusList);
        // component.find('orderStatusSelect').set('v.value', orderStatus);

        // console.log('v.relatedOrderList : ' + );
        // console.log(JSON.stringify(component.get('v.relatedOrderList')));
    },

    fnCloseDeliveryInformationModal: function (component, event, helper) {
            component.set('v.showDeliveryInformationModal', false);
    },

    /**
     * @description 주문 상태 변경 리스트 선택시 변경후 상태정보 업데이트
     * @param component
     * @author 23.02.10 / I2MAX.SEUNGHUNAN
     */
    orderStatusChange : function(component) {
//        var orderStChangeDT = component.find('orderStChangeDT');
//        var selectedRows = orderStChangeDT.getSelectedRows()[0];
        var selectedRows = component.get('v.selectedRowsForStChg');
        var prLiList = component.get('v.relatedOrderList');
        var updatedOrderStatus = component.find('orderStatusSelect').get('v.value');
        var selectedId = [];

        for (var idx in prLiList) {
            if (prLiList[idx].Id == selectedRows.Id) {
                prLiList[idx].UpdatedOrderStatus = updatedOrderStatus;
                selectedId.push(prLiList[idx].Id);
                break;
            }
        }
        component.set('v.saveReadOnly', false);
        component.set('v.relatedOrderList', prLiList);
        component.set('v.preSelectedRows', selectedId);
        helper.sendMessage(component, {type:'items', items: component.get('v.data')});
    },

    /**
     * @description 주문 상태 변경 -> 송장번호, 수작업 사유 변경
     * @param component
     * @author 23.02.13 / I2MAX.SEUNGHUNAN
     */
    changeTextField : function(component) {
        console.log('change Text Field in ');
        // var selectedRows = component.get('v.selectedRowsForStChg')[0];
        // var handWorkReason = selectedRows.HandWorkReason;

        //console.log('editing handworkReaon :: ' + handWorkReason);
        // console.log('changeTextField!!! ');
        // todo: 23.02.13 Validation 추가해야함
        // if(component.get('v.changeReasonReadOnly') == false){
        //     console.log('ReadOnly 아님');
        //
        //     var prLiList = component.get('v.relatedOrderList');
        //     // var orderStChangeDT = component.find('orderStChangeDT');
        //     // var selectedRows = orderStChangeDT.getSelectedRows()[0];
        //     var selectedRows = component.get('v.selectedRowsForStChg');
        //     var selectedId = [];
        //     selectedId.push(selectedRows.Id);
        //     component.set('v.saveReadOnly', false);
        //     component.set('v.relatedOrderList', prLiList);
        //     component.set('v.preSelectedRows', selectedId);
        //
        //     console.log('wijmo sendMessage 직전');
            //helper.sendMessage(component, {type:'items', items: component.get('v.selectedRowsForStChg')});
        // }
    },

    /**
     * @description 처음 선택 시 본인 상태 보여주고 포커스 in 하면 본인 상태 리스트에서 제거
     * @param component
     * @author 23.02.13 / I2MAX.SEUNGHUNAN
     */
    orderStatusFocus : function(component) {
        var orderStatusList = component.get('v.orderStatusList');
        var stChangeTargetObj = component.get('v.stChangeTargetObj');
        component.set('v.orderStatusList', orderStatusList.filter(function(os) {
            return os != stChangeTargetObj.OrderStatus;
        }));
        component.find('orderStatusSelect').set('v.value', component.get('v.orderStatusList')[0]);

        // onchange
        var orderStChangeDT = component.find('orderStChangeDT');
        var selectedRows = orderStChangeDT.getSelectedRows()[0];
        var prLiList = component.get('v.relatedOrderList');
        var updatedOrderStatus = component.find('orderStatusSelect').get('v.value');
        var selectedId = [];

        for (var idx in prLiList) {
            if (prLiList[idx].Id == selectedRows.Id) {
                prLiList[idx].UpdatedOrderStatus = updatedOrderStatus;
                selectedId.push(prLiList[idx].Id);
                break;
            }
        }
        component.set('v.saveReadOnly', false);
        component.set('v.relatedOrderList', prLiList);
        component.set('v.preSelectedRows', selectedId);
    },

    // testAction : function(component) {
        // var tnMap = component.get('v.originMap');
        // console.log('h0');
        //
        // console.log(JSON.stringify(tnMap));
        // console.log(tnMap);
        // console.log(JSON.stringify(tnMap));
        // console.log('h');
        // console.log(tnMap['TrackingNumber']['asd']);

        // console.log(component.get('v.stChangeTargetObj'));
        // console.log(JSON.stringify(component.get('v.stChangeTargetObj')));
    // },


    fnInitializeConsigneeInformation  : function (component, event, helper) {
        if(component.get('v.isSameContactByReturnRequest')) {
            var contactConsigneeInfo = component.get('v.contactConsigneeInfo');
            contactConsigneeInfo.ConsigneeName = contactConsigneeInfo.ContactName;
            contactConsigneeInfo.ConsigneePhone = contactConsigneeInfo.ContactMobilePhone;
            contactConsigneeInfo.ConsigneeAddress = contactConsigneeInfo.ContactAddress;
            contactConsigneeInfo.ConsigneeDetailAddress = contactConsigneeInfo.ContactDetailAddress;
            component.set('v.contactConsigneeInfo', contactConsigneeInfo);
        } else {
            var contactConsigneeInfo = component.get('v.contactConsigneeInfo');
            contactConsigneeInfo.ConsigneeName = '';
            contactConsigneeInfo.ConsigneePhone = '';
            contactConsigneeInfo.ConsigneeAddress = '';
            contactConsigneeInfo.ConsigneeDetailAddress = '';
            component.set('v.newAddress', '');

            component.set('v.contactConsigneeInfo', contactConsigneeInfo);
        }
    },

    /**
     * @description 주문상태변경 모달에서 저장 버튼 클릭 시
     * @param component, event, helper
     * @author 23.02.13 / I2MAX.SEUNGHUNAN
     */
    fnSave : function(component, event, helper) {
        console.log('fnSave orderStatus Change');
        var target = component.get('v.stChangeTargetObj');
        console.log('target :: ' + JSON.stringify(target));
        var dialog = component.find('dialog');
        if (target.length == 0) {
            helper.showToast('error', '변경할 주문을 선택해주세요.');
            return;
        }
        console.log('asdfas');
        var orderNumber = target[0].OrderNumber;
        var handWorkReason = component.get('v.stChangeTargetObj.HandWorkReason');
        console.log('asdfas1asz');

        if (handWorkReason == null || handWorkReason == '') {
            helper.showToast('error', '변경사유를 입력해주세요.');
            return;
        }
        console.log('osss ');

        var param = {
            message: '주문번호: ' + orderNumber + '\n' +
                     '변경사유: ' + handWorkReason + '\n' +
                     '주문 상태 변경하시겠습니까?'
        };


        dialog.confirm(param, function (response) {
            if (response.result) {
                helper.fnUpdateOrderStatus(component);
            }
        }, null);
    },

    /**
     * @description 판매저장 버튼 클릭 시 판매저장
     * @param component
     * @author 23.02.21 / I2MAX.SEUNGHUNAHN
     */
    fnSelling : function(component, event, helper) {
        //seung yoon heo 판매저장 다중클릭
        component.set('v.salesSaveBtnDisabled', true);
        helper.saveSales(component);
    },

    fnSelling2 : function(component) {
        // 교환주문 포함되어 있음
        var relatedOrderList = component.get('v.relatedOrderList');
        var flag = true;

        console.log('fnSelling relatedOrderList');
        console.log(JSON.stringify(relatedOrderList));

        // 원주문건 중 판매 번호가 없는 것들에 대해서 조회 (판매저장 대상)
        // todo: 모든 품목들에 대해서(다른 항번) 판매저장 인지 막아야 하는지
        relatedOrderList = relatedOrderList.filter(function(ol) {
            var subNumber = ol.SubNumber;
            var salesNumber = ol.SalesNumber;
            return (subNumber != null
                && subNumber != undefined
                && subNumber.includes('-')
                && subNumber.split('-')[2] == '01'
                && (salesNumber == null || salesNumber == undefined));
        });
        console.log('filterRelatedList : ' + JSON.stringify(relatedOrderList));

        var pListMapSalesInfo = [];
        for (var idx in relatedOrderList) {
            console.log('selectedRows');
            var item = relatedOrderList[idx];
            console.log(JSON.stringify(item));

            var mapSalesInfo = {
                'SourceLocationId'         : item.LocationId,
                'Product2Id'               : item.Product2Id,
                'MODELName'                : item.ModelCode,
                //     'WorkOrderId'              : workorderId,
                'SR_RSRV_PART_Id'          : item.SR_RSRV_PART_Id,
                'ProductRequestId'         : item.ParentId,
                'ProductRequestLineItemId' : item.Id,
                //     'ProductTransferId'        : item.ProductTransferId,
                'SalesQuantity'            : item.SalesQuantity,
                //     단가계산 대리점 판매 할인율 코드(SM_DEPT__c의 AGENCY_DC_RATE__c 적용 X)
                'unitPrice'                : item.CustomerPrice,
                'ParentLocation'           : item.ParentLocation,
                'ParentLocationId'         : item.ParentLocationId,
                'Price'                    : item.CustomerPrice,
                'ASCPrice'                 : item.ASCPrice,
                'subTotal'                 : item.SaleAmount,
                'CheckDiscount'            : false,
                // ================= 소모품 용으로 추가 =================
                'ContactId'                : item.ContactId,
                'DeptId'                   : item.ShippedDepartment,
                // ===================================================
                'Substitute'               : item.SubstituteYN == '원' ? '원품' : '대치부품'
                //     ========== 기능성 부품 주문 못하니까 필요 없음 ==========
                //     'TECH_PART_YN'             : item.TECH_PART_YN,
                //     'TechPartsSaleReason'      : TechPartsSaleReason,
                //     'TechPartsSaleOtherReason' : TechPartsSaleOtherReason,
                //     ===================================================
                //     'DeprtmentCode'            : deprtmentCode,
                //     'remarks'                  : item.remarks,
                //     'vipDiscountAmt'           : item.vipDiscountAmt
            };
            pListMapSalesInfo.push(mapSalesInfo);
        }

        console.log('mapSalesInfo :: ' + JSON.stringify(pListMapSalesInfo));

        var action = component.get('c.doSaveSales');
        action.setParams({
            'pStrSelectedTabId' : 'Customer',
            // 소모품 Destination 없음
            'pStrDestinationLocationId' : '',
            'pListMapSalesInfo' : pListMapSalesInfo,
            // 판매정보에 들어가야 할 금액 PR 별로 할당해야할듯
            'pIntTotalAmount' : 0,
            // 판매정보에 들어가야 할 금액 PR 별로 할당해야 할듯
            'pIntDiscountAmount' : 0,
            'pStrContactId' : '',
            'pStrDeptId' : '',
            'pListDocument' : null,
            // 임직원
            'pMapEmpSearchInfo' : null,
            // false 세팅
            'pVipYN' : false,
            'pCouponYN' : false,
        });
    },

    contactConsigneeChange  : function (component, event, helper) {
        var inputName = component.get('v.newName');
        if(!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |]+$/.test(inputName))){
            component.set('v.newName','');
        }


    },

    fnPhoneChg : function(component, event, helper){
        var IbCallNo = component.get("v.newPhone");

        IbCallNo = helper.gfnChgTelFormat(component, event, IbCallNo);
        component.set("v.newPhone", IbCallNo);




      },

    /**
     * @description 주문상태변경 버튼 CSS 설정
     * @param component
     * @author 23.02.26 / I2MAX.SEUNGHUNAN
     */
    fnOrderStatusChg : function(component) {
        var orderStatusBtn = component.find('orderStatusBtn');
        var orderStatusDisabled = component.get('v.orderStatusDisabled');
        if (orderStatusDisabled == false) {
            orderStatusBtn.set('v.class', 'gridSlaveBtn');
        }
        else {
            orderStatusBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 판매저장 버튼 CSS 변경
     * @param component
     * @author 23.03.11 / I2MAX.SEUNGHUNAN
     */
    fnSalesSaveBtnChg : function(component) {
        console.log('판매저장 버튼 chg');
        var salesSaveBtn = component.find('salesSaveBtn');
        var salesSaveBtnDisabled = component.get('v.salesSaveBtnDisabled');
        if (salesSaveBtnDisabled == false) {
            salesSaveBtn.set('v.class', 'gridSlaveBtn');
        }
        else {
            salesSaveBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    handleRowAction: function (component, event, helper) {
            var action = event.getParam('action');
            var row = event.getParam('row');
            console.log('handleRowAction!');
            console.log(JSON.stringify(action));
            console.log('6 : ' + row['Id']);
            var recordId = row['Id'];

            helper.fnSetDeliveryInformationColumns(component, recordId);

            component.set('v.showDeliveryInformationModal', true);
    },

    /**
     * @description 조회 시 모든 버튼 disabled로 초기화
     * 및 페이지네이션 관련 pageoffset 초기화
     * @param component, event
     * @author 23.03.11 / I2MAX.SEUNGHUNAN
     */
    fnSearchBtnClick : function(component, event) {
        var isSearchBtnClick = event.getParam('isSearchBtnClick');
        if (isSearchBtnClick) {
            component.set('v.orderStatusDisabled', true);
            component.set('v.salesSaveBtnDisabled', true);

            // pagination
            component.set('v.pageOffset', 0);
        }
    },

    /**
     * @description 주문내역 리스트가 더 조회가 가능하다면 조회하도록 바닥페이지에 전송
     * @param component, event
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    //23.09.07 PHJ 현재사용 x
    // fnLoadMore : function(component, event, helper) {
    //     var loadMoreValid = helper.loadMoreData(component);
    //     var evt = $A.get('e.c:EX_PaginationResearch_evt');
    //     var pageOffset = component.get('v.pageOffset');
    //     var onloadControl = component.get('v.onloadControl');
    //     var data = component.get('v.data');

    //     /**
    //      * 데이터 테이블에 데이터가 있는 채 조회할 때는 Return으로
    //      * recordLimit 만큼 재조회하도록 한다.
    //      */
    //     if (data.length == 0) return;
    //     if (onloadControl) {
    //         component.set('v.onloadControl', false);
    //         loadMoreValid.then(function(valid) {
    //             if (valid) {
    //                 evt.setParam('pageNumber', pageOffset+1);
    //                 component.set('v.pageOffset', pageOffset+1);
    //                 evt.fire();
    //             }
    //             component.set('v.onloadControl', true);
    //         });
    //     }
    // },


    // updateColumnSorting: function (cmp, event, helper) {
    //     var fieldName = event.getParam('fieldName');
    //     var sortDirection = event.getParam('sortDirection');
    //     cmp.set("v.sortedBy", fieldName);
    //     cmp.set("v.sortedDirection", sortDirection);
    //     helper.sortData(cmp, fieldName, sortDirection);
    // },

    /**
     * @description Wijmo -> SFDC Event Handler
     * @param component
     * @param event
     * @param helper
     */
    onWijmoMessage  : function(component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        switch (payload.type) {
            case 'rowSelection':
                    if(component.get('v.showOrderStChangeModal')){
                        console.log('os rowSelection');
                        //2023.08.01 seung yoon heo 모달 띄울 시 자동으로 값 체크 및 상태 변경
                        console.log(JSON.stringify(component.get('v.selectedRowsFromWijmo')));
                        helper.fnSelectedFromWijmo(component, event, helper, payload.type, component.get('v.selectedRowsFromWijmo'));
                        helper.sendMessage(component, {type:'chekcedData', items: payload.selectedRows});
                        
                    }else{
                        console.log('payLoad : ' + payload);
                        console.log(JSON.stringify(payload));
                        const selectedRows = payload.selectedRows;
                        console.log('selectedRows :: ' + selectedRows);
                        console.log(JSON.stringify(component.get('v.selectedRowsFromWijmo')));

                        helper.buttonCheckerForWijmo(component, selectedRows);
                    }

                break;
            case 'dblclick':
                if (component.get('v.showOrderStChangeModal')) {
                    helper.fnSelectedFromWijmo(component, event, helper, payload.type, payload.selectedRows);
                } else {
                    console.log('dblclick !!!!');
                    component.set('v.selectedRowsFromWijmo', payload.item);
                    console.log(payload.type);
                    console.log(JSON.stringify(component.get('v.selectedRowsFromWijmo')));

                    helper.fnSelectedFromWijmo(component, event, helper, payload.type, null);
                }
            case 'editing':
                if (component.get('v.showOrderStChangeModal')) {
                    var handWorkReason = payload.item.HandWorkReason;
                    component.set('v.stChangeTargetObj.HandWorkReason', handWorkReason);
                }
                break;
            case 'rowAction':
                if(payload.name == 'TrackingSearchPage') {
                    var url = 'https://trace.cjlogistics.com/web/detail.jsp?slipno=' + payload.row.TrackingNumber;
                    window.open(url, '_blank');
                } else {
                    helper.handleWijmoRowAction(component, event, helper, payload.row);
                    component.set('v.componentName','wijmo_EXdeliveryInfo');
                    setTimeout(function () {
                        helper.sendMessage(component, {type:'items', items: component.get('v.deliveryInformationData')});
                    }, 1000);
                }
                break;
            case 'downloadDone':
                component.set('v.showSpinner', false);
                break;
        }
    },

    onStatusChangeWijmoMessage: function(component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        switch (payload.type) {
            case 'editing':
                component.set('v.stChangeTargetObj', payload.item);
            break;
        }
    },


     /**
     * @description Wijmo -> SFDC Event Handler
     * @param component
     * @param event
     * @param helper
     */
    downloadExcel : function(component, event, helper) {
        console.log('downloadExcel !');
        component.set('v.showSpinner', true);
        helper.fnDownloadExcel(component, event, helper);
    }

});