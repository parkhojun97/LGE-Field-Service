/**
 * Created by pttc on 12/15/22.
 */

({
   // ----------------------- //
     // override
     // ----------------------- //
     /**
      * Event Hook. 부모로부터 전달되는 이벤트를 후킹한다.
      * @param component
      * @param slotNo 이벤트 대상 슬롯 번호
      * @param type 이벤트 타입
      * @param detail 이벤트 데이터
      * @returns {boolean} true 를 반환하면 이벤트 처리를 중단한다.
      */
     onObserved: function (component, slotNo, type, detail) {
             if(slotNo == '2' && type == 'manual') {
                var evt = $A.get("e.c:EX_ContEmp_evt");
                console.log('wwww : ' +component.get('v.isManagement'));
                evt.setParam("objEmp" ,component.get('v.objEmp'));
                evt.setParam("objCont" ,component.get('v.objCont'));
                evt.setParam("ServiceResource" ,component.get('v.serviceResource'));
                evt.setParam("prId" ,component.get('v.prId'));
                evt.setParam("isManagement" ,component.get('v.isManagement'));

                evt.fire();
             }

             console.log('type : '+ type);
             console.log('detail : '+ JSON.stringify(detail));
             console.log('취소 여부 : ' +  component.get('v.isCancel'));
             console.log('pointFlag : ' +  component.get('v.pointFlag'));
             console.log('cashFlag : ' +  component.get('v.cashFlag'));
             console.log('paidAmount : ' +  component.get('v.paidAmount'));
             if(detail.payment == 'PG_VBANK1'){
                 detail.payment = PG_VBANK;
              }
             if(slotNo == '4' && type == 'amount' && detail.body == 0){
                  component.set("v.isReset" ,true);
               }

             if(type == 'save') {
                 if(detail.method == 'credit'){

                    component.set('v.isVirtual',true);
                 }
             }

             if(type == 'amount'){
                 if(slotNo == '1' && detail.amount == 0){
                     component.set('v.pointFlag',true);
                 }
                 if(slotNo == '2' && detail.amount == 0){
                      component.set('v.cashFlag',true);
                  }
             }

            if(type == 'reset' && component.get('v.pointFlag')  && component.get('v.paidAmount') == 0 && component.get('v.isCancel')){
                component.destroy();
            }

            if(type == 'status' && slotNo == '1'){
                if(detail.amount == component.get('v.totalAmount') && detail.status == 'completed'){
                    component.set('v.isLoadingForCommonSpinner', true);
                }
            }
        if ('message' === type) {  // vf 와 통신을 위한 메시지
            const callback = (detailWithResponse) => {
                this.update(component, this.getSlots(component), slotNo, type, detailWithResponse);
            }
            this.connectVf(component, detail, callback);

            return true;
        }
        return false;
     },
   /**
      * 실행 플랫폼 구분 (desktop, mobile)
      * @returns {string}
      */
     getPlatform: function () {
         return 'desktop'
     },

     // ----------------------- //
     // method
     // ----------------------- //
     readerListener: null,
     addCardReaderListener: function (component, detail, callback) {
         //카드 승인후 callback
         if (null != this.readerListener) { // 어느 곳에서든 저장됐던 리스너는 제거해주면 된다.
             window.removeEventListener('message', this.readerListener, false);
             this.readerListener = null;
         }
         this.readerListener = (evt) => {
             window.removeEventListener('message', this.readerListener, false);
             this.readerListener = null;

             let response = evt.data;
             console.log("response From VF : ", JSON.stringify(response));
             let offset =  new Date().getTimezoneOffset() * 60000;
             let dateOffset = new Date(new Date().getTime() - offset);
             console.log('속도측정 -------------------------------------------------- EX_Payment.cmp.addCareReaderLister - 결과:' + dateOffset.toISOString());

             detail.isSuccess = response.result !== 'f';
             detail.response = response;
             callback(detail);

         };
         window.addEventListener('message', this.readerListener, false); //-> FNPaymentCard.drive > doSave
     },

     reprintAll: function (component) {
         const data = this.getSlots(component).map(e => e.getPrintData()).filter(e => !!e);
         if (data && data.length) {
             this.loopPrint(component, data)
         }
     },

     loopPrint: function(component, data) {

         if(data && data.length) {
             const d = {
                 action: 'print',
                 body: data.shift()
             }
             const callback = (detail) => {

                 if(detail.isSuccess){
                     if(data.length) {
                         this.loopPrint(component, data);
                     }
                 }else{
                     this.toast("인쇄 에러 : " +detail.response.resultMsg, 'f');
                 }

             }
             this.connectVf(component, d, callback);
         }
     },

     connectVf: function (component, detail, callback) {
         const vfWindow = component.find('vfFrame').getElement().contentWindow;
         const action = detail.action;
         const body = detail.body;
         if ('card' === action) {
             this.addCardReaderListener(component, detail, callback);
         } else if ('print' === action) {
             this.addCardReaderListener(component, detail, callback);

             let kDept = component.get('v.dept');
             if(kDept){
                 body.company = kDept.BIZ_NAME__c;
                 body.bizNo = this.formatBizNo(kDept.BIZ_ID__c);
                 body.address = '';
                 if(kDept.ADDRESS_NEW__c){
                     body.address = kDept.ADDRESS_NEW__c +' '
                 }
                 if(kDept.DETAIL_ADDR__c){
                     body.address += kDept.DETAIL_ADDR__c;
                 }

                 body.bossName = kDept.CHIEF_NAME__c;
                 body.tel = kDept.TEL_NO__c;
             }
             console.log('print == ', JSON.stringify(body));
         }
         const message = body;
         message.action = action;

         vfWindow.postMessage(message, '*');
     },

    // updateSoldOutOrder: function(component, soldOutOrder) {
    //      var action = component.get('c.updateSoldOutOrder');
    //      var prLiIdSet = [];
    //      soldOutOrder.forEach(function(item) {
    //          prLiIdSet.add(item.Id);
    //      })
    //      action.setParam('prLiIdSet', prLiIdSet);
    //
    //      action.setCallback(this, function(response) {
    //          var state = response.getState();
    //          if (state === 'SUCCESS') {
    //              console.log('품절주문건 주문상태 업데이트 성공');
    //          }
    //          else if (state === 'ERROR') {
    //              var errors = response.getError();
    //              console.log('품절주문건 주문상태 업데이트 실패 : ' + errors);
    //          }
    //      });
    //
    //      $A.enqueueAction(action);
    // }
});