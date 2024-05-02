/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-03.
 */

({
    doGetInitData: function (component, event, helper) {
        console.log('doGetInitData');

        var action = component.get('c.doGetInitData');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var mapSettingValueOrigin = result['mapSettingValueOrigin'];

                //PHJ231208
                var currentUserDeptName = result['currentUserDeptName'];
                var deptList = mapSettingValueOrigin.Comm.listMapCenter;
                component.set('v.deptList', deptList);
                deptList.forEach(item => {
                    if(item.label == currentUserDeptName){
                        component.set('v.defaultDeptNN', true);
                        component.set('v.defaultDept', item.label);
                        component.set('v.mapSearchParam.CNSLDiv', item.value);
                        let obj = {label: 'ALL', value: 'ALL'};
                        deptList.push(obj);

                        let index1 = deptList.indexOf(item);
                        deptList.splice(index1, 1);
                        let index2 = deptList.indexOf(obj);
                        if (index2 !== -1) {
                            deptList.splice(0, 0, deptList.splice(index2, 1)[0]);
                        }
                    }
                });
                //END
                
                // 원본 따로 저장.
                component.set('v.mapSettingValueOrigin', mapSettingValueOrigin);
                // console.log(JSON.stringify(mapSettingValueOrigin));
                // 원본 깊은 복사 후 화면에 뿌릴용도로 따로 저장.
                var mapSettingValue = mapSettingValueOrigin;
                component.set('v.mapSettingValue', mapSettingValue);
                component.set('v.showSpinner', false);

                console.log('mapSettingValue :: ',mapSettingValue);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    fnDoSearch: function (component, event, helper) {
        component.set('v.showSpinner', true);

        var recordLimit = component.get('v.recordLimit');
        var pageOffset = component.get('v.pageOffset');
        var mapSearchParam = component.get('v.mapSearchParam');
        mapSearchParam['recordLimit'] = recordLimit;
        mapSearchParam['pageOffset'] = pageOffset;

        //PHJ231211
        var deptList = component.get('v.deptList');
        deptList.forEach(item => {
            if(component.get('v.mapSearchParam.CNSLDiv') == item.label){
                mapSearchParam['CNSLDiv'] = item.value;
            }
        })

        var isSearchBtnClick = mapSearchParam['isSearchBtnClick'];

        if (isSearchBtnClick) {
            component.set('v.listPR', []);
            component.set('v.listPRLI', []);
        }

        var isValid;
        isValid = helper.fnValidDate(component, event, helper);
        console.log('va :'+isValid);
        if (isValid == false) {
            component.set('v.showSpinner', false);
            return;
        }
        console.log('mapSearchParam : '+mapSearchParam);

        var action = component.get('c.doGetSearchData');
        action.setParams({
            'mapSearchParam': mapSearchParam
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result.STATUS == 'S') {
                var productRequests = result.productRequests;

                //23.09.07 PHJ
                var totalRecord = productRequests.length;
                component.set('v.totalRecord', totalRecord);
                // var totalRecord = 0;
                // if (result['totalRecord'] != null && result['totalRecord'] != undefined) {
                //     totalRecord = result['totalRecord'];
                //     component.set('v.totalRecord', totalRecord);
                // }

                // 23.01.20 / I2MAX.SanghunYeo
                /*var ProductRequestLineItems = result['productRequestLineItems'];
                if(ProductRequestLineItems.length != 0) {
                    component.set('v.listDummyPRLI', ProductRequestLineItems);
                } else {
                    component.set('v.listDummyPRLI', []);
                }*/

                console.log(productRequests.length);
                if(productRequests.length != 0) {
                    if (isSearchBtnClick) {
                        //component.set('v.listPR', productRequests);
                        const child = component.find("orderList");
                        child.find("wijmo_EXConsumableOrderList").message({type:'items', items: productRequests});
                    }
                    else {
                        var curListPR = component.get('v.listPR');
                        //component.set('v.listPR', curListPR.concat(productRequests));
                        const child = component.find("orderList");
                        child.find("wijmo_EXConsumableOrderList").message({type:'items', items: curListPR.concat(productRequests)});
                    }
                } else {
                    //component.set('v.listPR', []);
                    component.set('v.totalRecord', 0);

                    const child = component.find("orderList");
                    child.find("wijmo_EXConsumableOrderList").message({type:'items', items: []});
                }

                component.set('v.showSpinner', false);

                if (isSearchBtnClick) {
                    // 하위 Detail Section 초기화
                    component.set('v.initializeFlag', !component.get('v.initializeFlag'));
                }
            } else if (result.STATUS == 'E') {
                this.showToast('warning', 'System Admin에게 문의 부탁드립니다.');
                console.log('Error : '+ result.message);
                component.set('v.showSpinner', false);
                component.set('v.totalRecord', 0);
            }
            // var state = response.getState();
            // if (state === "SUCCESS") {
            //     //var result = response.getReturnValue();
            //     console.log('result : '+result);

                

            // } else {
                
            // }
        });


        $A.enqueueAction(action);
    },

    
    gfnChgTelFormat: function (component, event, strTel) {

        var strLen = '';
        var strSetValue = '';

        if (!strTel) return strTel;

        strTel = strTel.replace(/[^0-9]/g, '');
        strLen = String(strTel.length);

        switch (strLen) {
            case '8' :
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4); //"###-####";
                break;

            case '9' :
                strSetValue = strTel.substr(0, 2);
                strSetValue += '-' + strTel.substr(2, 3);
                strSetValue += '-' + strTel.substr(5); //"##-###-####";
                break;

            case '10' :

                if (strTel.substr(0, 2) == "02") {
                    strSetValue = strTel.substr(0, 2);
                    strSetValue += '-' + strTel.substr(2, 4);
                    strSetValue += '-' + strTel.substr(6); //"##-####-####";
                } else {
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 3);
                    strSetValue += '-' + strTel.substr(6); //"###-###-####";
                }
                break;

            //23.11.21 PHJ modify '010'이 들어가지 않으면 "####-###-####" 형식으로 변환
            case '11' :
                if(strTel.includes('010')){
                    strSetValue = strTel.substr(0, 3);
                    strSetValue += '-' + strTel.substr(3, 4);
                    strSetValue += '-' + strTel.substr(7); //"###-####-####";
                } else {
                    strSetValue = strTel.substr(0, 4);
                    strSetValue += '-' + strTel.substr(4, 3);
                    strSetValue += '-' + strTel.substr(7); //"####-###-####";
                }
                break;
            //23.11.21 PHJ modify 12자리이면 "####-####-####" 형식으로 변환
            case '12':
                // strSetValue = strTel.substr(0, 3);
                // strSetValue += '-' + strTel.substr(3, 4);
                // strSetValue += '-' + strTel.substr(7, 4);
                strSetValue = strTel.substr(0, 4);
                strSetValue += '-' + strTel.substr(4, 4);
                strSetValue += '-' + strTel.substr(8, 4);
                break;


            default:
                strSetValue = strTel;
        }

        return strSetValue;
    },

    /**
     * @author I2MAX.SEOKHOLEE
     * @param component
     * @param event
     * @param helper
     * @returns {boolean}
     */
    fnValidDate  : function (component, event, helper) {
        var mapSearchParam = component.get('v.mapSearchParam');

        if($A.util.isEmpty(mapSearchParam.baseDateStart) || $A.util.isEmpty(mapSearchParam.baseDateEnd)) {
            this.showToast('warning', '시작 날짜와 종료 날짜는 필수 입력 조건 입니다.');
            return false;
        }

        var startDate = new Date(mapSearchParam.baseDateStart);
        var endDate = new Date(mapSearchParam.baseDateEnd);

        var searchName = new Map();
        var searchOrderNum = new Map();

        searchName.set('CNSLUser',  mapSearchParam.CNSLUser == undefined ? '' :  mapSearchParam.CNSLUser);
        searchName.set('contactName', mapSearchParam.contactName == undefined ? '' : mapSearchParam.contactName);
        searchName.set('contactPhone', mapSearchParam.contactPhone == undefined ? '' : mapSearchParam.contactPhone);
        searchName.set('consigneePhone', mapSearchParam.consigneePhone == undefined ? '' : mapSearchParam.consigneePhone);
        searchName.set('consigneeName', mapSearchParam.consigneeName == undefined ? '' : mapSearchParam.consigneeName);
        //PHJ231211 
        searchName.set('CNSLDiv', mapSearchParam.CNSLDiv == 'ALL' ? '' : mapSearchParam.CNSLDiv);


        searchOrderNum.set('orderNo', mapSearchParam.orderNo == undefined ? '' : mapSearchParam.orderNo);
        searchOrderNum.set('CJorderNo', mapSearchParam.CJorderNo == undefined ? '' : mapSearchParam.CJorderNo);
        //23.11.22 PHJ 판매번호 필터추가
        searchOrderNum.set('salesNo', mapSearchParam.salesNo == undefined ? '' : mapSearchParam.salesNo);

        console.log('mapSearchParam  :::  ' , JSON.stringify(mapSearchParam));
        console.log('mapSearchParam.orderNo  :::  ' , mapSearchParam.orderNo);
        console.log('searchOrderNum  :::  ' , searchOrderNum);


        var time = endDate - startDate;
        const diffDate = time / (24 * 60 * 60 * 1000);
        console.log(diffDate);
        
        if(diffDate < 0) {
            this.showToast('warning', '시작 날짜는 종료 날짜보다 이후 일 수 없습니다.');
            return false;
        }

        if (searchOrderNum.get('orderNo') == '' && searchOrderNum.get('CJorderNo') == '' && searchOrderNum.get('salesNo') == '') {

            if (searchName.get('CNSLUser') != '' || searchName.get('contactName') != '' || searchName.get('consigneeName') != '' 
             || searchName.get('CNSLDiv') != '' || searchName.get('contactPhone') != '' || searchName.get('consigneePhone') != '' ) {
                    if(diffDate > 30)  {
                        this.showToast('warning', '고객명/수취인명/전화번호/상담사/상담부서 조회 기간은 최대 31일 가능합니다.');
                        return false;
                    }
                
            }else{
                // // 2023.08.16 seung yoon heo 최대 조회기간 90일 -> 7일로 변경 // 채널 선택시 2주로 기간 변경 //// fs엔 양쪽다 30일 적용
                if (mapSearchParam['orderChannel'] == 'ALL') {
                    if(diffDate > 2)  {
                        this.showToast('warning', '전체 조회 기간은 최대 3일 가능합니다.');
                        return false;
                    }
                } else{
                    if(diffDate > 6)  {
                        this.showToast('warning', '채널 선택 조회 기간은 최대 7일 가능합니다.');
                        return false;
                    }
                }
                
            }
            
        }

        


        
        return true;
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    /**
     * @description caseId를 매개변수로 Case 쿼리, 주문내역 상담이력 Set
     * @param component
     * @param caseId
     * author 23.01.19 / I2MAX.SEUNGHUNAN
     */
    getCaseByCaseId : function(component, caseId) {
        console.log('helper caseId : ' + caseId);
        var action = component.get("c.doGetCaseByCaseId");
        action.setParam('caseId', caseId);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('조회 Case : ' + response.getReturnValue());
                console.log(JSON.stringify(response.getReturnValue()));

                component.set("v.objCase", response.getReturnValue());

                var curCaseDescription = response.getReturnValue().Description;
                var curOrderNumber = component.get("v.curOrderNumber");

                try {
                    console.log('hh');
                    if (curCaseDescription === undefined) {
                        console.log('c0');
                        // Case에 상담 이력이 없는 경우
                        // component.set("v.productRequestDescription", '현재 Case에 상담이력이 없는 경우.수정 전 데이터임');
                        component.set("v.productRequestDescription", '');
                        // component.set('v.objCaseId', null);
                        // component.set('v.initializeFlag', !component.get('v.initializeFlag'));
                        return;
                    }
                    console.log('c1');
                    if (curCaseDescription.includes(curOrderNumber)) {
                        console.log('check2');
                        var startIdx = curCaseDescription.indexOf(curOrderNumber);
                        var endIdx = curCaseDescription.indexOf('OrderLineItem End', startIdx);

                        // component.set("v.productRequestDescription", curCaseDescription.substring(startIdx, endIdx));
                    }
                    else {
                        console.log('check3');
                        // component.set("v.productRequestDescription", response.getReturnValue().Description);
                    }
                } catch(error) {
                    console.log('error : ' + error.getMessage());
                }
            }
            else {
                console.log('Case 조회 Fail');
                component.set("v.objCase", null);
                component.set("v.productRequestDescription", '');
            }
        });
        $A.enqueueAction(action);
    },
    changeDateFormat: function (date, flag) {
        date = flag == 1 ? date : new Date(date.setDate(date.getDate()-2));
        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },


    //23 09 07 hyungho.chun 라벨로 받아온 스트링을 잘라서 리스트 형태로 만들기 (string -> [{label : 라벨값 , value : 벨류값 }, ...])
    setOptionListFromStrWithMark: function (labelStr, mark) {
        
        var result = labelStr.split(/\r?\n/);
        
        console.log(result);

        var returnValue = [];

        for(var i =0;i<result.length;i++){
            var element = {label : result[i].split(mark)[0] , value : result[i].split(mark)[result[i].split(mark).length-1]};
            returnValue.push(element);
        }
        console.log('returnValue222 :: ',returnValue);
        
        return returnValue;
    },
    
    //23 09 08 hyungho.chun serviceResource 한번에 조회 버튼 때 아래컴포넌트(EX_ConsumableOrderDetailList, EX_ConsumableOrderDetail) 로 쏴주기
    fngetServiceResource: function (component, event, helper) {
        
        var action = component.get('c.doGetServiceResource');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result >>> ' + result);
                if (result != null)
                    component.set('v.serviceResource', result);


            } else {
                console.log(response.getError());
                component.set('v.showSpinner', false);

            }

            

        });
        $A.enqueueAction(action);
    },

});