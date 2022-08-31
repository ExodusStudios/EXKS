local krist = {}

local function incrementId()
    krist.id = krist.id + 1
end

local function checkTable(table) --the code editor yells at me so this hopefully supresses it
    if not next(table) then
        return true
    end
    return false
end

function krist:init(key)
    assert(type(key) == "string" or type(key) == "nil", "bad argument #1 to 'krist:init' (string expected, got " .. type(key) .. ")") -- haha funny type checking

    if key == nil then key = "" end

    local response = http.post("https://krist.dev/ws/start", key)
    response = textutils.unserialiseJSON(response)

    print(response.url)

    self.socket = http.websocket(response.url)
    self.id = 0
    self.key = key
end

function krist:selfAccountDetails()
    local data = {id = self.id, type = "me"}
    self.socket.send()
    local resp = self.socket.receive(5)
    local v
    assert(resp == nil, "websocket timed out or server was detonated by Al-Queda")
    assert(checkTable(resp), "for some reason the table is just nil")
    if resp["ok"] == true and not resp["type"] == "keepalive" then
        v = {ok = true, balance = resp["balance"], resp["address"]}
    else
        v = {ok = false}
    end
    incrementId()
    return v
end

function krist:makeTransaction(recipient, amount) -- i want to access self so : instead of . -- and also makeTransaction instead --understood -sqz
    local v

    local data = {id = self.id, type = "make_transaction", to = recipient, amount = amount}
    self.socket.send(textutils.serializeJSON(data))
    local resp = self.socket.receive(5) -- receive instead of recieve
    assert(checkTable(resp), "for some reason the table is just nil")
    assert(resp == nil, "websocket timed out or server was detonated by Al-Queda")
    if resp["ok"] == true and not resp["type"] == "keepalive" then --ignore this warning
        v = { ok = true, to = resp["sent_name"], value = resp["value"] }
    else
        v = { ok = false }
    end

    incrementId()
    return v
end

return krist

-- Comment section
--[[
    SQZ Only

]]
--[[
    Sponge Only

]]
--[[
    Compec Only

]]
