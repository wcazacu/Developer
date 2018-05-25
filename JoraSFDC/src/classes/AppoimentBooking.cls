public class AppoimentBooking extends GoogleApiManager{
    Public List<Physician__c> availablePhysicians{get;set;}  
    Public datetime nStart {get;set;}
    Public datetime nEnd {get;set;}
    Public Boolean showPhysicians {get;set;}
    Public Boolean showPatient {get;set;}
    Public Boolean editPatient {get;set;}
    public List<phWrapper> wrappedPhysicians {get;set;}
    public Physician__c selectedPhysician {get;set;}
    public List<pWrapper> wrappedPatients {get;set;}
    public Patient__c selectedPatient {get;set;}
    public String PatientName {get;set;}
    public List<Appointment__c> appts {get;set;}
    public Appointment__c bookedAppt {get;set;}
    public Boolean isResponseReady {get {return responseCalendarEvent.id != null;}set;}
    public Boolean showButtns {get;set;}
    
    public class MyException extends Exception{}
    
    
    public AppoimentBooking(){
        if(nStart==null){
            nStart=datetime.now();
        }
        if(nEnd==null){
            nEnd=datetime.now();
        }
        if (editPatient==null){
            editPatient=false;
        }
        if (PatientName==null){
            PatientName='';
        }
        showPatient=false;
        showPhysicians=false;
        showButtns=false;
        
        Google_App__c GoogleApp=[SELECT LastModifiedDate, expiresIn__c, Id, OwnerId, CreatedDate FROM Google_App__c order by LastModifiedDate desc limit 1][0];
        
         try{
            
            if(GoogleApp.LastModifiedDate.addSeconds(3600) < DateTime.now() ) throw new MyException('User needs to authenticate');

        }
        
        catch(exception e){
            System.debug('ERROR:' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please go to "Google Apps" tab to Autenticate first');
            ApexPages.addMessage(myMsg);
            
            
        }
      
    }
    
    Public void getPhysicians(){
        
        List<Appointment__c> apts=[select Appointment_Physician__r.Id from Appointment__c where 
                                   (start_time__c >=:nStart and end_time__c <=:nEnd) OR
                                   (start_time__c <=:nStart and end_time__c >=:nStart) OR
                                   (start_time__c <=:nEnd and end_time__c >=:nEnd)
                                  ];
        system.debug(apts);
        List<ID> Ph_Ap_ID=new list<id>();
        for(Appointment__c a :apts){
            Id x =[select id from Physician__c where id=:a.Appointment_Physician__c].Id;
            
            system.debug(x);
            Ph_Ap_ID.add(x);
        }
        system.debug(Ph_Ap_ID);
        availablePhysicians=[SELECT Id, Name, Department__c, Appointment_Price__c, Email__c,Phone__c  FROM Physician__c where Not id in :Ph_Ap_ID];
        if(availablePhysicians.size()>0){showPhysicians=true;}
        system.debug(showPhysicians);
        List<phWrapper> phwl =new List<phWrapper>();
        for (Physician__c ph : availablePhysicians){
            phwl.add(new phWrapper(ph));
        }
        wrappedPhysicians=phwl;
        showPhysicians=true;
    }
    
    public PageReference processSelectedPh(){
        
        List<phWrapper> w=new List<phWrapper>();
        
        for(phWrapper xPh: wrappedPhysicians) {
            
            if(xPh.selected == True) {
                selectedPhysician=xPh.wph;
                w.add(xPh);
            }
            
        }
        wrappedPhysicians=w;
        return null;
    } 
    
    public PageReference processSelectedP(){
        if(wrappedPatients.size()>1 || selectedPatient==Null){
            List<pWrapper> w=new List<pWrapper>();
            
            for(pWrapper xP: wrappedPatients) {
                
                if(xP.selected == True) {
                    selectedPatient=xP.wp;
                    w.add(xP);
                }
                
            }
            wrappedPatients=w;
            showButtns=true;
        }else{
            selectedPatient=null;
            findPatients();
        }   
        return null;
    }
    
    public void findPatients(){
        
        List<Patient__c> pl=[select id, Name, Email__c, Phone__c  from Patient__c where Name like :('%'+PatientName+'%') limit 5];
        List<pWrapper> pwl =new List<pWrapper>();
        for (Patient__c p:pl){
            pwl.add(new pWrapper(p));
        }
        wrappedPatients=pwl;
        editPatient= false;
        showPatient=true;
    }    
    
    
    public void editPat(){
        
        
        try{
            
            if(selectedPatient==null){
                throw new MyException('');
            }
            editPatient= !editPatient;
            showPatient=!showPatient;
            showButtns=false;
            
        }
        
        catch(exception e){
            System.debug('ERROR:' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please select a Patient to Edit');
            ApexPages.addMessage(myMsg);
            
            
        }
        
    }
    
    
    public PageReference savePatient(){
        update selectedPatient;
        
        editPatient= !editPatient;
        showPatient=!showPatient;
        showButtns=true;
        return null;
    } 
    
    // This is our wrapper/container class.  
    public class phWrapper {
        public Physician__c wph {get; set;}
        public Boolean selected {get; set;}
        
        //This is the contructor method.  
        public phWrapper(Physician__c ph) {
            wph = ph;
            selected = false;
        }
    }
    
    public class pWrapper {
        public Patient__c wp {get; set;}
        public Boolean selected {get; set;}
        
        //This is the contructor method.  
        public pWrapper(Patient__c p) {
            wp = p;
            selected = false;
        }
    }
    
    public void bookAppointment(){
        try{
            Appointment__c appt=new Appointment__c();
            
            appt.Start_Time__c=nStart;
            appt.End_Time__c=nEnd;
            appt.Appointment_Physician__c=selectedPhysician.Id;
            appt.Appointment_Patient__c=selectedPatient.Id;
            
            insert appt;
            
            bookedAppt=[select id,Appointment_Physician__r.Email__c, start_time__c,end_time__c from Appointment__c where id=:appt.Id];
        }
        catch(exception e){
            System.debug('ERROR:' + e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please select a Physician AND a Patient');
            ApexPages.addMessage(myMsg);
            
            
        }
        if(bookedAppt.Id!=null){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The appointment was successfully booked in SFDC')); 
            
        }
    }
    
    public void sendPatientEmail(){
        
        String address = selectedPatient.Email__c;
        String subject = 'Appointment Confirmation';
        String body =  'Dear <b>'+ selectedPatient.Name+'</b><BR />'
            + 'Thank you booking the appointment with me today!'+'<BR />'+'<BR />'
            + 'The appointment is with our '+ selectedPhysician.Department__c  +' physician: ' +selectedPhysician.Name + '<BR />'
            + '<b>Start Time: </b>'+ bookedAppt.start_time__c + '<BR />' + '<b>End Time: </b>' + bookedAppt.end_time__c + '<BR />'
            + '<b>Appointment Price: </b>'+selectedPhysician.Appointment_Price__c+'$'+'<BR />'+'<BR />' 
            + 'Best Regards,'+'<BR />'
            +'Office Manager: ' +'<BR />'+ system.UserInfo.getName();
        String[]  addresses = new String[]{},
            subjects = new String[]{},
                messages = new String[]{};
                    addresses.add(address);
        subjects.add(subject);
        messages.add(body);
        EmailManagerVC em = new EmailManagerVC();
        
        Messaging.SendEmailResult r = em.sendMail(addresses, subjects, messages);
        if(r.isSuccess()){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Confirmation email was successfully sent to '+address)); 
            
        }
        
    } 
    //Google API Calls
    //calendar event object to be serialized and passed to the API
    
    public GoogleCalendarEvent inputCalendarEvent {
        get {
            if(inputCalendarEvent == null){
                inputCalendarEvent = new GoogleCalendarEvent();
                //pre-populate start and end time
                inputCalendarEvent.start = new GoogleEventTime();
                //start in one day
                
                inputCalendarEvent.start.gDatetime = bookedAppt.start_time__c;
                
                inputCalendarEvent.gEnd = new GoogleEventTime();
                //end in an hour
                
                inputCalendarEvent.gEnd.gDatetime = bookedAppt.end_time__c;
                
                inputCalendarEvent.reminders.useDefault = true;
                
                //add attendees
                for(Integer i=0; i<1; i++){			
                    GoogleEventAttendee gEventAttendee = new GoogleEventAttendee();
                    gEventAttendee.email=bookedAppt.Appointment_Physician__r.Email__c;
                    inputCalendarEvent.attendees.add(gEventAttendee);
                    
                }
                inputCalendarEvent.summary='This is the summary test';
                inputCalendarEvent.location='Toronto';
                inputCalendarEvent.attendees[0].optional=false;
                inputCalendarEvent.attendees[0].additionalGuests=0;
                
                
            }
            return inputCalendarEvent;
            
        }
        set;
    }
    //calendar event object to be deserialized from the API response
    public GoogleCalendarEvent responseCalendarEvent{
        get {
            if(responseCalendarEvent == null)
                responseCalendarEvent = new GoogleCalendarEvent();
            return responseCalendarEvent;
        }
        set;
    }
    
    
    
    
    public PageReference createCalendarEvent(){
        
        system.debug(inputCalendarEvent); 
        
        try{
            String calendarEventJsonInput = inputCalendarEvent.serialize();	
            System.debug('calendarEventJsonInput: ' + calendarEventJsonInput);
            String calendarEventJsonOutput;
            //no callouts in test mode
            if(!Test.isRunningTest())
                calendarEventJsonOutput = doAPICall(CALENDAR_URL + '/' + 'primary' + EVENT_URL, calendarEventJsonInput, 'POST');
            else{
                doAPICall(CALENDAR_URL + '/' + 'primary' + EVENT_URL, calendarEventJsonInput, 'POST');
                calendarEventJsonOutput = testEventJson;
            }
            System.debug('calendarEventJsonOutput: ' + calendarEventJsonOutput);
            if(isAPIError)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, calendarEventJsonOutput));
            else{
                responsecalendarEvent.deserialize(calendarEventJsonOutput);
                 
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            System.debug(e);
        }
        
        return null;
    }
    
}