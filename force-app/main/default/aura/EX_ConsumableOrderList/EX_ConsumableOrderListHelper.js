/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    // getCaseByCaseId : function(component, caseId) {
    //     console.log('orderList helper.');
    //     var action = component.get("c.getCaseByCaseId");
    //
    //     action.setParam('caseId', caseId);
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             component.set("v.objCase", response.getReturnValue());
    //         }
    //         else {
    //             console.log('fail');
    //         }
    //     });
    //     $A.enqueueAction(action);
    // }
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
    /**
     * @description 소모품 알림(알림톡, SMS) 재전송
     * @param component
     * author 23.02.02 / I2MAX.SEUNGHUNAN
     */
    resend : function(component, resendType) {
        // this.LightningConfirm.open({
        //     message: '결제 URL 전송하시겠습니까?',
        //     theme: 'shade',
        //     label: '결제 URL 전송 확인',
        // }).then(function(result) {
        //     if (result == false) {
        //         return;
        //     }
        // });
        var action = component.get('c.doResend');
        var exObjId = component.get('v.exObjId');
        action.setParams({
            'exObjId' : exObjId,
            'resendType' : resendType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var resultWrapper = result['resultWrapper'];
                var notiType = result['notiType'];

                if (resultWrapper == null || resultWrapper == undefined) {
                    this.showToast('error', notiType + ' 전송 실패');
                }
                else if (resultWrapper.isSuccess == true && resultWrapper.result == 'success') {
                    this.showToast('success', notiType + '을(를) 전송하였습니다.');
                }
                else if (resultWrapper.isSuccess == false && resultWrapper.result == 'error') {
                    this.showToast('error', notiType + ' 전송 실패 :: ' + resultWrapper.errorMsg);
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * @description 소모품 알림(알림톡, SMS) 재전송 전 소모품 임시 메시지 Object 저장
     * @param component, selectedRows
     * author 23.02.04 / I2MAX.SEUNGHUNAN
     */
    saveTmpMessageObj : function(component, selectedRows, resendType) {
        var action = component.get('c.doSaveTmpExMessageObj');
        var dialog = component.find('dialog');
        action.setParams({
            'jsonString' : JSON.stringify(selectedRows[0]),
            'resendType' : resendType
        });

        // 소모품 임시 메시지 Object 최신화 전 알림톡 발신 방지
        dialog.set('v.showSpinner', true);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.exObjId', returnValue);
                dialog.set('v.showSpinner', false);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
                component.set('v.exObjId', null);
                dialog.set('v.showSpinner', false);
                dialog.set('v.isOpen', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    // 23.09.07 PHJ 위즈모 전환
    // sortData: function (cmp, fieldName, sortDirection) {
    //     var data = cmp.get("v.data");
    //     var reverse = sortDirection !== 'asc';
    //     data.sort(this.sortBy(fieldName, reverse))
    //     cmp.set("v.data", data);
    // },

    // 23.09.07 PHJ 위즈모 전환
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
    // 23.09.07 PHJ 위즈모 전환
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
    sendMessage: function(component, msg) {
        console.log('위즈모');

        console.log('msg -> ' + msg);
        
        component.find('wijmo_EXConsumableOrderList').message(msg);
    },
    fnWijmoSeleceted: function (component, event, helper) {
        console.log('### row fnSeleceted ###');

        var row = component.get('v.selectedRowsFromWijmo');
        console.log(row);
        console.log(JSON.stringify(row));

        if (JSON.stringify(row) == '[]') {
            return;
        }

        component.set('v.objSelected',row);
//        component.set('v.channel', row[0].OrderChannel);
        component.set('v.orderNumber', row[0].OrderNumber);
        component.set('v.orderStatus', row[0].OrderStatus);


        ////23.04.13 contact 추가 위치 조정
        component.set('v.contactId',row[0].contactId );
        // setTimeout(() => {
            
        // },1000);
        var evt = $A.get("e.c:EX_ConsumableOrderList_evt");
        var caseId = row[0].CaseId;
        var caseDescription = row[0].CaseDescription;
        var orderNumber = row[0].OrderNumber;

        console.log('orderList case Id : ' + caseId);
        console.log('caseId == null : ' + (caseId == null));
        console.log('caseId != null : ' + (caseId != null));
        console.log('selected : ' +JSON.stringify(row));
        component.set('v.orderData',row);
        evt.setParam("contactId", row[0].contactId );
        evt.setParam("caseId", caseId);
        evt.setParam("caseDescription", caseDescription);
        evt.setParam("data", row);
        evt.setParam("orderNumber", orderNumber);
        console.log('fire!!!!!!!!!!!!');
        component.set('v.showSpinner',false);
        evt.fire();
    },

    fnDownloadExcel : function(component, event, helper) {
        var data = component.get('v.data');
        var msg = {type:'downloadExcel', items: data}
        console.log('fnDownloadExcel msg -> ' + msg);
        component.find('wijmo_EXConsumableOrderList').message(msg);
    },
    
    //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)
    isSpecificationValid : function(component, orderNumber) {
        console.log('HELPER.isSpecificationValid !!');

        var action = component.get("c.isSpecificationValid");

        action.setParams({
            'orderNumber' : orderNumber
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.isSpecificationValid', returnValue);
                console.log('returnValue isSpecificationValid !! : '+returnValue);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fnCustomerUrl: function (component, event, helper, item) {

        var url = item.CaseURL;
        console.log('url : '+url);
        var workspaceAPI = component.find("workspace");
        var preTabIdx = null;

        workspaceAPI.getEnclosingTabId().then(function (response) {
            preTabIdx = response;
            const urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": url,
                "target": '_self'
            });
            urlEvent.fire();
        }).catch(function (error) {
            console.log("customer search Error :" + JSON.stringify(error));
        });
    },
    // 영수증 관련 팝업창 
    openScriptFormPop: function (component, selectedRow, pdfType) {
        var strModalName = "영수증";
        console.log('pdfType!!!!!::: ',pdfType);
        console.log('selectedRow[0].Id ::: ',selectedRow[0].Id);
        $A.createComponent(
            "c:EX_receiptFormPop",
            {
                "sHeader": strModalName,
                "productRequestId": selectedRow[0].Id,
                "OrderChannel": selectedRow[0].OrderChannel,
                "pdfType": pdfType,
                "popWidth": "width: 12px"
            },
            function (cCommonConfirm, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log('openScriptFormPop >> ');
                    // callback action
                    component.set("v.modalContent", cCommonConfirm);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },
    //23 08 30 hyungho.chun 콜센터직원경우 true
    getUserProfile: function (component) {
        
        var returnBoolean = false;
        setTimeout(() => {
            var action = component.get('c.getUserProfile');
            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    console.log('콜센터직원체크 success');
                    console.log('result ::',result);
                    returnBoolean = result;
                    component.set('v.isCenterUser', result);
                }
            });
            $A.enqueueAction(action);

        }, 3);
        console.log('returnBoolean ::: ',returnBoolean);
        return returnBoolean;
    },
    
    //23 08 31 hyungho.chun 판매정보있는경우 true
    checkSrSale: function (component, prId) {
        
        // var returnBoolean = false;
        
        var action = component.get('c.checkSrSale');
        console.log ('prId :: ',prId);
        action.setParams({
            'prId' : prId
        });
        setTimeout(() => {
            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                console.log('state :: ',state);
                if (state === "SUCCESS") {
                    console.log('판매정보여부체크 success');
                    console.log('result ::222',result);
                    // returnBoolean = result;
                    component.set('v.isSrSaleOn',result);
                }
            });
            $A.enqueueAction(action);
        }, 3);
        // console.log('returnBoolean :::222 ',returnBoolean);

        // return returnBoolean;
    


        
    },     


});