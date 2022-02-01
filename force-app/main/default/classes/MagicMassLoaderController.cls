public with sharing class MagicMassLoaderController {

    @AuraEnabled
    public static MagicMassLoaderWrappers.LoadResult loadFileData(String targetObject, String base64) {
        
        MagicMassLoaderService mmls = new MagicMassLoaderService();
        
        return mmls.loadMassData(targetObject, base64);
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectConfig> getObjectAllowed() {
        
        List<ObjectConfig> oConfigs = new List<ObjectConfig>();
        List<Magic_Mass_Loader_Configuration__mdt> configs = new MagicMassLoaderService().getConfigurations();

        for(Magic_Mass_Loader_Configuration__mdt config:configs) {
            oConfigs.add(new ObjectConfig(config.Magic_Mass_Loader_Object__r.Object_API_Name__c
                                            ,config.Magic_Mass_Loader_Object__r.DeveloperName));
        }

        return oConfigs;
    }

    public class ObjectConfig {
        @AuraEnabled
        public String value {get; private set;}
        @AuraEnabled
        public String label {get; private set;}

        public ObjectConfig(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}
