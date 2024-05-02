/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-04.
 */

({
    // 레코드 검색 결과 모달
    doOpenModal: function (component) {
        var data = component.get("v.objSelected");
        console.log('data :::::', data);
        this.sendMessage(component, {type: 'items', items: data}, 'wijmo_EXOrderCancel');
    },
    doCloseModal: function (component) {
        //23 12 05 hyungho.chun 주문취소시 계좌검증 화면 데이터 초기화
        component.set('v.receiverName', '');
        component.set('v.bankCode', '');
        component.set('v.bankAccountNo', '');
        
        component.set('v.ShowModal', false);
    },
    doReturnModal: function (component) {
        var data = component.get("v.productRequestLineItemsByReturnRequest");
        var hasPointAmount = component.get('v.hasPointAmount');
        if (!hasPointAmount) {
            this.sendMessage(component, {type: 'items', items: data}, 'wijmo_EXOrderReturn');
        } else {
            this.sendMessage(component, {type: 'items', items: data}, 'wijmo_EXOrderDisabledReturn');
        }
    },
    doOpenModalForCashier: function (component, userPermission) {
        component.set('v.ShowModalForCashier', true);

        // 임시로 System Administrator 일 때만 조회 못하게.

        // 40900 부품담당자 ------> 조회 불가능
        // PGT665 소모품센터 ------> 조회 불가능
        // T82930 상담사 ------> 조회 가능
        // 27479 신사업지원팀 -----> 조회 가능

        // let userInfo = component.get('v.userSessionInfo');
        //
        // console.log('userInfo : ' + JSON.stringify(userInfo, null, 2));

        console.log('component.get(\'v.ServiceResource\') : ' + JSON.stringify(component.get('v.ServiceResource'), null, 2));

        // 자재관리자일경우로 가정. FS에는 serviceResource생성이 안되서 땜빵해놓음 검색된 데이터에서 첫번째 값들어가게
        if (userPermission == true) {
//             component.find('requiredField').reduce(function (init, comp) {
//                 let label = comp.get('v.label');
//                 console.log('label : ' + label);
//                 if (label == '팀명') {
// //                    comp.set('v.disabled', true);
//                     comp.set('v.value', component.get('v.ServiceResource')[0].SM_DEPT__r.fm_HIGH_DEPT_NAME__c)
//                 }
//             }, 1);

//            component.find('centerId').set('v.disabled', true);
            component.find('centerId').set('v.value', component.get('v.ServiceResource')[0].SM_DEPT__r.DEPT_NAME__c);

            component.set('v.mapSearchParam.teamName', component.get('v.ServiceResource')[0].SM_DEPT__r.fm_HIGH_DEPT_NAME__c);
            component.set('v.mapSearchParam.centerName', component.get('v.ServiceResource')[0].SM_DEPT__r.DEPT_NAME__c);
            component.set('v.defaultUserTeamName', component.get('v.ServiceResource')[0].SM_DEPT__r.fm_HIGH_DEPT_NAME__c);
            component.set('v.defaultUserCenterName', component.get('v.ServiceResource')[0].SM_DEPT__r.DEPT_NAME__c);

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
                    component.set('v.mapSettingSelect.listTeam', result.listTeam);
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
        }
        // var evt = $A.get("e.c:EX_Overflow_evt");
        //
        // evt.setParam("CssClass", true);
        // evt.fire();

        // if(username == 'System Administrator1'){
        //     component.find('requiredField').reduce(function (init,comp) {
        //         let label = comp.get('v.label');
        //         console.log('label : ' + label);
        //         if (label == '팀명') {
        //             comp.set('v.disabled', true);
        //         }
        //     },1);
        //
        //     component.find('centerId').set('v.disabled', true);
        // }
    },
    doCloseModalForCashier: function (component) {
        component.set('v.ShowModalForCashier', false);

        // 현금입금대상 조회 데이터값들 리셋
        this.cashierResetData(component);

        // var evt = $A.get("e.c:EX_Overflow_evt");
        //
        // evt.setParam("CssClass", true);
        // evt.fire();

    },
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
    fnDoSearch: function (component, event, helper) {

        component.set('v.showSpinnerForCashier', true);

        // 조회 조건에서 필수로 들어가야할 조건들을 체크1 .
        let requiredField = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            let checkForValid = false;

            console.log('inputCmp.get(\'v.label\') : ' + inputCmp.get('v.label'));
            if (inputCmp.get('v.label') == '팀명') {
                //팀명이 선택이거나 맨처음에 아무것도 선택안했을 때 validation 걸리게 하기
                console.log('inputCmp.get(\'v.value\') : ' + inputCmp.get('v.value'));
                if (inputCmp.get('v.value') == '선택' || inputCmp.get('v.value') == undefined || inputCmp.get('v.value') == null) {
                    checkForValid = false;
                } else {
                    checkForValid = true;
                }
            } else {
                // 필수 입력 에서 아무것도 안햇을경우
                if (inputCmp.get('v.value') == undefined || inputCmp.get('v.value') == null) {
                    checkForValid = false;
                } else {
                    checkForValid = true;
                }
            }
            return validSoFar && checkForValid;
        }, true);

        // 조회 조건에서 필수로 들어가야할 조건들을 체크2 .
        let requiredCheckbox = component.find('requiredCheckbox').reduce(function (validSoFar, inputCmp) {
            return validSoFar || inputCmp.get('v.checked');
        }, false);

        // 조회 기간에서 시작날짜가 끝날짜보다 큰지 아닌지 체크
        let dateValidCheck = false;
        // 조회 기간이 30일이 넘는지 안넘는지 체크
        let dateThirtyDaysCheck = false;

        let initialSDate = component.get('v.mapSearchParam.initialSDate');
        let initialEDate = component.get('v.mapSearchParam.initialEDate');

        let SDate = new Date(initialSDate);
        let EDate = new Date(initialEDate);

        let Difference_In_Time = EDate.getTime() - SDate.getTime();
        let Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);

        // todo 23.04.12 / 테스트 위해서 주석처리
        // if( Difference_In_Days > 30){
        //     // 조회 기간이 30일 넘으면 true 값
        //     dateThirtyDaysCheck = true;
        // }

        if (SDate > EDate) {
            // 조회 기간에서 시작날짜가 끝날짜보다 크면 true 값
            dateValidCheck = true;
        }

        // 첫번째로 시작날짜가 끝날짜 보다 큰지 체크
        if (dateValidCheck) {
            this.showToast('warning', '조회기간 설정이 잘못되었습니다.');
            component.set('v.showSpinnerForCashier', false);
        } else {
            // 조회기간에서 시작날짜가 끝날짜보다 작지만, 필수 입력값이 다 채워지지 않은지 체크
            if (requiredField && requiredCheckbox) {
                // 조회기간에서 시작날짜가 끝날짜보다 작고 필수 입력값이 다 채워졌지만, 조회 기간이 30일 넘는지 체크
                if (dateThirtyDaysCheck) {
                    this.showToast('warning', '조회기간은 최대 30일까지 가능합니다.');
                    component.set('v.showSpinnerForCashier', false);
                } else {
                    // 조회 validation 을 다 거친 후 조회
                    // 해당 조건에 에 맞게 데이터 조회
                    var mapSearchParam = component.get('v.mapSearchParam');

                    if (mapSearchParam.SE == '전체') {
                        mapSearchParam.SE = null;
                    }

                    console.log('mapSearchParam : ' + mapSearchParam);
                    console.log('mapSearchParam : ' + JSON.stringify(mapSearchParam, null, 2));
                    var cashAction = component.get('c.doSearchCashDepositRequests');
                    cashAction.setParams({
                        'mapSearchParam': mapSearchParam
                    });
                    cashAction.setCallback(this, function (response) {
                        console.log('EX_ConsumablesOrderManagementController')
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('doSearchCashDepositRequests');
                            var result = response.getReturnValue();
                            console.log(result);
                            console.log(JSON.stringify(result));
                            console.log(JSON.stringify(result, null, 2));
                            console.log('result : ' + JSON.stringify(result.cashDepositTables, null, 2));

                            // let amount = 0;

                            // result.forEach( function (value) {
                            //     console.log('value : ' + value.DepositAmount);
                            // });

                            let amount = result.cashDepositTables.reduce(function (first, value) {
                                return first + value.DepositAmount;
                            }, 0);

                            component.set('v.cashPaymentAmount', amount.toLocaleString('ko-KR'));

                            component.set('v.objSelectedForCashier', result.cashDepositTables);
                            component.set('v.cashListTotalSize', result.cashDepositTables.length);
                            component.set('v.cashPaymentAmount', result.totalAmount);
                            component.set('v.showSpinnerForCashier', false);
                            var cashdeposititem = component.get('v.objSelectedForCashier');
                            this.handleSendMessage(component, {type: 'items', items: cashdeposititem});

                        } else {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                            } else {
                                this.showToast("error", "Unknown error");
                            }
                            component.set('v.showSpinnerForCashier', false);
                        }
                    });
                    $A.enqueueAction(cashAction);
                }
            } else {
                this.showToast('warning', '선택되지 않은 조회조건이 있습니다.');
                component.set('v.showSpinnerForCashier', false);
            }
        }
    },
    doSendSms: function (component, selectedCashDepositRows) {

        console.log('doSendSmS!!!');
        //console.log('selectedCashDepositRows[0].BankName' + selectedCashDepositRows[0].BankName);

        console.log('JSON.stringify(selectedCashDepositRows[BankName]) >>' + JSON.stringify(selectedCashDepositRows['BankName']));
        var bankName = JSON.stringify(selectedCashDepositRows['BankName']);
        var vbankNum = JSON.stringify(selectedCashDepositRows['VirtualBankNum']);

        // 선택한 레코드가 있는지 없는지 확인.
        console.log('bankName > ' + bankName + ' , vbankNum > ' + vbankNum);
        if (selectedCashDepositRows == undefined || selectedCashDepositRows == null || selectedCashDepositRows.length == 0) {
            this.showToast('warning', '선택된 현금입금대상이 없습니다.');
//        } else if((bankName==undefined || bankName ==null)&&(vbankNum==undefined || vbankNum ==null)){
        } else if (bankName == null || bankName == undefined || vbankNum == null || vbankNum == undefined) {
            console.log('은행과 가상계좌번호 정보가 존재하지 않습니다!!')
            this.showToast('warning', '은행명과 가상계좌번호를 입력해주세요 .');
        } else {
            // 선택된 레코드들을 대상으로 서버단에서 SMS 보내기
            let action = component.get('c.doSendSms');
            action.setParams({
                'selectedCashDepositRows': selectedCashDepositRows
            })
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    console.log('3');
                    //let result = response.getReturnValue();
                    let result = response.getReturnValue();

                    component.set('v.receiverNumber', result['receiverPhone']);
                    console.log('4-1 : ' + selectedCashDepositRows.ConsigneePhoneNum);
                    component.set('v.exObjId', result['exObjId']);
                    console.log('exObjId:' + result['exObjId']);
                    component.set('v.receiverMsg', result['receiverMsg']);
                    console.log('receiverMsg:' + result['receiverMsg']);

                    component.set('v.kakaoModal', true);

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
        }
    },

    // 무조건 null 이 맨뒤로 간다. NULLS LAST
    // sortBy: function (field, reverse, primer) {
    //     var key = primer ?
    //         function(x) {return primer(x[field])} :
    //         function(x) {return x[field]};
    //     reverse = !reverse ? 1 : -1;
    //     return function (a, b) {
    //         a = key(a);
    //         b = key(b);
    //         console.log('a : ' + a);
    //         if (a === undefined || a === null) {
    //             return 1;
    //         }
    //
    //         if (b === undefined || b === null) {
    //             return -1;
    //         }
    //
    //         if (a === b) {
    //             return 0;
    //         }
    //
    //         return reverse * ((a > b) - (b > a));
    //     }
    // },

    // 무조건 null 이 앞으로 온다. NULLS FIRST
    // sortBy: function (field, reverse, primer) {
    //     var key = primer ?
    //         function(x) {return primer(x[field])} :
    //         function(x) {return x[field]};
    //     reverse = !reverse ? 1 : -1;
    //     console.log('reverse : ' + reverse);
    //     return function (a, b) {
    //         a = key(a);
    //         b = key(b);
    //         console.log('a : ' + a);
    //         if (a === undefined || a === null) {
    //             return -1;
    //         }
    //
    //         if (b === undefined || b === null) {
    //             return 1;
    //         }
    //
    //         if (a === b) {
    //             return 0;
    //         }
    //
    //         return reverse * ((a > b) - (b > a));
    //     }
    // },

    // 정방향 일 때는 NULL FIRST, 역방향 일 때는 NULL LAST
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x[field])
            } :
            function (x) {
                return x[field]
            };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            a = key(a);
            b = key(b);
            // console.log('a : ' + a);
            if (reverse === 1) {
                if (a === undefined || a === null) {
                    return -1;
                }

                if (b === undefined || b === null) {
                    return 1;
                }

                if (a === b) {
                    return 0;
                }
            } else if (reverse === -1) {
                if (a === undefined || a === null) {
                    return 1;
                }

                if (b === undefined || b === null) {
                    return -1;
                }

                if (a === b) {
                    return 0;
                }
            }

            return reverse * ((a > b) - (b > a));
        }
    },

    // sortBy: function(field, reverse, primer) {
    //     var key = primer
    //         ? function(x) {
    //             return primer(x[field]);
    //         }
    //         : function(x) {
    //             return x[field];
    //         };
    //
    //     // console.log('key : ' + JSON.stringify(key()));
    //     // console.log('key : ' + key);
    //
    //     return function(a, b) {
    //         a = key(a);
    //         b = key(b);
    //         // return reverse * ((a > b) - (b > a));
    //         return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
    //     };
    // },

    handleSort: function (component, event) {
        var data = component.get('v.objSelectedForCashier');
        // var data = cmp.get("v.mydata");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.objSelectedForCashier", data);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', fieldName);
    },

    // handleSort: function(component, event) {
    //     var sortedBy = event.getParam('fieldName');
    //     var sortDirection = event.getParam('sortDirection');
    //
    //     let DATA = component.get('v.objSelectedForCashier');
    //
    //     var cloneData = DATA.slice(0);
    //     cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
    //
    //     component.set('v.objSelectedForCashier', cloneData);
    //     component.set('v.sortDirection', sortDirection);
    //     component.set('v.sortedBy', sortedBy);
    // },
    validationCheck: function (component, event, helper) {

        var isValid = true;
        var returnRequestItemTable = component.get('v.productRequestLineItemsByReturnRequest');
        
        //24 01 19 hyungho.chun 결제자정보와 수취인정보가 다른경우(체크박스 푼 경우) 수취인정보 다 들어가있는지 확인하는 로직 추가 
        var isSameContactByReturnRequest = component.get('v.isSameContactByReturnRequest');
        if(!isSameContactByReturnRequest){
            var contactConsigneeInfo = component.get('v.contactConsigneeInfo');
            var consigneeName = contactConsigneeInfo.ConsigneeName;
            var phoneCol = contactConsigneeInfo.ConsigneePhone;
            var newAddress = contactConsigneeInfo.ConsigneeAddress;
            var detailAddress = contactConsigneeInfo.ConsigneeDetailAddress;
            if(consigneeName == '' || consigneeName == null || consigneeName == undefined){
                this.showToast('error','수취인의 이름이 없습니다');
                isValid = false;
            }
            // if(phoneCol == 'color:red' ){
            //     this.showToast('error','잘못된 전화번호 형식입니다');
            //     isValid = false;
    
            // }
            if(phoneCol == '' || phoneCol == undefined){
                this.showToast('error','받는 분의 전화번호가 입력되지 않았습니다');
                isValid = false
            }
            if(newAddress  == '' || newAddress == null || newAddress == undefined){
                this.showToast('error','주소가 없습니다');
                isValid = false;
    
            }

            //24.02.02 gw.lee 상세주소 강제 입력
            if (detailAddress  == '' || detailAddress == null || detailAddress == undefined) {
                contactConsigneeInfo.ConsigneeDetailAddress = '( )';

                component.set('v.contactConsigneeInfo', contactConsigneeInfo);
            }
            //24 01 19 hyungho.chun 상세주소는 임시로 제외
        //    if(detailAddress  == '' || detailAddress == null || detailAddress == undefined){
        //        this.showToast('error','상세주소가 없습니다');
        //        isValid = false;
    
        //    }     
        }        
        

        returnRequestItemTable.forEach((item) => {
            if (item.RequestedReturnQuantity < 0) {
                helper.showToast('error', '요청 수량을 확인해주세요.');

                isValid = false;
                return;
            }


            if (item.SalesQuantity < item.RequestedReturnQuantity) {

                helper.showToast('error', '반품요청 수량이 주문수량보다 많습니다.');

                isValid = false;
                return;
            }

            if (!Number.isInteger(item.RequestedReturnQuantity)) {
                helper.showToast('error', '정수(숫자) 외에 수량지정 주문이 불가능합니다.');

                isValid = false;
                return;
            }
        });

        var isVBANKRefund = component.get('v.isVBANKRefund'); // 가상계좌환불정보 미출력 여부
        var isValidBankAccount = component.get('v.isValidBankAccount'); //계좌검증 성공 여부

        if (!isVBANKRefund) { //가상계좌환불정보 미출력 여부
            if (!isValidBankAccount) { //계좌검증 성공 여부
                helper.showToast('error', '계좌검증을 먼저 실행해 주세요.');

                isValid = false;
            }
        }

        return isValid;
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

    // 현금입금대상 조회 데이터 리셋
    cashierResetData: function (component) {
        component.set('v.mapSearchParam.teamName', '선택');
        component.set('v.mapSearchParam.centerName', '전체');
        component.set('v.mapSearchParam.SE', '전체');
        component.set('v.mapSearchParam.payment', null);
        component.set('v.mapSearchParam.orderNo', null);
        component.set('v.mapSearchParam.DepositY', false);
        // component.set('v.mapSearchParam.DepositN', false);
        //23 07 21 hyungho.chun 현금입금대상모달 닫았다가 열어도 미입금체크는 유지
        component.set('v.mapSearchParam.DepositN', true);
        component.set('v.mapSearchParam.DepositNone', false);

        component.set('v.objSelectedForCashier', null);
        component.set('v.cashListTotalSize', 0);
        component.set('v.cashPaymentAmount', 0);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.mapSearchParam.initialSDate', today);
        component.set('v.mapSearchParam.initialEDate', today);
        // let selectedCashDepositColumns = component.get('v.selectedCashDepositColumns');
        component.get('v.selectedCashDepositColumns', [])
    },

    /**
     * @description 소모품 주문관리 반품 모달 Open
     * @param component
     * @param event
     * @author 23.02.13 / I2MAX.SEOKHOLEE
     * @modified 23.07.15 / gw.lee
     */
    // doOpenReturnOrderModal  : function (component, event, helper) {

    //     component.set('v.showSpinner', true);

    //     var objSelected = component.get('v.objSelected')[0];
    //     var orderNumber = objSelected.OrderNumber;
    //     console.log('orderNumber : ' + orderNumber);

    //     var basisOrderNumber = objSelected.BasisOrderNumber;

    //     console.log('basisOrderNumber ? : ' + basisOrderNumber);

    //     var action = component.get('c.doGetOrderLineItemDataByReturnRequest');

    //     action.setParams({
    //         'orderNumber' : basisOrderNumber != null ? basisOrderNumber : orderNumber
    //     })

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();

    //             // 고객정보
    //             component.set('v.contactConsigneeInfo',result['contactConsigneeInfo']);
    //             // 상담이력 정보
    //             if(result['caseInfo'] != null) {
    //                 component.set('v.caseInfo', result['caseInfo']);
    //                 component.set('v.caseDescriptionByReturnRequest', result['caseInfo'].CaseDescription);
    //             }
    //             var productRequestLineItemsByReturnRequest = result['productRequestLineItemsByReturnRequest'];
    //             var listMap = component.get("v.objSelected");
    //             var productRequestLineItems = [];
    //             listMap.forEach(item => {
    //                 productRequestLineItemsByReturnRequest.forEach(prli => {
    //                     if(item.Id == prli.Id) {
    //                         productRequestLineItems.push(prli);
    //                     }
    //                 });
    //             })

    //             productRequestLineItems.forEach((item) => {
    //                 if(component.get('v.hasPointAmount') == false && item.PointAmount != null && item.PointAmount > 0) {
    //                     component.set('v.hasPointAmount', true);
    //                 }
    //                 if(component.get('v.isMig') == false && item.IsMig == true){
    //                     component.set('v.isMig', true);
    //                 }
    //                 if(component.get('v.hasPointAmount') || component.get('v.isMig')) {
    //                     item.RequestedReturnQuantity = item.SalesQuantity;
    //                 }
    //             })

    //             this.fnSetReturnColumns(component);

    //             component.set('v.productRequestLineItemsByReturnRequest', productRequestLineItems);

    //             component.set('v.showSpinner', false);
    //             component.set('v.showReturnOrderModal',true);
    //         } else {
    //             var errors = response.getError();
    //             console.log('### Error: ' + errors[0].message);
    //             component.set('v.showSpinner', false);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    // 반품 수량 validation
    fnChkReturnQuantity: function (objSelected, draftValues) {
        let isValidQuantity = true;
        let totalQty;
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
        return isValidQuantity;
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
        let isVBANKRefund = true; //가상계좌환불정보 미출력 여부
        var isValid = false;


        console.log('return item : ' + JSON.stringify(listMap));

        if (listMap.length > 0) {
            var subNum = '';
            listMap.forEach(item => {
                console.log('consumable item -> ' + item);
                console.log(JSON.stringify(item));
                if (item.OrderChannel != '소모품택배') {
                    isValid = true;
                }
                if (item.ConsumablesBusinessTypeCode != '주문') {
                    isValid = true;
                }
                if (item.OrderStatus != '배송중' && item.OrderStatus != '배송완료' && item.OrderStatus != '배송준비중') {
                    isValid = true;
                }
//                if(item.SalesNumber == null) {
//                    isValid = true;
//                }
                // if(item.PayMethod == '현금' || item.PayMethod == '현금대리입금' || item.PayMethod == '가상계좌'){
                //     isVBANKRefund = false;
                //     component.set("v.isVBANKRefund", isVBANKRefund);
                // }

                // "SalesQuantity":4
                // "ReturnQuantity":0
                // "ExpectedReturnQuantity":2
                if (item.ConsumablesBusinessTypeCode == '주문') {
                    if (parseInt(item.SalesQuantity) <= parseInt(item.ReturnQuantity) + parseInt(item.ExpectedReturnQuantity)) {
                        isValid = true;
                    }
                }
            });
        } else isValid = true;
        console.log('isValid :::: Check :::: ' + isValid);
        //2023-07-07 gw.lee
        //수량 반품 또는 교환 진행중인건 외 추가 Action 불가 로직 추가
        if (!isValid) {

            //현재 선택한 rows
            //var selectedRows = component.get('v.wijmoSelectedRows');
            var selectedRows = component.get('v.objSelected');
            var selectedSubNumbers = [];
            selectedRows.forEach(row => {
                selectedSubNumbers.push(row.SubNumber.split('-')[0].substring(-3));
            });

            console.log('selectedSubNumbers :::: ' + selectedSubNumbers);

            //현재 선택한 row와 관련
            var lineItem = component.get('v.data');
            var checkStatusList = ['상품준비중', '반품요청', '반품예약'];

            lineItem.forEach((v) => {
                console.log('v.SubNubmer :::: ' + v.SubNumber);
                console.log('dd ' + v.SubNumber.split('-')[0].substring(-3));
                if (selectedSubNumbers.includes(v.SubNumber.split('-')[0].substring(4, 1))) {
                    if (checkStatusList.includes(v.OrderStatus)) {
                        isValid = true;

                        return false;
                    }
                }
            });


            // lineItem.forEach((item) => {
            //     if (item.SubNumber.split('-')[0].includes(subNum)) {
            //         if (checkStatusList.includes(item.OrderStatus)) {
            //             isValid = true;   

            //             return false;
            //         }
            //     }
            // });
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
        let selectedMasterData = component.get("v.selectedMasterData");
        let allData = component.get("v.data");
        let resValid = false;

        console.log('selectedMasterData ::  :: ' , JSON.stringify(selectedMasterData));
        console.log('objSelected ::  :: ' , JSON.stringify(objSelected));

        let canceledBefore = component.get('v.orderCancelBeen', true);
        if(objSelected.length <= 0 && canceledBefore){
            return true;
        }

        //20230714 ysh
        var i = 0;
        console.log('allData.length : ' + allData.length);
        if (allData.length > 0) {
            allData.forEach(lineItem => {
                console.log('lineItem.PaymentCompletedDT ::  :: ' ,lineItem.PaymentCompletedDT);
                // if (lineItem.OrderStatus == '결제요청' && (lineItem.PaymentRequestDT == null || lineItem.PaymentRequestDT == undefined)) {
                //2023.09.12 seung yoon heo 결제완료 기준 날짜 PaymentRequestDT > PaymentCompletedDT으로 변경
                if (lineItem.OrderStatus == '결제요청' && (lineItem.PaymentCompletedDT == null || lineItem.PaymentCompletedDT == undefined)) {
                    i++;
                }
            })
            console.log('결제요청인데 일시 없는 품목의 갯수 i : ' + i);
            if (i == allData.length) {
                console.log('주문취소버튼 활성!');
                component.set('v.isCancelForRepay', true);
                return false;
            }
        }

        component.set('v.isCancelForRepay', false);
        // if (selectedMasterData[0].PaymentRequestDT == null || selectedMasterData[0].PaymentMethod == null) {
        //2023.09.12 seung yoon heo 결제완료 기준 날짜 PaymentRequestDT > PaymentCompletedDT으로 변경
        //23 09 21 hyungho.chun OrderStatus 를 먼저체크해서 걸리면 바로 주문취소 활성화기준에 true로 return해버림
        if(selectedMasterData[0].OrderStatus == '결제요청' || selectedMasterData[0].OrderStatus == '결제완료' || selectedMasterData[0].OrderStatus == '상품준비중' || selectedMasterData[0].OrderStatus == '품절예약완료' || selectedMasterData[0].OrderStatus == '배송준비중'){
            if (selectedMasterData[0].PaymentCompletedDT == null || selectedMasterData[0].PaymentMethod == null) {
                let flag = true;
                objSelected.forEach(function (selected) {
                    if (!selected.OrderStatus != "결제요청") {
                        flag = false;
                    }
                });
                if (flag) {
                    return false;
                }
            }
        }else{
            return true;
        }

        if (objSelected.length > 0) {
            console.log('bbbbb' + objSelected[0]);
            console.log('bbbb : ' + JSON.stringify(objSelected[0]));
            console.log('bbbb : ' + JSON.stringify(objSelected));
//            if(objSelected[0].PaymentRequestDT == null){
//                let flag = true;
//                objSelected.forEach(function (selected) {
//                    if (!selected.OrderStatus != "결제요청") {
//                        flag = false;
//                    }
//                });
//                if(flag){
//                    return false;
//                }
//            }
            //주문채널 : CIC택배
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

                console.log('selected :::: ' , selected);

                /*if (selected.OrderStatus == "품절예약완료" && (selected.AppointmentStatus != "요청중" && selected.AppointmentStatus != "입고완료")) {
                    valid2 = false;
                }*/
                //if (!(selected.ConsumablesBusinessTypeCode == "주문" || selected.ConsumablesBusinessTypeCode == "교환주문")) {
                if (!(selected.ConsumablesBusinessTypeCode == "주문")) {
                    valid3 = false;
                }
                if (selected.OrderChannel != "소모품택배") {
                    valid4 = false;
                }
                // if(selected.PayMethod == '현금' || selected.PayMethod == '현금대리입금'  || selected.PayMethod == '가상계좌'){
                //     isVBANKRefund = false;
                //     component.set("v.isVBANKRefund", isVBANKRefund);
                // }
            });
            
            console.log('valid : ' + valid);
            console.log('valid2 : ' + valid2);
            console.log('valid3 : ' + valid3);
            console.log('valid4 : ' + valid4);



            //valid > 결제요청,결제완료,상품준비중, 품절예약완료인 경우 true
            if (valid) {
                //이건 쓰지도 않음 주석되어있음 true고정
                if (!valid2) {
                    resValid = true;
                } else {
                    // 선택된 row의 ConsumablesBusinessTypeCode가 주문일 경우 true
                    if (!valid3) {
                        resValid = true;
                    } else {
                        //OrderChannel이 소모품 택배가 아닐경우 false
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
        console.log('resValid : ' + resValid);

        return resValid;
    },

    /**
     * @description 결제요청 버튼 활성화 Validation
     * 버튼 disabled 속성에 직접 들어가기 때문에 true가 비활성화
     * @param component
     * @param event
     *  활성화 조건 : 1. 소모품 택배 주문이며 품절주문일 경우 모든 품목의 상태가 결제요청, 결제요청일시가 null
     * 활성화 조건 : 2. 소모품 택배 주문이며 일반주문일 경우 모든 품목의 결제요청일시가 null , 약속상태= '입고완료'
     * @author 23.05.05 / I2MAX.JIEUNSONG
     */
    fnRePaymentBtnValid: function (component) {
        var isValid = true;
        //var listMap = component.get("v.objSelected");
        var dataList = component.get("v.data"); //상세 주문내역의 품목
        console.log('dataList :: ' + dataList + ', ' + dataList.length + '건');

        var i = 0;

        //if((dataList.length > 0 )&& (listMap.length > 0)) {
        if (dataList.length > 0) {
            dataList.forEach(lineItem => {
                if (lineItem.OrderType == '품절주문' && (lineItem.OrderStatus == '결제요청' || lineItem.OrderStatus == '품절예약완료') && (lineItem.PaymentRequestDT == null || lineItem.PaymentRequestDT == undefined) && lineItem.AppointmentStatus == '입고완료') {
                    i++;
                } else if (lineItem.OrderType == '일반주문' && lineItem.OrderStatus == '결제요청' && (lineItem.PaymentRequestDT == null || lineItem.PaymentRequestDT == undefined)) {
                    i++;
                }
            })
            console.log('조건에 충족하는 품목의 갯수 i : ' + i);
            if (i == dataList.length) {
                isValid = false;
            }

        } else {
            isValid = true;
        }

        return isValid;

    },

    doCloseReturnOrderModal: function (component) {
        component.set('v.isSameReturnRequestReason', true);
        component.set('v.isSameContactByReturnRequest', true);
        component.set('v.showReturnOrderModal', false);
        // PHJ
        component.set('v.receiverName', '');
        component.set('v.bankCode', '');
        component.set('v.bankAccountNo', '');
    },
    /**
     * @description 소모품 주문관리 반품 컬럼 초기화
     * @param component
     * @param event
     * @author 23.02.14 / I2MAX.SEOKHOLEE
     */
    fnSetReturnColumns: function (component) {
        // 반품 요청을 수정 할수 있는 경우 / CIC 이고, 포인트 결제를 진행하지 않은 경우
        // 기존 Migration 데이터는 전량 반품만 가능
        var requestedReturnQuantityEditable = !component.get('v.isMig') && component.get('v.isCIC') && !component.get('v.hasPointAmount');

        console.log('CIC => ' + component.get('v.isCIC'));
        console.log('hasPointAmount => ' + component.get('v.hasPointAmount'));
        console.log('isMig => ' + component.get('v.isMig'));
        console.log('requestedReturnQuantityEditable => ' + requestedReturnQuantityEditable);

        let returnOrderColumns = [
            // {label: '번호', fieldName: 'SEQ', type: 'text', initialWidth: 10, hideDefaultActions: true, cellAttributes: {alignment: 'center'}},
            {label: '주문번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '파트넘버', fieldName: 'ReceivedPartNo', type: 'text', initialWidth: 100, hideDefaultActions: true},
            {label: '품명', fieldName: 'PartName', type: 'text', initialWidth: 200, hideDefaultActions: true},
            {label: '소비자가', fieldName: 'CustomerPrice', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '주문수량', fieldName: 'SalesQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '판매금액', fieldName: 'SaleAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},

            {
                label: '반품요청수량',
                fieldName: 'RequestedReturnQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true,
                editable: requestedReturnQuantityEditable,

                cellAttributes: {class: {fieldName: 'ReturnColor'}}

            },
            {
                label: '반품사유',
                fieldName: 'ReturnRequestReason',
                type: 'text',
                initialWidth: 250,
                editable: 'true',
                hideDefaultActions: true,
                cellAttributes: {class: {fieldName: 'ReturnColor'}}
            },
            {
                label: '반품금액',
                fieldName: 'RequestedReturnAmount',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {label: '반품수량', fieldName: 'ReturnQuantity', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {
                label: '반품예정수량',
                fieldName: 'ExpectedReturnQuantity',
                type: 'number',
                initialWidth: 100,
                hideDefaultActions: true
            },
            {label: '할인금액', fieldName: 'DiscountAmount', type: 'number', initialWidth: 100, hideDefaultActions: true},
            {label: '결제금액', fieldName: 'PaymentAmount', type: 'number', initialWidth: 100, hideDefaultActions: true}
            // {label: '결제방식', fieldName: 'PayMethod', type: 'text', initialWidth: 150, hideDefaultActions: true},

            // iconName: 'utility:edit'
        ];

        component.set('v.returnOrderColumns', returnOrderColumns);
    },

    /**
     *
     * @param component
     */
    fnSetDeliveryInformationColumns: function (component, recordId) {
        console.log('Start====================');
        console.log(component.get('v.isCIC'));


        console.log('End====================');
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
        console.log('타입은2 ' + typeof recordId);

        var action = component.get('c.getProliDeliveryNoListwithId');
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


//        let deliveryInformation  = [
//            {
//                "OrderChannel" : "CIC",
//                "OrderNumber" : "O100001147",
//                "OrderSeq": "001",
//                "TrackingNumber": "569339677336",
//                "DeliveryCompany" : "CJ대한통운",
//                "TrackingNumberURL": "http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=569339677336"
//            },
//            {
//                "OrderChannel" : "CIC",
//                "OrderNumber" : "O100001147",
//                "OrderSeq": "001",
//                "TrackingNumber": "569339677337",
//                "DeliveryCompany" : "CJ대한통운",
//                "TrackingNumberURL": "http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=569339677336"
//            }
//        ];


    },

    /**
     * @description 소모품 알림(알림톡, SMS) 재전송 전 소모품 임시 메시지 Object 저장
     * @param component, selectedRows
     * author 23.02.04 / I2MAX.SEUNGHUNAN
     */
    saveTmpMessageObj: function (component, selectedRows, resendType) {
        var action = component.get('c.doSaveTmpExMessageObj');
        var dialog = component.find('dialog');
        action.setParams({
            'jsonString': JSON.stringify(selectedRows[0]),
            'resendType': resendType
        });

        // 소모품 임시 메시지 Object 최신화 전 알림톡 발신 방지
        dialog.set('v.showSpinner', true);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set('v.exObjId', returnValue);
                dialog.set('v.showSpinner', false);
            } else if (state === 'ERROR') {
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

    /**
     * @description 소모품 알림(알림톡, SMS) 재전송
     * @param component
     * author 23.02.02 / I2MAX.SEUNGHUNAN
     */
    resend: function (component, selectedRows, resendType) {
        // this.LightningConfirm.open({
        //     message: '결제 URL 전송하시겠습니까?',
        //     theme: 'shade',
        //     label: '결제 URL 전송 확인',
        // }).then(function(result) {
        //     if (result == false) {
        //         return;
        //     }
        // });/////
        var action = component.get('c.doResend');
        var exObjId = component.get('v.exObjId');
        action.setParams({
            'exObjId': exObjId,
            'resendType': resendType,
            'jsonString': JSON.stringify(selectedRows[0])
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var resultWrapper = result['resultWrapper'];
                var notiType = result['notiType'];
                console.log(JSON.stringify(result));
                console.log('rw :: ' + JSON.stringify(resultWrapper));
                console.log('nt :: ' + JSON.stringify(notiType));

                if (resultWrapper == null || resultWrapper == undefined) {
                    this.showToast('error', notiType + ' 전송 실패');
                } else if (resultWrapper.isSuccess == true && resultWrapper.result == 'success') {
                    this.showToast('success', notiType + '을(를) 전송하였습니다.');
                } else if (resultWrapper.isSuccess == false && resultWrapper.result == 'error') {
                    this.showToast('error', notiType + ' 전송 실패 :: ' + resultWrapper.errorMsg);
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    console.log("error : " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    /*전화번호 형식 변경*/
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

            //23.11.21 PHJ modify '010'이 들어가지 않으면 "####-###-####" 형식으로 변환
            case '11' :
                if(strTel.includes('010')){
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 4);
                    strSetValue += '-' + strTel.substr(7); //"###-####-####";
                } else {
                    strSetValue = strTel.substr(0, 4);
                    strSetValue += '-' + strTel.substr(4, 3);
                    strSetValue += '-' + strTel.substr(7); //"####-###-####";
                }
                break;
            //23.11.21 PHJ modify 12자리이면 "####-####-####" 형식으로 변환
            case '12':
                // strSetValue = strTel.substr(0, 3);
                // strSetValue += '-' + strTel.substr(3, 4);
                // strSetValue += '-' + strTel.substr(7, 4);
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4, 4);
                strSetValue += '-' + strTel.substr(8, 4);
                break;


            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },

    /**
     * @description 결제요청, 재전송 버튼들 disabled 상태로 초기화
     * @param component, event, helper
     * author 23.02.26 / I2MAX.SEUNGHUNAN
     */
    fnBtnsInit: function (component) {
        component.set('v.rePaymentBtnDisabled', true);
        component.set('v.paymentURLBtnDisabled', true);
        component.set('v.virtualAcctBtnDisabled', true);
        component.set('v.SMSBtnDisabled', true);
    },

    fnGetOrderLineItemData: function (component, event, helper) {
        console.log('fnGetOrderLineItemData');
        component.set('v.data', []);

        // 초기화
        component.set('v.showSpinner', true);
        component.set('v.selectedRows', []);
        component.set('v.isMig', false);
        component.set('v.hasPointAmount', false);
        component.set("v.isVBANKRefund", true);
        ///////////////////////////////////////////////////////
        var selectedRows = [];
        var recordId;
        var isEvt = component.get('v.isEvt');
        console.log('isEvt => ' + isEvt);
        if (isEvt) {
            selectedRows = event.getParam('data');
            recordId = selectedRows[0].Id;
            component.set('v.selectedMasterDataForCustPhone', selectedRows);
        } else {
            console.log('결제요청 결제완료시');
            selectedRows = component.get('v.objSelected');
            console.log('applyPayment selected Rows :: ' + JSON.stringify(selectedRows));
            console.log('objSelected');
            console.log('objSelected' + selectedRows[0]);
            console.log(JSON.stringify(component.get('v.objSelected')));
            console.log('data');
            console.log(JSON.stringify(component.get('v.data')));
            recordId = selectedRows[0].ParentId;
        }

        console.log('결제요청 결제완료시2');
        var caseId = event.getParam('caseId');
        var caseDescription = event.getParam('caseDescription') == null ? event.getParam('caseDescription') : (event.getParam('caseDescription')).replace('null',''); //23.09.26 PHJ Case description 해결되면 replace 삭제

        component.set('v.contactId', event.getParam('contactId'));

        component.set('v.selectedMasterData', selectedRows);

        console.log('결제요청 결제완료시3');
        var isVBANKRefund = true;

        if (selectedRows[0].OrderChannel == '소모품택배') {
            component.set('v.isCIC', true);
        } else {
            component.set('v.isCIC', false);
        }

        console.log('결제요청 결제완료시4');
        if (selectedRows[0].PaymentMethod == '현금' || selectedRows[0].PaymentMethod == '현금입금' || selectedRows[0].PaymentMethod == '가상계좌') {
            //console.log('isVBANKRefund -> ' + isVBANKRefund);
            if (selectedRows[0].OrderStatus == '결제요청') {
                isVBANKRefund = true;
            } else {
                isVBANKRefund = false;
            }
            component.set("v.isVBANKRefund", isVBANKRefund);
        }
        console.log('결제요청 결제완료시5');
        // LineItem 조회 시 버튼 초기화
        // todo: 조회 버튼 클릭시에도 초기화 해야함
        component.set('v.rePaymentBtnDisabled', true);
        component.set('v.virtualAcctBtnDisabled', true);
        component.set('v.paymentURLBtnDisabled', true);
        component.set('v.SMSBtnDisabled', true);

        console.log('결제요청 결제완료시6');
        // 주문취소, 반품요청 초기화
        component.set('v.orderCancelBtnDisabled', true);
        console.log('주문취소버튼비활성화5');
        component.set('v.returnRequestBtnDisabled', true);

        var selectPr = selectedRows[0];
        var paymentMethod = selectPr.PaymentMethod;
        var orderStatus = selectPr.OrderStatus;
        var appointmentStatus = selectPr.AppointmentStatus;
        var orderChannel = selectPr.OrderChannel;
        var paymentType = selectPr.PaymentType;
        var paymentRequestDT = selectPr.PaymentRequestDT;
        var MOID = selectPr.MOID;
        console.log('selectPr : ' + selectPr);


        // 결제요청 버튼 활성화 여부
        // 04.26 추가 ) 결제요청상태인데 결제전송일시가 없을때도 결제요청 활성화
//        if ((orderStatus == '품절예약완료' && appointmentStatus == '입고완료') || (orderStatus == '결제요청' && (paymentRequestDT ==null||paymentRequestDT ==undefined))) {
//            console.log( '결제요청 버튼 활성화 !');
//            component.set('v.rePaymentBtnDisabled', false);
//        }

        console.log('결제요청 결제완료시6');

        var action = component.get('c.doGetOrderLineItemData');
        action.setParams({
            'recordId': recordId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('결제요청 결제완료시7');
                var result = response.getReturnValue();
                var productRequestLineItems = result['productRequestLineItems'];
                var orderStatusValid = false;

                console.log('결제요청 결제완료시8');
                component.set('v.data', productRequestLineItems);
                component.set('v.caseId', caseId);
                component.set('v.caseDescription', caseDescription);
                component.set('v.objSelected', []);
                //
                // todo: productRequestLineItem 가지고 재전송 버튼 enabled / disabled
                // detaillist의 datatable의 fnselected에서 재전송 조작은 제거해야함
                for (var idx in productRequestLineItems) {
                    if (productRequestLineItems[idx].OrderStatus == '결제요청') {
                        orderStatusValid = true;
                    }
                }
                console.log('결제요청 결제완료시9');
                if (orderChannel == '소모품택배' && orderStatusValid) {
                    component.set('v.isExistBeforePay', true); // 결제요청 상태 여부
                    switch (paymentType) {
                        case 'VBANK':
                            component.set('v.virtualAcctBtnDisabled', false);
                            if (MOID == null) {
                                component.set('v.virtualAcctBtnDisabled', true);
                            }
                            component.set('v.paymentURLBtnDisabled', true);
                            component.set('v.SMSBtnDisabled', true);
                            break;
                        case 'CASH':
                            component.set('v.virtualAcctBtnDisabled', true);
                            component.set('v.paymentURLBtnDisabled', true);
                            component.set('v.SMSBtnDisabled', true);
                            break;
                        case 'URL':
                            component.set('v.virtualAcctBtnDisabled', true);
                            component.set('v.paymentURLBtnDisabled', false);
                            component.set('v.SMSBtnDisabled', false);
                            break;
                    }
                    console.log('결제요청 결제완료시10');
                } else {
                    component.set('v.isExistBeforePay', false); // 결제요청 상태 여부
                }
            } else {
                console.log('결제요청 결제완료시11');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            console.log('결제요청 결제완료시12');
            //20230703 ysh
            component.set('v.rePaymentBtnDisabled', this.fnRePaymentBtnValid(component)); //결제요청
            //20230714
            component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component)); //주문취소

            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);

        /*
            23.01.20 / I2MAX.SanghunYeo
            로직변경 (DB조회 -> 기존데이터에서 출력)
        */
        /*let dummyData = component.get("v.dummyData");
        if(dummyData.length > 0){
            let productRequestLineItems = [];
            dummyData.forEach(function(dummy){
                if(recordId == dummy.ParentId){
                    productRequestLineItems.push(dummy);
                }
            });
            component.set('v.data', productRequestLineItems);
        }
        component.set('v.showSpinner', false);*/

        /*
            23.02.02 / I2MAX.DHKim
            재결재 유저 정보
         */

        // component.find('rePaymentBtn').set('v.disabled', true);
        //component.find('refundBtn').set('v.disabled', true);

        // 결제요청, 재전송 버튼들 초기화
        // helper.fnBtnsInit(component);

        console.log('selectedData : ' + JSON.stringify(selectedRows, null, 2));

        console.log('결제요청 결제완료시13');
        let depositedDate = selectedRows[0].OrderDate;

        let depositedYear = depositedDate.substring(0, 4);
        let depositedMonth = depositedDate.substring(5, 7);
        let depositedDay = depositedDate.substring(8, 10);

        let formatDate = depositedYear + depositedMonth + depositedDay;

        console.log('결제요청 결제완료시14');
        component.set('v.rePaymentUserInfo.OrderNum', selectedRows[0].OrderNumber);
        component.set('v.rePaymentUserInfo.DepositedName', selectedRows[0].CustomerName);
        component.set('v.rePaymentUser₩Info.DepositedDueDay', formatDate);
        component.set('v.rePaymentUserInfo.CustomerPhone', selectedRows[0].CustomerPhone);

        console.log('결제요청 결제완료시15');
    },
    fngetServiceResource: function (component, event, helper) {
        var contactId = component.get('v.contactId');

        var action = component.get('c.doGetServiceResource');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result >>> ' + result);
                if (result != null)
                    component.set('v.serviceResource', result);


            } else {
                console.log(response.getError());
                component.set('v.showSpinner', false);

            }

            component.set('v.showSpinner', false);

        });
        $A.enqueueAction(action);
    },

    fnGetManagementData: function (component, event, helper) {
        console.log('manage ');
        var action = component.get('c.doGetManagementData');
        var isRePay = component.get('v.isRePay');
        if (isRePay) {
            console.log('isRePay :: ');
            component.set('v.objSelected', component.get('v.data'));
        }
        console.log('objSelected :: ' + JSON.stringify(component.get('v.objSelected')));
        console.log('Data :: ' + JSON.stringify(component.get('v.data')));
        var params = {
            'standardOrderData': JSON.stringify(component.get('v.objSelected')),
        };
        action.setParams({
            'paramMap': params
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var standardOrderData = [];
            var soldOutOrderData = [];
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('wmwmwm >>> ' + JSON.stringify(result));
                console.log('data ::: ' + JSON.stringify(component.get('v.data')));
                if (result != null) {

                    result.forEach(function(item) {
                        if (item.orderType == 'Sold Out') {
                            soldOutOrderData.push(item);
                        }
                        else {
                            standardOrderData.push(item);
                        }
                    });
                    // var data = component.get('v.data');
                    // data.forEach(function(item) {
                    //     if (item.OrderType == '품절주문') {
                    //         soldOutOrderData.push(item);
                    //     }
                    //     else {
                    //         standardOrderData.push(item);
                    //     }
                    // });
                    // data.forEach(item => {
                    //     result.forEach(items => {
                    //         if (items.Id == item.Id) {
                    //             if (item.OrderType == '품절주문') {
                    //                 items.basicOrder = false;
                    //             } else {
                    //                 items.basicOrder = true;
                    //             }
                    //
                    //         }
                    //     });
                    // });
                    console.log('result :::: ' + JSON.stringify(result));
                    // component.set('v.standardOrderData', result);

                    component.set('v.standardOrderData', standardOrderData);
                    component.set('v.soldOutOrderData', soldOutOrderData);

                    this.fnCreateComponent(component, event, helper);
                }
            } else {
                console.log(response.getError());
                component.set('v.showSpinner', false);

            }

            component.set('v.showSpinner', false);

        });
        $A.enqueueAction(action);
    },
    fnCheckToPayment: function (component, event, helper, selectedRows) {
        if (component.get('v.rePaymentBtnDisabled') == false) {
            if (component.get('v.data').length != selectedRows.length) {
                helper.showToast('error', '모든 주문을 선택해주세요');
                return;
            }
        }
        this.fnGetManagementData(component, event, helper);
    },
    fnCreateComponent: function (component, event, helper) {
        let selectedRows = component.get("v.objSelected");
        console.log('aa ' +JSON.stringify(component.get('v.objCont')));
        console.log('aa ' +selectedRows[0]);

        // var sendData = component.get('v.standardOrderData');
        // var isBasic = sendData.basicOrder;

        var soldOutConsumableOrderId = undefined;
        var stdConsumableOrderId = undefined;

        if(selectedRows[0].OrderType =='품절주문'){
            soldOutConsumableOrderId = selectedRows[0].ParentId;
        }
        else {
            stdConsumableOrderId = selectedRows[0].ParentId;
        }
        var id;
        var data;
        // 2024.01.31 seung yoon heo 결제요청시 수취인 로직 추가
        var getConsignee = component.get("v.productRequest");
        var consigneeName = getConsignee.CONSIGNEE_Name__c;
        var IbCallNo = getConsignee.CONSIGNEE_TPNO_1__c;
        var newAddress = getConsignee.CONSIGNEE_Address__c;
        var detailAddress = getConsignee.CONSIGNEE_Address_DETAIL__c;
        var zoneCode = getConsignee.CONSIGNEE_PostalCode__c;

        var ContactVIP = component.get('v.ContactVIP'); //24 02 14 hyungho.chun


        console.log('standardOrderData :: ' + JSON.stringify(component.get('v.standardOrderData')));
        console.log('soldOutOrderData :: ' + JSON.stringify(component.get('v.soldOutOrderData')));
        $A.createComponent(
            "c:EX_SuppliesCreateOrder",
            {
                'standardOrderData': component.get('v.standardOrderData'),
                'soldOutOrderData' : component.get('v.soldOutOrderData'),
                'stdConsumableOrderId': stdConsumableOrderId,
                'soldOutConsumableOrderId': soldOutConsumableOrderId,
                'isContactSame' : false,
                'consigneeName' : consigneeName,
                'IbCallNo' : IbCallNo,
                'newAddress' : newAddress,
                'detailAddress' : detailAddress,
                'zoneCode' : zoneCode,
                'isManagement': true,
                'isTemporary': false,
                'isRePay': true,
                'ContactVIP': ContactVIP, //24 02 14 hyungho.chun
                'contactId': component.get('v.contactId'),
                'objCont': component.get('v.objCont'),
                'serviceResource': component.get('v.serviceResource'),

            },

            function (cmp, status, errorMessage) {
                console.log('modal Open :: ' + status);
                if (status === "SUCCESS") {
                    component.set("v.modalContent", cmp);
                    // var body = component.get("v.modalContent");
                    // body.push(newComponent);
                    // component.set("v.modalContent", body);

                } else if (status === "INCOMPLETE") {
                    console.log('No response from server or client is offline.');
                } else if (status === "ERROR") {
                    console.log('Error :' + errorMessage);
                }
            });
    },
    fnGetContactInfo: function (component, event, helper) {
        var action = component.get('c.fnGetContactInfo');
        console.log('con ' + component.get('v.contactId'));
        action.setParams({
            'contactId': component.get('v.contactId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    // component.set('v.objCont', result);
                    //24 02 14 hyungho.chun apex Controller 리턴 형식 바꾸고 vip할인율도 추가
                    component.set('v.objCont', result.objCon);
                    component.set('v.ContactVIP', result.contactVIP);
                    
                }
            } else {
                console.log(response.getError());
                component.set('v.showSpinner', false);

            }

            component.set('v.showSpinner', false);

        });
        $A.enqueueAction(action);
    },
    sendMessage: function (component, msg, type) {
        console.log('위즈모');
        console.log('msg ::: ' + msg);
        console.log('msg ::: ' + JSON.stringify(msg));
        component.find(type).message(msg);
    },
    sendMessage2: function (component, msg) {
        component.find('wijmo_EXdeliveryInfo').message(msg);
    },
    handleSendMessage: function (component, msg) {
        console.log('위즈모');
        console.log('msg' + msg);
        console.log('msg : ' + JSON.stringify(msg));
        component.find('wijmo_EXCashDeposit').message(msg);
    },
    fnGetWijmoOrderLineItemData: function (component, event, helper) {
        console.log('fnGetWijmoOrderLineItemData');
        component.set('v.data', []);

        // 초기화
        component.set('v.showSpinner', true);
        component.set('v.selectedRows', []);
        component.set('v.isMig', false);
        component.set('v.hasPointAmount', false);
        component.set("v.isVBANKRefund", true);
        ///////////////////////////////////////////////////////
        var selectedRows = [];
        var recordId;
        var isEvt = component.get('v.isEvt');
        console.log('isEvt => ' + isEvt);
        console.log(event.getParam('data'));


//        selectedRows = event.getParam('data');
//        recordId = event.getParam('data')[0].Id;
//        component.set('v.selectedMasterDataForCustPhone', selectedRows);

//        if (isEvt && evt.getParam('data') != undefined) {
        if (isEvt) {
            if (event.getParam('data') != undefined) {
                selectedRows = event.getParam('data');
            } else {
                selectedRows = component.get('v.selectedMasterData');
            }

            recordId = selectedRows[0].Id;
            component.set('v.selectedMasterDataForCustPhone', selectedRows);
        } else {
            selectedRows = component.get('v.objSelected');
            console.log('objSelected');
            console.log(JSON.stringify(component.get('v.objSelected')));
            console.log('data');
            console.log(JSON.stringify(component.get('v.data')));
            recordId = selectedRows[0].ParentId;
        }


        var caseId = event.getParam('caseId');
        var caseDescription = event.getParam('caseDescription') == null ? event.getParam('caseDescription') : (event.getParam('caseDescription')).replace('null',''); //23.09.26 PHJ Case description 해결되면 replace 삭제

        component.set('v.contactId', event.getParam('contactId'));

        console.log('selected Rows : ' + JSON.stringify(selectedRows));
        component.set('v.selectedMasterData', selectedRows);

        var isVBANKRefund = true;

        if (selectedRows[0].OrderChannel == '소모품택배') {
            component.set('v.isCIC', true);
        } else {
            component.set('v.isCIC', false);
        }

        //23 12 01 hyungho.chun 결제URL(가상계좌)건도 환불계좌정보 받아야함 (selectedRows[0].PaymentMethod =='결제URL' && selectedRows[0].PaymentMethodCode =='VBANK') 추가
        if (selectedRows[0].PaymentMethod == '현금' || selectedRows[0].PaymentMethod == '현금입금' || selectedRows[0].PaymentMethod == '가상계좌' || (selectedRows[0].PaymentMethod =='결제URL' && selectedRows[0].PaymentMethodCode =='VBANK')) {
            //console.log('isVBANKRefund -> ' + isVBANKRefund);
            if (selectedRows[0].OrderStatus == '결제요청') {
                isVBANKRefund = true;
            } else {
                isVBANKRefund = false;
            }
            component.set("v.isVBANKRefund", isVBANKRefund);
        }

        // LineItem 조회 시 버튼 초기화
        // todo: 조회 버튼 클릭시에도 초기화 해야함
        component.set('v.rePaymentBtnDisabled', true);
        component.set('v.virtualAcctBtnDisabled', true);
        component.set('v.paymentURLBtnDisabled', true);
        component.set('v.SMSBtnDisabled', true);

        // 주문취소, 반품요청 초기화
        component.set('v.orderCancelBtnDisabled', true);
        console.log('주문취소버튼비활성화6');
        component.set('v.returnRequestBtnDisabled', true);

        var selectPr = selectedRows[0];
        var paymentMethod = selectPr.PaymentMethod;
        var orderStatus = selectPr.OrderStatus;
        var appointmentStatus = selectPr.AppointmentStatus;
        var orderChannel = selectPr.OrderChannel;
        var paymentType = selectPr.PaymentType;
        var paymentRequestDT = selectPr.PaymentRequestDT;
        var MOID = selectPr.MOID;
        var vbankNumOn = false;
        if(selectPr.VbankNum){
            vbankNumOn = true;
        }
        

        console.log('selectPr : ' + JSON.stringify(selectPr));
        console.log('paymentType : ' + paymentType);
        console.log('paymentMethod : ' + paymentMethod);
        console.log('paymentRequestDT : ' + paymentRequestDT);
        console.log('recordId : ' + recordId);

        // 결제요청 버튼 활성화 여부
        // 04.26 추가 ) 결제요청상태인데 결제전송일시가 없을때도 결제요청 활성화
//        if ((orderStatus == '품절예약완료' && appointmentStatus == '입고완료') || (orderStatus == '결제요청' && (paymentRequestDT ==null||paymentRequestDT ==undefined))) {
//            console.log( '결제요청 버튼 활성화 !');
//            component.set('v.rePaymentBtnDisabled', false);
//        }

        console.log('caseId111:' + caseId);
        console.log('caseDescription111:' + caseDescription);

        var action = component.get('c.doGetOrderLineItemData');
        action.setParams({
            'recordId': recordId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var productRequestLineItems = result['productRequestLineItems'];
                var orderStatusValid = false;


                console.log('11111');
                console.log('productRequestLineItems ::::::::::', productRequestLineItems);
                console.log('22222');
                component.set('v.data', productRequestLineItems);
                this.sendMessage(component, {
                    type: 'items',
                    items: component.get('v.data')
                }, 'wijmo_EXConsumableOrderDetailList');

                component.set('v.caseId', caseId);
                component.set('v.caseDescription', caseDescription);
                component.set('v.objSelected', []);

                //
                // todo: productRequestLineItem 가지고 재전송 버튼 enabled / disabled
                // detaillist의 datatable의 fnselected에서 재전송 조작은 제거해야함
                for (var idx in productRequestLineItems) {
                    if (productRequestLineItems[idx].OrderStatus == '결제요청') {
                        orderStatusValid = true;
                    }
                }
                if (orderChannel == '소모품택배' && orderStatusValid) {
                    component.set('v.isExistBeforePay', true); // 결제요청 상태 여부
                    switch (paymentType) {
                        case 'VBANK':
                            component.set('v.virtualAcctBtnDisabled', false);
                            if (MOID == null) {
                                component.set('v.virtualAcctBtnDisabled', true);
                            }
                            component.set('v.paymentURLBtnDisabled', true);
                            component.set('v.SMSBtnDisabled', true);
                            break;
                        case 'CASH':
                            component.set('v.virtualAcctBtnDisabled', true);
                            component.set('v.paymentURLBtnDisabled', true);
                            // component.set('v.SMSBtnDisabled', false);
                            //23 07 21 hyungho.chun 결제방식 현금일시 sms전송버튼 비활성화
                            component.set('v.SMSBtnDisabled', true);
                            break;
                        case 'URL':
                            // component.set('v.virtualAcctBtnDisabled', true);
                            // component.set('v.paymentURLBtnDisabled', false);
                            // component.set('v.SMSBtnDisabled', false);
                            
                            //24 01 10 hyungho.chun url도 가상계좌번호채번시 가상계좌재발송버튼을 활성화시
                            component.set('v.virtualAcctBtnDisabled', !vbankNumOn);
                            component.set('v.paymentURLBtnDisabled', vbankNumOn);
                            component.set('v.SMSBtnDisabled', vbankNumOn);

                            
                            break;
                    }
                } else {
                    component.set('v.isExistBeforePay', false); // 결제요청 상태 여부
                }
                console.log('acv  ' + component.get('v.data'));
                console.log('stringfify acv ::::' + JSON.stringify(component.get('v.data')));

            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set('v.rePaymentBtnDisabled', this.fnRePaymentBtnValid(component));//결제요청
            component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component)); //주문취소
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);

        let depositedDate = selectedRows[0].OrderDate;

        let depositedYear = depositedDate.substring(0, 4);
        let depositedMonth = depositedDate.substring(5, 7);
        let depositedDay = depositedDate.substring(8, 10);

        let formatDate = depositedYear + depositedMonth + depositedDay;

        component.set('v.rePaymentUserInfo.OrderNum', selectedRows[0].OrderNumber);
        component.set('v.rePaymentUserInfo.DepositedName', selectedRows[0].CustomerName);
        component.set('v.rePaymentUserInfo.DepositedDueDay', formatDate);
        component.set('v.rePaymentUserInfo.CustomerPhone', selectedRows[0].CustomerPhone);

        //component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component));

    },
    fnWijmoSelected: function (component, event, helper) {

        //let selectedRows = component.get('v.wijmoSelectedRows');
        let selectedRows = component.get('v.selectedList');
        component.set('v.returnRequestList', selectedRows);

        //결제요청 상태 여부
        let isExistBeforePay = component.get('v.isExistBeforePay');
        console.log('결제요청 상태 여부 : ' + isExistBeforePay);

        console.log('Start====================');
        console.log(selectedRows);
        console.log('End====================');
        // 선택 취소하거나, 선택 후 주문내역 입력할 경우 selectedRows length가 0 이 되었을 때 pass
        if (selectedRows.length == 0 || selectedRows == null || selectedRows == undefined) {
            component.set('v.orderCancelBtnDisabled', true);
            console.log('주문취소버튼비활성화7');
            component.set('v.returnRequestBtnDisabled', true);
            component.set('v.rePaymentBtnDisabled', true);
        } else {
            component.set("v.objSelected", selectedRows);
            component.set("v.userInfoObject", selectedRows);
            component.set('v.channelType', selectedRows[0].OrderChannel);
        }


        console.log('selectedRows:' + JSON.stringify(selectedRows));

        // 반품요청 버튼 Validation
        component.set('v.returnRequestBtnDisabled', this.fnReturnRequestBtnValid(component));

        // 주문취소 버튼 Validation
        component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component));

        // 23.05.05 결제요청 버튼 Validation
        component.set('v.rePaymentBtnDisabled', this.fnRePaymentBtnValid(component));
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
    fnCashWijmoSelected: function (component, event, helper) {

        let selectedRows = component.get('v.closeModalColumnsForCashier');

        //결제요청 상태 여부
        // let isExistBeforePay = component.get('v.isExistBeforePay');
        // console.log('결제요청 상태 여부 : ' + isExistBeforePay);

        console.log('Start====================');
        console.log(selectedRows);
        console.log('End====================');
        // 선택 취소하거나, 선택 후 주문내역 입력할 경우 selectedRows length가 0 이 되었을 때 pass
        // if (selectedRows.length == 0 || selectedRows == null closeModalColumnsForCashier|| selectedRows == undefined) {
        //     component.set('v.orderCancelBtnDisabled', true);
        //     component.set('v.returnRequestBtnDisabled', true);
        //     component.set('v.rePaymentBtnDisabled', true);
        //     //component.set('v.virtualAcctBtnDisabled', true);
        //     //component.set('v.paymentURLBtnDisabled', true);
        //     //component.set('v.SMSBtnDisabled', true);
        //     return;
        // }

        // component.set("v.objSelected", selectedRows);
        // component.set("v.userInfoObject", selectedRows);
        // component.set('v.channelType', selectedRows[0].OrderChannel);

        console.log('selectedRows:' + JSON.stringify(selectedRows));

        // 반품요청 버튼 Validation
        // component.set('v.returnRequestBtnDisabled', this.fnReturnRequestBtnValid(component));

        // 주문취소 버튼 Validation
        // component.set('v.orderCancelBtnDisabled', this.fnOrderCancelBtnValid(component));

        // 23.05.05 결제요청 버튼 Validation
        // component.set('v.rePaymentBtnDisabled', this.fnRePaymentBtnValid(component));

    },
    fnCancelProduct: function (component, event, helper, row) {
        var newData;
        var data = component.get('v.data');
        var total = component.get('v.orderTotal');
        total -= row.Price * row.QTY;
        component.set('v.orderTotal', total);
        var rowIndex = data.findIndex(function (item) {
            return item.Id === row.Id;
        });

        if (rowIndex > -1) {
            data.splice(rowIndex, 1);
            newData = data;
        }
        this.sendMessage(component, {type: 'items', items: newData}, 'wijmo_EXConsumableOrderDetailList');
    },
    fnDownloadExcel: function (component, event, helper) {
        var data = component.get('v.objSelectedForCashier');
        var msg = {type: 'downloadExcel', items: data}
        console.log('fnDownloadExcel msg -> ' + msg);
        component.find('wijmo_EXCashDeposit').message(msg);
    },

    handleWijmoRowAction: function (component, event, helper, row) {
        var recordId = row['Id'];
        component.set('v.showDeliveryInformationModal', true);

        helper.fnSetDeliveryInformationColumns(component, recordId);
    },

    //23 12 26 hyungho.chun 현금입금대상 프로필별 체크
    checkifSVC: function (component, event, helper) {
        
        var action = component.get('c.isSVC');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result >>> ' + result);
                
                component.set('v.isSVC', result);
            } else {
                console.log(response.getError());
                // component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    //24 01 11 hyungho.chun 주문조회 다시하지않고 결제하자마자 취소할경우대비 자체적으로 PR의 정보를 조회해서 받아오는 목적
    findProductRequestitSelf: function (component, event, helper) {
        component.set('v.showSpinner', true);

        var mapSearchParam = {};
        var objSelected = component.get('v.objSelected');

        mapSearchParam['orderNo'] = objSelected[0].OrderNumber;

        console.log('mapSearchParam : '+mapSearchParam);


        var isVBANKRefund = true;

        var action = component.get('c.doGetSearchData');
        action.setParams({
            'mapSearchParam': mapSearchParam
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result.STATUS == 'S') {
                var productRequests = result.productRequests;         

                console.log(productRequests.length);
                if(productRequests.length != 0) {
                    component.set("v.selectedMasterData",productRequests);
                    var temp = component.get('v.selectedMasterData');
                    console.log('selectedMasterData : ', (temp));                        
                        if (productRequests[0].PaymentMethod == '현금' || productRequests[0].PaymentMethod == '현금입금' || productRequests[0].PaymentMethod == '가상계좌' || (productRequests[0].PaymentMethod =='결제URL' && productRequests[0].PaymentMethodCode =='VBANK')) {
                            //console.log('isVBANKRefund -> ' + isVBANKRefund);
                            if (productRequests[0].OrderStatus == '결제요청') {
                                isVBANKRefund = true;
                            } else {
                                isVBANKRefund = false;
                            }
                            component.set("v.isVBANKRefund", isVBANKRefund);
                        }                    
                    console.log('주문재조회성공');
                } else {
                    this.showToast('warning', 'System Admin에게 문의 부탁드립니다.');
                }
            } else if (result.STATUS == 'E') {
                this.showToast('warning', 'System Admin에게 문의 부탁드립니다.');
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },    

});