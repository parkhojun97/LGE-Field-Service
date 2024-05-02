/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-03.
 */

({
    doGetInitData: function (component, event, helper) {
        console.log('doGetInitData');
        var action = component.get('c.doGetInitData');
        var mapSearchParam = component.get('v.mapSearchParam');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                var mapSettingValueOrigin = result['mapSettingValueOrigin'];
                // 원본 따로 저장.
                component.set('v.mapSettingValueOrigin', mapSettingValueOrigin);
                // console.log(JSON.stringify(mapSettingValueOrigin));
                // 원본 깊은 복사 후 화면에 뿌릴용도로 따로 저장.
                var mapSettingValue = mapSettingValueOrigin;
               
                component.set('v.showSpinner', false);
                console.log('mapSettingValue' , mapSettingValue);
                // console.log('JSONmapSettingValue' , JSON.stringify(mapSettingValue));
                
                //2023.07.31 seung yoon heo
                mapSettingValue.Comm.listOrderStatusCode.splice(1,0,{label : 'ALL' , value : 'ALL' , selected: true });
                mapSettingValue.Comm.listOrderStatusCode.splice(4,0,mapSettingValue.Comm.listOrderStatusCode[6]);
                mapSettingValue.Comm.listOrderStatusCode.splice(7,1);
                component.set('v.mapSettingValue', mapSettingValue);
                mapSearchParam.orderStatus = 'ALL';
                console.log('mapSettingValue 22' , mapSettingValue);
                component.set('v.mapSearchParam', mapSearchParam);

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
        var recordLimit = component.get('v.recordLimit');
        var pageOffset = component.get('v.pageOffset');
        var mapSearchParam = component.get('v.mapSearchParam');

        mapSearchParam['recordLimit'] = recordLimit;
        mapSearchParam['pageOffset'] = pageOffset;

        var isSearchBtnClick = mapSearchParam['isSearchBtnClick'];
        var collectionYN = component.get('v.collection_YN');

        if (isSearchBtnClick) {
            component.set('v.listPR', []);
            // component.set('v.listPRLI', []);
        }

        
        // 2023.08.16 seung yoon heo 최대 조회기간 90일 -> 7일로 변경
        var isValid;
        isValid = helper.fnValidDate(component, event, helper);
        console.log('va :'+isValid);
        if (isValid == false) {
            component.set('v.showSpinner', false);
            return;
        }

        component.set('v.showSpinner', true);
        var action = component.get('c.doGetSearchData');

        action.setParams({
            'mapSearchParam': mapSearchParam,
            'collectionYN' : collectionYN

        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var returnOrderLineItems = result['returnOrderLineItems'];

                //23.09.07 PHJ
                var totalRecord = returnOrderLineItems.length;
                component.set('v.totalRecord', totalRecord);
                // var totalRecord = 0;
                // component.set('v.totalRecord', totalRecord);
                // if (result['totalRecord'] != null && result['totalRecord']) {
                //     totalRecord = result['totalRecord'];
                //     component.set('v.totalRecord', totalRecord);
                // }


                //소모품 오류에 '반품오류'가 있는 경우 OR 반품내역들의 원주문의 판매정보가 없는 경우 빨간색 음영 처리
//                for (var i = 0; i < returnOrderLineItems.length; i++) {
//                    var row = returnOrderLineItems[i];
//                    console.log( 'row.ProductRequest_SR_SaleId :  '+ row.ProductRequest_SR_SaleId);
//
//                    console.log( 'row.SALE_Number :  '+ row.SALE_Number);
//
//                    if ((row.Consumables_Error != null && (row.Consumables_Error).includes('반품오류')) || row.SALE_Number == null) {
//                        console.log( 'row.Consumables_Error ::  ' + row.Consumables_Error);
//                        returnOrderLineItems[i].ErrorColor='errorColor';
//                    }
//                }

                //소모품 반품내역 음영처리 조건
                //1. 반품건 상태 != '반품요청철회' && 판매번호 = NULL -- '반품요청철회'는 반품관리 창에서 추가 작업할 수 있는 상태값이 아니기에 오류표시 불필요
                //2. 원주문건 상태 != '배송준비중' && 판매번호 = NULL -- 판매번호는 배송중일때 생성
                for(var i = 0; i < returnOrderLineItems.length; i++) {
                    var row = returnOrderLineItems[i];

                    //23.10.18
                    //교환 컬럼 추가
                    row.Consumables_Business_Type_Code = row.Consumables_Business_Type_Code == 'Return' ? 'N' : 'Y';

                    if ((row.Consumables_Error != null && (row.Consumables_Error).includes('반품오류')) ||
                        ((row.SALE_Number == null ) && row.PRLI_Consumables_Order_Status!='배송준비중' && row.Consumables_Order_Status !='반품요청철회')) {
                        returnOrderLineItems[i].ErrorColor='errorColor';
                    } else {
                    }

                }

                // 2024.01.23 seung yoon heo 반품요청 중복발생 제거
                var sameValues = new Set();
                var newReturnOrderLineItems = returnOrderLineItems.filter(val => {
                    var subNum = val.Sub_Order_Number.split('-');
                    var key = val.Order_Number + '^' + subNum[0] + '^' + val.parts_Number;
                    if (!sameValues.has(key)) {
                        sameValues.add(key);
                        return true;
                    } else {
                        if (val.Consumables_Order_Status == '반품확정' || val.Consumables_Order_Status == '반품완료') {
                            return true;
                        } else {
                             return false;
                        }
                       
                    }
                });

                if (isSearchBtnClick) {
                    console.log('check1 :: ' , newReturnOrderLineItems);
                    component.set('v.listPR', newReturnOrderLineItems);
                    component.set('v.totalRecord', component.get('v.listPR').length); // PHJ
                }
                else {
                    var curListPR = component.get('v.listPR');
                    component.set('v.listPR', curListPR.concat(newReturnOrderLineItems));
                     console.log('check2 :: ' , newReturnOrderLineItems);
                     component.set('v.totalRecord', component.get('v.listPR').length); // PHJ

                }
                component.set('v.channel',mapSearchParam.orderChannel);
                component.set('v.status',mapSearchParam.orderStatus);
                component.set('v.showSpinner', false);
                console.log('mapSearchParam.orderStatus : ' , mapSearchParam.orderStatus);
            } else {
                var errors = response.getError();
                console.log('Error : ' + errors[0].message);
                component.set('v.showSpinner', false);
                component.set('v.totalRecord', 0);
            }
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

            case '11' :

                strSetValue = strTel.substr(0, 3);
                strSetValue += '-' + strTel.substr(3, 4);
                strSetValue += '-' + strTel.substr(7); //"###-####-####";
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
        var startDate = new Date(mapSearchParam.baseDateStart);
        var endDate = new Date(mapSearchParam.baseDateEnd);

        var time = endDate - startDate;
        const diffDate = time / (24 * 60 * 60 * 1000);


        var searchOrderNum = new Map();
        searchOrderNum.set('orderNo', mapSearchParam.orderNo == undefined ? '' : mapSearchParam.orderNo);
        searchOrderNum.set('CJorderNo', mapSearchParam.CJorderNo == undefined ? '' : mapSearchParam.CJorderNo);


        if(diffDate < 0) {
            this.showToast('warning', '시작 날짜는 종료 날짜보다 이후 일 수 없습니다.');
            return false;
        }

        if (searchOrderNum.get('orderNo') == '' && searchOrderNum.get('CJorderNo') == '') {

            if(diffDate > 30)  {
                this.showToast('warning', '반품관리 조회 기간은 최대 31일 가능합니다.');
                return false;
            }

        }



        //  // 2023.08.16 seung yoon heo 최대 조회기간 90일 -> 7일로 변경 // 채널 선택시 2주로 기간 변경 // fs엔 양쪽다 30일 적용
        //  if (mapSearchParam['orderChannel'] == 'ALL') {
        //     if(diffDate > 7)  {
        //         this.showToast('warning', '전체 조회 기간은 최대 1주일 가능합니다.');
        //         return false;
        //     }
        // } else{
        //     if(diffDate > 14)  {
        //         this.showToast('warning', '채널 선택 조회 기간은 최대 2주일 가능합니다.');
        //         return false;
        //     }
        // }

      

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
        var action = component.get("c.doGetCaseByCaseId");
        action.setParam('caseId', caseId);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set("v.objCase", response.getReturnValue());

                var curCaseDescription = response.getReturnValue().Description;
                var curOrderNumber = component.get("v.curOrderNumber");

                try {
                    if (curCaseDescription === undefined) {
                        // Case에 상담 이력이 없는 경우
                        // component.set("v.productRequestDescription", '현재 Case에 상담이력이 없는 경우.수정 전 데이터임');
                        component.set("v.productRequestDescription", null);
                        return;
                    }
                    if (curCaseDescription.includes(curOrderNumber)) {
                        var startIdx = curCaseDescription.indexOf(curOrderNumber);
                        var endIdx = curCaseDescription.indexOf('OrderLineItem End', startIdx);

                        // component.set("v.productRequestDescription", curCaseDescription.substring(startIdx, endIdx));
                    }
                    else {
                        // component.set("v.productRequestDescription", response.getReturnValue().Description);
                    }
                } catch(error) {
                    console.log('error : ' + error.getMessage());
                }
            }
            else {
                component.set("v.objCase", null);
                component.set("v.productRequestDescription", null);
            }
        });
        $A.enqueueAction(action);
    },
    changeDateFormat: function (date, flag) {
        date = flag == 1 ? date : new Date(date.setDate(date.getDate()-6));
        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },

    //23 09 07 hyungho.chun 라벨로 받아온 스트링을 잘라서 리스트 형태로 만들기 (string -> [{label : 라벨값 , value : 벨류값 }, ...])
    setOptionListFromStrWithMark: function (labelStr, mark, statusYN) {
        
        var result = labelStr.split(/\r?\n/);
        
        console.log(result);

        var returnValue = [];

        for(var i =0;i<result.length;i++){
            var element;
            if(statusYN==true && result[i].split(mark)[0]=='ALL'){
                element = {label : result[i].split(mark)[0] , value : result[i].split(mark)[result[i].split(mark).length-1], selected : true};
            }else{
                element = {label : result[i].split(mark)[0] , value : result[i].split(mark)[result[i].split(mark).length-1]};
            }
            returnValue.push(element);
        }
        console.log('returnValue222 :: ',returnValue);
        
        return returnValue;
    },  


});