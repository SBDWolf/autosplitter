// Code by Kannadan

state("higan"){
    byte level : "higan.exe",  0x7D0C66;
    ushort menu : "higan.exe", 0x7BBF10;
    ushort finisher : "higan.exe", 0x7B172D;
    ushort x : "higan.exe", 0x7C060E;
    ushort yCamera : "higan.exe", 0x7B0D14;
    byte button1 : "higan.exe", 0x7B0D24;
    byte button2 : "higan.exe", 0x7B0D25;
    byte options : "higan.exe", 0x7B0CE7;
}

state("snes9x-x64"){
    byte level : 0x8DCBB8,  0xFF9E;
    ushort menu : 0x8D8BE8, 0xB248;
    ushort finisher : 0x8D8BE8, 0xA65;
    ushort x : 0x8D8BE8, 0xF946;
    ushort yCamera : 0x8D8BE8, 0x4C;
    byte button1 : 0x8D8BE8, 0x5C;
    byte button2 : 0x8D8BE8, 0x5D;
    byte options : 0x8D8BE8, 0x1F;
}

//SNES CONTROLS
//button1: A->128, X->64, R->16, L->32
//button2: Y->64, B->128, START->16, SELECT->32
//button2: UP->8, DOWN->4, LEFT->2, RIGHT->1

//finisher = 0xffff when simba throwing something
//Start menu position = 24064
//options is zero when in options menu, high in main menu

startup{
}

init
{
    current.currentLevel = 0;
    current.canStart = true;
    current.throwing = false;
    current.scarx = 1209; //higher
    current.scary = 70; //lower
}

start 
{
    print("[LION]: button1 -> " + current.button1);
    print("[LION]: button2 -> " + current.button2);
    print("[LION]: menu -> " + current.menu);
    print("[LION]: level -> " + current.level);
    print("[LION]: options -> " + current.options);
    print("[LION]: finisher -> " + current.finisher);
    print("[LION]: start -> " + current.canStart);
    if(current.options == 0){
        current.canStart = false;
    } else {
        if(current.button2 == 0){
            current.canStart = true;
        }
    }
    if(current.canStart && current.level == 0 && (current.button1 >= 64 || current.button2 == 16 || current.button2 > 32 ) && current.menu == 24064 ){
        return true;
    }
}

split 
{
    if( current.level > old.level){
        if(current.level == 15){
            current.currentLevel = 4;
        } else{
            current.currentLevel = current.level;
        }
        return true;
    }
    if(current.level == 9 && current.yCamera < current.scary && current.x >= current.scarx && current.finisher == 0xFFFF){
        return true;
    }
}

