@isTest
public class MathUtilsTest {
    @isTest
    static void testCalculateBMI() {
        Decimal bmi = MathUtils.calculateBMI(70, 1.75);
        System.assertEquals(22.86, bmi, 'BMI should be 22.86');
    }

    @isTest
    static void testBMIZeroHeight() {
        try {
            MathUtils.calculateBMI(70, 0);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Height must be greater than zero'));
        }
    }

    @isTest
    static void testCalculateLoanEMI() {
        Map<String, Decimal> result = MathUtils.calculateLoanEMI(100000, 10, 12);
        System.assertNotEquals(null, result.get('emi'), 'EMI should not be null');
        System.assert(result.get('emi') > 0, 'EMI should be positive');
        System.assert(result.get('totalInterest') > 0, 'Interest should be positive');
    }
}