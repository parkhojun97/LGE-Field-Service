/**
 * Created by I2MAX.SEOKHOLEE on 2022-12-26.
 */

({
    fnTemporaryCreateOrder  : function (component, event, helper) {
        console.log('fnTemporaryCreateOrder start');

        // 소모품 주문 Header
        var objCont = component.get('v.objCont');
        var contactId = component.get('v.contactId');
        var consigneeName = component.get('v.consigneeName');
        var IbCallNo = component.get('v.IbCallNo');
        var newAddress = component.get('v.newAddress');
        var detailAddress = component.get('v.detailAddress');
        var requestedTerm = component.get('v.requestedTerm');
        var remark = component.get('v.remark');
        var isContactSame = component.get('v.isContactSame');

        if(isContactSame) {
            consigneeName = objCont.Name;
            IbCallNo = objCont.Phone;
        }

        console.log('isContactSame');
        console.log(isContactSame);
        // 소모품 주문 Item(일반)
        var standardOrderData = component.get('v.standardOrderData');

        // 소모품 주문 Item(품절)
        var soldOutOrderData = component.get('v.soldOutOrderData');


        var action = component.get('c.doSaveConsumableOrder');
        var param = null;
        if(component.get('v.isManagement')){
            params = {
                        'contactId' : contactId,
                        'consigneeName' : consigneeName,
                        'IbCallNo' : IbCallNo,
                        'newAddress' : newAddress,
                        'detailAddress' : detailAddress,
                        'requestedTerm' : requestedTerm,
                        'remark' : remark,
                        'isContactSame' : isContactSame,
                        'standardOrderData' : JSON.stringify(standardOrderData),
                        'soldOutOrderData' : JSON.stringify(soldOutOrderData),
                        'isTemporary' : false,
                        'stdConsumableOrderId' : component.get('v.stdConsumableOrderId'),
                        'soldOutConsumableOrderId' : component.get('v.soldOutConsumableOrderId'),
                        'poId' : component.get('v.poId'),
                        'isManagement' : true
                    };
        }else{
            params = {
                'contactId' : contactId,
                'consigneeName' : consigneeName,
                'IbCallNo' : IbCallNo,
                'newAddress' : newAddress,
                'detailAddress' : detailAddress,
                'requestedTerm' : requestedTerm,
                'remark' : remark,
                'isContactSame' : isContactSame,
                'standardOrderData' : JSON.stringify(standardOrderData),
                'soldOutOrderData' : JSON.stringify(soldOutOrderData),
                'isTemporary' : false,
                'stdConsumableOrderId' : component.get('v.stdConsumableOrderId'),
                'soldOutConsumableOrderId' : component.get('v.soldOutConsumableOrderId'),
                'poId' : component.get('v.poId'),
            };
        }

        action.setParams({
            'paramMap' : params
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var standardOrderItemTables = result['standardOrderItemTables'];
                var soldOutOrderItemTables = result['soldOutOrderItemTables'];


                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "소모품 주문이 성공적으로 저장 되었습니다.",
                    "type" : "success"
                });
                toast.fire();
                component.destroy();

                $A.get('e.force:refreshView').fire();

            } else if(state ==='ERROR'){
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                this.gfnShowToast("error", errors[0].message);
            }
        });
        $A.enqueueAction(action);

    },


    fnSetOrderData: function (component, event, helper) {

        var standardOrderDataList = component.get('v.standardOrderData');
        console.log('fnSetOrderData :: ' + JSON.stringify(standardOrderDataList));

        var remark = component.get('v.remark');

        if(standardOrderDataList ==  ''){
            component.set('v.latePayment',true);

            component.set('v.IsPrint',true);

        }
        var soldOutOrderDataList = component.get('v.soldOutOrderData');

        console.log('check sold out ??? ' , soldOutOrderDataList);


        // 일반 주문 총 개수
        var standardTotalCount = 0;
        // 일반 주문 총 판매 금액
        var standardTotalSalesAmount = 0;
        // 일반 주문 총 총 할인 액
        var standardTotalDiscountAmount = 0;
        // 일반 주문 총 결제 금액(현금)
        var standardTotalPayment_CASH = 0;
        // 일반 주문 총 결제 금액(카드)
        var standardTotalPayment_CARD = 0;
        // 일반 주문 총 포인트 금액
        var standardTotalPointAmount = 0;
        // 일반 주문 총 결제 금액
        var standardTotalPaymentAmount = 0;
        // 일반 주문 vip 할인율
        var vipDiscount = component.get('v.ContactVIP') != undefined ? component.get('v.ContactVIP') : 0;

        var vipTotal = 0;
        var empTotal = 0;
        var promotionTotal = 0;

//        var vipDiscount = 0.75;
        console.log('ddddd :' + vipDiscount);
        // 임직원 여부
        var isEmployee = component.get('v.isEmployee');
//        var isEmployee = true;
        console.log('aaaaaa : ' + JSON.stringify(component.get('v.standardOrderData')));

        standardOrderDataList.forEach((item) => {

            var alreadyAppliedPromotionDiscountAmount = 0;

            alreadyAppliedPromotionDiscountAmount = item.DiscountAmount != 0 || item.DiscountAmount != null 
            ? item.DiscountAmount : 0;

            if(item.PromotionPrice == undefined){
                item.PromotionPrice = 0;
            }
            // 할인금액
            item.DiscountAmount = 0;

            console.log('vipDiscount : '+ vipDiscount);
            console.log('item.DiscountType : '+ item.discountType);
            console.log('PromotionPrice : '+item.PromotionPrice);
            console.log('ASCPrice : '+item.ASCPrice);
            if(item.PromotionPrice == null){
                item.PromotionPrice = 0;
            }
            var isEmployee = component.get('v.isEmployee') || item.discountType == '임직원';

            //24.02.15 gw.lee
            //vip가 할인율 1순위임으로, vip할인율 금액이 있을 경우, vip할인율 적용
            //vip 할인 : 할인 할 금액비교 
            //임직원 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 작으면 임직원)
            //프로모션가 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 크면 프로모션)
            // if((item.Price * vipDiscount - (item.Price - item.ASCPrice) > 0) || component.get('v.isEmployee') == false && vipDiscount != 0){
            if (vipDiscount != 0) {
                item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                item.discountType = 'VIP';
                component.set('v.discountType','VIP');
                vipTotal += item.DiscountAmount;
                // if((item.Price * vipDiscount * item.QTY > item.PromotionPrice * item.QTY)){// 24 01 03 PHJ
                // }else{
                //     if(item.PromotionPrice != 0){
                //        item.DiscountAmount = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                //        item.discountType = '프로모션';
                //        component.set('v.discountType','프로모션');
                //        promotionTotal += item.DiscountAmount;
                //     }
                //     else{
                //        item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                //        item.discountType = 'VIP';
                //        component.set('v.discountType','VIP');
                //        vipTotal += item.DiscountAmount;
                //     }
                // }
            //24.02.15 gw.lee
            }else if(( component.get('v.isManagement') ? 
                    item.ASCPrice - item.PromotionPrice < 0 && isEmployee : item.ASCPrice - item.PromotionPrice < 0 && isEmployee) || (item.PromotionPrice == 0 && isEmployee)){
                        item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
                        item.discountType = '임직원';
                        component.set('v.discountType','임직원');
                        empTotal += item.DiscountAmount;
            }else if(item.PromotionPrice !=0  && item.PromotionPrice != null){
                if (isEmployee && item.ASCPrice - item.PromotionPrice < 0 ) {
                    item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
                    item.discountType = '임직원';
                    component.set('v.discountType','임직원');
                    empTotal += item.DiscountAmount;
                } else {
                    item.DiscountAmount = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    item.discountType = '프로모션';
                    component.set('v.discountType','프로모션');
                    promotionTotal += item.DiscountAmount;
                }
                // if(alreadyAppliedPromotionDiscountAmount < (item.QTY * (item.Price - item.ASCPrice))){
                //     item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
                //     item.discountType = '임직원';
                //     component.set('v.discountType','임직원');
                //     empTotal += item.DiscountAmount;
                // }else if(alreadyAppliedPromotionDiscountAmount > (item.QTY * (item.Price - item.ASCPrice))){
                //     item.DiscountAmount = alreadyAppliedPromotionDiscountAmount;
                //     item.discountType = '프로모션';
                //     component.set('v.discountType','프로모션');
                //     promotionTotal += item.DiscountAmount;
                // }
            }

            // if(item.discountType =='임직원'){
            //    item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
            //    empTotal += item.DiscountAmount;
            // }
            console.log('create  : ' +item.discountType + ' ' + item.DiscountAmount);

           

            standardTotalCount += 1;
            standardTotalSalesAmount += item.SalesAmount;
            standardTotalDiscountAmount +=  item.DiscountAmount;
            standardTotalPayment_CASH += item.PaymentAmount_CASH;
            standardTotalPayment_CARD += item.PaymentAmount_CARD;
            standardTotalPointAmount += item.PointAmount;

             //2023.11.29 seung yoon heo 상담이력 결제금액 추가
            if (remark) {
                var remarkSplit = remark.split('\n');
                for (let i = 0; i < remarkSplit.length; i++) {
                    if (remarkSplit[i].includes('|')) {
                            if (item.ProductCode == remarkSplit[i].split('|')[0].trim()) {
                                let chgValue = remarkSplit[i].split('|');
                                chgValue.splice(remarkSplit[i].split('|').length - 1 , 1 , ' ' + String(parseInt(item.SalesAmount - item.DiscountAmount)));
                                let addValue = chgValue.join('|');
                                remarkSplit[i] = addValue;
                            }       
                    }    
                }
    
                remark = remarkSplit.join('\n');
                
            }
 

        });

     
        // 일반 주문 총 결제금액
        standardTotalPaymentAmount = standardTotalPayment_CASH + standardTotalPayment_CARD + standardTotalPointAmount;

        component.set('v.vipDiscountAmount', vipTotal);
        component.set('v.empDiscountAmount', empTotal);
        component.set('v.promotionDiscountAmount', promotionTotal);

        component.set('v.stdOrderTotalSalesCount', standardTotalCount);
        console.log('일반 판매 : ' + standardTotalSalesAmount +'일반 할인 : ' +standardTotalDiscountAmount);
        component.set('v.stdOrderTotalSalesAmount', standardTotalSalesAmount);
        component.set('v.stdOrderTotalDiscountAmount', standardTotalDiscountAmount);
        component.set('v.stdOrderTotalPointAmount', standardTotalPointAmount);
        component.set('v.stdOrderTotalPaymentAmount', standardTotalSalesAmount - standardTotalDiscountAmount);


        // 품절 주문 총 개수
        var soldOutTotalCount = 0;
        // 품절 주문 총 판매 금액
        var soldOutTotalSalesAmount = 0;
        // 품절 주문 총 총 할인 액
        var soldOutTotalDiscountAmount = 0;
        // 품절 주문 총 결제 금액(현금)
        var soldOutTotalPayment_CASH = 0;
        // 품절 주문 총 결제 금액(카드)
        var soldOutTotalPayment_CARD = 0;
        // 품절 주문 총 포인트 금액
        var soldOutTotalPointAmount = 0;
        // 품절 주문 총 결제 금액
        var soldOutTotalPaymentAmount = 0;

        soldOutOrderDataList.forEach((item) => {
            if(item.PromotionPrice == undefined){
                item.PromotionPrice = 0;
            }
            // 판매금액
            item.SalesAmount = item.QTY * item.Price;
            // 할인금액
            if(item.DiscountAmount == null || item.DiscountAmount == undefined || item.DiscountAmount == 0){ //24 02 13 hyungho.chun 이미 discountAmount가 있다면 수정하지않는다
                item.DiscountAmount = 0;
            }
            
            // 포인트
            item.PointAmount = 0;
            // 결제 금액 현금
            item.PaymentAmount_CASH = 0;
            // 결제 금액 카드
            item.PaymentAmount_CARD = 0;
            // 결제 금액
            item.PaymentAmount = 0;

            soldOutTotalCount += 1;
            soldOutTotalSalesAmount += item.SalesAmount;
            soldOutTotalPayment_CASH =0;
            soldOutTotalPayment_CARD =0;
            soldOutTotalPointAmount =0;
            console.log('1111 ' +item.DiscountAmount );
            if(item.PromotionPrice == null){
                item.PromotionPrice = 0;
            }

            var isEmployee = component.get('v.isEmployee') || item.discountType == '임직원';
            //24.02.15 gw.lee
            //vip가 할인율 1순위임으로, vip할인율 금액이 있을 경우, vip할인율 적용
            //vip 할인 : 할인 할 금액비교 
            //임직원 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 작으면 임직원)
            //프로모션가 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 크면 프로모션)
            // if((item.Price * vipDiscount - (item.Price - item.ASCPrice) > 0) || component.get('v.isEmployee') == false && vipDiscount != 0){
            if (vipDiscount != 0) {
                item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                item.discountType = 'VIP';
                component.set('v.discountType','VIP');
                vipTotal += item.DiscountAmount;
                // if((item.Price * vipDiscount * item.QTY > (item.Price - item.PromotionPrice) * item.QTY)){// 24 01 03 PHJ
                // }else{
                //     // 24 01 04 PHJ
                //     if(vipDiscount != 0){
                //         item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                //         item.discountType = 'VIP';
                //         component.set('v.discountType','VIP');
                //         vipTotal += item.DiscountAmount;
                //     }else{
                //         if(item.PromotionPrice != 0){
                //            item.DiscountAmount = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                //            item.discountType = '프로모션';
                //            component.set('v.discountType','프로모션');
                //            promotionTotal += item.DiscountAmount;
                //         }
                //     }
                // }
            }else if(( component.get('v.isManagement') ? 
            item.ASCPrice - item.PromotionPrice < 0 && isEmployee : item.ASCPrice - item.PromotionPrice < 0 && isEmployee) || (item.PromotionPrice == 0 && isEmployee)){
               item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
               item.discountType = '임직원';
               component.set('v.discountType','임직원');
               empTotal += item.DiscountAmount;
            }else if(item.PromotionPrice !=0  && item.PromotionPrice != null){
                if (isEmployee && item.ASCPrice - item.PromotionPrice < 0 ) {
                    item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
                    item.discountType = '임직원';
                    component.set('v.discountType','임직원');
                    empTotal += item.DiscountAmount;
                } else {
                    item.DiscountAmount = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    item.discountType = '프로모션';
                    component.set('v.discountType','프로모션');
                    promotionTotal += item.DiscountAmount;
                }
            }

           
            console.log('2222 ' +item.DiscountAmount  +  ' ' + item.discountType);
            soldOutTotalDiscountAmount += item.DiscountAmount;

             //2023.11.29 seung yoon heo 상담이력 결제금액 추가
            if (remark) {
                
                var remarkSplit = remark.split('\n');
                for (let i = 0; i < remarkSplit.length; i++) {
                    if (remarkSplit[i].includes('|')) {
                            if (item.ProductCode == remarkSplit[i].split('|')[0].trim()) {
                                let chgValue = remarkSplit[i].split('|');
                                chgValue.splice(remarkSplit[i].split('|').length - 1 , 1 , ' ' + String(parseInt(item.SalesAmount - item.DiscountAmount)));
                                let addValue = chgValue.join('|');
                                remarkSplit[i] = addValue;
                            }       
                    }    
                }
    
                remark = remarkSplit.join('\n');
            }
 

        });

        // 품절 주문 총 결제금액
        soldOutTotalPaymentAmount = soldOutTotalSalesAmount - soldOutTotalDiscountAmount;

        component.set('v.remark', remark);
        component.set('v.soldOutOrderTotalSalesCount', soldOutTotalCount);
        // component.set('v.soldOutOrderTotalSalesAmount', soldOutTotalSalesAmount - soldOutTotalDiscountAmount);
        component.set('v.soldOutOrderTotalSalesAmount', soldOutTotalSalesAmount); //24 01 25 hyungho.chun 
        component.set('v.soldOutOrderTotalDiscountAmount', soldOutTotalDiscountAmount);
        component.set('v.soldOutOrderTotalPointAmount', soldOutTotalPointAmount);
        component.set('v.soldOutOrderTotalPaymentAmount', soldOutTotalSalesAmount - soldOutTotalDiscountAmount);

     
        console.log('품절총 : ' +parseInt(component.get('v.soldOutOrderTotalDiscountAmount')));
        console.log('일반총 : ' +parseInt(component.get('v.stdOrderTotalSalesAmount')));
        component.set('v.OrderTotalSalesAmount',parseInt(component.get('v.soldOutOrderTotalSalesAmount'))+parseInt(component.get('v.stdOrderTotalSalesAmount')) );


    },
    fnGetPaymentAmount: function (component, event, helper) {
            component.set('v.showSpinner',true);
            var params = {
                'prId' : component.get('v.prId'),
            };

            var action = component.get('c.doGetPaymentAmount');
            action.setParams({
                'paramMap': params
            });
            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result['point'] != null)
                        component.set('v.Point',result['point']);
                    if(result['cash'] != null)
                        component.set('v.Cash',result['cash']);
                    if(result['card'] != null)
                        component.set('v.Card',result['card']);

                    component.set('v.OrderTotalPaymentAmount',  parseInt(component.get('v.Point'))  + parseInt(component.get('v.Cash')) + parseInt(component.get('v.Card')));

                    console.log('point : ' + result['point']);
                    console.log('cash : ' + result['cash']);
                    console.log('card : ' + result['card']);
                } else {
                    console.log(response.getError());
                    component.set('v.showSpinner', false);

                }
                var standardOrderDataList = component.get('v.standardOrderData');
                var soldOutOrderDataList = component.get('v.soldOutOrderData');
                var isManagement = component.get('v.isManagement');
