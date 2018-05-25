public class GoogleNotificationSettings {
 
	public List<GoogleNotification> notifications {	
		get {
			if(notifications == null)
				notifications = new List<GoogleNotification>();
			return notifications;
		}
		set;
	}		
}