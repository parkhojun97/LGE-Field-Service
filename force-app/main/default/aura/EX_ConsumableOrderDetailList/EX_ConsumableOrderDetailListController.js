/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    fnInit: function (component, event, helper) {

        //23 12 26 hyungho.chun 현금입금대상 프로필별 체크
        helper.checkifSVC(component, event, helper);

        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");

        component.set('v.mapSearchParam.initialSDate', today);
        component.set('v.mapSearchParam.initialEDate', today);

        component.set('v.mapSearchParam.DepositY', false);
        component.set('v.mapSearchParam.DepositN', true);
        component.set('v.mapSearchParam.DepositNone', false);

        /* 결제요청, 재전송 버튼 들 초기화 */
        component.set('v.rePaymentBtnDisabled', true);
        component.set('v.paymentURLBtnDisabled', true);
        component.set('v.virtualAcctBtnDisabled', true);
        component.set('v.SMSBtnDisabled', true);

        /* 주문 취소, 반품 요청 버튼 초기화*/
        component.set('v.orderCancelBtnDisabled', true);
        console.log('주문취소버튼비활성화1');
        component.set('v.isCancelForRepay',false);
        component.set('v.returnRequestBtnDisabled', true);

        let columns = [
            {
                label: '주문형태',
                fieldName: 'ConsumablesBusinessTypeCode',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
            },
            // {
            //     label: '주문순번',
            //     fieldName: 'OrderSEQ',
            //     type: 'number',
            //     hideDefaultActions: true,
            //     initialWidth: 75,
            //     cellAttributes: {alignment: 'center'}
            // },
            {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: 'Sub번호', fieldName: 'SubNumber', type: 'text', initialWidth: 80, hideDefaultActions: true},
            {label: '주문채널', fieldName: 'OrderChannel', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {
                label: '주문일시', fieldName: 'OrderDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true, sortable : true
            },
            {label: '주문상태', fieldName: 'OrderStatus', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {
                label: '주문상태상세',
                fieldName: 'OrderStatusDetail',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true
            },
            // {
            //     label: '송장번호',
            //     fieldName: 'TrackingNumber',
            //     type: 'url',
            //     typeAttributes: {label: {fieldName: 'TrackingNumber'}, target: '_blank'},
            //     initialWidth: 200,
            //     hideDefaultActions: true
            // },
            {
                label: '송장번호',
                fieldName: 'TrackingNumber',
                type: 'button',
                initialWidth: 150,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'All_Cell_Color'}, alignment: 'right'}
                ,
                typeAttributes: {
                    label: {fieldName: 'TrackingNumber'},
                    title: {fieldName: 'TrackingNumber'},
                    variant: 'base',
                    class: 'text-button_delivery',
                    orderNumber: {fieldName: 'OrderNumber'}
                }
            },

            {
                label: '요청 PartNo',
                fieldName: 'RequestedPartNo',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {
                label: '입고 PartNo',
                fieldName: 'ReceivedPartNo',
                type: 'text',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {label: '대치', fieldName: 'SubstituteYN', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '판매수량', fieldName: 'SalesQuantity', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '예약상태', fieldName: 'AppointmentStatus', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: '사업부', fieldName: 'DIV', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: '한글품명', fieldName: 'PartNameKOR', type: 'text', initialWidth: 250, hideDefaultActions: true},
            {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 250, hideDefaultActions: true},
            {label: '모델', fieldName: 'Model', type: 'text', initialWidth: 200, hideDefaultActions: true},

            {label: '출고부서', fieldName: 'ShippedDepartment', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: '소비자가', fieldName: 'CustomerPrice', type: 'number', initialWidth: 120, hideDefaultActions: true},


            {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '할인유형', fieldName: 'DiscountType', type: 'text', initialWidth: 120, hideDefaultActions: true},
            {label: '현금결제', fieldName: 'CashAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '카드결제', fieldName: 'CardAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '포인트결제', fieldName: 'PointAmount', type: 'number', initialWidth: 120, hideDefaultActions: true},
            // 요청 수량
            {
                label: '요청수량',
                fieldName: 'RequestedQuantity',
                type: 'number',
                initialWidth: 120,
                hideDefaultActions: true
            },
            {label: '취소수량', fieldName: 'CancelQuantity', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {label: '반품수량', fieldName: 'ReturnQuantity', type: 'number', initialWidth: 120, hideDefaultActions: true},
            {
                label: '반품예정수량',
                fieldName: 'ExpectedReturnQuantity',
                type: 'number',
                initialWidth: 120,
                hideDefaultActions: true
            },
            // ExpectedReturnQuantity
            {label: '교환수량', fieldName: 'ExchangeQuantity', type: 'number', initialWidth: 120, hideDefaultActions: true},


            // 배송 Section Start
            {
                label: '판매번호', fieldName: 'SalesNumber', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: 'CJ 주문번호', fieldName: 'CJOrderNumber', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: 'CJ 주문전송여부',
                fieldName: 'CJOrderSendYN',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: 'CJ 주문전송일시', fieldName: 'CJOrderSendDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: '배송상태', fieldName: 'DeliveryStatus', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: '출하일시', fieldName: 'ShipmentDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: '배송일시', fieldName: 'DeliveryDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: '택배사', fieldName: 'DeliveryCompany', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            {
                label: '택배비', fieldName: 'DeliveryFee', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'DeliveryColor'}}
            },
            // 배송 Section End

            // 취소 Section Start
            {
                label: '취소부서명',
                fieldName: 'CancelDepartment',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            {
                label: '취소자사번',
                fieldName: 'CancelRequesterEmployeeNumber',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            {
                label: '취소자명', fieldName: 'CancelRequester', type: 'text', initialWidth: 120, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            {
                label: '취소일시', fieldName: 'CancelRequestedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            {
                label: '취소사유',
                fieldName: 'CancelRequestReason',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            // 취소 Section End
            // 반품 Section Start
            {
                label: '반품부서명',
                fieldName: 'ReturnDepartment',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품요청자사번',
                fieldName: 'ReturnRequesterEmployeeNumber',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품요청자명',
                fieldName: 'ReturnRequester',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품요청일시', fieldName: 'ReturnRequestedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품요청사유',
                fieldName: 'ReturnRequestReason',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            // {
            //     label: '반품요청상태',
            //     fieldName: 'ReturnRequestStatus',
            //     type: 'text',
            //     initialWidth: 120,
            //     hideDefaultActions: true,
            //     cellAttributes: {class: {fieldName: 'ReturnColor'}}
            // },
            {
                label: '반품승인일시', fieldName: 'ReturnApprovedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            // 반품 Section End

            // 교환 Section Start
            {
                label: '교환요청부서',
                fieldName: 'ExchangeRequesterDepartment',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ExchangeColor'}}
            },
            {
                label: '교환요청자',
                fieldName: 'ExchangeRequester',
                type: 'text',
                initialWidth: 120,
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ExchangeColor'}}
            },
            {
                label: '교환요청일시', fieldName: 'ExchangeRequestedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }, initialWidth: 200, hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ExchangeColor'}}
            },
            // 교환 Section End
//            {
//                 label: '상담Case번호',
//                 fieldName: 'CaseURL',
//                 type: 'url',
//                 typeAttributes: {label: {fieldName: 'CaseNumber'}, target: '_blank'},
//                 initialWidth: 200,
//                 hideDefaultActions: true
//             },

        ];

        component.set("v.columns", columns);

        let closeModalColumns = [
            {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '요청 파트넘버', fieldName: 'RequestedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '소비자가', fieldName: 'CustomerPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
            //{label: '취소수량', fieldName: 'CancelQuantity', type: 'number', editable:'true', iconName: 'utility:edit', initialWidth: 100, hideDefaultActions: true, cellAttributes: {class: {fieldName: 'CancelColor'}}},
            //{label: '취소금액', fieldName: 'CancelAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {
                label: '취소사유',
                fieldName: 'CancelRequestReason',
                type: 'text',
                initialWidth: 250,
                editable: 'true',
                iconName: 'utility:edit',
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'CancelColor'}}
            },
            {
                label: '주문수량',
                fieldName: 'QuantityRequested',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '결제방식', fieldName: 'PayMethod', type: 'text', initialWidth: 150, hideDefaultActions: true}
        ];

        component.set("v.closeModalColumns", closeModalColumns);

        //은행코드
        component.set("v.bankOptions", [
            {label: '기업은행', value: '003'},
            {label: '국민은행', value: '004'},
            {label: '외한은행', value: '005'},
            {label: '수협은행', value: '007'},
            {label: '농협은행', value: '011'},
            {label: '우리은행', value: '020'},
            {label: '제일은행', value: '023'},
            {label: '씨티은행', value: '027'},
            {label: '대구은행', value: '031'},
            {label: '부산은행', value: '032'},
            {label: '광주은행', value: '034'},
            {label: '전북은행', value: '037'},
            {label: '경남은행', value: '039'},
            {label: '우체국', value: '071'},
            {label: '하나은행', value: '081'},
            {label: '신한은행', value: '088'},
            {label: 'K은행', value: '089'},
            {label: '삼성은행', value: '024'},
            {label: '카카오뱅크', value: '090'} //24 03 12 hyungho.chun 카카오뱅크만 옵션추가
        ]);

        let closeModalColumnsForCashier = [
            {
                label: '주문번호',
                fieldName: 'OrderNumber',
                type: 'text',
                sortable: true,
                initialWidth: 120,
                hideDefaultActions: true
            },
            {
                label: '주문일시',
                fieldName: 'CreatedDate',
                type: 'date',
                sortable: true,
                initialWidth: 240,
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                },
                hideDefaultActions: true
            },
            {
                label: '주문자명',
                fieldName: 'Name',
                type: 'text',
                sortable: true,
                initialWidth: 120,
                hideDefaultActions: true
            },
            {
                label: '주문자전화번호',
                fieldName: 'ConsigneePhoneNum',
                type: 'text',
                sortable: true,
                initialWidth: 120,
                hideDefaultActions: true
            },
            {
                label: '은행명',
                fieldName: 'BankName',
                type: 'text',
                editable: 'true',
                sortable: true,
                initialWidth: 100,
                hideDefaultActions: true
            },
            {
                label: '가상계좌번호',
                fieldName: 'VirtualBankNum',
                type: 'text',
                sortable: true,
                initialWidth: 130,
                hideDefaultActions: true
            },
            {
                label: '입금여부',
                fieldName: 'DepositStatus',
                type: 'text',
                sortable: true,
                initialWidth: 90,
                hideDefaultActions: true
            },
            {
                label: '입금금액',
                fieldName: 'DepositAmount',
                type: 'number',
                sortable: true,
                initialWidth: 90,
                hideDefaultActions: true
            },
            {
                label: '입금일자',
                fieldName: 'DepositDate',
                type: 'date',
                sortable: true,
                initialWidth: 240,
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                },
                hideDefaultActions: true
            },
            {
                label: '승인번호',
                fieldName: 'ApprovalNumber',
                type: 'text',
                sortable: true,
                initialWidth: 130,
                hideDefaultActions: true
            },
            {
                label: '주문접수부서',
                fieldName: 'DeptName',
                type: 'text',
                sortable: true,
                initialWidth: 150,
                hideDefaultActions: true
            },
            {
                label: '주문접수자명',
                fieldName: 'ChiefName',
                type: 'text',
                sortable: true,
                initialWidth: 120,
                hideDefaultActions: true
            },
        ]

        component.set('v.closeModalColumnsForCashier', closeModalColumnsForCashier);

        // 반품 모달 컬럼
        helper.fnSetReturnColumns(component);

        // var hostname = window.location.hostname;
        // console.log('hn : ' + hostname);
        //
        // var vfHost = hostname.split(".")[0] + "--c.sandbox.vf.force.com";
        // component.set("v.vfHost", vfHost);
        // window.addEventListener("message", function (event) {
        //     console.log('event data : ' + JSON.stringify(event.data));
        //     if (event.data.target === 'DAUMADDR') {
        //         switch (event.data.userSelectedType) {
        //             case "R":
        //                 var roadAddress = event.data.roadAddress;
        //                 roadAddress += (event.data.buildingName === "" ? "" : (" (" + event.data.buildingName + ")"));
        //                 component.set("v.newAddress", roadAddress);
        //                 break;
        //             case "J":
        //                 component.set("v.newAddress", event.data.jibunAddress);
        //                 break;
        //         }
        //     }
        // });

        // input select 값 불러오기, 팀명, 조직명 값 가져오기.
        var action = component.get('c.getInitData');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                component.set('v.mapSettingSelect', result);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        //23 09 08 hyungho.chun serviceResource 상위컴포넌트에서받음
        // helper.fngetServiceResource(component, event, helper);
        component.set('v.showSpinner', false);
    },
    getOrderLineItemData : function (component, event, helper) {
        // 이벤트 인입 여부 True
        component.set('v.isEvt', true);
        component.set('v.isRePay', false);
        // helper.fnGetOrderLineItemData(component, event, helper);
        helper.fnGetWijmoOrderLineItemData(component, event, helper);
        helper.fnGetContactInfo(component, event, helper);
    },

    fnModalOpenForRePayment: function (component, event, helper) {
        //let selectedRows = component.get("v.objSelected");
        let selectedRows = component.get("v.data");
        component.set('v.isRePay', true);
        helper.fnCheckToPayment (component, event, helper, selectedRows);
    },
    handleCompleted: function (component, event, helper) {
        const name = event.getParam('name');
        const detail = event.getParam('detail');
        var contactId = component.get('v.contactId');

        console.log(name, JSON.stringify(detail));
        $A.get('e.force:closeQuickAction').fire();
    },
    fnModalCloseForRePayment: function (component, event, helper) {

        var evt = $A.get("e.c:EX_Overflow_evt");

        evt.setParam("CssClass", false);
        evt.fire();

        component.set('v.ShowModalForRePayment', false);
    },

    fnGetRadioValue: function (component, event, helper) {
        let radioValue = event.getParam('value');
        let radioValueCheckMap = component.get('v.radioValueCheckMap');

        console.log('radioValue : ' + radioValue);

        if (radioValue == '소득공제') {
            radioValueCheckMap.incomeTax = true;
            radioValueCheckMap.expenditureEvidence = false;
            radioValueCheckMap.nothing = false;
        } else if (radioValue == '지출증빙') {
            radioValueCheckMap.incomeTax = false;
            radioValueCheckMap.expenditureEvidence = true;
            radioValueCheckMap.nothing = false;
        } else if (radioValue == '미발행') {
            radioValueCheckMap.incomeTax = false;
            radioValueCheckMap.expenditureEvidence = false;
            radioValueCheckMap.nothing = true;
        }

        component.set('v.radioValueCheckMap', radioValueCheckMap);
    },

    // fnAddressSearch: function (component) {
    //     var vfOrigin = "https://" + component.get("v.vfHost");
    //     var vfWindow = component.find("vfFrame").getElement().contentWindow;
    //     var data = {
    //         target: "DAUMAPICALL"
    //     };
    //     vfWindow.postMessage(data, vfOrigin);
    // },

    fnSearchAddr : function(component, event, helper){
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
                        component.set("v.modalContentForSearchAddress", []);
                        var body = component.get("v.modalContentForSearchAddress");
                        body.push(newComponent);
                        component.set("v.modalContentForSearchAddress", body);
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
            //zip id로 검색 해도 될듯?
            let objData = event.getParam('objData');
            let selectedRows = objData.selectedRows;
            console.log(selectedRows);
            console.log(JSON.stringify(selectedRows));


            
            // component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
            // component.set('v.detailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
            component.set('v.newAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
        	component.set('v.contactConsigneeInfo.ConsigneeAddress', selectedRows.newAddr != undefined && selectedRows.newAddr != '' ? selectedRows.newAddr : selectedRows.addrOld != undefined && selectedRows.addrOld != '' ? selectedRows.addrOld : selectedRows.addrNew);
            //2024.02.24 seung yoon heo 주소 이벤트 필드명 변경
            // component.set('v.contactConsigneeInfo.ConsigneeDetailAddress', selectedRows.NADR3S);
            component.set('v.contactConsigneeInfo.ConsigneeDetailAddress', selectedRows.detailNew != undefined && selectedRows.detailNew != '' ? selectedRows.detailNew : selectedRows.detailOld);
        
        console.log('component.get(v.newAddress)  : '+component.get('v.newAddress'));
        console.log('component.get(v.contactConsigneeInfo.ConsigneeAddress)  : '+component.get('v.contactConsigneeInfo.ConsigneeAddress'));
            //component.set('v.productRequest.CONSIGNEE_PostalCode__c', selectedRows.ZPRNR);

            console.log(' 끝2');

    },

    fnSelected: function (component, event, helper) {

        let selectedRows = event.getParam('selectedRows');



        //결제요청 상태 여부
        let isExistBeforePay = component.get('v.isExistBeforePay');
        console.log('결제요청 상태 여부 : ' + isExistBeforePay);
        if(isExistBeforePay){
            //결제요청상태면 전체선택 해줘야함
//            let allDataList = component.get('v.data');
//            let allDataIds = [];
//            allDataList.forEach((item) => {
//                allDataIds.push(item.Id);
//            });
//            component.find('orderListDt').set('v.selectedRows', allDataIds);
//            let selectedrows2 = component.find('orderListDt').get('v.selectedRows');
//
//            if (selectedRows.length == 0 || selectedRows == null || selectedRows == undefined) {
//                component.set('v.selectedRows', []);
//            }
        }

        // var afterSelectedRows = [];
        // selectedRows1.forEach((item) => {
        //     if(item.ConsumablesBusinessTypeCode == '주문') {
        //         afterSelectedRows.push(item);
        //     }
        // });
        //
        // component.set('v.selectedRows', afterSelectedRows);
        //
        // var selectedRows = component.get('v.selectedRows');
        // component.find('orderListDt').set('v.selectedRows', selectedRows);
        console.log('Start====================');
        console.log(selectedRows);
        console.log('End====================');
        // 선택 취소하거나, 선택 후 주문내역 입력할 경우 selectedRows length가 0 이 되었을 때 pass 
        if (selectedRows.length == 0 || selectedRows == null || selectedRows == undefined) {
            component.set('v.orderCancelBtnDisabled', true);
            console.log('주문취소버튼비활성화2');
            component.set('v.isCancelForRepay',true);
            component.set('v.returnRequestBtnDisabled', true);
            //component.set('v.rePaymentBtnDisabled', true);
            //component.set('v.virtualAcctBtnDisabled', true);
            //component.set('v.paymentURLBtnDisabled', true);
            //component.set('v.SMSBtnDisabled', true);
            return;
        }

        component.set("v.objSelected", selectedRows);
        component.set("v.tempObjSelected", selectedRows);
        component.set("v.userInfoObject", selectedRows);
        component.set('v.channelType', selectedRows[0].OrderChannel);

        console.log('selectedRows:' + JSON.stringify(selectedRows));

        // 반품요청 버튼 Validation
        component.set('v.returnRequestBtnDisabled', helper.fnReturnRequestBtnValid(component));

        // 주문취소 버튼 Validation
        component.set('v.orderCancelBtnDisabled', helper.fnOrderCancelBtnValid(component));

        // 23.05.05 결제요청 버튼 Validation
        //component.set('v.rePaymentBtnDisabled', helper.fnRePaymentBtnValid(component));

        //if (component.get('v.userInfoObject.OrderStatus') == '결제요청') {
            // let rePaymentBtn = component.find('rePaymentBtn');
            // rePaymentBtn.set('v.disabled', false);
            // let refundBtn = component.find('refundBtn');
            // refundBtn.set('v.disabled', true);
         //else if (component.get('v.userInfoObject.OrderStatus') == '배송중' || component.get('v.userInfoObject.OrderStatus') == '배송완료') {
            //if (component.get('v.userInfoObject.OrderChannel') == 'CIC') {
                //if (component.get('v.userInfoObject.ConsumablesBusinessTypeCode') == '주문') {
                    // let refundBtn = component.find('refundBtn');
                    // refundBtn.set('v.disabled', false);
                    // let rePaymentBtn = component.find('rePaymentBtn');
                    // rePaymentBtn.set('v.disabled', true);
                //}
            //}
        //}
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('action => ' + action);

        console.log(JSON.stringify(action));
        console.log('JSON.stringify(row)  : '+JSON.stringify(row));

        //console.log('1 : ' + JSON.stringify(row)['Id']);
        //console.log('2 : ' + JSON.stringify(row)[0]['Id']);
       //console.log('3 : ' + JSON.stringify(row).Id);
       //console.log('4 : ' + JSON.stringify(row)[0].Id);
       //console.log('5 : ' + row.id);
       console.log('6 : ' + row['Id']);
       var recordId = row['Id'];




        helper.fnSetDeliveryInformationColumns(component,recordId);
        component.set('v.showDeliveryInformationModal', true);
    },

    //계좌검증
    fnCheckBankAccount: function (component, event, helper) {
        component.set('v.isValidBankAccount', true); //24 03 18 hyungho.chun 일단 누르자마자 잠궈서 인터페이스 수신전에 수정못하게 조정

        var bankCode = component.get('v.bankCode'); //은행코드
        var bankAccountNo = component.get('v.bankAccountNo'); //계좌번호
        var receiverName = component.get('v.receiverName'); //예금주명
        var selectedMasterData = component.get('v.selectedMasterData');
        var action = component.get('c.doCheckBankAccount');

        if (bankCode == null || bankAccountNo == null || receiverName == null) {
            component.set('v.isValidBankAccount', false);
            helper.showToast('error', ' 계좌정보를 입력해 주세요.');
        } else {
            console.log('계좌검증! Start ');
            console.log(bankCode);
            console.log(bankAccountNo);
            console.log(receiverName);
            console.log(selectedMasterData);

            action.setParams({
                'bankCode': bankCode,
                'bankAccountNo': bankAccountNo,
                'receiverName': receiverName,
                'selectedMasterData': selectedMasterData
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('SUCCESS @@@ ');

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
                //임시로 계좌검증 성공
//                component.set('v.isValidBankAccount', true);
//                helper.showToast("success", "[임시]계좌검증이 완료되었습니다.");
            });
            // component.set('v.isValidBankAccount', true);
            // helper.showToast("success", "(임시)계좌검증이 완료되었습니다.");
            $A.enqueueAction(action);
        }
    },

    //Open Modal
    fnModalOpen: function (component, event, helper) {
        console.log('fnModalOpen');
        //2023-03-23 결제완료 전 주문 취소시 전체 주문단위로 취소
        let allData = component.get("v.data");
        let objSelected = component.get("v.objSelected");
        component.set("v.tempObjSelected", objSelected);
        let valid1 = true;

        //주문취소 - 결제요청 상태일경우만
        let isBeforePay = true;
        if (objSelected != undefined && objSelected.length > 0) {
            let masterData = component.get('v.data');
            masterData.forEach(function (selected) {
                if(selected.OrderStatus != "결제요청"){
                    isBeforePay = false;

                    return false;
                }
            });

            console.log('전체 길이 allData.length :: ',allData.length);
            console.log('선택 길이 objSelected.length :: ',objSelected.length);
            //23 12 18 hyungho.chun 선택한게 전체인경우엔 팝업띄울필요없음
            if(isBeforePay && (objSelected.length < allData.length) ){
                component.set("v.objSelected", allData);
                component.set("v.tempObjSelected", allData);
                helper.showToast('info', '결제완료 전 주문 취소 시 주문단위 취소만 가능합니다.');
            }
        }else {
            component.set("v.objSelected",allData);
            component.set("v.tempObjSelected",allData);
        }
        if(valid1){
            var evt = $A.get("e.c:EX_Overflow_evt");
            evt.setParam("CssClass", true);
            evt.fire();
            component.set('v.ShowModal', true);
            component.set('v.NewCaseDescription', '');
            setTimeout(function () {
                //24 01 11 hyungoh.chun 주문재조회
                helper.findProductRequestitSelf(component); 
                helper.doOpenModal(component);
            }, 2000);
        }

        // let objSelected = component.get("v.objSelected");
        // if (objSelected.length > 0) {
        //     //주문채널 : CIC택배
        //     //주문상태 : 일반주문 결제요청, 결제완료, 상품준비중, 품절주문 결제요청, 결제완료, 품절주문완료(약속상태-요청중 or 입고완료)
        //     //요청구분 : 주문, 교환주문
        //     let valid = true; //주문상태 validation
        //     let valid2 = true; //약속상태 validation
        //     let valid3 = true; //요청구분 validation
        //     let valid4 = true; //주문채널 validation
        //     let isVBANKRefund = true; //가상계좌환불정보 미출력 여부
        //
        //     objSelected.forEach(function (selected) {
        //         if (!(selected.OrderStatus == "결제요청"
        //             || selected.OrderStatus == "결제완료"
        //             || selected.OrderStatus == "상품준비중"
        //             || selected.OrderStatus == "품절예약완료")) {
        //             valid = false;
        //         }
        //         /*if (selected.OrderStatus == "품절예약완료" && (selected.AppointmentStatus != "요청중" && selected.AppointmentStatus != "입고완료")) {
        //             valid2 = false;
        //         }*/
        //         if (!(selected.ConsumablesBusinessTypeCode == "주문" || selected.ConsumablesBusinessTypeCode == "교환주문")) {
        //             valid3 = false;
        //         }
        //         if (selected.OrderChannel != "소모품택배") {
        //             valid4 = false;
        //         }
        //         if(selected.PayMethod == '현금'){
        //             isVBANKRefund = false;
        //             component.set("v.isVBANKRefund", isVBANKRefund);
        //         }
        //     });
        //     if (valid) {
        //         if (!valid2) {
        //             helper.showToast('info', '품절예약완료상태 일 경우, 약속상태가 \"요청중\",\"입고완료\"일 경우만 취소가 가능합니다.');
        //         } else {
        //             if (!valid3) {
        //                 helper.showToast('info', '요청구분이 \"주문\",\"교환주문\"일 경우만 취소가 가능합니다.');
        //             } else {
        //                 if (!valid4) {
        //                     helper.showToast('info', '주문채널이 \"CIC\"일 경우만 취소가 가능합니다.');
        //                 } else {
        //                     /*모달 창 오픈 시 뒤에 배경 화면 scroll 방지*/
        //                     var evt = $A.get("e.c:EX_Overflow_evt");
        //                     evt.setParam("CssClass", true);
        //                     evt.fire();
        //                     helper.doOpenModal(component);
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

    //Close Modal
    fnModalClose: function (component, event, helper) {

        /*
            모달 창 오픈 시 뒤에 배경 화면 scroll 방지
         */

        // 2023.11.15 seung yoon heo 주문취소사유 초기화
        var tempObjSelected = JSON.parse(JSON.stringify(component.get('v.tempObjSelected')));

        console.log('tempObjSelected' , JSON.stringify(tempObjSelected));
        tempObjSelected.forEach(item => {
            item.CancelRequestReason = '';
        });

        component.set('v.draftVal', '');
        
        component.set('v.isSameCancelRequestReason', true);


        var evt = $A.get("e.c:EX_Overflow_evt");

        evt.setParam("CssClass", false);
        evt.fire();

        helper.doCloseModal(component);
    },

    //취소 수량 수정
    fnChkVal: function (component, event, helper) {
        //변경 데이터
        let draftValues = event.getParam('draftValues');
        //데이터테이블 데이터
        let objSelected = component.get("v.objSelected");

        let isValidQuantity = new Map();

        isValidQuantity = helper.fnChkQuantity(objSelected, draftValues);

        // 취소사유 동일 체크 시 취소사유 모두 동일하게
        var isSameCancelRequestReason = component.get('v.isSameCancelRequestReason');
        console.log('isSameCancelRequestReason =>' + isSameCancelRequestReason);

        objSelected.forEach((item) => {
            draftValues.forEach((draftItem) => {
                if (isSameCancelRequestReason) {
                    item.CancelRequestReason = draftItem.CancelRequestReason;
                }
            });
        });

        if (!isValidQuantity.get('isValid')) {
            helper.showToast('error', isValidQuantity.get('message'));
        }
    },

    fnModalOpenForCashier: function (component, event, helper) {

        var evt = $A.get("e.c:EX_Overflow_evt");

        evt.setParam("CssClass", true);
        evt.fire();

        let IsCenterPartsManager = component.get('v.IsCenterPartsManager');

        console.log('IsCenterPartsManager : ' + JSON.stringify(IsCenterPartsManager, null, 2));

        if (IsCenterPartsManager == true) {
            helper.doOpenModalForCashier(component, IsCenterPartsManager);
        } else {
            helper.doOpenModalForCashier(component, IsCenterPartsManager);
        }

        // 프로필로 체크하기 (사용안함 x)
        // const username = component.get('v.CurrentUser')['Profile'].Name;
        // helper.doOpenModalForCashier(component, username);
    },

    fnModalCloseForCashier: function (component, event, helper) {

        var evt = $A.get("e.c:EX_Overflow_evt");

        evt.setParam("CssClass", false);
        evt.fire();


        helper.doCloseModalForCashier(component);
    },

    fnEnter: function (component, event, helper) {
        if (event.keyCode == 13) {
            helper.fnDoSearch(component, event, helper);

        }
    },

    fnSearch: function (component, event, helper) {
        console.log('clicked');
        helper.fnDoSearch(component, event, helper);
    },

    fnSelectedCashDeposit: function (component, event, helper) {
        let selectedRows = event.getParam('selectedRows');
        console.log('selectedRows : ' + JSON.stringify(selectedRows, null, 2));

        let selectedRow = {};

        selectedRow = selectedRows[0];

        component.set('v.selectedCashDepositColumn', selectedRow);
    },

    fnSendSms: function (component, event, helper) {
        // let selectedDepositColumns = component.get('v.selectedCashDepositColumns');
        let selectedDepositColumns = component.get('v.selectedCashDepositColumn');

        var resendType = event.getSource().get('v.label'); //'SMS 발송'

        component.set('v.resendType', resendType);

        console.log('selectedDepositColumns : ' + JSON.stringify(selectedDepositColumns, null, 2));

        helper.doSendSms(component, selectedDepositColumns);
    },

    fnTeamChange: function (component, event, helper) {
        component.set('v.showSpinnerForCashier', true);

        component.set('v.mapSearchParam.centerName', '전체');
        component.set('v.mapSearchParam.SE', '전체');

        let selectedTeam = component.get('v.mapSearchParam.teamName');
        let action = component.get('c.getCenterData');
        action.setParams({
            'selectedTeam': selectedTeam
        })
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                component.set('v.mapSettingSelect.listTeam', result.listTeam);
                component.set('v.mapSettingSelect.listCenter', result.listCenter);
                // component.set('v.mapSettingSelect.listSE',  '전체');
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
            }

            component.set('v.showSpinnerForCashier', false);
        });
        $A.enqueueAction(action);
    },

    fnCenterChange: function (component, event, helper) {
        component.set('v.showSpinnerForCashier', true);

        let selectedTeam = component.get('v.mapSearchParam.teamName');
        let selectedCenter = component.get('v.mapSearchParam.centerName')

        let action = component.get('c.getSEData');
        action.setParams({
            'selectedTeam': selectedTeam,
            'selectedCenter': selectedCenter
        })
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                // component.set('v.mapSettingSelect.listTeam', result.listTeam);
                component.set('v.mapSettingSelect.listCenter', result.listCenter);
                component.set('v.mapSettingSelect.listSE', result.listSE);
                if (result.listSE.length == 0 || result.listSE == null || result.listSE == undefined) {
                    component.set('v.mapSearchParam.SE', '전체');
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                } else {
                    helper.showToast("error", "Unknown error");
                }
            }

            component.set('v.showSpinnerForCashier', false);
        });
        $A.enqueueAction(action);
    },

    handleSort: function (component, event, helper) {
        helper.handleSort(component, event);
    },

    fnCancel: function (component, event, helper) {
        //23 09 22 주문취소하면 주문취소팝업버튼 초기화
        component.set('v.orderCancelBtnDisabled', true);
        component.set('v.orderCancelBeen', true);

        //component.set('v.isCancelTF', true);
        component.set('v.showSpinner',true);
        var strCaseId = component.get('v.caseId');
        var remark = component.get('v.caseDescription');
        var NewDescription = component.get('v.NewCaseDescription');
        var selectedRows = component.get('v.tempObjSelected');
        //var draftValues = component.find('cancelDataTable').get('v.draftValues');
        var draftValues = component.get('v.tempObjSelected');
        var isVBANKRefund = component.get('v.isVBANKRefund'); // 가상계좌환불정보 미출력 여부
        var bankCode = component.get('v.bankCode'); //은행코드
        // var bankAccountNo = component.get('v.bankAccountNo'); //계좌번호
        var bankAccountNoTemp = component.get('v.bankAccountNo'); //계좌번호
        
        var bankAccountNo = '';
        var regNum = /[0-9]/;
        for(var item in bankAccountNoTemp){
            console.log(item);
            console.log(bankAccountNoTemp[item]);
            if(regNum.test(bankAccountNoTemp[item])){
                bankAccountNo += bankAccountNoTemp[item];
            }
        }
        console.log(' 계좌번호 !! :: ',bankAccountNo);

        var receiverName = component.get('v.receiverName'); //예금주명
        var isValidBankAccount = component.get('v.isValidBankAccount'); //계좌검증 성공 여부
        var resendType = event.getSource().get('v.label'); //'주문 취소'

        component.set('v.resendType', resendType);

        if (!isVBANKRefund) { //가상계좌환불정보 미출력 여부
            if (!isValidBankAccount) { //계좌검증 성공 여부
                helper.showToast('error', '계좌검증을 먼저 실행해 주세요.');
                component.set('v.showSpinner',false);
                return false;
            }
        }

        //PHJ20231220
        var reasonNull = false;
        selectedRows.forEach(cancelItem => {
            if(cancelItem.CancelRequestReason == null || cancelItem.CancelRequestReason == undefined || cancelItem.CancelRequestReason.trim() == ''){
                reasonNull = true;    
            }
        })
        if(reasonNull == true) {
                helper.showToast('warning', '취소사유를 입력해주세요.');
                component.set('v.showSpinner',false);
                return;
        }

        //check validation
        let isValidQuantity = new Map();
        //isValidQuantity = helper.fnChkQuantity(selectedRows, draftValues);

        //2023-07-15 gw.lee
        //미사용 로직 주석 처리
        // if (!isValidQuantity.get('isValid')) {
        //     helper.showToast('error', isValidQuantity.get('message'));
        //     component.set('v.showSpinner',false);
        //     return false;
        // } else {
        // }
        remark += ('\n' + NewDescription);
        console.log('strCaseId:' + strCaseId + ', remark:' + remark);
        console.log('selectedRows : ' + JSON.stringify(selectedRows));
        console.log('draftValues : ' + JSON.stringify(draftValues));
        //console.log(JSON.stringify(component.find('cancelDataTable').get('v.draftValues')));

        var selectedMasterData = component.get('v.selectedMasterData');
        var selectedMasterDataForCustPhone = component.get('v.selectedMasterDataForCustPhone');
        console.log('selectedMasterData:' + JSON.stringify(selectedMasterData));

        var action = component.get('c.doCancel');
        action.setParams({
            'orderType': 'cancel',
            'strCaseId': strCaseId,
            'remark': remark,
            'selectedRows': selectedRows,
            'draftValues': draftValues,
            'selectedMasterData': selectedMasterData,
            'bankCode': bankCode,
            'bankAccountNo': bankAccountNo,
            'receiverName': receiverName,
            'resendType' : resendType,
            'jsonString' : JSON.stringify(selectedRows[0]),
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
                    helper.showToast("success", "주문취소 완료");
                    
                    component.set('v.showSpinner',false);
                    helper.doCloseModal(component);

                    //refresh
                    component.set('v.isEvt', false);


                    helper.fnGetWijmoOrderLineItemData(component, event, helper);

//                    helper.getOrderLineItemData(component, event, helper);




                    //수신자 핸드폰 번호
                    component.set('v.receiverNumber',selectedMasterDataForCustPhone[0].CustomerPhone);
                    //component.set('v.receiverNumber','01091236537');
                    component.set('v.exObjId', result['exObjId']);
                    component.set('v.receiverMsg', result['receiverMsg']);
                    console.log('exObjId:' + result['exObjId']);
                    console.log('receiverMsg:' + result['receiverMsg']);
                    //component.set('v.kakaoModal', true);

                    var selectedRows2 = component.get('v.data');
                    var receiverNumber = component.get('v.receiverNumber');
                    var action2 = component.get('c.doResend');
                    var exObjId = component.get('v.exObjId');
                    console.log('receiverNumber : '+ receiverNumber);

                    action2.setParams({
                        'exObjId' : exObjId,
                        'resendType' : resendType,
                        'jsonString' : JSON.stringify(selectedRows2[0]),
                        'receiverNumber' : receiverNumber
                    });
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === 'SUCCESS') {
                            var result = response.getReturnValue();
                            console.log('result' + result);

                            //isSuccess, errorMsg
                            var isSuccess = result['isSuccess'];

                            console.log('isSuccess' + isSuccess);

                            if (isSuccess == true) {
                                helper.showToast('success', '주문취소 알림톡을 전송하였습니다.');
                                component.set('v.resendType', '');
                                component.set('v.receiverNumber', '');
                                component.set('v.receiverMsg', '');
                            }
                            else{
                                helper.showToast('error', '주문취소 알림톡 전송 실패 :: ' + result['errorMsg']);
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
                    component.set('v.showSpinner',false);
                    helper.showToast("error", resultMessage);
                }
                //23 12 18 hyungho.chun 취소사유 체크박스 초기화
                component.set('v.isSameCancelRequestReason', true);
            } else {
                //23 12 18 hyungho.chun 취소사유 체크박스 초기화
                component.set('v.isSameCancelRequestReason', true);
                component.set('v.showSpinner',false);
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
        $A.enqueueAction(action);
    },

    //////////////////////// 반품 Case ////////////////////////

    /**
     * 반품 Modal Open
     * @param component
     * @param event
     * @param helper
     */
    fnOpenReturnOrderModal: function (component, event, helper) {
        //helper.doOpenReturnOrderModal(component);
        component.set('v.showSpinner', true);
        component.set('v.isValidBankAccount', false);
        
        var objSelected = component.get('v.objSelected')[0];
        var orderNumber = objSelected.OrderNumber;
        console.log('orderNumber : ' + orderNumber);

        var basisOrderNumber = objSelected.BasisOrderNumber;

        console.log('basisOrderNumber ? : ' + basisOrderNumber);

        var action = component.get('c.doGetOrderLineItemDataByReturnRequest');

        action.setParams({
            'orderNumber' : basisOrderNumber != null ? basisOrderNumber : orderNumber
        })

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                // 고객정보
                component.set('v.contactConsigneeInfo',result['contactConsigneeInfo']);
                // 상담이력 정보
                if(result['caseInfo'] != null) {
                    component.set('v.caseInfo', result['caseInfo']);
                    let caseDesc = result['caseInfo'].CaseDescription == null ? result['caseInfo'].CaseDescription : (result['caseInfo'].CaseDescription).replace('null','');
                    component.set('v.caseDescriptionByReturnRequest', caseDesc);
                    //23.11.15 PHJ
                    let prDesc = result['caseInfo'].Description == null ? result['caseInfo'].Description : (result['caseInfo'].Description).replace('null','');
                    component.set('v.appendRemarkByReturnRequest', prDesc);
                }
                var productRequestLineItemsByReturnRequest = result['productRequestLineItemsByReturnRequest'];
                var listMap = component.get("v.objSelected");
                var productRequestLineItems = [];
                listMap.forEach(item => {
                    productRequestLineItemsByReturnRequest.forEach(prli => {
                        if(item.Id == prli.Id) {
                            productRequestLineItems.push(prli);
                        }
                    });
                })

                productRequestLineItems.forEach((item) => {
                    if(component.get('v.hasPointAmount') == false && item.PointAmount != null && item.PointAmount > 0) {
                        component.set('v.hasPointAmount', true);
                    }
                    if(component.get('v.isMig') == false && item.IsMig == true){
                        component.set('v.isMig', true);
                    }
                    // if(component.get('v.hasPointAmount') || component.get('v.isMig')) {
                    //     item.RequestedReturnQuantity = item.SalesQuantity;
                    // }
                    // 2023. 10. 10 seung yoon heo isMig 해제
                    if(component.get('v.hasPointAmount')) {
                        item.RequestedReturnQuantity = item.SalesQuantity;
                    }
                })

                helper.fnSetReturnColumns(component);

                component.set('v.productRequestLineItemsByReturnRequest', productRequestLineItems);

                component.set('v.showSpinner', false);
                component.set('v.showReturnOrderModal',true);
                setTimeout(function () {
                    helper.doReturnModal(component);
                }, 2000);
            } else {
                var errors = response.getError();
                console.log('### Error: ' + errors[0].message);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * 반품 Modal Close
     * @param component
     * @param event
     * @param helper
     */
    fnCloseReturnOrderModal: function (component, event, helper) {
        helper.doCloseReturnOrderModal(component);
    },

    // 반품 수량 수정
    // fnChkReturnVal: function (component, event, helper) {
    //     //변경 데이터
    //     let draftValues = event.getParam('draftValues');
    //     //데이터테이블 데이터
    //     let productRequestLineItemsByReturnRequest = component.get("v.productRequestLineItemsByReturnRequest");

    //     let isValidQuantity = true;

    //     isValidQuantity = helper.fnChkReturnQuantity(productRequestLineItemsByReturnRequest, draftValues);

    //     console.log('isValidQuantity => ' + isValidQuantity);
    //     if (!isValidQuantity) {
    //         helper.showToast('info', '반품요청 수량을 다시 확인 해주세요.');
    //         component.find('returnDataTable').set('v.draftValues', []);
    //     } else {
    //         var isSameReturnRequestReason = component.get('v.isSameReturnRequestReason');
    //         console.log('isSameReturnRequestReason =>' + isSameReturnRequestReason);


    //         var itemTable = component.get('v.productRequestLineItemsByReturnRequest');
    //         itemTable.forEach((item) => {

    //             draftValues.forEach((draftItem) => {
    //                 if (isSameReturnRequestReason) {
    //                     item.ReturnRequestReason = draftItem.ReturnRequestReason;
    //                 }

    //                 if (item.Id == draftItem.Id) {
    //                     if (draftItem.RequestedReturnQuantity != null) {
    //                         item.RequestedReturnQuantity = draftItem.RequestedReturnQuantity;
    //                     }
    //                     if (draftItem.ReturnRequestReason != null) {
    //                         item.ReturnRequestReason = draftItem.ReturnRequestReason;
    //                     }
    //                 }
    //             })
    //         })
    //         component.set('v.productRequestLineItemsByReturnRequest', itemTable);

    //     }
    // },

    // // wijmo 반품 수량 수정
    // fnChkReturnVal: function (component, event, helper) {
    //     //변경 데이터
    //     let draftValues = event.getParam('draftValues');
    //     //데이터테이블 데이터
    //     let productRequestLineItemsByReturnRequest = component.get("v.productRequestLineItemsByReturnRequest");

    //     let isValidQuantity = true;

    //     isValidQuantity = helper.fnChkReturnQuantity(productRequestLineItemsByReturnRequest, draftValues);

    //     console.log('isValidQuantity => ' + isValidQuantity);
    //     if (!isValidQuantity) {
    //         helper.showToast('info', '반품요청 수량을 다시 확인 해주세요.');
    //         component.find('returnDataTable').set('v.draftValues', []);
    //     } else {
    //         var isSameReturnRequestReason = component.get('v.isSameReturnRequestReason');
    //         console.log('isSameReturnRequestReason =>' + isSameReturnRequestReason);


    //         var itemTable = component.get('v.productRequestLineItemsByReturnRequest');
    //         itemTable.forEach((item) => {

    //             draftValues.forEach((draftItem) => {
    //                 if (isSameReturnRequestReason) {
    //                     item.ReturnRequestReason = draftItem.ReturnRequestReason;
    //                 }

    //                 if (item.Id == draftItem.Id) {
    //                     if (draftItem.RequestedReturnQuantity != null) {
    //                         item.RequestedReturnQuantity = draftItem.RequestedReturnQuantity;
    //                     }
    //                     if (draftItem.ReturnRequestReason != null) {
    //                         item.ReturnRequestReason = draftItem.ReturnRequestReason;
    //                     }
    //                 }
    //             })
    //         })
    //         component.set('v.productRequestLineItemsByReturnRequest', itemTable);

    //     }
    // },
    
    /**
     * @description 반품 요청
     * @param component, event, helper
     * author 23.02.08 / I2MAX.SEOKHOLEE
     */
    fnRequestReturnOrder: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.doRequestReturnOrder');
        var returnRequestItemTable = component.get('v.productRequestLineItemsByReturnRequest');

        var isValid = helper.validationCheck(component, event, helper);


        var bankCode = component.get('v.bankCode'); //은행코드
        // var bankAccountNo = component.get('v.bankAccountNo'); //계좌번호
        var receiverName = component.get('v.receiverName'); //예금주명
        var isVBANKRefund = component.get('v.isVBANKRefund'); // 가상계좌환불정보 미출력 여부
        var isValidBankAccount = component.get('v.isValidBankAccount'); //계좌검증 성공 여부
        var bankAccountNoTemp = component.get('v.bankAccountNo'); //계좌번호

        var bankAccountNo = '';
        var regNum = /[0-9]/;
        for(var item in bankAccountNoTemp){
            console.log(item);
            console.log(bankAccountNoTemp[item]);
            if(regNum.test(bankAccountNoTemp[item])){
                bankAccountNo += bankAccountNoTemp[item];
            }
        }
        console.log(' 계좌번호 !! :: ',bankAccountNo);        

        //PHJ20231220
        var reasonNull = false;
        returnRequestItemTable.forEach(returnOrderItem => {
            if(returnOrderItem.ReturnRequestReason == null || returnOrderItem.ReturnRequestReason == undefined || returnOrderItem.ReturnRequestReason.trim() == ''){
                reasonNull = true;
            }
        })
        if(reasonNull == true){
            helper.showToast('warning', '반품 사유를 입력하여야 합니다.');
            component.set('v.showSpinner', false);
            return;
        }
        
        if (isValid) {
            var param = {
                'orderType': 'return',
                'contactConsigneeInfo': component.get('v.contactConsigneeInfo'),
                'productRequestLineItemsByReturnRequest': JSON.stringify(returnRequestItemTable),
                'caseInfo' : component.get('v.caseInfo'),
                'appendRemarkByReturnRequest' : component.get('v.appendRemarkByReturnRequest'),
                'bankCode' : bankCode,
                'bankAccountNo' : bankAccountNo,
                'receiverName' : receiverName
            };
    
            console.log(param);
            action.setParams({
                'paramMap': param
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
    
                if (state == "SUCCESS") {
                    
                    if (result.isPhoneVal != null || result.isPhoneVal != undefined) {
                        helper.showToast('error', result.isPhoneVal);
                        component.set('v.showSpinner', false);
                        return;
                    }
                    component.set('v.bankAccountNo', ''); //계좌번호
                    component.set('v.receiverName', ''); //예금주명
                    component.set('v.isValidBankAccount', false); //계좌검증 성공 여부
    
                    helper.showToast('success', '반품요청이 정상적으로 처리 되었습니다.');
                    component.set('v.caseInfo', null);
                    component.set('v.appendRemarkByReturnRequest', '');
                    component.set('v.showReturnOrderModal', false);
                    //24 01 17 hyunghoc.chun 반품요청성공시에도 주소 및 결제자주소체크박스 초기화
                    component.set('v.isSameReturnRequestReason', true);
                    component.set('v.isSameContactByReturnRequest', true);                      
                    component.set('v.showSpinner', false);
                    console.log(result)
                    var ObjIdList = result['exObjIdList'];
                    var newList = [];
                    if(ObjIdList != undefined) {
                        ObjIdList.forEach((item => {
                            newList.push(item);
                        }));
                    }
                    console.log('newList -> ' + newList);
                    if(!$A.util.isEmpty(newList)) {
                        component.set('v.isEvt', false);
                        // helper.fnGetOrderLineItemData(component, event, helper);
                        helper.fnGetWijmoOrderLineItemData(component, event, helper);
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
                        // helper.fnGetOrderLineItemData(component, event, helper);
                        helper.fnGetWijmoOrderLineItemData(component, event, helper);
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
        } else {
            component.set('v.showSpinner',false);
        }

    },

    fnSendKakao: function (component, event, helper) {
        var evt = $A.get("e.force:showToast");
        var returnRequestItemTable = component.get('v.productRequestLineItemsByReturnRequest');


        var action = component.get('c.doSendKakaoMessage');
        var param = {
            'contactConsigneeInfo': component.get('v.contactConsigneeInfo'),
            'productRequestLineItemsByReturnRequest': JSON.stringify(returnRequestItemTable)
        };

        action.setParams({
            'paramMap': param
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result['retCode'] == '200') {
                    evt.setParams({
                        type: 'Success',
                        message: '정상적으로 알림톡이 발송되었습니다.'
                    });
                    evt.fire();
                    component.set("v.kakaoModal", false);
                } else {
                    evt.setParams({
                        type: 'Error',
                        message: '알림톡 발송에 실패하였습니다. '
                    });
                    evt.fire();
                }

            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        evt.setParams({
                            type: 'Error',
                            message: errors[0].message
                        });
                        evt.fire();
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

        });

        $A.enqueueAction(action);
    },

    /**
     * @description 반품 요청 Modal 에서 초기화 함수
     * @param component, event, helper
     * author 23.02.08 / I2MAX.SEOKHOLEE
     */
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
    
    /**
     * @description
     * @param component
     * @param event
     * @param helper
     */
    fnCloseDeliveryInformationModal: function (component, event, helper) {
        component.set('v.showDeliveryInformationModal', false);
    },

    /**
     * @description 결제요청 버튼 css 설정
     * @param component
     * author 23.02.24 / I2MAX.SEUNGHUNAHN
     */
    fnRePaymentBtnChg : function (component, event) {
        var rePaymentBtn = component.find('rePaymentBtn');
        var rePaymentBtnDisabled = component.get('v.rePaymentBtnDisabled');

        console.log('rePaymentBtn : ' + rePaymentBtn);
        console.log('rePaymentBtn disabled : ' + rePaymentBtn.get('v.disabled'));
        console.log('rePaymentBtnDisabled : ' + rePaymentBtnDisabled);

        if (rePaymentBtnDisabled == false) {
            // console.log('a');
            // $A.util.removeClass(rePaymentBtn, 'gridSlaveBtnDisabled');
            // console.log(rePaymentBtn.get('v.class'));
            // $A.util.addClass(rePaymentBtn, 'gridSlaveBtn');
            rePaymentBtn.set('v.class', 'gridSlaveBtn');
            // console.log(rePaymentBtn.get('v.class'));

        } else {
            rePaymentBtn.set('v.class', 'gridSlaveBtnDisabled');
            // console.log('b');
            // $A.util.removeClass(rePaymentBtn, 'gridSlaveBtn');
            // console.log(rePaymentBtn.get('v.class'));
            // $A.util.addClass(rePaymentBtn, 'gridSlaveBtnDisabled');
            // console.log(rePaymentBtn.get('v.class'));
        }
    },

    /**
     * @description 결제URL재전송 버튼 css 설정
     * @param component
     * author 23.02.26 / I2MAX.SEUNGHUNAHN
     */
    fnPaymentURLBtnChg : function (component) {
        // var resendBtns = component.find('resendBtn'); // list 통합
        // for (var idx in resendBtns) {
        //     if (resendBtns[idx])
        // }
        var paymentURLBtn = component.find('paymentURLBtn');
        var paymentURLBtnDisabled = component.get('v.paymentURLBtnDisabled');
        if (paymentURLBtnDisabled == false) {
            paymentURLBtn.set('v.class', 'gridSlaveBtn');
        } else {
            paymentURLBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 가상계좌재전송 버튼 css 설정
     * @param component
     * author 23.02.26 / I2MAX.SEUNGHUNAHN
     */
    fnVirtualAcctBtnChg : function (component) {
        var virtualAcctBtn = component.find('virtualAcctBtn');
        var virtualAcctBtnDisabled = component.get('v.virtualAcctBtnDisabled');
        if (virtualAcctBtnDisabled == false) {
            virtualAcctBtn.set('v.class', 'gridSlaveBtn');
        } else {
            virtualAcctBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description SMS재전송 버튼 css 설정
     * @param component
     * author 23.02.26 / I2MAX.SEUNGHUNAHN
     */
    fnSMSBtnChg : function (component) {
        var SMSBtn = component.find('SMSBtn');
        var SMSBtnDisabled = component.get('v.SMSBtnDisabled');
        if (SMSBtnDisabled == false) {
            SMSBtn.set('v.class', 'gridSlaveBtn');
        } else {
            SMSBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    //2312 26 hyungho.chun 현금입금대상 버튼 css 설정
    fncashDepositBtnChg : function (component) {
        var cashDepositBtn = component.find('cashDepositBtn');
        var isSVC = component.get('v.isSVC');
        if (isSVC == true) {
            cashDepositBtn.set('v.class', 'gridSlaveBtn');
        } else {
            cashDepositBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 주문 취소 버튼 css 설정
     * @param component
     * author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnOrderCancelBtnChg : function (component) {
        var orderCancelBtn = component.find('orderCancelBtn');
        var orderCancelBtnDisabled = component.get('v.orderCancelBtnDisabled');
        if (orderCancelBtnDisabled == false) {
            orderCancelBtn.set('v.class', 'gridSlaveBtn');
        } else {
            orderCancelBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    /**
     * @description 반품 요청 버튼 css 설정
     * @param component
     * author 23.03.02 / I2MAX.SEUNGHUNAHN
     */
    fnReturnRequestBtnChg : function (component) {
        var returnRequestBtn = component.find('returnRequestBtn');
        var returnRequestBtnDisabled = component.get('v.returnRequestBtnDisabled');
        if (returnRequestBtnDisabled == false) {
            returnRequestBtn.set('v.class', 'gridSlaveBtn');
        } else {
            returnRequestBtn.set('v.class', 'gridSlaveBtnDisabled');
        }
    },

    // todo: 23.02.26 MultiSelect 처리
    /**
     * @description 소모품 알림(알림톡, SMS) 재전송 전에 임시 메시지 오브젝트 Insert
     * 알림톡 콜아웃과 DML간 트랜잭션 분리를 위해 User Confirm시 DML
     * @param component, event, helper
     * author 23.02.04 / I2MAX.SEUNGHUNAN
     */
    dmlBeforeResend : function (component, event, helper) {
        //var selectedRows = component.get('v.objSelected');
        var selectedRows = component.get('v.data');
        console.log(JSON.stringify(selectedRows));
        if (selectedRows.length <= 0) {
            helper.showToast('error', '선택된 주문이 없습니다.');
            return;
        }
        var resendType = event.getSource().get('v.label');
        component.set('v.resendType', resendType);

        //수신자 핸드폰 번호
        component.set('v.receiverNumber',component.get('v.rePaymentUserInfo.CustomerPhone'));
        component.set('v.showSpinner', true);

        var action = component.get('c.doSaveTmpExMessageObj');
        action.setParams({
            'jsonString' : JSON.stringify(selectedRows[0]),
            'resendType' : resendType
        });

        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.exObjId', returnValue['exObjId']);
                component.set('v.receiverMsg', returnValue['receiverMsg']);
                console.log('exObjId:' + returnValue['exObjId']);
                console.log('receiverMsg:' + returnValue['receiverMsg']);

                component.set('v.kakaoModal', true);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
                component.set('v.exObjId', null);
                helper.showToast('error', '알림톡 전송 오류:' + errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    fnReSendKakao : function (component, event, helper) {
        component.set('v.showSpinner',true); //24 01 10 hyungho.chun 스피너추가
        console.log('fnReSendKakao');
        var resendType = component.get('v.resendType');
        var receiverNumber = component.get('v.receiverNumber');
        var receiverMsg = component.get('v.receiverMsg');
        //var selectedRows = component.get('v.objSelected');
        var selectedRows = component.get('v.data');

        console.log('resendType:' + resendType);
        console.log('receiverNumber:' + receiverNumber);
        console.log('receiverMsg:' + receiverMsg);

        var action = component.get('c.doResend');
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
            component.set('v.showSpinner',false); //24 01 10 hyungho.chun 스피너추가
            component.set('v.kakaoModal', false);
        });
        $A.enqueueAction(action);
    },

    consigneeNameChange : function (component) {
        var inputName = component.get('v.contactConsigneeInfo.ConsigneeName');
        if (!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |]+$/.test(inputName))) {
            component.set('v.contactConsigneeInfo.ConsigneeName', '');
        }
    },

    fnDetailAddressChange : function (component) {
        var detailAddress = component.get('v.contactConsigneeInfo.ConsigneeDetailAddress');
        if (!(/^[ㄱ-ㅎ|가-힣|a-z|A-Z| |0-9|\-|ㅏ-ㅣ]+$/.test(detailAddress))) {
            component.set('v.contactConsigneeInfo.ConsigneeDetailAddress', '');
        }
    },

    fnCloseKakao: function (component, event, helper) {
        component.set("v.kakaoModal", false);
    },

    fnPhoneChg : function(component, event, helper){
        // var IbCallNo = component.get("v.receiverNumber");
        var IbCallNo = event.getSource().get('v.value');
        IbCallNo = helper.gfnChgTelFormat(component, event, IbCallNo);
        // component.set("v.receiverNumber", IbCallNo);
        event.getSource().set('v.value', IbCallNo);
    },
    applyPayment: function (component, event, helper) {
        // helper.showToast('success','결제가 완료되었습니다'); //24 01 02 hyungho.chun 결제팝업쪽에 포인트전액/ 현장카드 일경우에만뜨게끔 조치
        component.set('v.isEvt',false);
        console.log('eeee');
        setTimeout(function(){
            // helper.fnGetOrderLineItemData(component, event, helper);
            helper.fnGetWijmoOrderLineItemData(component, event, helper);
        }, 2000);
//        helper.fnGetPaymentAmount(component, event, helper);

    },
    /**
     * @description 조회 시 모든 버튼 disabled로 초기화
     * @param component, event
     * @author 23.03.11 / I2MAX.SEUNGHUNAN
     */
    fnButtonInit : function (component, event) {
        var isSearchBtnClick = event.getParam('isSearchBtnClick');
        if (isSearchBtnClick) {
            component.set('v.orderCancelBtnDisabled', true);
            console.log('주문취소버튼비활성화3');
            component.set('v.isCancelForRepay',true);
            component.set('v.returnRequestBtnDisabled', true);
            component.set('v.rePaymentBtnDisabled', true);
            component.set('v.virtualAcctBtnDisabled', true);
            component.set('v.paymentURLBtnDisabled', true);
            component.set('v.SMSBtnDisabled', true);
        }
        var serviceResource = event.getParam('serviceResource');
        component.set('v.serviceResource', serviceResource);

    },
    onWijmoMessage: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;
        const isChecked = payload.checked;

        switch (payload.type) {
            case 'rowSelection':
                component.set("v.selectedList", JSON.parse(JSON.stringify(payload)).selectedRows);
                component.set("v.objSelected", JSON.parse(JSON.stringify(payload)).selectedRows);
                // if (isChecked) {
                //     if(payload.selectedRows > 0){
                //         helper.fnWijmoSelected(component, event, helper , JSON.parse(JSON.stringify(payload)).selectedRows);
                //     }else{
                //         if (component.get('v.isCancelForRepay') == false) {
                //             component.set('v.orderCancelBtnDisabled', true);
                //         }
                //         console.log('주문취소버튼비활성화4');
                //         component.set('v.returnRequestBtnDisabled', true);
                //     }
                // } else {
                //     if (payload.selectedRows.length > 0) {
                //         helper.fnWijmoSelected(component, event, helper , JSON.parse(JSON.stringify(payload)).selectedRows);
                //     } else {
                //         if (component.get('v.isCancelForRepay') == false) {
                //             component.set('v.orderCancelBtnDisabled', true);
                //         }
                //         console.log('주문취소버튼비활성화4');
                //         component.set('v.returnRequestBtnDisabled', true);
                //     }
                // }
                if (payload.selectedRows.length > 0) {
                    helper.fnWijmoSelected(component, event, helper , JSON.parse(JSON.stringify(payload)).selectedRows);
                } else {
                    console.log('isCancelForRepay :: ' , isCancelForRepay);
                    if (component.get('v.isCancelForRepay') == false) {
                        component.set('v.orderCancelBtnDisabled', true);
                    }
                    console.log('주문취소버튼비활성화4');
                    component.set('v.returnRequestBtnDisabled', true);
                }
                break;
            case 'dblclick':
                let selectList = [];
                selectList.push(JSON.parse(JSON.stringify(payload)).item);
                component.set("v.selectedList", selectList);
                component.set("v.objSelected", JSON.parse(JSON.stringify(payload)).item);
                if(selectList != null){
                    helper.fnWijmoSelected(component, event, helper , selectList);
                }else{
                    console.log('isCancelForRepay :: ' , isCancelForRepay);

                    if(component.get('v.isCancelForRepay') == false){
                        component.set('v.orderCancelBtnDisabled', true);
                    }
                    console.log('주문취소버튼비활성화4');
                    component.set('v.returnRequestBtnDisabled', true);
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
                        helper.sendMessage2(component, {type:'items', items: component.get('v.deliveryInformationData')});

                    }, 1500);
                }
                break;
        }
    },
    onCashWijmoMessage: function (component, event, helper) {
        console.log('onCashWijmoMessage -----------------------------');
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;

        switch (payload.type) {
            //2023-07-12 gw.lee
            //위지모 이벤트 전달 주석 해제
            case 'rowSelection':
                // component.set('v.closeModalColumnsForCashier',payload.selectedRows);
            
                //helper.fnCashWijmoSelected(component, event, helper);
                console.log('payload.selectedRows[0] : ' + payload.selectedRows[0]);
                component.set('v.selectedCashDepositColumn', payload.selectedRows[0]);

                //23.08.31 PHJ
                if(payload.selectedRows[0].DepositStatus == '미입금'){
                    component.set('v.payedF', true);
                }
                if(payload.selectedRows[0].DepositStatus == '입금'){
                        component.set('v.payedF', false);
                }

                break;
            case 'dblclick' :
                console.log('더블클릭!')
                console.log('payload.item : ' + payload.item);
                component.set('v.selectedCashDepositColumn', payload.item);

                 //23.08.31 PHJ
                 if(payload.item.DepositStatus == '미입금'){
                    component.set('v.payedF', true);
                }
                if(payload.item.DepositStatus == '입금'){
                        component.set('v.payedF', false);
                }
                break;
            case 'downloadDone':
                component.set('v.showSpinnerForCashier', false);
        }
    },

    onOrderCancelWijmoMessage: function (component, event, helper) {
        console.log('onCashWijmoMessage -----------------------------');
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;

        switch (payload.type) {
            case 'editing':
                //변경 데이터
                //데이터테이블 데이터
                let objSelected = component.get("v.objSelected");
                let tempObjSelected = JSON.parse(JSON.stringify(component.get("v.tempObjSelected")));
                let draftValues = payload.item;

                const cancelReason = draftValues.CancelRequestReason;
                component.set('v.draftVal', cancelReason);

                //let isValidQuantity = new Map();
                //isValidQuantity = helper.fnChkQuantity(objSelected, draftValues);

                // 취소사유 동일 체크 시 취소사유 모두 동일하게
                var isSameCancelRequestReason = component.get('v.isSameCancelRequestReason');
                console.log('isSameCancelRequestReason =>' + isSameCancelRequestReason);

                if (isSameCancelRequestReason) {
                    tempObjSelected.forEach((item) => {
                        if (isSameCancelRequestReason) {
                            if (draftValues.CancelRequestReason == undefined) {
                                item.CancelRequestReason = '';
                            } else {

                                item.CancelRequestReason = draftValues.CancelRequestReason;
                            }
                        }
                    });
                    helper.sendMessage(component, {type:'items', items: tempObjSelected}, 'wijmo_EXOrderCancel');
                } else {
                    let subNumber = payload.item.SubNumber;
                    tempObjSelected.forEach((item) => {
                        if (!isSameCancelRequestReason && subNumber == item.SubNumber) {
                            if (draftValues.CancelRequestReason == undefined) {
                                item.CancelRequestReason = '';
                            } else {

                                item.CancelRequestReason = draftValues.CancelRequestReason;
                            }
                            //item.RequestedReturnQuantity = draftValues.RequestedReturnQuantity;
                        }
                    });
                }

                console.log('tempObjSelected :::: ' + tempObjSelected);
                console.log('draftValues :::: ' + draftValues);
                component.set('v.tempObjSelected', tempObjSelected);
            break;
        }
    },

    onOrderReturnWijmoMessage: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);
        const actionName = payload.name;
        const row = payload.row;

        switch (payload.type) {
            case 'editing':
                //변경 데이터
                //데이터테이블 데이터
                let productRequestLineItemsByReturnRequest = component.get("v.productRequestLineItemsByReturnRequest");
                let hasPointAmount = component.get('v.hasPointAmount');
                let draftValues = JSON.parse(JSON.stringify(payload.item));
                console.log('draftValues ::: ' + draftValues);
                console.log('draftValues ::: ' + JSON.parse(JSON.stringify(draftValues)));

                var listType = 'wijmo_EXOrderReturn';
                if (hasPointAmount) {
                    listType = 'wijmo_EXOrderDisabledReturn';
                } 

                // 취소사유 동일 체크 시 취소사유 모두 동일하게
                var isSameReturnRequestReason = component.get('v.isSameReturnRequestReason');
                
                let quantityCheck = true;

                if (isSameReturnRequestReason) {
                    productRequestLineItemsByReturnRequest.forEach((item) => {
                        if (isSameReturnRequestReason) {
                             if (draftValues.ReturnRequestReason == undefined) {
                                item.ReturnRequestReason = '';
                            } else {

                                item.ReturnRequestReason = draftValues.ReturnRequestReason;
                            }

                            if (item.Id == draftValues.Id && !hasPointAmount) {
                                item.RequestedReturnQuantity = draftValues.RequestedReturnQuantity;
                                item.RequestedReturnAmount = draftValues.RequestedReturnQuantity * item.CustomerPrice;
                            }
                        }
                    });
                    
                } else {
                    productRequestLineItemsByReturnRequest.forEach((item) => {
                        if (!isSameReturnRequestReason && item.Id == draftValues.Id) {
                            if (draftValues.ReturnRequestReason == undefined) {
                                item.ReturnRequestReason = '';
                            } else {

                                item.ReturnRequestReason = draftValues.ReturnRequestReason;
                            }
                            
                            if (!hasPointAmount) {
                                item.RequestedReturnQuantity = draftValues.RequestedReturnQuantity;
                                item.RequestedReturnAmount = draftValues.RequestedReturnQuantity * item.CustomerPrice;
                            }
                        }
                    });
                }

                component.set("v.productRequestLineItemsByReturnRequest", productRequestLineItemsByReturnRequest);
                helper.sendMessage(component, {type:'items', items: productRequestLineItemsByReturnRequest}, listType);
                // if (quantityCheck) {
                //     helper.sendMessage(component, {type:'items', items: productRequestLineItemsByReturnRequest}, listType);
                //     component.set("v.productRequestLineItemsByReturnRequest", productRequestLineItemsByReturnRequest);
                // } else {
                // }

            break;

        }
    },

    sameReasonTF : function(component, event, helper) {
        if(component.get('v.isSameCancelRequestReason') == true){
            console.log('go?', component.get('v.isSameCancelRequestReason'));
            var sameReasonRows = JSON.parse(JSON.stringify(component.get('v.tempObjSelected')));
            sameReasonRows.forEach((item) => {
                item.CancelRequestReason = component.get('v.draftVal');
            });
            helper.sendMessage(component, {type:'items', items: sameReasonRows}, 'wijmo_EXOrderCancel');
        }
    },
    
    downloadExcel : function(component, event, helper) {
        console.log('downloadExcel !');
        component.set('v.showSpinnerForCashier', true);
        helper.fnDownloadExcel(component, event, helper);
    },
    fnInitialize: function(component, event, helper) {
        let detailData = component.get('v.data');
        let masterData = component.get('v.data2');

        let parentId;
        let paymentDate;
        let status;
        //추가 수정 로직
        //2023 07 10 gw.lee
        if (detailData && masterData) {
            detailData.forEach((item) => {
                let itemData = JSON.parse(JSON.stringify(item));
    
                if (itemData.ParentId && !parentId) {
                    parentId = itemData.ParentId;
    
                    return false;
                }
            });
    
            masterData.forEach((item) => {
                let itemData = JSON.parse(JSON.stringify(item));

                if (parentId == itemData.Id) {
                    paymentDate = itemData.PaymentRequestDT;
                    status = itemData.OrderStatus;
                    return false;
                }
            });
        }

//        if (!paymentDate && parentId && status == '결제요청') {
//            helper.sendMessage(component, {type:'itemsChecked', items: component.get('v.data')});
//            //component.set("v.wijmoSelectedRows", component.get('v.data'));
//            //helper.fnWijmoSelected(component, event, helper , component.get('v.data'));
//        } else {
//            helper.sendMessage(component, {type:'items', items: component.get('v.data')});
//        }

        helper.sendMessage(component, {type:'items', items: component.get('v.data')}, 'wijmo_EXConsumableOrderDetailList');
        

        // if (productData.PAYMENT_REQUEST_DATE__c != '' && masterData.OrderStatus == '결제요청') {
        //     helper.sendMessage(component, {type:'itemsChecked', items: component.get('v.data')});
        // } else {
        //기존 로직
        //  helper.sendMessage(component, {type:'items', items: component.get('v.data')});
        // }

    },    
});