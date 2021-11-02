local equipment = {[15] = {id = 0}, [8] = {id = 0},  [7] = {id = 0}, [6] = {id = 10690}, [5] = {id = 0}, [4] = {id = 23062},  [3] = {id = 0}, [0] = {id = 0}, }--require('equipment')

local slots = {
    main = 0,
    sub = 1,
    range = 2,
    ammo = 3,
    head = 4,
    body = 5,
    hands = 6,
    legs = 7,
    feet = 8,
    neck = 9,
    waist = 10,
    lear = 11,
    rear = 12,
    lring = 13,
    rring = 14,
    back = 15,
}


local function build_modifiers(modifiers, modifing_gear, other)
    for slot, gear in pairs(modifing_gear) do
        modifier = gear[equipment[slot].id]
        if modifier then
            modifiers[modifier.type][modifier.precedence] = modifiers[modifier.type][modifier.precedence] + modifier.value
        end
    end 
    if other then
        for _, v in pairs(other) do
            modifiers[other.type][other.precedence] = modifiers[other.type][other.precedence] + other.value
        end
    end
end


local rules = {job_abilities = {}, spells = {}}
rules.job_abilities[16] = function(modifiers)
    local mighty_strikes = {
        [slots.hands] = {
            [10690] = {type = 'additive', precedence = 1, value = 15}, --Warrior's Mufflers +2
            [26976] = {type = 'additive', precedence = 1, value = 15}, --Agoge Mufflers
            [26977] = {type = 'additive', precedence = 1, value = 15}, --Agoge Mufflers +1
        },
    }
    build_modifiers(modifiers, mighty_strikes)
end

rules.job_abilities[31] = function(modifiers)
    local berserk = {
        [slots.main] = {
            [20678] = {type = 'additive', precedence = 1, value = 15}, -- Firangi
            [20842] = {type = 'additive', precedence = 1, value = 15}, -- Reikiono
            [20845] = {type = 'additive', precedence = 1, value = 20}, -- Instigator
        },

        [slots.feet] = {
            [27328] = {type = 'additive', precedence = 1, value = 15}, -- Agoge Calligae
            [27329] = {type = 'additive', precedence = 1, value = 20}, -- Agoge Calligae +1
        },

        [slots.body] = {
            [27807] = {type = 'additive', precedence = 1, value = 10}, -- Pummeler's Lorica
            [27828] = {type = 'additive', precedence = 1, value = 14}, -- Pummeler's Lorica +1
            [23107] = {type = 'additive', precedence = 1, value = 16}, -- Pummeler's Lorica +2
            [23442] = {type = 'additive', precedence = 1, value = 18}, -- Pummeler's Lorica +3
        },

        [slots.back] = {
            [26246] = {type = 'additive', precedence = 1, value = 15}, -- Cichol's Mantle
        },
    }
    build_modifiers(modifiers, berserk)
end

rules.spells[108] = function(modifiers, target) -- Regen
    local gear = {
        [slots.main] = {
            [21175] = {type = 'additive', precedence = 0, value = 12}, -- Coeus
        },
        [slots.head] = {
            [27787] = {type = 'additive', precedence = 0, value = 20}, -- Runeist Bandeau
            [27706] = {type = 'additive', precedence = 0, value = 21}, -- Runeist Bandeau +1
            [23062] = {type = 'additive', precedence = 0, value = 24}, -- Runeist Bandeau +2
            [23397] = {type = 'additive', precedence = 0, value = 27}, -- Runeist Bandeau +3
        },
        [slots.hands] = {
            [11206] = {type = 'additive', precedence = 0, value = 9},  -- Orison Mitts +1
            [11106] = {type = 'additive', precedence = 0, value = 18}, -- Orison Mitts +2
            [27056] = {type = 'additive', precedence = 0, value = 20}, -- Ebers Mitts
            [27057] = {type = 'additive', precedence = 0, value = 22}, -- Ebers Mitts +1
        },
        [slots.legs] = {
            [28092] = {type = 'additive', precedence = 0, value = 15}, -- Theophany Pantaloons
            [28113] = {type = 'additive', precedence = 0, value = 18}, -- Theophany Pantaloons +1
            [23243] = {type = 'additive', precedence = 0, value = 21}, -- Theophany Pantaloons +2
            [23578] = {type = 'additive', precedence = 0, value = 24}, -- Theophany Pantaloons +3
        },
        [slots.back] = {
            [26265] = {type = 'additive', precedence = 0, value = 15}, -- Lugh's Cape
        },
    }

    local other = {}


    build_modifiers(modifiers, gear, other)
