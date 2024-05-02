/**
 * Created by A78916 on 2022-12-21.
 */

//카드승인: 정합체크(h.validate)-> h.onValidate호출(정상일시) -> 단말기에서 데이타 읽어오기 -> save -> 승인완료
({

    handleCardPay: function (component, event, helper) {
        //23 09 09 hyungho.chun 카드승인 버튼시 창 닫지말라는 토스트 메세지
        helper.toast('결제 완료까지 창을 닫지 마세요', 'w')
        helper.vaidateAnd(component, $A.getCallback(() => {
            component.set('v.isNfcClicked', false);
            helper.validate(component, 'card');
        }));
    },

    handleCancel: function (component, event, helper) {
        let kMessage = '카드 결제를 취소하시겠습니까?';
        helper.confirm('확인', kMessage).then(confirmed => {
            if (confirmed) {
                //cancel구현부는 FNPaymentCard.drive()에 있다.
                //cancel이 완료되면 onCancel()이 호출된다.
                helper.cancel(component, 'card', {});
            }
        });
    },

    handleNfc: function (component, event, helper) {
        helper.vaidateAnd(component, $A.getCallback(() => {
            component.set('v.isNfcClicked', true);
            helper.validate(component, 'nfc');
        }));
    },

    handleManualPay: function (component, event, helper) {
        helper.vaidateAnd(component, $A.getCallback(() => {
            if (component.get('v.isPending')) { // 수기 입력
                const validList = [
                    [helper.require(component, ['card-type']), '카드종류를 입력하세요.'],
                    [helper.require(component, ['approval-no']), '승인번호를 입력하세요.'],
                    [helper.require(component, ['approval-date']), '승인일시를 확인하세요.']
                ];
                const isValid = validList.reduce((acc, el, index) => {
                    if (!el[0]) {
                        helper.toast(el[1]);
                    }
                    return acc & el[0];
                }, true);
                if (isValid) {
                    helper.setStatus(component, 'progressing');
                    helper.save(component, 'store', {
                        TID: component.get('v.TIDNum'),
                        ISSUE_CARD_NAME: component.get('v.cardType'),
                        APPR_NUM: component.get('v.authNum'),
                        APPR_DTTM: component.get('v.authDate'), // GMT 0
                    });
                }
            }
        }));
    },

    handleCloseCardReader: function (component, event, helper) {
        component.set('v.isOpenInstallment', false);
    },

    handleStartTrade: function (component, event, helper) {
        if (component.get('v.isNfcClicked')) {
            component.set('v.isOpenInstallment', false);
            helper.startNfc(component, component.get('v.installment'));
        } else {
            helper.showCardReaderSpinner(component, true);
            helper.startTrade(component, component.get('v.installment'));
        }
    },

    onCloseNfc: function (component, event, helper) {
        component.set('v.isOpenNfc', false);
        const type = event.getParam('type');

        // 완료하면 type=complete, 취소는 close
        if ('complete' === type) {
            helper.fetch(component, 'nfc', {});
        }
    }


});