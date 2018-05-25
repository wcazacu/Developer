public class testDelete {
   public list<TestObject__c> l{get;set;}
        
transient String  Jsn {get;set;}
    String  Jsn2 {get;set;} 
    public PageReference  getRecs(){
        
        
     l=[SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, JustTextField__c FROM TestObject__c limit 1000];
   jsn=json.serialize(l);
           jsn2=json.serialize(l);
        return null;
    }

    
}