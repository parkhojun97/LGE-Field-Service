/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    fnInit: function (component, event, helper) {
        //23 08 30 hyungho.chun
        var isCenterUser = helper.getUserProfile(component);

        if(isCenterUser){
            component.set('v.isCenterUser', true);
            console.log('isCenterUser setting ::');
        }

        let orderListDt = component.find('orderListDt');
        console.log('END fnInit of consumableorderList');

        //23 11 02 hyungho.chun 탭 여러개 loading.. 결함 처리
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                   
            if (tabId) {
                console.log('response.tabId ' , tabId);
                var focusedTabId = tabId;
                console.log('focusedTabId' , focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "소모품주문관리"
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

    },
    fnSearchData: function (component, event, helper) {
        helper.sendMessage(component, {type:'items', items: component.get('v.data')});
    },
    applyPayment: function (component, event, helper) {
       setTimeout(function(){
            helper.sendMessage(component, {type:'items', items: component.get('v.data')});
        }, 2000);
    },
    fnSeleceted: function (component, event, helper) {
        console.log('### row fnSeleceted ###');
        console.log(event.getParam('selectedRows'));
        console.log(JSON.stringify(event.getParam('selectedRows')));

        if (JSON.stringify(event.getParam('selectedRows')) == '[]') {
            return;
        }

        component.set('v.objSelected',event.getParam('selectedRows'));
        component.set('v.channel', event.getParam('selectedRows')[0].OrderChannel);
        component.set('v.orderNumber', event.getParam('selectedRows')[0].OrderNumber);
        component.set('v.orderStatus', event.getParam('selectedRows')[0].OrderStatus);


        ////23.04.13 contact 추가 위치 조정
        component.set('v.contactId',event.getParam('selectedRows')[0].contactId );
        var evt = $A.get("e.c:EX_ConsumableOrderList_evt");
        var caseId = event.getParam('selectedRows')[0].CaseId;
        var caseDescription = event.getParam('selectedRows')[0].CaseDescription;
        var orderNumber = event.getParam('selectedRows')[0].OrderNumber;

        console.log('orderList case Id : ' + caseId);
        console.log('caseId == null : ' + (caseId == null));
        console.log('caseId != null : ' + (caseId != null));
        console.log('selected : ' +JSON.stringify(event.getParam('selectedRows')));
        component.set('v.orderData',event.getParam('selectedRows'));
        evt.setParam("contactId", event.getParam('selectedRows')[0].contactId );
        evt.setParam("caseId", caseId);
        evt.setParam("caseDescription", caseDescription);
        evt.setParam("data", event.getParam('selectedRows'));
        evt.setParam("orderNumber", orderNumber);


        evt.fire();
    },

    downloadCSVFile: function (component, event) {
        let vData = component.get("v.data");
        if(vData.length < 1){
            var evt = $A.get("e.force:showToast");
            evt.setParams({
                key: "info_alt",
                type: 'info',
                message: '주문을 조회해 주세요.'
            });
            evt.fire();

            return;
        }

        //////////////////////////////// CSV 출력 컬럼 세팅 시작 ////////////////////////////
        // 존재하는 fieldName만 정의.
        /*let csv_columns = [
            {label: '요청구분'      , fieldName: 'Consumables_Business_Type_Code__c'    },
            {label: '주문채널'      , fieldName: 'Order_CHNL_TYPE_Code__c'              },
            {label: '주문번호'      , fieldName: 'Order_Number__c'                      },
            {label: '주문형태'      , fieldName: 'Consumables_Order_Class_Code__c'      },
            {label: '주문일시'      , fieldName: 'CreatedDate'                          },
            {label: '고객'          , fieldName: 'Order_CUST_Name__c'                   },
            {label: '고객 전화번호'  , fieldName: 'Order_CUST_Phone__c'                  },
            {label: '수취인'        , fieldName: 'CONSIGNEE_Name__c'                    },
            {label: '수취인 전화번호' , fieldName: 'CONSIGNEE_TPNO_1__c'                  },
            {label: '결제금액'       , fieldName: 'PAYMENT_Amount__c'                    },
            {label: '부서명'        , fieldName: 'ENDP_Code__c'                         },
            {label: '상담사사번'     , fieldName: 'employeeNumber'                       },
            {label: '상담사명'       , fieldName: 'createdByName'                        },
            {label: 'Sub번호'      , fieldName: 'SubNumber'                            },
            {label: '결제일시'      , fieldName: 'PaymentDate'                          },
            {label: '주문상태'      , fieldName: 'OrderStatus'                          },
            {label: '주문상태상세'   , fieldName: 'OrderStatusDetail'                    },
            {label: '약속상태'      , fieldName: 'AppointmentStatus'                    },
            {label: '판매번호'      , fieldName: 'SalesNumber'                          },
            {label: '판매일시'      , fieldName: 'SalesDate'                            },
            {label: 'CJ 주문전송여부', fieldName: 'CJOrderSendYN'                        },
            {label: '판매수량'      , fieldName: 'SalesQuantity'                        },
            {label: '취소수량'      , fieldName: 'CancelQuantity'                       },
            {label: '반품수량'      , fieldName: 'ReturnQuantity'                       },
            {label: '교환수량'      , fieldName: 'ExchangeQuantity'                     },
            {label: '주문수량'      , fieldName: 'QuantityRequested'                    },
            {label: 'CJ 주문번호'   , fieldName: 'CJOrderNumber'                        },
            {label: '출하일시'      , fieldName: 'ShipmentDate'                         },
            {label: '배송일시'      , fieldName: 'DeliveryDate'                         },
            {label: '택배사'        , fieldName: 'DeliveryCompany'                      },
            {label: '송장번호'      , fieldName: 'TrackingNumber'                       },
            {label: '특기사항'      , fieldName: 'Remarks'                              },
            {label: '사업부'        , fieldName: 'DIV'                                  },
            {label: '요청 파트넘버'  , fieldName: 'RequestedPartNo'                      },
            {label: '요청 금액'     , fieldName: 'RequestedAmount'                      },
            {label: '입고 파트넘버'  , fieldName: 'ReceivedPartNo'                       },
            {label: '품명'         , fieldName: 'PartName'                             },
            {label: '소비자가'      , fieldName: 'CustomerPrice'                        },
            {label: '판매금액'      , fieldName: 'SaleAmount'                           },
            {label: '할인금액'      , fieldName: 'DiscountAmount'                       },
            {label: '결제예정금액'   , fieldName: 'EstimatedPaymentAmount'               },
            {label: '현금결제'      , fieldName: 'CashAmount'                           },
            {label: '카드결제'      , fieldName: 'CardAmount'                           },
            {label: '포인트결제'    , fieldName: 'PointAmount'                           },
            {label: '택배비'        , fieldName: 'DeliveryFee'                          },
            {label: '요청일시'      , fieldName: 'RequestedDate'                        },
            {label: '요청자'        , fieldName: 'RequestedUser'                        }
        ];*/
        let csv_columns = [
            {label: '주문순번', fieldName: 'OrderSEQ'},
            {label: '주문채널', fieldName: 'OrderChannel'},
            {label: '주문번호', fieldName: 'OrderNumber'},
            {label: '주문일시', fieldName: 'OrderDate'},
            {label: '주문형태', fieldName: 'OrderType'},
            {label: '결제자', fieldName: 'CustomerName'},
            {label: '결제자전화번호', fieldName: 'CustomerPhone'},
            {label: '받는분', fieldName: 'CONSIGNEE_Name'},
            {label: '받는분전화번호', fieldName: 'CONSIGNEE_Phone'},
            {label: '결제방식', fieldName: 'PaymentMethod'},
            {label: '결제금액', fieldName: 'PaymentAmount'},
            {label: '결제여부', fieldName: 'PaymentYN'},
            {label: 'MCS', fieldName: 'MCS'},
            {label: '부서명', fieldName: 'ConsultantDIV'},
            {label: '상담사사번', fieldName: 'ConsultantEmployeeNumber'},
            {label: '상담사명', fieldName: 'ConsultantUser'},
            {label: '상담내용', fieldName: 'CaseDescription'},

            {label: '주문 형태', fieldName: 'ConsumablesBusinessTypeCode'},
            //{label: '주문순번', fieldName: 'OrderSEQ'},
            {label: 'Sub번호', fieldName: 'SubNumber'},
            //{label: '주문채널', fieldName: 'OrderChannel'},
            //{label: '주문일시', fieldName: 'OrderDate'},
            //{label: '주문번호', fieldName: 'OrderNumber'},
            {label: '주문상태', fieldName: 'OrderStatus'},
            {label: '주문상태상세', fieldName: 'OrderStatusDetail'},
            {label: '송장번호', fieldName: 'TrackingNumber'},
            {label: '요청 PartNo', fieldName: 'RequestedPartNo'},
            {label: '입고 PartNo', fieldName: 'ReceivedPartNo'},
            {label: '대치', fieldName: 'SubstituteYN'},
            {label: '부분입고', fieldName: 'PartiallyReceived'},
            {label: '약속상태', fieldName: 'AppointmentStatus'},
            {label: '사업부', fieldName: 'DIV'},
            {label: '한글품명', fieldName: 'PartNameKOR'},
            {label: '품명', fieldName: 'PartName'},
            {label: '모델', fieldName: 'Model'},
            {label: '출고부서', fieldName: 'ShippedDepartment'},
            {label: '소비자가', fieldName: 'CustomerPrice'},
            {label: '판매수량', fieldName: 'SalesQuantity'},
            {label: '판매금액', fieldName: 'SaleAmount'},
            //{label: '결제금액', fieldName: 'PaymentAmount'},
            {label: '할인금액', fieldName: 'DiscountAmount'},
            {label: '할인유형', fieldName: 'DiscountType'},
            {label: '현금결제', fieldName: 'CashAmount'},
            {label: '카드결제', fieldName: 'CardAmount'},
            {label: '포인트결제', fieldName: 'PointAmount'},
            {label: '취소수량', fieldName: 'CancelQuantity'},
            {label: '반품수량', fieldName: 'ReturnQuantity'},
            {label: '교환수량', fieldName: 'ExchangeQuantity'},
            {label: '판매번호', fieldName: 'SalesNumber'},
            {label: 'CJ 주문번호', fieldName: 'CJOrderNumber'},
            {label: 'CJ 주문전송여부', fieldName: 'CJOrderSendYN'},
            {label: 'CJ 주문전송일시', fieldName: 'CJOrderSendDate'},
            {label: '배송상태', fieldName: 'DeliveryStatus'},
            {label: '출하일시', fieldName: 'ShipmentDate'},
            {label: '배송일시', fieldName: 'DeliveryDate'},
            {label: '택배사', fieldName: 'DeliveryCompany'},
            {label: '택배비', fieldName: 'DeliveryFee'},
            {label: '취소부서명', fieldName: 'CancelDepartment'},
            {label: '취소자사번', fieldName: 'CancelRequesterEmployeeNumber'},
            {label: '취소자명', fieldName: 'CancelRequester'},
            {label: '취소일시', fieldName: 'CancelRequestedDate'},
            {label: '취소사유', fieldName: 'CancelRequestReason'},
            {label: '반품부서명', fieldName: 'ReturnDepartment'},
            {label: '반품요청자사번', fieldName: 'ReturnRequesterEmployeeNumber'},
            {label: '반품요청자명', fieldName: 'ReturnRequester'},
            {label: '반품요청일시', fieldName: 'ReturnRequestedDate'},
            {label: '반품요청사유', fieldName: 'ReturnRequestReason'},
            {label: '반품승인일시', fieldName: 'ReturnApprovedDate'},
            {label: '반품승인자', fieldName: 'ReturnApprover'},
            {label: '반품승인사유', fieldName: 'ReturnApprovedReason'},
            {label: '부품상태', fieldName: 'PartStatus'},
            {label: '교환정보', fieldName: 'ExchangeInformation'},
            {label: '교환대상', fieldName: 'ExchangeTarget'},
            {label: '교환요청부서', fieldName: 'ExchangeRequesterDepartment'},
            {label: '교환요청자', fieldName: 'ExchangeRequester'},
            {label: '교환요청일시', fieldName: 'ExchangeRequestedDate'},
            {label: '상담Case번호', fieldName: 'CaseNumber'},
            {label: '적치장소', fieldName: 'Location'}
        ];

        //console.log('csv_columns : ' + csv_columns);
        //////////////////////////////// CSV 출력 컬럼 세팅 끝 ///////////////////////////////

        //////////////////////////////// CSV 출력 데이터 세팅 시작 /////////////////////////////
        let recordId = '';
        let isFirst = true;
        vData.forEach(function (data){
            if(isFirst){
                recordId += '\'' +data.Id+ '\'';
                isFirst = false;
            }else{
                recordId += ',\'' +data.Id+ '\'';
            }
        });

        var action = component.get('c.doGetOrderLineItemData');
        action.setParams({
            'recordId': recordId,
            'isDownload': true
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var productRequestLineItems = result['productRequestLineItems'];
                //CSV데이터 생성을 위해 주문데이터와 상세주문 데이터 결합 ( productRequestLineItems.ParentId == productRequest.Id)
                productRequestLineItems.forEach( function (item){
                    vData.forEach(function (data){
                        if(item.ParentId == data.Id){
                            /*item.Consumables_Business_Type_Code__c = data.Consumables_Business_Type_Code__c; //요청구분'
                            item.Order_CHNL_TYPE_Code__c = data.Order_CHNL_TYPE_Code__c; //주문채널'
                            item.Order_Number__c = data.Order_Number__c; //주문번호'
                            item.Consumables_Order_Class_Code__c = data.Consumables_Order_Class_Code__c; //주문형태'
                            item.CreatedDate = data.CreatedDate; //주문일시'
                            item.Order_CUST_Name__c = data.Order_CUST_Name__c; //고객'
                            item.Order_CUST_Phone__c = data.Order_CUST_Phone__c; //고객 전화번호'
                            item.CONSIGNEE_Name__c = data.CONSIGNEE_Name__c; //수취인'
                            item.CONSIGNEE_TPNO_1__c = data.CONSIGNEE_TPNO_1__c; //수취인 전화번호'
                            item.PAYMENT_Amount__c = data.PAYMENT_Amount__c; //결제금액'
                            item.ENDP_Code__c = data.ENDP_Code__c; //부서명'
                            item.employeeNumber = data.employeeNumber; //상담사사번'
                            item.createdByName = data.createdByName; //상담사명'*/

                            item.OrderSEQ = data.OrderSEQ; //주문순번
                            item.OrderChannel = data.OrderChannel; //주문채널
                            item.OrderNumber = data.OrderNumber; // 주문번호
                            item.OrderDate = data.OrderDate; //주문일시
                            item.OrderType = data.OrderType; //주문형태
                            item.CustomerName = data.CustomerName; //결제자
                            item.CustomerPhone = data.CustomerPhone; //결제자전화번호
                            item.CONSIGNEE_Name = data.CONSIGNEE_Name; //받는분
                            item.CONSIGNEE_Phone = data.CONSIGNEE_Phone; //받는분전화번호
                            item.PaymentMethod = data.PaymentMethod; //결제방식
                            item.PaymentAmount = data.PaymentAmount; //결제금액
                            item.PaymentYN = data.PaymentYN; //결제여부
                            item.MCS = data.MCS; //MCS
                            item.ConsultantDIV = data.ConsultantDIV; //부서명
                            item.ConsultantEmployeeNumber = data.ConsultantEmployeeNumber; //상담사사번
                            item.ConsultantUser = data.ConsultantUser; //상담사명
                            item.CaseDescription = data.CaseDescription; //상담내용
                        }
                    });
                });

                //////////////////////////////// CSV 다운로드 공통모듈 호출 시작 ////////////////////////
                var evt = $A.get("e.c:EX_DownloadCSV_evt");
                //evt.setParam("data", component.get("v.data"));
                evt.setParam("data", productRequestLineItems);
                evt.setParam("columns", csv_columns);
                evt.setParam("title", "ConsumableOrderList");
                evt.fire();
                //////////////////////////////// CSV 다운로드 공통모듈 호출 끝 //////////////////////////


            } else {
                var errors = response.getError();
                if (errors) {
                    console.log('error : ' + errors[0].message);
                    console.log('errors : ' + errors);
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    console.log("Unknown error");
                    this.showToast("error", "Unknown error");
                }
            }
            //component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
        //////////////////////////////// CSV 출력 데이터 세팅 끝 //////////////////////////////


    },
    fnShowPdf: function (component, event, helper) {
         var selectedRow = component.get('v.objSelected');
        console.log('selectedRow111 : '+selectedRow);
        console.log('selectedRow222 : '+JSON.stringify(selectedRow));
        
          var orderType = selectedRow[0].OrderType;
         if(selectedRow == '' || selectedRow == null){
            return helper.showToast('error','주문을 선택해주세요');
         }
            component.set('v.showSpinner', true);
        console.log('fnShow PDF ! ');
        console.log( 'order'+selectedRow[0].contactName);
        console.log('OrderNumber  : ' + selectedRow[0].OrderNumber);
        console.log('OrderStatus  : ' + selectedRow[0].OrderStatus);
        console.log('PaymentAmount  : ' + selectedRow[0].PaymentAmount);

        //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)  
        var isSpecificationValid = component.get('v.isSpecificationValid');

        console.log('isSpecificationValid@@@@ : '+isSpecificationValid);

            $A.createComponent(
           "c:EX_SuppliesQuoteList",
           {
               "orderNumber" : selectedRow[0].OrderNumber,
               "latePayment" : false,
               "IsPrint" : true,
               "isManagement" : true,
               "RCVRName" : selectedRow[0].contactName,
               "RCVREmail" : selectedRow[0].contactEmail,
               "contactId" : selectedRow[0].contactId,
               "parentId" : selectedRow[0].Id,
               "orderStatus" : selectedRow[0].OrderStatus,
               "discountType" : selectedRow[0].discountType,
            //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)
               "isSpecificationValid" : isSpecificationValid,

               "soldOutConsumableOrderId" : selectedRow[0].Id,
               "stdConsumableOrderId" : selectedRow[0].Id,
               "listSelectRows" : null,


           },
           function (cmp, status, errorMessage) {
               if (status === "SUCCESS") {
                   component.set("v.modalContent", cmp);

               } else if (status === "INCOMPLETE") {
                   console.log('No response from server or client is offline.');
               } else if (status === "ERROR") {
                   console.log('Error :' + errorMessage);
               }
           });
       component.set('v.showSpinner', false);

        console.log('----------end');
    },

    /**
     * @description 소모품 알림(알림톡, SMS) 재전송 전에 임시 메시지 오브젝트 Insert
     * 알림톡 콜아웃과 DML간 트랜잭션 분리를 위해 User Confirm시 DML
     * @param component, event, helper
     * author 23.02.04 / I2MAX.SEUNGHUNAN
     */
    dmlBeforeResend : function(component, event, helper) {
        // todo : Multi ProductRequestLine Case
        var selectedRows = component.get('v.objSelected');
        if (selectedRows.length <= 0) {
            helper.showToast('error', '선택된 주문이 없습니다.');
            return;
        }
        var resendType = event.getSource().get('v.label');
        var dialog = component.find('dialog');
        var param = {
            message : ''
        };
        switch(resendType) {
            case '결제URL재전송':
                param.message = '결제URL 알림톡을 전송하시겠니까?';
                break;
            case '가상계좌재전송':
                param.message = '가상계좌 알림톡을 전송하시겠니까?';
                break;
            case 'SMS재전송':
                param.message = '가상계좌 SMS를 전송하시겠니까?';
                break;
        }
        helper.saveTmpMessageObj(component, selectedRows, resendType);

        dialog.confirm(param, function(response) {
            if (response == null || response == undefined) {
                helper.showToast('error', '사용자 응답 오류');
                return;
            }
            if (response.result != null) {
                var exObjId = component.get('v.exObjId');
                if (exObjId == null || exObjId == undefined) {
                    helper.showToast('error', '알림톡 전송 오류');
                    return;
                }
                if (response.result) {
                    helper.resend(component, resendType);
                    // response.resendType | '결제URL재전송', '가상계좌재전송', 'SMS재전송'
                }
                else {
                    helper.showToast('error', '알림톡 전송 취소');
                }
            }
        }, resendType);
    },

    // 23.09.07 PHJ 위즈모 전환
    // updateColumnSorting: function (cmp, event, helper) {
    //     var fieldName = event.getParam('fieldName');
    //     var sortDirection = event.getParam('sortDirection');
    //     cmp.set("v.sortedBy", fieldName);
    //     cmp.set("v.sortedDirection", sortDirection);
    //     helper.sortData(cmp, fieldName, sortDirection);
    // },

    /**
     * @description 주문내역 리스트가 더 조회가 가능하다면 조회하도록 바닥페이지에 전송
     * @param component, event
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    // 23.09.07 PHJ 위즈모 전환
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

    /**
     * @description 바닥페이지에서 검색 클릭 시 offset 초기화
     * @param component, event
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    fnSearchBtnClick : function(component, event) {
        var isSearchBtnClick = event.getParam('isSearchBtnClick');
        if (isSearchBtnClick) {
            component.set('v.pageOffset', 0);
        }
    },
    onWijmoMessage1: function (component, event, helper) {
        const payload = event.getParam('payload');
        console.log('Salesforce handleMessage data : ', JSON.parse(JSON.stringify(payload)));
        console.log('payload.row : ', payload.row);

        const actionName = payload.name;
        const row = payload.row;
        component.set('v.isSrSaleOn',false);
        console.log('v.isSrSaleOn 선택직전::',component.get('v.isSrSaleOn'));

        switch (payload.type) {
            case 'rowSelection':
                console.log('payLoad : ' + payload);
                console.log(JSON.stringify(payload));
                const selectedRows = payload.selectedRows;

                console.log('selectedRows@@@  : ' + JSON.stringify(selectedRows));
                if(selectedRows.length == 0){
                    component.set('v.channel', null);
                }else{
                    component.set('v.objSelected', selectedRows[0]);
                    component.set('v.channel', selectedRows[0].OrderChannel);
                    //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)
                    helper.isSpecificationValid(component, selectedRows[0].OrderNumber);
                    //23 08 31 hyungho.chun
                    helper.checkSrSale(component,selectedRows[0].Id);
                }
                break;
            case 'dblclick':
                console.log('dblclick !!!!');
                console.log('payload.item : '+JSON.stringify(payload.item));
                component.set('v.selectedRowsFromWijmo',  payload.item);

                //23 08 07 hyungho.chun 더블클릭시에도 명세서 체크박스 보이게 수정
                helper.isSpecificationValid(component, payload.item.OrderNumber);
 
                helper.fnWijmoSeleceted(component, event, helper);

                const selectedRow = payload.item;
                
                component.set('v.objSelected', selectedRow);
                component.set('v.channel', selectedRow.OrderChannel);

                //23 08 31 hyungho.chun
                helper.checkSrSale(component,selectedRow.Id);                
                
                
                break;
            case 'rowAction':
                if ('URL' === actionName && payload.row.CaseURL != null) {
                    helper.fnCustomerUrl(component, event, helper, payload.row);
                }
                break;
            case 'downloadDone':
                component.set('v.showSpinner', false);
                break;
        }
    },
    downloadExcel : function(component, event, helper) {
        console.log('downloadExcel !');
        component.set('v.showSpinner', true);
        helper.fnDownloadExcel(component, event, helper);
    },

    //23 08 30 hyungho.chun 영수증 버튼클릭
    fnReceiptForm: function(component, event, helper){


        var selectedRow = component.get('v.objSelected');
        console.log('영수증버튼후 selectedRow : ',selectedRow);

        var isSrSaleOn = component.get('v.isSrSaleOn');
        
        if(selectedRow.length>0){
            if(isSrSaleOn){
                helper.openScriptFormPop(component, selectedRow, "EX_receiptForm");
            }else{
                return helper.showToast('error','판매정보가 없는 주문입니다');
            }
        }else{
            return helper.showToast('error','주문을 선택해주세요');
        }

    }


});