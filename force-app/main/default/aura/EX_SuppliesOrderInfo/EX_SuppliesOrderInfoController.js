/**
 * Created by I2MAX.SEOKHOLEE on 2022/12/25.
 */

({
    fnInit: function (component, event, helper) {


//        if(component.get('v.standardOrderData')!=null || component.get('v.soldOutOrderData')!=null)
            helper.fnSetOrderData(component, event, helper);
//            else{
//                  console.log('xxxxxxxxxxxxxxxxxxxxxxxxxx');
//
//            }
        helper.getCompanyList(component, event, helper);

    },
    paymentChange : function (component, event, helper) {


            helper.fnSetOrderData(component, event, helper);

                if(!component.get('v.latePayment')){
                     var OrderTotalSalesAmount = component.get('v.stdOrderTotalSalesAmount');
                     var OrderTotalDiscountAmount =  component.get('v.stdOrderTotalDiscountAmount');
                     var OrderTotalPointAmount = component.set('v.stdOrderTotalPointAmount');

                     component.set('v.OrderTotalSalesAmount',OrderTotalSalesAmount);
                     component.set('v.OrderTotalDiscountAmount',OrderTotalDiscountAmount);
                     component.set('v.OrderTotalPointAmount',OrderTotalPointAmount);
                }else{
                     var OrderTotalSalesAmount = parseInt(component.get('v.stdOrderTotalSalesAmount'))  + parseInt(component.get('v.soldOutOrderTotalSalesAmount')) ;
                     var OrderTotalDiscountAmount =  component.get('v.stdOrderTotalDiscountAmount') + component.get('v.soldOutOrderTotalDiscountAmount');
                     var OrderTotalPointAmount = component.set('v.stdOrderTotalPointAmount') + component.get('v.soldOutOrderTotalPointAmount');

                     component.set('v.OrderTotalSalesAmount',OrderTotalSalesAmount);
                     component.set('v.OrderTotalDiscountAmount',OrderTotalDiscountAmount);
                     component.set('v.OrderTotalPointAmount',OrderTotalPointAmount);
                }
                console.log('std : ' + component.get('v.stdOrderTotalSalesAmount') + 'sold : ' + component.get('v.soldOutOrderTotalSalesAmount') );

    },
    fnAddData: function (component, event, helper) {
                console.log('fnAddData Start data');

       var standardOrderDataList =event.getParam('standardOrderDataList');
         var soldOutOrderDataList =event.getParam('soldOutOrderDataList');


//                 standardOrderDataList.forEach(function (item) {
//                     console.log('item : ' + item.Price);
//                                 standardOrderDataList.push(item);
//                                 stdOrderTotalPaymentAmount =stdOrderTotalPaymentAmount + item.ASCPrice;
//                                 stdOrderTotalSalesAmount = stdOrderTotalSalesAmount + item.Price;
//
//                         });
//                  soldOutOrderDataList.forEach(function (item) {
//                                soldOutOrderDataList.push(item);
//                                stdOrderTotalPaymentAmount =stdOrderTotalPaymentAmount + item.ASCPrice;
//                                stdOrderTotalSalesAmount = stdOrderTotalSalesAmount + item.Price;
//
//                         });





        component.set('v.standardOrderData', standardOrderDataList);
        component.set('v.soldOutOrderData', soldOutOrderDataList);
        helper.fnSetOrderData(component, event, helper);
    },

compareAuth : function(component, event, helper){
        var expiretime = component.get('v.expAuthTime');
        var authCompText = component.get('v.authCompText');
        var authText = component.get('v.authText');
        console.log(expiretime+'마감시간');
        console.log(authCompText + ' 입력한 TEXT');
        console.log(authText + ' 서버로 부터 받은 5 자리');

        if(authCompText.trim() != authText){
            helper.showToast('ERROR','발송 된 인증번호와 다르게 입력 하셨습니다.');
            component.set('v.isTimer', true);
        }

        else {
            helper.showToast('SUCCESS','인증이 완료 되었습니다.');

            component.set('v.finishedTimer', true);
            component.set('v.isTimer', false);
            component.set('v.isEmployee',true);
            component.set('v.isConfirm', false);
            
            component.set('v.authActive', true);
//            var companyName = component.get('v.companyName');
//            var employeeNum = component.get('v.employeeNum');
//            var employeeName = component.get('v.employeeName');
            console.log('회사아아 >> ' + companyName);
//            var appEvent = $A.get("e.c:FS_CustomerDiscountPopEvt");
//            appEvent.setParams({
//                "EmpSearchResult" : true,
//                "SelectedCompany" : companyName,
//                "EmployeeNum" : employeeNum,
//                "EmployeeName" : employeeName,
//            });
//            appEvent.fire();
//
//            window.setTimeout( $A.getCallback(function() {
//                component.destroy();
//            }), 1000 );
        }

    },
    fnIdentify : function(component, event, helper) {
        //helper.identifyEmployee(component, event, helper);

        // var empchoice = component.find('listEmp').get("v.value");
        var listcompany = component.find('listcompany').get('v.value');
        var listRelation = component.find('listEmp').get('v.value');
        // console.log('초이스' + empchoice);
        // console.log('회사 초이스' + listcompany);
        var employeeNum = component.get('v.employeeNum');
        var employeeName = component.get('v.employeeName');
        var employeePhone = component.get('v.chkEmployeePhone');


        //23.10.11 PHJ
        if(listcompany == '' || listcompany == undefined) {
            helper.showToast('ERROR', '회사를 선택해주세요.');
            return;
        }
        else if(employeeNum == '' || employeeNum == undefined) {
            helper.showToast('ERROR', '사원번호를 입력해주세요.');
            return;
        } 
        else if(employeeName == '' || employeeName == undefined) {
            helper.showToast('ERROR', '성명을 입력해주세요.');
            return;
        } 
        else if(listRelation == '' || listRelation == undefined || listRelation == '관계를 선택해주세요.') {
            helper.showToast('ERROR', '관계를 선택해주세요.');
            return;
        } 
        else{
            component.set('v.chkEmployeeName', employeeName);
            component.set('v.chkEmployeeNum', employeeNum);
            component.set('v.chkCompanyName', listcompany);
            component.set('v.chkEmployeeRelationShip',listRelation);
            helper.getIdentityCheck(component, event, helper, employeeName, employeeNum, listcompany);
        }
                
                
        // if(empchoice == '' || listcompany == '' || employeeNum == '' || employeeName =='' ||
        //     empchoice ==undefined || listcompany == undefined || employeeNum == undefined || employeeName ==undefined || listRelation == '' || listRelation == undefined || listRelation == '관계를 선택해주세요.' ){
                
        //     helper.showToast('ERROR', '정확한 정보를 입력해주세요.');
        //     return;
        // } else {
        //     component.set('v.chkEmployeeName', employeeName);
        //     component.set('v.chkEmployeeNum', employeeNum);
        //     component.set('v.chkCompanyName', listcompany);
        //     component.set('v.chkEmployeeRelationShip',empchoice);
        //     helper.getIdentityCheck(component,event,helper, employeeName, employeeNum, listcompany);
        //     // 검색 완료 했다 치고 등록 해야 함 ;
        // }

    },
    
    fnReAuthNo : function(component, event, helper) {
        var employeePhone = component.get('v.chkEmployeePhone');
        component.set('v.authActive', true); //24 02 14 hyungho.chun 누르자마자 일단 바로 비활성화(재빠른 더블클릭방지)
 
        if (!helper.isPhoneNum(employeePhone) || !helper.isMobilePhone(employeePhone)) {
            helper.showToast('ERROR', '올바른 전화번호를 입력하세요.');
            component.set('v.authActive', false);
            return;
        }
        //Timer 초기화 Interval On-Off
        // if(component.get('v.finishedTimer')==true){
            component.set('v.finishedTimer', false);
            component.set('v.countDownMinutes', 2);
            component.set('v.countDownSeconds', 60);
        // }

        helper.createAuth(component,event,helper);

        window.setTimeout(
            $A.getCallback(function() {
                if(component.get('v.authText') != null){
                    console.log('생성 후 채번'+component.get('v.authText'));
                    helper.countDowntimer(component,event,helper);
                }
            }), 2000
        );
	},

    fnAuthNo : function(component, event, helper) {
        var employeePhone = component.get('v.chkEmployeePhone');
        component.set('v.authActive', true); //24 02 14 hyungho.chun 누르자마자 일단 바로 비활성화(재빠른 더블클릭방지)
 
        if (!helper.isPhoneNum(employeePhone) || !helper.isMobilePhone(employeePhone)) {
            helper.showToast('ERROR', '올바른 전화번호를 입력하세요.');
            component.set('v.authActive', false);
            return;
        }
        //Timer 초기화 Interval On-Off
        if(component.get('v.finishedTimer')==true){
            component.set('v.finishedTimer', false);
            component.set('v.countDownMinutes', 2);
            component.set('v.countDownSeconds', 60);
        }

        helper.createAuth(component,event,helper);

        window.setTimeout(
            $A.getCallback(function() {
                if(component.get('v.authText') != null){
                    console.log('생성 후 채번'+component.get('v.authText'));
                    helper.countDowntimer(component,event,helper);
                }
            }), 2000
        );
	},

    //입력값 변경 체크 (임직원 검색 후 입력값을 변경할 시, 확인 버튼 disable 처리)
    fnInputChange : function(component, event) {
        var beforeEmpNum = component.get('v.employeeNum');
        var beforeEmpName = component.get('v.employeeName');
        var beforeCompany = component.find('listcompany').get('v.value');
        var beforeRelation = component.find('listEmp').get('v.value');
        var currentEmpNum = component.get('v.chkEmployeeNum');
        var currentEmpName = component.get('v.chkEmployeeName');
        var currentCompany = component.get('v.chkCompanyName');
        var currentRelation = component.get('v.chkRelationName');

        var chkConfirm = (beforeEmpNum != currentEmpNum || beforeEmpName != currentEmpName ||  beforeCompany != currentCompany || beforeRelation != currentRelation) ? true : false;
        component.set('v.isConfirm', chkConfirm);
    },
    handleEmpResult : function(component, event, helper){
        component.set('v.isConfirm',true);

        if(component.get('v.discountType') != null){
            if(component.get('v.discountType') == '임직원'){ // 24 01 05 PHJ
                helper.showToast('success','임직원할인이 적용되었습니다');
            }
        }else{
            helper.showToast('success','임직원할인이 적용되었습니다');
        }
        
        component.set('v.empDiscountJustApplied', true); //24 02 14 hyungho.chun 임직원할인 방금적용!
        helper.fnSetOrderData(component, event, helper);
        helper.fnSetEmpDate(component, event, helper);
        component.set('v.isConfirm', true);
    },
    handlePhoneBlur: function (component, event, helper) {
        let kTarget = event.getSource();
        kTarget.set('v.value', helper.formatPhoneNum(kTarget.get('v.value')));
    },
});