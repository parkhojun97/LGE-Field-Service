/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-11.
 */

({
    fnInit: function (component, event, helper) {

        /* 주문취소, 반품요청, 교환요청(todo) 버튼 초기화 */
        component.set('v.orderCancelBtnDisabled', true);
        component.set('v.returnRequestBtnDisabled', true);
        component.set('v.exchangeRequestBtnDisabled', true);

       
        // helper.fnSetReturnColumns(component);
        // helper.fnSetExchangeColumns(component);

        // let closeModalColumns = [
        //     {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '요청 파트넘버', fieldName: 'RequestedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
        //     {label: '소비자가', fieldName: 'CustomerPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     //{label: '취소수량', fieldName: 'CancelQuantity', type: 'number', editable:'true', iconName: 'utility:edit', initialWidth: 100, hideDefaultActions: true, cellAttributes: {class: {fieldName: 'CancelColor'}}},
        //     //{label: '취소금액', fieldName: 'CancelAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {
        //         label: '취소사유',
        //         fieldName: 'CancelRequestReason',
        //         type: 'text',
        //         initialWidth: 250,
        //         editable: 'true',
        //         iconName: 'utility:edit',
        //         hideDefaultActions: true,
        //         cellAttributes: {class: {fieldName: 'CancelColor'}}
        //     },
        //     {
        //         label: '주문수량',
        //         fieldName: 'QuantityRequested',
        //         type: 'number',
        //         initialWidth: 100,
        //         hideDefaultActions: true
        //     },
        //     {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
        //     {label: '결제방식', fieldName: 'PaymentMethod', type: 'text', initialWidth: 150, hideDefaultActions: true}
        // ];

        // component.set("v.closeModalColumns", closeModalColumns);

        //은행코드
        // component.set("v.bankOptions", [
        //     {label: '기업은행', value: '003'},
        //     {label: '국민은행', value: '004'},
        //     {label: '외한은행', value: '005'},
        //     {label: '수협은행', value: '007'},
        //     {label: '농협은행', value: '011'},
        //     {label: '우리은행', value: '020'},
        //     {label: '제일은행', value: '023'},
        //     {label: '씨티은행', value: '027'},
        //     {label: '대구은행', value: '031'},
        //     {label: '부산은행', value: '032'},
        //     {label: '광주은행', value: '034'},
        //     {label: '전북은행', value: '037'},
        //     {label: '경남은행', value: '039'},
        //     {label: '우체국', value: '071'},
        //     {label: '하나은행', value: '081'},
        //     {label: '신한은행', value: '088'},
        //     {label: 'K은행', value: '089'},
        //     {label: '삼성은행', value: '024'}
        // ]);
    },

    getOrderLineItemData: function (component, event, helper) {
        console.log('@@@@@getOrderLineItemData');
        // 이벤트 인입 여부 True
        component.set('v.isEvt', true);
        /* 주문취소, 반품요청, 교환요청 버튼 초기화 */
        component.set('v.orderCancelBtnDisabled', true);
        component.set('v.returnRequestBtnDisabled', true);
        component.set('v.exchangeRequestBtnDisabled', true);
        helper.fnGetOrderLineItemData(component, event, helper);
    },

    fnSelected: function (component, event, helper) {
        console.log('fnSelected');
        var selectedRows = event.getParam('selectedRows');
        // 선택 취소하거나, 선택 후 주문내역 입력할 경우 selectedRows length가 0 이 되었을 때 pass
        if (selectedRows.length == 0 || selectedRows == null || selectedRows == undefined) {
            component.set('v.orderCancelBtnDisabled', true);
            component.set('v.returnRequestBtnDisabled', true);
            component.set('v.exchangeRequestBtnDisabled', true);
            return;
        }
        component.set('v.objSelected', selectedRows);
        component.set('v.channelType', selectedRows[0].OrderChannel);

        // 주문취소 버튼 Validation
        component.set('v.orderCancelBtnDisabled', helper.fnOrderCancelBtnValid(component));
        // 반품요청 버튼 Validation
        component.set('v.returnRequestBtnDisabled', helper.fnReturnRequestBtnValid(component));
        // 교환요청 버튼 Validation
        component.set('v.exchangeRequestBtnDisabled', helper.fnExchangeRequestBtnValid(component));
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

    //취소 수량 수정
    // fnChkVal: function (component, event, helper) {
    //     //변경 데이터
    //     let draftValues = event.getParam('draftValues');
    //     //데이터테이블 데이터
    //     let objSelected = component.get("v.dataForCancel");

    //     let isValidQuantity = new Map();

    //     isValidQuantity = helper.fnChkQuantity(objSelected, draftValues);

    //     // 취소사유 동일 체크 시 취소사유 모두 동일하게
    //     var isSameCancelRequestReason = component.get('v.isSameCancelRequestReason');
    //     console.log('isSameCancelRequestReason =>' + isSameCancelRequestReason);

    //     objSelected.forEach((item) => {
    //         draftValues.forEach((draftItem) => {
    //             if (isSameCancelRequestReason) {
    //                 item.CancelRequestReason = draftItem.CancelRequestReason;
    //             }
    //         });
    //     });

    //     if (!isValidQuantity.get('isValid')) {
    //         helper.showToast('error', isValidQuantity.get('message'));
    //     }
    // },
    //Close Modal
    fnModalClose: function (component, event, helper) {

        /*
            모달 창 오픈 시 뒤에 배경 화면 scroll 방지

        var evt = $A.get("e.c:EX_Overflow_evt");

        evt.setParam("CssClass", false);
        evt.fire();
        */

        helper.doCloseModal(component);
    },
    //계좌검증
    fnCheckBankAccount: function (component, event, helper) {
        var bankCode = component.get('v.bankCode'); //은행코드
        var bankAccountNo = component.get('v.bankAccountNo'); //계좌번호
        var receiverName = component.get('v.receiverName'); //예금주명
        var selectedMasterData = component.get('v.selectedMasterData');

        var action = component.get('c.doCheckBankAccount');

        if (bankCode == null || bankAccountNo == null || receiverName == null) {
            component.set('v.isValidBankAccount', false);
            helper.showToast('error', ' 계좌정보를 입력해 주세요.');
        } else {
            action.setParams({
                'bankCode': bankCode,
                'bankAccountNo': bankAccountNo,
                'receiverName': receiverName,
                'selectedMasterData': selectedMasterData
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var resultStat = result['resultStat'];
                    var resultMessage = result['resultMessage'];

                    console.log('resultStat:' + resultStat);
                    console.log('resultMessage:' + resultMessage);

                    if (resultStat == "SUCCESS") {
                        component.set('v.isValidBankAccount', true);
                        helper.showToast("success", "계좌검증이 완료되었습니다.");
                    } else {
                        component.set('v.isValidBankAccount', false);
                        helper.showToast("error", resultMessage);
                    }
                } else {
                    component.set('v.isValidBankAccount', false);
                    var errors = response.getError();
                    if (errors) {
                        console.log('error : ' + errors[0].message);
                        console.log('errors : ' + errors);
                        if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                    } else {
                        console.log("Unknown error");
                        helper.showToast("error", "Unknown error");
                    }
                }
            });
            // component.set('v.isValidBankAccount', true);
            // helper.showToast("success", "(임시)계좌검증이 완료되었습니다.");
            $A.enqueueAction(action);
        }
    },

    /**
     * @description 주문 취소 버튼 css 설정
     * @param component
     * author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnOrderCancelBtnChg : function(component) {
        var orderCancelBtn = component.find('orderCancelBtn');
        var orderCancelBtnDisabled = component.get('v.orderCancelBtnDisabled');
        if (orderCancelBtnDisabled == false) {
            orderCancelBtn.set('v.class', 'gridSlaveBtn');
        }
        else {
            orderCancelBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },
    // 주문취소
    fnOpenOrderCancelModal: function (component, event, helper) {
        console.log('foocm1');
        var evt = $A.get("e.c:EX_Overflow_evt");
        evt.setParam("CssClass", true);
        evt.fire();
        console.log('foocm2');
        helper.doOpenCancelOrderModal(component);
        // let objSelected = component.get("v.objSelected");
        // if (objSelected.length > 0) {
        //     //주문채널 : ThinQ
        //     //주문상태 : 일반주문 결제요청, 결제완료, 상품준비중, 품절주문 결제요청, 결제완료, 품절주문완료(약속상태-요청중 or 입고완료)
        //     //요청구분 : 주문, 교환주문
        //     let valid = true; //주문상태 validation
        //     let valid2 = true; //약속상태 validation
        //     let valid3 = true; //요청구분 validation
        //     let valid4 = true; //주문채널 validation
        //     let isVBANKRefund = component.get('v.isVBANKRefund'); //가상계좌환불정보 미출력 여부
        //
        //     objSelected.forEach(function (selected) {
        //         if (!(selected.OrderStatus == "결제요청"
        //             || selected.OrderStatus == "결제완료"
        //             || selected.OrderStatus == "상품준비중"
        //             || selected.OrderStatus == "품절예약완료")) {
        //             valid = false;
        //         }
        //         /*if(selected.OrderStatus == "품절예약완료" && (selected.AppointmentStatus != "요청중" && selected.AppointmentStatus != "입고완료")){
        //             valid2 = false;
        //         }*/
        //         if (!(selected.ConsumablesBusinessTypeCode == "주문" || selected.ConsumablesBusinessTypeCode == "교환주문")) {
        //             valid3 = false;
        //         }
        //         if (selected.OrderChannel != "ThinQ") {
        //             valid4 = false;
        //         }
        //         if (selected.OrderChannel == "ThinQ") {
        //             //가상계좌환불정보 미출력 여부 (ThinQ 는 항상 미출력)
        //             isVBANKRefund = true;
        //             component.set("v.isVBANKRefund", isVBANKRefund);
        //         }
        //     });
        //     /////////////////테스트용 임시
        //     /*valid = true;
        //     valid2 = true;
        //     valid3 = true;
        //     valid4 = true;
        //     */
        //     /////////////////테스트용 임시
        //     if (valid) {
        //         if (!valid2) {
        //             helper.showToast('info', '품절예약완료상태 일 경우, 약속상태가 \"요청중\",\"입고완료\"일 경우만 취소가 가능합니다.');
        //         } else {
        //             if (!valid3) {
        //                 helper.showToast('info', '요청구분이 \"주문\",\"교환주문\"일 경우만 취소가 가능합니다.');
        //             } else {
        //                 if (!valid4) {
        //                     helper.showToast('info', '주문채널이 \"ThinQ\"일 경우만 취소가 가능합니다.');
        //                 } else {
        //                     /*모달 창 오픈 시 뒤에 배경 화면 scroll 방지
        //                     var evt = $A.get("e.c:EX_Overflow_evt");
        //                     evt.setParam("CssClass", true);
        //                     evt.fire();
        //                     */
        //                     helper.doOpenCancelOrderModal(component);
        //                 }
        //             }
        //         }
        //     } else {
        //         helper.showToast('info', '주문상태가 \"결제요청\",\"결제완료\",\"상품준비중\",\"품절예약완료\"일 경우만 취소가 가능합니다.');
        //     }
        // } else {
        //     helper.showToast('info', '주문을 선택해 주세요.');
        // }
    },
    // fnCancel: function (component, event, helper) {
    //     component.set('v.showSpinner', true);
    //     var strCaseId = component.get('v.caseId');
    //     var remark = component.get('v.caseDescription');
    //     var NewDescription = component.get('v.NewCaseDescription');
    //     var selectedRows = component.get('v.dataForCancel');
    //     var draftValues = component.find('cancelDataTable').get('v.draftValues');
    //     var isVBANKRefund = component.get('v.isVBANKRefund'); // 가상계좌환불정보 미출력 여부
    //     var bankCode = component.get('v.bankCode'); //은행코드
    //     var bankAccountNo = component.get('v.bankAccountNo'); //계좌번호
    //     var receiverName = component.get('v.receiverName'); //예금주명
    //     var isValidBankAccount = component.get('v.isValidBankAccount'); //계좌검증 성공 여부

    //     if (!isVBANKRefund) { //가상계좌환불정보 미출력 여부
    //         component.set('v.showSpinner', false);
    //         if (!isValidBankAccount) { //계좌검증 성공 여부
    //             helper.showToast('error', '계좌검증을 먼저 진행해 주세요.');
    //             return false;
    //         }
    //     }

    //     //check validation
    //     let isValidQuantity = new Map();
    //     isValidQuantity = helper.fnChkQuantity(selectedRows, draftValues);

    //     if (!isValidQuantity.get('isValid')) {
    //         component.set('v.showSpinner', false);
    //         helper.showToast('error', isValidQuantity.get('message'));
    //         return false;
    //     } else {

    //         remark += ('\n' + NewDescription);
    //         console.log('strCaseId:' + strCaseId + ', remark:' + remark);
    //         console.log('selectedRows : ' + JSON.stringify(selectedRows));
    //         console.log('draftValues : ' + JSON.stringify(draftValues));
    //         console.log(JSON.stringify(component.find('cancelDataTable').get('v.draftValues')));

    //         var selectedMasterData = component.get('v.selectedMasterData');
    //         console.log('selectedMasterData:' + JSON.stringify(selectedMasterData));

    //         var action = component.get('c.doCancel');
    //         action.setParams({
    //             'strCaseId': strCaseId,
    //             'remark': remark,
    //             'selectedRows': selectedRows,
    //             'draftValues': draftValues,
    //             'selectedMasterData': selectedMasterData,
    //             'bankCode': bankCode,
    //             'bankAccountNo': bankAccountNo,
    //             'receiverName': receiverName
    //         })
    //         action.setCallback(this, function (response) {
    //             var state = response.getState();
    //             if (state === "SUCCESS") {
    //                 var result = response.getReturnValue();
    //                 var resultStat = result['resultStat'];
    //                 var resultMessage = result['resultMessage'];

    //                 console.log('resultStat:' + resultStat);
    //                 console.log('resultMessage:' + resultMessage);

    //                 if (resultStat == "SUCCESS") {
    //                     component.set('v.showSpinner', false);
    //                     helper.showToast("success", "주문취소 완료");

    //                     //refresh
    //                     component.set('v.isEvt', false);
    //                     helper.fnGetOrderLineItemData(component, event, helper);

    //                     helper.doCloseModal(component);

    //                     /*//카카오발신
    //                     var resendType = event.getSource().get('v.label'); //'주문 취소'
    //                     component.set('v.resendType', resendType);

    //                     //수신자 핸드폰 번호
    //                     //component.set('v.receiverNumber',selectedRows[0].CONSIGNEE_Phone);
    //                     component.set('v.receiverNumber',selectedRows[0].CustomerPhone);
    //                     component.set('v.showSpinner', true);

    //                     console.log('json : ' + JSON.stringify(selectedRows[0]));
    //                     console.log('resendType : ' + resendType);

    //                     var action2 = component.get('c.doSaveTmpExMessageObj');
    //                     action2.setParams({
    //                         'jsonString' : JSON.stringify(selectedRows[0]),
    //                         'resendType' : resendType
    //                     });

    //                     action2.setCallback(this, function(response) {
    //                         console.log('action2 response');
    //                         component.set('v.showSpinner', false);
    //                         var state = response.getState();
    //                         if (state === 'SUCCESS') {
    //                             var returnValue = response.getReturnValue();
    //                             component.set('v.exObjId', returnValue['exObjId']);
    //                             component.set('v.receiverMsg', returnValue['receiverMsg']);
    //                             console.log('exObjId:' + returnValue['exObjId']);
    //                             console.log('receiverMsg:' + returnValue['receiverMsg']);

    //                             component.set('v.kakaoModal', true);
    //                         }
    //                         else if (state === 'ERROR') {
    //                             var errors = response.getError();
    //                             if (errors[0] && errors[0].message) {
    //                                 console.log("error : " + errors[0].message);
    //                             }
    //                             component.set('v.exObjId', null);
    //                             helper.showToast('error', '알림톡 전송 오류:' + errors[0].message);
    //                         }
    //                     });
    //                     $A.enqueueAction(action2);*/
    //                     component.set('v.orderCancelBtnDisabled',true);
    //                 } else {
    //                     component.set('v.showSpinner', false);
    //                     helper.showToast("error", resultMessage);
    //                 }

    //             } else {
    //                 component.set('v.showSpinner', false);
    //                 var errors = response.getError();
    //                 if (errors) {
    //                     console.log('error : ' + errors[0].message);
    //                     console.log('errors : ' + errors);
    //                     if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
    //                 } else {
    //                     console.log("Unknown error");
    //                     helper.showToast("error", "Unknown error");
    //                 }
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }
    // },

    /**
     * @description 반품 요청 버튼 css 설정
     * @param component
     * author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnReturnRequestBtnChg : function(component) {
        var returnRequestBtn = component.find('returnRequestBtn');
        var returnRequestBtnDisabled = component.get('v.returnRequestBtnDisabled');
        if (returnRequestBtnDisabled == false) {
            returnRequestBtn.set('v.class', 'gridSlaveBtn');
        }
        else {
            returnRequestBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    consigneeNameChange : function(component) {
        var inputName = component.get('v.contactConsigneeInfo.ConsigneeName');
        if(!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |]+$/.test(inputName))){
            component.set('v.contactConsigneeInfo.ConsigneeName','');
        }
    },
    detailAddressChange : function(component) {
        var detailAddress = component.get('v.contactConsigneeInfo.ConsigneeDetailAddress');
        if(!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |0-9|\-|ㅏ-ㅣ]+$/.test(detailAddress))){
            component.set('v.contactConsigneeInfo.ConsigneeDetailAddress','');
        }
    },

    // 반품 클릭할 시 실행
    // fnOpenReturnOrderModal: function (component, event, helper) {
    //     helper.doOpenReturnOrderModal(component);
    // },
    /**
     * @description 소모품 통합주문관리 반품 모달 Close
     * @param component
     * @param event
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     */
    fnCloseReturnOrderModal: function (component, event, helper) {
        helper.doCloseReturnOrderModal(component);
    },
    // 반품 수량 수정
    fnChkReturnVal: function (component, event, helper) {

        //변경 데이터
        let draftValues = event.getParam('draftValues');
        //데이터테이블 데이터
        let productRequestLineItemsByReturnRequest = component.get("v.productRequestLineItemsByReturnRequest");

        let isValidQuantity = true;

        isValidQuantity = helper.fnChkReturnQuantity(component, productRequestLineItemsByReturnRequest, draftValues);
        console.log('isValidQuantity => ' + isValidQuantity);
        if (!isValidQuantity) {
            helper.showToast('info', '반품수량이 주문수량보다 큽니다.');
            component.find('returnDataTable').set('v.draftValues', []);
        } else {
            var isSameReturnRequestReason = component.get('v.isSameReturnRequestReason');
            console.log('isSameReturnRequestReason =>' + isSameReturnRequestReason);


            var itemTable = component.get('v.productRequestLineItemsByReturnRequest');
            itemTable.forEach((item) => {
                console.log('item.ReturnRequestReason -> ' + item.ReturnRequestReason);
                draftValues.forEach((draftItem) => {
                    console.log('draftItem.ReturnRequestReason -> ' + draftItem.ReturnRequestReason);

                    if (isSameReturnRequestReason) {
                        item.ReturnRequestReason = draftItem.ReturnRequestReason;
                    }

                    if (item.Id == draftItem.Id) {
                        if (draftItem.RequestedReturnQuantity != null) {
                            item.RequestedReturnQuantity = draftItem.RequestedReturnQuantity;
                        }
                        if (draftItem.ReturnRequestReason != null) {
                            item.ReturnRequestReason = draftItem.ReturnRequestReason;
                        }
                    }
                })
            })


            component.set('v.productRequestLineItemsByReturnRequest', itemTable);

        }
    },
    /**
     * @description 반품 요청
     * @param component, event, helper
     * author 23.02.08 / I2MAX.SEOKHOLEE
     */
    fnRequestReturnOrder: function (component, event, helper) {
        component.set('v.showSpinner', true);
        console.log('반품 요청 버튼 클릭 : ' + JSON.stringify(component.get('v.objSelected')));
        var action = component.get('c.doRequestReturnOrder');

        var returnRequestItemTable = component.get('v.productRequestLineItemsByReturnRequest');

        var isValid = true;
        var isValid2 = true;
        let totalQty;

        returnRequestItemTable.forEach((item) => {
            if ($A.util.isEmpty(item.ReturnRequestReason)) {
                isValid = false;
                return;
            }
            totalQty = parseInt(item.RequestedReturnQuantity) + parseInt(item.ExpectedReturnQuantity) + parseInt(item.ReturnQuantity);

            if (totalQty > item.SalesQuantity) {
                isValid2 = false;
                return;
            }
        });
        // if (!isValid) {
        //     helper.showToast('info', '반품 사유를 입력하여야 합니다.');
        //     component.set('v.showSpinner', false);
        //
        //     return;
        // }
        if (!isValid2) {
            helper.showToast('info', '반품수량이 주문수량을 초과 하였습니다.');
            component.set('v.showSpinner', false);

            return;
        }

        console.log(
            'channelType => ' + component.get('v.channelType')
        );

        var param = {
            'contactConsigneeInfo': component.get('v.contactConsigneeInfo'),
            'productRequestLineItemsByReturnRequest': JSON.stringify(returnRequestItemTable),
            'channelType': component.get('v.channelType'),
            'caseInfo' : component.get('v.caseInfo'),
            'appendRemarkByReturnRequest' : component.get('v.appendRemarkByReturnRequest')
        };

        console.log(param);
        action.setParams({
            'paramMap': param
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();

            if (state == "SUCCESS") {

                helper.showToast('success', '반품요청이 정상적으로 처리 되었습니다.');
                component.set('v.caseInfo', null);
                component.set('v.appendRemarkByReturnRequest', '');
                component.set('v.showReturnOrderModal', false);
                component.set('v.showSpinner', false);
                console.log(result)
                var ObjIdList = result['exObjIdList'];
                var newList = [];
                if(ObjIdList != undefined) {
                    ObjIdList.forEach((item => {
                        newList.push(item);
                    }));
                }
                if(!$A.util.isEmpty(newList)) {
                    component.set('v.isEvt', false);
                    helper.fnGetOrderLineItemData(component, event, helper);

                    component.set('v.resendType', '반품요청');
                    component.set('v.exObjIdList', newList);

                    component.set('v.receiverNumber', component.get('v.contactConsigneeInfo').ContactMobilePhone);

                    //component.set('v.kakaoModal', true);1

                    var selectedRows2 = component.get('v.data');
                    var receiverNumber = component.get('v.receiverNumber');
                    var action2 = component.get('c.doResendReturnRequest');
                    var exObjIdList = component.get('v.exObjIdList');

                    console.log('exObjIdList => ' + exObjIdList);


                    action2.setParams({
                        'exObjIdList' : exObjIdList,
                        'resendType' : '반품요청',
                        'jsonString' : JSON.stringify(selectedRows2[0]),
                        'receiverNumber' : receiverNumber
                    });
                    console.log('action2');

                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === 'SUCCESS') {
                            var result = response.getReturnValue();
                            console.log('result' + result);

                            //isSuccess, errorMsg
                            var isSuccess = result['isSuccess'];

                            console.log('isSuccess' + isSuccess);

                            if (isSuccess == 'success') {
                                helper.showToast('success', '반품요청 알림톡을 전송하였습니다.');
                                component.set('v.resendType', '');
                                component.set('v.receiverNumber', '');
                                component.set('v.receiverMsg', '');
                            }
                            else{
                                helper.showToast('error', '반품요청 알림톡 전송 실패 :: ' + result['errorMsg']);
                            }
                        }
                        else if (state === 'ERROR') {
                            var errors = response.getError();
                            console.log('errors' + errors);
                            if (errors[0] && errors[0].message) {
                                console.log("error : " + errors[0].message);
                                helper.showToast('error', resendType + ' 전송 실패 :: ' + errors[0].message);
                            }
                        }
                    });
                    $A.enqueueAction(action2);

                } else {
                    component.set('v.isEvt', false);
                    helper.fnGetOrderLineItemData(component, event, helper);
                }

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

    fnInitializeConsigneeInformation: function (component, event, helper) {
        if (component.get('v.isSameContactByReturnRequest')) {
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
     /*주소 검색 모듈 최신화*/
    fnAddressSearch : function(component, event, helper){
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
              let objData = event.getParam('objData');
              let selectedRows = objData.selectedRows;
              console.log('selectedRows :: '+ selectedRows);
              console.log(JSON.stringify(selectedRows));

              //업데이트 되는 부분 아래
              console.log('@@@ #contactConsigneddInfo :: ' + JSON.stringify(component.get('v.contactConsigneeInfo')));
            //   console.log('selectedRows.ZPRNR  : ' + selectedRows.ZPRNR);
              console.log('selectedRows.postalCode  : ' + selectedRows.postalCode);
              console.log('selectedRows.newAddr  : ' + selectedRows.newAddr);
            //   console.log(' selectedRows.NADR3S : ' + selectedRows.NADR3S);
              console.log(' selectedRows.detailNew : ' + selectedRows.detailNew);
              component.set('v.newAddress', selectedRows.newAddr);
              component.set('v.contactConsigneeInfo.ConsigneeAddress', selectedRows.newAddr);
            //   component.set('v.contactConsigneeInfo.ConsigneeDetailAddress', selectedRows.NADR3S);
            //   component.set('v.contactConsigneeInfo.CONSIGNEE_PostalCode', selectedRows.ZPRNR);
              component.set('v.contactConsigneeInfo.ConsigneeDetailAddress', selectedRows.detailNew);
              component.set('v.contactConsigneeInfo.CONSIGNEE_PostalCode', selectedRows.postalCode);
              console.log('주소 검색 끝');

      },

    // 구 버전 배송지 검색
//    fnAddressSearch: function (component) {
//        var vfOrigin = "https://" + component.get("v.vfHost");
//        var vfWindow = component.find("vfFrame").getElement().contentWindow;
//        var data = {
//            target: "DAUMAPICALL"
//        };
//        vfWindow.postMessage(data, vfOrigin);
//    },

    /**
     * @description Phone Number 정제 함수
     * @param component, event, helper
     * author 23.02.15 / I2MAX.SEOKHOLEE
     */
    fnPhoneChg: function (component, event, helper) {
        var contactConsigneeInfo = component.get('v.contactConsigneeInfo');
        contactConsigneeInfo.ConsigneePhone = helper.gfnChgTelFormat(component, event, contactConsigneeInfo.ConsigneePhone);
        component.set("v.contactConsigneeInfo", contactConsigneeInfo);
    },

    fnPhoneChg2 : function(component, event, helper){
        var IbCallNo = component.get("v.receiverNumber");
        IbCallNo = helper.gfnChgTelFormat(component, event, IbCallNo);
        component.set("v.receiverNumber", IbCallNo);
    },

    /**
     * @description
     * @param component
     * @param event
     * @param helper
     */
    fnCloseDeliveryInformationModal: function (component, event, helper) {
        component.set('v.showDeliveryInformationModal', false);
    },

    // 교환 Section
    /**
     * @description 소모품 통합주문관리 교환 모달 Open
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    fnOpenExchangeModal: function (component, event, helper) {
        helper.doOpenExchangeModal(component);
    },

    /**
     * @description 소모품 통합주문관리 교환 모달 Close
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    fnCloseExchangeModal: function (component, event, helper) {
        helper.doCloseExchangeModal(component);
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
        var preTabIdx = null;

        workspaceAPI.getEnclosingTabId().then(function (response) {
            preTabIdx = response;
            const urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/n/CustomerSearch?c__strCaller=' + 'Consumable&c__ptId=' + preTabIdx,
                "target": '_self'
            });
            urlEvent.fire();
        }).catch(function (error) {
            console.log("customer search Error :" + JSON.stringify(error));
        });
    },

    /**
     * @description 소모품 택배 교환 요청 화면에서 교환부품조회를 위한 소모품 택배주문 페이지 Modal
     * @param component
     * @param event
     * @param helper
     * @author 23.02.23 / I2MAX.SEOKHOLEE
     */
    fnShowConsumableOrder  : function (component, event, helper) {
        var listMap = component.get("v.objSelected");
        var isValid = true;

        if (listMap.length > 0) {
            listMap.forEach(item => {

                if (item.ConsumablesBusinessTypeCode != '주문') {
                    isValid = false;
                    helper.showToast('info', '주문 건만 교환요청 진행 가능합니다.');
                    return;
                }
                // if (item.OrderChannel != 'LGE.COM' && item.OrderChannel != '소모품택배') {
                //     isValid = false;
                //     helper.showToast('info', 'LGE.COM 과 소모품택배 주문 건만 교환요청 가능합니다.');
                //     return;
                // }
                //
                // if(item.OrderStatus != '배송완료') {
                //     isValid = false;
                //     helper.showToast('info', '배송완료 건만 교환요청 가능 합니다.');
                //     return;
                // }

            });
            if (isValid) {
                
                helper.doShowConsumableOrder(component, event, helper);
            }
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
     * @description 교환 요청 버튼 css 설정
     * @param component
     * author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnExchangeRequestBtnChg  : function (component, event, helper) {
        var exchangeRequestBtn = component.find('exchangeRequestBtn');
        var exchangeRequestBtnDisabled = component.get('v.exchangeRequestBtnDisabled');
        if (exchangeRequestBtnDisabled == false) {
            exchangeRequestBtn.set('v.class', 'gridSlaveBtn');
        }
        else {
            exchangeRequestBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 조회 시 모든 버튼 disabled로 초기화
     * @param component, event
     * @author 23.03.11 / I2MAX.SEUNGHUNAN
     */
    fnButtonInit : function(component, event) {
        var isSearchBtnClick = event.getParam('isSearchBtnClick');
        if (isSearchBtnClick) {
            component.set('v.orderCancelBtnDisabled', true);
            component.set('v.returnRequestBtnDisabled', true);
            component.set('v.exchangeRequestBtnDisabled', true);
        }
    },

    fnCloseKakao: function (component, event, helper) {
        component.set("v.kakaoModal", false);
    },

    fnReSendKakao : function (component, event, helper) {
        var resendType = component.get('v.resendType');
        var receiverNumber = component.get('v.receiverNumber');
        var receiverMsg = component.get('v.receiverMsg');
        //var selectedRows = component.get('v.objSelected');
        var selectedRows = component.get('v.data');

        console.log('resendType:' + resendType);
        console.log('receiverNumber:' + receiverNumber);
        console.log('receiverMsg:' + receiverMsg);

        var action = component.get('c.doResendKakao');
        var exObjId = component.get('v.exObjId');
        action.setParams({
            'exObjId' : exObjId,
            'resendType' : resendType,
            'jsonString' : JSON.stringify(selectedRows[0]),
            'receiverNumber' : receiverNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result' + result);

                //isSuccess, errorMsg
                var isSuccess = result['isSuccess'];

                console.log('isSuccess' + isSuccess);

                if (isSuccess == true) {
                    helper.showToast('success', resendType + '을(를) 전송하였습니다.');
                    component.set('v.resendType', '');
                    component.set('v.receiverNumber', '');
                    component.set('v.receiverMsg', '');
                }
                else{
                    helper.showToast('error', resendType + ' 전송 실패 :: ' + result['errorMsg']);
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                console.log('errors' + errors);
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                    helper.showToast('error', resendType + ' 전송 실패 :: ' + errors[0].message);
                }
            }
            component.set('v.kakaoModal', false);
        });
        $A.enqueueAction(action);
    },

     /**
     * @description Wijmo -> SFDC Event Handler
     * @param component
     * @param event
     * @param helper
     */
      onWijmoMessage  : function(component, event, helper) {
        const payload = event.getParam('payload');
        console.log('11');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        switch (payload.type) {
            case 'rowSelection':
                let selectedRows = [];
                selectedRows.push(JSON.parse(JSON.stringify(payload.selectedRows)));
                helper.fnWijmoSelected(component, event, helper, selectedRows);
                // console.log(JSON.stringify(component.get('v.selectedRowsFromWijmo')));

                // component.set('v.selectedRowsFromWijmo', selectedRows);
                // //helper.fnSelectedFromWijmo(component, event, helper);

                // const compEvent = component.getEvent('onrowselection');
                // compEvent.setParam('detail', {selectedRows});
                // compEvent.fire();
                break;
            case 'dblclick':
                
                console.log('dblclick !!!!');
                //2023-07-13 gw.lee
                //테스트를 위한 임시방편 로직
                let selectedRow = [];
                selectedRow.push(JSON.parse(JSON.stringify(payload.item)));
                helper.fnWijmoSelected(component, event, helper, selectedRow);
                // component.set('v.selectedRowsFromWijmo', payload.item);
                // console.log(JSON.stringify(component.get('v.selectedRowsFromWijmo')));
                break;

            case 'rowAction':
                if(payload.name == 'TrackingSearchPage') {
                    var url = 'https://trace.cjlogistics.com/web/detail.jsp?slipno=' + payload.row.TrackingNumber;
                    window.open(url, '_blank');
                } else {
                    helper.handleWijmoRowAction(component, event, helper, payload.row);
                    component.set('v.componentName','wijmo_EXdeliveryInfo');
                    setTimeout(function () {
                        helper.sendMessage2(component, {type:'items', items: component.get('v.deliveryInformationData')});

                    }, 1500);
                }
                break;
        }
    },
    
    //23 07 13 hyungho.chun
    fnInitialize: function(component, event, helper) {
        helper.sendMessage(component, {type:'items', items: component.get('v.data')});

    }

});