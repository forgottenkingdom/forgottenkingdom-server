local World = require(_G.engineDir .. "world")
local RealmWorld = require(_G.libDir .. "middleclass")("RealmWorld", World)

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Systems
-- local DeathSystem       = require(_G.baseDir .. "game.systems.system-death")
-- local WorldBossSystem   = require(_G.baseDir .. "game.systems.system-world_boss")
-- local MotherSystem      = require(_G.baseDir .. "game.systems.system-mother")
-- local EntityAiSystem    = require(_G.baseDir .. "game.systems.system-entity_ai")
local DestroySystem     = require(_G.baseDir .. "game.systems.system-destroy")
local ProjectileSystem  = require(_G.baseDir .. "game.systems.system-projectile")
local WorldLimitSystem  = require(_G.baseDir .. "game.systems.system-world_limit")
local NatureSystem  = require(_G.baseDir .. "game.systems.system-nature")

function RealmWorld:initialize()
    World.initialize(self)

    self.width = 2000
    self.height = 2000
    -- self:addSystem(DeathSystem:new(self))
    -- self:addSystem(WorldBossSystem:new(self))
    -- self:addSystem(MotherSystem:new(self))
    -- self:addSystem(EntityAiSystem:new(self))
    
    self:addSystem(ProjectileSystem:new(self))
    self:addSystem(NatureSystem:new(self))
    self:addSystem(WorldLimitSystem:new(self))
    self:addSystem(DestroySystem:new(self))
end

return RealmWorld