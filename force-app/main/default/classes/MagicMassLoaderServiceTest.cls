@isTest
public with sharing class MagicMassLoaderServiceTest {
    

    @TestSetup
    static void makeData(){

        Case case1 = new Case(Status='New');

        Case case2 = new Case(Status='New');

        insert case1;
        insert case2;
    }

    @isTest
    public static void testLoadingMassData() {

        List<Case> cases = [SELECT Id, CaseNumber FROM Case];

        String caseFile = 'Case Id;Case Number;Status\r\n';
        for(Case c : cases) {
            List<Object> params = new List<Object>{c.id,c.CaseNumber};
            caseFile+= String.format('{0};{1};Working\r\n',params);
        }

        String targetObject = 'Case';
        String base64File = EncodingUtil.base64Encode(Blob.valueOf(caseFile));

        Test.startTest();
        MagicMassLoaderService mmls = new MagicMassLoaderService();
        mmls.loadMassData('Case', base64File);
        Test.stopTest();
        
        List<Case> updatedCases = [SELECT Id, CaseNumber,Status FROM Case];

        for(Case c : updatedCases) {
            System.assertEquals('Working', c.Status);
        }
    }

    @isTest
    public static void testOrgConfigPresent() {
        List<Magic_Mass_Loader_Configuration__mdt> orgConfigs = [SELECT Id
                                                                FROM  Magic_Mass_Loader_Configuration__mdt 
                                                                WHERE isActive__c = true];
        MagicMassLoaderService mmls = new MagicMassLoaderService();
        System.assertEquals(orgConfigs.size(), mmls.getConfigurations().size());
    }

}
