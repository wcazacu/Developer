public class AppointmentGoogleEmbed{

    public List<SelectOption> PhysiciansCalendars {get;set;}
     public String selectedCalendar{get;set;}
    
 
 public AppointmentGoogleEmbed(){
  PhysiciansCalendars = new List<SelectOption>();
    PhysiciansCalendars.add(new SelectOption('','--None--'));
    list<Physician__c> Phs =  [select Google_Calendar_Link__c, name from Physician__c where Google_Calendar_Link__c!=null];
     for(Physician__c ph:Phs)
     {
     PhysiciansCalendars.add(new SelectOption(ph.Google_Calendar_Link__c, ph.Name));
     }
     
 
}
}