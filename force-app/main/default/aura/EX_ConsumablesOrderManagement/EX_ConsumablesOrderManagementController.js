/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-03.
 */

({
    fnInit: function (component, event, helper) {
        console.log('-------------------------------------------------- EX_ConsumablesOrderManagement.fnInit - start');
        component.set('v.showSpinner', true);


        //23 11 02 hyungho.chun 하위컴포넌트에서 보내줌
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     console.log('확인 ?? ' , JSON.stringify(response));
        //     var focusedTabId = response.tabId;
            
        //     workspaceAPI.setTabLabel({
        //         tabId: focusedTabId,
        //         label: "소모품주문관리"
        //     });
        //     workspaceAPI.setTabIcon({
        //         tabId: focusedTabId,        
        //         icon: 'custom:custom18'
        //     });
            
        // })

  

        //23 09 08 hyungho.chun serviceResource
        helper.fngetServiceResource(component, event, helper);
        //23 09 07 hyungho.chun 임시로 값보려고 열어둠
        helper.doGetInitData(component, event, helper);

       
        var mapSearchParam = component.get('v.mapSearchParam');

        var baseDateStart = helper.changeDateFormat(new Date(), 0);
        var baseDateEnd = helper.changeDateFormat(new Date(), 1);

        
        

        mapSearchParam.isPaymentY = true;
        mapSearchParam.isPaymentN = true;


        console.log('init 확인 :: ', JSON.stringify(mapSearchParam));

        mapSearchParam.baseDateStart = baseDateStart;
        mapSearchParam.baseDateEnd = baseDateEnd;
        component.set('v.mapSearchParam', mapSearchParam);

        // var EX_listMapCenter = $A.get("$Label.c.EX_listMapCenter");
        var EX_listOrderChannel = $A.get("$Label.c.EX_listOrderChannel");
        var EX_listOrderStatusCode = $A.get("$Label.c.EX_listOrderStatusCode");

        // var listMapCenter = helper.setOptionListFromStrWithMark(EX_listMapCenter,'^');
        var listOrderChannel = helper.setOptionListFromStrWithMark(EX_listOrderChannel,'^');
        var listOrderStatusCode = helper.setOptionListFromStrWithMark(EX_listOrderStatusCode,'^');




        // component.set('v.listMapCenter',listMapCenter);
        component.set('v.listOrderChannel',listOrderChannel);
        component.set('v.listOrderStatusCode',listOrderStatusCode);

        // component.set('v.showSpinner', false);

        // userSessionInfo 세팅
        // 조회조건 세팅(기본값)
        // helper.doInitSearchParamSetting(component, event, helper);
    },

    fnSearch: function (component, event, helper) {
        try {
            var mapSearchParam = component.get('v.mapSearchParam');
            component.set('v.pageOffset', 0);
            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.mapSearchParam', mapSearchParam);
            helper.fnDoSearch(component, event, helper);
            var evt = $A.get('e.c:EX_ConsumablesOrderManagement_evt');
            evt.setParam('isSearchBtnClick', true);
            //23 09 08 hyungho.chun serviceResource 추가
            evt.setParam('serviceResource',component.get('v.serviceResource'));
            console.log('serviceResource :: ',component.get('v.serviceResource'));
            console.log('evt ::' ,evt);
            evt.fire();
        } catch(e) {
            console.log(e);
        }
    },

    fnPhoneChg: function (component, event, helper) {
        var phoneNumber = event.getSource().get('v.value');
        phoneNumber = helper.gfnChgTelFormat(component, event, phoneNumber);
        event.getSource().set('v.value', phoneNumber);
    },

    // seung yoon heo OBS 주석처리
    // fnChannel: function (component, event, helper) {
    //     var getChannel = event.getSource().get('v.value');
    //     console.log('consu getChannel ?? ' , getChannel);
    //     if (getChannel == 'B') {
    //         component.set('v.mapSearchParam.orderNo', 'ORD-');
    //     } else {
    //         component.set('v.mapSearchParam.orderNo', '');
    //     }
    // },
    

    fnEnter: function (component, event, helper) {
        if (event.keyCode == 13) {
            var mapSearchParam = component.get('v.mapSearchParam');
            component.set('v.pageOffset', 0);
            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.mapSearchParam', mapSearchParam);
            helper.fnDoSearch(component, event, helper);
            var evt = $A.get('e.c:EX_ConsumablesOrderManagement_evt');
            evt.setParam('isSearchBtnClick', true);
            //23 09 08 hyungho.chun serviceResource 추가
            evt.setParam('serviceResource',component.get('v.serviceResource'));
            console.log('serviceResource :: ',component.get('v.serviceResource'));
            console.log('evt ::' ,evt);
            evt.fire();
        }
    },

    /**
     * @description ProductRequest 선택 시 Case 로 생성된 주문 여부에 따라 caseId 및 orderNumber Set Case의 Description이 존재하는데 주문 번호만 달라진경우 주문내역 상담이력 재설정
     * @param component
     * @param event
     * author 23.01.18 / I2MAX.SEUNGHUNAN
     */
    fnSetPrInfo : function(component, event) {
        var caseId = event.getParam('caseId');
        var orderNumber = event.getParam('orderNumber');
        console.log('caseId 수신 : ' + caseId);
        console.log('orderNumber 수신 : ' + orderNumber);

        component.set("v.objCaseId", caseId);
        component.set("v.curOrderNumber", orderNumber);

        try {
            var caseObj = component.get("v.objCase");
            console.log('caseObj : ' + caseObj);
            console.log(JSON.stringify(caseObj));

            if (caseObj != null && caseObj.Description != undefined && caseObj.Description.includes(orderNumber)) {
                var startIdx = caseObj.Description.indexOf(orderNumber);
                var endIdx = caseObj.Description.indexOf('OrderLineItem End', startIdx);

                // component.set("v.productRequestDescription", caseObj.Description.substring(startIdx, endIdx));
            }
        } catch(error) {
            console.log('error : ' + error.getMessage());
        }
    },

    /**
     * @description caseId attribute 변경 시 objCase Set
     * @param component
     * author 23.01.19 / I2MAX.SEUNGHUNAN
     */
    fnSetObjCase : function(component, event, helper) {
        var caseId = component.get("v.objCaseId");
        console.log('fsoj caseId : ' + caseId);
        if (caseId == null) {
            component.set("v.objCase", null);
            component.set("v.productRequestDescription", null);
            return;
        }

        helper.getCaseByCaseId(component, caseId);
    },

    fnSetCssClass: function (component, event, helper) {
        let modalOpenCheck = event.getParam('CssClass');

        if(modalOpenCheck) component.set('v.overflowClass', true);
        else component.set('v.overflowClass', false);
    },

    /**
     * @description 주문내역 리스트가 더 조회가 가능하다면 조회
     * @param component, event, helper
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    fnPaginationResearch : function(component, event, helper) {
        var pageOffset = event.getParam('pageNumber');
        console.log('management event receive : ' + pageOffset);
        component.set('v.pageOffset', pageOffset);

        var mapSearchParam = component.get('v.mapSearchParam');
        mapSearchParam['isSearchBtnClick'] = false;
        component.set('v.mapSearchParam', mapSearchParam);

        helper.fnDoSearch(component, event, helper);
    }

});