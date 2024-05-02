/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    fnInit: function (component, event, helper) {


        console.log('EX_ReturnOrderList fnInit 시작~');

        //23 11 02 hyungho.chun 탭 여러개 loading.. 결함 처리
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    
            if (tabId) {
                console.log('response.tabId ' , tabId);
                var focusedTabId = tabId;
                console.log('focusedTabId' , focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "소모품반품관리"
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

//         let columns = [

//                 {
//                     label: '반품요청일시', fieldName: 'return_Order_DTM', type: 'date', typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     },
//                     initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '주문채널',
//                     fieldName: 'order_Channel_TYPE',
//                     type: 'text',
//                     hideDefaultActions: true,
//                     initialWidth: 150,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '주문번호',
//                     fieldName: 'Order_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: 'Sub번호',
//                     fieldName: 'Sub_Order_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },

//                 {
//                     label: '주문상태',
//                     fieldName: 'Consumables_Order_Status',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },

//                 {
//                     label: '고객명',
//                     fieldName: 'customer_Name',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '사업부',
//                     fieldName: 'endp_Code',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: 'PART_NO',
//                     fieldName: 'parts_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '매핑모델',
//                     fieldName: 'model_Name',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '품명',
//                     fieldName: 'product_Name',
//                     type: 'text',
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '수량',
//                     fieldName: 'quantity_Returned',
//                     type: 'text',
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: 'CJ반품 주문 번호',
//                     fieldName: 'ffmt_Order_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '반품송장번호',
//                     fieldName: 'invoice_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },

//                 {
//                     label: 'CJ전송일시', fieldName: 'ffmt_Transfer_DTM', type: 'date', typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     },
//                     initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },

//                 // {
//                 //     label: '판매금액',
//                 //     fieldName: 'sale_Amount',
//                 //     type: 'number',
//                 //     initialWidth: 100,
//                 //     hideDefaultActions: true,
//                 //     cellAttributes:{
//                 //         class: {fieldName : 'ErrorColor'}
//                 //     }
//                 //     ,sortable : true
//                 // },
// //                {
// //                    label: '연동여부',
// //                    fieldName: 'linkage_YN',
// //                    type: 'text',
// //                    initialWidth: 100,
// //                    hideDefaultActions: true,
// //                    cellAttributes:{
// //                        class: {fieldName : 'ErrorColor'}
// //                      }
// //                },
//                 {
//                     label: '수거여부',
//                     fieldName: 'collection_YN',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '수거일자',
//                     fieldName: 'confirm_Date',
//                     type: 'date', typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     }, initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '확정',
//                     fieldName: 'CONFIRM_YN',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '반품요청사유',
//                     fieldName: 'Return_Requester_Reason',
//                     type: 'text',
//                     initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }

//                 },

//                 {
//                     label: '결제일자',
//                     fieldName: 'PAYMENT_DTM',
//                     type: 'date',
//                     typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     },
//                     initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '출고일시',
//                     fieldName: 'shipped_Date',
//                     type: 'date',
//                     typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     }, initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '배송완료',
//                     fieldName: 'Delivery_Completed',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },


//                 {
//                     label: '배송일자',
//                     fieldName: 'Delivery_Date',
//                     type: 'date',
//                     typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     }, initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },

//                 {
//                     label: '판매일자', fieldName: 'SALE_DTM', type: 'date', typeAttributes: {
//                         day: 'numeric',
//                         month: 'short',
//                         year: 'numeric',
//                         hour: '2-digit',
//                         minute: '2-digit',
//                         second: '2-digit',
//                         hour12: true
//                     }, initialWidth: 200,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '판매번호',
//                     fieldName: 'SALE_Number',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '판매금액',
//                     fieldName: 'sale_Amount',
//                     type: 'number',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 // {
//                 //     label: '판매항번',
//                 //     fieldName: 'SALE_SEQ',
//                 //     type: 'number',
//                 //     initialWidth: 100,
//                 //     hideDefaultActions: true,
//                 //     cellAttributes:{
//                 //         class: {fieldName : 'ErrorColor'}
//                 //     }
//                 //     ,sortable : true
//                 // },
//                 // {
//                 //     label: '주문항번',
//                 //     fieldName: 'order_SEQ',
//                 //     type: 'number',
//                 //     initialWidth: 100,
//                 //     hideDefaultActions: true,
//                 //     cellAttributes:{
//                 //         class: {fieldName : 'ErrorColor'}
//                 //     }
//                 //     ,sortable : true
//                 // },
//                 {
//                     label: '결제금액',
//                     fieldName: 'PAYMENT_Amount',
//                     type: 'number',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '결제유형',
//                     fieldName: 'payment_Type',
//                     type: 'text',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '현금',
//                     fieldName: 'CASH_PAYMENT_Amount',
//                     type: 'number',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '카드',
//                     fieldName: 'CARD_PAYMENT_Amount',
//                     type: 'number',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '포인트',
//                     fieldName: 'POINT_Amount',
//                     type: 'number',
//                     initialWidth: 100,
//                     hideDefaultActions: true,
//                     cellAttributes: {
//                         class: {fieldName: 'ErrorColor'}
//                     }
//                     , sortable: true
//                 },
//                 {
//                     label: '',
//                     width: 20
//                 },
//             ]
//         ;

//         component.set("v.columns", columns);


        // /* 양품 폐기 모달 컬럼 설정 */
        // let DisposalModalColumns = [
        //     {label: '주문채널', fieldName: 'order_Channel_TYPE', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문번호', fieldName: 'Order_Number', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '고객명', fieldName: 'customer_Name', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: 'PART_NO', fieldName: 'parts_Number', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: '반품수량',
        //         fieldName: 'quantity_Returned',
        //         type: 'number',
        //         initialWidth: 100,
        //         hideDefaultActions: true
        //     },
        //     {
        //         label: '양품수량',
        //         fieldName: 'Good_Quality_Quantity',
        //         type: 'number',
        //         initialWidth: 100,
        //         hideDefaultActions: true,
        //         editable: 'true',
        //         iconName: 'utility:edit',
        //         cellAttributes: {class: {fieldName: 'CancelColor'}}
        //     },
        //     {
        //         label: '폐기수량',
        //         fieldName: 'Disposal_Quantity',
        //         type: 'number',
        //         initialWidth: 100,
        //         hideDefaultActions: true,
        //         editable: 'true',
        //         iconName: 'utility:edit',
        //         cellAttributes: {class: {fieldName: 'CancelColor'}}
        //     },
        //     //{label: '폐기사유', fieldName: 'Disposal_Reason', type:'text', initialWidth:270, hideDefaultActions:true,  editable: 'true', iconName: 'utility:edit', cellAttributes: {class: {fieldName: 'CancelColor'}} },
        //     {
        //         label: '폐기사유',
        //         fieldName: 'Disposal_Reason',
        //         type: 'text',
        //         hideDefaultActions: true,
        //         editable: 'true',
        //         iconName: 'utility:edit',
        //         cellAttributes: {class: {fieldName: 'CancelColor'}}
        //     },
        //     {
        //         label: 'CJ반품 주문번호',
        //         fieldName: 'ffmt_Order_Number',
        //         type: 'text',
        //         initialWidth: 150,
        //         hideDefaultActions: true
        //     },
        //     {label: '반품송장번호', fieldName: 'invoice_Number', type: 'text', initialWidth: 150, hideDefaultActions: true},


        // ];
        // component.set("v.DisposalModalColumns", DisposalModalColumns);

        // /* 배송지 수정 목록 컬럼 설정*/
        // let ChangeAddressDatatableColumns = [
        //     {label: '주문채널', fieldName: 'order_Channel_TYPE', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '주문번호', fieldName: 'Order_Number', type: 'text', hideDefaultActions: true},
        //     {label: '결제자', fieldName: 'OrderCustName', type: 'text', hideDefaultActions: true},
        //     {label: '결제자 전화번호', fieldName: 'OrderCustMobilePhone', type: 'text', hideDefaultActions: true},
        //     {label: '받는분', fieldName: 'ConsigneeName', type: 'text', hideDefaultActions: true},
        //     {label: '받는분 전화번호', fieldName: 'ConsigneeTPNO', type: 'text', hideDefaultActions: true},


        // ];
        // component.set("v.ChangeAddressDatatableColumns", ChangeAddressDatatableColumns);

        /* 23.05.01 반품확정 버튼 초기화 */
        component.set('v.ReturnOrderConfirmBtnDisabled', true);
        component.set('v.HandleDisposalBtnDisabled', true);
        component.set('v.ChangeAddressBtnDisabled', true);
        component.set('v.ChangeReturnOrderCancelBtnDisabled', true);
    },


    //23 09 06 hyungho.chun 위즈모로전환
    // fnSeleceted: function (component, event, helper) {
    //     if (event.getParam('selectedRows').length == 0) {
    //         component.set('v.fStatus', null);
    //         component.set('v.channel', null);
    //         component.set('v.status', null);
    //         component.set('v.linkage_YN', null);
    //         component.set('v.collection_YN', null);
    //         component.set('v.CONFIRM_YN', null);
    //         component.set('v.Consumables_Business_Type_Code', null);

    //         /* 23.05.01 추가 */
    //         component.set('v.ReturnOrderConfirmBtnDisabled', true);
    //         component.set('v.HandleDisposalBtnDisabled', true);
    //         component.set('v.ChangeAddressBtnDisabled', true);
    //         component.set('v.ChangeReturnOrderCancelBtnDisabled', true);
    //     } else {
    //         console.log('selected');
    //         var selectedRows = event.getParam('selectedRows');

    //         var jsonRow = JSON.stringify(selectedRows);
    //         console.log(jsonRow);
    //         //추가
    //         //component.set('v.dataTemp', jsonRow);
    //         component.set('v.dataTemp', selectedRows);
    //         //
    //         component.set('v.channel', selectedRows[selectedRows.length - 1].order_Channel_TYPE);
    //         //component.set('v.status',selectedRows[selectedRows.length-1].status);
    //         component.set('v.status', selectedRows[selectedRows.length - 1].Consumables_Order_Status);//수정
    //         component.set('v.linkage_YN', selectedRows[selectedRows.length - 1].linkage_YN);
    //         component.set('v.collection_YN', selectedRows[selectedRows.length - 1].collection_YN);
    //         component.set('v.CONFIRM_YN', selectedRows[selectedRows.length - 1].CONFIRM_YN);
    //         component.set('v.ffmt_Transfer_YN', selectedRows[selectedRows.length - 1].ffmt_Transfer_YN);
    //         component.set('v.ffmt_Transfer_DTM', selectedRows[selectedRows.length - 1].ffmt_Transfer_DTM);
    //         component.set('v.Consumables_Business_Type_Code', selectedRows[selectedRows.length - 1].Consumables_Business_Type_Code);

    //         console.log(component.get('v.channel'));
    //         console.log('Consumables_Business_Type_Code : ' + component.get('v.Consumables_Business_Type_Code'));
    //         console.log(component.get('v.status'));
    //         console.log(component.get('v.linkage_YN'));
    //         console.log('component.get(v.collection_YN)  : ' + component.get('v.collection_YN'));
    //         console.log('component.get(v.CONFIRM_YN)  : ' + component.get('v.CONFIRM_YN'));
    //         console.log('component.get(v.ffmt_Transfer_YN)  : ' + component.get('v.ffmt_Transfer_YN'));
    //         console.log('component.get(v.ffmt_Transfer_DTM)  : ' + component.get('v.ffmt_Transfer_DTM'));

    //         if (component.get('v.fStatus') == selectedRows[selectedRows.length - 1].status || component.get('v.fStatus') == '' || component.get('v.fStatus') == null) {
    //             console.log('기존 / 동일');

    //             component.set('v.fStatus', selectedRows[0].status);
    //             component.set('v.objSelected', selectedRows);


    //         } else {
    //             var newSelectList = [];
    //             for (var num = 1; num <= selectedRows.length - 1; num++) {
    //                 if (selectedRows[num].status == selectedRows[0].status) {
    //                     console.log('선택됨 : ' + component.get('v.objSelected'));
    //                     newSelectList.add(selectedRows[num]);
    //                 } else {
    //                     component.set('v.channel', null);
    //                     component.set('v.status', null);
    //                     component.set('v.linkage_YN', null);
    //                     component.set('v.collection_YN', null);
    //                     return helper.showToast('error', '동일한 상태의 주문만 선택해주세요');

    //                 }
    //             }
    //         }
    //         //반품반려버튼 활성화 여부 -  주문채널:베스트샵 , 반품상태: 반품대기(102), 소모품오류가 '반품오류'를 포함했는지 - 소모품오류를 포함했는지로 확인
    //         for (var i = 0; i < selectedRows.length; i++) {
    //             var row = selectedRows[i];


    //             var consumablesError = row.Consumables_Error;
    //             var orderStatus = row.Consumables_Order_Status;
    //             var orderChannel = row.order_Channel_TYPE;
    //             //todo 조건문 double check
    //             if ((!consumablesError || !(consumablesError.includes('소모품오류'))) && orderStatus != '반품대기' && orderChannel != '베스트샵') {
    //                 console.log('반품 반려 불가 조건임.');
    //                 console.log('consumablesError : ' + consumablesError + '  ' + 'orderStatus  : ' + orderStatus + '  ' + 'orderChannel  : ' + orderChannel);
    //                 component.set('v.RefundDecline_disable', true);
    //             } else {
    //                 console.log('반품 반려 가능 조건임.');
    //                 console.log('consumablesError : ' + consumablesError + '  ' + 'orderStatus  : ' + orderStatus + '  ' + 'orderChannel  : ' + orderChannel);
    //                 component.set('v.RefundDecline_disable', false);
    //             }
    //         }

    //         // 반품확정 버튼 Validation
    //         component.set('v.ReturnOrderConfirmBtnDisabled', helper.fnReturnOrderConfirmBtnDisabledBtnValid(component));
    //         component.set('v.HandleDisposalBtnDisabled', helper.fnHandleDisposalBtnDisabledValid(component));
    //         component.set('v.ChangeAddressBtnDisabled', helper.fnChangeAddressBtnChg(component));
    //         component.set('v.ChangeReturnOrderCancelBtnDisabled', helper.fnReturnOrderCancelBtnDisabledBtnValid(component));
    //     }
    // },
    
    //23 09 06 hyungho.chun 위즈모로 전환
    // kaka: function (component, event, helper) {
    //     var action = component.get('c.doSendKakaoMessage');

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             console.log('dfdfdf');
    //             var result = response.getReturnValue();
    //             if (result['retCode'] == '200') {
    //                 helper.showToast('success', '알림톡발송');
    //             } else {
    //                 helper.showToast('error', '알림톡실패');

    //             }

    //         } else {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     evt.setParams({
    //                         type: 'Error',
    //                         message: errors[0].message
    //                     });
    //                     evt.fire();
    //                 }
    //             } else {
    //                 this.showToast("error", "Unknown error");
    //             }
    //         }

    //     });

    //     $A.enqueueAction(action);
    // },
    /*반품 요청 철회 */
    cancelReturn: function (component, event, helper) {
        var dialog = component.find('dialog');
        var param = {
            //2024.03.18 seung yoon heo 문구변경
            // message: '반품 요청을 철회하시겠습니까?'
            message: 'CJ 반품취소여부 확인하셨습니까?'
        };

        dialog.confirm(param, function (response) {
            if (response.result) {
                var action = component.get('c.doCancelReturn');
                var selectedRows = component.get('v.objSelected');

                for (var i = 0; i < selectedRows.length; i++) {
                    var row = selectedRows[i];
                    var Consumables_Business_Type_Code = row.Consumables_Business_Type_Code;
                    if (Consumables_Business_Type_Code == 'ExchangeReturn') {
                        return helper.showToast('error', '교환 반품은 반품요청철회가 불가능합니다. 관리자 문의하세요.');
                    }
                }

                action.setParams({
                    'selectedRows': selectedRows
                })

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == 'SUCCESS') {
                        var result = response.getReturnValue();
                        var resultState = result['resultState'];
                        var resultMessage = result['resultMessage'];


                        if (resultState == 'SUCCESS') {
                            helper.showToast("success", "반품 철회가 완료되었습니다.");
                            //23.09.07 PHJ
                            $A.get('e.force:refreshView').fire();
                        } else {
                            helper.showToast("info", resultMessage);

                        }
                    } else {
                        var errors = response.getError();
                        if (errors) {
                            console.log('error : ' + errors[0].message);

                        } else {
                            console.log('Unknown error');
                            helper.showToast("error", "Unknown Error ");
                        }
                    }
                });

                $A.enqueueAction(action);
            }
        }, null);
    },
    /*양품 폐기 처리 모달*/
    //todo ReturnOrder의 레코드타입이 소모품 또는 케어용품 그리고 라인아이템의 주문상태가 반품확정 그리고 CJ전송여부와 수거여부 모두 Y인 데이터만 양품폐기 버튼이 사용되도록 처리 필요

    fnOpenModal: function (component, event, helper) {
        console.log('fnCheckIsDisposal is working ');
        //component.set('v.ShowModal', true);
        component.set('v.componentName', 'wijmo_EXReturnOrderDisposal');
        helper.doOpenModal(component);
        var selectedData = component.get('v.objSelected');
        setTimeout(function () {
            helper.sendMessage(component, {type: 'items', items: selectedData });
        }, 1000);


        console.log(' helper ShowModal True');

    },
    fnCloseModal: function (component, event, helper) {
        helper.doCloseModal(component);
    },

    /*배송지 수정 모달*/
    fnChangeAddressModal: function (component, event, helper) {
        //배송지 수정 컴포넌트 초기화
//        component.set('v.consigneeName', null);
//        component.set('v.consigneeTPNO', null);
//        component.set('v.consigneePostalCode', null);
//        component.set('v.consigneeAddress', null);
//        component.set('v.consigneeAddressDetail', null);
//        component.set('v.deliveryMessage', null);

            helper.fnInitializeConsigneeInformation(component, event, helper);
            helper.doChangeAddressModal(component);

        component.set('v.componentName', 'wijmo_EXReturnAddress');
        setTimeout(function () {
            helper.sendMessage(component, {type: 'items', items: component.get('v.objSelected')});
        }, 1000);

        //23.10.17 PHJ
        let selectedRows = [];
        if(component.get('v.objSelected').length == 1){
            selectedRows.push(component.get('v.objSelected')[0]);
            helper.fnGetConsigneeInfo(component, event, helper, selectedRows);
            helper.doChangeOrderNumber(component,selectedRows);
        }

    },

    fnCloseChangeAddressModal: function (component, event, helper) {
        helper.doCloseChangeAddressModal(component);
    },

    //23 09 06 hyung.ho chun 위즈모 전환
    // /*배송지 수정 모달에서 선택된 내역 가져오기 */
    // fnSelectedInChangeDelivery: function (component, event, helper) {
    //     if (event.getParam('selectedRows'.length == 0)) {
    //         component.set('v.consigneeName', null);
    //         component.set('v.consigneeTPNO', null);
    //         component.set('v.consigneeAddress', null);
    //         component.set('v.consigneePostalCode', null);
    //         component.set('v.consigneeAddressDetail', null);
    //         component.set('v.deliveryMessage', null)

    //     } else {
    //         var selectedRows = event.getParam('selectedRows');
    //         //배송지모달창에서 주문내역을 선택했을때
    //         if (selectedRows != null) {
    //             console.log('event.getParam(selectedRows) : ' + selectedRows);
    //             var jsonRow = JSON.stringify(selectedRows);
    //             console.log('jsonRow : ' + jsonRow);
    //             var b2bYN = selectedRows[selectedRows.length - 1].B2BCustomerYN;//B2B(기업고객)여부 체크
    //             component.set('v.consigneeName', selectedRows[selectedRows.length - 1].ConsigneeName);
    //             component.set('v.consigneeTPNO', selectedRows[selectedRows.length - 1].ConsigneeTPNO);
    //             component.set('v.consigneeAddress', selectedRows[selectedRows.length - 1].ConsigneeAddress);
    //             component.set('v.consigneePostalCode', selectedRows[selectedRows.length - 1].ConsigneePostalCode);
    //             component.set('v.consigneeAddressDetail', selectedRows[selectedRows.length - 1].ConsigneeAddressDetail);
    //             component.set('v.deliveryMessage', selectedRows[selectedRows.length - 1].DeliveryMessage);
    //             component.set('v.IdForChangeDelivery', selectedRows[selectedRows.length - 1].Id);
    //             var lightningCard = component.find('cardTitle');
    //             lightningCard.set('v.label', '주문 번호 : ' + selectedRows[selectedRows.length - 1].Order_Number)
    //         }


    //         console.log('b2bYN : ' + b2bYN);
    //         if (b2bYN != null && b2bYN == true) {
    //             component.set('v.validB2BCustomer', true);
    //         }

    //         //다른 내역을 클릭했을때 기존의 배송지 수정후를 초기화
    //         component.set('v.updatedConsigneeName', null);
    //         component.set('v.updatedConsigneeTPNO', null);
    //         component.set('v.updatedConsigneeAddress', null);
    //         component.set('v.updatedConsigneePostalCode', null);
    //         component.set('v.updatedConsigneeAddressDetail', null);
    //         component.set('v.updatedDeliveryMessage', null);
    //     }
    // },

    /*주소 검색 모듈 최신화*/
    fnSearch: function (component, event, helper) {

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
        console.log('selectedRows :: ' + selectedRows);
        console.log(JSON.stringify(selectedRows));

            // component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
            // component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
        //업데이트 되는 부분 아래
        //2024.02.24 seung yoon heo 이벤트 필드매핑 변경
        component.set('v.consigneeAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
        // component.set('v.consigneeAddressDetail', selectedRows.NADR3S);
        component.set('v.consigneeAddressDetail', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
        // component.set('v.consigneePostalCode', selectedRows.ZPRNR);
        component.set('v.consigneePostalCode', selectedRows.postalCode);

    },

    /*배송지 수정 업데이트*/
    fnChangeAddress: function (component, event, helper) {
        component.set('v.showSpinner', true);

        var cId = component.get('v.IdForChangeDelivery');
        var cName = component.get('v.consigneeName');
        var cTPNO = component.get('v.consigneeTPNO');
        var cPostalCode = component.get('v.consigneePostalCode');
        var cAddress = component.get('v.consigneeAddress');
        // var cAddressDetail = component.get('v.consigneeAddressDetail'); // 24 01 31 PHJ
        var cAddressDetail = component.get('v.consigneeAddressDetail').trim() != '' ? component.get('v.consigneeAddressDetail') : '( )'; // 24 01 31 PHJ
        var cDeliveryMessage = component.get('v.deliveryMessage');

        if(cId == null || cId == undefined) {
            return helper.showToast('info', '수정할 반품 대상을 선택 해 주세요.');
        }

        // 24 01 31 PHJ
        if(cAddressDetail == '( )'){
            component.set('v.consigneeAddressDetail','( )');
        }

        var action = component.get('c.doChangeAddress');

        action.setParams({
            'cId': cId,
            'cName': cName,
            'cTPNO': cTPNO,
            'cPostalCode': cPostalCode,
            'cAddress': cAddress,
            'cAddressDetail': cAddressDetail,
            'cDeliveryMessage': cDeliveryMessage
        })

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == 'SUCCESS') {
                component.set('v.showSpinner', false);

                var result = response.getReturnValue();
                var resultState = result['resultState'];
                var resultMessage = result['resultMessage'];
                if (resultState == 'SUCCESS') {
                    var updatedCName = component.get('v.consigneeName');
                    var updatedCTPNO = component.get('v.consigneeTPNO');
                    var updatedCAddress = component.get('v.consigneeAddress');
                    var updatedCPostalCode = component.get('v.consigneePostalCode');
                    var updatedCAddressDetail = component.get('v.consigneeAddressDetail');
                    var updatedCDeliveryMessage = component.get('v.deliveryMessage');
                    component.set('v.updatedConsigneeName', updatedCName);
                    component.set('v.updatedConsigneeTPNO', updatedCTPNO);
                    component.set('v.updatedConsigneeAddress', updatedCAddress);
                    component.set('v.updatedConsigneePostalCode', updatedCPostalCode);
                    // 24 01 31 PHJ
                    if(updatedCAddressDetail == '( )'){
                        component.set('v.updatedConsigneeAddressDetail','( )');
                    } else {
                        component.set('v.updatedConsigneeAddressDetail', updatedCAddressDetail);    
                    }
                    component.set('v.updatedDeliveryMessage', updatedCDeliveryMessage);
                    helper.showToast('success', '배송지 수정이 완료되었습니다');

                } else {
                    helper.showToast('info', resultMessage);

                }

            } else {
                var errors = response.getError();
                if (errors) {
                    helper.showToast('error', resultMessage);
                    component.set('v.showSpinner', false);
                } else {
                    helper.showToast('error', 'Unknown Error');
                    component.set('v.showSpinner', false);
                }
            }

        });
        $A.enqueueAction(action);
    },

    // 23 09 06 hyungho.chun 위즈모 전환
    // fnCheckVal: function (component, event, helper) {
    //     //수정된 데이터들 가져오기
    //     let draftValues = event.getParams('draftValues');
    //     console.log('fncheckval 에서 가져온 draftValues2' + JSON.stringify(draftValues));

    // },

    /*양품 폐기 처리 저장*/
    fnCheckDisposal: function (component, even, helper) {
        component.set('v.showSpinner', true);

        var action = component.get('c.doHandleDisposal');
//        var draftValues = component.find('DisposalDataTable').get('v.draftValues');
        var selectedRows = component.get('v.objSelectedDisposal');
        //2024.01.10 seung yoon heo
        var data = component.get('v.data');

        //23.09.20 PHJ
        var reasonValid = true;
        var qtyValid = true;
        var regularValid = true;
        let objSelectedDisposal = component.get('v.objSelectedDisposal');    
        objSelectedDisposal.forEach((item) => {
            //23.11.06 PHJ
            if(item.Good_Quality_Quantity == undefined) item.Good_Quality_Quantity = 0;
            if(item.Disposal_Quantity == undefined) item.Disposal_Quantity = 0;

            if((item.Disposal_Quantity != 0 && item.Disposal_Reason == undefined) || (item.Disposal_Quantity != 0 && item.Disposal_Reason.trim() == '')){
                helper.showToast('error', '폐기 사유를 입력해 주세요.');
                component.set('v.showSpinner', false);
                reasonValid = false;
                return;
            }
            if(String(item.Good_Quality_Quantity).includes('.') == true || String(item.Disposal_Quantity).includes('.') == true){
                helper.showToast('warning', '수량은 정수만 입력할 수 있습니다. 수량을 확인해주세요.'); 
                component.set('v.showSpinner', false);
                regularValid = false;
                return;
            }
            if(item.Good_Quality_Quantity + item.Disposal_Quantity != item.quantity_Returned){
                helper.showToast('warning', '양품수량과 폐기수량의 합이 반품수량과 맞지 않습니다.'); 
                component.set('v.showSpinner', false);
                qtyValid = false;
                return;
            }
            if(item.Good_Quality_Quantity == 0 && item.Disposal_Quantity == 0) {
                helper.showToast('warning', '수량을 확인해주세요.'); 
                component.set('v.showSpinner', false);
                qtyValid = false;
                return;
            }
        });

        if(reasonValid == true && qtyValid == true && regularValid == true){
            component.set('v.returnCompleteValid', true);
        }

        if(component.get('v.returnCompleteValid') == true){
            action.setParams({
                'draftValues': selectedRows
    
            })
    
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    var resultState = result['resultState'];
                    var resultMessage = result['resultMessage'];
    
                    console.log('response : ' + response);
                    console.log('resultState : ' + resultState + ' , resultMessage : ' + resultMessage);
                    if (resultState == 'SUCCESS') {
                        if (result.failOrder) {
                            helper.showToast("info", result.failOrder + "처리 실패 관리자에게 문의해주세요. \n 실패건수" + result.failOrder.length + "건");
                            component.set('v.ShowModal', false); // 24 01 10 PHJ 모달 닫기
                            data = data.filter(val => !selectedRows.filter(val => !result.failOrderId.some(item => val.Id === item.Id)).some(item => val.Id === item.Id));
                        } else{

                            helper.showToast("success", "양품/폐기수량 처리가 완료되었습니다");
                            data = data.filter(val => !selectedRows.some(item => val.Id === item.Id));
                        }

                        // 2024.01.10 seung yoon heo 양품/폐기 후 해당 값 리스트에서 삭제후 위즈모 재 호출
                    //     data.forEach((val, index)=>{
                    //         selectedRows.forEach(item=>{
                    //          if (val.Id == item.Id) {
                    //                data.splice(index, 1);  
                                 
                    //          }
                    //      })
                    //  });    
                    
                        component.set('v.data', data);

                        component.find('wijmo_EXReturnOrderList').message({type:'items', items: data});
                     
                        // $A.get('e.force:refreshView').fire(); // 24 01 10 PHJ 리프레쉬 불필요
                        component.set('v.ShowModal', false); // 24 01 10 PHJ 모달 닫기
                        component.set('v.showSpinner', false);
                    } else {
                        helper.showToast("info", resultMessage);
                        component.set('v.showSpinner', false);
                    }
                } else {
                    var errors = response.getError();
                    if (errors) {
                        component.set('v.showSpinner', false);
                    } else {
                        helper.showToast("error", "Unknown Error ");
                        component.set('v.showSpinner', false);
                    }
                }
            });
    
            $A.enqueueAction(action);
        }
        else{
            component.set('v.showSpinner', false);
            console.log('save valid!');
            return;
        }
    },

    /* 반품반려 */
    fnRefundDecline: function (component, event, helper) {
        component.set('v.showSpinner', true); //24 01 31 hyungho.chun
        console.log('반품 반려 진행');
        //반품반려대상이 아닌 건이 있는 경우 메세지를 표시한다
        //반품반려대상 조건 : 주문채널 = 베스트샵 & 주문상태 = 반품대기 혹은 반품오류
        //Toast 내용 : 반려대상이 아닌 건이 선택되었습니다. 주문채널 = 베스트샵 & 주문상태 = 반품대기 혹은 반품오류 건만 가능합니다.
        var selectedRows = component.get('v.objSelected');
        var action = component.get('c.doRefundDeclined');

        action.setParams({
            'selectedRows': selectedRows
        })

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                var resultState = result['resultState'];
                var resultMessage = result['resultMessage'];
                if (resultState == 'SUCCESS') {
                    console.log('반품 반려 완료');
                    helper.showToast('success', '반품 반려가 완료되었습니다.');
                    $A.get('e.force:refreshView').fire(); //24 01 31 hyungho.chun
                } else {
                    console.log('반품반려대상이 아님');
                    helper.showToast('info', resultMessage);
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    helper.showToast('error', resultMessage);
                } else {
                    helper.showToast("error", "Unknown Error");
                }
            }
            component.set('v.showSpinner', false); //24 01 31 hyungho.chun
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 선택한 반품 요청 건에 대한 반품 확정 처리
     * @param component
     * @param event
     * @param helper
     * @author 23.03.21 / I2MAX.SEOKHOLEE
     */

    //23.09.01 PHJ
    "returnOrderConfirm":function(component, event, helper) {

        console.log('반품확정버튼으로 팝업 열릴 때 ');
        console.log(' collection_YN :: ', component.get('v.collection_YN'));
        console.log(' collection_YN_Boolean :: ', component.get('v.collection_YN_Boolean'));
        console.log(' collection_YN_temp :: ', component.get('v.collection_YN_temp'));

        //23 12 09 hyungho.chun 이젠 수거여부도 화면 반품확정때 파람에 넣어줘야함
        if(component.get('v.collection_YN') == 'Y'){
            component.set('v.collection_YN_temp', 'Y');

            console.log(' 이미 수거여부 Y라서 collection_YN_temp 도 업데이트침!!  collection_YN_temp -> ', component.get('v.collection_YN_temp'));
        }

        //23.10.31 gw.lee
        //반품 확정 단건만 가능
        if (component.get('v.objSelected').length == 1) {
            component.set('v.textAreaValue', '');
            component.set('v.showConfirmDialog', true);
        } else {
            helper.showToast('Warning', '반품 확정은 1건만 가능합니다.');
        }
        // console.log('🤦‍♂️',component.get('v.showConfirmDialog'));
    },
    //23.09.01 PHJ
    "handleConfirmDialogNo" : function(component, event, helper) {
        // console.log('No');
        component.set('v.showConfirmDialog', false);

        //23 12 08 hyungho.chun 수거 체크박스 초기화
        component.set('v.collection_YN_Boolean',false);
        // component.set('v.collection_YN_temp','N');
        component.set('v.collection_YN_temp','Y'); //24 03 22 hyungho.chun default 값 Y 처리
    },
    //23.09.01 PHJ
    "handleConfirmDialogYes" : function(component, event, helper) {
        // console.log('Yes');
        console.log('확인버튼누를떄!');
        console.log(' collection_YN :: ', component.get('v.collection_YN'));
        console.log(' collection_YN_Boolean :: ', component.get('v.collection_YN_Boolean'));
        console.log(' collection_YN_temp :: ', component.get('v.collection_YN_temp'));
        //23 12 08 hyungho.chun 수거여부부터체크
        

        if(component.get('v.textAreaValue') != ''){
            helper.fnReturnOrderConfirm(component, event, helper);
            component.set('v.showConfirmDialog', false);
        }
        else{
            helper.showToast('Warning', '반품 확정 사유를 입력해 주세요.');
        }


    },


    /**
     * @description 반품 확정 버튼 css 설정
     * @param component
     * author 23.05.01 / I2MAX.JIEUNSONG
     */
    fnReturnOrderConfirmBtnChg: function (component) {
        var returnOrderConfirmBtn = component.find('returnOrderConfirmBtn');
        var ReturnOrderConfirmBtnDisabled = component.get('v.ReturnOrderConfirmBtnDisabled');
        if (ReturnOrderConfirmBtnDisabled == false) {
            returnOrderConfirmBtn.set('v.class', 'gridSlaveBtn');
        } else {
            returnOrderConfirmBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },
    /**
     * @description 양품/폐기 확정 버튼 css 설정
     * @param component
     * author 23.05.01 / I2MAX.JIEUNSONG
     */
    fnHandleDisposalBtnChg: function (component) {
        var handleDisposalBtn = component.find('handleDisposalBtn');
        var HandleDisposalBtnDisabled = component.get('v.HandleDisposalBtnDisabled');
        if (HandleDisposalBtnDisabled == false) {
            handleDisposalBtn.set('v.class', 'gridSlaveBtn');
        } else {
            handleDisposalBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 배송지수정 버튼 css 설정
     * @param component
     * author 23.05.01 / I2MAX.JIEUNSONG
     */
    fnChangeAddressBtnChg: function (component) {
        var changeAddressBtn = component.find('changeAddressBtn');
        var ChangeAddressBtnDisabled = component.get('v.ChangeAddressBtnDisabled');
        if (ChangeAddressBtnDisabled == false) {
            changeAddressBtn.set('v.class', 'gridSlaveBtn');
        } else {
            changeAddressBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 반품요청철회 버튼 css 설정
     * @param component
     * author 23.05.01 / I2MAX.JIEUNSONG
     */
    fnReturnOrderCancelBtnChg : function (component) {
        var changeReturnOrderCancelBtn = component.find('changeReturnOrderCancelBtn');
        var ChangeReturnOrderCancelBtnDisabled = component.get('v.ChangeReturnOrderCancelBtnDisabled');
        if (ChangeReturnOrderCancelBtnDisabled == false) {
            changeReturnOrderCancelBtn.set('v.class', 'gridSlaveBtn');
        } else {
            changeReturnOrderCancelBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 조회 시 모든 버튼 disabled로 초기화
     * 및 페이지네이션 관련 pageoffset 초기화
     * @param component, event
     * @author 23.03.11 / I2MAX.SEUNGHUNAN
     */
    fnSearchBtnClick: function (component, event) {
        var isSearchBtnClick = event.getParam('isSearchBtnClick');
        if (isSearchBtnClick) {
            // pagination
            component.set('v.pageOffset', 0);
        }
        // Send Wijmo
        console.log(':::: Send Wijmo ::::');
        var data = component.get('v.data');
//        helper.sendMessage(component, {type:'items', items: data});

        //this.sendMessage(component, {type: 'items', items: result.data});
        //component.find('wijmo_statement').message(msg);
//        var msg = {type: 'items', items: data};
//        component.find('wijmo_EXReturnOrderList').message(msg);
    },

    // /**
    //  * @description 주문내역 리스트가 더 조회가 가능하다면 조회하도록 바닥페이지에 전송
    //  * @param component, event
    //  * author 23.05.10 / I2MAX.SEUNGHUNAN
    //  */
    // 23 09 06 hyungho.chun 위즈모로 전환
    // fnLoadMore: function (component, event, helper) {
    //     var loadMoreValid = helper.loadMoreData(component);
    //     var evt = $A.get('e.c:EX_PaginationResearch_evt');
    //     var pageOffset = component.get('v.pageOffset');
    //     var onloadControl = component.get('v.onloadControl');
    //     var data = component.get('v.data');

    //     /**
    //      * 데이터 테이블에 데이터가 있는 채 조회할 때는 Return으로
    //      * recordLimit 만큼 재조회하도록 한다.
    //      */
    //     if (data.length === 0) return;

    //     if (onloadControl) {
    //         component.set('v.onloadControl', false);
    //         loadMoreValid.then(function (valid) {
    //             if (valid) {
    //                 evt.setParam('pageNumber', pageOffset + 1);
    //                 component.set('v.pageOffset', pageOffset + 1);
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
     *
     * @param component
     * @param event
     * @param helper
     */
    onWijmoMessage: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        switch (payload.type) {
            case 'rowSelection':
                console.log('wijmo rowSelection');
                component.set('v.wijmoSelectedRows', payload.selectedRows);
                helper.fnSelecetedWijmo(component, event, helper);
                break;
            case 'dblclick':
                //23 07 19 hyungho.chun 더블클릭시에도 배송지 수정
                console.log('더블클릭탐');
                // console.log('wijmo rowSelection');
                // component.set('v.wijmoSelectedRows', payload.selectedRows);
                component.set('v.wijmoSelectedRows', payload.item);
                helper.fnSelecetedWijmo(component, event, helper);
                // let selectedRows = [];
                // selectedRows.push(JSON.parse(JSON.stringify(payload.item)));

                // console.log(JSON.parse(JSON.stringify(payload.item)));

                // helper.fnGetConsigneeInfo(component, event, helper, selectedRows);
                // //23 07 18 hyungho.chun 배송지 수정 주문번호 수정기능
                // // helper.doChangeOrderNumber(component,selectedRows);
                // console.log('더블클릭탔음 fnSelecetedWijmo 탈차례');
                // component.set('v.wijmoSelectedRows', payload.selectedRows);
                // helper.fnSelecetedWijmo(component, event, helper);

            case 'editing':
                component.set('v.objSelected', payload.item);
                break;
            case 'toast' :
                helper.showToast('info', '반품 항목 선택 시 동일한 반품 주문 상태 건만 선택 가능 합니다.');
                break;
            case 'downloadDone':
                component.set('v.showSpinner', false);
                break;

        }
    },
    //23 07 18 hyungho.chun 배송지 수정 팝업 내 위즈모용
    onWijmoMessageForAddressChange: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        let selectedRows = [];
        switch (payload.type) {
            //23 07 21 hyungho.chun 배송지 팝업 rowSelection기능추가
            case 'rowSelection':
                console.log('wijmo rowSelection');
                
                selectedRows.push(JSON.parse(JSON.stringify(payload.selectedRows[0])));

                console.log(JSON.parse(JSON.stringify(payload.selectedRows[0])));
                
                helper.fnGetConsigneeInfo(component, event, helper, selectedRows);
                
                helper.doChangeOrderNumber(component,selectedRows);
                break;
            case 'dblclick':
                
                selectedRows.push(JSON.parse(JSON.stringify(payload.item)));

                console.log(JSON.parse(JSON.stringify(payload.item)));

                helper.fnGetConsigneeInfo(component, event, helper, selectedRows);
                //23 07 18 hyungho.chun 배송지 수정 주문번호 수정기능
                helper.doChangeOrderNumber(component,selectedRows);

            // case 'editing':
            //     component.set('v.objSelected', payload.item);
            //     break;
            // case 'toast' :
            //     helper.showToast('info', '반품 항목 선택 시 동일한 반품 주문 상태 건만 선택 가능 합니다.');
            //     break;

        }
    },
    //23 07 19 hyungho.chun 양품/폐기 위즈모 분리
    onWijmoMessageForDisposal: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));

        console.log('v.objSelected :',component.get('v.objSelected'));
        // component.set('v.objSelectedDisposal', component.get('v.objSelected'));
        console.log('v.objSelectedDisposal 수정직전 :',component.get('v.objSelectedDisposal'));

        switch (payload.type) {
            //23.10.05 PHJ
            case 'click':
                component.set('v.targetCol', payload.targetCol);
                component.set('v.clickValue', payload.innerText);
                component.set('v.targetRow', payload.targetRow);
                break;
            //23.10.05 PHJ
            case 'keydown':
                if(payload.keyCode == 67){
                    component.set('v.setVal', component.get('v.clickValue'));
                    helper.sendMessage(component, {type: 'keydown', items: component.get('v.setVal')});
                }
                else if(payload.keyCode == 86){
                    if(component.get('v.targetCol') == 5) {
                        component.set('v.clickValue', component.get('v.setVal'));
                        component.get('v.objSelectedDisposal')[component.get('v.targetRow')].Good_Quality_Quantity = component.get('v.clickValue');
                    }
                    else if(component.get('v.targetCol') == 6) {
                        component.set('v.clickValue', component.get('v.setVal'));
                        component.get('v.objSelectedDisposal')[component.get('v.targetRow')].Disposal_Quantity = component.get('v.clickValue');
                    }
                }
                break;

                
            // case 'rowSelection':
            //     console.log('wijmo rowSelection');
            //     component.set('v.wijmoSelectedRows', payload.selectedRows);
            //     helper.fnSelecetedWijmo(component, event, helper);
            //     break;
            // case 'dblclick':
            //     let selectedRows = [];
            //     selectedRows.push(JSON.parse(JSON.stringify(payload.item)));

            //     console.log(JSON.parse(JSON.stringify(payload.item)));

            //     helper.fnGetConsigneeInfo(component, event, helper, selectedRows);
            //     //23 07 18 hyungho.chun 배송지 수정 주문번호 수정기능
            //     helper.doChangeOrderNumber(component,selectedRows);

            case 'editing':
                //23 07 19 hyungho.chun 양품/폐기 모달에서 선택한 row 따로 분리
                //23 08 17 hyungho.chun 멀티 row가능하게 수정
                let objSelectedDisposal = component.get('v.objSelectedDisposal');    
                let draftValues = JSON.parse(JSON.stringify(payload.item));
                console.log('draftValues ::: ' + draftValues);
                console.log('draftValues ::: ' + JSON.stringify(draftValues));

                objSelectedDisposal.forEach((item) => {
                    if(draftValues.Id == item.Id){
                        //23.10.05 PHJ
                        item.Good_Quality_Quantity = draftValues.Good_Quality_Quantity;
                        item.Disposal_Quantity = draftValues.Disposal_Quantity;
                        
                        if(draftValues.Disposal_Reason != null){
                            item.Disposal_Reason = draftValues.Disposal_Reason;
                        }
                        // 24 01 10 PHJ 폐기 사유가 '' 일 경우 처리
                        if(draftValues.Disposal_Reason == undefined){
                            item.Disposal_Reason = '';
                        }

                        if(String(draftValues.Good_Quality_Quantity).includes('-') == true || String(draftValues.Disposal_Quantity).includes('-') == true) {
                            helper.showToast('warning', '수량은 음수일 수 없습니다. 수량을 확인해주세요.');
                            item.Good_Quality_Quantity = 0;
                            item.Disposal_Quantity = 0;
                            return;
                        }

                        if(String(draftValues.Good_Quality_Quantity).includes('.') == true || String(draftValues.Disposal_Quantity).includes('.') == true){
                            helper.showToast('warning', '수량은 정수만 입력할 수 있습니다. 수량을 확인해주세요.');
                            return;
                        }
                        
                    }
                });
                component.set('v.objSelectedDisposal',objSelectedDisposal);
                component.get('v.objSelectedDisposal 수정직후 :',component.get('v.objSelectedDisposal'));
                // component.set('v.objSelectedDisposal', payload.item);


                break;
            case 'toast' :
                helper.showToast('info', '반품 항목 선택 시 동일한 반품 주문 상태 건만 선택 가능 합니다.');
                break;

        }
    },

    fnSearchData: function (component, event, helper) {
        component.set('v.componentName', 'wijmo_EXReturnOrderList');
        helper.sendMessage(component, {type: 'items', items: component.get('v.data')});

    },
    downloadExcel: function (component, event, helper) {
        console.log('downloadExcel !');
        component.set('v.showSpinner', true);
        helper.fnDownloadExcel(component, event, helper);
    },

    //24 01 24 hyungho.chun 케어플러스용 반품승인 버튼추가
    /* 반품승인 */
    fnRefundAccept: function (component, event, helper) {
        component.set('v.showSpinner', true); //24 01 31 hyungho.chun
        console.log('반품 승인 진행');
        //반품반려대상이 아닌 건이 있는 경우 메세지를 표시한다
        //반품반려대상 조건 : 주문채널 = 베스트샵 & 주문상태 = 반품대기 혹은 반품오류
        //Toast 내용 : 반려대상이 아닌 건이 선택되었습니다. 주문채널 = 베스트샵 & 주문상태 = 반품대기 혹은 반품오류 건만 가능합니다.
        var selectedRows = component.get('v.objSelected');
        var action = component.get('c.acceptRefund');

        action.setParams({
            'selectedRows': selectedRows
        })

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                var resultState = result['resultState'];
                var resultMessage = result['resultMessage'];
                if (resultState == 'SUCCESS') {
                    console.log('반품 승인 완료');
                    helper.showToast('success', '반품 승인이 완료되었습니다.');
                    $A.get('e.force:refreshView').fire(); //24 01 31 hyungho.chun
                } else {
                    console.log('반품승인대상이 아님');
                    helper.showToast('info', resultMessage);
                    $A.get('e.force:refreshView').fire(); //24 02 01 hyungho.chun
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    helper.showToast('error', resultMessage);
                } else {
                    helper.showToast("error", "Unknown Error");
                }
            }
            component.set('v.showSpinner', false); //24 01 31 hyungho.chun
        });

        $A.enqueueAction(action);
    },


});