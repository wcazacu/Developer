/**
* Controller for the CreateCalendarEvent VF page
* Creates a Google Calendar Event by making an API call go Google Calendar API and processes the response back
*/
public class CreateCalendarEventVC extends GoogleApiManager{
	
	
	//calendar event object to be serialized and passed to the API

			GoogleCalendarEvent	inputCalendarEvent = new GoogleCalendarEvent();


	//calendar event object to be deserialized from the API response
	public GoogleCalendarEvent responseCalendarEvent{
		get {
			if(responseCalendarEvent == null)
				responseCalendarEvent = new GoogleCalendarEvent();
			return responseCalendarEvent;
		}
		set;
	}
	
	public String selectedCalendarId { get;set; }
	
		
	public PageReference createCalendarEvent(){
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