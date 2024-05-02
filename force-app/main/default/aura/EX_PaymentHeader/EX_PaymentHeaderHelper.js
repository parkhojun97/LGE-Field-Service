/**
 * Created by A78916 on 2022-12-20.
 */

({
    // ----------------------- //
    // override
    // ----------------------- //
    getSlotComponentName: function (method) {
        console.log('method : ' + method);
        if(method == 'Credit'){
            return 'c:EX_Payment' + 'URL';
        }
        if(method == 'Point'){
            return 'c:EX_Payment' + method;
        }
        if(method == 'Card'){
            return 'c:EX_Payment' + method;
        }
        return 'c:FN_Payment' + method;
    },
    setFocus: function (component) {
        component.find('amount').focus();
    },
    onChangedSlot: function (component) {
        // abstract
    },
    slotParams: function (component) {
       return {}
    },
    /**
     * Event Hook. 부모로부터 전달되는 이벤트를 후킹한다.
     * @param component
     * @param target target 과 slotNo 가 같으면 자신이 요청한 이벤트
     * @param type 이벤트 타입
     * @param payload 이벤트 데이터
     * @param slotNo 자신의 슬롯 번호
     * @returns {boolean} true 를 반환하면 이벤트 처리를 중단한다.
     */
    onObserved: function (component, target, type, payload, slotNo) {
        if(type == 'amount' && slotNo == 2){
            component.set('v.amount', payload.amount);
        }else{
            return false;
        }
    }
});