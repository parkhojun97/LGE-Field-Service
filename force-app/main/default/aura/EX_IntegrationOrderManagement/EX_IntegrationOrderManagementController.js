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
        //         label: "소모품통합주문관리"
        //     });
        //     workspaceAPI.setTabIcon({
        //         tabId: focusedTabId,
        //         icon: 'custom:custom18'
        //     });
        // })

        // // 사용자 로그인 정보 세팅
        // helper.getUserInfo(component, event, helper);
        //
        // // Datatable 세팅
        // helper.doInitDatatableSetting(component, event, helper);
        //
        // // 조회조건 세팅(DB참조)

        //23 09 07 hyungho.chun 첫 로딩 검색조건 리스트들 백단에서 불러오는 곳
        // helper.doGetInitData(component, event, helper);

        // 조회조건 세팅(기본값)
        // helper.doInitSearchParamSetting(component, event, helper);
        var mapSearchParam = component.get('v.mapSearchParam');

        var baseDate = helper.changeDateFormat(new Date(), 0);
        var today = helper.changeDateFormat(new Date(), 1);

        mapSearchParam.baseDateStart = baseDate;
        mapSearchParam.baseDateEnd = today;
        mapSearchParam.isSalesCompleteY = true;
        mapSearchParam.isSalesCompleteN = true;
        // 23.10.23 PHJ
        mapSearchParam.isSalesQtyNotZero = false;

        component.set('v.mapSearchParam', mapSearchParam);


        var EX_listAppointmentStatus = $A.get("$Label.c.EX_listAppointmentStatus");
        var EX_listDepartment = $A.get("$Label.c.EX_listDepartment");
        var EX_listOrderChannel = $A.get("$Label.c.EX_listOrderChannel");
        var EX_listOrderStatusCode = $A.get("$Label.c.EX_listOrderStatusCode");

        // var listDepartment = helper.setOptionListFromStr(EX_listDepartment,3);

        var listAppointmentStatus = helper.setOptionListFromStrWithMark(EX_listAppointmentStatus,'^');
        var listDepartment = helper.setOptionListFromStrWithMark(EX_listDepartment,'^');
        var listOrderChannel = helper.setOptionListFromStrWithMark(EX_listOrderChannel,'^');
        var listOrderStatusCode = helper.setOptionListFromStrWithMark(EX_listOrderStatusCode,'^');

        // var listAppointmentStatus = [
        //     {label: '요청', value: '요청'},
        //     {label: '입고완료', value: '입고완료'}
        // ];

        // var listDepartment = [
        //     {label: 'GXC_전기차충전기', value: 'GXC'},
        //     {label: 'BSZ_고객서비스', value: 'BSZ'},
        //     {label: 'DAC_엘지이노텍', value: 'DAC'},
        //     {label: 'BRS_스타리온', value: 'BRS'},
        //     {label: 'MTZ_CEM', value: 'MTZ'},
        //     {label: 'PGZ_CAR', value: 'PGZ'},
        //     {label: 'RBZ_로봇비지니스센터', value: 'RBZ'},
        //     {label: 'DGZ_RAC에어컨', value: 'DGZ'},
        //     {label: 'SRJ_홈넷', value: 'SRJ'},
        //     {label: 'AOZ_생활용품', value: 'AOZ'},
        //     {label: 'BSA_홈IoT 솔루션', value: 'BSA'},
        //     {label: 'DVZ_청소기', value: 'DVZ'},
        //     {label: 'SQZ_스마트솔루션', value: 'SQZ'},
        //     {label: 'PHZ_포켓포토', value: 'PHZ'},
        //     {label: 'CWZ_헬스케어', value: 'CWZ'},
        //     {label: 'ANZ_안마의자', value: 'ANZ'},
        //     {label: 'DLZ_에어케어', value: 'DLZ'},
        //     {label: 'CLZ_Lighting', value: 'CLZ'},
        //     {label: 'WWZ_이동단말', value: 'WWZ'},
        //     {label: 'SRD_Solar', value: 'SRD'},
        //     {label: 'MKT_수익상품', value: 'MKT'},
        //     {label: 'GLZ_LCD TV', value: 'GLZ'},
        //     {label: 'PBZ_뷰티케어', value: 'PBZ'},
        //     {label: 'GPZ_PDP TV', value: 'GPZ'},
        //     {label: 'ADZ_지엔텔', value: 'ADZ'},
        //     {label: 'CVZ_C&C', value: 'CVZ'},
        //     {label: 'GRZ_CRT TV', value: 'GRZ'},
        //     {label: 'IPZ_액세서리', value: 'IPZ'},
        //     {label: 'PSZ_Storage', value: 'PSZ'} ,
        //     {label: 'BBS_테크데이터', value: 'BBS'},
        //     {label: 'CNZ_냉장고', value: 'CNZ'},
        //     {label: 'PKZ_Security', value: 'PKZ'},
        //     {label: 'AZZ_프린터', value: 'AZZ'},
        //     {label: 'CDZ_식기세척기', value: 'CDZ'},
        //     {label: 'DMZ_CAC에어컨', value: 'DMZ'},
        //     {label: 'PAZ_캠코더', value: 'PAZ'},
        //     {label: 'PCZ_PC', value: 'PCZ'},
        //     {label: 'DFZ_세탁기', value: 'DFZ'},
        //     {label: 'GMZ_Monitor', value: 'GMZ'},
        //     {label: 'PNZ_DAV', value: 'PNZ'}
        // ];
        
        // var listOrderChannel = [
        //     {label: 'LGE.COM', value: 'B'},
        //     {label: 'ThinQ', value: 'S'},
        //     {label: '소모품택배', value: 'V'},
        //     {label: '베스트샵', value: 'BestShop'},
        //     {label: '소모품샵', value: 'Y'}
        // ];

        // var listOrderStatusCode = [
        //     {label: '품절예약완료', value: '000'},
        //     {label: '결제요청', value: '001'},
        //     {label: '결제완료', value: '002'},
        //     {label: '결제취소', value: '003'},
        //     {label: '주문취소', value: '004'},
        //     {label: '자동주문취소완료', value: '005'},
        //     {label: '상품준비중', value: '006'},
        //     {label: '배송준비중', value: '010'},
        //     {label: '배송중', value: '030'},
        //     {label: '배송완료', value: '070'}            
        // ];

        component.set('v.listAppointmentStatus',listAppointmentStatus);
        component.set('v.listDepartment',listDepartment);
        component.set('v.listOrderChannel',listOrderChannel);
        component.set('v.listOrderStatusCode',listOrderStatusCode);

        component.set('v.showSpinner', false);

    },

    fnSearch: function (component, event, helper) {
        //component.set('v.showSpinner', true);
        var mapSearchParam = component.get('v.mapSearchParam');
        try{
            component.set('v.pageOffset', 0);
            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.mapSearchParam', mapSearchParam);
            helper.fnDoSearch(component, event, helper);
            var evt = $A.get("e.c:EX_IntegrationOrderManagement_evt");
            evt.setParam('isSearchBtnClick', true);
            evt.fire();
        }catch(e){
            console.error("Exception occurred while fnSearch:", e);
        }
    },

    fnPhoneChg: function (component, event, helper) {
        var phoneNumber = event.getSource().get('v.value');
        phoneNumber = helper.gfnChgTelFormat(component, event, phoneNumber);
        event.getSource().set('v.value', phoneNumber);
    },

    // seung yoon heo OBS 자동입력 주석처리
    // fnChannel: function (component, event, helper) {
    //     var getChannel = event.getSource().get('v.value');
    //     console.log('getChannel ?? ' , getChannel);
    //     if (getChannel == 'B') {
    //         component.set('v.mapSearchParam.orderNo' , 'ORD-');    
    //     } else { 
    //         component.set('v.mapSearchParam.orderNo' , '');    
    //     }

    // },


    

    fnEnter: function (component, event, helper) {
        if (event.keyCode == 13) {
//            component.set('v.showSpinner', true);
            var mapSearchParam = component.get('v.mapSearchParam');
            mapSearchParam['isSearchBtnClick'] = true;
            component.set('v.mapSearchParam', mapSearchParam);
            helper.fnDoSearch(component, event, helper);
        }
    },

    checkboxGroupTest : function(component) {
        console.log('cbgt');
        console.log(component.get('v.mapSearchParam')['salesCompleteYNList']);
    },

    /**
     * @description 주문내역 리스트가 더 조회가 가능하다면 조회 /
     * 07/15 infinite loading이 사라졌지만 이벤트 파라미터 네이밍은 그대로 둠.
     * 주문상태변경 후 재조회로 변경
     * 추후 infinite loading을 사용한 다른 화면에서도 주문번호로 로 재조회 refresh 사용하게되면 변경예정
     * eventParameter
     * @param component, event, helper
     * author 23.05.10 / I2MAX.SEUNGHUNAN
     */
    reSearchOrderNumber : function(component, event, helper) {
        var orderNumber = event.getParam('pageNumber');
        // console.log('management event receive : ' + pageOffset);
        // component.set('v.pageOffset', pageOffset);

        var mapSearchParam = component.get('v.mapSearchParam');
        mapSearchParam['isSearchBtnClick'] = true;
        mapSearchParam['orderNo'] = orderNumber;
        component.set('v.mapSearchParam', mapSearchParam);

        helper.fnDoSearch(component, event, helper);
    }
});