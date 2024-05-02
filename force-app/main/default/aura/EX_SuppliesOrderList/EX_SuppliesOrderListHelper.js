/**
 * Created by A75685 on 2022-11-13.
 */

({
    gfinit : function(component , event, helper){
        var maxAmount = $A.get("$Label.c.ConsumablesAmountLimit");
        component.set('v.maximumAmount', maxAmount);
        var maxMangerAmount = $A.get("$Label.c.ConsumablesManagerAmountLimit");
        component.set('v.maximumManagerAmount', maxMangerAmount);
    },
    /*테스트용*/
    getParts : function(component , event, helper, listId){
        console.log('getParts ');
        console.log('listId :: '  + listId);
        let action =component.get("c.getPartData");
        action.setParams({
            listId : listId
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('state :: ' + state);
            if(state === "SUCCESS"){

                let result = response.getReturnValue();
                let listProd = result.listProd;
                listProd.forEach(function(data){
                    if(data.DISABLED_DT__c){
                        data.IsDisabled =  '\u2611';
                    } else {
                        data.IsDisabled =  '\u2B1C';
                    }
                });
                component.set("v.data", listProd);


            } else if (state === "ERROR"){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },


    showToast : function(type, message, mode) {
        let dismissible = mode != undefined ? mode : 'dismissible';
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message,
            mode: dismissible
        });
        evt.fire();

    },
    getData : function(component, helper, standardOrderDataList, soldOutOrderDataList){
        //
        // ///2023.04.14
        // component.set('v.standardOrderData', standardOrderDataList);
        // component.set('v.soldOutOrderData', soldOutOrderDataList);
        // ///2023.04.14
        
         var evt = $A.get("e.c:EX_SuppliesOrderList_evt");
                evt.setParams({
                    'standardOrderDataList' : standardOrderDataList,
                    'soldOutOrderDataList'  : soldOutOrderDataList,
                });
                evt.fire();
    },
    /**
     * @description 소모품 주문 저장 전 front 단 Validation Check 함수
     * @param component
     * @param event
     * @param helper
     * @author 22.12.20 / I2MAX.SEOKHOLEE
     */
    fnConsumableOrderValidCheck  : function (component, event, helper, itemValues , isCreateOrder) {
        
        var isValid = true;
        var isCreateOrder = isCreateOrder != undefined ? isCreateOrder : component.get('v.isCreateOrder');

        var objCont = !isCreateOrder ? component.get('v.consertObjCont') : component.get('v.objCont'); 
        var isContactSame = !isCreateOrder ? component.get('v.consertIsContactSame') :component.get('v.isContactSame'); 
        var phoneCol = !isCreateOrder ? component.get('v.consertPhoneCol') :component.get('v.phoneCol'); 
        var consigneeName = !isCreateOrder ? component.get('v.consertConsigneeName') :component.get('v.consigneeName'); 
        var newAddress = !isCreateOrder ? component.get('v.consertNewAddress') :component.get('v.newAddress'); 
        var detailAddress = !isCreateOrder ? component.get('v.consertDetailAddress') :component.get('v.detailAddress'); 
     
        // 최소 택배 주문 금액  임시 세팅
        var minimumDeliveryOrderAmount = component.get('v.parseFee');
        // 총 Item 주문 금액
        var totalItemPrice = 0;
        var maximumQuantity = component.get('v.maximumAmount');
        var maximumMangerQuiantity = component.get('v.maximumManagerAmount');
        var isExchangeOrder = component.get('v.isExchangeOrder');
        console.log('maximumQuantity ' + maximumQuantity );

      
        if (component.get('v.exchangeLimitedQuantity') < 0) {
            var toast = $A.get("e.force:showToast");
              toast.setParams({
                "message": "요청수량이 주문수량보다 많아 주문이 불가능합니다.",
                "type": "error"
              });
              toast.fire();
              isValid = false;
               return isValid;
        }

        if(objCont == null ){
             var toast = $A.get("e.force:showToast");
              toast.setParams({
                "message": "고객 정보가 없습니다",
                "type": "error"
              });
              toast.fire();
              isValid = false;
               return isValid;
         }

        if (isContactSame && (objCont.POSTAL_CODE__c == null
            || objCont.POSTAL_CODE__c == '')) {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "message": "고객의 우편번호가 없습니다. \'결제자 정보와 동일\'을 해제하시고 주소를 직접 입력해주세요.",
                "type": "error"
            });
            toast.fire();
            return false;
        }

        // 2024.01.12 seung yoon heo 고객의 우편번호가 00000인 경우 주문 val
        if (isContactSame && (objCont.POSTAL_CODE__c == '00000')) {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "message": "유효한 주소가 아닙니다. 도로명 주소를 확인해 주세요.",
                "type": "error"
            });
            toast.fire();
            return false;
        }
        console.log('col :' + phoneCol);

        console.log(consigneeName);
        console.log(phoneCol);
        console.log(newAddress);
        console.log(detailAddress);

        if(consigneeName == '' || consigneeName == null || consigneeName == undefined){
            this.showToast('error','수취인의 이름이 없습니다');
            isValid = false;
        }
        if(phoneCol == 'color:red' ){
            this.showToast('error','잘못된 전화번호 형식입니다');
            isValid = false;

        }
        if(phoneCol == '' || phoneCol == undefined){
            this.showToast('error','받는 분의 전화번호가 입력되지 않았습니다');
            isValid = false
        }
        if(newAddress  == '' || newAddress == null || newAddress == undefined){
            this.showToast('error','주소가 없습니다');
            isValid = false;

        }
        //24 01 19 hyungho.chun 상세주소도 결제자와 수취인 정보 다를경우 필수 입력
        //24.01.31 gw.lee 상세주소 Validation 주석 처리
        //    if(detailAddress  == '' || detailAddress == null || detailAddress == undefined){
        //        this.showToast('error','상세주소가 없습니다');
        //        isValid = false;
        //    }

        console.log('tt');
        itemValues.forEach(item => {
            totalItemPrice += item.Price * item.QTY;
            
            //23.12.26 gw.lee
            //소모품만 주문 가능 로직 추가
            if (item.PART_TYPE != 'Y' && !isExchangeOrder) { //24 01 12 hyungho.chun 교환주문은 소모품아니여도 주문생성가능
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "소모품이 아닌 경우, 주문이 불가능합니다.",
                    "type": "warning"
                });
                toast.fire();
                isValid = false;
                return isValid;
            }

            //23 12 19 hyungho.chun 현장 판매 제품은 주문못한다는 팝업 추가
            if(item.Note == '택배 불가 상품'){
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "현장 판매상품은 소모품 택배 주문이 불가능합니다.",
                    "type": "warning"
                });
                toast.fire();
                isValid = false;
                return isValid;
            }

            else if(parseInt(item.QTY)>maximumQuantity && component.get('v.bulkOrderManager') == false){
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "최대 주문수량은 50개입니다.",
                    "type": "warning"
                });
                toast.fire();
                isValid = false;
                return isValid;
            } else if (parseInt(item.QTY)>maximumMangerQuiantity && component.get('v.bulkOrderManager') == true) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "관리자 최대 주문수량은 1000개입니다.",
                    "type": "warning"
                });
                toast.fire();
                isValid = false;
                return isValid;
            }

            if (!Number.isInteger(item.QTY)) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "소수점 수량지정 주문이 불가능합니다.",
                    "type": "warning"
                });
                toast.fire();

                isValid = false;
                return isValid;
            }

            if (item.QTY == 0 || item.QTY == undefined) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "수량 입력이 필요합니다.",
                    "type": "warning"
                });
                toast.fire();

                isValid = false;
                return isValid;
            }

            //gw.lee 24.01.08
            //단종된 상품 주문 가능 수정
            if (item.DISABLED_TYPE == 'Y' && item.QTY > item.fm_Available_Quantity) {		
                var toast = $A.get("e.force:showToast");		
                toast.setParams({		
                    "message": "단종된 상품은 가용수량을 초과할 수 없습니다.",		
                    "type": "warning"		
                });		
                toast.fire();		
                isValid = false;		
                return isValid;		
            }

            if (isExchangeOrder == true) {
                if (item.PurchaseType == '품절주문') {
                    var toast = $A.get("e.force:showToast");		
                    toast.setParams({		
                        "message": "교환 요청의 경우, 품절 주문이 불가능합니다.",		
                        "type": "warning"		
                    });		
                    toast.fire();		
                    isValid = false;		
                    return isValid;		
                }
            }

            let itemValue = component.get('v.currentTotalQty') + item.QTY;
            console.log('itemValue ::: ', itemValue);

            component.set('v.currentTotalQty', itemValue);
        });
        
        if (minimumDeliveryOrderAmount > totalItemPrice && component.get('v.costLimitManager') == false && isValid == true && component.get('v.isExchangeOrder') == false) {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "message": "최소 주문금액은 " + minimumDeliveryOrderAmount + " 원 입니다.",
                "type": "warning"
            });
            toast.fire();
            isValid = false;

        }


        console.log('isvla ' +isValid);

        return isValid;

    },

    fnGetLocation: function (component, event, helper) {
        let action =component.get("c.getResourceLocation");
        action.setCallback(this, function(response){
            let state = response.getState();
                   console.log('state :: ' + state);
                   if(state === "SUCCESS"){

                       let result = response.getReturnValue();
                       console.log('rrrjrjirjirjirj : ' + JSON.stringify(result));
                        component.set("v.currentLocation", result.currentLocation);
                        // 2023.12.12 seung yoon heo SM프로필 요청센터 적용
                        if (result.serviceCenterId != undefined) {
                            component.set("v.serviceCenterId", result.serviceCenterId);
                            component.set("v.serviceCenterLabel", result.serviceCenterLabel);
                        }

                        }


                   else if (state === "ERROR"){
                       let errors = response.getError();
                       if (errors) {
                           if (errors[0] && errors[0].message) {
                               this.showToast("error", errors[0].message);
                           }
                       } else {
                           this.showToast("error", "Unknown error");
                       }
                   }

           });
    $A.enqueueAction(action);

    },
    sendMessage: function(component, msg, type) {
        let wijimoName = 'wijmo_EXSuppliesOrderList';
        if (type) {
            wijimoName = type;
        }
        component.find(wijimoName).message(msg);
    },
    fnCancelProduct: function (component, event, helper, row) {
        var newData;
        var data = component.get('v.data');
        var total = component.get('v.orderTotal');
        total -=  row.Price * row.QTY;
        component.set('v.orderTotal',total);
        

        //gw.lee 2023.08.05
        //삭제 오류로 key데이터
        var rowIndex = data.findIndex(function (item) {
            if (row.Id != undefined) {
                return item.Id === row.Id
            } else {
                return item.key === row.key
            }
        });

        if (rowIndex > -1) {
            data.splice(rowIndex, 1);
            newData = data;
        }
        component.set('v.data',newData);

        let listType = '';
        if (component.get('v.isExchangeOrder') == true) {
            listType = 'wijmo_EXSuppliesOrderDisabledList';
        }

        this.sendMessage(component, {type:'items', items: newData}, listType);
        System.debug('1111111');
        console.log('1111111');

    },
    fnWijmoAddData: function (component, event, helper) {
        try {

            console.log('fnAddData Start');
    
            let evtDelimiter = event.getParam('delimiter');
            let evtData = event.getParam('data');
            let evtType = event.getParam('type');
            let evtPurchaseType = event.getParam('purchaseType');
            //2024.01.03 seung yoon heo 단종부품 event 추가
            let disabledCheck = event.getParam('disabledCheck');
            let crossPartCheck = event.getParam('crossPartCheck');

            //2023.12.08 seung yoon heo 출고부서
            var ShipmentNameMap = new Map();
            ShipmentNameMap.set(evtData.DIVCODE, evtData.ShipmentName);

            var quantityMap = component.get('v.quantityMap');
            quantityMap[evtData.sProductItemId] = evtData;
            quantityMap[evtData.sProductItemId].divShipmentCode = evtData.DIVCODE;
            if (evtData.ShipmentName != '' && evtData.ShipmentName != undefined && evtData.ShipmentName != '소모품센터') {
                quantityMap[evtData.sProductItemId].divShipmentName = evtData.ShipmentName;
            }
            component.set('v.quantityMap', quantityMap);

            if (evtPurchaseType == 'standard') {
                evtPurchaseType = '일반 주문';
            } else {
                evtPurchaseType = '품절 주문';
            }
            let evtDIVCODE = evtData.DIVCODE;
    
            let evtProdId = evtData.sProductItemId;
            let evtSubstitute = evtData.SUBSTITUTE
    
            let evtId = evtData.productRequestLineItemId;
            var evtObsMemberPrice = evtData.ObsMemberPrice;
            var evtOriginConsumerPrice = evtData.originConsumerPrice;
    
            console.log('evtObsMemberPrice => ' + evtObsMemberPrice);
            console.log('evtOriginConsumerPrice => ' + evtOriginConsumerPrice);
    
            let strTabId = component.get("v.strTabId");
            let data = component.get("v.data");
            let FSIsMaterialPortal = component.get('v.FSIsMaterialPortal');
    
            var isExchangeOrder = component.get('v.isExchangeOrder');
            var hasPointAmount = component.get('v.hasPointAmount');
            var maximumQuantity = component.get('v.maximumAmount');
    
            let listType = '';
            if (isExchangeOrder == true) {
                listType = 'wijmo_EXSuppliesOrderDisabledList';
            }
    
            //gw.lee 교환 필요
            var dataList = [];
            let listProductId = data.map(data => data.sProductItemId);
            dataList.push(evtData);
    
            this.sendMessage(component, {type:'setData', items: evtData}, listType);
            console.log('component.get("v.draftValues") ::: ' + component.get("v.draftValues"));
            var draftValues = component.get("v.draftValues");
            
            var isIncludes = false;
    
            if (FSIsMaterialPortal) {
                draftValues = data;
            }
            var thisinstanc = this;

            var isdisabledCheck = false;

            var isDraftValueSet = false;
            if (data.length > 0) {
                data.forEach((item, index) => {
                    if(item.Note == '재고 조회 필요') {
                        if(isDraftValueSet == false) {
                            isDraftValueSet = true;
                        }
                    }
                    //2024.01.03 seung yoon heo 단종일 경우 val 추가
                    if (disabledCheck && evtData.wonPartNum != undefined) {
                        if(item.Note == '재고 조회 필요') {
                            if (item.ProductCode == evtData.wonPartNum && evtData.fm_Available_Quantity == 0) { //24 01 23 hyungho.chun 단종인건도 가용수량 체크하는 하는 로직 추가 
                                var dialog = component.find('dialog');
    
                                var param = {
                                    message : '주문내역에서 해당 소모품 삭제해드릴까요?',
                                };
                                dialog.confirm(param, function(response) {
                                    console.log('response :' + response.result);
                                    if(response.result == true){
                                        data.splice(index, 1);
                                        thisinstanc.sendMessage(component, {type:'items', items: data}, listType);
                                        component.set('v.data', data);
                                    }
                                }, '단종주문내역');

                                isdisabledCheck = true;
                            }
                        } 
                    }
                    //2024.01.03 seung yoon heo 쌍방대치일 경우
                    // if (crossPartCheck) {
                    if (crossPartCheck && evtData.wonPartNum != undefined) { //24 01 23 hyungho.chun 원 단종 대치품 단종아닌경우만
                        if(item.Note == '재고 조회 필요') {
                            if (item.ProductCode == evtData.wonPartNum && item.ProductCode != evtData.ProductCode) {
                                 var dialog = component.find('dialog');
        
                                    var param = {
                                        message : '주문내역에 대치품 추가 되어 원 소모품 삭제해드릴까요?',
                                    };
                                    dialog.confirm(param, function(response) {
                                        console.log('response :' + response.result);
                                        if(response.result == true){
                                            data.splice(index, 1);
                                            thisinstanc.sendMessage(component, {type:'items', items: data}, listType);
                                            component.set('v.data', data);
                                        }
                                    }, '쌍방대치주문내역');
                            }
                        }
                    }
                });
            }
            //2024.02.01 seung yoon heo disabledCheck가 true일땐 항상 toast표출
            if (disabledCheck) {
                this.showToast('warning', '단종된 상품의 가용 수량이 없는 경우 구매가 불가능합니다.');	
                return;    
            }
     
            

            if(isDraftValueSet == true) {
                draftValues = data;
            }
    
            console.log('draftValues :: ' + JSON.stringify(draftValues));
            console.log('evtDelimiter > ' + evtDelimiter + ' / strTabId :' + strTabId);
            console.log('========================== data ===========================');
            console.log(JSON.stringify(data));
            console.log('========================== evtId ===========================');
            console.log(evtId);
    
            var requestedReturnQuantity = component.get('v.requestedReturnQuantity');
            console.log('requestedReturnQuantity => ' + requestedReturnQuantity);
    
    
                if (evtDelimiter == strTabId) {
    
                    if (evtType == 'add') {

                        // test PHJ
                        component.set('v.addPrdShipmentName', evtData.ShipmentName);
                        component.set('v.addPrdShipmentCode', evtData.DIVCODE);
        
                        //기존에 있는 데이터
                        let listProductId = data.map(data => data.sProductItemId);
                        let listproduct2Id = data.map(data => data.sProductId);
        
                        // 소모품 택배 주문시
                        // if (listProductId.length && listProductId.includes(evtProdId) && !isExchangeOrder) { 
                        if (listProductId.length && (listProductId.includes(evtProdId) || (evtData.PART_TYPE =='N' && listproduct2Id.includes(evtData.sProductId))) && !isExchangeOrder) { //24 01 22 hyungho.chun 소모품아닌 경우 분기 추가
                            
                            var _this = this;
        
                            data.forEach(function (data) {
                                if(data.PromotionPrice != null){
                                    data.promotionCellColor = "font-color-red";
                                }
                                // if (data.sProductItemId == evtProdId) {
                                if ((data.sProductItemId == evtProdId)|| (  evtData.PART_TYPE =='N' && data.sProductId == evtData.sProductId )) { //24 01 22 hyungho.chun 소모품아닌 경우 분기 추가
        
                                    //1. data 셋팅 (draft value에 있으면 해당 value에서 데이터 가져와서)
                                    //2. draft에 셋팅
                                    if (draftValues.length) {
                                        for (let i in draftValues) {
                                            if (draftValues[i].sProductItemId == data.sProductItemId) {
        
                                                let qty = parseInt(draftValues[i].QTY);
                                                console.log('qqqqq : ' + qty);
        
                                                //23.10.18 gw.lee
                                                //23.11.22 gw.lee
                                                //자재 포탈에서 넘어와 재고 조회가 필요한 경우, 요청 수량값으로 셋팅
                                                if (data.Note == '재고 조회 필요' && qty > 0) {
                                                    data.QTY = qty;
                                                } else {
                                                    data.QTY = (qty) + 1        
                                                }
                                                // data.QTY = (qty) + 1

                                                if (maximumQuantity <= (qty + 1) && component.get('v.bulkOrderManager') == false) {
                                                    var toast = $A.get("e.force:showToast");
                                                    toast.setParams({
                                                        "message": "최대주문 초과.",
                                                        "type": "error"
                                                    });
                                                    toast.fire();
                                                    //gw.lee 23.10.04
                                                    //최디재문 초과 시, 수량 1 -> 50변경
                                                    data.QTY = 50;
                                                }
        
                                                console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                                                console.log('data.QTY ->' + data.QTY);
                                                console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                                                console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                                                console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);
                                                console.log('evtData.originConsumerPrice -> ' + evtData.originConsumerPrice);
        
                                                if (evtData.fm_Available_Quantity < data.QTY) {
                                                    evtData.PurchaseType = '품절 주문';
                                                    data.PurchaseType = '품절 주문';
                                                    evtData.ShipmentCode = evtData.DIVCODE;
                                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                    data.ShipmentCode = evtData.DIVCODE;
                                                    data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                } else if (evtData.fm_Available_Quantity >= data.QTY) {
                                                    evtData.PurchaseType = '일반 주문';
                                                    data.PurchaseType = '일반 주문';
                                                    if (evtData.EXQuantity >= data.QTY) {
                                                        evtData.ShipmentCode = 'PH8002';
                                                        evtData.ShipmentName = '소모품센터';
                                                        data.ShipmentCode = 'PH8002';
                                                        data.ShipmentName = '소모품센터';
                                                    } else if (evtData.DIVQuantity >= data.QTY) {
                                                        evtData.ShipmentCode = evtData.DIVCODE;
                                                        evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                        data.ShipmentCode = evtData.DIVCODE;
                                                        data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                    } else {
                                                        evtData.ShipmentCode = evtData.DIVCODE;
                                                        evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                        data.ShipmentCode = evtData.DIVCODE;
                                                        data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                    }
                                                }
        
                                                data.Price = evtData.Price;
                                                data.PromotionPrice = evtData.PromotionPrice;
                                                if (component.get('v.orderTotal') + data.Price < component.get('v.parseFee') && component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false  && data.PARCEL_YN == 'Y') {
                                                    var parseFeeMsg = '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.';
        
                                                    var toastParseFee = $A.get("e.force:showToast");
                                                    toastParseFee.setParams({
                                                    "message": parseFeeMsg,
                                                    "type": "info"
                                                    });
                                                    toastParseFee.fire();
                                                    
                                                    data.Note = '최소주문금액 미달';
        
                                                } 
                                                //gw.lee 24.01.08
                                                //단종된 상품 주문 가능 수정
                                                else if (data.DISABLED_TYPE == 'Y' && data.QTY > data.fm_Available_Quantity) {	
                                                    data.QTY = data.fm_Available_Quantity;
                                                    data.PurchaseType = '일반 주문';	
                                                    _this.showToast('warning', '단종된 상품은 가용수량을 초과할 수 없습니다.');		
                                                    //data.Note = '단종상품 주문불가';
                                                }
                                                else {
                                                    //23 12 19 hyungho.chun
                                                    if(data.Note != '택배 불가 상품'){
                                                        if(evtData.Note != null && evtData.Note == '택배 불가 상품'){
                                                            data.Note = '택배 불가 상품';
                                                        }else{  
                                                            data.Note = null;
                                                        }
                                                        
                                                    }
                                                }
        
                                                data.ASCPrice = evtData.ASCPrice;
                                                data.ObsMemberPrice = evtObsMemberPrice;
                                                data.ShipmentCode = evtData.ShipmentCode;
                                                data.originConsumerPrice =  evtData.originConsumerPrice;
        //
        //                                        draftValues[i].QTY = data.QTY;
        //                                        draftValues[i].Price = data.Price;
        //                                        draftValues[i].ASCPrice = data.ASCPrice;
        //                                        draftValues[i].Note = data.Note;
        //                                        draftValues[i].SUBSTITUTE = evtSubstitute;
        //                                        draftValues[i].PurchaseType = data.PurchaseType;
        ////                                        draftValues[i].divCode = data.ShipmentCode;
        //                                        draftValues[i].ObsMemberPrice = data.ObsMemberPrice;
        //                                        draftValues[i].ShipmentCode = data.ShipmentCode;
        //                                        draftValues[i].PromotionPrice = data.PromotionPrice;
        //                                        draftValues[i].originConsumerPrice = data.originConsumerPrice;
        
                                                console.log(JSON.stringify(draftValues[i]));
        
                                                // 자재포탈 인입 시 재고 조회를 통하여 데이터를 세팅하는 경우
                                                if (FSIsMaterialPortal) {
                                                    data.cellColor = '';
                                                    data.isForMaterialPortalValid = '';
        
                                                    draftValues[i].cellColor = '';
                                                    draftValues[i].isForMaterialPortalValid = 'Y';
        
                                                }
                                                
                                                if(data.isForMaterialPortalValid == 'N') {
                                                    draftValues[i].isForMaterialPortalValid = 'Y';
                                                    data.isForMaterialPortalValid = 'Y';
                                                }
                                            }
                                        }
        
        //                                component.find('orderListDt').set("v.draftValues", draftValues);
                                        component.set("v.draftValues", draftValues);
                                        component.set('v.orderTotal', component.get('v.orderTotal') + data.Price);
                                        console.log('444 total : ' + component.get('v.orderTotal'));
        
                                    } else {
                                        data.PurchaseType = evtPurchaseType;
        
                                        data.QTY = (data.QTY + 1)
                                        if (maximumQuantity <= data.QTY && component.get('v.bulkOrderManager') == false) {
                                            var toast = $A.get("e.force:showToast");
                                            toast.setParams({
                                                "message": "최대주문 초과.",
                                                "type": "error"
                                            });
                                            toast.fire();
                                            //gw.lee 23.10.04
                                            //최디재문 초과 시, 수량 1 -> 50변경
                                            data.QTY = 50;
                                        }
        
                                        console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                                        if(evtData.QTY == undefined) evtData.QTY = 1;
                                        console.log('evtData.QTY ->' + evtData.QTY);
                                        console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                                        console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                                        console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);
                                        console.log('위치 check :::: ');

        
                                        if (evtData.fm_Available_Quantity < data.QTY) {
                                            evtData.PurchaseType = '품절 주문';
                                            evtData.ShipmentCode = evtData.DIVCODE;
                                            evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                            data.PurchaseType = '품절 주문';
                                            data.ShipmentCode = evtData.DIVCODE;
                                            data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                        } else if (evtData.fm_Available_Quantity >= data.QTY) {
                                            evtData.PurchaseType = '일반 주문';
                                            if (evtData.EXQuantity >= 1  && evtData.EXQuantity >= data.QTY) {
                                                evtData.ShipmentCode = 'PH8002';
                                                evtData.ShipmentName = '소모품센터';
                                                data.ShipmentCode = 'PH8002';
                                                data.ShipmentName = '소모품센터';
                                            } else if (evtData.DIVQuantity >= 1) {
                                                evtData.ShipmentCode = evtData.DIVCODE;
                                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                data.ShipmentCode = evtData.DIVCODE;
                                                data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                            } else {
                                                evtData.ShipmentCode = evtData.DIVCODE;
                                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                data.ShipmentCode = evtData.DIVCODE;
                                                data.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                            }
                                        }
        
                                        // if (data.EXQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                                        //     data.DIV_CODE = 'PH8002';
                                        //
                                        // } else if (data.DIVQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                                        //     data.DIV_CODE = data.DIVCODE;
                                        //
                                        // } else {
                                        //     data.PurchaseType = '품절 주문';
                                        //     data.DIV_CODE = data.DIVCODE;
                                        //
                                        // }
                                        data.Price = evtData.Price;
                                        data.SUBSTITUTE = evtData.SUBSTITUTE;
                                        data.Id = evtData.Id;
                                        
                                        if (component.get('v.orderTotal') + data.Price< component.get('v.parseFee') && component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false && data.PARCEL_YN == 'Y') {
                                            _this.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                                            data.Note = '최소주문금액 미달';
        
                                        } 
                                        //gw.lee 24.01.08
                                        //단종된 상품 주문 가능 수정
                                        else if (data.DISABLED_TYPE == 'Y' && data.QTY > data.fm_Available_Quantity) {    
                                            data.QTY = data.fm_Available_Quantity;
                                            data.PurchaseType = '일반 주문';                             
                                            _this.showToast('warning', '단종된 상품은 가용수량을 초과할 수 없습니다.');		
                                            // data.Note = '단종상품 주문불가';
                                        }
                                        else {
                                            //23 12 19 hyungho.chun
                                            if(data.Note != '택배 불가 상품'){
                                                data.Note = null;
                                            }
    
                                        }
        //                                data.ASCPrice = data.QTY * evtData.ASCPrice;
                                        data.ObsMemberPrice = evtObsMemberPrice;
        
        //                                draftValues.push({
        //                                    'QTY': data.QTY
        //                                    , 'Price': data.Price
        //                                    , 'ASCPrice': data.ASCPrice
        //                                    , 'sProductItemId': data.sProductItemId
        //                                    , 'Note': data.Note
        //                                    , 'SUBSTITUTE': data.Substitute
        //                                    , 'ShipmentCode': data.ShipmentCode
        //                                    , 'PurchaseType': data.PurchaseType
        //                                    , 'Id': data.Id
        //                                    , 'ObsMemberPrice' : data.ObsMemberPrice
        //                                });
        
        //                                component.find('orderListDt').set("v.draftValues", draftValues);
                                        component.set("v.draftValues", draftValues);
                                        component.set('v.orderTotal', component.get('v.orderTotal') + data.Price);
                                        console.log('555 total : ' + component.get('v.orderTotal'));
        
                                    }
                                }
                            });
                            // 소모품 교환 주문 시
                        } else if (listProductId.length && listProductId.includes(evtProdId) && isExchangeOrder) {
                            // data.forEach((item) => {
                            //     for (let i in draftValues) {
                            //         console.log('draftValues[i].productRequestLineItemId -> ' + draftValues[i].productRequestLineItemId);
                            //         console.log('item.productRequestLineItemId -> ' + item.productRequestLineItemId);
                            //         console.log('draftValues[i].ProductCode -> ' + draftValues[i].ProductCode);
        
                            //         if (evtId == item.productRequestLineItemId) {
                            //             if (draftValues[i].ProductCode != item.ProductCode || draftValues[i].DIVCODE != item.DIVCODE) {
                            //                 console.log('draftValues[i]');
                            //                 console.log(draftValues[i]);
                            //             }
                            //         }
                            //     }
                            // });
                            var _this = this;
        
                            data.forEach(function (data) {
                                if(data.PromotionPrice != null){
                                    data.promotionCellColor = "font-color-red";
                                }
                                if (data.sProductItemId == evtProdId) {
        
                                    //1. data 셋팅 (draft value에 있으면 해당 value에서 데이터 가져와서)
                                    //2. draft에 셋팅
                                    if (draftValues.length) {
                                        for (let i in draftValues) {
                                            if (draftValues[i].sProductItemId == data.sProductItemId) {
        
                                                // let qty = parseInt(draftValues[i].QTY);
                                                // data.QTY = (qty) + 1
                                                // if (maximumQuantity <= (qty + 1) && component.get('v.bulkOrderManager') == false) {
                                                //     this.showToast('error', '최대주문 초과');
                                                //     data.QTY = 1;
                                                // }
        
                                                console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                                                //if(evtData.QTY == undefined) evtData.QTY = 1;
                                                console.log('evtData.QTY ->' + evtData.QTY);
                                                console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                                                console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                                                console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);
                                                if (evtData.fm_Available_Quantity < evtData.QTY) {
                                                    evtData.PurchaseType = '품절 주문';
                                                    evtData.ShipmentCode = evtData.DIVCODE;
                                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                } else if (evtData.fm_Available_Quantity >= evtData.QTY) {
                                                    evtData.PurchaseType = '일반 주문';
                                                    if (evtData.EXQuantity >= 1  && evtData.EXQuantity >= evtData.QTY) {
                                                        evtData.ShipmentCode = 'PH8002';
                                                        evtData.ShipmentName = '소모품센터';
                                                    } else if (evtData.DIVQuantity >= 1) {
                                                        evtData.ShipmentCode = evtData.DIVCODE;
                                                        evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                    } else {
                                                        evtData.ShipmentCode = evtData.DIVCODE;
                                                        evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                                    }
                                                }
        
                                                // if (data.QTY > data.fm_Available_Quantity) {
                                                //     data.PurchaseType = '품절 주문';
                                                //     data.DIV_CODE = data.DIVCODE;
                                                // }
                                                // if (data.EXQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                                                //     data.DIV_CODE = 'PH8002';
                                                //
                                                // } else if (data.DIVQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity
                                                // ) {
                                                //     data.DIV_CODE = data.DIVCODE;
                                                //
                                                // } else {
                                                //     data.PurchaseType = '품절 주문';
                                                //     data.DIV_CODE = data.DIVCODE;
                                                // }
                                                data.Price = evtData.Price;

                                                if (component.get('v.orderTotal') + data.Price< component.get('v.parseFee') && component.get('v.isExchangeOrder') == false && data.PARCEL_YN == 'Y') {
                                                    this.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                                                    data.Note = '최소주문금액 미달';
        
                                                } 
                                                //gw.lee 24.01.08
                                                //단종된 상품 주문 가능 수정
                                                else if (data.DISABLED_TYPE == 'Y' && data.QTY > data.fm_Available_Quantity) {		
                                                    data.QTY = data.fm_Available_Quantity;
                                                    data.PurchaseType = '일반 주문';
                                                    _this.showToast('warning', '단종된 상품은 가용수량을 초과할 수 없습니다.');		
                                                    //data.Note = '단종상품 주문불가';
                                                } 
                                                else {
                                                    //23 12 19 hyungho.chun
                                                    if(data.Note != '택배 불가 상품'){
                                                        data.Note = null;
                                                    }
                                                }
        
        
                                                data.ASCPrice = evtData.ASCPrice;
                                                data.productRequestLineItemId = evtId;
                                                data.ObsMemberPrice = evtObsMemberPrice;
        
                                                console.log(JSON.stringify(draftValues[i]));
        
                                            }
                                        }
        
        //                                component.find('orderListDt').set("v.draftValues", draftValues);
                                        component.set("v.draftValues", draftValues);
                                        if (!isExchangeOrder) {
                                            component.set('v.orderTotal', component.get('v.orderTotal') + data.Price);
                                            console.log('666 total : ' + component.get('v.orderTotal'));
        
                                        }
        
                                    } else {
                                        // data.QTY = (data.QTY + 1)
                                        // if (maximumQuantity <= (data.QTY + 1) && component.get('v.bulkOrderManager') == false) {
                                        //     this.showToast('error', '최대주문 초과');
                                        //     data.QTY = 1;
                                        // }

                                        // 교환 요청시 소모품 택배 == 0
                                        //            OBS == 기존 수량 그대로
                                        if (isExchangeOrder && hasPointAmount) {
                                            data.QTY = data.QTY;
                                        } else if (isExchangeOrder && !hasPointAmount) {
                                            data.QTY = data.QTY == undefined ? 0 : data.QTY;
                                        }
        
                                        console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                                        //if(evtData.QTY == undefined) evtData.QTY = 1;
                                        console.log('evtData.QTY ->' + evtData.QTY);
                                        console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                                        console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                                        console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);
                                        if (evtData.fm_Available_Quantity < evtData.QTY) {
                                            evtData.PurchaseType = '품절 주문';
                                            evtData.ShipmentCode = evtData.DIVCODE;
                                            evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                        } else if (evtData.fm_Available_Quantity >= evtData.QTY) {
                                            evtData.PurchaseType = '일반 주문';
                                            if (evtData.EXQuantity >= 1  && evtData.EXQuantity >= evtData.QTY) {
                                                evtData.ShipmentCode = 'PH8002';
                                                evtData.ShipmentName = '소모품센터';
                                            } else if (evtData.DIVQuantity >= 1) {
                                                evtData.ShipmentCode = evtData.DIVCODE;
                                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                            } else {
                                                evtData.ShipmentCode = evtData.DIVCODE;
                                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                            }
                                        }
        
                                        // if (data.EXQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                                        //     data.DIV_CODE = 'PH8002';
                                        //
                                        // } else if (data.DIVQuantity >= data.QTY && data.EXQuantity <= data.fm_Available_Quantity) {
                                        //     data.DIV_CODE = data.DIVCODE;
                                        //
                                        // } else {
                                        //     data.PurchaseType = '품절 주문';
                                        //     data.DIV_CODE = data.DIVCODE;
                                        // }
                                        data.Price = evtData.Price;
                                        data.SUBSTITUTE = evtData.SUBSTITUTE;
                                        data.Id = evtData.Id;
                                        if (component.get('v.orderTotal') + data.Price  < component.get('v.parseFee') && component.get('v.isExchangeOrder') == false && data.PARCEL_YN == 'Y') {
                                            this.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                                            data.Note = '최소주문금액 미달';
        
                                        } else {
                                            //23 12 19 hyungho.chun
                                            if(data.Note != '택배 불가 상품'){
                                                data.Note = null;
                                            }                                            
                                        }
                                        data.ASCPrice = data.QTY * evtData.ASCPrice;
                                        data.ObsMemberPrice = evtObsMemberPrice;
        
                                        data.PurchaseType = evtPurchaseType;
                                        data.productRequestLineItemId = evtId;
                                        component.set("v.draftValues", draftValues);
                                        if (!isExchangeOrder) {
                                            component.set('v.orderTotal', component.get('v.orderTotal') + data.Price);
                                        }
                                        console.log('111 total : ' + component.get('v.orderTotal'));
                                    }
                                }
                            });
                        }
                        // 주문 파트 데이터 없는 경우 Add
                        else {
                            evtData.PurchaseType = evtPurchaseType;
                            evtData.SUBSTITUTE = evtSubstitute;
                            if(evtData.PromotionPrice != null){
                                evtData.promotionCellColor = "font-color-red";
                            }

                            //23.11.01 gw.lee
                            
                                                           
        
                            // gw.lee 23.11.01
                            // 교환 요청시 수량 고정
                            //소모품 택배 주문일 경우, 기본 수량 1
                            //교환 주문일 경우, 기본 수량 0
                            let reqQuantity  = evtData.reqQty;
                            // if (reqQuantity == undefined) {
                            //     reqQuantity = requestedReturnQuantity != undefined ? requestedReturnQuantity : evtData.reqQty;
                            // }

                            if (isExchangeOrder == true) {
                                if ((hasPointAmount || evtData.ChannelTypeCode != 'V')) {
                                    //reqQuantity = reqQuantity == undefined ? requestedReturnQuantity == undefined ? 0 : requestedReturnQuantity : reqQuantity;
                                    if (hasPointAmount && reqQuantity > evtData.fm_Available_Quantity) {
                                        this.showToast('warning', '요청수량이 가용수량보다 많을 수 없습니다.');	
                                        return false;
                                    } else {
                                        evtData.QTY = reqQuantity;    
                                    }
                                } else if (reqQuantity && !hasPointAmount) {
                                    evtData.QTY = reqQuantity;
                                } else if (!hasPointAmount) {
                                    evtData.QTY = 0;
                                }
                            } else {
                                evtData.QTY = 1;
                            }
        
        
                            console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                            if(evtData.QTY == undefined) evtData.QTY = 1;
                            console.log('evtData.QTY ->' + evtData.QTY);
                            console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                            console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                            console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);

                            if (evtData.fm_Available_Quantity < evtData.QTY) {
                                evtData.PurchaseType = '품절 주문';
                                evtData.ShipmentCode = evtData.DIVCODE;
                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                            } else if (evtData.fm_Available_Quantity >= evtData.QTY) {
                                evtData.PurchaseType = '일반 주문';
                                if (evtData.EXQuantity >= 1  && evtData.EXQuantity >= evtData.QTY) {
                                    evtData.ShipmentCode = 'PH8002';
                                    evtData.ShipmentName = '소모품센터';
                                } else if (evtData.DIVQuantity >= 1) {
                                    evtData.ShipmentCode = evtData.DIVCODE;
                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                } else {
                                    evtData.ShipmentCode = evtData.DIVCODE;
                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                }
                            }
        
                            /////04.14 순서 변경 및 수정
                            if (component.get('v.orderTotal') + evtData.Price * evtData.QTY < component.get('v.parseFee')) {
                                if (component.get('v.orderTotal') < component.get('v.parseFee') && evtData.QTY == 0 && isExchangeOrder && !hasPointAmount) {
                                    //24.01.23 gw.lee 이용석 책임님 승인 최초 등록 제거
                                    // evtData.Note = '최초 등록';
                                } else if (component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false && evtData.PARCEL_YN == 'Y'){
                                    this.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                                    evtData.Note = '최소주문금액 미달';
                                } else if (evtData.DISABLED_TYPE == 'Y' && evtData.QTY > evtData.fm_Available_Quantity) {		
                                    evtData.QTY = evtData.fm_Available_Quantity;
                                    evtData.PurchaseType = '일반 주문';
                                    this.showToast('warning', '단종된 상품은 가용수량을 초과할 수 없습니다.');			
                    
                                    //evtData.Note = '단종상품 주문불가'
                                }
            
                            } else {
                                // data.Note = null;
                                //23 12 19 hyungho.chun 택배 불가 상품은 null로 바꾸면 안됨
                                if(evtData.Note != '택배 불가 상품'){
                                    evtData.Note = null;
                                }
                                
                            }
            
                            // data.productRequestLineItemId = evtId;
                            evtData.productRequestLineItemId = evtId;
                            evtData.ObsMemberPrice = evtObsMemberPrice;
                            evtData.originConsumerPrice = evtOriginConsumerPrice;
        
                            console.log(evtData.ObsMemberPrice);
                            console.log('draftValues222221 : '+ draftValues);
                            try {
                                
                                //draftValues.push(evtData);
                                data.push(JSON.parse(JSON.stringify(evtData)));
                            } catch (e) {
                                console.log('e :::: ' + e);
                            }
                            console.log(draftValues);
                            console.log(JSON.stringify(draftValues));
        
        //                    component.find('orderListDt').set("v.draftValues", draftValues);
                            component.set("v.draftValues", draftValues);
                            component.set('v.orderTotal', component.get('v.orderTotal') + evtData.Price * evtData.QTY);
                            console.log('222 total : ' + component.get('v.orderTotal'));
        
                        }
                        console.log('exchangeORer ::: ' + component.get('v.isExchangeOrder'));
                        console.log('hasPointAmount ::: ' + component.get('v.hasPointAmount'));

                        //23.10.01 PHJ
                        if(component.get('v.orderTotal') >= 5000){
                            // let temp = [];
                            // for(var i=0; i<component.get('v.data').length; i++){
                            //     temp.push(component.get('v.data')[i]);
                            //     //gw.lee 23.10.11 단종상품일 경우, 주문 Note유지
                            //     if(component.get('v.data')[i].Note == '최소주문금액 미달' && component.get('v.data')[i].Note != '단종상품 주문불가'){
                            //         component.get('v.data')[i].Note = null;         
                            //     }
                            // } 
                            component.get('v.data').forEach((item) => {
                                if(item.Note == '최소주문금액 미달' && item.Note != '단종상품 주문불가'){
                                    //23 12 19 hyungho.chun
                                    if(item.Note != '택배 불가 상품'){
                                        item.Note = null;         
                                    }
                                }
                            });
                        }
                        
        
                        let listType = '';
                        if (isExchangeOrder == true) {
                            listType = 'wijmo_EXSuppliesOrderDisabledList';
                        }
                        
                        //gw.lee 23.10.17
                        //원 => 쌍방대치 내릴 경우, 원 삭제용 파람 추가
                        // let originId = event.getParam('originId');

                        // if (originId) {
                        //     for (let i = 0; i < data.length; i++) {
                        //         if (data[i].sProductId == originId) {
                        //             data.splice(i, 1);
                        //             i--;
                        //         }
                        //     }
                        // }

                        // // 2023.12.08 seung yoon heo 출고부서 한글명
                        // for (let i = 0; i < data.length; i++) {
                        //     if(data[i].ShipmentCode != 'PH8002'){
                        //         data[i].ShipmentName = ShipmentNameMap.get(data[i].DIVCODE);
                        //     } else {
                        //         data[i].ShipmentName = '소모품센터';
                        //     }
                        // }


                        component.set("v.data", data);


                        this.sendMessage(component, {type:'items', items: component.get('v.data')}, listType);
                        //23 09 22 hyungho.chun 바로아래주석 테스트
                        //this.sendMessage(component, {type:'setData', items: component.get('v.data')}, listType);     

                        console.log('Start====================');
                        console.log(JSON.stringify(component.get('v.data')));
                        console.log('End====================');
                        var standardOrderDataList = [];
                        var soldOutOrderDataList = [];
        
                        data.forEach((item) => {
                            if(item.PromotionPrice != null){
                                item.promotionCellColor = "font-color-red";
                            }
                            if (item.PurchaseType == '일반 주문') {
                                standardOrderDataList.push(item);
                            } else {
                                soldOutOrderDataList.push(item);
                            }
                        });
                        helper.getData(component, helper, standardOrderDataList, soldOutOrderDataList);
                    } 
                    else if(evtType == 'click'){
                        let listProductId = data.map(data => data.sProductItemId);
                        console.log('evtType : '+ evtType + '  listProductId.lengt : ' +listProductId.length  +'     '+ listProductId.includes(evtProdId));
        
                        if(!listProductId.includes(evtProdId)){
                            evtData.PurchaseType = evtPurchaseType;
                            evtData.SUBSTITUTE = evtSubstitute;
                            if(evtData.PromotionPrice != null){
                                evtData.promotionCellColor = "font-color-red";
                            }
                            evtData.QTY = 1;
                            // 교환 요청시 수량 고정
                            if (isExchangeOrder == true && hasPointAmount == true) {
                                evtData.QTY = requestedReturnQuantity
                            } else if (isExchangeOrder) {
                                evtData.QTY = 0;
                            }
        
                            console.log('evtData.fm_Available_Quantity -> ' + evtData.fm_Available_Quantity);
                            if(evtData.QTY == undefined) evtData.QTY = 1;
        
                            console.log('evtData.QTY ->' + evtData.QTY);
                            console.log('evtData.DIVQuantity  ->  ' + evtData.DIVQuantity);
                            console.log('evtData.EXQuantity -> ' + evtData.EXQuantity);
                            console.log('evtData.DIVCODE -> ' + evtData.DIVCODE);
                            if (evtData.fm_Available_Quantity < evtData.QTY) {
                                evtData.PurchaseType = '품절 주문';
                                evtData.ShipmentCode = evtData.DIVCODE;
                                evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                            } else if (evtData.fm_Available_Quantity >= evtData.QTY) {
                                evtData.PurchaseType = '일반 주문';
                                if (evtData.EXQuantity >= 1  && evtData.EXQuantity >= evtData.QTY) {
                                    evtData.ShipmentCode = 'PH8002';
                                    evtData.ShipmentName = '소모품센터';
                                } else if (evtData.DIVQuantity >= 1) {
                                    evtData.ShipmentCode = evtData.DIVCODE;
                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                } else {
                                    evtData.ShipmentCode = evtData.DIVCODE;
                                    evtData.ShipmentName = ShipmentNameMap.get(evtData.DIVCODE);
                                }
                            }
        
                            /////04.14 순서 변경 및 수정
                            if (component.get('v.orderTotal') + evtData.Price < component.get('v.parseFee') && component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false && evtData.PARCEL_YN == 'Y') {
                                this.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                                // data.Note = '최소주문금액 미달';
                                evtData.Note = '최소주문금액 미달';
        
                            } else {
                                // data.Note = null;
                                //23 12 19 hyungho.chun
                                if(evtData.Note != '택배 불가 상품'){
                                    evtData.Note = null;
                                }                        
                            }
        
                            // data.productRequestLineItemId = evtId;
                            evtData.productRequestLineItemId = evtId;
                            evtData.ObsMemberPrice = evtObsMemberPrice;
                            evtData.originConsumerPrice = evtOriginConsumerPrice;
                            data.push(evtData);
        
                            component.set("v.draftValues", draftValues);
                            component.set('v.orderTotal', component.get('v.orderTotal') + evtData.Price);
                            console.log('333 total : ' + component.get('v.orderTotal'));
        
                            
                            let listType = '';
                            if (component.get('v.isExchangeOrder') == true) {
                                listType = 'wijmo_EXSuppliesOrderDisabledList';
                            }
        
                            component.set("v.data", data);
                            
                            this.sendMessage(component, {type:'items', items: component.get('v.data')}, listType);
                            //23 09 22 hyungho.chun 바로아래주석 테스트
                            //this.sendMessage(component, {type:'setData', items: component.get('v.data')}, listType);

                            console.log('Start====================');
                            console.log(JSON.stringify(component.get('v.data')));
                            console.log('End====================');
                            var standardOrderDataList = [];
                            var soldOutOrderDataList = [];
        
                            data.forEach((item) => {
                                if(item.PromotionPrice != null){
                                    item.promotionCellColor = "font-color-red";
                                }
                                if (item.PurchaseType == '일반 주문') {
                                    standardOrderDataList.push(item);
                                } else {
                                    soldOutOrderDataList.push(item);
                                }
                            });
                            helper.getData(component, helper, standardOrderDataList, soldOutOrderDataList);
                        }
                        
                }
            }
        } catch (e) {
            console.log('e :::: ' + e);
        }
    },
    /* 데이터테이블 수량 변경시  sProductItemId*/
    fnGetWijmoDraft: function (component, event, helper, row) {
        //let
        console.log('데이터테이블 수량 변경  ::: ');
        let currentDraft = component.get("v.draftValues");
        var stoargeMap = component.get('v.stoargeMap');
        let draftValues = row; //현재 수정한 데이터테이블
        console.log(draftValues);
        let wijimoName = 'wijmo_EXSuppliesOrderList';


        let sProductItemId = draftValues.sProductItemId;
        
        console.log('타입확인 : '+ typeof draftValues.QTY );

        let qty = parseInt(draftValues.QTY == null || draftValues.QTY < 0 ? 0 : draftValues.QTY);

        // if (qty < 0 ) {
        //     qty = 0;
        // }

        console.log('갯수 : '+ qty);
//        let qty = parseInt(data.QTY__c);
        let dataDT = component.get("v.data");

        let unitPrice;
        let unitASCPrice;

        var maximumQuantity = component.get('v.maximumAmount');

        var quantityMap = component.get('v.quantityMap');

        var totalSum = 0;
        //23 09 21 hyungho.chun 임시 판매금액 저장
        var totalTemp = 0;

        // 2023.10.19 seung yoon heo 최소주문금액 토스트 메세지 수정
        var isLimit = false;
        var totalSumTemp = 0;

        var _this = this;
        dataDT.forEach(function (data) {
            //draftValues가 있을 때
            // if (data.sProductItemId == sProductItemId) {
            //24.02.28 gw.lee
            //1) 분해도 => 주문내역 + 소모품이 아닐 경우, 사업부 Location정보
            //2) 부품   => 주문내역, 적치장소 + 사업부 재고정보 
            //stoargeMap : 부품 => 주문내역 재고정보, 1번 과 2번 정보가 다른 경우 매칭 정보 저장
            if (row.Note == '재고 조회 필요') {
				if (row.sProductItemId == data.sProductItemId) {
					data.QTY = qty;
				}
			} else {
				if ((quantityMap[data.sProductItemId] != undefined && data.sProductItemId == sProductItemId) ||
                stoargeMap[data.sProductId] != undefined) {
				
                var divView = (quantityMap[data.sProductItemId] != undefined && data.sProductItemId == sProductItemId);
				var houseView = false;
                //사업부가 서로 다르고 현재 제품은 같고 현재 row의 사업부가 다른경우
				if (!divView && stoargeMap[data.sProductId].sProductId == data.sProductId && data.sProductId == row.sProductId && stoargeMap[data.sProductId].sProductItemId != row.sProductItemId) {
					houseView = true;
				}
                
                var data2;
                var isPass = false;
                if (!divView && houseView) {
                    data2 = stoargeMap[data.sProductId];
                    isPass = true;
                } else if (divView) {
                    data2 = quantityMap[data.sProductItemId];	
                    isPass = true;
                }
                
                console.log('data.QTY ::: ' , data.QTY);
                console.log('qty ::: ' , qty);

                if (isPass) {
                    unitPrice = parseInt(data.Price) / parseInt(data.QTY);
                    unitASCPrice = parseInt(data.ASCPrice) / parseInt(data.QTY);
    
                    data.QTY = qty;
                    data.divShipmentCode = data2.divShipmentCode;
                    data.divShipmentName = data2.divShipmentName;
                    
                    if (maximumQuantity <= qty && component.get('v.bulkOrderManager') == false) {
    
                        console.log('data.QTY1 ::: ' , data.QTY);
    
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "message": "최대주문 초과.",
                            "type": "error"
                        });
                        toast.fire();
    
                        //gw.lee 23.10.04
                        //최디재문 초과 시, 수량 1 -> 50변경
                        data.QTY = 50;
    
                    } else {
                        console.log('data.QTY2 ::: ' , data.QTY);
                        //23 12 27 hyungho.chun  || data2.fm_Available_Quantity == 0 추가 (품절주문에서 0으로 수량바꿨을때 일반주문으로바뀌던부분 보완)
                        if (data.QTY > data2.fm_Available_Quantity  || data2.fm_Available_Quantity == 0) {
                            data.PurchaseType = '품절 주문';
                            data.ShipmentCode = data.DIVCODE;
                            data.ShipmentName = data.divShipmentName;
                            console.log('data.QTY3 ::: ' , data.QTY);
                        } else {
                            // if (data.EXQuantity >= data.QTY) {
                            //     data.ShipmentCode = 'PH8002';
    
                            // } else if (data.DIVQuantity >= data.QTY) {
                            //     data.ShipmentCode = data.DIVCODE;
    
                            // } else {
                            //     data.PurchaseType = '품절 주문';
                            //     data.ShipmentCode = data.DIVCODE;
                            // }
                            data.PurchaseType = '일반 주문';
                            console.log('data.QTY4 ::: ' , data.QTY);
                            if (data2.EXQuantity >= data.QTY && data2.EXQuantity <= data2.fm_Available_Quantity) {
                                console.log('data.QTY5 ::: ' , data.QTY);
                                data.ShipmentCode = 'PH8002';
                                data.ShipmentName = '소모품센터';
                            } else if (data2.DIVQuantity >= data.QTY && data2.EXQuantity <= data2.fm_Available_Quantity) {
                                console.log('data.QTY6 ::: ' , data.QTY);
                                data.ShipmentCode = data2.DIVCODE;
                                data.ShipmentName = data2.divShipmentName;
                            } else {
                                console.log('data.QTY7 ::: ' , data.QTY);
                                data.ShipmentCode = data2.DIVCODE;
                                data.ShipmentName = data2.divShipmentName;
                            }
                        }
                        console.log('data.QTY8 ::: ' , data.QTY);
                        // data.Price = qty * unitPrice;
                        // data.ASCPrice = qty * unitASCPrice;
                        if (data2.DISABLED_TYPE == 'Y' && data.QTY > data2.fm_Available_Quantity) {
                            data.QTY = data2.fm_Available_Quantity;
                            data.PurchaseType = '일반 주문';
                            _this.showToast('warning', '단종된 상품은 가용수량을 초과할 수 없습니다.');
    
                            //data.Note = '단종상품 주문불가'
                        }
                        console.log('data.QTY9 ::: ' , data.QTY);
    
                        totalSum += data.Price * data.QTY;
    
    
                        if(data.PromotionPrice != null){
                            data.SaleAmount = data.PromotionPrice * (data.QTY);
                        }else{
                            data.SaleAmount = data.Price * (data.QTY);
                        }
                        if(data.SaleAmount != null && data.SaleAmount != 0){
                            totalTemp += data.SaleAmount;
                        }
                    }
                }
            }	
        }
    });

        var standardOrderDataList = [];
        var soldOutOrderDataList = [];

        console.log('dataDT plz :: ',dataDT);
        dataDT.forEach((item, index) => {
            
            if (item.PurchaseType == '일반 주문') {
                standardOrderDataList.push(item.data);
            } else {
                soldOutOrderDataList.push(item.data);
            }
            
            totalSumTemp += item.Price * item.QTY;

            //PHJ 
            // if (item.EXQuantity >= 1  && item.EXQuantity >= item.QTY) {
			// 	item.ShipmentCode = 'PH8002';
			// 	item.ShipmentName = '소모품센터';
			// }else if(item.EXQuantity >= 1  && item.EXQuantity + item.DIVQuantity  <= item.QTY){
            //     item.ShipmentCode = quantityMap[item.sProductItemId].ShipmentCode;
            //     item.ShipmentName = quantityMap[item.sProductItemId].ShipmentName;
			// } else {
            //      item.ShipmentCode = quantityMap[item.sProductItemId].ShipmentCode;
            //     item.ShipmentName = quantityMap[item.sProductItemId].ShipmentName;
            // }


            // 2023.10.19 seung yoon heo 최소주문금액 토스트 메세지 수정
            // if (component.get('v.orderTotal') + item.Price * item.QTY < component.get('v.parseFee') && component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false) {
            if (index == dataDT.length - 1 && totalSumTemp < component.get('v.parseFee') && component.get('v.costLimitManager') == false && component.get('v.isExchangeOrder') == false && dataDT.PARCEL_YN == 'Y') {
                helper.showToast('warning', '최소주문금액 ' + component.get('v.parseFee') + '원 미만입니다.');
                // item.Note = '최소주문금액 미달';
                isLimit = true;
            } 
        
            
        });

        // 2023.10.19 seung yoon heo 최소주문금액 토스트 메세지 수정
        if (isLimit) {
            for (let i = 0; i < dataDT.length; i++) {
                dataDT[i].Note = '최소주문금액 미달';
            }
        }else {
            for (let i = 0; i < dataDT.length; i++) {
                //23 12 19 hyungho.chun
                if(dataDT[i].Note != '택배 불가 상품' && dataDT[i].Note != '재고 조회 필요'){ //24 01 02 hyungho.chun 재고 조회 필요건은 그리드 수정했다고 note를 초기화 시키면 안된다
                    dataDT[i].Note = null;
                }                
            }
        }

        console.log('dataDT :::::: ' , JSON.stringify(dataDT));
        helper.getData(component, helper, standardOrderDataList, soldOutOrderDataList);
        component.set("v.data", dataDT);
        this.sendMessage(component, {type:'items', items: dataDT}, wijimoName);
    },
    fnFromMaterialPortalValidCheck: function (component, event, helper) {
        var data = component.get('v.data');
        console.log('data => ' + data);
        var isValid = true;
        data.forEach((item) => {

            console.log('item => ' + JSON.stringify(item));

            if (item.cellColor != undefined) {
                if(item.cellColor != '') {
                    isValid = false;
                    return isValid;
                }            
            }
        
            if (item.isForMaterialPortalValid != undefined) {
                if(item.isForMaterialPortalValid == 'N') {
                    isValid = false;
                    return isValid;
                }            
            }
        });

        return isValid;
    },

    gfnParsingUrl : function(name){
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
        return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    },

    // seung yoon
    fnOrderSave: function(component, event, helper, isCreateOrder){

        
        var offset =  new Date().getTimezoneOffset() * 60000;
	    var dateOffset = new Date(new Date().getTime() - offset);
        var isSuccess = false;
        component.set('v.showSpinner', true);
        component.set('v.currentTotalQty', 0);

        var isValid = true;
        // var consumableHeaderValues = component.get('v.consumableHeaderValues');
        var consumableLineItemValues = component.get('v.data');

        var FSIsMaterialPortal = component.get('v.FSIsMaterialPortal')
        console.log('FSIsMaterialPortal => ' + FSIsMaterialPortal);


        var toast = $A.get("e.force:showToast");
        toast.setParams({
            "message": "재고 조회를 다시 진행하여야 합니다.",
            "type": "info"
        });

        // 23.05.01 / 자재포탈에서 인입시 데이터 검증 여부 판별
        if (FSIsMaterialPortal) {
            isValid = helper.fnFromMaterialPortalValidCheck(component, event, helper);
            if (!isValid) {

                toast.fire();
                component.set("v.showSpinner", false);
                return;
            }
        }

        consumableLineItemValues.forEach((item) => {
           if(item.Note == '재고 조회 필요') {
               isValid = false;
               return;
           }
        });
        if(!isValid) {
            toast.fire();
            component.set("v.showSpinner", false);
            return;
        }

        console.log('FSIsMaterialPortal => ' + FSIsMaterialPortal);
        var focusedTabId;
        if (FSIsMaterialPortal) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                console.log('response  >> ' + JSON.stringify(response));
                focusedTabId = response.tabId;
                console.log('focusedTabId => ' + focusedTabId);

            }).catch(function (error) {
                console.log('Error -> ' + error);
            });
        }


        // // 소모품 주문 저장 전 front 단 Validation Check
        isValid = helper.fnConsumableOrderValidCheck(component, event, helper, consumableLineItemValues, isCreateOrder);
      

        console.log('isValid2 : ' + isValid);
        if (!isValid) {
            component.set("v.showSpinner", false);
            return;
        }

        //consumableLineItemValues =  // // 소모품 주문 저장 전 front 단 Validation Check
        //         isValid = helper.fnConsumableOrderValidCheck(component, event, helper, consumableLineItemValues);
        //
        //         console.log('isValid2 : ' + isValid);
        //         if (!isValid) {
        //             component.set("v.showSpinner", false);
        //             return;
        //         }JSON.stringify(consumableLineItemValues);


        var standardOrderData = [];
        var soldOutOrderData = [];

        consumableLineItemValues.forEach((item) => {
            if (item.PurchaseType == '일반 주문') {
                standardOrderData.push(item);
            } else {
                soldOutOrderData.push(item);
            }
        });
        console.log('일반주문 : ' + standardOrderData);
        var objCont;
        var contactId;
        var consigneeName;
        var IbCallNo;
        var newAddress;
        var detailAddress;
        var requestedTerm = '';
        var remark = '';
        var isContactSame;
        var stdOrderTotalPaymentAmount;
        var soldOutOrderTotalPaymentAmount;
        var strCaseId = '';
        var zoneCode;
        var managerNote = '';
        var ContactVIP;
        var isCreateOrder = isCreateOrder != null ? isCreateOrder : component.get('v.isCreateOrder');
        if (!isCreateOrder) {
            objCont = component.get('v.consertObjCont');
            contactId = component.get('v.consertContactId');
            consigneeName = component.get('v.consertConsigneeName');
            IbCallNo = component.get('v.consertIbCallNo');
            newAddress = component.get('v.consertNewAddress');
            detailAddress = component.get('v.consertDetailAddress');
            requestedTerm = component.get('v.consertRequestedTerm');
            remark = component.get('v.consertRemark');
            isContactSame = component.get('v.consertIsContactSame');
            zoneCode = component.get('v.consertZoneCode');
            managerNote = component.get('v.consertManagerNote');
            ContactVIP = component.get('v.consertContactVIP');
        } else {
            objCont = component.get('v.objCont');
            contactId = component.get('v.contactId');
            consigneeName = component.get('v.consigneeName');
            IbCallNo = component.get('v.IbCallNo');
            newAddress = component.get('v.newAddress');
            detailAddress = component.get('v.detailAddress');
            requestedTerm = component.get('v.requestedTerm');
            remark = component.get('v.remark');
            isContactSame = component.get('v.isContactSame');
            zoneCode = component.get('v.zoneCode');
            managerNote = component.get('v.managerNote');
            ContactVIP = component.get('v.ContactVIP');
            strCaseId = component.get("v.strCaseId");
        }
        stdOrderTotalPaymentAmount = 0;
        soldOutOrderTotalPaymentAmount = 0;
        console.log('contactId ::',contactId);
        console.log('requestedTerm : ' + requestedTerm);
        
        if (isContactSame) {
            consigneeName = objCont.Name;
            IbCallNo = objCont.Phone;
        }
        for (var idx in standardOrderData) {
            stdOrderTotalPaymentAmount += standardOrderData[idx].QTY * standardOrderData[idx].Price
        }
        for (var idx in soldOutOrderData) {
            soldOutOrderTotalPaymentAmount += soldOutOrderData[idx].QTY * soldOutOrderData[idx].Price
        }
        // var orderListDataList = component.get("v.data");
        // var orderListString = '';
        remark = remark === undefined ? '' : remark;
        // if (orderListDataList) {
        //     for (var idx in orderListDataList) {
        //         orderListString += orderListDataList[idx].PurchaseType + ' | '
        //             + orderListDataList[idx].ProductCode + ' | '
        //             + orderListDataList[idx].QTY + ' | '
        //             + orderListDataList[idx].Price + ' | '
        //             + (orderListDataList[idx].Price * orderListDataList[idx].QTY) + '\n';
        //     }
        //     remark += orderListString;
        // }

        // 소모품 주문 Item(일반)
        //var standardOrderData = component.get('v.standardOrderData');

        // 소모품 주문 Item(품절)
        // var soldOutOrderData = component.get('v.soldOutOrderData');
        console.log('총합 : stdOrderTotalPaymentAmount' + stdOrderTotalPaymentAmount);
        console.log('변환전 ㅓ일반 : ' + JSON.stringify(standardOrderData));
        console.log('변환전 품절 : ' + JSON.stringify(soldOutOrderData));
        console.log('할인율 : ' + ContactVIP);
        var isExchangeOrder = component.get('v.isExchangeOrder');

        var params = {
            'contactId': contactId,
            'consigneeName': consigneeName,
            'IbCallNo': IbCallNo,
            'newAddress': newAddress,
            'detailAddress': detailAddress,
            'requestedTerm': requestedTerm,
            'remark': remark,
            'isContactSame': isContactSame,
            'standardOrderData': JSON.stringify(standardOrderData),
            'soldOutOrderData': JSON.stringify(soldOutOrderData),
            'stdOrderTotalPaymentAmount': stdOrderTotalPaymentAmount,
            'soldOutOrderTotalPaymentAmount': soldOutOrderTotalPaymentAmount,
            'isTemporary': true,
            'isManagement': false,
            'strCaseId': strCaseId,
            'zoneCode': isContactSame && !isExchangeOrder ? objCont.POSTAL_CODE__c : zoneCode,
            'managerNote': managerNote,
            'ContactVIP': ContactVIP

        };
        var updatedRemark = '';
        var isOrderChange;
        var stdConsumableOrderId;
        var soldOutConsumableOrderId;
        var poId;
        
        //23 08 18 hyungho.chun 품절주문만있을때만 promise 처리
        if(soldOutOrderData.length>0 && standardOrderData==0){
            return new Promise((resolve,reject)=>{

                console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - start:' + dateOffset.toISOString());
                var action = component.get('c.doTemporarySaveConsumableOrder');
                action.setParams({
                    'paramMap': params
                });
        
                action.setCallback(this, function (response) {
                    var state = response.getState();
        
                    console.log('action state : ' + state);
                    if (state === "SUCCESS") {
                        var result = JSON.parse(JSON.stringify(response.getReturnValue()));
                        console.log('temp 저장 후의 result : ' + JSON.stringify(result));
                        console.log(result);
                        //23 08 18 hyungho.chun 
                        isSuccess = result['isSuccess'];
                        isOrderChange = result['isOrderChange'];

                           
                        //2023.10.13 seung yoon heo 수취인전화번호 val
                        if (result['isPhoneVal'] != null) {
                            var toast = $A.get("e.force:showToast");
                            toast.setParams({
                            "message": "받는분(수취인) 전화번호가 유효하지 않습니다.",
                            "type": "error"
                            });
                            toast.fire();

                            component.set("v.showSpinner", false);
                            return;
                        }
                        
                        if (result['STANDARD_ORDER'] != null) {
                            updatedRemark += ' \n\n ';
                            updatedRemark += (result['STANDARD_ORDER'].Order_Number__c + ' 일반주문\n');
                            if(remark != '') updatedRemark += (remark +'\n') ;
                            stdConsumableOrderId = result['STANDARD_ORDER'].Id;
                        }
                        if (result['standardOrderItemTables'] != null) {
                            standardOrderData = result['standardOrderItemTables'];
                            for (var idx in standardOrderData) {
                                updatedRemark += standardOrderData[idx].ProductCode + ' | '
                                    + standardOrderData[idx].ProductName + ' | '
                                    + standardOrderData[idx].QTY + ' | '
                                    // + standardOrderData[idx].ASCPrice + ' | '
                                    + standardOrderData[idx].Price + ' | '
                                    + (standardOrderData[idx].QTY * standardOrderData[idx].Price) + ' | '
                                    //2023.11.29 seung yoon heo 최초의 결제금액은 판매금액과 같다.
                                    + (standardOrderData[idx].QTY * standardOrderData[idx].Price) + '\n';
                            }
                        }
        
                        
                        if (result['SOLD_OUT_ORDER'] != null) {
                            updatedRemark += ' \n\n ';
                            updatedRemark += (result['SOLD_OUT_ORDER'].Order_Number__c + ' 품절주문\n');
                            if(remark != '') updatedRemark += (remark +'\n') ;
                            soldOutConsumableOrderId = result['SOLD_OUT_ORDER'].Id;
                        }
        
                        if (result['soldOutOrderItemTables'] != null) {
                            soldOutOrderData = result['soldOutOrderItemTables'];
                            for (var idx in soldOutOrderData) {
                                updatedRemark += soldOutOrderData[idx].ProductCode + ' | '
                                    + soldOutOrderData[idx].ProductName + ' | '
                                    // + soldOutOrderData[idx].ASCPrice + ' | '
                                    + soldOutOrderData[idx].QTY + ' | '
                                    + soldOutOrderData[idx].Price + ' | '
                                    + (soldOutOrderData[idx].QTY * soldOutOrderData[idx].Price) + ' | '
                                    //2023.11.29 seung yoon heo 최초의 결제금액은 판매금액과 같다.
                                    + (soldOutOrderData[idx].QTY * soldOutOrderData[idx].Price) + '\n';
                            }
                        }
                        
                        if (result['PO'] != null) {
                            poId = result['PO'].Id
                        }

                        resolve(result);
                    } else if (state === 'ERROR') {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('error', errors[0].message);
                                component.set('v.showSpinner', false);
                            }
                        } else {
                            helper.showToast('error', 'Unknown error');
                            component.set('v.showSpinner', false);
                        }
                        reject(errors);
                    }
                    
        
                });
                $A.enqueueAction(action);
            }).then(()=>{
                console.log('contactId ::',contactId);
                //23 08 18 hyungho.chun 품절주문하자마자 빠르게 예약할 경우 간헐적 에러로 주문 팝업창 나오는 타이밍 변경
                console.log('isSuccess ::',isSuccess);
                    
                if (isSuccess) {
                    console.log('>>> createComponent start <<< ');
                    console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - end:' + dateOffset.toISOString());

                    //23.12.11 gw.lee
                    //Confirm Message 추가, 소스 분리 필요
                    if (component.get('v.currentTotalQty') > 100) {
                        var dialog = component.find('dialog');

                        var param = {
                            message : '소모품 및 공급팀 담당자를 통해 확인 후 주문 생성하시는 것입니까?',
                            isExOrderCreate : true
                        };
            
                        dialog.confirm(param, function(response) {
                            console.log('response :' + response.result);
                            if (response == null || response == undefined) {
                                helper.showToast('error', '사용자 응답 오류');
                                return;
                            }
                            if(response.result == true){
                                $A.createComponent(
                                "c:EX_SuppliesCreateOrder",
                                {
                                    'standardOrderData': standardOrderData,
                                    'soldOutOrderData': soldOutOrderData,
                                    'contactId': contactId,
                                    'consigneeName': consigneeName,
                                    'IbCallNo': IbCallNo,
                                    'newAddress': newAddress,
                                    'detailAddress': detailAddress,
                                    'requestedTerm': requestedTerm,
                                    'remark': updatedRemark.replace('null',''),
                                    'isContactSame': isContactSame,
                                    'objCont': objCont,
                                    'stdConsumableOrderId': stdConsumableOrderId,
                                    'soldOutConsumableOrderId': soldOutConsumableOrderId,
                                    'poId': poId,
                                    'strCaseId': strCaseId,
                                    'zoneCode': isContactSame && !isExchangeOrder ? objCont.POSTAL_CODE__c : zoneCode,
                                    'ContactVIP': ContactVIP,
                                    'isOrderChange': isOrderChange,
                                    'FSIsMaterialPortal': component.get('v.FSIsMaterialPortal'),
                                    'focusedTabId': focusedTabId
                                },
                    
                                function (cmp, status, errorMessage) {
                                    if (status === "SUCCESS") {
                                        component.set("v.modalContent", cmp);
                                        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - create:' + dateOffset.toISOString());
                                        // var body = component.get("v.modalContent");
                                        // body.push(newComponent);
                                        // component.set("v.modalContent", body);
                                    } else if (status === "INCOMPLETE") {
                                        console.log('No response from server or client is offline.');
                                    } else if (status === "ERROR") {
                                        console.log('Error :' + errorMessage);
                                    }
                                });
                            }
                        }, '주문 요청');
                    } else {
                        $A.createComponent(
                            "c:EX_SuppliesCreateOrder",
                            {
                                'standardOrderData': standardOrderData,
                                'soldOutOrderData': soldOutOrderData,
                                'contactId': contactId,
                                'consigneeName': consigneeName,
                                'IbCallNo': IbCallNo,
                                'newAddress': newAddress,
                                'detailAddress': detailAddress,
                                'requestedTerm': requestedTerm,
                                'remark': updatedRemark.replace('null',''),
                                'isContactSame': isContactSame,
                                'objCont': objCont,
                                'stdConsumableOrderId': stdConsumableOrderId,
                                'soldOutConsumableOrderId': soldOutConsumableOrderId,
                                'poId': poId,
                                'strCaseId': strCaseId,
                                'zoneCode': isContactSame && !isExchangeOrder ? objCont.POSTAL_CODE__c : zoneCode,
                                'ContactVIP': ContactVIP,
                                'isOrderChange': isOrderChange,
                                'FSIsMaterialPortal': component.get('v.FSIsMaterialPortal'),
                                'focusedTabId': focusedTabId
                            },
                
                            function (cmp, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    component.set("v.modalContent", cmp);
                                    console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - create:' + dateOffset.toISOString());
                                    // var body = component.get("v.modalContent");
                                    // body.push(newComponent);
                                    // component.set("v.modalContent", body);
                                } else if (status === "INCOMPLETE") {
                                    console.log('No response from server or client is offline.');
                                } else if (status === "ERROR") {
                                    console.log('Error :' + errorMessage);
                                }
                            });
                    }
                }
                component.set('v.showSpinner', false);
            })
        }else{
            console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - start:' + dateOffset.toISOString());
            var action = component.get('c.doTemporarySaveConsumableOrder');
            action.setParams({
                'paramMap': params
            });

            action.setCallback(this, function (response) {
                var state = response.getState();

    
                console.log('action state : ' + state);
                if (state === "SUCCESS") {
                    console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - end:' + dateOffset.toISOString());
                    var result = JSON.parse(JSON.stringify(response.getReturnValue()));
                    console.log('temp 저장 후의 result : ' + JSON.stringify(result));
                    console.log(result);
                    isSuccess = result['isSuccess'];
                    isOrderChange = result['isOrderChange'];


                    //2023.10.13 seung yoon heo 수취인전화번호 val
                    if (result['isPhoneVal'] != null) {
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                        "message": "받는분(수취인) 전화번호가 유효하지 않습니다.",
                        "type": "error"
                        });
                        toast.fire();
                        
                        component.set("v.showSpinner", false);
                        return;
                    }
                    
                    
                    if (result['STANDARD_ORDER'] != null) {
                        updatedRemark += ' \n\n ';
                        updatedRemark += (result['STANDARD_ORDER'].Order_Number__c + ' 일반주문\n');
                        if(remark != '') updatedRemark += (remark +'\n') ;
                        stdConsumableOrderId = result['STANDARD_ORDER'].Id;
                    }
                    if (result['standardOrderItemTables'] != null) {
                        standardOrderData = result['standardOrderItemTables'];
                        for (var idx in standardOrderData) {
                            updatedRemark += standardOrderData[idx].ProductCode + ' | '
                                + standardOrderData[idx].ProductName + ' | '
                                + standardOrderData[idx].QTY + ' | '
                                // + standardOrderData[idx].ASCPrice + ' | '
                                + standardOrderData[idx].Price + ' | '
                                + (standardOrderData[idx].QTY * standardOrderData[idx].Price) + ' | '
                                //2023.11.29 seung yoon heo 최초의 결제금액은 판매금액과 같다.
                                + (standardOrderData[idx].QTY * standardOrderData[idx].Price) + '\n';
                        }
                    }
    
                    
                    if (result['SOLD_OUT_ORDER'] != null) {
                        updatedRemark += ' \n\n ';
                        updatedRemark += (result['SOLD_OUT_ORDER'].Order_Number__c + ' 품절주문\n');
                        if(remark != '') updatedRemark += (remark +'\n') ;
                        soldOutConsumableOrderId = result['SOLD_OUT_ORDER'].Id;
                    }
    
                    if (result['soldOutOrderItemTables'] != null) {
                        soldOutOrderData = result['soldOutOrderItemTables'];
                        for (var idx in soldOutOrderData) {
                            updatedRemark += soldOutOrderData[idx].ProductCode + ' | '
                                + soldOutOrderData[idx].ProductName + ' | '
                                // + soldOutOrderData[idx].ASCPrice + ' | '
                                + soldOutOrderData[idx].QTY + ' | '
                                + soldOutOrderData[idx].Price + ' | '
                                + (soldOutOrderData[idx].QTY * soldOutOrderData[idx].Price) + ' | '
                                //2023.11.29 seung yoon heo 최초의 결제금액은 판매금액과 같다.
                                + (soldOutOrderData[idx].QTY * soldOutOrderData[idx].Price) + '\n';
                        }
                    }

                 
                    if (result['PO'] != null) {
                        poId = result['PO'].Id
                    }
                    if (isSuccess) {
                        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - end:' + dateOffset.toISOString());
                        console.log('>>> createComponent start <<< ');
                        if (component.get('v.currentTotalQty') > 100) {
                            var dialog = component.find('dialog');

                            var param = {
                                message : '소모품 및 공급팀 담당자를 통해 확인 후 주문 생성하시는 것입니까?',
                                isExOrderCreate : true
                            };
                
                            dialog.confirm(param, function(response) {
                                console.log('response :' + response.result);
                                if (response == null || response == undefined) {
                                    helper.showToast('error', '사용자 응답 오류');
                                    return;
                                }
                                if(response.result == true){
                                    $A.createComponent(
                                        "c:EX_SuppliesCreateOrder",
                                        {
                                            'standardOrderData': standardOrderData,
                                            'soldOutOrderData': soldOutOrderData,
                                            'contactId': contactId,
                                            'consigneeName': consigneeName,
                                            'IbCallNo': IbCallNo,
                                            'newAddress': newAddress,
                                            'detailAddress': detailAddress,
                                            'requestedTerm': requestedTerm,
                                            'remark': updatedRemark.replace('null',''),
                                            'isContactSame': isContactSame,
                                            'objCont': objCont,
                                            'stdConsumableOrderId': stdConsumableOrderId,
                                            'soldOutConsumableOrderId': soldOutConsumableOrderId,
                                            'poId': poId,
                                            'strCaseId': strCaseId,
                                            'zoneCode': isContactSame && !isExchangeOrder ? objCont.POSTAL_CODE__c : zoneCode,
                                            'ContactVIP': ContactVIP,
                                            'isOrderChange': isOrderChange,
                                            'FSIsMaterialPortal': component.get('v.FSIsMaterialPortal'),
                                            'focusedTabId': focusedTabId
                                        },
                
                                        function (cmp, status, errorMessage) {
                                            if (status === "SUCCESS") {
                                                component.set("v.modalContent", cmp);
                                                console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - create:' + dateOffset.toISOString());
                                                // var body = component.get("v.modalContent");
                                                // body.push(newComponent);
                                                // component.set("v.modalContent", body);
                                            } else if (status === "INCOMPLETE") {
                                                console.log('No response from server or client is offline.');
                                            } else if (status === "ERROR") {
                                                console.log('Error :' + errorMessage);
                                            }
                                    });
                                }
                            }, '주문 요청');
                        } else {
                            $A.createComponent(
                                "c:EX_SuppliesCreateOrder",
                                {
                                    'standardOrderData': standardOrderData,
                                    'soldOutOrderData': soldOutOrderData,
                                    'contactId': contactId,
                                    'consigneeName': consigneeName,
                                    'IbCallNo': IbCallNo,
                                    'newAddress': newAddress,
                                    'detailAddress': detailAddress,
                                    'requestedTerm': requestedTerm,
                                    'remark': updatedRemark.replace('null',''),
                                    'isContactSame': isContactSame,
                                    'objCont': objCont,
                                    'stdConsumableOrderId': stdConsumableOrderId,
                                    'soldOutConsumableOrderId': soldOutConsumableOrderId,
                                    'poId': poId,
                                    'strCaseId': strCaseId,
                                    'zoneCode': isContactSame && !isExchangeOrder ? objCont.POSTAL_CODE__c : zoneCode,
                                    'ContactVIP': ContactVIP,
                                    'isOrderChange': isOrderChange,
                                    'FSIsMaterialPortal': component.get('v.FSIsMaterialPortal'),
                                    'focusedTabId': focusedTabId
                                },
        
                                function (cmp, status, errorMessage) {
                                    if (status === "SUCCESS") {
                                        component.set("v.modalContent", cmp);
                                        console.log('속도측정 -------------------------------------------------- EX_SuppliesOrderList.cmp.fnCreateOrder - create:' + dateOffset.toISOString());
                                        // var body = component.get("v.modalContent");
                                        // body.push(newComponent);
                                        // component.set("v.modalContent", body);
                                    } else if (status === "INCOMPLETE") {
                                        console.log('No response from server or client is offline.');
                                    } else if (status === "ERROR") {
                                        console.log('Error :' + errorMessage);
                                    }
                            });
                        }
                    }
    
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('error', errors[0].message);
                            component.set('v.showSpinner', false);
                        }
                    } else {
                        helper.showToast('error', 'Unknown error');
                        component.set('v.showSpinner', false);
                    }
                }
                component.set('v.showSpinner', false);
                
    
                
                
            });
            console.log('doTemporarySaveConsumableOrder enqueue직전 '+ new Date().toUTCString());
            $A.enqueueAction(action);            

        }
    },
});