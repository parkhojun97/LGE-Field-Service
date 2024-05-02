/**
 * Created by A80598 on 2023-01-20.
 */

({
    fnDownloadCSV: function (component, event) {
        var data = event.getParam('data');
        var column_label = event.getParam('columns');
        var title = event.getParam('title');

        let rowEnd = '\n';
        let csvString = '\ufeff';
        let rowData = new Set();
        let rowDataCol = new Set();

        /*console.log('data:'+data);
        console.log('column_label:'+column_label);
        console.log('title:'+title);*/

        data.forEach(function (record) {
            column_label.forEach(function (col) {
                let isExist = false;
                Object.keys(record).forEach(function (key) {
                    if(key == col.fieldName){
                        rowData.add(key);
                        rowDataCol.add(col.label);
                        isExist = true;
                    }
                });
                if(isExist == false){
                    rowData.add(col.fieldName);
                    rowDataCol.add(col.label);
                }
            });
        });

        rowData = Array.from(rowData);
        rowDataCol = Array.from(rowDataCol);

        // splitting using ','
        //csvString += rowData.join(',');
        csvString += rowDataCol.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < data.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = data[i][rowKey] === undefined ? '' : data[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = title + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        downloadElement.click();
    },

});