/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-11.
 */

({
    /**
     * @description 소모품 통합주문관리 반품 컬럼 초기화
     * @param component
     * @param event
     * @author 23.02.14 / I2MAX.SEOKHOLEE
     */
    // fnSetReturnColumns: function (component) {

    //     // 반품 요청을 수정 할수 있는 경우 / CIC 이고, 포인트 결제를 진행하지 않은 경우
    //     // 기존 Migration 데이터는 전량 반품만 가능
    //     var requestedReturnQuantityEditable = !component.get('v.isMig') && component.get('v.isCIC') && !component.get('v.hasPointAmount');

    //     console.log('CIC => ' + component.get('v.isCIC'));
    //     console.log('hasPointAmount => ' + component.get('v.hasPointAmount'));
    //     console.log('isMig => ' + component.get('v.isMig'));
    //     console.log('requestedReturnQuantityEditable => ' + requestedReturnQuantityEditable);
    //     let returnOrderColumns = [
    //         // {label: '번호', fieldName: 'SEQ', type: 'text', initialWidth: 10, hideDefaultActions: true, cellAttributes: {alignment: 'center'}},
    //         {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
    //         {label: '파트넘버', fieldName: 'ReceivedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
    //         {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 200, hideDefaultActions: true},
    //         {label: '소비자가', fieldName: 'CustomerPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '주문수량', fieldName: 'SalesQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},

    //         {
    //             label: '반품요청수량',
    //             fieldName: 'RequestedReturnQuantity',
    //             type: 'number',
    //             initialWidth: 100,
    //             hideDefaultActions: true,
    //             cellAttributes: {class: {fieldName: 'ReturnColor'}},
    //             editable: requestedReturnQuantityEditable,
    //         },

    //         {
    //             label: '반품사유',
    //             fieldName: 'ReturnRequestReason',
    //             type: 'text',
    //             initialWidth: 250,
    //             editable: 'true',
    //             hideDefaultActions: true,
    //             cellAttributes: {class: {fieldName: 'ReturnColor'}}
    //         },
    //         {
    //             label: '반품금액',
    //             fieldName: 'RequestedReturnAmount',
    //             type: 'number',
    //             initialWidth: 100,
    //             hideDefaultActions: true
    //         },

    //         {label: '반품수량', fieldName: 'ReturnQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {
    //             label: '반품예정수량',
    //             fieldName: 'ExpectedReturnQuantity',
    //             type: 'number',
    //             initialWidth: 100,
    //             hideDefaultActions: true
    //         },

    //         {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true}
    //         // {label: '결제방식', fieldName: 'PayMethod', type: 'text', initialWidth: 150, hideDefaultActions: true},

    //         // iconName: 'utility:edit'
    //     ];
    //     component.set('v.returnOrderColumns', returnOrderColumns);
    // },
    //취소 수량 validation
    fnChkQuantity: function (objSelected, draftValues) {
        let isValidQuantity = new Map();
        isValidQuantity.set('isValid', true);
        /*draftValues.forEach(function(draftData){
            objSelected.forEach(function(selectData){
                if(draftData.Id == selectData.Id){
                    if(draftData.CancelQuantity > selectData.QuantityRequested){
                        isValidQuantity.set('isValid',false);
                        isValidQuantity.set('message','취소수량이 주문수량보다 큽니다.');
                    }else if(selectData.PayMethod.includes('포인트') && draftData.CancelQuantity != selectData.QuantityRequested){
                        isValidQuantity.set('isValid',false);
                        isValidQuantity.set('message','포인트 결제가 있는 경우, 전량 취소만 가능합니다.');
                    }
                    // 마이그레이션 데이터는 전량 취소만 가능
                }
            });
        });*/
        return isValidQuantity;
    },
    doCloseModal: function (component) {
        component.set('v.ShowModal', false);
    },
    /**
     * @description 소모품 통합주문관리 주문취소 모달 Open
     * @param component
     * @param event
     * @author 23.02.14 / I2MAX.SANGHUNYEO
     */
    doOpenCancelOrderModal: function (component, event) {
        component.set('v.ShowModal', true);
        component.set('v.NewCaseDescription', '');
    },
    /**
     * @description 소모품 통합주문관리 반품 모달 Open
     * @param component
     * @param event
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     */
    // doOpenReturnOrderModal: function (component, event) {
    //     component.set('v.isVBANKRefund', true);

    //     component.set('v.showSpinner', true);

    //     var objSelectedList = component.get('v.objSelected');

    //     objSelectedList.forEach((item) => {
    //         console.log('item.CashAmount -> ' + item.CashAmount);
    //         if (component.get('v.isVBANKRefund') == true) {
    //             if (item.CashAmount != null && item.CashAmount > 0) {
    //                 component.set('v.isVBANKRefund', false);
    //             }
    //         }
    //     });

    //     var objSelected = component.get('v.objSelected')[0];
    //     var orderNumber = objSelected.OrderNumber;
    //     console.log('orderNumber : ' + orderNumber);

    //     var basisOrderNumber = objSelected.BasisOrderNumber;

    //     console.log('basisOrderNumber ? : ' + basisOrderNumber);

    //     var action = component.get('c.doGetOrderLineItemDataByReturnRequest');

    //     action.setParams({
    //         'orderNumber': basisOrderNumber != null ? basisOrderNumber : orderNumber
    //     })

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();

    //             // 고객정보
    //             component.set('v.contactConsigneeInfo', result['contactConsigneeInfo']);

    //             console.log(result['contactConsigneeInfo']);

    //             // 상담이력 정보
    //             if (result['caseInfo'] != null) {
    //                 component.set('v.caseInfo', result['caseInfo']);
    //                 component.set('v.caseDescriptionByReturnRequest', result['caseInfo'].CaseDescription);
    //             }

    //             var productRequestLineItemsByReturnRequest = result['productRequestLineItemsByReturnRequest'];
    //             //var listMap = component.get("v.objSelected");
    //             var productRequestLineItems = [];
    //             //listMap.forEach(item => {
    //             productRequestLineItemsByReturnRequest.forEach(prli => {
    //                 //if (item.Id == prli.Id) {
    //                 if (prli.OrderChannel == 'ThinQ') {
    //                     prli.RequestedReturnQuantity = prli.SalesQuantity;
    //                 }
    //                 productRequestLineItems.push(prli);
    //                 //}
    //             });
    //             //})

    //             productRequestLineItems.forEach((item) => {
    //                 if (component.get('v.hasPointAmount') == false && item.PointAmount != null && item.PointAmount > 0) {
    //                     component.set('v.hasPointAmount', true);
    //                 }
    //                 if (component.get('v.isMig') == false && item.IsMig == true) {
    //                     component.set('v.isMig', true);
    //                 }
    //                 if (component.get('v.hasPointAmount') || component.get('v.isMig')) {
    //                     item.RequestedReturnQuantity = item.SalesQuantity;
    //                 }

    //             })
    //             console.log(productRequestLineItems);
    //             component.set('v.productRequestLineItemsByReturnRequest', productRequestLineItems);

    //             component.set('v.showSpinner', false);
    //             this.fnSetReturnColumns(component);
    //             component.set('v.showReturnOrderModal', true);
    //         } else {
    //             var errors = response.getError();
    //             console.log('### Error: ' + errors[0].message);
    //             component.set('v.showSpinner', false);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    doCloseReturnOrderModal: function (component) {
        component.set('v.isSameReturnRequestReason', true);
        component.set('v.isSameContactByReturnRequest', true);
        component.set('v.showReturnOrderModal', false);
    },
    // 반품 수량 validation
    fnChkReturnQuantity: function (component, objSelected, draftValues) {
        let isValidQuantity = true;
        let totalQty;

        if (component.get('v.isCIC') == true) {
            draftValues.forEach(function (draftData) {
                objSelected.forEach(function (selectData) {
                    if (draftData.Id == selectData.Id) {
                        totalQty = parseInt(draftData.RequestedReturnQuantity) + parseInt(selectData.ExpectedReturnQuantity) + parseInt(selectData.ReturnQuantity);
                        console.log('totalQty -> ' + totalQty);
                        console.log('SalesQuantity -> ' + selectData.SalesQuantity);

                        if (totalQty > parseInt(selectData.SalesQuantity)) {
                            isValidQuantity = false;
                        }
                    }
                });
            });
        }
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

    /**
     * @description Phone Number 정제 함수
     * @param component, event, helper
     * author 23.02.15 / I2MAX.SEOKHOLEE
     */
    gfnChgTelFormat: function (component, event, strTel) {

        var strLen = '';
        var strSetValue = '';
        var beforeStrTel = strTel;

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

            case '11' :

                strSetValue = strTel.substr(0, 3);
                strSetValue += '-' + strTel.substr(3, 4);
                strSetValue += '-' + strTel.substr(7); //"###-####-####";
                break;
            case '12':
                strSetValue = strTel.substr(0, 3);
                strSetValue += '-' + strTel.substr(3, 4);
                strSetValue += '-' + strTel.substr(7, 4); //"###-####-####";
                break;


            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },

    /**
     *
     * @param component
     */
    fnSetDeliveryInformationColumns: function (component, recordId) {

        let deliveryInformationColumns = [
            {label: '주문채널', fieldName: 'OrderChannel', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 150, hideDefaultActions: true},
            {
                label: '주문항번',
                fieldName: 'OrderSeq',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true,
                cellAttributes: {alignment: 'right'}
            },
            {label: '택배사', fieldName: 'DeliveryCompany', type: 'text', initialWidth: 90, hideDefaultActions: true},
            {
                label: '송장번호',
                fieldName: 'TrackingNumberURL',
                type: 'url',
                typeAttributes: {label: {fieldName: 'TrackingNumber'}, target: '_blank'},
                initialWidth: 200,
                hideDefaultActions: true
            },
            {
                label: '입고 PartNo',
                fieldName: 'ReceivedPartNo',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 250, hideDefaultActions: true},
            {label: '사업부', fieldName: 'DIV', type: 'text', initialWidth: 120, hideDefaultActions: true}


            //{label: '송장번호', fieldName: 'TrackingNumber', type: 'URL', initialWidth: 130, hideDefaultActions: true}
        ];

        component.set('v.deliveryInformationOrderColumns', deliveryInformationColumns);

        console.log('helper에서 recordId : ' + recordId);
        console.log('타입은3333 ' + typeof recordId);

        var action = component.get('c.getDeliveryNumWithId');
        //var recordId = JSON.stringify(row).['Id'];
        console.log('helloo world');

        action.setParams({
            'Id': recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('action.success!!!');
            }
            console.log('action.setCallback');
            var result = response.getReturnValue();
            console.log('ressult !!!!' + result);
            //let deliveryInformation = result['dMap_list'];
            console.log('ressult !!!!22222222222' + JSON.stringify(result));
            let deliveryInformation = result;
            component.set('v.deliveryInformationData', deliveryInformation);
        });

        $A.enqueueAction(action);


//        let deliveryInformation = [
//            {
//                "OrderChannel": "CIC",
//                "OrderNumber": "O100001147",
//                "OrderSeq": "001",
//                "TrackingNumber": "569339677336",
//                "DeliveryCompany": "CJ대한통운",
//                "TrackingNumberURL": "http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=569339677336"
//            },
//            {
//                "OrderChannel": "CIC",
//                "OrderNumber": "O100001147",
//                "OrderSeq": "001",
//                "TrackingNumber": "569339677337",
//                "DeliveryCompany": "CJ대한통운",
//                "TrackingNumberURL": "http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=569339677336"
//            }
//        ];
//
//        component.set('v.deliveryInformationOrderColumns', deliveryInformationColumns);
//        component.set('v.deliveryInformationData', deliveryInformation);
    },

    // 교환 Section
    /**
     * @description 소모품 통합주문관리 교환 컬럼 초기화
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    // fnSetExchangeColumns: function (component) {
    //     let exchangeColumns = [
    //         {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
    //         {label: '파트넘버', fieldName: 'PART_NO', type: 'text', initialWidth: 100, hideDefaultActions: true},
    //         {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
    //         {label: '소비자가', fieldName: 'UnitPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '반품수량', fieldName: 'ReturnQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '반품금액', fieldName: 'ReturnAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {
    //             label: '주문수량',
    //             fieldName: 'QuantityRequested',
    //             type: 'number',
    //             initialWidth: 100,
    //             hideDefaultActions: true
    //         },
    //         {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
    //         {label: '할인유형', fieldName: 'DiscountType', type: 'text', initialWidth: 100, hideDefaultActions: true}
    //     ];

    //     component.set('v.exchangeColumns', exchangeColumns);
    // },

    /**
     * @description 소모품 통합주문관리 교환 Modal Open
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    doOpenExchangeModal: function (component, event, helper) {
        component.set('v.showExchangeModal', true);

    },

    /**
     * @description 소모품 통합주문관리 교환 Modal Close
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    doCloseExchangeModal: function (component) {
        component.set('v.showExchangeModal', false);
    },

    /**
     * @description 소모품 통합주문관리 교환 주문 Modal Close
     * @param component
     * @param event
     * @author 23.02.22 / I2MAX.SEOKHOLEE
     */
    doShowConsumableOrder: function (component) {
        component.set("v.showSpinner", true);

        let objSelected = component.get('v.objSelected');
        let hasPointAmount = false;
        console.log('objSelected -> ');
        //console.log(JSON.stringify(objSelected));

        //23 07 03 hyungho.chun 포인트외 금액 여부
        let hasETCAmount = false;

        objSelected.forEach((item) => {
            console.log('item ::',item);
            item.productReuqestLineItemId = item.Id;
            if (item.PointAmount > 0) {
                hasPointAmount = true;
                item.QuantityRequested = 0;
            }
            if (item.CardAmount > 0 || item.CashAmount>0) {
                hasETCAmount = true;
                
            }

            console.log('hasPointAmount ::',hasPointAmount);
            console.log('hasETCAmount ::',hasETCAmount);
            
        })
        var self = this;
        $A.createComponents([
                [
                    "c:SC_Supplies", {
                    'isExchangeOrder': true,
                    'isSplitViewOpened': false,
                    'exchangeReturnOrderData': objSelected,
                    'basisOrderNumber': objSelected[0].OrderNumber,
                    'hasPointAmount': hasPointAmount,
                    'hasETCAmount':hasETCAmount
                }
                ]
            ],
            function (components, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set("v.showSpinner", false);

                    component.find('overlayLib').showCustomModal({
                        header: "교환요청",
                        body: components[0],

                        cssClass: "slds-modal_large exchange_Modal",
                        showCloseButton: true,
                        closeCallback: function () {
                            component.set('v.isEvt', false);
                            component.set('v.isFromCloseCallback', true);
                            self.fnGetOrderLineItemData(component, event, helper);
                            console.log('closecalalback 끝');


                        }
                    }).then(function (overlay) {
                        console.log('popup then!!');
                        component.set("v.showSpinner", false);

                    })


                } else {
                    console.log(JSON.stringify(errorMessage));
                    component.set("v.showSpinner", false);
                }
            }
        );
    },

    /**
     * @description 기존 반품요청 버튼 활성화 Validation 로직 이식,
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     * @author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnReturnRequestBtnValid: function (component) {
        var listMap = component.get("v.objSelected");
        var isValid = false;

        if (listMap.length > 0) {
            listMap.forEach(item => {
                console.log(' item -> ' + item);
                console.log(JSON.stringify(item));
                // if(item.ConsumablesBusinessTypeCode == '주문' && item.PaymentMethodCode == 'VBANK') {
                //     component.set('v.isVBANKRefund', false);
                // }
                if (item.ConsumablesBusinessTypeCode != '주문') {
                    isValid = true;
                    console.log('isValid 0:::: ' + isValid);
                }
                if (item.OrderChannel != 'ThinQ') {
                    isValid = true;

                    console.log('isValid 1:::: ' + isValid);
                }
                if (item.OrderStatus != '배송준비중' && (item.OrderStatus != '배송중' || item.SalesNumber == null) && (item.OrderStatus != '배송완료' || item.SalesNumber == null)) {
                    isValid = true;
                    console.log('isValid 2:::: ' + isValid);
                }
                // if(item.SalesNumber == null) {
                //     isValid = true;
                // }
                console.log('fnReturnRequestBtnValid START!!>');
                console.log('item.SalesQuantity > ' + item.SalesQuantity + ', item.ReturnQuantity > ' + item.ReturnQuantity + ', item.ExpectedReturnQuantity' + item.ExpectedReturnQuantity);


                if (item.returnQuantity == null) {
                    item.returnQuantity = 0;
                }
                if (item.ExpectedReturnQuantity == null) {
                    item.ExpectedReturnQuantity = 0;
                }
                if (item.ExchangeQuantity == null) {
                    item.ExchangeQuantity = 0;
                }
                console.log('item.SalesQuantity > ' + item.SalesQuantity + ', item.ReturnQuantity > ' + item.ReturnQuantity + ', item.ExpectedReturnQuantity' + item.ExpectedReturnQuantity + 'item.ExchangeQuantity ' + item.ExchangeQuantity);

                if (!(item.SalesQuantity > (item.ReturnQuantity + item.ExpectedReturnQuantity + item.ExchangeQuantity))) {
                    isValid = true;
                    console.log('isValid 3:::: ' + isValid);
                }
            });
        } else isValid = true;

        if (!isValid) {
            isValid = this.fnBtnLineItemStatusCheck(component);
        }

        return isValid;
    },

    /**
     * @description 기존 주문취소 버튼 활성화 Validation 이식
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     * @author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnOrderCancelBtnValid: function (component) {
        let objSelected = component.get("v.objSelected");
        let resValid = false;
        console.log('lgw log :::: ', objSelected);
        if (objSelected.length > 0) {
            //주문채널 : ThinQ
            //주문상태 : 일반주문 결제요청, 결제완료, 상품준비중, 품절주문 결제요청, 결제완료, 품절주문완료(약속상태-요청중 or 입고완료)
            //요청구분 : 주문, 교환주문
            let valid = true; //주문상태 validation
            let valid2 = true; //약속상태 validation
            let valid3 = true; //요청구분 validation
            let valid4 = true; //주문채널 validation
            let isVBANKRefund = true; //가상계좌환불정보 미출력 여부

            objSelected.forEach(function (selected) {
                if (!(selected.OrderStatus == "결제요청"
                    || selected.OrderStatus == "결제완료"
                    || selected.OrderStatus == "상품준비중"
                    || selected.OrderStatus == "품절예약완료")) {
                    valid = false;
                }
                /*if (selected.OrderStatus == "품절예약완료" && (selected.AppointmentStatus != "요청중" && selected.AppointmentStatus != "입고완료")) {
                    valid2 = false;
                }*/
                if (!(selected.ConsumablesBusinessTypeCode == "주문" || selected.ConsumablesBusinessTypeCode == "교환주문")) {
                    valid3 = false;
                }
                if (selected.OrderChannel != "ThinQ") {
                    valid4 = false;
                }
                if (selected.OrderChannel == "ThinQ") {
                    //가상계좌환불정보 미출력 여부 (ThinQ 는 항상 미출력)
                    isVBANKRefund = true;
                    component.set("v.isVBANKRefund", isVBANKRefund);
                }
            });
            if (valid) {
                if (!valid2) {
                    resValid = true;
                } else {
                    if (!valid3) {
                        resValid = true;
                    } else {
                        if (!valid4) {
                            resValid = true;
                        }
                        // else {
                        //     /*모달 창 오픈 시 뒤에 배경 화면 scroll 방지*/
                        //     var evt = $A.get("e.c:EX_Overflow_evt");
                        //     evt.setParam("CssClass", true);
                        //     evt.fire();
                        //     helper.doOpenModal(component);
                        // }
                    }
                }
            } else {
                resValid = true;
            }
        } else {
            resValid = true;
        }

        return resValid;
    },

    /**
     * @description 기존 교환요청 버튼 활성화 Validation 로직 이식,
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     * @author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnExchangeRequestBtnValid_original: function (component) {
        /**
         주문 내역 선택 && 관련 주문 내역 (Multi Select)
         주문상태 == '배송완료'
         && 주문형태 == '주문'
         && (주문채널 == 'ThinQ' || 주문채널 == '소모품택배')
         **/
        let objSelected = component.get("v.objSelected");
        let resValid = false;
        if (objSelected.length > 0) {
            //주문채널 : ThinQ, 소모품택배
            //주문상태 : 배송완료
            //요청구분 : 주문
            let valid = true; //주문상태 validation
            let valid2 = true; //약속상태 validation
            let valid3 = true; //요청구분 validation
            let valid4 = true; //주문채널 validation
            let valid5 = true;
            let isVBANKRefund = true; //가상계좌환불정보 미출력 여부

            objSelected.forEach(function (selected) {

                if (!(selected.OrderStatus == "배송완료" && selected.SalesNumber != null)) {
//                if (!(selected.OrderStatus == "배송완료")) {
                    valid = false;
                }
                /*if (selected.OrderStatus == "품절예약완료" && (selected.AppointmentStatus != "요청중" && selected.AppointmentStatus != "입고완료")) {
                    valid2 = false;
                }*/
                if (!(selected.ConsumablesBusinessTypeCode == "주문")) {
                    valid3 = false;
                }
//                if (!(selected.OrderChannel == "lge.com" || selected.OrderChannel == "소모품택배")) {
//                    valid4 = false;
//                }
                if (!(selected.OrderChannel == "소모품택배" || selected.OrderChannel == "ThinQ" || selected.OrderChannel == 'LGE.COM')) {
                    valid4 = false;
                }
                if (selected.returnQuantity == null) {
                    selected.returnQuantity = 0;
                }
                if (selected.ExpectedReturnQuantity == null) {
                    selected.ExpectedReturnQuantity = 0;
                }
                if (selected.ExchangeQuantity == null) {
                    selected.ExchangeQuantity = 0;
                }
                console.log('fnExchangeRequestBtnValid > ');
                //주문수량 > (반품수량 + 반품예정수량 + 교환수량) 일때만 활성화
                if (!(selected.SalesQuantity > (selected.ReturnQuantity + selected.ReturnQuantity + selected.ExpectedReturnQuantity))) {
                    valid5 = false;
                }
            });
            if (valid) {
                if (!valid2) {
                    resValid = true;
                } else {
                    if (!valid3) {
                        resValid = true;
                    } else {
                        if (!valid4) {
                            resValid = true;
                        } else {
                            if (!valid5) {
                                resValid = true;
                            }
                        }
                    }
                }
            } else {
                resValid = true;
            }
        } else {
            resValid = true;
        }

        return resValid;
    },


    fnExchangeRequestBtnValid: function (component) {
        /**
         주문 내역 선택 && 관련 주문 내역 (Multi Select)
         주문상태 == '배송완료'
         && 주문형태 == '주문'
         && (주문채널 == 'ThinQ' || 주문채널 == '소모품택배'|| 주문채널 =='LGE.COM')
         **/
        let listMap = component.get("v.objSelected");
        let isValid = false;

        console.log('수정된 fnExchangeRequestBtnValid !!!!');
        if (listMap.length > 0) {
            listMap.forEach(item => {
                if (item.ConsumablesBusinessTypeCode != '주문') {
                    isValid = true;
                    console.log('수정된 fnExchangeRequestBtnValid (1)');
                }
                //if (!(item.OrderChannel == 'ThinQ' || item.OrderChannel == '소모품택배')) {
                    //23 10 10 hyungho.chun ThinQ도 교환요청버튼 비활성화
                // if (!(item.OrderChannel == 'ThinQ' || item.OrderChannel == '소모품택배' || item.OrderChannel == 'LGE.COM')) {
                if (!(item.OrderChannel == '소모품택배' || item.OrderChannel == 'LGE.COM')) {                        
                    isValid = true;
                    console.log('수정된 fnExchangeRequestBtnValid (2)');
                }
                if (item.OrderStatus != '배송완료') {
                    isValid = true;
                    console.log('수정된 fnExchangeRequestBtnValid (3)');
                }
                if (item.SalesNumber == undefined) {
                    isValid = true; //판매번호 있어야함
                }
                if (item.returnQuantity == null) {
                    item.returnQuantity = 0;
                }
                if (item.ExpectedReturnQuantity == null) {
                    item.ExpectedReturnQuantity = 0;
                }
                if (item.ExchangeQuantity == null) {
                    item.ExchangeQuantity = 0;
                }
                console.log('item.SalesQuantity > ' + item.SalesQuantity + ', item.ReturnQuantity > ' + item.ReturnQuantity + ', item.ExpectedReturnQuantity' + item.ExpectedReturnQuantity + 'item.ExchangeQuantity ' + item.ExchangeQuantity);

                if (!(item.SalesQuantity > (item.ReturnQuantity + item.ExpectedReturnQuantity + item.ExchangeQuantity))) {
                    isValid = true;
                    console.log('수정된 fnExchangeRequestBtnValid (4)');
                }
            });

        } else {
            isValid = true;
        }

        if (!isValid) {
            // isValid = this.fnBtnLineItemStatusCheck(component);
        }
        return isValid;
    },

    //2023-07-07 gw.lee
    //수량 반품 또는 교환 진행중인건 외 추가 Action 불가 로직 추가
    //2023-10-10 gw.lee
    //교환 진행중일 경우, 추가 교환 불가
    fnBtnLineItemStatusCheck: function (component) {
        var lineItem = component.get('v.data');
        var checkStatusList = ['교환요청'];

        var checkValid = false;

        lineItem.forEach((item) => {
            if (checkStatusList.includes(item.OrderStatusDetail)) {
                checkValid = true;

                return false;
            }
        });

        return checkValid;
    },

    fnGetOrderLineItemData: function (component, event, helper) {



        var isEvt = component.get('v.isEvt');
        console.log('isEvt => ' + isEvt);

        if(isEvt == true) {
            component.set("v.showSpinner", true);
        }

        var selectedRows = [];
        if (isEvt) {
            console.log('isEvt True 타긴할까?');
            selectedRows = event.getParam('data');
        } else {
            console.log('isEvt False 타긴할까?');
            selectedRows = component.get('v.objSelected');
        }

        component.set('v.isMig', false);
        component.set('v.hasPointAmount', false);
        component.set("v.isVBANKRefund", true);

        if (selectedRows[0].OrderChannel == '소모품택배') {
            component.set('v.isCIC', true);
        } else {
            component.set('v.isCIC', false);
        }

        var parentId = selectedRows[0].ParentId;

        // 23.01.27 테스트 용
        var orderNumber = selectedRows[0].OrderNumber;
        var orderSeq = selectedRows[0].OrderSeq;
        console.log('orderNumber : ' + orderNumber);

        var basisOrderNumber = selectedRows[0].BasisOrderNumber;
        console.log('basisOrderNumber ? : ' + basisOrderNumber);

        component.set('v.selectedMasterData', selectedRows);

        /* 주문취소, 반품요청, 교환요청 버튼 초기화 */
        component.set('v.orderCancelBtnDisabled', true);
        component.set('v.returnRequestBtnDisabled', true);
        component.set('v.exchangeRequestBtnDisabled', true);

        // 23.01.27 테스트 용
        var action = component.get('c.doGetOrderLineItemData');

        action.setParams({
            // 23.01.27 테스트 용
            'orderNumber': basisOrderNumber != null ? basisOrderNumber : orderNumber,
            'orderSeq': null
            // 'parentId' : parentId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            var cbtc = null;
            var sn = null;
            var os = null;
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var productRequestLineItems = result['productRequestLineItems'];
                console.log('productRequestLineItems ::::',productRequestLineItems);
                console.log('orderSEQ :: ' + orderSeq);
                component.set('v.data', productRequestLineItems.filter(function (pr) {
                    os = pr.OrderSeq;
                    console.log('detail os !! : ' + os);
                    return os == orderSeq;
                }));

                //23 08 29 hyungho.chun 임시
                component.set('v.data', productRequestLineItems);

                console.log(':::: Send Wijmo orderDetailList::::');
                var data = component.get('v.data');
                console.log('os data :: ' + data);
                helper.sendMessage(component, {type: 'items', items: data});


                var evt = $A.get('e.c:EX_IntegrationOrderList_evt');


                /**
                 * 4/20 기존에는 orderSeq를 Apex Controller 파라미터로 직접 줬지만
                 * filter에서 조건 추가하기로 수정했음. (판매저장건 Validation위해 모든 품목 조회를 위함)
                 * 밑에 주문 취소랑 묶어서 사용할 수 있을 것
                 */
                console.log('BEFORE Filter originRelatedOrderList', JSON.stringify(productRequestLineItems));

                var originRelatedOrderList = productRequestLineItems.filter(function (pr) {
                    cbtc = pr.ConsumablesBusinessTypeCode;
                    var oss = pr.OrderStatus;
                    sn = pr.SubNumber;
                    return ((cbtc !== '' && cbtc !== null)
                        && (cbtc === '주문' || cbtc === '교환주문')
                        && (!oss.includes('취소'))
                        && (sn.includes('-01')));

                });
                originRelatedOrderList.sort(function (a, b) {

                    return a.SubNumber < b.SubNumber ? -1 : +(a.SubNumber > b.SubNumber);
                });

                console.log('AFTER Filter originRelatedOrderList', JSON.stringify(originRelatedOrderList));

                evt.setParam('originRelatedOrderList', originRelatedOrderList);
                var filteredPrLi = productRequestLineItems.filter(function (pr) {
                    console.log('pppr : ' + JSON.stringify(pr));
                    cbtc = pr.ConsumablesBusinessTypeCode;
                    os = pr.OrderSeq;
                    return ((cbtc !== '' && cbtc !== null)
                        && (cbtc === '주문' || cbtc === '교환주문')
                        && (os == orderSeq));
                });

                filteredPrLi.sort(function (a, b) {
                    return a.SubNumber < b.SubNumber ? -1 : +(a.SubNumber > b.SubNumber);
                });
                evt.setParam('relatedOrderList', filteredPrLi);
                evt.fire();

                //component.set('v.objSelected', []);

                //주문취소 용 원 주문번호의 관련주문내역 조회
                // var action2 = component.get('c.doGetOrderLineItemData');

                // action2.setParams({
                //     'orderNumber': basisOrderNumber != null ? basisOrderNumber : orderNumber,
                //     'orderSeq': null
                // })
                // action2.setCallback(this, function (response2) {
                //     var state2 = response2.getState();
                //     if (state2 === "SUCCESS") {
                //         var result = response2.getReturnValue();
                //         var productRequestLineItems = result['productRequestLineItems'];
                //         console.log('dlist2 : ' + productRequestLineItems);
                //         console.log(JSON.stringify(productRequestLineItems));

                //         component.set('v.dataForCancel', productRequestLineItems);
                //         component.set("v.showSpinner", false);
                //     }
                // });
                // $A.enqueueAction(action2);


            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);


        //closeCallback 닫기 실행때만 버튼 Validation 실행
        //교환요청 모달 닫기시 실행
        var isFromCloseCallback = component.get('v.isFromCloseCallback');
        if (isFromCloseCallback) {
            // 주문취소 버튼 Validation
            component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component));
            // 반품요청 버튼 Validation
            component.set('v.returnRequestBtnDisabled', this.fnReturnRequestBtnValid(component));
            // 교환요청 버튼 Validation
            component.set('v.exchangeRequestBtnDisabled', this.fnExchangeRequestBtnValid(component));
        }
        component.set('v.showSpinner', false);
    },


    /**
     *
     * @param component
     * @param msg
     */
    sendMessage: function (component, msg) {
        component.find('EXIntegrationOrderDetailList').message(msg);
    },

    sendMessage2: function (component, msg) {
        component.find('wijmo_EXdeliveryInfo').message(msg);
    },

    fnWijmoSelected: function (component, event, helper, selectedRows) {
        // 선택 취소하거나, 선택 후 주문내역 입력할 경우 selectedRows length가 0 이 되었을 때 pass
        if (selectedRows.length == 0 || selectedRows == null || selectedRows == undefined) {
            component.set('v.orderCancelBtnDisabled', true);
            component.set('v.returnRequestBtnDisabled', true);
            component.set('v.exchangeRequestBtnDisabled', true);
            return;
        }

        component.set('v.objSelected', selectedRows[0]);
        component.set('v.channelType', selectedRows[0].OrderChannel);

        // 주문취소 버튼 Validation
        component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component));
        // 반품요청 버튼 Validation
        component.set('v.returnRequestBtnDisabled', this.fnReturnRequestBtnValid(component));
        // 교환요청 버튼 Validation
        component.set('v.exchangeRequestBtnDisabled', this.fnExchangeRequestBtnValid(component));
    },

    handleWijmoRowAction: function (component, event, helper, row) {
        var recordId = row['Id'];
        component.set('v.showDeliveryInformationModal', true);

        helper.fnSetDeliveryInformationColumns(component, recordId);
    },
});