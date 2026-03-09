@isTest
public class StringUtilsTest {
    @isTest static void testCapitalize() { System.assertEquals('Hello', StringUtils.capitalize('hello')); System.assertEquals(null, StringUtils.capitalize(null)); }
    @isTest static void testCapitalizeWords() { System.assertEquals('Hello World', StringUtils.capitalizeWords('hello world')); }
    @isTest static void testTruncate() { System.assertEquals('Hello...', StringUtils.truncate('Hello World Test', 8)); System.assertEquals('Hi', StringUtils.truncate('Hi', 10)); }
    @isTest static void testMaskEmail() { System.assertEquals('te***@example.com', StringUtils.maskEmail('test@example.com')); }
    @isTest static void testMaskPhone() { System.assertEquals('***4567', StringUtils.maskPhone('1234567')); }
    @isTest static void testRandom() { System.assertEquals(10, StringUtils.generateRandomString(10).length()); }
}