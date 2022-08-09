_G.baseDir      = (...):match("(.-)[^%.]+$")
_G.libDir       = _G.baseDir .. "lib."
_G.engineDir    = _G.libDir .. "engine."

_G.gameDir      = _G.baseDir .. "game."
_G.componentsDir = _G.gameDir .. "components."
_G.entitiesDir  = _G.gameDir .. "entities."
_G.systemsDir   = _G.gameDir .. "systems."
_G.worldsDir   = _G.gameDir .. "worlds."

local random = math.random
_G.uuid = function ()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

_G.Server = {
    Clients = {},
    getClientByTcp = function (self, clientid)
        local uid = nil
        for k, v in pairs(self.Clients) do
            if v.tcp == clientid then
                uid = k
            end
        end
        return uid
    end,
    getClientByUdp = function (self, clientid)
        local uid = nil
        for k, v in pairs(self.Clients) do
            if v.udp == clientid then
                uid = k
            end
        end
        return uid
    end,
    Tcp = require(_G.libDir .. "tcp_server"):new(),
    Udp = require(_G.libDir .. "udp_server"):new()
}
local JSON = require(_G.libDir .. "json")

_G.bitser = require(_G.libDir .. "bitser")
_G.DB = {}

local entities, entitiesError = love.filesystem.read("game/entities/entities.json")
_G.DB.Entities = JSON:decode(entities)

local handshake = "00000"
_G.RealmWorld = require(_G.worldsDir .. "world-realm"):new()
local PlayerEntity = require(_G.entitiesDir .. "entity-player")
local ProjectileEntity = require(_G.entitiesDir .. "entity-projectile")

_G.Server.Tcp:listen(8080)
_G.Server.Udp:listen(8080)

_G.Server.Tcp.handshake = handshake
_G.Server.Udp.handshake = handshake

_G.Server.Udp.callbacks.recv = function (data, clientid)
    -- print("[".. tostring(clientid) .. "]: " .. packet.id)
    local packet = bitser.loads(data)

    if packet.id == "connection" then
        if type(_G.Server.Clients[packet.uuid]) ~= "table" then
            _G.Server.Clients[packet.uuid] = {}
            _G.Server.Clients[packet.uuid].udp = clientid
        else
            _G.Server.Clients[packet.uuid].udp = clientid
        end
        print("[UDP][".. packet.uuid .."]: connected")
    elseif packet.id == "disconnection" then
        _G.Server.Clients[packet.uuid].udp = nil
        print("[UDP][".. packet.uuid .."]: disconnected")
    elseif packet.id == "player_move" then
        local uid = _G.Server:getClientByUdp(clientid)
        local entity = _G.RealmWorld:getEntityById(uid)
        if entity then
            local tranformComponent = entity:getComponent("Position")
            if packet.cmd == "up" then
                tranformComponent.position.y = tranformComponent.position.y - 5
            elseif packet.cmd == "down" then
                tranformComponent.position.y = tranformComponent.position.y + 5
            elseif packet.cmd == "left" then
                tranformComponent.position.x = tranformComponent.position.x - 5
            elseif packet.cmd == "right" then
                tranformComponent.position.x = tranformComponent.position.x + 5
            end
        end    
    elseif packet.id == "player_shoot" then
        local uid = _G.Server:getClientByUdp(clientid)
        local entity = _G.RealmWorld:getEntityById(uid)
        if entity then
            entity:shoot()
        end
    elseif packet.id == "player_pvp" then
        local uid = _G.Server:getClientByUdp(clientid)
        local entity = _G.RealmWorld:getEntityById(uid)
        if entity then
            entity:getComponent("Player").pvp = not entity:getComponent("Player").pvp
        end
    elseif packet.id == "player_orientation" then
        local uid = _G.Server:getClientByUdp(clientid)
        local entity = _G.RealmWorld:getEntityById(uid)
        local m = packet.data
        if entity then
            local position = entity:getComponent("Position").position
            local dimension = entity:getComponent("Dimension")
            local orientation = entity:getComponent("Orientation").orientation
            entity:getComponent("Orientation").orientation = math.atan2(m.y - position.y, m.x - position.x + dimension.width / 2)
        end
    elseif packet.id == "player_shield" then
        local uid = _G.Server:getClientByUdp(clientid)
        local entity = _G.RealmWorld:getEntityById(uid)
        if entity then
            local mouse = packet.data
            local shield = entity:getComponent("Shield")
            if shield then
                print(shield)
                shield.activated = packet.data
            end
        end
    end
end

_G.Server.Udp.callbacks.connect = function (clientid)
    print("[UDP][".. tostring(clientid) .. "]: connected")
end

_G.Server.Udp.callbacks.disconnect = function (clientid)
    -- delete entity with clientId
    print("[UDP][".. tostring(clientid) .. "]: disconnected")
end

_G.Server.Tcp.callbacks.recv = function (data, clientid)
    local packet = _G.bitser.loads(data)
    print(packet.id)
    if packet.id == "connection" then
        if type(_G.Server.Clients[packet.uuid]) ~= "table" then
            _G.Server.Clients[packet.uuid] = {}
            _G.Server.Clients[packet.uuid].tcp = clientid
        else
            _G.Server.Clients[packet.uuid].tcp = clientid
        end
        print("[TCP][".. packet.uuid .."]: connected")
        _G.Server.Tcp:send(_G.bitser.dumps({
           id = "world_load",
           world = _G.RealmWorld:toNbt()
        }), clientid)
    elseif packet.id == "disconnection" then
        _G.Server.Clients[packet.uuid].tcp = nil
        print("[TCP][".. packet.uuid .."]: disconnected")
    elseif packet.id == "request_player_entity" then
        local clans = { "alliance", "horde", "steampunk" }
        for k, v in pairs(_G.Server.Clients) do
            if v.tcp == clientid then
                local entity = RealmWorld:getEntityById(k)
                if not entity then
                _G.RealmWorld:addEntity(PlayerEntity:new(k, {
                    position = { x = 100, y = 100 },
                    orientation = 0,
                    dimension = { width = 32, height = 32 },
                    hand = nil,
                    viewDistance = 500,
                    intelligence = 10,
                    force = 10,
                    speed = 50,
                    agility = 10,
                    life = 100,
                    fame = 0,
                    shield = 100,
                    wallet = 100,
                    clan = { name = clans[love.math.random(1, #clans)], fame = 0 },
                    quest = nil,
                    name = "Vincent"
                }))
                end
            end 
        end
    end
end

_G.Server.Tcp.callbacks.connect = function (clientid )
    print("[TCP][".. tostring(clientid) .. "]: connected")
end

_G.Server.Tcp.callbacks.disconnect = function (clientid)
    print("[TCP][".. tostring(clientid) .. "]: disconnected")
end

function love.update (dt)
    _G.Server.Tcp:update(dt)
    _G.Server.Udp:update(dt)
    _G.RealmWorld:update(dt)
end

function love.quit()
    _G.Server.Tcp:close()
    _G.Server.Udp:close()
end