//                var  standardTotalPaymentAmount = 0;
//                var standardTotalSalesAmount =0;
//
//                var pointDecimal = 0.0;
//                var cashDecimal = 0.0;
//                var cardDecimal = 0.0;
//                var maxNum = 0.0;
//                var flag = -1;
//                console.log('list : ' +standardOrderDataList);
//                standardOrderDataList.forEach((item) => {
//
//                    console.log('111111type ' +component.get('v.Point') +' '+ item.SalesAmount + ' ' + item.DiscountAmount +' ' + component.get('v.stdOrderTotalPaymentAmount'));
//
//                    item.PointAmount = Math.floor(parseInt(component.get('v.Point'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))));
//                    item.CardAmount = Math.floor(parseInt(component.get('v.Card'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))));
//                    item.CashAmount = Math.floor(parseInt(component.get('v.Cash'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))));
//
//                    pointDecimal += parseFloat(component.get('v.Point'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))) -  item.PointAmount ;
//                    cashDecimal += parseFloat(component.get('v.Cash'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))) - item.CashAmount;
//                    cardDecimal += parseFloat(component.get('v.Card'))*(parseInt(item.SalesAmount - item.DiscountAmount)/parseInt(component.get('v.stdOrderTotalPaymentAmount'))) - item.CardAmount;
//
//
//                    if(maxNum < parseFloat(item.SalesAmount - item.DiscountAmount)){
//                        maxNum = parseFloat(item.SalesAmount - item.DiscountAmount);
//                        flag++;
//                    }
//                    console.log('222222 ' +item.PointAmount +' ' +item.CardAmount + ' ' +item.CashAmount +' ' + item.SalesAmount);
//                    standardTotalPaymentAmount += item.PointAmount  +item.CardAmount  +item.CashAmount;
//                });
//                console.log('포인트 소수 : pointDecimal' + pointDecimal);
//                console.log('카드 소수 : cardDecimal' + cardDecimal);
//                console.log('현금 소수 : cashDecimal' + cashDecimal);
//                console.log('가장 큰값 ' +  standardOrderDataList[flag].SalesAmount);
//                standardOrderDataList[flag].PointAmount += pointDecimal;
//                standardOrderDataList[flag].CardAmount += cardDecimal;
//                standardOrderDataList[flag].CashAmount += cashDecimal;
//                component.set('v.stdOrderTotalPaymentAmount', standardTotalPaymentAmount);

                /**
                 *  isManagement && soldOutOrderDataList !== 0
                 *  이 경우에는 품절주문 결제요청이므로 앞단에서 상태 업데이트 했으니 패스하고
                 *  나머지 경우 소모품 택배주문 && 일반주문 결제요청 만 fnDoSave 호출
                 */
                console.log('suppliesCreateOrder standardOrderDataList :: ' + JSON.stringify(standardOrderDataList));
                console.log('suppliesCreateOrder standardOrderDataList length :: ' + standardOrderDataList.length);
                console.log('suppliesCreateOrder soldOutDataList :: ' + JSON.stringify(soldOutOrderDataList));
                console.log('suppliesCreateOrder soldOutDataList length :: ' + soldOutOrderDataList.length);
                if (isManagement && soldOutOrderDataList.length !== 0) {
                    this.updateSoldOutOrder(component, soldOutOrderDataList);
                }
                else {
                    this.fndoSave(component, event, helper, standardOrderDataList);
                }
            });
            $A.enqueueAction(action);

    },
    fnApplyPaymentAmount: function (component, event, helper) {

        var selectedPaymentMethod = component.get('v.selectedPaymentMethod');
        var selectedPaymentAmount = parseInt(component.get('v.selectedPaymentAmount'));

        var standardOrderDataList = component.get('v.standardOrderData');
        var paymentSuccess =true;
        var soldOutOrderDataList = component.get('v.soldOutOrderData');



        standardOrderDataList.sort(function (a, b) {
            if (a.SalesAmount > b.SalesAmount) return -1;
            else if (b.SalesAmount > a.SalesAmount) return 1;
            else return 0;
        });
        var soldTotal = 0;

        var standardTotal = 0;
        var TotalSales = 0;

           standardOrderDataList.forEach((item) => {
                TotalSales +=item.SalesAmount;
            });
                soldOutOrderDataList.forEach((item) => {
                    TotalSales +=item.SalesAmount;
                    soldTotal += item.PaymentAmount_CASH + item.PaymentAmount_CARD + item.PointAmount;
                });
            standardOrderDataList.forEach((item) => {
                       if (selectedPaymentAmount > 0) {
                           console.log('결제 금액 : ' + selectedPaymentAmount);
                            if(soldTotal + item.PaymentAmount_CASH + item.PaymentAmount_CARD + item.PointAmount+selectedPaymentAmount > TotalSales){
                                paymentSuccess = false;
                                return this.gfnShowToast('warning','판매금액을 초과했습니다');
                            }
                           else{
                               if (selectedPaymentMethod == 'cash') {
                                       // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                       if (selectedPaymentAmount <= TotalSales) {
                                            // 판매 금액 만큼 결제금액(현금) 에 세팅
                                            if(selectedPaymentAmount >= item.SalesAmount) {
                                                item.PaymentAmount_CASH = item.SalesAmount;
                                                selectedPaymentAmount -= item.SalesAmount;
                                            }
                                            else{
                                                item.PaymentAmount_CASH += selectedPaymentAmount;
                                                selectedPaymentAmount = 0;
                                            }
                                       } else {
                                            paymentSuccess = false;
                                            return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                       }

                                   }
                                else if (selectedPaymentMethod == 'card') {
                                      // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                      if (selectedPaymentAmount <= TotalSales) {
                                          // 판매 금액 만큼 결제금액(현금) 에 세팅
                                            if(selectedPaymentAmount >= item.SalesAmount) {
                                                item.PaymentAmount_CARD = item.SalesAmount;
                                                selectedPaymentAmount -= item.SalesAmount;
                                            }
                                            else{
                                                item.PaymentAmount_CARD += selectedPaymentAmount;
                                                selectedPaymentAmount = 0;
                                        }
                                       } else {
                                           paymentSuccess = false;
                                           return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                      }



                               } else if (selectedPaymentMethod == 'point') {
                                      // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                  if (selectedPaymentAmount <= TotalSales) {
                                      // 판매 금액 만큼 결제금액(현금) 에 세팅
                                        if(selectedPaymentAmount >= item.SalesAmount) {
                                            item.PointAmount = item.SalesAmount;
                                            selectedPaymentAmount -= item.SalesAmount;
                                        }
                                        else{
                                            item.PointAmount += selectedPaymentAmount;
                                            selectedPaymentAmount = 0;
                                            }
                                  } else {
                                       paymentSuccess = false;
                                       return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                  }

                               }
                           console.log('결제 금액2 : ' + selectedPaymentAmount);


                            standardTotal += item.PaymentAmount_CASH + item.PaymentAmount_CARD + item.PointAmount;
                            }
                       }


                   })

                   if(component.get('v.latePayment')){

                   soldOutOrderDataList.forEach((item) => {
                       if (selectedPaymentAmount > 0) {
                           if((standardTotal + item.PaymentAmount_CASH + item.PaymentAmount_CARD + item.PointAmount > TotalSales) || paymentSuccess == false){
                               paymentSuccess = false;
                           }
                           else{
                                  if (selectedPaymentMethod == 'cash') {
                                          // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                          if (selectedPaymentAmount <= TotalSales) {
                                              // 판매 금액 만큼 결제금액(현금) 에 세팅
                                               item.PaymentAmount_CASH += selectedPaymentAmount;
                                          } else {
                                               paymentSuccess = false;
                                               return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                          }

                                      }
                                   else if (selectedPaymentMethod == 'card') {
                                         // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                         if (selectedPaymentAmount <= TotalSales) {
                                             // 판매 금액 만큼 결제금액(현금) 에 세팅
                                             item.PaymentAmount_CARD += selectedPaymentAmount;
                                         } else {
                                              paymentSuccess = false;
                                              return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                         }


                                  } else if (selectedPaymentMethod == 'point') {
                                         // 현재 입력 금액이 판매 금액 보다 크거나 같은경우
                                     if (selectedPaymentAmount <= TotalSales) {
                                         // 판매 금액 만큼 결제금액(현금) 에 세팅
                                         item.PointAmount += selectedPaymentAmount;
                                     } else {
                                          paymentSuccess = false;
                                          return this.gfnShowToast('warning','판매금액을 초과했습니다');
                                     }

                                  }
                       }
                   }
                });
        }
        component.set('v.standardOrderData', standardOrderDataList);
        if(component.get('v.latePayment')){
            component.set('v.soldOutOrderData', soldOutOrderDataList);
            this.sendMessageSold(component, {type:'items', items: soldOutOrderDataList});
        }
        // 일반 주문 총 개수
        var standardTotalCount = 0;
        // 일반 주문 총 판매 금액
        var standardTotalSalesAmount = 0;
        // 일반 주문 총 총 할인 액
        var standardTotalDiscountAmount = 0;
        // 일반 주문 총 결제 금액(현금)
        var standardTotalPayment_CASH = 0;
        // 일반 주문 총 결제 금액(카드)
        var standardTotalPayment_CARD = 0;
        // 일반 주문 총 포인트 금액
        var standardTotalPointAmount = 0;
        // 일반 주문 총 결제 금액
        var standardTotalPaymentAmount = 0;

