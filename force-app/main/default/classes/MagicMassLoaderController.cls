public with sharing class MagicMassLoaderController {

    @AuraEnabled
    public static void loadMassData(String base64) {
        List<String> dataLines = EncodingUtil.base64Decode(base64).toString().split('[\n\r]');

        Map<String,Schema.SObjectType> objectsMap  = Schema.getGlobalDescribe();
        Schema.SObjectType s = objectsMap.get('Case');
        Map<String,Schema.SObjectField> mapField = s.getDescribe().fields.getMap();
        List<String> labels = dataLines[0].split(';');
        // removing the first line with labels, from the data
        dataLines.remove(0);

        Map<Integer, FieldStruct> fieldMapped = new Map<Integer,FieldStruct>();
        Map<String,Schema.DescribeFieldResult> fieldLabelToApi = new Map<String,Schema.DescribeFieldResult>();

        for(String field:mapField.keySet()) {
            Schema.DescribeFieldResult fieldDesc = mapField.get(field).getDescribe();
            fieldLabelToApi.put(fieldDesc.getLabel().toLowerCase(),fieldDesc);
        }

        for(Integer i=0;i<labels.size();i++){
            String fieldLabel = labels[i].toLowerCase();
            if(fieldLabelToApi.containsKey(fieldLabel)) {
                String fieldApiName = fieldLabelToApi.get(fieldLabel).getName() ;
                // if the field specified is not updateable, we will just skip it by associating a null value, except if it is Id.
                // this is useful in case for example in an extract there is Id, Case number as reference 
                // but we don't want to update it
                Schema.DescribeFieldResult fieldDesc = fieldLabelToApi.get(fieldLabel);
                if(fieldDesc.updateable || fieldApiName == 'Id') { 
                    FieldStruct currentField = new FieldStruct(labels[i], fieldApiName);
                    fieldMapped.put(i,currentField);
                } else {
                    fieldMapped.put(i,null);
                }

            }
        }
        System.debug(fieldMapped);

        List<SObject> objToUpdate = new List<SObject>();
        for(String line:dataLines) {
            Sobject so = s.newSObject();
            List<String> values = line.split(';');

            // if number of values on the line is different of number of labels, skip the line
            // TODO Notification?
            if(values.size() != labels.size()) {
                continue;
            }

            Integer index = 0;
            // To improve, now based on the order of the values.. Is it a long term solution?
            for(String value:values) {
                if(fieldMapped.get(index) != null) {
                    so.put(fieldMapped.get(index).apiName,value);
                }
                index++;
            }
            objToUpdate.add(so);
        }

        if(objToUpdate.size() > 0) {
            update objToUpdate;
        }

    }

    private class FieldStruct {
        public string label { get; private set;}
        public String apiName { get; private set;}

        public FieldStruct(String label, String apiName) {
            this.label = label;
            this.apiName = apiName;

        }
    }
}
