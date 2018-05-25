public class AppointmentLookupController {

    public String searchEmail {get;set;}
    public String searchName {get;set;}
    public List<ApptPatient> searchResults {get;set;}
    
    public AppointmentLookupController(){
        
            searchName ='enter keyword';
                searchEmail ='enter keyword';
    }
      
   public PageReference doSearch() {
 
       List<ApptPatient> aps=new List<ApptPatient>();
       
       List<Appointment__c> results1 =  [select Name, Appointment_Patient__r.Name,Appointment_Patient__r.Email__c 
                                         ,Appointment_Physician__r.Name,Appointment_Physician__r.Email__c 
                                         ,start_time__c, end_time__c from Appointment__c
                                        where Appointment_Patient__r.Email__c like :('%'+searchEmail+'%')
                                      or Appointment_Patient__r.Name like :('%'+searchName+'%')];
       
       for (Appointment__c r:results1){
           ApptPatient ap=new ApptPatient();
           ap.Patient_Name=r.Appointment_Patient__r.Name;
           ap.Patient_Email=r.Appointment_Patient__r.Email__c;
           ap.Physician_Name=r.Appointment_Physician__r.Name;
           ap.Physician_Email=r.Appointment_Physician__r.Email__c;
           ap.start_time=r.start_time__c;
           ap.end_time=r.end_time__c;
           aps.add(ap);           
       }
       
       searchResults=aps;
 //system.debug(searchResults);
       return null;
   }
    
    Public class ApptPatient{
        Public String  Patient_Name{get;set;}
        Public String  Patient_Email{get;set;}
        Public String  Physician_Name{get;set;}
        Public String  Physician_Email{get;set;}
        Public DateTime  start_time{get;set;}
        Public DateTime  end_time{get;set;}        
    }

}