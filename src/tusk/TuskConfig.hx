package tusk;

class TuskConfig {
    public static var text_normal:Vec4 = new Vec4(1, 1, 1, 1);
    public static var text_red:Vec4 = new Vec4(0.671, 0.275, 0.259, 1); // 'r' #AB4642
    public static var text_green:Vec4 = new Vec4(0.631, 0.71, 0.424, 1); // 'g' #A1B56C
    public static var text_blue:Vec4 = new Vec4(0.486, 0.686, 0.761, 1); // 'b' #7CAFC2
    public static var text_cyan:Vec4 = new Vec4(0.525, 0.757, 0.725, 1); // 'c' #86C1B9
    public static var text_magenta:Vec4 = new Vec4(0.729, 0.545, 0.686, 1); // 'm' #BA8BAF
    public static var text_yellow:Vec4 = new Vec4(0.969, 0.792, 0.533, 1); // 'y' #F7CA88
    public static var text_black:Vec4 = new Vec4(0.094, 0.094, 0.094, 1); // 'k' #181818

    public static var window_headerHeight:Float = 16;
    public static var window_headerColour:Vec4 = new Vec4(0, 0, 0, 0.75);
    public static var window_headerTextColour:Vec4 = new Vec4(1, 1, 1, 1);
    public static var window_bodyColour:Vec4 = new Vec4(0, 0, 0, 0.5);

    public static var button_normalColour:Vec4 = new Vec4(0.5, 0.5, 0.5, 0.9);
    public static var button_hoveredColour:Vec4 = new Vec4(0.75, 0.75, 0.75, 1);
    public static var button_pressedColour:Vec4 = new Vec4(1, 1, 1, 1);
    public static var button_disabledColour:Vec4 = new Vec4(0.25, 0.25, 0.25, 0.9);
}