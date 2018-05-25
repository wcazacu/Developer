trigger LazyEmployee on Case (after insert) {
  
    integer oldTriggers = [select count() from case where createdbyid = :userInfo.getUserId()];
    integer newTriggers = trigger.newMap.size();
    integer totalTriggers = oldTriggers + newTriggers;
   integer cs= integer.valueOf(UserLimits__c.getInstance(userInfo.getUserId()).CaseLimit__c);
    
    system.debug(totalTriggers);
    if(totalTriggers>cs){
        for (case c:trigger.new){
            c.adderror('Too many cases created this month for user '+userInfo.getName()+' ('+userInfo.getUserId()+'):'+cs +'Current' +oldTriggers);          
            
        }

    }
   
}