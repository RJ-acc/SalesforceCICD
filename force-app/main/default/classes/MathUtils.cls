public with sharing class MathUtils {
    @AuraEnabled
    public static Decimal calculateBMI(Decimal weightKg, Decimal heightM) {
        if (heightM <= 0) {
            throw new AuraHandledException('Height must be greater than zero');
        }
        return (weightKg / (heightM * heightM)).setScale(2);
    }

    @AuraEnabled
    public static Map<String, Decimal> calculateLoanEMI(Decimal principal, Decimal annualRate, Integer months) {
        Decimal monthlyRate = annualRate / 12 / 100;
        Decimal emi = (principal * monthlyRate * Math.pow(1 + Double.valueOf(monthlyRate), months)) /
                      (Math.pow(1 + Double.valueOf(monthlyRate), months) - 1);

        Map<String, Decimal> result = new Map<String, Decimal>();
        result.put('emi', emi.setScale(2));
        result.put('totalPayment', (emi * months).setScale(2));
        result.put('totalInterest', ((emi * months) - principal).setScale(2));
        return result;
    }
}