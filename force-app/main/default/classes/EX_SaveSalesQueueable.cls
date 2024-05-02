/**
 * Created by I2MAX.SEUNGHUNAN on 2023-03-19.
 */

public with sharing class EX_SaveSalesQueueable implements Queueable {
    public List<String> orderNumberList = new List<String>();

    public EX_SaveSalesQueueable(List<String> orderNumberList) {
        this.orderNumberList = orderNumberList;
    }
    public void execute(QueueableContext context) {
        try {
            EX_ConsumableUtil.doSaveSales(orderNumberList);
        } catch(Exception e) {
            System.debug('SaveSalesQueue Error :: ' + e.getMessage());
        }
    }
}