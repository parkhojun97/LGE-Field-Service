/**
 * Created by A78916 on 2023-06-02.
 */

({
    sendEvent: function (component, type) {
        const evt = component.getEvent('onClose');
        evt.setParam('name', 'NFC');
        evt.setParam('type', type);
        evt.setParam('detail', {});
        evt.fire();
    },
    closeWithUnsubscribe: function (component, type) {
        component.set('v.uuid', null); // clear uuid
        this.unsubscribe(component);
        // close event
        this.sendEvent(component, type);
    },
    subscribe: function (component) {
        const empApi = component.find('empApi');
        const channel = '/event/FN_PaymentNFC__e';
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(evt => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(evt));
            //
            const userId = $A.get("$SObjectType.CurrentUser.Id");
            const uuid = component.get('v.uuid');
            const payload = evt.data.payload;
            if (userId === payload.TARGET_USER_ID__c && !!uuid && uuid === payload.UUID__c) {
                if ('complete' === payload.STATUS__c) {
                    // event matched
                    this.closeWithUnsubscribe(component, 'complete');
                }
            }
        })).then(subscription => {
                // Subscription response received.
                // We haven't received an event yet.
                console.log('Subscription request sent to: ', subscription.channel);
                // Save subscription to unsubscribe later
                component.set('v.subscription', subscription);
            });
    },
    unsubscribe: function(component) {
        const empApi = component.find('empApi');
        const subscription = component.get('v.subscription');

        if (subscription) {
            // Unsubscribe from event
            empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
                // Confirm that we have unsubscribed from the event channel
                console.log('Unsubscribed from channel ' + unsubscribed.subscription);
                component.set('v.subscription', null);
            }));
        }
    },
});