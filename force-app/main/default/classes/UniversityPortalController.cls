public without sharing class UniversityPortalController {

    public class UserContext {
        @AuraEnabled public Id userId;
        @AuraEnabled public String email;
        @AuraEnabled public String userName;
        @AuraEnabled public Id contactId;
        @AuraEnabled public String userType;
        @AuraEnabled public String contactName;
        @AuraEnabled public String phone;
        @AuraEnabled public String accountName;
    }

    @AuraEnabled(cacheable=true)
    public static UserContext getCurrentUserContext() {

        User currentUser = [
            SELECT Id, Name, Email, Username,
                   ContactId, User_Type__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
        ];

        UserContext result = new UserContext();

        result.userId = currentUser.Id;
        result.userName = currentUser.Username;
        result.email = currentUser.Email;
        result.contactId = currentUser.ContactId;
        result.userType = currentUser.User_Type__c;

        // External users have a related Contact.
        if (currentUser.ContactId != null) {

            Contact relatedContact = [
                SELECT Id, Name, Phone, Account.Name
                FROM Contact
                WHERE Id = :currentUser.ContactId
                WITH USER_MODE
                LIMIT 1
            ];

            result.contactName = relatedContact.Name;
            result.phone = relatedContact.Phone;
            result.accountName = relatedContact.Account!=null?relatedContact.Account.Name:null;
        }

        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Course_Enrollment__c> getMyCourses() {

        // Identify the currently logged-in user.
        User currentUser = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ];
        // Internal users do not necessarily have a Contact.
        if (currentUser.ContactId == null) {
            return new List<Course_Enrollment__c>();
        }

        // Retrieve this student's course enrollments.
        List<Course_Enrollment__c> enrollments = [
            SELECT Id,
                   Name,
                   Enrollment_Date__c,
                   Enrollment_Status__c,
                   Completion_Date__c,
                   Grade__c,
                   Course__r.Name,
                   Course__r.Course_Code__c,
                   Course__r.Course_Status__c,
                   Course__r.Start_Date__c,
                   Course__r.End_Date__c,
                   Course__r.Description__c
            FROM Course_Enrollment__c
            WHERE Student_Contact__c = :currentUser.ContactId
            WITH SYSTEM_MODE
            ORDER BY Enrollment_Date__c DESC NULLS LAST ];
        return enrollments;
    }

}