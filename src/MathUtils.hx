package;

class MathUtils {
    public static function round(number:Float, precision:Int):Float {
        var num = number; 
        num = num * Math.pow(10, precision);
        num = Math.round( num ) / Math.pow(10, precision);
        return num;
    }
}