public with sharing class DataValidator {
    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) return false;
        String regex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        return Pattern.compile(regex).matcher(email).matches();
    }
    public static Boolean isValidPhone(String phone) {
        if (String.isBlank(phone)) return false;
        return phone.replaceAll('[^0-9]', '').length() >= 10;
    }
    public static Boolean isValidUrl(String url) {
        if (String.isBlank(url)) return false;
        return url.startsWith('http://') || url.startsWith('https://');
    }
    public static String sanitizeInput(String input) {
        if (String.isBlank(input)) return '';
        return input.stripHtmlTags().trim();
    }
    public static Boolean isValidCurrency(Decimal amount) { return amount != null && amount >= 0; }
    @AuraEnabled
    public static Map<String, Boolean> validateContactData(String email, String phone, String website) {
        Map<String, Boolean> r = new Map<String, Boolean>();
        r.put('emailValid', isValidEmail(email)); r.put('phoneValid', isValidPhone(phone)); r.put('websiteValid', isValidUrl(website));
        return r;
    }
}