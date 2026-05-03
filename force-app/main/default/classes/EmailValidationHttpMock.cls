@IsTest
public with sharing class EmailValidationHttpMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"email_deliverability": {"status": "deliverable", "status_detail": "valid_email"}}');
        return response;
    }
}