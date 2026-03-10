@isTest
public class HelloWorldTest {
    @isTest
    static void testSayHello() {
        String result = HelloWorld.sayHello('Ravi');
        System.assertEquals('Hello, Ravi! Welcome to Salesforce CI/CD.', result);
    }
}