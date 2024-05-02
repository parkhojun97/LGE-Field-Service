({
    gfnInit : function(component) {
		let offset =  new Date().getTimezoneOffset() * 60000;
		let dateOffset = new Date(new Date().getTime() - offset);
		console.log('속도측정 -------------------------------------------------- EX_DocPreview.gfnInit - start:' + dateOffset.toISOString());
        console.log('RCVRName ::: ',component.get("v.RCVRName"));
        console.log('contactAddress  :::  ',component.get('v.contactAddress'));
        component.set("v.isLoading", true);
        console.log(component.get('v.latePayment') );
        // 24-02-13 PHJ
        // if(component.get('v.IsPrint') == false){
        //     component.set('v.soldOutConsumableOrderId',null);
        // }
        if(component.get('v.stdConsumableOrderId') == null && component.get('v.soldOutConsumableOrderId') != null){
            component.set('v.IsPrint', true);
        }
        if(component.get('v.isManagement') == false){
            var tmpComponent = component.get('v.value');
            for (var idx in tmpComponent) {
                console.log('선택됨 ' +tmpComponent[idx]);
                if(tmpComponent[idx] == '견적서')component.set('v.quoteYN',true);
                if(tmpComponent[idx] == '사업자등록증')component.set('v.regiYN',true);
                if(tmpComponent[idx] == '명세서')component.set('v.specYN',true);
                if(tmpComponent[idx] == '통장사본')component.set('v.bankYN',true);
            }
            var self = this;
             console.log('aa ' +component.get('v.RCVRName'));

            var action = component.get('c.getTemplate');
            var params = {
                'IsPrint' : component.get('v.IsPrint'),
                'latePayment' : component.get('v.latePayment'),
                'isManagement' : component.get('v.isManagement'),
                'orderNumber' : component.get('v.orderNumber'),
                'RCVRName' : component.get("v.RCVRName"),
                'RCVREmail' : component.get("v.RCVREmail"),
                'Note' : component.get("v.Note"),
                'value' : JSON.stringify(component.get('v.value')),
                'isManagement' : component.get('v.isManagement'),
                'standardOrderData' : JSON.stringify(component.get("v.standardOrderData")),
                'soldOutOrderData' : component.get("v.soldOutOrderData") != null ? JSON.stringify(component.get("v.soldOutOrderData")) : null,
                'contactId' : component.get('v.contactId'),

                //23 09 02 hyungho.chun 주소 받기
                'contactAddress' :  component.get('v.contactAddress'),

                'stdConsumableOrderId' : component.get('v.stdConsumableOrderId'),
                'soldOutConsumableOrderId' : component.get('v.soldOutConsumableOrderId'),
                'isEmployee' : component.get('v.isEmployee'),
                'discountType' : component.get('v.discountType'),
                'stdOrderTotalDiscountAmount' : component.get('v.stdOrderTotalDiscountAmount')

            };
            action.setParams({
                 'paramMap' : params

            });
            console.log('paramMap > ', params);
            action.setCallback(this, function(response) {
            var sState = response.getState();
                console.log('-------------------------------------------------- EX_DocPreview.getTemplate - SUCCESS');
                if(sState === "SUCCESS") {
                    var returnMap = response.getReturnValue();
                    console.log('Ex_DOCPreview . getTemplate. returnMap : ' + returnMap );
                    var orderNumber = returnMap['orderNo'];
                    console.log('orderNumber: ' +orderNumber);
                    var quoteId = returnMap['quoteId'];
                    console.log('quoteId : ' + quoteId);
                    component.set('v.createdQuoteId', quoteId);

                    //var orderNumber = response.getReturnValue();
                    var order='contactId='+component.get("v.contactId") +'&orderNumber='+orderNumber;
                    console.log('order : ' + order);
                    if(component.get('v.quoteYN')){
                        component.set('v.pdfUrl','/apex/EX_SuppliesPDF?id=quote&'+ order);
                        console.log(component.get('v.pdfUrl'));

                    }
                    if(component.get('v.specYN'))
                        component.set('v.invoicePdfUrl','/apex/EX_SuppliesPDF?id=invoice&'+ order);
                    component.set('v.regiPdfUrl', '/apex/EX_SuppliesPDF?id=regi&'+ order);
                    component.set('v.bankPdfUrl','/apex/EX_SuppliesPDF?id=bank&'+ order);
                    component.set("v.isLoading", false);

                }
                else if(sState === "ERROR") {
                    var errors = response.getError();
                    console.log(JSON.stringify(errors));
                    console.table(errors);
                    component.set("v.isLoading", false);
                    if(errors[0].message == 'List index out of bounds: 0'){
                        this.gfnShowToast("error", '견적 가능한 주문 품목이 없습니다.');
                    }else{
                        this.gfnShowToast("error", errors[0].message);
                    }
                    this.gfnCancel(component);
                    
                }
                else {
                    this.gfnShowToast("error", "System Error.");
                }


            });

            $A.enqueueAction(action);
        }
        else{
             var action = component.get('c.getTemplate');
             //23.04.19
             var tmpComponent = component.get('v.value');
             for (var idx in tmpComponent) {
                 console.log('선택됨 ' +tmpComponent[idx]);
                 if(tmpComponent[idx] == '견적서')component.set('v.quoteYN',true);
                 if(tmpComponent[idx] == '사업자등록증')component.set('v.regiYN',true);
                 if(tmpComponent[idx] == '명세서')component.set('v.specYN',true);
                 if(tmpComponent[idx] == '통장사본')component.set('v.bankYN',true);


             }
             ///

            console.log('주문번호 : '+component.get('v.orderNumber'));
             var params = {
                 isManagement : true,
                 latePayment : false,
                 orderNumber : component.get('v.orderNumber'),
                 parentId : component.get('v.parentId'),
                //23 09 02 hyungho.chun 주소 받기
                 contactAddress :  component.get('v.contactAddress'),  
                 //23 09 04 hyungho.chun 이름 받기
                 RCVRName : component.get("v.RCVRName"),               
                 value : JSON.stringify(component.get('v.value')),
                 discountType: component.get('v.discountType'),
                 Note : component.get('v.Note'),
                 RCVREmail : component.get('v.RCVREmail'),
             };
             action.setParams({
                 'paramMap' : params
                 });
                  action.setCallback(this, function(response) {
					let offset =  new Date().getTimezoneOffset() * 60000;
					let dateOffset = new Date(new Date().getTime() - offset);
					console.log('속도측정 -------------------------------------------------- EX_DocPreview.getTemplate - SUCCESS:' + dateOffset.toISOString());

                      var sState = response.getState();
                      if(sState === "SUCCESS") {
                          var returnMap = response.getReturnValue();
                          console.log('Ex_DOCPreview . getTemplate. returnMap : ' + returnMap );
                          console.log('Ex_DOCPreview . getTemplate. returnMap : ' + JSON.stringify(returnMap) );
                          var orderNumber = returnMap['orderNo'];
                           console.log('orderNumber: ' +orderNumber);
                           var quoteId = returnMap['quoteId'];
                           console.log('quoteId : ' + quoteId);
                           component.set('v.createdQuoteId', quoteId);

                           console.log('getTemplate이후 만들어진 Quoteid 조회 component.get(v.createdQuoteId) :: '+component.get('v.createdQuoteId'));
                          //var orderNumber = response.getReturnValue();
                          component.set("v.stdConsumableOrderId", params.parentId);
                          console.log('ordernumber: ' +params.parentId);
                          var order='contactId='+component.get("v.contactId") +'&orderNumber='+params.parentId;
//                          component.set('v.specYN',true);
					      console.log('@@@@@ order : ' + order);
                          component.set('v.pdfUrl','/apex/EX_SuppliesPDF?id=quote&'+ order);
                          component.set('v.invoicePdfUrl','/apex/EX_SuppliesPDF?id=invoice&'+ order);
                          ////23.04.19
                          component.set('v.regiPdfUrl', '/apex/EX_SuppliesPDF?id=regi&'+ order);
                          component.set('v.bankPdfUrl','/apex/EX_SuppliesPDF?id=bank&'+ order);
                          ///////
                          }
                      else if(sState === "ERROR") {
                          var errors = response.getError();
                          console.log(JSON.stringify(errors));
                          console.table(errors);
                          component.set("v.isLoading", false);
                          if(errors[0].message == 'List index out of bounds: 0'){
                            this.gfnShowToast("error", '견적 가능한 주문 품목이 없습니다.');
                        }else{
                            this.gfnShowToast("error", errors[0].message);
                        }
                        this.gfnCancel(component);
                      }
                      else {
                          this.gfnShowToast("error", "System Error.");
                      }
                      component.set("v.isLoading", false);
                  });
                  $A.enqueueAction(action);
        }
    },

    gfnSave : function(component) {

             var action = component.get("c.saveQuote");
            if(component.get('v.documentId')==null){
                return this.showToast('error','견적서가 초기화 되었습니다');
            }
            const orderNum = component.get('v.parentId') ? component.get('v.parentId') : component.get('v.stdConsumableOrderId') ? component.get('v.stdConsumableOrderId') : component.get('v.soldOutConsumableOrderId') ? component.get('v.soldOutConsumableOrderId') : '';
            var params = {
                        'IsPrint' : component.get('v.IsPrint'),
                        'recordId' : component.get('v.contactId'),
                         'RCVRName' : component.get('v.RCVRName'),
                         'RCVREmail' : component.get('v.RCVREmail'),
                         'isManagement' : component.get('v.isManagement'),
                        'orderNumber' : orderNum,

                        //23.04.28 추가
                        'Note' : component.get('v.Note'),

                        'quoteId' : component.get('v.createdQuoteId'),
                       };
               	        action.setParams({
                                'paramMap' : params

               	        });
          action.setCallback(this, function(response) {
            var sState = response.getState();
                if(sState === "SUCCESS") {
                        var  documentIdList= response.getReturnValue();
    //
                        component.set('v.documentId',documentIdList[0]);
                        component.set('v.invoiceId',documentIdList[1]);
    //                    component.set('v.idList',documentIdList);

                        this.gfnShowToast("success", "저장완료");

                        ///23.04.17
                        var cmpEvent = component.getEvent("refreshEvent");
                        cmpEvent.setParams({
                            "msg" : documentIdList[0], 'origin' : documentIdList[1] });
                        cmpEvent.fire();
                        ///23.04.17

                        component.destroy();


                }
                else if(sState === "ERROR") {
                    var errors = response.getError();
                    console.log(JSON.stringify(errors));
                    console.table(errors);
                    self.gfnShowToast("error", errors[0].message);
                }
                else {
                    self.gfnShowToast("error", "System Error.");
                }

                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);

        },

     gfnCancel : function(component) {

                 var action = component.get("c.cancelQuote");
                 console.log('std ' +component.get('v.stdConsumableOrderId'));
                  console.log('oo ' +component.get('v.soldOutConsumableOrderId'));

                action.setParams({
                        'orderNumber' : component.get('v.orderNumber')


                });
          action.setCallback(this, function(response) {
                      console.log('end-------------------------------');

            var sState = response.getState();
                if(sState === "SUCCESS") {
                        component.set('v.documentId','');
                        console.log('pdf생성 취소');


                        ///23.04.17
                        var cmpEvent = component.getEvent("refreshEvent");
                        cmpEvent.fire();
                        ///23.04.17

                        component.destroy();


                }
                else if(sState === "ERROR") {
                    var errors = response.getError();
                    console.log(JSON.stringify(errors));
                    console.table(errors);
                    self.gfnShowToast("error", errors[0].message);
                }
                else {
                    self.gfnShowToast("error", "System Error.");
                }

                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);

        },
    gfnShowToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type"    : type,
            "message" : message
        });
        toastEvent.fire();
    },

})