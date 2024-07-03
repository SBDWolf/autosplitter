// Code by Kannadan and SBDWolf
//
// Some code taken from the Super Metroid autosplitter: https://github.com/UNHchabo/AutoSplitters/blob/master/SuperMetroid/LiveSplit.SuperMetroid.asl

state("bsnes"){}
state("snes9x"){}
state("snes9x-x64"){}
state("retroarch"){}
state("higan"){}

startup
{
    vars.scarX = 1209;
    vars.scarY = 70;

    Action<string> DebugOutput = (text) => {
        print("[The Lion King SNES Autosplitter] "+text);
    };
    vars.DebugOutput = DebugOutput;
}

init {
    IntPtr memoryOffset = IntPtr.Zero;

    if (memory.ProcessName.ToLower().Contains("snes9x")) {
        var versionsLegacy = new Dictionary<int, long>{
            { 10330112, 0x789414 },   // snes9x 1.52-rr
            { 7729152, 0x890EE4 },    // snes9x 1.54-rr
            { 5914624, 0x6EFBA4 },    // snes9x 1.53
            { 6909952, 0x140405EC8 }, // snes9x 1.53 (x64)
            { 6447104, 0x7410D4 },    // snes9x 1.54/1.54.1
            { 7946240, 0x1404DAF18 }, // snes9x 1.54/1.54.1 (x64)
            { 6602752, 0x762874 },    // snes9x 1.55
            { 8355840, 0x1405BFDB8 }, // snes9x 1.55 (x64)
            { 6856704, 0x78528C },    // snes9x 1.56/1.56.2
            { 9003008, 0x1405D8C68 }, // snes9x 1.56 (x64)
            { 6848512, 0x7811B4 },    // snes9x 1.56.1
            { 8945664, 0x1405C80A8 }, // snes9x 1.56.1 (x64)
            { 9015296, 0x1405D9298 }, // snes9x 1.56.2 (x64)
            { 6991872, 0x7A6EE4 },    // snes9x 1.57
            { 9048064, 0x1405ACC58 }, // snes9x 1.57 (x64)
            { 7000064, 0x7A7EE4 },    // snes9x 1.58
            { 9060352, 0x1405AE848 }, // snes9x 1.58 (x64)
            { 8953856, 0x975A54 },    // snes9x 1.59.2
            { 12537856, 0x1408D86F8 },// snes9x 1.59.2 (x64)
            { 9646080, 0x97EE04 },    // Snes9x-rr 1.60
            { 13565952, 0x140925118 },// Snes9x-rr 1.60 (x64)
            { 9027584, 0x94DB54 },    // snes9x 1.60
            { 12836864, 0x1408D8BE8 } // snes9x 1.60 (x64)
        };

        long pointerAddr;
        if (versionsLegacy.TryGetValue(modules.First().ModuleMemorySize, out pointerAddr)) {
            memoryOffset = memory.ReadPointer((IntPtr)pointerAddr);
        }
        else {
            // Module-relative addresses
            var versions = new Dictionary<int, int>{
                { 10399744, 0x587494 }, // snes9x 1.62.3
                { 15474688, 0xA32314 }, // snes9x 1.62.3 (x64)
            };
            int wramAddr;
            if (versions.TryGetValue(modules.First().ModuleMemorySize, out wramAddr)) {
                memoryOffset = modules.First().BaseAddress + wramAddr;
            }
        }

    } else if (memory.ProcessName.ToLower().Contains("bsnes") || memory.ProcessName.ToLower().Contains("higan")) {
        var versions = new Dictionary<int, int>{
            { 23781376, 0x7B0CC8 },      // higan v110
            { 52477952, 0x716D7C },      // bsnes v115
            { 52719616, 0x73AD7C },      // bsnes v115 2023 Nightly
        };

        int wramAddr;
        if (versions.TryGetValue(modules.First().ModuleMemorySize, out wramAddr)) {
            memoryOffset = modules.First().BaseAddress + wramAddr;
        }

    }else if (memory.ProcessName.ToLower().Contains("retroarch")) {
        var bsnesModule = modules.FirstOrDefault(m => m.ModuleName.ToLower() == "bsnes_libretro.dll");
        if (bsnesModule != null) {
            var versions = new Dictionary<int, int>{
                { 53301248, 0x8179DC }, // bsnes v115
            };
            int wramOffset;
            if (versions.TryGetValue(bsnesModule.ModuleMemorySize, out wramOffset)) {
                memoryOffset = bsnesModule.BaseAddress + wramOffset;
            }
        }
    }

    if (memoryOffset == IntPtr.Zero) {
        vars.DebugOutput("Unsupported emulator version");
        vars.watchers = new MemoryWatcherList{};
        // Throwing prevents initialization from completing. LiveSplit will
        // retry it until it eventually works. (Which lets you load a core in
        // RA for example.)
        throw new InvalidOperationException("Unsupported emulator version");
    }

    vars.DebugOutput("Found WRAM address: 0x" + memoryOffset.ToString("X8"));
    vars.watchers = new MemoryWatcherList
    {
        new MemoryWatcher<byte>(memoryOffset + 0x1FF9E) { Name = "level" },
        new MemoryWatcher<ushort>(memoryOffset + 0xB248) { Name = "menu" },
        new MemoryWatcher<ushort>(memoryOffset + 0xA65) { Name = "finisher" },
        new MemoryWatcher<ushort>(memoryOffset + 0xF946) { Name = "x" },
        new MemoryWatcher<ushort>(memoryOffset + 0x4C) { Name = "yCamera" },
        new MemoryWatcher<byte>(memoryOffset + 0x5C) { Name = "joypad1" },
        new MemoryWatcher<byte>(memoryOffset + 0x5D) { Name = "joypad2" },
        new MemoryWatcher<byte>(memoryOffset + 0x1F) { Name = "options" },
    };
}    

update
{
    vars.watchers.UpdateAll(game);
}

start
{
    if(vars.watchers["options"].Current == 0){
        vars.canStart = false;
    } else {
        if(vars.watchers["joypad2"].Current == 0){
            vars.canStart = true;
        }
    }
    if(vars.canStart && vars.watchers["level"].Current == 0 && (vars.watchers["joypad1"].Current >= 64 || vars.watchers["joypad2"].Current == 16 || vars.watchers["joypad2"].Current > 32 ) && vars.watchers["menu"].Current == 24064 ){
        return true;
    }
}

split 
{
    if(vars.watchers["level"].Current > vars.watchers["level"].Old){
        return true;
    }
    if(vars.watchers["level"].Current == 9 && vars.watchers["yCamera"].Current < vars.scarY && vars.watchers["x"].Current >= vars.scarX && vars.watchers["finisher"].Current == 0xFFFF){
        return true;
    }
}

reset {
    if (vars.watchers["level"].Old != 14 && vars.watchers["level"].Current == 14){
    return true;
    }
}