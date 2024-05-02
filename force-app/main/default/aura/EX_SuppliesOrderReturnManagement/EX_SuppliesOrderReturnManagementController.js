/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-03.
 */

({
    fnInit: function (component, event, helper) {
        console.log('fnInit');
        component.set('v.showSpinner', true);
        //23 11 02 hyungho.chun 하위컴포넌트에서 보내줌
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.setTabLabel({
        //         tabId: focusedTabId,
        //         label: "소모품반품관리"
        //     });
        //     workspaceAPI.setTabIcon({
        //         tabId: focusedTabId,
        //         icon: 'custom:custom18'
        //     });
        // })
        //23 09 07 hyungho.chun 백단생략
        // helper.doGetInitData(component, event, helper);
        var mapSearchParam = component.get('v.mapSearchParam');

        var baseDate = helper.changeDateFormat(new Date(), 0);
        var today = helper.changeDateFormat(new Date(), 1);

        mapSearchParam.baseDateStart = baseDate;
        mapSearchParam.baseDateEnd = today;


        //23 09 07 hyungho.chun 백단생략 -> 라벨링으로 수정
        var EX_listOrderChannel = $A.get("$Label.c.EX_listOrderChannel");
        var EX_returnOrderStatusCode = $A.get("$Label.c.EX_returnOrderStatusCode");

        var listOrderChannel = helper.setOptionListFromStrWithMark(EX_listOrderChannel,'^',false);
        var listOrderStatusCode = helper.setOptionListFromStrWithMark(EX_returnOrderStatusCode,'^',true);

        
        
        component.set('v.listOrderChannel',listOrderChannel);
        component.set('v.listOrderStatusCode',listOrderStatusCode);

        component.set('v.showSpinner', false);

        // 조회조건 세팅(기본값)
        // helper.doInitSearchParamSetting(component, event, helper);
    },

    fnSearch: function (component, event, helper) {
        try {
            var mapSearchParam = component.get('v.mapSearchParam');
            var evt = $A.get('e.c:EX_SuppliesOrderReturnManagement_evt');
            console.log('evt ' + evt);

            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.pageOffset', 0);
            component.set('v.mapSearchParam', mapSearchParam);

            evt.setParam('isSearchBtnClick', true);
            evt.fire();

            helper.fnDoSearch(component, event, helper);
        } catch(e) {
            console.log(e);
        }
    },

    fnPhoneChg: function (component, event, helper) {
        var phoneNumber = event.getSource().get('v.value');
        phoneNumber = helper.gfnChgTelFormat(component, event, phoneNumber);
        event.getSource().set('v.value', phoneNumber);
    },

    fnEnter: function (component, event, helper) {
        if (event.keyCode == 13) {
            var mapSearchParam = component.get('v.mapSearchParam');
            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.mapSearchParam', mapSearchParam);
            helper.fnDoSearch(component, event, helper);
        }
    },


});