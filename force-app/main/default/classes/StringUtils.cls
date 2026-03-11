public with sharing class StringUtils {
    public static String capitalize(String input) {
        if (String.isBlank(input)) return input;
        return input.substring(0, 1).toUpperCase() + input.substring(1).toLowerCase();
    }
    public static String capitalizeWords(String input) {
        if (String.isBlank(input)) return input;
        List<String> words = input.split(' '); List<String> cap = new List<String>();
        for (String w : words) cap.add(capitalize(w));
        return String.join(cap, ' ');
    }
    public static String truncate(String input, Integer maxLen) {
        if (String.isBlank(input) || input.length() <= maxLen) return input;
        return input.substring(0, maxLen - 3) + '...';
    }
    public static String maskEmail(String email) {
        if (String.isBlank(email) || !email.contains('@')) return email;
        List<String> parts = email.split('@');
        if (parts[0].length() <= 2) return email;
        return parts[0].substring(0, 2) + '***@' + parts[1];
    }
    public static String maskPhone(String phone) {
        if (String.isBlank(phone) || phone.length() < 4) return phone;
        return '***' + phone.substring(phone.length() - 4);
    }
    public static String generateRandomString(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String result = '';
        for (Integer i = 0; i < length; i++) { Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length()); result += chars.substring(idx, idx + 1); }
        return result;
    }
}