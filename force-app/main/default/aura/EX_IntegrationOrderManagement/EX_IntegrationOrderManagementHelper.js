/**
 * Created by I2MAX.SEUNGHUNAN on 2023-01-03.
 */

({
    doGetInitData: function (component, event, helper) {
        console.log('doGetInitData');
        var action = component.get('c.doGetInitData');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                var mapSettingValueOrigin = result['mapSettingValueOrigin'];
                // 원본 따로 저장.
                component.set('v.mapSettingValueOrigin', mapSettingValueOrigin);
                // console.log(JSON.stringify(mapSettingValueOrigin));
                // 원본 깊은 복사 후 화면에 뿌릴용도로 따로 저장.
                var mapSettingValue = mapSettingValueOrigin;
                component.set('v.mapSettingValue', mapSettingValue);
                component.set('v.showSpinner', false);

                console.log('mapSettingValue :: ',mapSettingValue);

                

            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    

    fnDoSearch: function (component, event, helper) {
        let offset =  new Date().getTimezoneOffset() * 60000;
        let dateOffset = new Date(new Date().getTime() - offset);
        console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.가장처음- start():' + dateOffset.toISOString());
        
        component.set('v.showSpinner', true);

        var recordLimit = component.get('v.recordLimit');
        var pageOffset = component.get('v.pageOffset');
        var mapSearchParam = component.get('v.mapSearchParam');
        mapSearchParam['recordLimit'] = recordLimit;
        mapSearchParam['pageOffset'] = pageOffset;

        var isSearchBtnClick = mapSearchParam['isSearchBtnClick'];
        console.log('클릭전 v.listPR : ', component.get('v.listPR', []));
        console.log('클릭전 v.listPRLI : ', component.get('v.listPRLI', []));
        if (isSearchBtnClick) {
            component.set('v.listPR', []);
            component.set('v.listPRLI', []);
        }
        console.log('클릭후 v.listPR : ', component.get('v.listPR', []));
        console.log('클릭후 v.listPRLI : ', component.get('v.listPRLI', []));

        var isValid;
        isValid = this.fnValidDate(component, event, helper);
        if (isValid == false) {
            component.set('v.showSpinner', false);
            return;
        }

        var isOneOrderNum = false; //23 12 22 hyungho.chun 아래4개중 하나라도 검색조건에있다면 doGetReturnDeptSearch 안타고 바로 조회
        if(mapSearchParam.orderNo || mapSearchParam.cjOrderNumber || mapSearchParam.salesNo || mapSearchParam.invoiceNo){
            isOneOrderNum = true;    
        }
        
        var mainDataPromise = new Promise(function (resolve, reject) {
            var action1 = component.get('c.doGetSearchData');
            //23.11.09 gw.lee
            //setBackgound추가
            action1.setBackground();
            action1.setParams({
                'mapSearchParam': mapSearchParam
            });
       
            action1.setCallback(this, function (response) { 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //returnOrderLineItem을 조회하기 위한 prliIdList
                    var prliId = [];
                    // deptCode를 검색하기 위한 deptCodeSet
                    // var deptCodeSet = new Set();
                    // var shipmentCodeSet = new Set();

                    var prlis = JSON.parse(JSON.stringify(result.productRequestLineItems));

                    var totalRecord = prlis.length;
                    component.set('v.totalRecord', totalRecord);


                    for (let i = 0; i < prlis.length; i++) {
                        prliId.push(prlis[i].Id);

                        // if (prlis[i].SHIPPED_Department_Code__c != undefined) {
                        //     shipmentCodeSet.add(prlis[i].SHIPPED_Department_Code__c);
                        // }
                        
                        // if (prlis[i].CANCEL_Department_Code__c != undefined) {
                        //     deptCodeSet.add(prlis[i].CANCEL_Department_Code__c);
                        // }
                        // if (prlis[i].Exchange_Request_Department_Code__c != undefined) {
                        //     deptCodeSet.add(prlis[i].Exchange_Request_Department_Code__c);
                        // }
                    }

                    // var shipmentCodeList = Array.from(shipmentCodeSet);
                    // var deptCodeList = Array.from(deptCodeSet);
                    console.log('prliId' , prliId);
                    // console.log('deptCodeSet' , deptCodeSet);
                    // console.log('deptCodeList' , deptCodeList);




                    // if(!isOneOrderNum){ //23 12 22 hyungho.chun 오더넘버존재시 안탐
                        // console.log(' mainDataParam.prliId ' , mainDataParam.prliId);
                        // console.log(' mainDataParam.deptCodeList ' , mainDataParam.deptCodeList);
                        // console.log(' mainDataParam.shipmentCodeList ' , mainDataParam.shipmentCodeList);
                        var action2 = component.get('c.doGetReturnDeptSearch');
                        //23.11.09 gw.lee
                        //setBackgound추가
                        action2.setBackground();
                        // action2.setStorable(); // 23 12 26 hyungho.chun setStroable 추가
    
                        let offset2 =  new Date().getTimezoneOffset() * 60000;
                        let dateOffset2 = new Date(new Date().getTime() - offset2);
                        console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setParams직전- start():' + dateOffset2.toISOString());
    
                        action2.setParams({
                            'prliId': prliId
                            // 'deptCodeList':mainDataParam.deptCodeList,
                            // 'shipmentCodeList' : mainDataParam.shipmentCodeList
                        });
    
                        let offset3 =  new Date().getTimezoneOffset() * 60000;
                        let dateOffset3 = new Date(new Date().getTime() - offset3);
                        console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setParams직후- start():' + dateOffset3.toISOString());
    
                        action2.setCallback(this, function (response) { 
                            var state = response.getState();
    
                            let offset4 =  new Date().getTimezoneOffset() * 60000;
                            let dateOffset4 = new Date(new Date().getTime() - offset4);
                            console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setCallback응답받자마자- start():' + dateOffset4.toISOString());
    
                            if (state === "SUCCESS") {
                                var result = response.getReturnValue();
                                var returnValue = result[0];
                                //var shipmentMap = result[1];
                                //var deptValue = result[2] != undefined ? result[2] : {};
        
                                //console.log('returnValue' , JSON.stringify(returnValue));
                                //console.log('deptValue' , JSON.stringify(deptValue));
                                
                                console.log('returnValue 123 :: ',returnValue);
    
                                // , deptValue, shipmentMap
                                resolve({prlis, prliId, returnValue});
                            } else if(state === "ERROR") {
                                reject(response.getError());
                            }
                        });
                        $A.enqueueAction(action2);
                    // }












                    
                    
                    // var returnValue = null;
                    // console.log('result.returnValue :: ',result.returnValue);
                    
                    // if(result.returnValue){

                    //     returnValue = JSON.parse(JSON.stringify(result.returnValue));
                    //     console.log('returnValue :: ',returnValue);
                        
                    //     resolve({prlis, prliId, returnValue});
                    // }else{
                    //     resolve({prlis, prliId});
                    // }

                    

                } else if(state === "ERROR") {
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action1);

        });
      
        // var returnDataPromoise = mainDataPromise.then(function(mainDataParam) {
        //     return new Promise(function (resolve, reject) { 
                
        //         if(!isOneOrderNum){ //23 12 22 hyungho.chun 오더넘버존재시 안탐
        //             console.log(' mainDataParam.prliId ' , mainDataParam.prliId);
        //             // console.log(' mainDataParam.deptCodeList ' , mainDataParam.deptCodeList);
        //             // console.log(' mainDataParam.shipmentCodeList ' , mainDataParam.shipmentCodeList);
        //             var action2 = component.get('c.doGetReturnDeptSearch');
        //             //23.11.09 gw.lee
        //             //setBackgound추가
        //             action2.setBackground();
        //             // action2.setStorable(); // 23 12 26 hyungho.chun setStroable 추가

        //             let offset2 =  new Date().getTimezoneOffset() * 60000;
        //             let dateOffset2 = new Date(new Date().getTime() - offset2);
        //             console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setParams직전- start():' + dateOffset2.toISOString());

        //             action2.setParams({
        //                 'prliId': mainDataParam.prliId
        //                 // 'deptCodeList':mainDataParam.deptCodeList,
        //                 // 'shipmentCodeList' : mainDataParam.shipmentCodeList
        //             });

        //             let offset3 =  new Date().getTimezoneOffset() * 60000;
        //             let dateOffset3 = new Date(new Date().getTime() - offset3);
        //             console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setParams직후- start():' + dateOffset3.toISOString());

        //             action2.setCallback(this, function (response) { 
        //                 var state = response.getState();

        //                 let offset4 =  new Date().getTimezoneOffset() * 60000;
        //                 let dateOffset4 = new Date(new Date().getTime() - offset4);
        //                 console.log('속도측정 -------------------------------------------------- fnDoSearch.cmp.returnDataPromoise.setCallback응답받자마자- start():' + dateOffset4.toISOString());

        //                 if (state === "SUCCESS") {
        //                     var result = response.getReturnValue();
        //                     var returnValue = result[0];
        //                     //var shipmentMap = result[1];
        //                     //var deptValue = result[2] != undefined ? result[2] : {};
    
        //                     //console.log('returnValue' , JSON.stringify(returnValue));
        //                     //console.log('deptValue' , JSON.stringify(deptValue));
                            
        //                     console.log('returnValue 123 :: ',returnValue);

        //                     // , deptValue, shipmentMap
        //                     resolve({returnValue});
        //                 } else if(state === "ERROR") {
        //                     reject(response.getError());
        //                 }
        //             });
        //             $A.enqueueAction(action2);
        //         }else{
        //             let returnValue = null;
        //             if(mainDataParam.returnValue){
        //                 returnValue =  mainDataParam.returnValue;
        //                 resolve({returnValue});
        //             }else{
        //                 reject({returnValue})
        //             }

        //         }
        //     });
        // });

        var centerDataPromoise = new Promise(function (resolve, reject) {
            var action3 = component.get('c.dogetCenterSearch');
            //23.11.09 gw.lee
            //setBackgound추가
            action3.setBackground();
            action3.setCallback(this, function (response) { 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                   console.log('centerDataPromoise :: ' , result);
                   var reformCenterMap = result.map(function (item) {
                        var rObj = {};
                        rObj[item.DEPT_CODE__c] = item.Name;
                        return rObj;
                   });

                   console.log('reformCenterMap' , reformCenterMap);


                    resolve(reformCenterMap);

                } else if(state === "ERROR") {
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action3);

        });

        // Promise.all([mainDataPromise, centerDataPromoise, returnDataPromoise ]).then(function(results){
        Promise.all([mainDataPromise, centerDataPromoise ]).then(function(results){            
            var prlis = JSON.parse(JSON.stringify(results[0].prlis));
            // var returnValue = isOneOrderNum ? results[0].returnValue : results[2].returnValue;
            var returnValue = results[0].returnValue;
            // var deptValue = results[1].deptValue;
            // var shipmentMap = results[1].shipmentMap;
            var reformCenterMap = results[1];
            //console.log('shipment' , shipmentMap);
            console.log('Promise.all1' , prlis);
            console.log('Promise.all2' , returnValue);
            //console.log('Promise.all3' , deptValue);
            console.log('Promise.all4' , reformCenterMap);

            if (prlis.length != 0) {
                var STATUS_CODE_KOR = new Map();
                STATUS_CODE_KOR.set('000' , '품절예약완료');
                STATUS_CODE_KOR.set('001' , '결제요청');
                STATUS_CODE_KOR.set('002' , '결제완료');
                STATUS_CODE_KOR.set('003' , '결제취소');
                STATUS_CODE_KOR.set('004' , '주문취소');
                STATUS_CODE_KOR.set('005' , '자동주문취소');
                STATUS_CODE_KOR.set('006' , '상품준비중');
                STATUS_CODE_KOR.set('010' , '배송준비중');
                STATUS_CODE_KOR.set('030' , '배송중');
                STATUS_CODE_KOR.set('070' , '배송완료');
                STATUS_CODE_KOR.set('100' , '반품요청');
                STATUS_CODE_KOR.set('101' , '반품예약');
                STATUS_CODE_KOR.set('102' , '반품대기');
                STATUS_CODE_KOR.set('120' , '반품확정');
                STATUS_CODE_KOR.set('121' , '반품완료');
                STATUS_CODE_KOR.set('090' , '반품요청철회');
                STATUS_CODE_KOR.set('130' , '교환요청');

                console.log('STATUS_CODE_KOR' , STATUS_CODE_KOR);


                var DELIVERY_STATUS_CODE_KOR = new Map();
                DELIVERY_STATUS_CODE_KOR.set('10', '송장수신');
                DELIVERY_STATUS_CODE_KOR.set('27', '집하예정');
                DELIVERY_STATUS_CODE_KOR.set('29', '미집하');
                DELIVERY_STATUS_CODE_KOR.set('30', '집하');
                DELIVERY_STATUS_CODE_KOR.set('70', '배송완료');
                DELIVERY_STATUS_CODE_KOR.set('85', '반송');
                DELIVERY_STATUS_CODE_KOR.set('90', '취소');
                DELIVERY_STATUS_CODE_KOR.set('99', '오류');

                console.log('STATUS_CODE_KOR' , STATUS_CODE_KOR);

                var MASKING_STATUS_CODE_SET = new Set();
                MASKING_STATUS_CODE_SET.add('003');
                MASKING_STATUS_CODE_SET.add('004');
                MASKING_STATUS_CODE_SET.add('005');
                MASKING_STATUS_CODE_SET.add('070');
                MASKING_STATUS_CODE_SET.add('110');
                MASKING_STATUS_CODE_SET.add('090');
                MASKING_STATUS_CODE_SET.add('120');
                // function renameKey(obj, old_key, new_key) {
                //     if (old_key !== new_key) {
                //         if(Object.getOwnPropertyDescriptor(obj, old_key) != undefined) Object.defineProperty(obj, new_key, Object.getOwnPropertyDescriptor(obj, old_key));
                //         delete obj[old_key];
                //     }
                // }

                // prlis.forEach(obj => {
                //     try{
                //         renameKey(obj, 'INVOICE_Number__c', 'TrackingNumber');
                //         renameKey(obj, 'Consumables_Order_Class_Code__c', 'ConsumablesBusinessTypeCode');
                //         renameKey(obj, 'Order_CHNL_TYPE_Code__c', 'OrderChannel');
                //         renameKey(obj, 'RSRV_Number__c', 'RequestedPartNo');
                //         renameKey(obj, 'fm_ENC_Order_CUST_Name__c', 'CustomerName');
                //     }catch(error){
                //         console.log('Exception ::: ' , error);
                //     }
                // });

                var isPayment = false;
                var isSale = false;
                var isCJSend = false;

                var orderQuerySeq = 1;

                var integrationOrderItemTable = [];

                for (let i = 0; i < prlis.length; i++) {
                    isPayment = prlis[i].Consumables_Order_Class_Code__c != '003' || prlis[i].Consumables_Order_Class_Code__c != '004' ? true : false;
                    isSale = (prlis[i].Consumables_Order_Class_Code__c == '030' || prlis[i].Consumables_Order_Class_Code__c == '070') && prlis[i].SALE_Number__c != undefined ? true : false;
                    isCJSend =  prlis[i].FFMT_Order_Transfer_YN__c;
                    
                    var sn = prlis[i].SUB_Order_Number__c;
                    if (sn != null && sn.includes('-')) {
                        var targetIndex = sn.split('-').length;

                        if (targetIndex > 2) {
                            prlis[i].SubNumber = sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                        } else {
                            prlis[i].SubNumber = sn;
                        }
                    } else {
                        prlis[i].SubNumber = sn;
                    }

                    if (prlis[i].BASIS_Parts_Number__c != undefined && prlis[i].PART_NO__c != undefined) {
                        if (prlis[i].BASIS_Parts_Number__c == prlis[i].PART_NO__c) {
                            prlis[i].SubstituteYN = '원';
                        } else {
                            prlis[i].SubstituteYN = '대치';
                        }
                    } else {
                        prlis[i].SubstituteYN = '';
                    }

                    //23.12.05 gw.lee
                    //약속상태 그대로 보여주기
                    // if (prlis[i].RSRV_Number__c != undefined && prlis[i].RSRV_Number__c != '' && prlis[i].RSRV_Number__c != null) {
                    //     prlis[i].AppointmentStatus = prlis[i].Appointment_Status__c;
                    // } else {
                    //     if (prlis[i].Consumables_Order_Status__c == '003' || prlis[i].Consumables_Order_Status__c == '004') {
                    //         prlis[i].AppointmentStatus = '취소';
                    //     } else { 
                    //     }
                    // }
                    prlis[i].AppointmentStatus = prlis[i].Appointment_Status__c;

                    //23.12.05 gw.lee
                    //약속상태 그대로 보여주기, 예약번호가 있을 경우만 취소 상태로 표출
                    if (prlis[i].Appointment_Status__c != undefined && 
                        (prlis[i].Appointment_Status__c == 'PO Canceld' || 
                        (prlis[i].Parent.SR_RSRV_PART_Id__c != null && (prlis[i].Consumables_Order_Status__c == '003' || prlis[i].Consumables_Order_Status__c == '004')))) {
                            //2024.02.29 seung yoon heo 취소 => 약속취소
                            // prlis[i].AppointmentStatus = '취소';
                            prlis[i].AppointmentStatus = '약속취소';
                    }

                    // if (prlis[i].UnitPrice__c > 0) {
                    //     prlis[i].CustomerPrice = prlis[i].UnitPrice__c;
                    // } else {
                        // 2024.03.20 seung yoon heo 소비자가 CONSUMER_Price__c보이게 수정
                        prlis[i].CustomerPrice = prlis[i].CONSUMER_Price__c != undefined ? prlis[i].CONSUMER_Price__c : 0;
                    // }

                    if (prlis[i].SALE_Discount_Type_Code__c == 'V') {
                        prlis[i].DiscountType = 'VIP';
                    } else if(prlis[i].SALE_Discount_Type_Code__c == 'E') { 
                        prlis[i].DiscountType = '임직원';
                    } else if(prlis[i].SALE_Discount_Type_Code__c == 'P') {
                        prlis[i].DiscountType = '프로모션';
                    } else if (prlis[i].SALE_Discount_Type_Code__c == 'D') {
                        prlis[i].DiscountType = '쿠폰';
                    } else if (prlis[i].SALE_Discount_Type_Code__c == 'L') {
                        prlis[i].DiscountType = '회원';
                    }

                    
                    

                    if (prlis[i].Parent.PAYMENT_YN__c == true || prlis[i].PAYMENT_YN__c == true) {
                        //현금결제
                        if (prlis[i].VIRTUAL_ACCT_PAYMENT_Amount__c != 0 && prlis[i].VIRTUAL_ACCT_PAYMENT_Amount__c != undefined) {
                            prlis[i].CASHAmount = Math.ceil(prlis[i].VIRTUAL_ACCT_PAYMENT_Amount__c);
                        } else { 
                            prlis[i].CASHAmount = 0;
                        }
                        //카드결제
                        if (prlis[i].CARD_PAYMENT_Amount__c != 0 && prlis[i].CARD_PAYMENT_Amount__c != undefined) {
                            prlis[i].CardAmount = Math.ceil(prlis[i].CARD_PAYMENT_Amount__c);
                        } else {
                            prlis[i].CardAmount = 0;
                        }
                        //포인트결제
                        if (prlis[i].POINT_Amount__c != 0 && prlis[i].POINT_Amount__c != undefined) {
                            prlis[i].PointAmount = Math.ceil(prlis[i].POINT_Amount__c);
                        } else {
                            prlis[i].PointAmount = 0;
                        }
                        prlis[i].PaymentAmount = prlis[i].PAYMENT_Amount__c;

                    } else {
                        // 결제 미완료

                        //카드결제
                        if (prlis[i].CARD_PAYMENT_Amount__c != 0 && prlis[i].CARD_PAYMENT_Amount__c != undefined) {
                            prlis[i].CardAmount = Math.ceil(prlis[i].CARD_PAYMENT_Amount__c);
                        } else {
                            prlis[i].CardAmount = 0;
                        }

                        // 현금결제
                        if (prlis[i].CASH_PAYMENT_Amount__c != 0 && prlis[i].CASH_PAYMENT_Amount__c != undefined) {
                            prlis[i].CASHAmount = Math.ceil(prlis[i].CASH_PAYMENT_Amount__c);
                        } else {
                            prlis[i].CASHAmount = 0;
                        }

                        // 포인트결제
                        if (prlis[i].POINT_Amount__c != 0 && prlis[i].POINT_Amount__c != undefined) {
                            prlis[i].PointAmount = Math.ceil(prlis[i].POINT_Amount__c);
                        } else {
                            prlis[i].PointAmount = 0;
                        }

                        prlis[i].PaymentAmount = prlis[i].PAYMENT_Amount__c;
                    }

                    if (prlis[i].Parent.fm_IsMaskingTarget__c && MASKING_STATUS_CODE_SET.has(prlis[i].Consumables_Order_Status__c)) {
                        prlis[i].CustomerName = prlis[i].Parent.fm_ENC_Order_CUST_Name__c;
                        prlis[i].CustomerPhone = prlis[i].Parent.fm_ENC_Order_CUST_TPNO_1__c;
                    } else {
                        prlis[i].CustomerName = prlis[i].Parent.Order_CUST_Name__c;
                        prlis[i].CustomerPhone = prlis[i].Parent.Order_CUST_TPNO_1__c;
                    }

                    if (STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Status__c) != undefined &&
                    (STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Status__c) == '배송중' || 
                    STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Status__c) == '배송완료') &&
                    prlis[i].SALE_Number__c == undefined
                    ) {
                        prlis[i].DeliveryColor = 'bg_color_salesError';
                        prlis[i].CancelColor = 'bg_color_salesError';
                        prlis[i].ReturnColor = 'bg_color_salesError';
                        prlis[i].ExchangeColor = 'bg_color_salesError';
                        prlis[i].SalesError = 'bg_color_salesError';
                    } else { 
                        prlis[i].DeliveryColor = 'bg_color_delivery';
                        prlis[i].CancelColor = 'bg_color_cancel';
                        prlis[i].ReturnColor = 'bg_color_return';
                        prlis[i].ExchangeColor = 'bg_color_exchange';
                    }



                    var itemTable = {
                        'OrderQuerySeq' : orderQuerySeq++,
                        'Id' : prlis[i].Id,
                        'TrackingNumber' : isCJSend ? prlis[i].INVOICE_Number__c : null,
                        'ConsumablesBusinessTypeCode' : (prlis[i].Consumables_Order_Class_Code__c != undefined ? prlis[i].Consumables_Order_Class_Code__c : ''),
                        'SubNumber' : prlis[i].SubNumber,
                        'OrderChannel' : (prlis[i].Order_CHNL_TYPE_Code__c != null ? prlis[i].Order_CHNL_TYPE_Code__c : '미지정'),
                        'OrderDate' : prlis[i].Parent.Order_Date__c != undefined ? prlis[i].Parent.Order_Date__c : "",
                        'OrderNumber' : prlis[i].Order_Number__c != undefined ? prlis[i].Order_Number__c : "",
                        'OrderStatus' : STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Status__c)
                                        != undefined ? STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Status__c) : '',
                        'OrderStatusDetail' : STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Detail__c)
                                        != undefined ? STATUS_CODE_KOR.get(prlis[i].Consumables_Order_Detail__c) : '',
                        'RequestedPartNo' : prlis[i].BASIS_Parts_Number__c,
                        'ReceivedPartNo' : prlis[i].PART_NO__c,
                        'SalesQuantity' : prlis[i].SALE_Quantity__c != undefined ? prlis[i].SALE_Quantity__c : 0,
                        'SubstituteYN' : prlis[i].SubstituteYN,
                        'AppointmentStatus' : prlis[i].AppointmentStatus,
                        'DIV' : prlis[i].ENDP_Code__c,
                        'PartNameKOR' : prlis[i].fm_Consumables_PART_DESC_KOR__c,
                        'PartName' : prlis[i].Product2.PART_DESC__c,
                        'Model' : prlis[i].Product2.MODEL_CODE__c != undefined ? prlis[i].Product2.MODEL_CODE__c : "",
                        //'ShippedDepartment' : shipmentMap[prlis[i].SHIPPED_Department_Code__c],
                        'ShippedDepartment' : prlis[i].SHIPPED_Department_Code__c,
                        'CustomerPrice' : prlis[i].CustomerPrice,
                        'SaleAmount' : prlis[i].SALE_Amount__c != undefined ? prlis[i].SALE_Amount__c : 0,
                        'PaymentAmount' : prlis[i].PAYMENT_Amount__c != undefined ? prlis[i].PAYMENT_Amount__c : 0,
                        'DiscountAmount' : prlis[i].Last_Discount_Amount__c != undefined ? prlis[i].Last_Discount_Amount__c : 0,
                        'DiscountType' :  prlis[i].DiscountType,
                        'CashAmount' : prlis[i].CASHAmount,
                        'CardAmount' : prlis[i].CardAmount,
                        'PointAmount' : prlis[i].PointAmount,
                        'PaymentAmount' : prlis[i].PaymentAmount,
                        'QuantityRequested' : prlis[i].QuantityRequested != undefined ? prlis[i].QuantityRequested : 0,
                        'CancelQuantity' : prlis[i].CANCEL_Quantity__c != undefined ? prlis[i].CANCEL_Quantity__c : 0,
                        'ReturnQuantity' : prlis[i].Return_Order_Quantity__c != undefined ? prlis[i].Return_Order_Quantity__c : 0,
                        'ExpectedReturnQuantity': returnValue[prlis[i].Id] != undefined ? returnValue[prlis[i].Id] : 0,
                        'ExchangeQuantity' : prlis[i].Exchange_Quantity__c != undefined ? prlis[i].Exchange_Quantity__c : 0,
                        'SalesNumber' : prlis[i].SALE_Number__c,
                        'CJOrderNumber' : isCJSend ? prlis[i].FFMT_Order_Number__c : null,
                        'CJOrderSendYN' : isCJSend ? 'Y' : 'N',
                        'CJOrderSendDate' : isCJSend ? prlis[i].FFMT_Transfer_DTM__c : null,
                        'DeliveryStatus' : DELIVERY_STATUS_CODE_KOR.has(prlis[i].DELIVERY_STATUS_CODE__c) ? DELIVERY_STATUS_CODE_KOR.get(prlis[i].DELIVERY_STATUS_CODE__c) : '',
                        'ShipmentDate' : isCJSend ? prlis[i].SHIP_DTM__c : null,
                        'DeliveryDate' : isCJSend && prlis[i].Consumables_Order_Status__c == '070' ? prlis[i].Delivery_DTM__c : null,
                        'DeliveryCompany' : isCJSend ? prlis[i].DELIVERY_CODE__c : null,
                        'DeliveryFee' : prlis[i].PARCEL_FEE_Amount__c,
                        //'CancelDepartment' : prlis[i].CANCEL_Department_Code__c != undefined && deptValue.hasOwnProperty(prlis[i].CANCEL_Department_Code__c) ? deptValue[prlis[i].CANCEL_Department_Code__c] : '',
                        // 'CancelRequesterEmployeeNumber' : prlis[i].CANCEL_UserId__c != undefined ? prlis[i].CANCEL_UserId__r.EmployeeNumber != undefined ? prlis[i].CANCEL_UserId__r.EmployeeNumber : '' :  '',
                        // 'CancelRequester' : prlis[i].CANCEL_UserId__c != undefined ? prlis[i].CANCEL_UserId__r.name != undefined ? prlis[i].CANCEL_UserId__r.name : '' : '',
                        // 'CancelRequestedDate' : prlis[i].CANCEL_Request_DTM__c,
                        // 'CancelRequestReason' : prlis[i].CANCEL_Reason__c,
                        // // 'ExchangeRequesterDepartment' : prlis[i].Exchange_Request_Department_Code__c != undefined ? 
                        // //                                 deptValue.hasOwnProperty(prlis[i].Exchange_Request_Department_Code__c) ? 
                        // //                                 deptValue[prlis[i].Exchange_Request_Department_Code__c] : '' : '',
                        // 'ExchangeRequester' : prlis[i].Exchange_Requester_Id__c != undefined ? prlis[i].Exchange_Requester_Id__r.Name != undefined ? 
                        //                     prlis[i].Exchange_Requester_Id__r.Name : '' : '',
                        'ExchangeRequestedDate' : prlis[i].Exchange_Request_DTM__c,
                        'CaseNumber' : prlis[i].Parent.CaseId != undefined ? (prlis[i].Parent.Case.Subject != undefined && prlis[i].Parent.Case.CaseNumber != undefined) ?
                                    prlis[i].Parent.Case.Subject + ' ' + prlis[i].Parent.Case.CaseNumber : '' : '',
                        'CaseURL' : prlis[i].Parent.fmURL_CaseNumber__c != undefined ? prlis[i].Parent.fmURL_CaseNumber__c : '',
                        'ParentId' : prlis[i].ParentId,
                        'OrderSeq' : prlis[i].Order_SEQ__c,
                        'CustomerName' : prlis[i].CustomerName,
                        'CustomerPhone' : prlis[i].CustomerPhone,
                        'SalesDate' : isSale ? prlis[i].Parent.CreatedDate : null,
                        'ASCPrice' : prlis[i].Product2.ASC_PRICE__c != undefined ? prlis[i].Product2.ASC_PRICE__c : 0,
                        'RequestedDate' : prlis[i].Parent.CreatedDate,
                        'ModelCode' : prlis[i].fm_MODEL_Code__c,
                        'BasisOrderNumber' : (prlis[i].Consumables_Business_Type_Code__c == 'Order' && prlis[i].BASIS_Order_Item_Id__c == undefined) ? 
                                        null : prlis[i].BASIS_Order_Item_Id__c != undefined ? prlis[i].BASIS_Order_Item_Id__r.Order_Number__c : '',
                        'HandWorkYN' : prlis[i].HAND_WORK_YN__c ? 'Y' : 'N',
                        'HandWorkDate' : prlis[i].HAND_WORK_DATE__c,
                        'HandWorkUser' : prlis[i].HAND_WORK_USER_ID__c,
                        'HandWorkReason' : prlis[i].HAND_WORK_REASON__c,
                        'CancelAmount' : (prlis[i].CANCEL_Quantity__c != undefined && prlis[i].CANCEL_Quantity__c > 0 && prlis[i].CustomerPrice > 0) ?
                                        prlis[i].CANCEL_Quantity__c * prlis[i].CustomerPrice : 0,
                        'ParentLocationId' : prlis[i].SourceLocationId != undefined ? prlis[i].SourceLocation.ParentLocationId__c : '',
                        'ParentLocation' : prlis[i].SourceLocationId != undefined ? prlis[i].SourceLocation.ParentLocationId__c != undefined ? prlis[i].SourceLocation.ParentLocationId__r.Name : '' : '', 
                        'Product2Id' : prlis[i].Product2Id,
                        'LocationId' : prlis[i].SourceLocationId,
                        'SR_RSRV_PART_Id' : prlis[i].Parent.SR_RSRV_PART_Id__c,
                        'OrderStatusChangeHistory' : prlis[i].Order_Status_Change_History__c,
                        'DeliveryColor' : prlis[i].DeliveryColor, 
                        'CancelColor' : prlis[i].CancelColor,
                        'ReturnColor' : prlis[i].ReturnColor,
                        'ExchangeColor' : prlis[i].ExchangeColor,
                        'SalesError' : prlis[i].SalesError,
                        'CheckFlag' : true,
                        'CustomerNameEnc' : prlis[i].Parent.fm_ENC_Order_CUST_Name__c,
                        'CustomerPhoneEnc' : prlis[i].Parent.fm_ENC_Order_CUST_TPNO_1__c != undefined ? 
                                            prlis[i].Parent.fm_ENC_Order_CUST_TPNO_1__c : prlis[i].Parent.fm_ENC_Order_CUST_TPNO_2__c,
                        'isMasking' : prlis[i].Parent.fm_IsMaskingTarget__c

                    };

                    (integrationOrderItemTable).push(itemTable);

                }

                // 만약 null값이나 undefined값이 문제가 될시 추가
                // integrationOrderItemTable.forEach(item =>{
                //     for (const key in item) {
                //         if (item[key] == null || item[key] == undefined) {
                //             delete item[key];
                //         }

                //         // console.log('item[key]' , item[key]); value값 
                //         // console.log('key' , key);   key값
                //         // console.log('item' , item); item 전체
                //     }
                // })

                console.log('값 확인 ' , integrationOrderItemTable);
                if (isSearchBtnClick) {
                    //component.set('v.listPR', integrationOrderItemTable);
                    const child = component.find("orderList");
                    child.find("wijmo_EXIntegrationOrderList").message({type:'items', items: integrationOrderItemTable});
                }else{
                    var curListPR = component.get('v.listPR');
                    //component.set('v.listPR', curListPR.concat(integrationOrderItemTable));

                    const child = component.find("orderList");
                    child.find("wijmo_EXIntegrationOrderList").message({type:'items', items: curListPR.concat(integrationOrderItemTable)});
                }
            } else {
                // component.set('v.listPR', []);
                component.set('v.totalRecord', 0);

                const child = component.find("orderList");
                child.find("wijmo_EXIntegrationOrderList").message({type:'items', items: []});
            }



            component.set('v.showSpinner', false);



         });

        // Promise.all([mainDataPromise, returnDataPromoise, centerDataPromoise]).then(function(results){
        //     var result1 = results[0];
        //     var result2 = results[1];
        //     var result3 = results[2];
        //     console.log('Promise.all1' , result1);
        //     console.log('Promise.all2' , result2);
        //     console.log('Promise.all3' , result3);

        //  });


        
        // var action2 = component.get('c.doGetSearchData2');
   
        // action2.setParams({
        //     'mapSearchParam': mapSearchParam
        // });
    
        // var firPromise = new Promise(function (resolve, reject) {
        //     action1.setCallback(this, function (response) {
        //         var result = response.getReturnValue();
        //         if (result.STATUS == 'S') {
        //             var productRequestLineItems = result.productRequestLineItems;
        //             //23.09.08 PHJ
        //             var totalRecord = productRequestLineItems.length;
        //             component.set('v.totalRecord', totalRecord);
        //             console.log('productRequestLineItems 1' , productRequestLineItems);
        //             resolve(productRequestLineItems);
        //             // var totalRecord = 0;
        //             // if (result['totalRecord'] != null && result['totalRecord'] != undefined) {
        //             //     totalRecord = result['totalRecord'];
        //             //     component.set('v.totalRecord', totalRecord);
        //             // }
        
        //             // if(productRequestLineItems.length != 0){
        //             //     if (isSearchBtnClick) {
        //             //         component.set('v.listPR', productRequestLineItems);
        //             //     }
        //             //     else{
        //             //         var curListPR = component.get('v.listPR');
        //             //         component.set('v.listPR', curListPR.concat(productRequestLineItems));
        //             //     }
        //             // }
        //             // else {
        //             //     component.set('v.listPR', []);
        //             //     component.set('v.totalRecord', 0);
        //             // }
        //             //console.log('### data : ', component.get('v.listPR'));
        //             component.set('v.showSpinner', false);
        //         } else if (result.STATUS == 'E') {
    
        //             this.showToast('warning', 'System Admin에게 문의 부탁드립니다.');
        //             console.log('Error : '+ result.message);
        //             component.set('v.showSpinner', false);
        //         }
               
        //     });
        //     $A.enqueueAction(action1);
        
        // });

        // var sndPromise = new Promise(function (resolve, reject) {
        //     action2.setCallback(this, function (response) {
        //         var result = response.getReturnValue();
        //         if (result.STATUS == 'S') {
        //             var productRequestLineItems = result.productRequestLineItems;

        //             console.log('productRequestLineItems2' , productRequestLineItems);
        //             resolve(productRequestLineItems);
        //             component.set('v.showSpinner', false);
        //         } else if (result.STATUS == 'E') {
    
        //             this.showToast('warning', 'System Admin에게 문의 부탁드립니다.');
        //             console.log('Error : '+ result.message);
        //             component.set('v.showSpinner', false);
        //         }
               
        //     });
        //     $A.enqueueAction(action2);
        
        // });

        // Promise.all([firPromise, sndPromise]).then(function(results){
        //     var result1 = results[0];
        //     var result2 = results[1];
        //     if (result1.length != 0) {
        //         var allData = [];
        //         allData.push(...result1);
        //         allData.push(...result2);

        //         var CombineData = [];
        //         console.log( 'allData' , allData);


        //         allData.forEach(item => {
        //             var Id = item.Id;
        //             if (!CombineData[Id]) {
        //                 CombineData[Id] = item;
        //             }else{
        //                 CombineData[Id] = Object.assign({}, CombineData[Id], item);
        //             }
        //         });
        //         console.log( 'CombineData' , CombineData);


        //         const repackgeData = [];

        //         for (const id in CombineData) {
        //             const item = CombineData[id];
        //             const obj = Object.assign({}, item, { Id: id });
        //             repackgeData.push(obj);
        //         }
                
        //         console.log('repackgeData ' , repackgeData);
                
        //         console.log( 'repackgeData' , repackgeData);
        //         if (isSearchBtnClick) {
        //             component.set('v.listPR', repackgeData);
        //         }else{
        //             var curListPR = component.get('v.listPR');
        //             component.set('v.listPR', curListPR.concat(repackgeData));
        //         }


        //     }else{
        //         component.set('v.listPR', []);
        //         component.set('v.totalRecord', 0);
        //     }


        // }).catch(function(error){
        //     console.error('오류 발생', error);
        // });

        
    },

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

    // 날짜 포멧 변경하기 (YYYY-MM-DD)
    changeDateFormat: function (date, flag) {
        date = flag == 1 ? date : new Date(date.setDate(date.getDate()-2));
        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },

    // fnValidate : function (component, event, helper){
    //     var mapSearchParam = component.get('v.mapSearchParam');
    //     var baseDateStart = new Date(mapSearchParam.baseDateStart);
    //     var baseDateEnd = new Date(mapSearchParam.baseDateEnd);

    //     var time = baseDateEnd - baseDateStart;
    //     var diffDate = time / (24 * 60 * 60 * 1000);

    //     var salesCompleteY = mapSearchParam.isSalesCompleteY;
    //     var salesCompleteN = mapSearchParam.isSalesCompleteN;

    //     console.log('y : ' + salesCompleteY);
    //     console.log('n : ' + salesCompleteN);

    //     if(diffDate < 0){
    //         this.showToast('error', '시작일이 종료일 보다 클 수 없습니다.');
    //         return false;
    //     }
    //     if (salesCompleteY == false && salesCompleteN == false) {
    //         this.showToast('error', '판매완료여부를 선택해주세요.');
    //         return false;
    //     }

    //     return true;
    // },

     // 2023.08.16 seung yoon heo 최대 조회기간 90일 -> 7일로 변경
    fnValidDate  : function (component, event, helper) {
        var mapSearchParam = component.get('v.mapSearchParam');
        var startDate = new Date(mapSearchParam.baseDateStart);
        var endDate = new Date(mapSearchParam.baseDateEnd);
        
        var time = endDate - startDate;
        const diffDate = time / (24 * 60 * 60 * 1000);

        var salesCompleteY = mapSearchParam.isSalesCompleteY;
        var salesCompleteN = mapSearchParam.isSalesCompleteN;

        var searchName = new Map();
        var searchOrderNum = new Map();

        searchName.set('contactName',  mapSearchParam.contactName == undefined ? '' :  mapSearchParam.contactName);
        // 24.03.15 seung yoon heo 조회조건 추가
        searchName.set('contactPhone',  mapSearchParam.contactPhone == undefined ? '' :  mapSearchParam.contactPhone);

        searchOrderNum.set('orderNo', mapSearchParam.orderNo == undefined ? '' : mapSearchParam.orderNo);
        searchOrderNum.set('cjOrderNumber', mapSearchParam.cjOrderNumber == undefined ? '' : mapSearchParam.cjOrderNumber);
        //23.11.22 PHJ 판매번호 필터추가
        searchOrderNum.set('salesNo', mapSearchParam.salesNo == undefined ? '' : mapSearchParam.salesNo);

        console.log('mapSearchParam  :::  ' , JSON.stringify(mapSearchParam));
        console.log('mapSearchParam.orderNo  :::  ' , mapSearchParam.orderNo);
        console.log('searchOrderNum  :::  ' , searchOrderNum);


        if(diffDate < 0) {
            this.showToast('warning', '시작 날짜는 종료 날짜보다 이후 일 수 없습니다.');
            return false;
        }
        
        if (searchOrderNum.get('orderNo') == '' && searchOrderNum.get('cjOrderNumber') == '' && searchOrderNum.get('salesNo') == '') {

            if (salesCompleteY == false && salesCompleteN == false) {
                this.showToast('error', '판매완료여부를 선택해주세요.');
                return false;
            }
    
          
            if (searchName.get('contactName') != '' || searchName.get('contactPhone') != '') {

                if(diffDate > 30)  {
                    this.showToast('warning', '고객명/전화번호 조회 기간은 최대 31일 가능합니다.');
                    return false;
                }
            }else{
                //3일
                if (mapSearchParam['orderChannel'] == 'ALL') {
                    if(diffDate > 2)  {
                        this.showToast('warning', '전체 조회 기간은 최대 3일 가능합니다.');
                        return false;
                    }
                } else{
                    if(diffDate > 6)  {
                        this.showToast('warning', '채널 선택 조회 기간은 최대 7일 가능합니다.');
                        return false;
                    }
                }
                
            }
        }

       
        return true;
    },

    // ToastMessage용 함수
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },



    //23 09 07 hyungho.chun 라벨로 받아온 스트링을 잘라서 리스트 형태로 만들기 (string -> [{label : 라벨값 , value : 벨류값 }, ...])
    // setOptionListFromStr: function (labelStr, num) {
        
    //     var result = labelStr.split(/\r?\n/);
        
    //     console.log(result);

    //     var returnValue = [];

    //     for(var i =0;i<result.length;i++){
    //         var element = {label : result[i].substring(0, result[i].length-num-1) , value : result[i].substring(result[i].length-num)};
    //         returnValue.push(element);
    //     }
    //     console.log('returnValue :: ',returnValue);
        
    //     return returnValue;
    // },

    //23 09 07 hyungho.chun 라벨로 받아온 스트링을 잘라서 리스트 형태로 만들기 (string -> [{label : 라벨값 , value : 벨류값 }, ...])
    setOptionListFromStrWithMark: function (labelStr, mark) {
        
        var result = labelStr.split(/\r?\n/);
        
        console.log(result);

        var returnValue = [];

        for(var i =0;i<result.length;i++){
            var element = {label : result[i].split(mark)[0] , value : result[i].split(mark)[result[i].split(mark).length-1]};
            returnValue.push(element);
        }
        console.log('returnValue222 :: ',returnValue);
        
        return returnValue;
    },        
});