public with sharing class MagicMassLoaderService implements IMagicMassLoader {

    public MagicMassLoaderWrappers.LoadResult loadMassData(String targetObject, String base64) {
        List<String> dataLines = EncodingUtil.base64Decode(base64).toString().split('[\n\r]');

        Map<String,Schema.SObjectType> objectsMap  = Schema.getGlobalDescribe();
        Schema.SObjectType s = objectsMap.get(targetObject);
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

        // object map so if there is several time same Id in the document, we take only one value, and the last
        Map<Id,Sobject> recordsMap = new Map<Id,Sobject>();
        for(String line:dataLines) {
            Sobject so = s.newSObject();
            List<String> values = line.split(';');

            // if number of values on the line is different of number of labels, skip the line
            // TODO Notification?
            if(values.size() != labels.size()) {
                continue;
            }

            Integer index = 0;
            Id objectId;
            // To improve, now based on the order of the values.. Is it a long term solution?
            for(String value:values) {
                if(fieldMapped.get(index) != null) {
                    if(fieldMapped.get(index).apiName == 'Id') {
                        objectId = value;
                    }

                    so.put(fieldMapped.get(index).apiName,value);
                }
                index++;
            }
            recordsMap.put(objectId,so);
        }

        Integer linesSuccess = 0;
        Integer linesError = 0;
        Integer recordsProcessed = recordsMap.values().size();

        if(recordsMap.keyset().size() > 0) {
            List<Database.SaveResult> results = Database.update(recordsMap.values(), false);

            for(Database.SaveResult result:results) {
                if(result.isSuccess()) {
                    linesSuccess++;
                } else {
                    linesError++;
                }
            }
        }

        MagicMassLoaderWrappers.LoadResult resultSum = new MagicMassLoaderWrappers.LoadResult(recordsProcessed,linesSuccess,linesError);

        return resultSum;
    }

    public List<Magic_Mass_Loader_Configuration__mdt> getConfigurations() {
        return [SELECT DeveloperName, Modes_Allowed__c, 
                        Magic_Mass_Loader_Object__r.DeveloperName, 
                        Magic_Mass_Loader_Object__r.Object_API_Name__c 
                FROM  Magic_Mass_Loader_Configuration__mdt 
                WHERE isActive__c = true];
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