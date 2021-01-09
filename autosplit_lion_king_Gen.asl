// Code by Kannadan
// retroarch address scan from beninswens sonic splitter

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

state("retroarch"){     //genesis_plus_gx core only
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
            IntPtr result = IntPtr.Zero;
            var scanner = new SignatureScanner(proc, dll.BaseAddress, (int)dll.ModuleMemorySize);
            result = scanner.Scan(target);
            return result;
        });
}

init
{


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
    if(game.ProcessName == "retroarch"){
        IntPtr baseAddress, codeOffset;
        long memoryReference;
        long refLocation = 0;
        long memoryOffset = 0;
        SigScanTarget target;
        baseAddress = modules.First().BaseAddress;
        ProcessModuleWow64Safe libretromodule = modules.Where(m => m.ModuleName == "genesis_plus_gx_libretro.dll").First();  
        if ( game.Is64Bit() ) {
            target = new SigScanTarget(0x10, "85 C9 74 ?? 83 F9 02 B8 00 00 00 00 48 0F 44 05 ?? ?? ?? ?? C3");
            codeOffset = vars.LookUpInDLL( game, libretromodule, target );
            memoryReference = memory.ReadValue<int>( codeOffset );
            refLocation = ( (long) codeOffset + 0x04 + memoryReference );

        } else {
            target = new SigScanTarget(0, "8B 44 24 04 85 C0 74 18 83 F8 02 BA 00 00 00 00 B8 ?? ?? ?? ?? 0F 45 C2 C3 8D B4 26 00 00 00 00");
            codeOffset = vars.LookUpInDLL( game, libretromodule, target );
            memoryReference = 0;
            refLocation = (long) codeOffset + 0x11;
        }
        vars.emuoffsets = new MemoryWatcherList
        {
            new MemoryWatcher<uint>( (IntPtr) refLocation ) { Name = "genesis", FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull },
            new MemoryWatcher<uint>( (IntPtr) baseAddress ) { Name = "baseaddress", FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull }
        };
        memoryOffset = vars.emuoffsets["genesis"].Current;
        if ( memoryOffset == 0 && refLocation > 0 ) {
            memoryOffset = refLocation;
        }
        vars.watchers = new MemoryWatcherList{};

        vars.watchers.Add( new MemoryWatcher<byte>( 
            (IntPtr) ( (  memoryOffset ) + 0xCCCE + 0x24440) 
            ) { Name = "level", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
                    (IntPtr) ( (  memoryOffset ) + 0xCCF6 + 0x24440) 
                    ) { Name = "health", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<ushort>( 
            (IntPtr) ( (  memoryOffset ) + 0x84A8 + 0x24440) 
            ) { Name = "backGround", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<ushort>( 
                    (IntPtr) ( (  memoryOffset ) + 0x9356 + 0x24440) 
                    ) { Name = "x", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<ushort>( 
            (IntPtr) ( (  memoryOffset ) + 0x93D6 + 0x24440) 
            ) { Name = "xCamera", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<ushort>( 
                    (IntPtr) ( (  memoryOffset ) + 0x93D8 + 0x24440) 
                    ) { Name = "yCamera", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
            (IntPtr) ( (  memoryOffset ) + 0x819B + 0x24440) 
            ) { Name = "button1", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
                    (IntPtr) ( (  memoryOffset ) + 0x819C + 0x24440) 
                    ) { Name = "button2", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
            (IntPtr) ( (  memoryOffset ) + 0x916E + 0x24440) 
            ) { Name = "cursor", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
                    (IntPtr) ( (  memoryOffset ) + 0x3400 + 0x24440) 
                    ) { Name = "options", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<byte>( 
                    (IntPtr) ( (  memoryOffset ) + 0x000D + 0x24440) 
                    ) { Name = "paused", Enabled = true } 
        );
        vars.watchers.Add( new MemoryWatcher<ushort>( 
                    (IntPtr) ( (  memoryOffset ) + 0xE9B4 + 0x24440) 
                    ) { Name = "finisher", Enabled = true } 
        );

        current.level = vars.watchers["level"].Current;
        current.health = vars.watchers["health"].Current;
        current.backGround = vars.toBigEndian(vars.watchers["backGround"].Current);
        current.x = vars.toBigEndian(vars.watchers["x"].Current);
        current.xCamera = vars.toBigEndian(vars.watchers["xCamera"].Current);
        current.yCamera = vars.toBigEndian(vars.watchers["yCamera"].Current);
        current.button1 = vars.watchers["button1"].Current;
        current.button2 = vars.watchers["button2"].Current;
        current.cursor = vars.watchers["cursor"].Current;
        current.options = vars.watchers["options"].Current;
        current.paused = vars.watchers["paused"].Current;
        current.finisher = vars.toBigEndian(vars.watchers["finisher"].Current);
    }
    
}

start 
{
    if(current.options == 0){
        current.canStart = false;
    } else {
        if(current.button2 == 0){
            current.canStart = true;
        }
    }
    if(vars.toBigEndian(old.backGround) != vars.scenes["menu"]){
        current.canStart = false;
    }

    if(current.canStart && current.button2 >= 16 && old.options != 0 && current.cursor == 248 && vars.toBigEndian(old.backGround) == vars.scenes["menu"]){
        current.currentLevel = 1;
        return true;
    }
}

update
{
    if(game.ProcessName == "retroarch"){
        vars.watchers.UpdateAll(game);
        current.level = vars.watchers["level"].Current;
        current.health = vars.watchers["health"].Current;
        current.backGround = vars.toBigEndian(vars.watchers["backGround"].Current);
        current.x = vars.toBigEndian(vars.watchers["x"].Current);
        current.xCamera = vars.toBigEndian(vars.watchers["xCamera"].Current);
        current.yCamera = vars.toBigEndian(vars.watchers["yCamera"].Current);
        current.button1 = vars.watchers["button1"].Current;
        current.button2 = vars.watchers["button2"].Current;
        current.cursor = vars.watchers["cursor"].Current;
        current.options = vars.watchers["options"].Current;
        current.paused = vars.watchers["paused"].Current;
        current.finisher = vars.toBigEndian(vars.watchers["finisher"].Current);
    }
}

split 
{
    if(current.paused != 0){
        return false;
    }
    if(current.level == 10 && current.finisher == 0xFFFF && vars.toBigEndian(current.yCamera) < current.scary && vars.toBigEndian(current.x) > current.scarx){
        return true;
    }
    

    
    if(current.level == current.currentLevel + 1){
        current.currentLevel = current.level;
        return true;
    }
    if(vars.toBigEndian(old.backGround) == vars.scenes[vars.lNames[current.currentLevel]] && vars.toBigEndian(current.backGround) < vars.scenes[vars.lNames[current.currentLevel]] && current.health > 0){
        if(current.currentLevel == 1 && current.cursor == 248){
            return false;
        }
        if(current.currentLevel != current.level){
            return false;
        }
        if(current.currentLevel == 5 && vars.toBigEndian(current.yCamera) < 2400){
            return false;
        }

        if(current.currentLevel == 9 && (vars.toBigEndian(current.yCamera) < 580 || vars.toBigEndian(current.xCamera) < 2750)){
            return false;
        }
        current.currentLevel = current.currentLevel + 1;
        return true;
    }
    
}

