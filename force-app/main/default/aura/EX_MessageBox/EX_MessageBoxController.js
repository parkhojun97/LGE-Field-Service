/**
 * Created by I2MAX.SEUNGHUNAN on 2023-02-04.
 */

({
    /**
     * @description Confirm 메세지 호출
     *  > Aura:method 에 정의된 Parameter 사용
     */
    confirm : function(component,event,helper){
        // Initialize
        helper.fn_initialize(component,event,helper);

        // Parse Method Param
        var parameters = event.getParam('arguments');
        if( parameters != null && parameters.param != null ){
            var message     = parameters.param.message;
            var callback    = parameters.callback;
            var resendType  = parameters.resendType;

            console.log('check orderCreate' , parameters.param.isExOrderCreate);

            // Set Attribute
            component.set('v.message',message);
            component.set('v.callback',callback);
            component.set('v.resendType', resendType);
            component.set('v.isOpen',true);
            // 2023.09.26 seung yoon heo CreateOrder
            component.set('v.isExOrderCreate',parameters.param.isExOrderCreate);
        }
    },
    /**
     * @description Dialog 내부 클릭 이벤트
     *  > Parent Element 클릭 종료이벤트의 Chaining 방지
     */
    preventCloseEvent : function(component,event,helper){
        event.stopPropagation();
    },
    /**
     * @description Dialog Confirm
     *  > Callback result 반환
     */
    doConfirm : function(component,event,helper){
        var callback = component.get('v.callback');
        var resendType = component.get('v.resendType');

        if (callback != null) {
            var param = {
                result : true,
                resendType : resendType
            };
            callback(param);
        }
        component.set('v.isOpen',false);
    },
    /**
     * @description Dialog Confirm
     *  > Callback result 반환
     */
    doCancel : function(component,event,helper){
        var callback = component.get('v.callback');
        if(callback != null ){
            var param = {
                result : false
            };
            callback(param);
        }
        component.set('v.isOpen',false);
    }
})