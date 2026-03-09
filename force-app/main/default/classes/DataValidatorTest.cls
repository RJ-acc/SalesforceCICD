@isTest
public class DataValidatorTest {
    @isTest static void testEmail() { System.assert(DataValidator.isValidEmail('t@e.com')); System.assert(!DataValidator.isValidEmail('bad')); System.assert(!DataValidator.isValidEmail(null)); }
    @isTest static void testPhone() { System.assert(DataValidator.isValidPhone('1234567890')); System.assert(!DataValidator.isValidPhone('123')); }
    @isTest static void testUrl() { System.assert(DataValidator.isValidUrl('https://e.com')); System.assert(!DataValidator.isValidUrl('e.com')); }
    @isTest static void testSanitize() { System.assertEquals('Hello', DataValidator.sanitizeInput('<b>Hello</b>')); System.assertEquals('', DataValidator.sanitizeInput(null)); }
    @isTest static void testCurrency() { System.assert(DataValidator.isValidCurrency(100.50)); System.assert(!DataValidator.isValidCurrency(null)); }
    @isTest static void testValidateContact() { Map<String, Boolean> r = DataValidator.validateContactData('t@e.com', '5551234567', 'https://t.com'); System.assert(r.get('emailValid')); }
}