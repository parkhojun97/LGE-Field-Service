({
    fnInit : function(component, event, helper) {
        localStorage.removeItem('isMove');
    },
    onTabFocused : function(component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var previousTabId = event.getParam('previousTabId');
        var workspaceAPI = component.find("workspace");

        if (focusedTabId != undefined && previousTabId != undefined) {
            if (localStorage.getItem('isMove') != 'true') {
                var searchTabList = ['소모품통합주문관리', '소모품주문관리', '소모품반품관리'];
                workspaceAPI.getAllTabInfo().then(function(response) {
                    for (let i = 0; i < response.length; i++) {
                        var loopTabId = response[i].tabId;
        
                        //현재 탭 또는 이전 탭에 서브탭이 없을 경우 ==> 소모품
                        if ((previousTabId == loopTabId && !response[i].isSubtab) || focusedTabId == loopTabId && !response[i].isSubtab) {
                            console.log('success');
                            //이전 탭 실행 여부
                            if (previousTabId == loopTabId && searchTabList.includes(response[i].customTitle)) {
                                var evt = $A.get('e.c:EX_Search_evt');
        
                                evt.setParam('previousTabId', previousTabId);
                                evt.setParam('previousTabName', response[i].customTitle);
                                evt.setParam('focusTabId', focusedTabId);
        
                                localStorage.setItem('isMove', 'true');
                                evt.fire();
                            }
                        } else {
                            break;
                        }
                    };
                });
            } else {
                localStorage.removeItem('isMove');
            }
        }
    },

    //24 01 04 hyungho.chun 탭생성시발동
    tabCreated: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var selectedNaviDev ='';
        
        var navigationItemAPI = component.find("navigationItemAPI");
        navigationItemAPI.getSelectedNavigationItem().then(function(response) {
            selectedNaviDev = response.developerName;
        })
        .catch(function(error) {
        console.log('ex tab error ::: ', error)
        });

        workspaceAPI.getAllTabInfo().then(function(allTab) {
            for(var tabIndex in allTab) {
                var data = allTab[tabIndex];

                if ( //택배주문,주문관리,통합주문관리,반품주문관리,프로모션 탭하나더열리면 강제닫기
                (selectedNaviDev == 'ConsumablesOrder' && data.url.includes('ConsumablesOrder?overrideNavRules=true'))
                ||(selectedNaviDev == 'ConsumablesOrderManagement' && data.url.includes('ConsumablesOrderManagement?overrideNavRules=true'))
                ||(selectedNaviDev == 'IntegrationOrderManagement' && data.url.includes('IntegrationOrderManagement?overrideNavRules=true'))
                ||(selectedNaviDev == 'SupplieOrderReturn' && data.url.includes('SupplieOrderReturn?overrideNavRules=true'))
                ||(selectedNaviDev == 'EX_Promotion__c' && data.url.includes('overrideNavRules=true') && data.url.includes('EX_Promotion__c'))
                    ) {
                        if(tabIndex == allTab.length -1){
                            workspaceAPI.closeTab({tabId: data.tabId});
                        }                         
                }
            }
        });
        
    }
})