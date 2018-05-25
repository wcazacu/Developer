public with sharing class EmailManagerVC{
    public Messaging.SendEmailResult sendMail(String [] addresses, String [] subjects, String [] messages) {
        Messaging.SingleEmailMessage [] emails = new Messaging.SingleEmailMessage[]{};
        Integer totalMails = addresses.size();
        for(Integer i=0; i < totalMails; i++){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subjects[i]);
            email.setToAddresses(new List<String> { addresses[i] });
            email.setHtmlBody(messages[i]);
            emails.add(email);
        }
        return Messaging.sendEmail(emails)[0];
    }
}