//            for(var i=0; i<standardOrderDataList.length; i++){

//                standardTotalCount += 1;
        console.log('isManage ' + component.get('v.isManagement'));
        standardTotalSalesAmount += parseInt(standardOrderDataList[0].SalesAmount);
        standardTotalDiscountAmount += parseInt(standardOrderDataList[0].DiscountAmount);
        standardTotalPayment_CASH += parseInt(standardOrderDataList[0].PaymentAmount_CASH);
        standardTotalPayment_CARD += parseInt(standardOrderDataList[0].PaymentAmount_CARD);
        standardTotalPointAmount += parseInt(standardOrderDataList[0].PointAmount);

//            }


        // 일반 주문 총 결제금액
        standardTotalPaymentAmount = parseInt(component.get('v.Point')) + parseInt(component.get('v.Card')) + parseInt(component.get('v.Cash'));

        component.set('v.stdOrderTotalCardAmount',parseInt(standardTotalPayment_CASH));
        component.set('v.stdOrderTotalCashAmount',parseInt(standardTotalPayment_CARD));
        component.set('v.stdOrderTotalPointAmount', parseInt(standardTotalPointAmount));

        component.set('v.stdOrderTotalSalesCount', standardTotalCount);
        component.set('v.stdOrderTotalSalesAmount', standardTotalSalesAmount);
        component.set('v.stdOrderTotalDiscountAmount', standardTotalDiscountAmount);


            // 품절 주문 총 개수
        var soldOutTotalCount = 0;
        // 품절 주문 총 판매 금액
        var soldOutTotalSalesAmount = 0;
        // 품절 주문 총 총 할인 액
        var soldOutTotalDiscountAmount = 0;
        // 품절 주문 총 결제 금액(현금)
        var soldOutTotalPayment_CASH = 0;
        // 품절 주문 총 결제 금액(카드)
        var soldOutTotalPayment_CARD = 0;
        // 품절 주문 총 포인트 금액
        var soldOutTotalPointAmount = 0;
        // 품절 주문 총 결제 금액
        var soldOutTotalPaymentAmount = 0;

        if(component.get('v.latePayment')){
            for(var i=0 ;i<soldOutOrderDataList.length; i++){
                soldOutTotalCount += 1;
                soldOutTotalSalesAmount += soldOutOrderDataList[i].SalesAmount;
                soldOutTotalDiscountAmount += soldOutOrderDataList[i].DiscountAmount;
                soldOutTotalPayment_CASH += soldOutOrderDataList[i].PaymentAmount_CASH;
                soldOutTotalPayment_CARD += soldOutOrderDataList[i].PaymentAmount_CARD;
                soldOutTotalPointAmount += soldOutOrderDataList[i].PointAmount;

            }

            // 품절 주문 총 결제금액
            soldOutTotalPaymentAmount = soldOutTotalPayment_CASH + soldOutTotalPayment_CARD + soldOutTotalPointAmount;

            component.set('v.soldOutOrderTotalPointAmount', parseInt(soldOutTotalPointAmount));
            component.set('v.soldOutOrderTotalCashAmount', parseInt(soldOutTotalPayment_CASH));
            component.set('v.soldOutOrderTotalCardAmount', parseInt(soldOutTotalPayment_CARD));

            component.set('v.soldOutOrderTotalSalesCount', soldOutTotalCount);
            component.set('v.soldOutOrderTotalSalesAmount', soldOutTotalSalesAmount);
            component.set('v.soldOutOrderTotalDiscountAmount', soldOutTotalDiscountAmount);

        }
        console.log('std point : ' +  parseInt(standardTotalPointAmount) );
        console.log('sold point : ' +  parseInt(soldOutTotalPointAmount) );
         if(component.get('v.selectedPaymentAmount') == 0){
               if (selectedPaymentMethod == 'cash') {
                   component.set('v.Cash',0);

               }
               else if (selectedPaymentMethod == 'card') {
                   component.set('v.Card',0);

               }
               else if (selectedPaymentMethod == 'point') {
                   component.set('v.Point',0);

               }
               else if (selectedPaymentMethod == '2') {
                   component.set('v.Card',0);
                   component.set('v.Cash',0);

               }
               else if (selectedPaymentMethod == '1') {
                   component.set('v.Point',0);

               }
          }else
          {
                 component.set('v.Cash', parseInt(standardTotalPayment_CASH) + parseInt(soldOutTotalPayment_CASH));
                 component.set('v.Card',  parseInt(standardTotalPayment_CARD) + parseInt(soldOutTotalPayment_CARD));
                 component.set('v.Point', parseInt(standardTotalPointAmount) + parseInt(soldOutTotalPointAmount));
          }



        console.log('현금 : '+component.get('v.Cash'));
        console.log('카드 : '+component.get('v.Card'));
        console.log('포인트 : '+component.get('v.Point'));

        var totalCount = standardTotalCount + soldOutTotalCount;
        var stdTotalPayment = parseInt(component.get('v.stdOrderTotalPaymentAmount'));
        var soldTotalPayment =  parseInt(soldOutTotalPaymentAmount);



        component.set('v.OrderTotalPaymentAmount', totalPayment);
        if(paymentSuccess){
            var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "message": "결제가 성공적으로 완료 되었습니다.",
                            "type": "success"
                        });
            toast.fire();
        }

        component.set('v.selectedPaymentAmount', 0);
        if (parseInt(standardTotalSalesAmount) + parseInt(soldOutTotalSalesAmount) <= parseInt(component.get('v.OrderTotalPaymentAmount'))) {
            component.set('v.isPaymentMode', false);
            component.set('v.IsOrderCreation', true);
            standardTotalPaymentAmount = 0;
            soldOutTotalPaymentAmount = 0;
            if(component.get('v.latePayment')){
                for(var i=0 ;i<soldOutOrderDataList.length; i++){
                    if(component.get('v.soldOutOrderTotalSalesAmount') > component.get('v.stdOrderTotalSalesAmount')){
                        soldOutOrderDataList[i].PointAmount = Math.ceil(parseInt(component.get('v.Point'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));
                        soldOutOrderDataList[i].CardAmount = Math.ceil(parseInt(component.get('v.Card'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));
                        soldOutOrderDataList[i].CashAmount = Math.ceil(parseInt(component.get('v.Cash'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));

                        console.log('품절 ' +soldOutOrderDataList[i].PointAmount +' ' +soldOutOrderDataList[i].CardAmount + ' ' +soldOutOrderDataList[i].CashAmount);
                    }
                    else{
                       soldOutOrderDataList[i].PointAmount = Math.floor(parseInt(component.get('v.Point'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));
                       soldOutOrderDataList[i].CardAmount = Math.floor(parseInt(component.get('v.Card'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));
                       soldOutOrderDataList[i].CashAmount = Math.floor(parseInt(component.get('v.Cash'))*(parseInt(soldOutOrderDataList[i].SalesAmount)/parseInt(soldTotalPayment)));
                        console.log('품절 ' +soldOutOrderDataList[i].PointAmount +' ' +soldOutOrderDataList[i].CardAmount + ' ' +soldOutOrderDataList[i].CashAmount);

                    }
                    soldOutTotalPaymentAmount += soldOutOrderDataList[i].SalesAmount;

                    }
                }
                 for(var i=0 ;i<standardOrderDataList.length; i++){
                    if(component.get('v.stdOrderTotalSalesAmount') > component.get('v.soldOutOrderTotalSalesAmount')){
                        standardOrderDataList[i].PointAmount = Math.ceil(parseInt(component.get('v.Point'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                        standardOrderDataList[i].CardAmount = Math.ceil(parseInt(component.get('v.Card'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                        standardOrderDataList[i].CashAmount = Math.ceil(parseInt(component.get('v.Cash'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                        console.log('일반1 ' +standardOrderDataList[i].PointAmount +' ' +standardOrderDataList[i].CardAmount + ' ' +standardOrderDataList[i].CashAmount);

                    }
                    else{
                       standardOrderDataList[i].PointAmount = Math.floor(parseInt(component.get('v.Point'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                       standardOrderDataList[i].CardAmount = Math.floor(parseInt(component.get('v.Card'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                       standardOrderDataList[i].CashAmount = Math.floor(parseInt(component.get('v.Cash'))*(parseInt(standardOrderDataList[i].PaymentAmount)/parseInt(stdTotalPayment)));
                        console.log('일반2 ' +standardOrderDataList[i].PointAmount +' ' +standardOrderDataList[i].CardAmount + ' ' +standardOrderDataList[i].CashAmount);

                    }
                    standardTotalPaymentAmount += standardOrderDataList[i].SalesAmount;

                    }
                component.set('v.standardOrderData', standardOrderDataList);
                component.set('v.stdOrderTotalPaymentAmount', standardTotalPaymentAmount);
                console.log('std ' + standardOrderDataList);
                if(component.get('v.latePayment')){
                    component.set('v.soldOutOrderData', soldOutOrderDataList);
                    this.sendMessageSold(component, {type:'items', items: soldOutOrderDataList});
                    component.set('v.soldOutOrderTotalPaymentAmount', parseInt(soldOutTotalPaymentAmount));

                    }
                else{
                    component.set('v.soldOutOrderTotalPaymentAmount', 0);
                    component.set('v.soldOutOrderTotalSalesAmount', 0);


                }
                console.log('sold ' + soldOutTotalPaymentAmount);


        }
    },

    // fnGetOrderInfo  : function (component, event, helper) {
    //     component.set('v.showSpinner',true);
    //     var stdConsumableOrderId = component.get('v.stdConsumableOrderId');
    //     var soldOutConsumableOrderId =  component.get('v.soldOutConsumableOrderId');

    //     console.log('stdConsumableOrderId :: ' + stdConsumableOrderId);
    //     console.log('soldOutConsumableOrderId :: ' + soldOutConsumableOrderId);

    //     var params = {
    //         'stdConsumableOrderId' : stdConsumableOrderId,
    //         'soldOutConsumableOrderId' : soldOutConsumableOrderId
    //     };

    // 2023.09.06 seung yoon heo helper 묶음
    //     var action = component.get('c.doGetOrderInfo');
    //     action.setParams({
    //         'paramMap': params
    //     });
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('result >>> ' + stdConsumableOrderId != null ? stdConsumableOrderId : soldOutConsumableOrderId);
    //             var stdId =  result[stdConsumableOrderId != null ? stdConsumableOrderId : soldOutConsumableOrderId]['Id'];
    //             if(stdConsumableOrderId != null){
    //                 var stdOrderNumber =  result[stdConsumableOrderId != null ? stdConsumableOrderId : '']['Order_Number__c'];
    //                 component.set('v.prOrderNumber',stdOrderNumber);
    //             }
    //             if(soldOutConsumableOrderId != null){
    //                 var soldOrderNumber =  result[soldOutConsumableOrderId != null ? soldOutConsumableOrderId : '']['Order_Number__c'];
    //                 component.set('v.prSoldOutOrderNumber',soldOrderNumber);
    //                 console.log('soldOrderNumber : ' +soldOrderNumber);

    //             }
    //             if(component.get('v.latePayment') == false && stdConsumableOrderId != null){
    //                 if(component.get('v.isManagement') == false){
    //                     soldOutConsumableOrderId = null;
    //                 }
    //             }
    //             console.log('stdid : ' +stdId);

    //             component.set('v.prId',stdId);


    //         } else {
    //             console.log(response.getError());
    //             component.set('v.showSpinner', false);

    //         }

    //         component.set('v.showSpinner', false);

    //     });
    //     $A.enqueueAction(action);
    // },
    gfnShowToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            key : "info_alt",
            "type"    : type,
            "message" : message
        });
        toastEvent.fire();
    },

    // 2023.09.06 seung yoon heo helper 묶음
    // fnGetContactInfo : function (component, event, helper) {
    //     var contactId = component.get('v.contactId');

    //     var action = component.get('c.doGetContactDept');

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('result >>> ' + result);
    //             component.set('v.ContactDept',result);


    //         } else {
    //             console.log(response.getError());
    //             component.set('v.showSpinner', false);

    //         }

    //         component.set('v.showSpinner', false);

    //     });
    //     $A.enqueueAction(action);
    // },
     
    // 2023.09.06 seung yoon heo helper 묶음
    // fnGetEmpInfo : function (component, event, helper) {
    //     var action = component.get('c.doGetEmpInfo');

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             component.set('v.objEmp',result);


    //         } else {
    //             console.log(response.getError());
    //             component.set('v.showSpinner', false);

    //         }

    //         component.set('v.showSpinner', false);

    //     });
    //     $A.enqueueAction(action);
    // },

    fndoSave  : function (component, event, helper, standardOrderDataList) {
        if(component.get('v.standardOrderData').length == 0 && component.get('v.soldOutOrderData').length != 0){
            component.set('v.showSpinner',true);
        }
        console.log('fnSave!!');
        // 소모품 주문 Header
        var objCont = component.get('v.objCont');
        var contactId = component.get('v.contactId');
        var consigneeName = component.get('v.consigneeName');
        var IbCallNo = component.get('v.IbCallNo');
        var newAddress = component.get('v.newAddress');
        var detailAddress = component.get('v.detailAddress');
        var requestedTerm = component.get('v.requestedTerm');
        var remark = component.get('v.remark');
        var isContactSame = component.get('v.isContactSame');
        var stdOrderTotalPaymentAmount = parseFloat(component.get('v.stdOrderTotalPaymentAmount'));
        var soldOutOrderTotalPaymentAmount = parseFloat(component.get('v.soldOutOrderTotalPaymentAmount'));
        var stdOrderTotalSalesAmount = parseFloat(component.get('v.isManagement') == false ? component.get('v.stdOrderTotalSalesAmount') : 0);
        var soldOutOrderTotalSalesAmount = parseFloat(component.get('v.isManagement') == false ? component.get('v.soldOutOrderTotalSalesAmount') : 0);
        var stdOrderTotalDiscountAmount = parseFloat(component.get('v.stdOrderTotalDiscountAmount'));
        var soldOutOrderTotalDiscountAmount = parseFloat(component.get('v.soldOutOrderTotalDiscountAmount'));

        console.log(parseInt(soldOutOrderTotalPaymentAmount));
        console.log(typeof stdOrderTotalPaymentAmount);

        var stdConsumableOrderId = component.get('v.stdConsumableOrderId');
        var soldOutConsumableOrderId = component.get('v.soldOutConsumableOrderId');
        var poId = component.get('v.poId');
        var strCaseId = component.get('v.strCaseId');
        var isBeforePaymentYN = component.get('v.IsBeforePaymentYN');
        var zoneCode = component.get('v.zoneCode');
        var isManagement = component.get('v.isManagement');


        console.log('할인가 : ' + soldOutOrderTotalDiscountAmount);
        console.log('isManagement : ' + isManagement);
        if(isContactSame == true && isManagement == false) {
            consigneeName = objCont.Name;
            IbCallNo = objCont.Phone;
        }
        // 소모품 주문 Item(일반)
        var standardOrderData = standardOrderDataList;
        if(standardOrderData == null){
            standardOrderData = [];
        }
        console.log('Start====================');
        console.log('standardOrderData');
        console.log(standardOrderData);
        console.log('End====================');

        // 소모품 주문 Item(품절)
        var soldOutOrderData = component.get('v.soldOutOrderData');
        console.log('Start====================');
        console.log('soldOutOrderData');
        console.log(soldOutOrderData);
        console.log('End====================');
//            if(isManagement){
//                soldOutConsumableOrderId = null;
//            }
        var FSIsMaterialPortal = component.get('v.FSIsMaterialPortal');
        var focusedTabId = component.get('v.focusedTabId');

        console.log('focusedTabId => ' + focusedTabId);

        var action = component.get('c.doSaveConsumableOrder');

        console.log('결제금 : ' +component.get('v.OrderTotalPaymentAmount'));
        console.log('chkEmployeeName' + component.get('v.chkEmployeeName'));
        console.log('chkEmployeeNum' + component.get('v.chkEmployeeNum'));
        console.log('chkCompanyName' + component.get('v.chkCompanyName'));
        console.log('chkEmployeeRelationShip' + component.get('v.chkEmployeeRelationShip'));
        console.log('오아ㅗ아ㅗ아 : ' + JSON.stringify(standardOrderData));
        var params = {
            'contactId' : contactId,
            'consigneeName' : consigneeName,
            'IbCallNo' : IbCallNo,
            'newAddress' : newAddress,
            'detailAddress' : detailAddress,
            'requestedTerm' : requestedTerm,
            'remark' : remark,
            'isContactSame' : isContactSame,
            'standardOrderData' : JSON.stringify(standardOrderData),
            'soldOutOrderData' : JSON.stringify(soldOutOrderData),
            'stdOrderTotalPaymentAmount' : stdOrderTotalPaymentAmount,
            'soldOutOrderTotalPaymentAmount' : parseInt(soldOutOrderTotalPaymentAmount),
            'stdOrderTotalSalesAmount' : stdOrderTotalSalesAmount,
            'soldOutOrderTotalSalesAmount' : soldOutOrderTotalSalesAmount,
            'stdConsumableOrderId' : stdConsumableOrderId,
            'soldOutConsumableOrderId' : soldOutConsumableOrderId,
            'poId' : poId,
            'strCaseId' : strCaseId,
            'isBeforePaymentYN' : isBeforePaymentYN,
            'stdOrderTotalDiscountAmount' : parseFloat(component.get('v.stdOrderTotalDiscountAmount')),
            'soldOutOrderTotalDiscountAmount' : parseFloat(component.get('v.soldOutOrderTotalDiscountAmount')),
            'zoneCode' : zoneCode,
            'ContactVIP' : component.get('v.ContactVIP'),
            'isEmployee' : component.get('v.isEmployee'),
            'discountType' : component.get('v.discountType'),
            'chkEmployeeName' : component.get('v.chkEmployeeName'),
            'chkEmployeeNum' : component.get('v.chkEmployeeNum'),
            'chkCompanyName' : component.get('v.chkCompanyName'),
            'chkEmployeeRelationShip' : component.get('v.chkEmployeeRelationShip'),
            'isManagement' : component.get('v.isManagement')

        };
        console.log('con' +params);
        action.setParams({
            'paramMap' : params
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log(result);

                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "message": "소모품 주문이 성공적으로 저장 되었습니다.",
                    "type" : "success"
                });
                toast.fire();

                var errorMsg = result['caseUpdateFail'];
                if (errorMsg != null) {
                    toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "message": "Case 업데이트 실패 >> " + errorMsg,
                        "type" : "error"
                    });
                    toast.fire();
                }

                // <!-- 23.05.01 자재포탈 인입 여부 추가 -->
                console.log('FSIsMaterialPortal => ' + FSIsMaterialPortal);
                console.log('focusedTabId => ' + focusedTabId);
                if(FSIsMaterialPortal) {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.closeTab({tabId: focusedTabId});
                }

                component.destroy();
                component.set('v.showSpinner', false);

                $A.get('e.force:refreshView').fire();

            } else if(state ==='ERROR'){
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                helper.gfnShowToast("error", errors[0].message);
                component.set('v.showSpinner', false);
            }

        });
        $A.enqueueAction(action);
    },
    // 2023.09.06 seung yoon heo helper 묶음
    // fngetServiceResource : function (component, event, helper) {
    //     var contactId = component.get('v.contactId');

    //     var action = component.get('c.doGetServiceResource');
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();

    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('result >>> ' + result);
    //             if(result!=null)
    //                 component.set('v.serviceResource',result);


    //         } else {
    //             console.log(response.getError());
    //             component.set('v.showSpinner', false);

    //         }

    //         component.set('v.showSpinner', false);

    //     });
    //     $A.enqueueAction(action);
    // },

    fnSetWijmo : function (component, event, helper) {
        var standardOrderData = component.get('v.standardOrderData');
        var soldOutOrderData = component.get('v.soldOutOrderData');
        console.log('setWijmo standard :: ' + JSON.stringify(standardOrderData));
        console.log('setWijmo soldOut :: ' + JSON.stringify(soldOutOrderData));
        var isManagement = component.get('v.isManagement');
        if (isManagement && soldOutOrderData.length !== 0) {
            console.log('soldOut data Set');
            /**
             *  standardOrderData에 넣어주어서 계산 같은 것 품절주문건들 대상으로 계산할 수 있게,
             *  기존 품절주문만 있을 경우 품절 주문 예약으로 바로 진행되어 버림
             *  따라서 사용자에겐 품절주문 결제로 보여주지만 데이터는 soldOutOrderData, standardOrderData가 같은 상태
             *  이렇게 품절건만 있을 경우에 대해서 품절 건들은 doSaveConsumableOrder가 아니라
             *  updateSoldOutStatus 메서드를 탈 수 있게 해줘야함
             */
            this.sendMessageSold(component, {type:'items', items: soldOutOrderData});
        }
        else {
            this.sendMessageStd(component, {type:'items', items: standardOrderData});
            this.sendMessageSold(component, {type:'items', items: soldOutOrderData});
        }


    },

    sendMessageStd: function(component, msg) {
        if(msg.items.length != 0){
                        console.log('위즈모' + JSON.stringify(msg.items));

            component.find('wijmo_EXSuppliesCreateOrder_std').message(msg);
        }
    },
    sendMessageSold: function(component, msg) {
        if(msg.items.length != 0){
                        console.log('위즈모' + JSON.stringify(msg.items));

            component.find('wijmo_EXSuppliesCreateOrder_sold').message(msg);
        }
    },

    updateSoldOutOrder: function(component, soldOutOrderDataList) {
        var action = component.get('c.updateSoldOutOrderDataList');
        console.log('zzzzz');


        //24 02 14 hyungho.chun 컨트롤러 파람 수정
        // var prLiIdSet = [];
        // soldOutOrderDataList.forEach(item => {
        //     prLiIdSet.push(item.Id);
        // });
        // action.setParam('prLiIdSet', prLiIdSet);

        //24 02 14 hyungho.chun 컨트롤러 파람 수정 시작
        var params = {};
        soldOutOrderDataList.forEach(item => {
            var tempValue = {};
            tempValue.Price = item.Price;
            tempValue.QTY = item.QTY;
            if(item.discountType != null && item.discountType != undefined){
                tempValue.discountType = item.discountType;
                tempValue.DiscountAmount = item.DiscountAmount;
            }
            params[item.Id] = tempValue;
        });        

        console.log('params :: ', params);
        console.log('params Stringify:: ', JSON.stringify(params));

        // action.setParams({
        //     'paramMap' : params
        // });
        action.setParam('paramMap2', JSON.stringify(params));
        //24 02 14 hyungho.chun 컨트롤러 파람 수정 끝

        console.log('zzzzz');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('품절주문건 주문상태 업데이트 성공');

                var evt = $A.get("e.c:EX_CompleteEvent_evt");
                evt.setParam("complete" ,true);
                evt.fire();

            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                console.log('품절주문건 주문상태 업데이트 실패 : ' + errors);
                console.log(JSON.stringify(errors));
            }
            component.destroy();
        });

        $A.enqueueAction(action);
    },

    fnCreateOrderInfo : function (component, event, helper) {
        component.set('v.showSpinner',true);
        var stdConsumableOrderId = component.get('v.stdConsumableOrderId');
        var soldOutConsumableOrderId =  component.get('v.soldOutConsumableOrderId');
        console.log('stdConsumableOrderId :: ' + stdConsumableOrderId);
        console.log('soldOutConsumableOrderId :: ' + soldOutConsumableOrderId);

        var params = {
            'stdConsumableOrderId' : stdConsumableOrderId,
            'soldOutConsumableOrderId' : soldOutConsumableOrderId
        };

        var action = component.get('c.exSuppliesCreateOrderGroup');
        action.setParams({
            'paramMap': params
        });
        action.setCallback(this, function (response) {
            
                var result = response.getReturnValue();
                console.log('result!!!!! :: ' , result);
                if (result.STATUS.result == 'S') {
                        
                        if (result.doGetOrderInfo) {
                            var GetOrder = result.doGetOrderInfo;
                            console.log('GetOrder!!!!! :: ' , GetOrder);
                            console.log('result >>> ' + stdConsumableOrderId != null ? stdConsumableOrderId : soldOutConsumableOrderId);
                            var stdId =  GetOrder[stdConsumableOrderId != null ? stdConsumableOrderId : soldOutConsumableOrderId]['Id'];
                            if(stdConsumableOrderId != null){
                                var stdOrderNumber =  GetOrder[stdConsumableOrderId != null ? stdConsumableOrderId : '']['Order_Number__c'];
                                component.set('v.prOrderNumber',stdOrderNumber);
                            }
                            if(soldOutConsumableOrderId != null){
                                var soldOrderNumber =  GetOrder[soldOutConsumableOrderId != null ? soldOutConsumableOrderId : '']['Order_Number__c'];
                                component.set('v.prSoldOutOrderNumber',soldOrderNumber);
                                console.log('soldOrderNumber : ' +soldOrderNumber);
        
                            }
                            if(component.get('v.latePayment') == false && stdConsumableOrderId != null){
                                if(component.get('v.isManagement') == false){
                                    soldOutConsumableOrderId = null;
                                }
                            }
                            console.log('stdid : ' +stdId);
                            component.set('v.prId',stdId);
                        }
                        if (result.doGetEmpInfo.result) {
                            var GetEmp = result.doGetEmpInfo.result;
                            console.log('GetEmp!!!!! :: ' , GetEmp);
        
                            component.set('v.objEmp',GetEmp);
                        }
                        if (result.doGetContactDept.result) {
                            var GetCon = result.doGetContactDept.result;
                            console.log('GetCon!!!!! :: ' , GetCon);
        
                            console.log('GetCon >>> ' + GetCon);
                            component.set('v.ContactDept',GetCon);
                        }
                        if (result.doGetServiceResource.result) {
                            var GetServic = result.doGetServiceResource.result;
                            console.log('GetServic!!!!! :: ' , GetServic);
                            
                            if(GetServic!=null)
                                component.set('v.serviceResource',GetServic);
                        }
        
                    
                    // component.set('v.showSpinner', false);
                } else if(result.STATUS.result == 'E'){
                    helper.gfnShowToast("error", result.error.result);
                    // component.set('v.showSpinner', false);
                }


        });
        $A.enqueueAction(action);
    },

    fnDeleteOrderInfo : function (component, event, helper) {
        var stdConsumableOrderId = component.get('v.stdConsumableOrderId');
        var soldOutConsumableOrderId =  component.get('v.soldOutConsumableOrderId');
        console.log( ' stdConsumableOrderId : ' , stdConsumableOrderId);
        console.log( ' soldOutConsumableOrderId : ' , soldOutConsumableOrderId);
        
        var params = {
            'stdConsumableOrderId' : stdConsumableOrderId,
            'soldOutConsumableOrderId' : soldOutConsumableOrderId
        };

        var action = component.get('c.doOrderDeleteInfo');
        action.setParams({
            'paramMap': params
        });

        action.setCallback(this, function (response) {

            console.log('response' , response);
            var state = response.getState();
            if(state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('doOrderDeleteInfo :: ' , result);
                    if (result.status == 's') {
                        console.log('주문 삭제');
                        component.set('v.isOpen',false);
                    }else{

                        this.gfnShowToast("warning ", result.message);
                    }

                    

               } else {
                    console.log('주문 삭제 fail');
               }
               //23 10 05 hyungho.chun 스피너추가
               component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);

        if(component.get('v.isRePay')){
            $A.get('e.force:refreshView').fire();
        }
    },

    fnConInfoByCase : function (component, event, helper) {
        var strCaseId = component.get('v.strCaseId');

        console.log('fnConInfoByCase Id :: ' , strCaseId);
        
        // var params = {
        //     'strCaseId' : strCaseId
        // };

        var action = component.get('c.doConInfoByCase');
        action.setParams({
            'strCaseId': strCaseId
        });

        action.setCallback(this, function (response) {
            console.log('response' , response);
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result 확인 ' , JSON.stringify(result));
                component.set('v.objCont', result);
               
            } else {
                var errors = response.getError();
                console.log('strCase로 고객 조회 실패 : ' + errors);
            }
        });

        $A.enqueueAction(action);
    }
});