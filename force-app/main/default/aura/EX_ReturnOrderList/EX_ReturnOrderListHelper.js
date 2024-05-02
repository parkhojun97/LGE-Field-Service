/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-25.
 */

({
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    },

    //23.09.01 PHJ
    fnReturnOrderConfirm: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var selectedRows = component.get('v.objSelected');
        console.log('selectedRows : ',selectedRows);
        var roliIdSet = [];
        selectedRows.forEach((item) => {
            roliIdSet.push(item.Id);
        });
        console.log('roliIdSet : ',roliIdSet);
        //23.09.01 PHJ
        component.set('v.textAreaSetValue', component.get('v.textAreaValue'));
        let textAreaVal = component.get('v.textAreaSetValue');

        //23 12 09 hyungho.chun 
        var collection_YN_temp = component.get('v.collection_YN_temp');
        console.log(' collection_YN_temp :: ', collection_YN_temp);
        var collectionFinalBoolean = false;
        if(collection_YN_temp == 'Y'){
            collectionFinalBoolean = true;
        }else if( collection_YN_temp = 'N'){
            collectionFinalBoolean = false;
        }else{
            helper.showToast('error', '수거여부체크가 제대로 안됐습니다.');
        }
        
        var action = component.get('c.doReturnOrderConfirm');
        var params = {
            'returnOrderLineItemIdList': roliIdSet,
            //23.09.01 PHJ
            'textAreaVal': textAreaVal,
            //23 12 09 hyungho.chun
            'collectionYN': collectionFinalBoolean,
        };
        action.setParams({
            'paramMap': params
        });

        console.log(roliIdSet);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                //23 10 01 hyungho.chun detail없는경우 오류메세지 따로 표출
                // if(rtnMap['errorReason'] != null && rtnMap['errorReason'] == 'DetailMissing'){
                //     component.set('v.showSpinner', false);
                //     helper.showToast('error', rtnMap['errorMessage']);
                //     return;
                // }
                  
                console.log(JSON.stringify(result));

                if (result['isSuccess']) {
                    component.set('v.showSpinner', false);
                    helper.showToast('success', '반품 확정이 완료되었습니다.');
                } else {
                    component.set('v.showSpinner', false);
                    helper.showToast('error', '반품 확정을 실패하였습니다. ' + result['errMsg']);
                    // component.set('v.collection_YN_temp','N');
                    component.set('v.collection_YN_temp','Y'); //24 03 22 hyungho.chun default 값 Y로 수정
                    return;
                }
                //23.09.06 PHJ
                $A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
                component.set('v.showSpinner', false);
                var errors = response.getError();
                helper.showToast('error', '반품 확정을 실패하였습니다.');
                console.log('error : ' + errors.message);
            }
            
            // component.set('v.collection_YN_temp','N');
            component.set('v.collection_YN_temp','Y'); //24 03 22 hyungho.chun default 값 Y로 수정
        });

        $A.enqueueAction(action);
    },


    doOpenModal: function (component) {
        component.set('v.objSelectedDisposal', component.get('v.objSelected'));
        component.set('v.ShowModal', true);

    },
    doCloseModal: function (component) {
        component.set('v.ShowModal', false);
        
        //23.10.06 PHJ
        let objSelectedDisposal = component.get('v.objSelectedDisposal');    
        objSelectedDisposal.forEach((item) => {
            item.Good_Quality_Quantity = 0;
            item.Disposal_Quantity = 0;
            item.Disposal_Reason = '';
        });
    },
    doChangeAddressModal: function (component) {

        // component.set('v.consigneeName', component.get('v.objSelected')[0].customer_Name);
        // component.set('v.consigneeTPNO', component.get('v.objSelected')[0].ConsigneeTPNO);
        // component.set('v.consigneeAddress', component.get('v.objSelected')[0].ConsigneeAddress);
        // component.set('v.consigneePostalCode', component.get('v.objSelected')[0].ConsigneePostalCode);
        // component.set('v.consigneeAddressDetail', component.get('v.objSelected')[0].ConsigneeAddressDetail);
        // component.set('v.deliveryMessage', component.get('v.objSelected')[0].DeliveryMessage);
        // component.set('v.IdForChangeDelivery', component.get('v.objSelected')[0].Id);

        component.set('v.ShowChangeAddressModal', true);
        var lightningCard = component.find('cardTitle');
        lightningCard.set('v.label', '주문 번호 : ' + component.get('v.objSelected')[0].Order_Number);

    },
    doCloseChangeAddressModal: function (component) {
        component.set('v.ShowChangeAddressModal', false);
        
        console.log('v.wijmoSelectedRows :::::::: ', component.get('v.wijmoSelectedRows'));
        console.log('v.objSelected :::::',component.get("v.objSelected"));
    },


    /**
     * @description 반품확정 버튼 활성화 체크,
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     * @author 23.05.01/ I2MAX.JIEUNSONG
     */
    fnReturnOrderConfirmBtnDisabledBtnValid: function (component) {
        var listMap = component.get("v.objSelected");
        console.log('listMap ::',listMap);
        var isValid = false;

        if (listMap.length > 0) {
            listMap.forEach(item => {
                //23 08 19 hyungho.chun 반품확정버튼 활성화 기준 수정
                if(item.Consumables_Order_Status == '반품요청'){
                    // if(!(item.ffmt_Transfer_YN =='Y' && item.ffmt_Transfer_DTM != null)){
                    //     isValid = true;
                    //     return isValid;
                    // }
                    //23 09 19 hyungho.chun 반품요청의 경우 다른 조건 체크하지않는거로 변경

                    //23.10.23 PHJ 교환이 Y 일 경우 반품확정 Disabled 처리
                    if(item.Consumables_Business_Type_Code === 'Y'){
                        isValid = true;
                    }
                    return isValid;
                }else if(item.Consumables_Order_Status == '반품확정'){
                    if(!(item.CONFIRM_YN == 'N')){
                        isValid = true;
                        return isValid;
                    }
                }else{
                    isValid = true;
                    return isValid;
                }

                // if(item.Consumables_Order_Status != '반품확정') {
                //     isValid = true;
                //     return isValid;
                // }
                
                // if (item.Consumables_Order_Status == '반품확정' && item.CONFIRM_YN == 'Y') {
                //     isValid = true;
                //     return isValid;
                // }
                
            });
        } else {
            isValid = true;
        }

        return isValid;
    },

    fnHandleDisposalBtnDisabledValid: function (component) {
        var listMap = component.get("v.objSelected");
        var isValid = false;

        if (listMap.length > 0) {
            listMap.forEach(item => {
                if (item.Consumables_Order_Status != '반품확정') {
                    isValid = true;
                }
                if (item.CONFIRM_YN != 'Y') {
                    isValid = true;
                }

                //23 12 09 hyungho.chun 양품/폐기 버튼 활성화기준에서 더이상 수거여부는 체크하지 않음
                // if (item.collection_YN != 'Y') {
                //     isValid = true;
                // }
                //23 09 19 hyungho.chun 반품요청하자마자 바로 확정하는경우가 있어서 조건 하나 제외
                // if (item.ffmt_Transfer_YN != 'Y') {
                //     isValid = true;
                // }
            });
        } else {
            isValid = true;
        }

        return isValid;
    },

    /**
     * @description 배송지수정 버튼 활성화 체크,
     * 조건 : (주문상태 = '반품요청'  & 수거여부 = 'N' & CJ전송여부 = 'N' & CJ전송일시 = NULL) OR (채널 = '택배주문' AND 상태 = '반품예약')
     * @param component
     * @param event
     * @author 23.05.04/ I2MAX.JIEUNSONG
     */
    fnChangeAddressBtnChg: function (component) {
        var listMap = component.get("v.objSelected");
        //var isValid = true;
        var isValid = false;
        if (listMap.length > 0) {
            listMap.forEach(item => {
                // 20230519 ysh 하나라도 조건에 안맞으면 비활성화 하도록 변경
//                if (item.Consumables_Order_Status == '반품요청' && item.ffmt_Transfer_YN == 'N' && item.ffmt_Transfer_DTM==null && item.collection_YN == 'N') {
//                    isValid = false;
//                }
//                if (item.order_Channel_TYPE == '소모품택배' && item.Consumables_Order_Status == '반품예약') {
//                    isValid = false;
//                }
                // if ((item.Consumables_Order_Status != '반품요청' || item.ffmt_Transfer_YN != 'N' || 
                // item.ffmt_Transfer_DTM != null || item.collection_YN != 'N') && (item.order_Channel_TYPE != '소모품택배' || item.Consumables_Order_Status != '반품예약')) {
                    
                //     isValid = true;
                // }

                // if(item.order_Channel_TYPE != '소모품택배') {
                //     isValid = true;
                // }

                //23 07 18 hyungho.chun 로직 변경
                if(item.order_Channel_TYPE == 'ThinQ') {
                    isValid = true;
                }

                if(item.Consumables_Order_Status != '반품요청' && item.Consumables_Order_Status != '반품예약'){
                    isValid = true;
                }

                if(item.ffmt_Transfer_YN != 'N' || item.ffmt_Transfer_DTM != null || item.collection_YN != 'N'){
                    isValid = true;
                }





            });
        } else {
            isValid = true;
        }

        return isValid;
    },


    /**
     * @description 반품요청철회 버튼 활성화 체크,
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     * @author 
     */
     fnReturnOrderCancelBtnDisabledBtnValid: function (component) {
        var listMap = component.get("v.objSelected");
        var isValid = false;

        if (listMap.length > 0) {
            listMap.forEach(item => {

                if(!(item.order_Channel_TYPE == '소모품택배' || item.order_Channel_TYPE == 'LGE.COM')) {
                    isValid = true;
                    return isValid;
                }

                if ((item.Consumables_Order_Status != '반품요청' && item.Consumables_Order_Status != '반품예약')) {
                    isValid = true;
                    return isValid;
                }
                

                //2024.03.18 seung yoon heo cj전송여부 체크 해제
                // if(item.ffmt_Transfer_YN != 'N' ||  item.ffmt_Transfer_DTM != null || item.collection_YN != 'N') {
                //     isValid = true;
                //     return isValid;
                // }
                
                //23.10.19 PHj
                if(item.Consumables_Business_Type_Code == 'Y') {
                    isValid = true;
                    return isValid;
                }

            });
        } else {
            isValid = true;
        }

        return isValid;
    },



    /**
     * @description 데이터 테이블 스크롤 가능 여부 판단해서 return Promise 사용
     * @param component
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    //23.09.07 PHJ 현재 사용 x
    // loadMoreData: function (component) {
    //     var data = component.get('v.data');
    //     var recordLimit = component.get('v.recordLimit');
    //     var totalRecord = component.get('v.totalRecord');

    //     var isValid = new Promise($A.getCallback(function (resolve, reject) {
    //         var action = component.get('c.moreLoadValid');
    //         action.setParams({
    //             'dataLength': data.length,
    //             'recordLimit': recordLimit,
    //             'totalRecord': totalRecord
    //         });
    //         action.setCallback(this, function (response) {
    //             var state = response.getState();
    //             if (state === 'SUCCESS') {
    //                 resolve(response.getReturnValue());
    //             } else if (state === 'ERROR') {
    //                 reject(response.getError());
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }));
    //     return isValid;
    // },
    // sortData: function (cmp, fieldName, sortDirection) {
    //     var data = cmp.get("v.data");
    //     var reverse = sortDirection !== 'asc';
    //     data.sort(this.sortBy(fieldName, reverse))
    //     cmp.set("v.data", data);
    // },
    // sortBy: function (field, reverse, primer) {
    //     var key = primer ?
    //         function (x) {
    //             return primer(x[field])
    //         } :
    //         function (x) {
    //             return x[field]
    //         };
    //     reverse = !reverse ? 1 : -1;
    //     return function (a, b) {
    //         return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
    //     }
    // },

    
    fnSelecetedWijmo: function (component, event, helper) {
        console.log('fnSelecetedWijmo 시작');

        let selectedRows = component.get('v.wijmoSelectedRows');

        if (selectedRows.length == 0) {
            component.set('v.fStatus', null);
            component.set('v.channel', null);
            component.set('v.status', null);
            component.set('v.linkage_YN', null);
            component.set('v.collection_YN', null);
            component.set('v.CONFIRM_YN', null);
            component.set('v.Consumables_Business_Type_Code', null);

            /* 23.05.01 추가 */
            component.set('v.ReturnOrderConfirmBtnDisabled', true);
            component.set('v.HandleDisposalBtnDisabled', true);
            component.set('v.ChangeAddressBtnDisabled', true);
            component.set('v.ChangeReturnOrderCancelBtnDisabled', true);
        } else {
            var jsonRow = JSON.stringify(selectedRows);
            //추가
            //component.set('v.dataTemp', jsonRow);
            component.set('v.dataTemp', selectedRows);
            //
            component.set('v.channel', selectedRows[selectedRows.length - 1].order_Channel_TYPE);
            //component.set('v.status',selectedRows[selectedRows.length-1].status);
            component.set('v.status', selectedRows[selectedRows.length - 1].Consumables_Order_Status);//수정
            component.set('v.linkage_YN', selectedRows[selectedRows.length - 1].linkage_YN);
            component.set('v.collection_YN', selectedRows[selectedRows.length - 1].collection_YN);
            component.set('v.CONFIRM_YN', selectedRows[selectedRows.length - 1].CONFIRM_YN);
            component.set('v.ffmt_Transfer_YN', selectedRows[selectedRows.length - 1].ffmt_Transfer_YN);
            component.set('v.ffmt_Transfer_DTM', selectedRows[selectedRows.length - 1].ffmt_Transfer_DTM);
            component.set('v.Consumables_Business_Type_Code', selectedRows[selectedRows.length - 1].Consumables_Business_Type_Code);

            // console.log(component.get('v.channel'));
            // console.log('Consumables_Business_Type_Code : ' + component.get('v.Consumables_Business_Type_Code'));
            // console.log(component.get('v.status'));
            // console.log(component.get('v.linkage_YN'));
            // console.log('component.get(v.collection_YN)  : '+component.get('v.collection_YN'));
            // console.log('component.get(v.CONFIRM_YN)  : '+component.get('v.CONFIRM_YN'));
            // console.log('component.get(v.ffmt_Transfer_YN)  : '+component.get('v.ffmt_Transfer_YN'));
            // console.log('component.get(v.ffmt_Transfer_DTM)  : '+component.get('v.ffmt_Transfer_DTM'));
            component.set('v.objSelected', selectedRows);

            if (component.get('v.fStatus') == selectedRows[selectedRows.length - 1].status || component.get('v.fStatus') == '' || component.get('v.fStatus') == null) {

                component.set('v.fStatus', selectedRows[0].status);
                // 반품확정 버튼 Validation
                component.set('v.ReturnOrderConfirmBtnDisabled', helper.fnReturnOrderConfirmBtnDisabledBtnValid(component));
                component.set('v.HandleDisposalBtnDisabled', helper.fnHandleDisposalBtnDisabledValid(component));
                component.set('v.ChangeAddressBtnDisabled', helper.fnChangeAddressBtnChg(component));
                component.set('v.ChangeReturnOrderCancelBtnDisabled', helper.fnReturnOrderCancelBtnDisabledBtnValid(component));

            } else {
                var newSelectList = [];
                for (var num = 1; num <= selectedRows.length - 1; num++) {
                    if (selectedRows[num].status == selectedRows[0].status) {
                        console.log('선택됨 : ' + component.get('v.objSelected'));
                        newSelectList.add(selectedRows[num]);
                    } else {
                        component.set('v.channel', null);
                        component.set('v.status', null);
                        component.set('v.linkage_YN', null);
                        component.set('v.collection_YN', null);
                        return this.showToast('error', '동일한 상태의 주문만 선택해주세요');

                    }
                }
            }
            //반품반려버튼 활성화 여부 -  주문채널:베스트샵 , 반품상태: 반품대기(102), 소모품오류가 '반품오류'를 포함했는지 - 소모품오류를 포함했는지로 확인
            for (var i = 0; i < selectedRows.length; i++) {
                var row = selectedRows[i];


                var consumablesError = row.Consumables_Error;
                var orderStatus = row.Consumables_Order_Status;
                var orderChannel = row.order_Channel_TYPE;
                //todo 조건문 double check
                if ((!consumablesError || !(consumablesError.includes('소모품오류'))) && orderStatus != '반품대기' && orderChannel != '베스트샵') {
                    // console.log('반품 반려 불가 조건임.');
                    // console.log('consumablesError : ' + consumablesError + '  ' + 'orderStatus  : ' + orderStatus  + '  ' + 'orderChannel  : ' + orderChannel);
                    component.set('v.RefundDecline_disable', true);
                } else {
                    // console.log('반품 반려 가능 조건임.');
                    // console.log('consumablesError : ' + consumablesError + '  ' + 'orderStatus  : ' + orderStatus  + '  ' + 'orderChannel  : ' + orderChannel);
                    component.set('v.RefundDecline_disable', false);
                }
            }

            // 반품확정 버튼 Validation
            component.set('v.ReturnOrderConfirmBtnDisabled', helper.fnReturnOrderConfirmBtnDisabledBtnValid(component));
            component.set('v.HandleDisposalBtnDisabled', helper.fnHandleDisposalBtnDisabledValid(component));
            component.set('v.ChangeAddressBtnDisabled', helper.fnChangeAddressBtnChg(component));
            component.set('v.ChangeReturnOrderCancelBtnDisabled', helper.fnReturnOrderCancelBtnDisabledBtnValid(component));

        }
    },
    sendMessage: function (component, msg) {
        var cName = component.get('v.componentName');
        // console.log('cName ' + cName);
        component.find(cName).message(msg);
    },

    fnDownloadExcel: function (component, event, helper) {
        var data = component.get('v.data');
        var msg = {type: 'downloadExcel', items: data}
        console.log('fnDownloadExcel msg -> ' + msg);
        component.find('wijmo_EXReturnOrderList').message(msg);
    },

    fnGetConsigneeInfo: function (component, event, helper, selectedRows) {
        component.set('v.showSpinner', true);

        component.set('v.updatedConsigneeName', '');
        component.set('v.updatedConsigneeTPNO', '');
        component.set('v.updatedConsigneePostalCode', '');
        component.set('v.updatedConsigneeAddress', '');
        component.set('v.updatedConsigneeAddressDetail', '');
        component.set('v.updatedDeliveryMessage', '');

        var action = component.get('c.doGetConsigneeInfo');
        console.log('selectedRow -> ' + selectedRows);
        var selectedRowId = selectedRows[0].Id;

        action.setParams({
            'selectedRowId': selectedRowId,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);

                component.set('v.IdForChangeDelivery', result['roId']);
                component.set('v.consigneeName', result['consigneeName']);
                component.set('v.consigneeTPNO', result['consigneeTPNO']);
                component.set('v.consigneePostalCode', result['consigneePostalCode']);
                component.set('v.consigneeAddress', result['consigneeAddress']);
                component.set('v.consigneeAddressDetail', result['consigneeAddressDetail']);
                component.set('v.deliveryMessage', result['deliveryMessage']);

                component.set('v.showSpinner', false);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.showSpinner', false);
                        evt.setParams({
                            type: 'Error',
                            message: errors[0].message
                        });
                        evt.fire();
                    }
                } else {
                    component.set('v.showSpinner', false);
                    this.showToast("error", "Unknown error");
                }
            }
        })
        $A.enqueueAction(action);

    },


    fnInitializeConsigneeInformation : function (component, event, helper) {
        component.set('v.updatedConsigneeName', '');
        component.set('v.updatedConsigneeTPNO', '');
        component.set('v.updatedConsigneePostalCode', '');
        component.set('v.updatedConsigneeAddress', '');
        component.set('v.updatedConsigneeAddressDetail', '');
        component.set('v.updatedDeliveryMessage', '');

        component.set('v.consigneeName', '');
        component.set('v.consigneeTPNO', '');
        component.set('v.consigneePostalCode', '');
        component.set('v.consigneeAddress', '');
        component.set('v.consigneeAddressDetail', '');
        component.set('v.deliveryMessage', '');
    },
    //23 07 18 hyungho.chun 배송지 수정 주문번호 수정기능
    doChangeOrderNumber: function (component,selectedRows) {

        var lightningCard = component.find('cardTitle');
        lightningCard.set('v.label', '주문 번호 : ' + selectedRows[0].Order_Number);

    },

});