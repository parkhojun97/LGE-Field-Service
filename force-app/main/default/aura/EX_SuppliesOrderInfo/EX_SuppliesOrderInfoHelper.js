/**
 * Created by I2MAX.SEOKHOLEE on 2022-12-26.
 */

({
    fnSetOrderData: function (component, event, helper) {


        var standardOrderDataList = component.get('v.standardOrderData');

        var remark = component.get('v.remark');
        console.log('json:  ' +standardOrderDataList);

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
        component.set('v.vipDiscount', vipDiscount);//24 02 15 hyungho.chun

        var vipTotal = 0;
        var empTotal = 0;
        var promotionTotal = 0;
        // 임직원 여부
        var isEmployee = component.get('v.isEmployee');
//        var isEmployee = true;
        var discountType = component.get('v.discountType');
        standardOrderDataList.forEach((item) => {

            var alreadyAppliedPromotionDiscountAmount = 0;

            alreadyAppliedPromotionDiscountAmount = item.DiscountAmount != 0 || item.DiscountAmount != null 
            ? item.DiscountAmount : 0;


            if(item.PromotionPrice == undefined){
                item.PromotionPrice = 0;
            }
            console.log('management : '+ component.get('v.isManagement'));
            console.log('item.discountType : '+ item.discountType);
//            if(component.get('v.isManagement')){
//                if(item.discountType == '임직원'){
//                    component.set('v.isEmployee', true);
//                }
//                else if(item.discountType == 'VIP'){
//                    vipDiscount = item.DiscountAmount/(item.Price * item.QTY);
//                    console.log('vipDiscount!!!! : '+ item.DiscountAmount/(item.Price * item.QTY));
//
//                }
//            }
            // 판매금액
            item.SalesAmount = item.QTY * item.Price;
            // 포인트
            // 결제 금액 현금
            item.PaymentAmount_CASH = 0;
            // 결제 금액 카드
            item.PaymentAmount_CARD = 0;
            // 결제 금액
            item.PaymentAmount = 0;
            item.DiscountAmount = 0;


            if(item.PromotionPrice == null){
                item.PromotionPrice = 0;
            }
            //24.02.15 gw.lee
            //금액뒤집는 로직 제거
            // if(item.PromotionPrice != 0 && component.get('v.isManagement')){
            //     item.PromotionPrice = item.Price * item.QTY - item.PromotionPrice;
            // }
            console.log('할인 타입 : '+item.discountType);
            console.log('vipDiscount : '+ vipDiscount);
            console.log('PromotionPrice : '+item.PromotionPrice);
            console.log('ASCPrice : '+item.ASCPrice);

            //24.02.15 gw.lee
            //vip가 할인율 1순위임으로, vip할인율 금액이 있을 경우, vip할인율 적용
            //vip 할인 : 할인 할 금액비교 
            //임직원 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 작으면 임직원)
            //프로모션가 할인 : 할인 후 금액 비교 (ASCPrice - 프로모션가가 더 크면 프로모션)
            // if((item.Price * vipDiscount - item.ASCPrice > 0) || component.get('v.isEmployee') == false && vipDiscount != 0){
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
                //        if(component.get('v.isEmployee') && discountType != null){
                //            helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.'); 
                //        }
                //     }
                //     else{
                //        item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                //        item.discountType = 'VIP';
                //        component.set('v.discountType','VIP');
                //        vipTotal += item.DiscountAmount;
                //        if(component.get('v.isEmployee') && discountType != null){
                //         //   helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.'); //24 01 02 hyungho.chun vip 할인-> vip할인이라 토스트 메세지 필요없음
                //        }
                //     }
                // }
            }else if(( component.get('v.isManagement') ? (item.ASCPrice - item.PromotionPrice < 0 && component.get('v.isEmployee') == true): (item.ASCPrice - item.PromotionPrice < 0 && component.get('v.isEmployee'))) || (item.PromotionPrice == 0 && component.get('v.isEmployee'))){
                // 24 01 05 PHJ   
                // 2024.01.08 seung yoon heo 임직원 할인 적용
                if(alreadyAppliedPromotionDiscountAmount < (item.QTY * (item.Price - item.ASCPrice))){
                    item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
                    item.discountType = '임직원';
                    component.set('v.discountType','임직원');
                    empTotal += item.DiscountAmount;
                }else if(alreadyAppliedPromotionDiscountAmount > (item.QTY * (item.Price - item.ASCPrice))){
                    item.DiscountAmount = alreadyAppliedPromotionDiscountAmount;
                    item.discountType = '프로모션';
                    component.set('v.discountType','프로모션');
                    promotionTotal += item.DiscountAmount;
                }
               //  else if(alreadyAppliedPromotionDiscountAmount == 0 || alreadyAppliedPromotionDiscountAmount == null || alreadyAppliedPromotionDiscountAmount == undefined){
               //    item.DiscountAmount = item.QTY * item.ASCPrice;     
               // }
              if(component.get('v.isEmployee') && discountType != null && item.PromotionPrice != 0 && item.PromotionPrice != undefined){ // 24 01 02 hyungho.chun item.PromotionPrice != 0 조건 추가 ( 프로모션 할인이있었는데 임직원할인이 높아서 바뀐경우에만 토스트메세지)
                  helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.');
              }
            } else if(item.PromotionPrice !=0  && item.PromotionPrice != null){
                item.DiscountAmount = (item.Price - item.PromotionPrice) * item.QTY;
                item.discountType = '프로모션';
                component.set('v.discountType','프로모션');
                promotionTotal += item.DiscountAmount; 
            }

            console.log('orderinfo  : ' +item.discountType + ' ' + item.DiscountAmount);

            // 소모품 창고
            item.DIV_CODE__c = 'PH8002';

            standardTotalCount += 1;
            standardTotalSalesAmount += item.SalesAmount;
            standardTotalPayment_CASH += item.PaymentAmount_CASH;
            standardTotalPayment_CARD += item.PaymentAmount_CARD;
            standardTotalDiscountAmount += item.DiscountAmount;
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

            console.log('할인 : '  +standardTotalDiscountAmount);
        });

        component.set('v.vipDiscountAmount', vipTotal);
        component.set('v.empDiscountAmount', empTotal);
        component.set('v.promotionDiscountAmount', promotionTotal);

        component.set('v.stdOrderTotalSalesCount', standardTotalCount);
        component.set('v.stdOrderTotalSalesAmount', standardTotalSalesAmount);
        component.set('v.stdOrderTotalDiscountAmount', standardTotalDiscountAmount);
        component.set('v.stdOrderTotalPaymentAmount', standardTotalSalesAmount  - standardTotalDiscountAmount);
        standardTotalPaymentAmount = standardTotalPayment_CASH +standardTotalPayment_CARD+standardTotalPointAmount;
        component.set('v.standardOrderData',standardOrderDataList);

        //24 02 15 hyungho.chun 일반주문계산후 할인금액초기화
        // var vipTotal = 0;
        // var empTotal = 0;
        // var promotionTotal = 0;


        var soldOutOrderDataList = component.get('v.soldOutOrderData');

        console.log('soldOutOrderDataList ' +soldOutOrderDataList );
//        if(!component.get('v.latePayment')){
//            soldOutOrderDataList = [];
//        }
        console.log(soldOutOrderDataList);
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
        var vipDiscount = component.get('v.ContactVIP') != undefined ? component.get('v.ContactVIP') : 0;
//        var vipDiscount = 0.25;
        component.set('v.vipDiscount', vipDiscount);//24 02 15 hyungho.chun
//         임직원 여부
        var isEmployee = component.get('v.isEmployee');
        console.log('ddddd '+component.get('v.discountType'));


//        var isEmployee = true;
        soldOutOrderDataList.forEach((item) => {
            if(item.PromotionPrice == undefined){
                item.PromotionPrice = 0;
            }
            // 판매금액
            item.SalesAmount = item.QTY * item.Price;
            // 할인금액
            item.DiscountAmount = 0;
            // 포인트
            item.PointAmount = 0;
            // 결제 금액 현금
            item.PaymentAmount_CASH = 0;
            // 결제 금액 카드
            item.PaymentAmount_CARD = 0;
            // 결제 금액
            item.PaymentAmount = 0;
            console.log('vipDiscount : '+item.Price * vipDiscount);
            console.log('PromotionPrice : '+item.PromotionPrice  * item.QTY);
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
            // if((item.Price * vipDiscount - item.ASCPrice > 0) || component.get('v.isEmployee') == false && vipDiscount != 0){

            if (vipDiscount != 0) {
                item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                item.discountType = 'VIP';
                component.set('v.discountType','VIP');
                vipTotal += item.DiscountAmount;
                // if((item.Price * vipDiscount * item.QTY > item.PromotionPrice * item.QTY)){// 24 01 03 PHJ
                // //  if(component.get('v.isEmployee') && discountType != null){
                // //      helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.'); //24 01 02 hyungho.chun 일반주문에도 없어서 품절주문에도 뺌
                // //  }
                // }else{
                //     if(item.PromotionPrice != 0){
                //        item.DiscountAmount = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                //        item.discountType = '프로모션';
                //        component.set('v.discountType','프로모션');
                //        promotionTotal += item.DiscountAmount;
                //      if(component.get('v.isEmployee') && discountType != null){
                //          helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.');
                //      }
                //     }
                //     else{
                //        item.DiscountAmount = item.QTY * item.Price * vipDiscount;
                //        item.discountType = 'VIP';
                //        component.set('v.discountType','VIP');
                //        vipTotal += item.DiscountAmount;
                //      if(component.get('v.isEmployee') && discountType != null){
                //         //  helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.'); //24 01 02 hyungho.chun vip 할인-> vip할인이라 토스트 메세지 필요없음
                //      }
                //     }
                // }
                //23 09 22 임직원할인 품절주문 로직이 일반주문때와 달라서 같에 변경 ( item.ASCPrice - item.PromotionPrice > 0 -> item.ASCPrice - item.PromotionPrice < 0)
            }else if(( component.get('v.isManagement') ? item.ASCPrice - item.PromotionPrice < 0 && isEmployee : item.ASCPrice - item.PromotionPrice < 0 && isEmployee) || (item.PromotionPrice == 0 && isEmployee)){
               item.DiscountAmount = item.QTY * (item.Price - item.ASCPrice);
               item.discountType = '임직원';
               component.set('v.discountType','임직원');
               empTotal += item.DiscountAmount;
                if(component.get('v.isEmployee') && discountType != null && item.PromotionPrice != 0){  // 24 01 02 hyungho.chun item.PromotionPrice != 0 조건 추가 ( 프로모션 할인이있었는데 임직원할인이 높아서 바뀐경우에만 토스트메세지)
                    helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.');
                }
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
                if(component.get('v.isEmployee') && discountType != null){
                    //  helper.showToast('success','중복할인이 불가하여 할인율 높은 것으로 자동 반영되었습니다.');  //24 01 02 hyungho.chun 프로모션 -> 프로모션 할인이라 토스트 메세지 필요없음
                }
            }
            soldOutTotalCount += 1;
            soldOutTotalSalesAmount += item.SalesAmount;
            soldOutTotalDiscountAmount += item.DiscountAmount;
            soldOutTotalPayment_CASH += 0;
            soldOutTotalPayment_CARD += 0;
            soldOutTotalPointAmount += 0;
            console.log('dico :' +item.DiscountAmount);

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
        component.set('v.soldOutOrderData',soldOutOrderDataList);
            var soldOutOrderData = component.get('v.soldOutOrderData');
            console.log('Start====================');
            console.log('soldOutOrderData');
            console.log(soldOutOrderData);


        // 품절 주문 총 결제금액
        console.log('ddddd2 '+component.get('v.discountType'));

        //24 02 15 hyungho.chun 
        // component.set('v.vipDiscountAmount', vipTotal);
        // component.set('v.empDiscountAmount', empTotal);
        // component.set('v.promotionDiscountAmount', promotionTotal);


        console.log('soldOutTotalSalesAmount ', soldOutTotalSalesAmount );
        console.log('soldOutOrderTotalPaymentAmount ', soldOutTotalSalesAmount - soldOutTotalDiscountAmount );
        component.set('v.remark', remark);
        component.set('v.soldOutOrderTotalSalesCount', soldOutTotalCount);
        component.set('v.soldOutOrderTotalSalesAmount', soldOutTotalSalesAmount);
        component.set('v.soldOutOrderTotalDiscountAmount', soldOutTotalDiscountAmount);
        component.set('v.soldOutOrderTotalPointAmount', soldOutTotalPointAmount);
        component.set('v.soldOutOrderTotalPaymentAmount', soldOutTotalSalesAmount - soldOutTotalDiscountAmount);
        soldOutTotalPaymentAmount = soldOutTotalSalesAmount - soldOutTotalDiscountAmount;
        console.log('일반 할이 ; ' +parseInt(component.get('v.stdOrderTotalDiscountAmount')) +' 품절 할인 : ' + parseInt(component.get('v.soldOutOrderTotalDiscountAmount')));
        var OrderTotalSalesAmount = standardTotalSalesAmount + soldOutTotalSalesAmount;
        var OrderTotalDiscountAmount = parseInt(component.get('v.stdOrderTotalDiscountAmount'))  + parseInt(component.get('v.soldOutOrderTotalDiscountAmount'));
        var OrderTotalPointAmount = soldOutTotalPointAmount + standardTotalPointAmount;
        var OrderTotalPaymentAmount = soldOutTotalPaymentAmount + standardTotalPaymentAmount;
        component.set('v.OrderTotalSalesAmount',OrderTotalSalesAmount);
        component.set('v.OrderTotalPaymentAmount',OrderTotalPaymentAmount);

        console.log('disc : ' + OrderTotalDiscountAmount);
        component.set('v.OrderTotalDiscountAmount',OrderTotalDiscountAmount);
        component.set('v.OrderTotalPointAmount',OrderTotalPointAmount);



    },

    getCompanyList : function(component, event, helper){
        const columns = [];
        var action = component.get("c.getCompanyList");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = JSON.parse(JSON.stringify(response.getReturnValue()));

                for(let i=0;i<result.length;i++) {
                    columns.push({"companyId":result[i].CP_ID,"companyName":result[i].CP_NAME});
                }
                console.log('columns ?? ' + columns);
                component.set('v.companyList', columns);
            }
        });
        $A.enqueueAction(action);

    },
    createAuth : function(component, event, helper){

        var action = component.get("c.generateAuth");
        var chkCompanyPhone = component.get('v.chkEmployeePhone');

        action.setParams({
            phonenumber : chkCompanyPhone
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                let date = new Date();
                console.log(date)
                date.setMinutes(date.getMinutes() + 10);
                console.log(JSON.stringify(result)+'번호 생성');
                component.set('v.authText', result.authText);
                console.log(result.authText +' <<<<<<<');
                // 개발환경용 테스트
                //23 10 01 hyungho.chun 인증번호 운영환경 자동기입 제거
                // component.set('v.authCompText',result.authText);
                component.set('v.expAuthTime', date);
                component.set('v.isTimer', true);

                
                setTimeout(function () {
                    component.set('v.reTimer', true);
                    component.set('v.authActive', false);
                }, 3000);
            }
        });
        $A.enqueueAction(action);

    },

    getIdentityCheck : function (component, event, helper, employeeName, employeeNum, listcompany){
        var action = component.get("c.identityCheck");
        action.setParams({
            employeeName : employeeName,
            employeeNum : employeeNum,
            listcompany : listcompany
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {

                //24 02 15 hyungho.chun 여기 FS올리기전에 다 지워야함
                // var result = response.getReturnValue();
                // console.log(JSON.stringify(result)+'<<<<<<<<<<<<<<<<<');
                // component.set('v.companyName', result.companyName);
                // var appEvent = $A.get("e.c:FS_CustomerDiscountPopEvt");
                // appEvent.setParams({
                // "EmpSearchResult" : true,
                // });
                // console.log('로깅 완료 ');
                // appEvent.fire();
                // component.set('v.isAuth', true);
                // component.set('v.finishedTimer', true);
                // component.set('v.isTimer', false);
                // component.set('v.isEmployee',true);
                // component.set('v.isConfirm',false);

            //24 02 15 hyungho.chun 임직원할인 파샬에서 테스트용으로 잠시 뚫어놓음    
                var result = response.getReturnValue();
                console.log(JSON.stringify(result)+'<<<<<<<<<<<<<<<<<');
               if(result.identityCheck===true){
                    component.set('v.companyName', result.companyName);
                    var appEvent = $A.get("e.c:FS_CustomerDiscountPopEvt");
                    appEvent.setParams({
                        "EmpSearchResult" : true,
                    });
                    console.log('로깅 완료 ');
                    appEvent.fire();
                    component.set('v.isAuth', true);
               } else {
                    component.set('v.isConfirm', true);
                    this.showToast('ERROR','임직원 할인대상이 아닙니다.');
               }
            }
        });
        $A.enqueueAction(action);


    },

    countDowntimer : function(component, event, helper){
        var countDownMinutes = component.get('v.countDownMinutes');
        var countDownSeconds = component.get('v.countDownSeconds');

        console.log(countDownMinutes  + '/////////'   + countDownSeconds);
        console.log('TIMER 호출 시작');
        if(countDownMinutes != null && countDownSeconds >= 0 && component.get('v.reTimer') == false){
            let self = this;
            var interval = window.setInterval(
                $A.getCallback(function() {

                    if(component.get('v.finishedTimer')==true){
                        window.clearInterval(interval);
                        component.set('v.countDownMinutes',2);
                        component.set('v.countDownSeconds', 60);
                        component.set('v.isTimer', false);
                        component.set('v.authText', '');
                        component.set('v.expAuthTime', null);
                    }
                    console.log('1');
                    self.countDownAction(component,event,helper);
                }), 1000
            );
            component.set('v.setIntervalId', component.getGlobalId());
        } else {

            console.log('타이머 체크 실패');
        }

    },

    countDownAction : function(component, event, helper){
        var countDownMinutes = component.get('v.countDownMinutes');
        var countDownSeconds = component.get('v.countDownSeconds');

        console.log('TIMER 호출 시작');
        if(countDownMinutes != null && countDownSeconds !=null ){
                    
                if(countDownMinutes==0 && countDownSeconds==0){
                    component.set('v.finishedTimer',true);
                    component.set('v.reTimer',false);
                    // 2023.09.20 seung yoon heo 인증시간 종료시 버튼 재 활성화
                    component.set('v.authActive',false);
                }
                if(countDownSeconds==0 && countDownMinutes!=0){
                    component.set('v.countDownMinutes', countDownMinutes-1);
                    component.set('v.countDownSeconds', 60);
                } else {
                    console.log('KEEP COUNTING');
                    if(!(countDownMinutes == 0 && countDownSeconds == 0)) {
                        component.set('v.countDownSeconds', countDownSeconds-1);
                    }
                    if(countDownMinutes==1 && countDownSeconds == 0){
                        console.log('1분이여서 타야하는데');
                        component.set('v.countDownMinutes',0);
                        component.set('v.countDownSeconds', 60);
                    }

                }
        } else {
            console.log(component.get('v.setIntervalId'));
            component.set('v.finishedTimer',true);
            // 2023.09.20 seung yoon heo 인증시간 종료시 버튼 재 활성화
            component.set('v.authActive',false);
            window.clearInterval(component.get("v.setIntervalId"));
        }

    },
    fnSetEmpDate: function(component, event, helper){
        var action = component.get("c.setEmpData");
        var orderNumber = component.get('v.prOrderNumber');
        var chkEmployeeName = component.get('v.chkEmployeeName');
        var chkEmployeeNum = component.get('v.chkEmployeeNum');
        var chkCompanyName = component.get('v.chkCompanyName');
        var chkCompanyPhone = component.get('v.chkEmployeePhone');
        var chkEmployeeRelationShip = component.get('v.chkEmployeeRelationShip');

        var standardOrderDataList = component.get('v.standardOrderData');
        var soldOutOrderDataList = component.get('v.soldOutOrderData');

        var params = {
            orderNumber : orderNumber,
            chkEmployeeName : chkEmployeeName,
            chkEmployeeNum : chkEmployeeNum,
            chkCompanyName : chkCompanyName,
            chkCompanyPhone : chkCompanyPhone,
            chkEmployeeRelationShip : chkEmployeeRelationShip,

            standardOrderDataList : JSON.stringify(standardOrderDataList),
            soldOutOrderDataList : JSON.stringify(soldOutOrderDataList)
            };

        action.setParams({
            'paramMap' : params
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                    console.log('임직원정보 update');
               } else {
                    console.log('임직원정보 fail');
               }

        });
        $A.enqueueAction(action);

    },
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt"
            , type: type
            , message: message
        });
        evt.fire();
    },
    isPhoneNum: function (phoneNum) {
        if (phoneNum) {
            let kFirstChar = phoneNum.slice(0, 1);
            if (kFirstChar !== '0') {
                return false;
            }
            let kOnlyNum = phoneNum.replace(/\D/g, '');
            return kOnlyNum.length > 8 && kOnlyNum.length < 12;
        }
        return false;
    },
    isMobilePhone: function (phoneNum) {
        if (!this.isPhoneNum(phoneNum)) {
            return false;
        }
        const kValidArray = ['010', '011', '016', '017', '018', '019'];
        let kFirstPart = phoneNum.slice(0, 3);
        let kOnlyNum = phoneNum.replace(/\D/g, '');
        return kValidArray.includes(kFirstPart) && kOnlyNum.length > 9;
    },
    formatPhoneNum: function (phoneNum) {
        if (!this.isPhoneNum(phoneNum)) {
            return phoneNum;
        }
        return phoneNum.replace(/\D/g, '').replace(/^(\d{2,3})(\d{3,4})(\d{4})$/g, `$1-$2-$3`);
    },

});