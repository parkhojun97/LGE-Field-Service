/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    // // 주문 리스트 Modal
    // doOpenOrderListModal : function (component) {
    //     component.set('v.ShowOrderListModal',true);
    // },
    // doCloseOrderListModal : function(component) {
    //     component.set('v.ShowOrderListModal', false);
    //     // 조회 데이터 리셋
    //     this.orderListReset(component);
    // },
    // 주문 상태 변경 Modal
    doOpenOrderStChangeModal :function (component) {
        component.set('v.showOrderStChangeModal',true);
    },

    /**
     * @description 소모품 통합주문관리 주문 상태 변경 모달 Close 및 초기화
     * @param component
     * @param event
     * @author 23.02.13 / I2MAX.SEUNGHUNAHN
     */
    doCloseOrderStChangeModal :function (component) {
        component.set('v.showOrderStChangeModal',false);
        component.set('v.stChangeTargetObj', null);
        component.set('v.orderStatusList', []);
        component.set('v.preSelectedRows', []);

        // 임시로 노출한 변경 후 상태정보 삭제
        var relatedOrderList = component.get('v.selectedRowsForStChg');
        var originMap = component.get('v.originMap');
        var originTrackingNumberMap = originMap['TrackingNumber'];
        var originHandWorkReasonMap = originMap['HandWorkReason'];

        console.log('originMap : ' + JSON.stringify(originMap));
        console.log(JSON.stringify(originTrackingNumberMap));
        console.log(JSON.stringify(originHandWorkReasonMap));


        relatedOrderList.forEach(function(ro) {
            if (!(ro.UpdatedOrderStatus == null || ro.UpdatedOrderStatus == undefined)) {
                ro.UpdatedOrderStatus = null;
            }

            // 취소 시 노출되던 송장번호 원복
            if (originTrackingNumberMap[ro.Id] != undefined
                && originTrackingNumberMap[ro.Id] != null
                && ro.TrackingNumber != originTrackingNumberMap[ro.Id]) {
                ro.TrackingNumber = originTrackingNumberMap[ro.Id];
            }

            // 취소 시 노출되던 변경사유 원복
            if (originHandWorkReasonMap[ro.Id] != undefined
                && originHandWorkReasonMap[ro.Id] != null
                && ro.HandWorkReason != originHandWorkReasonMap[ro.Id]) {
                ro.HandWorkReason = originHandWorkReasonMap[ro.Id];
            }
        });
        // component.set('v.selectedRows', relatedOrderList);

        // 수정 가능 필드 초기화
        component.set('v.deliveryCompanyReadOnly', true);
        component.set('v.trackingNumberReadOnly', true);
        component.set('v.changeReasonReadOnly', true);
        component.set('v.orderStatusReadOnly', true);
        component.set('v.deliveryDateReadOnly', true);
        component.set('v.saveReadOnly', true);
        // component.set('v.originTrackingNumberMap', {});
    },
    /**
     * @description 소모품 통합주문관리 반품 모달 Open
     * @param component
     * @param event
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     */
    doOpenReturnOrderModal :function (component, event) {
        console.clear();
        console.log('doOpenReturnOrderModal');

        component.set('v.showSpinner', true);

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
                console.log(result);
                // 상담이력 정보
                if(result['caseInfo'] != null) {
                    component.set('v.caseInfo', result['caseInfo']);
                    component.set('v.caseDescriptionByReturnRequest', result['caseInfo'].CaseDescription);
                }

                component.set('v.productRequestLineItemsByReturnRequest', result['productRequestLineItemsByReturnRequest']);
                component.set('v.showSpinner', false);
                component.set('v.showReturnOrderModal',true);
                console.log('doOpenReturnOrderModal Success');
            } else {
                var errors = response.getError();
                console.log('### Error: ' + errors[0].message);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    doCloseReturnOrderModal :function (component) {
        component.set('v.showReturnOrderModal',false);
    },
    // // 교환요청 Modal
    // doOpenExchangeModal :function (component) {
    //     component.set('v.showExchangeModal',true);
    // },
    // doCloseExchangeModal :function (component) {
    //     component.set('v.showExchangeModal',false);
    // },
    // 주문 리스트 조회
    fnDoOrderListSearch : function (component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.listOrder', []);

        var mapSearchOrderParam = component.get('v.mapSearchOrderParam');
        console.log('조회클릭!!');
        var isValid;
        isValid = helper.fnValidDate(component, event, helper);

        if (isValid == false) {
            component.set('v.showSpinner', false);
            return;
        }

        console.log('mapSearchOrderParam' + mapSearchOrderParam)
        console.log(JSON.stringify(mapSearchOrderParam));

        var action = component.get('c.doGetSearchOrderList');
        action.setParams({
            'mapSearchOrderParam': mapSearchOrderParam
        });
        action.setCallback(this, function (response) {
            console.log('EX_IntegrationOrderManagementController');
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result['productRLineItems']);
                var productRLineItems = result['productRLineItems'];

                if (productRLineItems.length != 0) {
                    component.set('v.listOrder', productRLineItems);
                } else {
                    component.set('v.listOrder', []);
                }
                console.log('###Data : ', component.get('v.listOrder'));
                component.set('v.showSpinner', false);
            } else {
                var errors = response.getError();
                console.log('### Error: ' + errors[0].message);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    fnUpdateList : function (component, event, strPhone) {
        component.set('v.showSpinner', true);

        var mapSearchOrderParam = component.get('v.mapSearchOrderParam');

        var action = component.get('c.doGetSearchOrderList');
        action.setParams({
            'mapSearchOrderParam': mapSearchOrderParam
        });
        action.setCallback(this, function (response) {
            console.log('EX_IntegrationOrderManagementController');
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result['productRLineItems']);
                var productRLineItems = result['productRLineItems'];

                if (productRLineItems.length != 0) {
                    component.set('v.listOrder', productRLineItems);
                } else {
                    component.set('v.listOrder', []);
                }
                console.log('###Data : ', component.get('v.listOrder'));
                component.set('v.showSpinner', false);
            } else {
                var errors = response.getError();
                console.log('### Error: ' + errors[0].message);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    fnPhoneChgFormat : function (component, event, strPhone) {
        var strLen = '';
        var strSetValue = '';

        if (!strPhone) return strPhone;

        strPhone = strPhone.replace(/[^0-9]/g, '');
        strLen = String(strPhone.length);

        switch (strLen) {
            case '8' :
                strSetValue = strPhone.substr(0,4);
                strSetValue += '-' + strPhone.substr(4);
                break;

            case '9' :
                strSetValue = strPhone.substr(0,2);
                strSetValue += '-' + strPhone.substr(2,3);
                strSetValue += '-' + strPhone.substr(5);
                break;

            case '10' :
                if(strPhone.substr(0,2) == "02") {
                    strSetValue = strPhone.substr(0,2);
                    strSetValue += '-' + strPhone.substr(2, 4);
                    strSetValue += '-' + strPhone.substr(6);
                } else {
                    strSetValue = strPhone.substr(0,3);
                    strSetValue += '-' + strPhone.substr(3,3);
                    strSetValue += '-' + strPhone.substr(6);
                }
                break;

            case '11' :
                strSetValue = strPhone.substr(0,3);
                strSetValue += '-' + strPhone.substr(3,4);
                strSetValue += '-' + strPhone.substr(7);
                break;

            default :
                strSetValue = strPhone;
        }

        return strSetValue;
    },

    fnValidDate : function (component, event, helper) {
        var mapSearchOrderParam = component.get('v.mapSearchOrderParam');

        if ($A.util.isEmpty(mapSearchOrderParam.baseDateStart) || $A.util.isEmpty(mapSearchOrderParam.baseDateEnd)) {
            this.showToast('warning', '시작 날짜와 종료 날짜는 필수 입력 조건입니다.');
            return false;
        }

        var startDate = new Date(mapSearchOrderParam.baseDateStart);
        var endDate = new Date(mapSearchOrderParam.baseDateEnd);

        var time = endDate - startDate;
        const diffDate = time / (24 * 60 * 60 * 1000);
        console.log(diffDate);

        if (diffDate < 0) {
            this.showToast('warning', '조회기간 설정이 잘못되었습니다.');
            return false;
        }
        if (diffDate > 30) {
            this.showToast('warning', '조회기간은 최대 30일 입니다.');
            return false;
        }
        if(mapSearchOrderParam.CJOrderY == null && mapSearchOrderParam.CJOrderN == null){
             this.showToast('error','CJ 전송여부를 입력해주세요');
             return false;
        }
        return true;
    },

    showToast : function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    // 주문리스트 조회 데이터 리셋
    orderListReset : function (component) {
        component.set('v.mapSearchOrderParam.orderChannel', 'ALL');
        component.set('v.mapSearchOrderParam.listDepartment', 'ALL');
        component.set('v.mapSearchOrderParam.orderNo', null);
        component.set('v.mapSearchOrderParam.contactName', null);
        component.set('v.mapSearchOrderParam.contactPhone', null);
        component.set('v.mapSearchOrderParam.CJOrderNo', null);
        component.set('v.mapSearchOrderParam.CJOrderY', false);
        component.set('v.mapSearchOrderParam.CJOrderN', false);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.mapSearchOrderParam.baseDateStart', today);
        component.set('v.mapSearchOrderParam.baseDateEnd', today);
        component.set('v.listOrder', null);
    },

    // 반품 수량 validation
    fnChkReturnQuantity : function(objSelected, draftValues){
        let isValidQuantity = true;
        draftValues.forEach(function(draftData){
            objSelected.forEach(function(selectData){
                console.log('draftData.RequestedReturnQuantity -> ' + draftData.RequestedReturnQuantity);
                console.log('selectData.SaleQuantity -> ' + selectData.SalesQuantity);
                if(draftData.Id == selectData.Id){
                    if(draftData.RequestedReturnQuantity > selectData.SalesQuantity){
                        isValidQuantity = false;
                    }
                }
            });
        });
        return isValidQuantity;
    },

    /**
     * @description 소모품 주문 상태 변경 시 주문 상태 리스트 및 수정 가능 필드 초기화
     * 23.02.13 배송준비중만 변경하도록 수정
     * @param component
     * @param String orderStatus
     * @param String orderChannel
     * @return List<String> orderStatusList
     * @author 23.02.11 / I2MAX.SEUNGHUNAHN
     */
    fnOrderStatusListInit : function(component, orderStatus, orderChannel) {
        var orderStatusList = [];

        orderStatusList.push(orderStatus);
        switch (orderStatus) {
            // case '상품준비중':
            //     component.set('v.deliveryCompanyReadOnly', false);
            //     component.set('v.trackingNumberReadOnly', false);
            //     component.set('v.changeReasonReadOnly', false);
            //     component.set('v.orderStatusReadOnly', false);
            //     if (orderChannel == 'ThinQ') {
            //         orderStatusList.push('주문취소');
            //     }
            //
            //     orderStatusList.push('배송준비중');
            //     orderStatusList.push('배송중');
            //     break;
            // case '배송중':
            //     component.set('v.changeReasonReadOnly', false);
            //     component.set('v.orderStatusReadOnly', false);
            //     orderStatusList.push('배송중');
            //     orderStatusList.push('배송완료');
            //     break;
            case '배송준비중':
                component.set('v.orderStatusReadOnly', false);
                component.set('v.changeReasonReadOnly', false);
                orderStatusList.push('상품준비중');
                break;
            default:
                orderStatusList.push('배송준비중');
                orderStatusList.push('배송중');
                // orderStatusList = [];
                break;
        }
        
        return orderStatusList;
    },

    /**
     * @description 소모품 주문 상태 변경 업데이트
     * @param component
     * @author 23.02.13 / I2MAX.SEUNGHUNAHN
     */
    fnUpdateOrderStatus : function(component) {
//           var orderStChangeDT = component.find('orderStChangeDT');
//           var selectedRows = orderStChangeDT.getSelectedRows()[0];

           var selectedRows = component.get('v.stChangeTargetObj');
           var prLiList = component.get('v.selectedRowsForStChg');
           var targetObjsId = [];
           var selectedId = [];

           console.log('helper prLiList : ' + JSON.stringify(prLiList));
           console.log('selectedRows : ' + JSON.stringify(selectedRows));
           /*for (var idx in prLiList) {
               if (prLiList[idx].Id == selectedRows.Id) {
                   selectedId.push(prLiList[idx].Id);
               }

               // 변경대상 Obj Id들
               if (prLiList[idx].UpdatedOrderStatus != null) {
                   targetObjsId.push(prLiList[idx].Id);
               }
           }*/
           for (var idx in selectedRows) {
                targetObjsId.push(selectedRows[idx].Id);
           }
           console.log('targetObjsId : ' + targetObjsId);
           var action = component.get('c.doUpdateOrderStatus');

           // param 값 확인 필요 23.08.07 PHJ
           action.setParams({
              'targetObjsId' : targetObjsId,
            //   'prLiList' : JSON.stringify(prLiList)
              'prLiList' : JSON.stringify(selectedRows)
            });

            console.log('helper prLiList 2: ' + JSON.stringify(prLiList));
            console.log('selectedRows 2: ' + JSON.stringify(selectedRows));


           component.set('v.showSpinner', true);
           action.setCallback(this, function(response) {
               var state = response.getState();
               var returnValue = null;
               if (state === 'SUCCESS') {
                   returnValue = response.getReturnValue();
                   if (returnValue == 'SUCCESS') {
                       this.showToast('SUCCESS', '주문 상태 변경 성공');
                       this.doCloseOrderStChangeModal(component);
                       //23.11.16 PHJ 재조회를 하는 이유는? 
                       var evt = $A.get('e.c:EX_PaginationResearch_evt');
                    //    evt.setParam('pageNumber', selectedRows[0].OrderNumber);
                       evt.fire();
                       component.set('v.showSpinner', false);
                   }
                   else {
                       console.log('error');
                       this.showToast('error', '주문 상태 변경 실패');
                       component.set('v.showSpinner', false);
                   }
               }
               else if (state === 'ERROR') {
                   console.log(response.getErrors());
                   this.showToast('error', response.getError());
                   component.set('v.showSpinner', false);
               }
           });

           $A.enqueueAction(action);
       },

    //송장번호 URL
//    getTrackingNumber : function(component) {
//        var action = component.get("c.doGetTrackingNumberList");
//        action.setParams({
//        });
//        action.setCallback(this, function(response) {
//            var state = response.getState();
//
//            if(state === "SUCCESS") {
//                var result = response.getReturnValue();
//                var listSms = result["data"];
//            }
//        });
//        $A.enqueueAction(action);
//    },
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

            case '11' :

                strSetValue = strTel.substr(0, 3);
                strSetValue += '-' + strTel.substr(3, 4);
                strSetValue += '-' + strTel.substr(7); //"###-####-####";
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
                'Id' : recordId
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state ==='SUCCESS'){
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

    /**
     * @description 판매 저장
     * @param component
     * author 23.03.07 / I2MAX.SEUNGHUNAN
     */
    saveSales : function(component) {
        // var objSelected = component.get('v.objSelected')[0];
        // var objSelected = component.get('v.selectedRowsSaveSales')[0];
        //23 09 16 hyungho.chun 판매저장할 대상 선택 방법 변경
        var objSelected = component.get('v.objSelected')[0];
        var orderNumberList = [];

        orderNumberList.push(objSelected.OrderNumber);
        console.log('orderNumberList : ' + orderNumberList);
        component.set('v.showSpinner', true);

        var action = component.get('c.doSaveSales');
        action.setParam('orderNumberList', orderNumberList);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {

                var rtnMap = response.getReturnValue();
                //23 10 01 hyungho.chun header없는경우 오류메세지 따로 표출
                // if(rtnMap['errorReason'] != null && rtnMap['errorReason'] == 'HeaderMissing'){
                //     this.showToast('error', rtnMap['errorMessage']);
                //     component.set('v.showSpinner', false);
                //     return;
                // }

                console.log(JSON.stringify(rtnMap));
                //console.log(JSON.stringify(rtnMap2));

                if (rtnMap == null || rtnMap == undefined) {
                    this.showToast('error', '판매 저장 실패');
                    component.set('v.showSpinner', false);
                    return;
                }
                else {
                    if (rtnMap['error'] != null) {
                        this.showToast('error', '판매 저장 실패 : ' + rtnMap['error']);
                        component.set('v.showSpinner', false);
                        return;
                    }
                }

                // if (rtnMap2 == null || rtnMap2 == undefined) {
                //     this.showToast('error', '판매 저장 대상 아님, 잘못된 데이터 값입니다. 관리자에게 문의하세요.');
                // }
                if (rtnMap['isSuccess'] == 'true') {
                    this.showToast('success', '판매저장이 완료되었습니다.');
                    component.set('v.salesSaveBtnDisabled', true);
                    //component.set('v.data', data);
                }

                else {
                    this.showToast('error', '판매저장 실패 : ' + rtnMap['error']);
                    // var data = component.get('v.data');
                    //
                    // for (var idx in data) {
                    //     if (data[idx].OrderNumber === objSelected.OrderNumber
                    //         && data[idx].SubNumber.includes('-01')
                    //         && rtnMap2[objSelected.OrderNumber] != null
                    //         && rtnMap2[objSelected.OrderNumber] != '') {
                    //         console.log('branch in savesales');
                    //         data[idx].SalesNumber = rtnMap['Sales Result Number Fair'][objSelected.OrderNumber];
                    //         data[idx].DeliveryColor = 'bg_color_delivery';
                    //         data[idx].CancelColor = 'bg_color_cancel';
                    //         data[idx].ReturnColor = 'bg_color_return';
                    //         data[idx].ExchangeColor = 'bg_color_exchange';
                    //         data[idx].SalesError = '';
                    //     }
                    // }
                //23.09.06 PHJ
                    return;
                }

                //23.09.06 PHJ
                $A.get('e.force:refreshView').fire();
            }
            else if(state === 'ERROR') {
                var errors = response.getError();
                this.showToast('error', '판매저장 실패');
                console.log('error : ' + errors.message);
            }
            component.set('v.orderListSelectedRows', objSelected.Id);
            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    },

    //23.09.07 PHJ 현재사용 x
    // sortData: function (cmp, fieldName, sortDirection) {
    //     var data = cmp.get("v.data");
    //     var reverse = sortDirection !== 'asc';
    //     data.sort(this.sortBy(fieldName, reverse))
    //     cmp.set("v.data", data);
    // },

    //23.09.07 PHJ 현재사용 x
    // sortBy: function (field, reverse, primer) {
    //     var key = primer
    //       ? function(x) {
    //           return x[field] !== null && x[field] !== undefined  ? primer(x[field]) : '';
    //         }
    //       : function(x) {
    //           return x[field] !== null && x[field] !== undefined  ? x[field] : '';
    //         };

    //     reverse = !reverse ? 1 : -1;

    //     return function(a, b) {
    //       a = key(a);
    //       b = key(b);

    //       if (a === '') return 1;  // Place null values at the end
    //       if (b === '') return -1; // Place null values at the end
    //       console.log('a : '+ a);

    //       if (typeof a === 'string' && typeof b === 'string') {
    //         if (a === b) return 0;  // If both values are the same, consider them equal
    //         return reverse * a.localeCompare(b);
    //       }

    //       if (typeof a === 'number' && typeof b === 'number') {
    //         return reverse * (a - b);
    //       }

    //       return 0; // If types are not compatible, consider them equal
    //     };
    // },

    /**
     * @description 데이터 테이블 스크롤 가능 여부 판단해서 return Promise 사용
     * @param component
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    //23.09.07 PHJ 현재 사용 x
    // loadMoreData : function(component) {
    //     var data = component.get('v.data');
    //     var recordLimit = component.get('v.recordLimit');
    //     var totalRecord = component.get('v.totalRecord');

    //     var isValid = new Promise($A.getCallback(function(resolve, reject) {
    //         var action = component.get('c.moreLoadValid');
    //         action.setParams({
    //             'dataLength': data.length,
    //             'recordLimit' : recordLimit,
    //             'totalRecord' : totalRecord
    //         });
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             if (state === 'SUCCESS') {
    //                 resolve(response.getReturnValue());
    //             }
    //             else if (state === 'ERROR') {
    //                 reject(response.getError());
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }));

    //     return isValid;
    //     // var moreDataLength = data.length + recordLimit;
    //     //
    //     // return (moreDataLength - data.length) <= recordLimit;
    // },
    fnSelectedFromWijmo: function (component, event, helper, type, selectedRows) {
        console.log('### row fnSelectedFromWijmo  ###');
        console.log('selectedRows :: ' + JSON.stringify(selectedRows));
        // rowSelection, doubleclick 둘다 들어옴
        if (component.get('v.showOrderStChangeModal')) {
            console.log('selectedRows :: ' + JSON.stringify(selectedRows));
            //if (!selectedRows) return;
            if (selectedRows != undefined) {
                component.set('v.stChangeTargetObj', selectedRows);
            }

            var targetObj = component.get('v.stChangeTargetObj');
            console.log('targetObj :: ' + JSON.stringify(targetObj));
            if (targetObj == null || targetObj == undefined) return;

            // 23.02.19 상품배송중으로 바로 변경되게 수정
            // var stChangeTargetObj = component.get('v.stChangeTargetObj');
            var prLiList = component.get('v.selectedRowsForStChg');
            //var updatedOrderStatus = '상품준비중';
            var selectedId = [];

            for (var idx in prLiList) {
                // prLiList[idx].UpdatedOrderStatus = updatedOrderStatus;
                // if (prLiList[idx].Id == targetObj.Id) {
                //     prLiList[idx].UpdatedOrderStatus = updatedOrderStatus;
                //     console.log('prLiList updated : ' + prLiList[idx].UpdatedOrderStatus);
                //     selectedId.push(prLiList[idx].Id);
                //     break;
                // }
            }

            

            component.set('v.componentName','wijmo_EXOrderStChange');
            component.set('v.saveReadOnly', false);
            component.set('v.changeReasonReadOnly', false);
            component.set('v.selectedRowsForStChg', prLiList);
            component.set('v.preSelectedRows', selectedId);

            

            // setTimeout(function () {
            //     helper.sendMessage(component, {type:'items', items: selectedRows});
            // }, 1000);


        }
        else if(type == 'dblclick'){
            component.set('v.showSpinner', false);
            var selectedRows = component.get('v.selectedRowsFromWijmo');
            component.set('v.objSelected', selectedRows);
            console.log('selectedRows -> ' + selectedRows);
            if (!selectedRows.length) {
                component.set('v.mapInfo', []);
                // component.set('v.showSpinner', false);
                return;
            }

            component.set("v.mapInfo", selectedRows);
            // var evt = $A.get("e.c:EX_ConsumableOrderList_evt");
            var evt = $A.get("e.c:EX_IntegrationOrderListNew_evt");
            evt.setParam("data", selectedRows);
            evt.fire();
        }
        // component.set('v.showSpinner', false);
    },

    /**
     * @description 통합주문관리 주문내역 버튼 (주문상태변경, 판매저장 Validation)
     * @param component, selectedRows(체크박스 클릭 row)
     * author 23.06.26 / I2MAX.SEUNGHUNAN
     */
    buttonCheckerForWijmo : function(component, selectedRows) {
        console.log('buttonCheckForWijmo');
        console.log(JSON.stringify(selectedRows));
        //23 09 16 hyungho.chun 판매저장대상용
        component.set('v.objSelected', selectedRows);

        if (Object.keys(selectedRows).length <= 0) {
            // 주문상태변경 버튼 초기화
            component.set('v.orderStatusDisabled', true);

            // 판매저장 버튼 초기화
            component.set('v.salesSaveBtnDisabled', true);
            return;
        }

        var strOrderStatus = selectedRows[0].OrderStatus;
        var strOrderChannel = selectedRows[0].OrderChannel;
        var orderNumber = selectedRows[0].OrderNumber;
        var orderSeq = selectedRows[0].OrderSeq;
        var OrderStatusDetail = selectedRows[0].OrderStatusDetail;
        var os = null;

        // 주문 상태 변경 Button Checker
        //23 09 21 hyungho.chun strOrderChannel == 'LGE.COM' 추가
        if (strOrderStatus == '배송준비중' && (strOrderChannel == '소모품택배' || strOrderChannel == 'LGE.COM') && selectedRows[0].BasisOrderNumber == null ) { //24 01 03 hyungho.chun 교환주문은 거르기위해  && selectedRows[0].BasisOrderNumber == null 추가
            component.set('v.orderStatusDisabled', false);
            console.log('component.get : ' + component.get("v.orderStatusDisabled"));
        }
        else {
            console.log('button off');
            component.set('v.orderStatusDisabled', true);
        }

        if(strOrderStatus == '배송준비중' && strOrderChannel == '소모품택배' && OrderStatusDetail == "반품예약" || 
           strOrderStatus == '배송준비중' && strOrderChannel == '소모품택배' && OrderStatusDetail == "교환요청"){
            component.set('v.orderStatusDisabled', true);
        }

        // 판매저장 버튼 체크
        var action = component.get('c.doGetOrderLineItemData');
        action.setParams({
            'orderNumber' : orderNumber,
            'orderSeq' : null
        });

        component.set('v.showSpinnerForOrderList', true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :: ' + state);
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();
                var productRequestLineItems = result['productRequestLineItems'];
                var cbtc = null, sn = null, os = null;

                console.log('ProductRequestLineItem :: ' + JSON.stringify(productRequestLineItems));

                // relatedList 추출 이식 (6/27)
                // 원주문건만 쿼리해오도록 한다. (취소카운트는 패스)
                var originRelatedOrderList = productRequestLineItems.filter(function(pr) {
                    cbtc = pr.ConsumablesBusinessTypeCode;
                    sn = pr.SubNumber;
                    os = pr.OrderStatus;
                    return ((cbtc !== '' && cbtc !== null)
                        && (cbtc === '주문' || cbtc === '교환주문')
                        //23 11 06 hyungho.chun 교환주문건이 상품준비중일때 판매확정버튼활성화되길래 뺌
                        // && (sn.includes('-01'))

                        // 23 07 14 hyungho.chun
                        //24 03 01 hyungho.chun 취소건 미리 제외하는 로직 복구
                        && (!os.includes('취소'))
                        );
                });

                originRelatedOrderList.sort(function (a, b) {
                    return a.SubNumber < b.SubNumber ? -1 : +(a.SubNumber > b.SubNumber);
                });
                console.log('판매저장 valid');
                console.log('@@ originRelatedOrderList @@ : ', JSON.stringify(originRelatedOrderList));
                // // 판매저장 Validation
                //12 05 hyungho.chun 시작을 true로 박고시작 전부다 배송중이거나 배송완료가아닌 배송중이나 배송완료건 하나만있어도 버튼활성화되야함 (결제후 부분취소후 나머지만 배송중으로 넘어간경우 대비) 
                var salesValid = true;
                var isNotReady = false;//24 03 01 hyungho.chun 하나라도 준비안된게있으면 true로 바꾼다.
                originRelatedOrderList.forEach(oro => {
                    console.log('oro : ', oro);
                    var SalesNumber = oro.SalesNumber;
                    var OrderStatus = oro.OrderStatus;
                    console.log('SalesNumber : ',SalesNumber);
                    console.log('OrderStatus : ',OrderStatus);
                    // 원주문건 5개중 2개는 취소되었다면 3개에 대해 판매처리 해야하므로 패스, 앞단에서 처리
                    // if (OrderStatus.includes('취소')) return;


                    //23 12 05 hyungho.chun 전부다 배송중이거나 배송완료가아닌 배송중이나 배송완료건 하나만있어도 버튼활성화되야함 (결제후 부분취소후 나머지만 배송중으로 넘어간경우 대비)
                    // if (!((SalesNumber == null) && (OrderStatus == '배송중' || OrderStatus == '배송완료'))) {
                    //     salesValid = true;
                    // }
                    if (SalesNumber != null) {
                        salesValid = true;
                        return;
                    }
                    if(OrderStatus.includes('준비중')){ //24 03 01 hyungho.chun 하나라도 상품준비중이나 배송준비중으로 남아있는경우 판매저장버튼 disabled
                        isNotReady = true;
                    }

                    if(((OrderStatus == '배송중' || OrderStatus == '배송완료'))){
                        salesValid = false;
                        return;
                    }


                });
                console.log('salesValid : ' ,salesValid);
                component.set('v.salesSaveBtnDisabled', (salesValid || isNotReady));
                // 판매저장 대상 건
                component.set('v.selectedRowsSaveSales', originRelatedOrderList);
                
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
                console.log('FilteredPrLi :: ' + JSON.stringify(filteredPrLi));

                var originMap = component.get('v.originMap');
                var trackingNumberMap = {};
                var handWorkReasonMap = {};

                filteredPrLi.forEach(function(ro) {
                    ro.After_Order_Status = 'font-color-red';
                    // Id를 Key로 기존의 송장번호, 수작업사유 저장
                    // 기존에 송장 번호, 수작업사유 존재 하지 않을 시 '' 처리해서 undefined 예방
                    trackingNumberMap[ro.Id] = ro.TrackingNumber != undefined ? ro.TrackingNumber : '';
                    handWorkReasonMap[ro.Id] = ro.HandWorkReason != undefined ? ro.HandWorkReason : '';

                    ro.HandWorkReason = '';
                });

                if (filteredPrLi == null || filteredPrLi == undefined) {
                    component.set('v.selectedRowsForStChg', null);
                    return;
                }
                component.set('v.selectedRowsForStChg', filteredPrLi);
                originMap['TrackingNumber'] = trackingNumberMap;
                originMap['HandWorkReason'] = handWorkReasonMap;
                console.log('TTTTTTTTTTTTTTT');
            }
            else if (state === "ERROR") {
                var errors = response.getError();

                component.set('v.selectedRowsForStChg', []);
                component.set('v.selectedRowsSaveSales', []);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set('v.showSpinnerForOrderList', false);
        });
        $A.enqueueAction(action);
    },

    /**
     *
     * @param component
     * @param msg
     */
    sendMessage: function(component, msg) {
        console.log('위즈모');

        console.log('msg -> ' + msg);
        var cName = component.get('v.componentName');

        console.log('cName : ', cName);
        console.log(component.find(cName));
        component.find(cName).message(msg);
    },


    /**
     * @description Wijmo -> SFDC Event Handler
     * @param component
     * @param event
     * @param helper
     */
    fnDownloadExcel : function(component, event, helper) {
        var data = component.get('v.data');
        var msg = {type:'downloadExcel', items: data}
        console.log('fnDownloadExcel msg -> ' + msg);
        console.log('data -> ' + JSON.stringify(data));
        component.find('wijmo_EXIntegrationOrderList').message(msg);
    },
    handleWijmoRowAction: function (component, event, helper, row) {
        var recordId = row['Id'];
        component.set('v.showDeliveryInformationModal', true);

        helper.fnSetDeliveryInformationColumns(component, recordId);
    },
});