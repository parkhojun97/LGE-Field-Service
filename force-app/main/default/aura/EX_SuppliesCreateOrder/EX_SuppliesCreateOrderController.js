/**
 * Created by I2MAX.SEOKHOLEE on 2022/12/25.
 */

({

    fnInit: function (component, event, helper) {
        console.log('createOrder Modal Init ');
        // var isRePay = component.get('v.isRePay');
        var isManagement = component.get('v.isManagement');
        // isManagement는 품절주문과, 일반주문이 존재하는데 품절주문일 경우 standard도 같이 채워줘야 함
        var standardOrderData = component.get('v.standardOrderData');
        var soldOutOrderData = component.get('v.soldOutOrderData');
        console.log('soldOutOrderData123 :: ',soldOutOrderData);

        // 품절주문만 존재할 경우
        if (isManagement && standardOrderData.length === 0) {
            component.set('v.standardOrderData', soldOutOrderData);
            console.log('only soldOutData');
        }

        console.log('>>> EX_SuppliesCreateOrder Init start <<< ');
        console.log('item : ' + JSON.stringify(component.get('v.standardOrderData')));
        console.log('stdConsumableOrderId >>> ' + component.get('v.stdConsumableOrderId'));
        console.log('soldOutConsumableOrderId >>> ' + component.get('v.soldOutConsumableOrderId'));
        console.log('poId >>> ' + component.get('v.poId'));
        console.log('strCaseId co >>> ' + component.get('v.strCaseId'));
        console.log('strCaseId coobj >>> ' + JSON.stringify(component.get('v.objCont')));
        if (component.get('v.strCaseId') != '' || component.get('v.strCaseId') != null || component.get('v.strCaseId') != undefined) {
            helper.fnConInfoByCase(component, event, helper);
        }

        if(component.get('v.isOrderChange') == true){
        helper.gfnShowToast('warning','재고가 소진되어 일반주문이 품절로 변경되었습니다.');
        }
        
        // 2023.09.06 seung yoon heo helper 묶음
        // helper.fnGetOrderInfo(component, event, helper);
        // helper.fnGetEmpInfo(component, event, helper);
        // helper.fnGetContactInfo(component, event, helper);
        // helper.fngetServiceResource(component, event, helper);

        helper.fnCreateOrderInfo(component, event, helper);

        
        setTimeout(function () {
            helper.fnSetOrderData(component, event, helper);
            helper.fnSetWijmo(component, event, helper);
        }, 2000);
        setTimeout(function () {
            component.set('v.showSpinner', false);
        }, 3500);

    },

    fnBack: function (component, event, helper) {
        component.set('v.isPaymentMode', false);
    },
    fnLatePayment: function (component, event, helper) {
        component.set('v.latePayment', !component.get('v.latePayment'));
        if (component.get('v.latePayment')) {
            component.set('v.IsPrint', true);
            component.set('v.IsBefore', true);
        } else {
            component.set('v.IsPrint', false);
            component.set('v.IsBefore', false);

        }

        if (component.get('v.latePayment') == false) {
            component.set('v.IsOrderCreation', false);
            component.set('v.OrderTotalPaymentAmount', 0);
            component.set('v.Point', 0);
            component.set('v.Card', 0);
            component.set('v.Cash', 0);
            component.set('v.soldOutOrderTotalSalesCount', 0);
            component.set('v.soldOutOrderTotalSalesAmount', 0);
            component.set('v.soldOutOrderTotalDiscountAmount', 0);
            component.set('v.soldOutOrderTotalPointAmount', 0);
            component.set('v.soldOutOrderTotalPaymentAmount', 0);
        }
        helper.fnSetOrderData(component, event, helper);


    },

    fnSave: function (component, event, helper) {

        helper.fndoSave(component, event, helper);

    },

    //24 01 05 hyungho.chun 특별vip회원으로 결제금액0인데 할인금액100%로 오는경우
    fnSaveFullDiscount: function (component, event, helper) {
        var standardOrderDataList = component.get('v.standardOrderData');
        component.set('v.showSpinner',true);
        helper.fndoSave(component, event, helper, standardOrderDataList);

    },    

    changePaymentMethod: function (component, event, helper) {
        component.set('v.selectedPaymentAmount', 0);
    },

    applyPayment: function (component, event, helper) {
//            helper.fnSetOrderData(component, event, helper);
        helper.gfnShowToast('success','주문을 생성중입니다');
        helper.fnGetPaymentAmount(component, event, helper); //옮겨야됨
//            helper.fndoSave(component, event, helper);

    },

    changeOrderData: function (component, event, helper) {
        helper.sendMessageStd(component, {type:'items', items: event.getParam('standardOrderData')});
        helper.sendMessageSold(component, {type:'items', items: event.getParam('soldOutOrderData')});
    },

    /**
     * 소모품 주문 Cancel 시 임시 저장 되어 있던 데이터 삭제.
     * @param component
     * @param event
     * @param helper
     */
    fnCancel: function (component, event, helper) {
        component.set('v.showSpinner',false);
        component.destroy();
    },
    // 24 01 02 PHJ
    fnCancel2: function (component, event, helper) {
        if(event.getParam('cancelModal')) component.set('v.isXSmall', true);
        else component.set('v.isXSmall', false);
    },
    fnDialogCancel: function (component, event, helper) {
        if(component.get('v.isOpen') == false){
            component.destroy();
        }

    },
    handleShowActiveSectionName: function (component) {
        if (component.find("accordion").get('v.activeSectionName') == '[]')
            component.find("accordion").set('v.activeSectionName', 'B');
        else {
            component.find("accordion").set('v.activeSectionName', '[]');

        }
    },
    handleCompleted: function (component, event, helper) {
        const name = event.getParam('name');
        const detail = event.getParam('detail');
        var contactId = component.get('v.contactId');

        console.log(name, JSON.stringify(detail));
        $A.get('e.force:closeQuickAction').fire();
    },
    fnPayment: function (component, event, helper) {
        console.log(component.get('v.stdOrderTotalSalesAmount'));
        component.set('v.showSpinner', true);
        if (component.get('v.OrderTotalSalesAmount') != 0) {
            console.log('JSON.stringify(standardOrderData) : ' + JSON.stringify(component.get('v.standardOrderData')));
            console.log(component.get('v.prId'));
            console.log(component.get('v.contactId'));
            console.log('component.get()  : ' + component.get('v.OrderTotalSalesAmount') + ' zxzx ' + component.get('v.OrderTotalDiscountAmount'));
            var stdList = component.get('v.standardOrderData');
            var goodsName = stdList[0].ProductName;
            var currentDate = '2023-02-21';

            var timezone = $A.get("$Locale.timezone");
            $A.localizationService.getToday(timezone, function(today){
                currentDate = today.toString();
                console.log('today :' +today);
            });
            console.log('dept :'+component.get('v.ContactDept'));
            console.log('xxxxx : ' +component.get('v.prOrderNumber'));

            if (stdList.size >= 2) {
                var listSize = stdList.size - 1;
                goodsName += '외 ' + listSize + ' 건';
            }

            var strCaseId = component.get('v.strCaseId');
            var contactId = component.get('v.contactId');
            var contactData = component.get('v.objCont');
            if (strCaseId) {
                contactId = contactData.Id;
            }

            $A.createComponent(
                "c:EX_Payment",
                {
                    "recordId": component.get('v.prId'),
                    "ContactId": contactId,
                    "DEPT_CODE_ID": component.get('v.ContactDept'),
                    "BIZ_ORIGIN_TYPE": 'C',
                    "BASIS_NO": component.get('v.prOrderNumber') != undefined ? component.get('v.prOrderNumber') : component.get('v.prSoldOutOrderNumber'),
                    "BASIS_DT": currentDate,
                    "SALE_AMT": component.get('v.stdOrderTotalPaymentAmount'),
                    "SETTLE_AMT": component.get('v.stdOrderTotalPaymentAmount'),
                    "GOODS_NAME": goodsName,
                    "GOODS_CNT": "1",
                    "BUNDLE": "true",
                    "onCompleted": component.get('c.handleCompleted'),
                    "CRD_MANUAL_INPUT_YN": 'N',
                    "OrderData": component.get('v.standardOrderData'),
                    "SoldOutOrderData": component.get('v.soldOutOrderData'),
                    "isRePay": true,
                    "objCont": component.get('v.objCont'),
                    "objEmp": component.get('v.objEmp'),
                    "serviceResource": component.get('v.serviceResource'),
                    "prId": component.get('v.prId'),
                    "isManagement": component.get('v.isManagement'),
                },
                function (cmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        console.log('cp: ' + cmp.get('v.isCancelPayment'));
                        component.set("v.modalContent", cmp);
                        component.set('v.showSpinner', false);

                        if (component.get('v.isCancelPayment')) {
                            this.fnCancel(component, event, helper);
                        }
                        // var body = component.get("v.modalContent");
                        // body.push(newComponent);
                        // component.set("v.modalContent", body);
                    } else if (status === "INCOMPLETE") {
                        console.log('No response from server or client is offline.');
                    } else if (status === "ERROR") {
                        console.log('Error :' + errorMessage);
                        component.set('v.showSpinner', false);

                    }
                });
            component.set('v.IsOrderCreation', true);
        } else {
            component.set('v.IsOrderCreation', true);

        }
//                component.set('v.isPaymentMode', true);

    },
    fnQuote: function (component, event, helper) {
        console.log('fnQuote standardOrderData > ', component.get('v.standardOrderData'));
        console.log('component.get(v.discountType)!!! : ' + component.get('v.discountType'));



        const orderNum = component.get('v.standardOrderData') && component.get('v.standardOrderData').length > 0 ? component.get('v.standardOrderData')[0].OrderNumber
            //: component.get('v.soldOutConsumableOrderId') && component.get('v.soldOutConsumableOrderId').length > 0 ? component.get('v.soldOutConsumableOrderId')[0].OrderNumber
            : component.get('v.soldOutOrderData') && component.get('v.soldOutOrderData').length > 0 ? component.get('v.soldOutOrderData')[0].OrderNumber
                : null;
        console.log('orderNum > ', orderNum);
                $A.createComponent(
            "c:EX_SuppliesQuoteList",
            {
                "standardOrderData": component.get('v.standardOrderData'),
                "soldOutOrderData": component.get('v.soldOutOrderData'),
                "contactId": component.get('v.contactId'),
                "objCont": component.get('v.objCont'),
                "stdConsumableOrderId": component.get('v.stdConsumableOrderId'),
                "soldOutConsumableOrderId": component.get('v.soldOutConsumableOrderId'),
                "latePayment": component.get('v.latePayment'),
                "IsPrint": component.get('v.IsPrint'),
                ///23.04.14
                "orderNumber" : orderNum,
                "discountType" : component.get('v.discountType'),
                "listSelectRows" : null,

            },
                function (cmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        console.log('cp: ' + cmp.get('v.isCancelPayment'));
                        component.set("v.modalContent", cmp);
                        component.set('v.showSpinner', false);
                        var container = component.find("slds-backdrop");
                        // 생성된 ChildComponent를 컨테이너에 추가
                        container.set("v.body", [newCmp]);

                        // ChildComponent에 스타일 파일 로드
                        $A.util.addClass(newCmp, "newCmp");
                        if (component.get('v.isCancelPayment')) {
                            this.fnCancel(component, event, helper);
                        }
                        // var body = component.get("v.modalContent");
                        // body.push(newComponent);
                        // component.set("v.modalContent", body);
                    } else if (status === "INCOMPLETE") {
                        console.log('No response from server or client is offline.');
                    } else if (status === "ERROR") {
                        console.log('Error :' + errorMessage);
                        component.set('v.showSpinner', false);

                    }
                });
    },
    dmlBeforeResend : function(component, event, helper) {

            // todo : Multi ProductRequestLine Case
            var resendType = event.getSource().get('v.label');
            var dialog = component.find('dialog');
            console.log('resendType :' +resendType);
            console.log('stdConsumableOrderId :  :' +component.get('v.stdConsumableOrderId'));
            console.log('soldOutConsumableOrderId :  :' +component.get('v.soldOutConsumableOrderId'));
            // var message ='주문생성이 아직 정상적으로 종료되지 않았습니다.\r\n' +
            //              '종료하겠습니까?\r\n\r\n';
            var message ='해당 주문 생성 미완료 건으로 \r\n 취소처리 하시겠습니까?\r\n\r\n';
            // if(component.get('v.prOrderNumber') != null){
            //     message += '일반 주문 : '+ component.get('v.prOrderNumber') +'\r\n';
            // }
            // if(component.get('v.prSoldOutOrderNumber') != null){
            //     message += '품절 주문 : '+ component.get('v.prSoldOutOrderNumber');
            // }
            var isExOrderCreate = true;

            var param = {
                message : message,
                isExOrderCreate : isExOrderCreate
            };

            //23.12.11 gw.lee
            //예약번호로 트리거로 주문 취소 불가 현상 => 컨펌 다이얼로그 time out setting
            component.set('v.showSpinner', true);
            setTimeout(function () {
                component.set('v.showSpinner', false);
                dialog.confirm(param, function(response) {
                    console.log('response :' + response.result);
                    if (response == null || response == undefined) {
                        helper.showToast('error', '사용자 응답 오류');
                        return;
                    }
                    if(response.result == true){
                        // setTimeout(function () {
                        //     helper.fnDeleteOrderInfo(component, event, helper);
                        // },0);
                        //23 10 05 hyungho.chun 스피너추가
                        component.set('v.showSpinner', true);
                        helper.fnDeleteOrderInfo(component, event, helper);
                    }
                }, resendType);
            }, 4000);
            
        },
    fnStdWijmo : function(component, event, helper) {
        if (component.get('v.isManagement')) return;
        var standardOrderData = component.get('v.standardOrderData');
        console.log('일반 변경 :: ' + JSON.stringify(standardOrderData));
        helper.sendMessageStd(component, {type:'items', items: component.get('v.standardOrderData')});
    },
    fnSoldWijmo : function(component, event, helper) {
        // if (!component.get('v.isRePay')) return;
        helper.sendMessageSold(component, {type:'items', items: component.get('v.soldOutOrderData')});
    }
});