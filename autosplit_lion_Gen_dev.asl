// Code by Kannadan

state("Fusion"){
    byte level : 0x2A52D4, 0xCCCF;
    byte health : 0x2A52D4, 0xCCF7;
    ushort backGround : 0x2A52D4, 0x84A8;
    ushort x : 0x2A52D4, 0x9356;
    ushort xCamera : 0x2A52D4, 0x93D6;
    ushort yCamera : 0x2A52D4, 0x93D8;
    byte button1 : 0x2A52D4, 0x819C;
    byte button2 : 0x2A52D4, 0x819D;
    byte cursor : 0x2A52D4, 0x916F;
    byte options : 0x2A52D4, 0x3400;
    byte paused : 0x2A52D4, 0x000C;
    ushort finisher : 0x2A52D4, 0xE9B4;
}

state("retroarch"){
    byte level : 0x2A52D4, 0xCCCF;
    // byte health : 0x2A52D4, 0xCCF7;
    // ushort backGround : 0x2A52D4, 0x84A8;
    // ushort x : 0x2A52D4, 0x9356;
    // ushort xCamera : 0x2A52D4, 0x93D6;
    // ushort yCamera : 0x2A52D4, 0x93D8;
    // byte button1 : 0x2A52D4, 0x819C;
    // byte button2 : 0x2A52D4, 0x819D;
    // byte cursor : 0x2A52D4, 0x916F;
    // byte options : 0x2A52D4, 0x3400;
    // byte paused : 0x2A52D4, 0x000C;
    // ushort finisher : 0x2A52D4, 0xE9B4;
}

//x value is level 10 specific

//GEN CONTROLS
//button1: A->64, B->16, C->32

//finisher = 0xffff when simba throwing something
//Start menu position = 248
//options is zero when in options menu, high in main menu

startup{
    vars.toBigEndian = (Func<ushort, ushort>)((value) => {
        int byte1 = (value >> 0) & 0xff;
        int byte2 = (value >> 8) & 0xff;

        return (ushort) (byte1 << 8 | byte2 << 0);
    });
    vars.LookUpInDLL = (Func<Process, ProcessModuleWow64Safe, SigScanTarget, IntPtr>)((proc, dll, target) =>
        {
            print("Scanning memory");

            IntPtr result = IntPtr.Zero;
            var scanner = new SignatureScanner(proc, dll.BaseAddress, (int)dll.ModuleMemorySize);
            result = scanner.Scan(target);
            return result;
        });
}

init
{
    IntPtr baseAddress, codeOffset;
    long refLocation = 0, smsOffset = 0;
    long memoryOffset = 0, smsMemoryOffset = 0;
    SigScanTarget target;

    current.currentLevel = 0;
    current.canStart = true;
    current.throwing = false;
    current.scarx = 1190; //higher
    current.scary = 200; //lower
    vars.scenes = new Dictionary<string, ushort>{
        {"menu", 3598},
        {"l1", 514},
        {"l2", 2670},
        {"l3", 1640},
        {"l4", 654},
        {"l5", 2},
        {"l6", 3138},
        {"l7", 1672},
        {"l8", 4},
        {"l9", 1636},
        {"l10", 2082},
    };
    vars.lNames = new List<String>(vars.scenes.Keys);
    ProcessModuleWow64Safe libretromodule = modules.Where(m => m.ModuleName == "genesis_plus_gx_libretro.dll" || m.ModuleName == "blastem_libretro.dll" || m.ModuleName == "picodrive_libretro.dll").First();                    
    target = new SigScanTarget(0x10, "85 C9 74 ?? 83 F9 02 B8 00 00 00 00 48 0F 44 05 ?? ?? ?? ?? C3");
    codeOffset = vars.LookUpInDLL( game, libretromodule, target );
    long memoryReference = memory.ReadValue<int>( codeOffset );
    refLocation = ( (long) codeOffset + 0x04 + memoryReference );
    print("[LION_INIT] process: " + game.ProcessName);
    print("[LION_INIT] models: " + libretromodule.BaseAddress);
    print("[LION_INIT] model size: " + libretromodule.ModuleMemorySize);
    print("[LION_INIT] game: " + game.Is64Bit());
    print("[LION_INIT] REF: " + refLocation);
}

start 
{
    // if(current.options == 0){
    //     current.canStart = false;
    // } else {
    //     if(current.button2 == 0){
    //         current.canStart = true;
    //     }
    // }

    // if(current.canStart && current.button2 >= 16 && old.options != 0 && current.cursor == 248 && vars.toBigEndian(old.backGround) == vars.scenes["menu"]){
    //     current.currentLevel = 1;
    //     return true;
    // }
}

split 
{
    if(current.paused != 0){
        return false;
    }
    if(current.level == 10 && current.finisher == 0xFFFF && vars.toBigEndian(current.yCamera) < current.scary && vars.toBigEndian(current.x) > current.scarx){
        print("[LION_SPLIT] win " + current.level);
        return true;
    }
    

    
    if(current.level == current.currentLevel + 1){
        current.currentLevel = current.level;
        print("[LION_SPLIT]: level swap-> ");
        return true;
    }
    if(vars.toBigEndian(old.backGround) == vars.scenes[vars.lNames[current.currentLevel]] && vars.toBigEndian(current.backGround) < vars.scenes[vars.lNames[current.currentLevel]] && current.health > 0){
        print("[LION_SPLIT]: health -> " + current.health);
        print("[LION_SPLIT]: level -> " + current.level);
        print("[LION_SPLIT]: BG -> " + vars.toBigEndian(current.backGround));
        print("[LION_SPLIT]: BGO -> " + vars.toBigEndian(old.backGround));
        print("[LION_SPLIT]: CURSOR -> " + current.cursor);
        if(current.currentLevel == 1 && current.cursor == 248){
            return false;
        }
        if(current.currentLevel != current.level){
            return false;
        }
        if(current.currentLevel == 5 && vars.toBigEndian(current.yCamera) < 2400){
            return false;
        }

        if(current.currentLevel == 9 && (vars.toBigEndian(current.yCamera) < 600 || vars.toBigEndian(current.xCamera) < 2750)){
            return false;
        }
        current.currentLevel = current.currentLevel + 1;
        return true;
        //print("[LION_SPLIT]:  -> " + current.level);
    }
    
}

