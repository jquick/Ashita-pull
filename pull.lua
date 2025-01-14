addon.name      = 'pull';
addon.author    = 'Mazungu';
addon.version   = '1.0.0';
addon.desc      = 'Convert /check into a pull message to party chat. Must use /pullToggle before /check in a macro';
addon.link      = 'https://github.com/jquick/Ashita-pull';

require('common');
local chat = require('chat');

--[[
Most all of this code is from the plugin Checker
https://git.ashitaxi.com/Addons/checker

This plugin just allows it to be sent to the party chat
--]]


-- Checker Variables
local checker = T{
    conditions = T{
        [0xAA] = chat.message('High Evasion, High Defense'),
        [0xAB] = chat.message('High Evasion'),
        [0xAC] = chat.message('High Evasion, Low Defense'),
        [0xAD] = chat.message('High Defense'),
        [0xAE] = '',
        [0xAF] = chat.message('Low Defense'),
        [0xB0] = chat.message('Low Evasion, High Defense'),
        [0xB1] = chat.message('Low Evasion'),
        [0xB2] = chat.message('Low Evasion, Low Defense'),
    },
    types = T{
        [0x40] = 'too weak to be worthwhile',
        [0x41] = 'like incredibly easy prey',
        [0x42] = 'like easy prey',
        [0x43] = 'like a decent challenge',
        [0x44] = 'like an even match',
        [0x45] = 'tough',
        [0x46] = 'very tough',
        [0x47] = 'incredibly tough',
    },
    widescan = T{ },
};

-- toggle enable of the plugin
local isActive = false;
local additionalOutput = '';
ashita.events.register('command', 'command_cb', function (e)
    if (string.sub(e.command, 1, 11) == '/pullToggle') then
        additionalOutput = string.gsub(e.command, '/pullToggle', '')
        e.blocked = true;
        isActive = true;
    end
end);

--[[
* event: packet_in
* desc : Event called when the addon is processing incoming packets.
--]]
ashita.events.register('packet_in', 'packet_in_cb', function (e)
    -- return early if not enabled
    if not isActive then
        return;
    end

    -- Packet: Zone Enter / Zone Leave
    if (e.id == 0x000A or e.id == 0x000B) then
        checker.widescan:clear();
        return;
    end

    -- Packet: Message Basic
    if (e.id == 0x0029) then
        local p1    = struct.unpack('l', e.data, 0x0C + 0x01); -- Param 1 (Level)
        local p2    = struct.unpack('L', e.data, 0x10 + 0x01); -- Param 2 (Check Type)
        local m     = struct.unpack('H', e.data, 0x18 + 0x01); -- Message (Defense / Evasion)

        -- Obtain the target entity..
        local target = struct.unpack('H', e.data, 0x16 + 0x01);
        local entity = GetEntity(target);
        if (entity == nil) then
            return;
        end

        -- Ensure this is a /check message..
        if (m ~= 0xF9 and (not checker.conditions:haskey(m) or not checker.types:haskey(p2))) then
            return;
        end

        -- Obtain the string form of the conditions and type..
        local c = checker.conditions[m];
        local t = checker.types[p2];

        -- Obtain the level override if needed..
        if (p1 <= 0) then
            local lvl = checker.widescan[target];
            if (lvl ~= nil) then
                p1 = lvl;
            end
        end

        -- Mark the packet as handled..
        e.blocked = true;

        local level = p1 > 0 and tostring(p1) or '???'
        local type;

        if (m == 0xF9) then
            type = 'Impossible to gauge!'
        else
            type = t
        end

        -- print to party
        if isActive then
            local output = string.format(
                '/p <Pulling> %s %s (Lv. %s) %s%s',
                entity.Name,
                string.char(0x81, 0xA8),
                p1,
                type,
                additionalOutput
            ) 
            AshitaCore:GetChatManager():QueueCommand(0, output);
            isActive = false;
        end
        return;
    end

    -- Packet: Widescan Results
    if (e.id == 0x00F4) then
        local idx = struct.unpack('H', e.data, 0x04 + 0x01);
        local lvl = struct.unpack('b', e.data, 0x06 + 0x01);

        checker.widescan[idx] = lvl;
        return;
    end
end);