end
rules.spells[110] = rules.spells[108] -- Regen II
rules.spells[111] = rules.spells[108] -- Regen III
rules.spells[477] = rules.spells[108] -- Regen IV
rules.spells[504] = rules.spells[108] -- Regen V

rules.spells.skills[36] = function(modifiers, target, id) -- Enhancing Magic
    local prepentuance = 0
    local rdm_empyrean_count = 0
    
    local gear = {
        [slots.main] = {
            [22055] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Oranyan
        },
        [slots.sub] = {
            [26419] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Ammurapi Shield
        },
        [slots.body] = {
            [27891] = {type = 'multiplicative', precedence = 1, value = 0.09}, -- Shabti Cuirass
            [27892] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Shabti Cuirass +1
        },
        [slots.hands] = {
            [27947] = {type = 'multiplicative', precedence = 1, value = 0.15}, -- Atrophy Gloves
            [27968] = {type = 'multiplicative', precedence = 1, value = 0.16}, -- Atrophy Gloves +1
            [23178] = {type = 'multiplicative', precedence = 1, value = 0.18}, -- Atrophy Gloves +2
            [23513] = {type = 'multiplicative', precedence = 1, value = 0.20}, -- Atrophy Gloves +3
            [28034] = {type = 'multiplicative', precedence = 1, value = 0.05}, -- Dynasty Mitts
        },
        [slots.legs] = {
            [27194] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Futhark Trousers
            [27195] = {type = 'multiplicative', precedence = 1, value = 0.20}, -- Futhark Trousers +1
            [23285] = {type = 'multiplicative', precedence = 1, value = 0.25}, -- Futhark Trousers +2
            [23620] = {type = 'multiplicative', precedence = 1, value = 0.30}, -- Futhark Trousers +3
        },
        [slots.feet] = {
            [11248] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Estoqueur's Houseaux +1
            [11148] = {type = 'multiplicative', precedence = 1, value = 0.20}, -- Estoqueur's Houseaux +2
            [27419] = {type = 'multiplicative', precedence = 1, value = 0.25}, -- Lethargy Houseaux
            [27420] = {type = 'multiplicative', precedence = 1, value = 0.30}, -- Lethargy Houseaux +1
            [23310] = {type = 'multiplicative', precedence = 1, value = 0.05}, -- Theo. Duckbills +2
            [23645] = {type = 'multiplicative', precedence = 1, value = 0.10}, -- Theo. Duckbills +3
        },
        [slots.back] = {
            [16204] = {type = 'multiplicative', precedence = 1, value = 0.1}, -- Estoqueur's Cape
            [26250] = {type = 'multiplicative', precedence = 1, value = 0.2}, -- Sucellos's Cape
        },
    }
    {11068, 26748, 26749, 26782, 26783}
    buffs = {
        [469] = {type = 'multiplicative', precedence = 2, value = 2}, -- Perpetuance Term needs checking with some weird combos of JA/Gifts
        [534] = {type = 'multiplicative', precedence = 4, value = -0.50}, -- Embolden Term needs to be verified.
    }
    if id ~- 40 and id ~= 41 then
        buffs[419] = {type = 'multiplicative', precedence = 2, value = 3}, -- Composure
    end
end

local function modify_duration(catagory, id, target, duration)
    local modifiers = {
        additive = {
            [0] = 0,
            [1] = 0,
            [2] = 0,
            [3] = 0,
            [4] = 0,
        },
        multiplicative = {
            [0] = 1,
            [1] = 1,
            [2] = 1,
            [3] = 1,
            [4] = 1,
        }
    }

    local checks = rules[catagory]
    if checks[id] then
        checks[id](modifiers, target)
    end
    if checks.skills and  checks.skills[skill_id] then
        checks.skills[skill_id](modifiers, target, id)
    end
    
    for i = 0, 4 do
        duration = (duration +  modifiers.additive[i]) * modifiers.multiplicative[i]
    end

    return duration
end

print(modify_duration('job_abilities', 16, 1, 30))
print(modify_duration('spells', 108, 1, 60))

items[10690] = { -- Warrior's Mufflers +2
    -- this is the list of its effects
    job_abilities = {
        [16] = {type = 'additive', precedence = 0, value = 15},
    },
}
items[26894] = {
    spells = {
        [108] = {type = 'additive', precedence = 0, value = 12},
    },
}
