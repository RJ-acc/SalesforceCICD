public with sharing class HelloWorld {
    @AuraEnabled
    public static String sayHello(String name) {
        return 'Hello, ' + name + '! Welcome to Salesforce CI/CD.';
    }
}