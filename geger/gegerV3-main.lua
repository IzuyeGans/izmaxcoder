print("Script Geiger V3 Loaded")
print("-- IzzDevs --")
--==================================================================================================================================================================================================================
--==================================================================================================================================================================================================================
--==================================================================================================================================================================================================================
geiger_items = { --don't change
    6416, 3196, 1500, 1498, 2806, 2804, 8270, 8272, 8274, 4676, 4678, 4680, 4682, 4652, 4650, 4648, 4646, 11186, 10086, 10084, 2206, 2244, 2246, 2242, 2248, 2250, 3792, 3306, 4654, 3204,
}

-- EMOJIS
whiteC   = "<:whitec:1098948680918237208>"
blackC   = "<:blackc:1098948646470426654>"
greenC   = "<:greenc:1098948661993537566>"
redC     = "<:redc:1098948715798081547>"
blueC    = "<:bluec:1098948697917767772>"
geigerC  = "<:geigerc:1098948635565232230>" --geiger charger
arrow    = "<:ar:1087310906817527818>"
rad_chem = "<:rad:1109044027107586118>"
blackS	 = "<:blacks:1119468621144531025>"
blueS 	 = "<:blues:1119468623501725746>"
greenS	 = "<:greens:1119468627658280971>"
orangeS	 = "<:oranges:1119468637313564794>"
purpleS	 = "<:purples:1119468639305863249>"
redS 	 = "<:reds:1119468642669699132>"
whiteS 	 = "<:whites:1119468648050987122>"
starF	 = "<:starf:1119468644250943619>"
nuclearF = "<:nuclearf:1119468633714864128>"
wls      = "<:wl:994245201826697226>"
--
OnlineMoji  = "<:online:858271078890864690>"
OfflineMoji = "<:offline:858271448493981696>"

-- Uptime
startT = os.time()
function SecondTT(seconds)
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end


function webHookEmbed(whMsID, title, desc)

    if not webhook_enable then return end

    local script = [[
        $webHookUrl = "]]..whURL.."/messages/"..whMsID..[["
        [System.Collections.ArrayList]$embedArray = @()
        $color = Get-Random -Minimum 0 -Maximum 16777215
        $title = ']]..title..[['
        $description = ']]..desc..[['
        $embedObject = [PSCustomObject]@{
            color = $color
            title = $title
            description = $description
            footer      = [PSCustomObject]@{
                text    = ']].."Last Update : "..os.date("%H:%M:%S").."\n"..[[IzzDevs'
                icon_url = "https://ik.imagekit.io/izdevs/izuye.png"
            }
        }
        $embedArray.Add($embedObject)
        $payload = [PSCustomObject]@{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    local pipe = io.popen('powershell -windowstyle Hidden -command -', 'w')
    pipe:write(script)
    pipe:close()
end


function getposx()

    return getBot():getWorld():getLocal().posx
end

function getposy()

    return getBot():getWorld():getLocal().posy
end

function getGeiger(bot, index)

    if not autoGet_geiger then return end

    if not bot:isInWorld() then
        sleep(500)
        bot:warp(storage_world[index])
        sleep(warp_interval)
    end

    if bot:getInventory():getItemCount(2204) > 0 or bot:getInventory():getItemCount(2286) > 0 then return end

    if getBot():getWorld().name ~= storage_world[index]:match("(.+)|"):upper() then
        sleep(500)
        bot:warp(storage_world[index])
        sleep(warp_interval)
    end

    if getBot():getWorld():getTile(math.floor(getposx()/32), math.floor(getposy()/32)).fg == 6 then
        sleep(500)
        bot:warp(storage_world[index])
        sleep(warp_interval)
    end

    while getBot():getInventory():getItemCount(2204) == 0 do
        for _, obj in pairs(getBot():getWorld():getObjects()) do
            if obj.id == 2204 then
                getBot().collect_range = 2
                getBot().auto_collect = true
                getBot():findPath(math.floor(obj.x/32), math.floor(obj.y/32))
                sleep(5000)

                while getBot():getInventory():getItemCount(2204) == 0 do sleep(1000) end
            end
        end
    end

    if getBot():getInventory():getItemCount(2204) > 1 then
        getBot().auto_collect = false
        sleep(4000)
        bot:drop(2204, getBot():getInventory():getItemCount(2204) - 1)
        sleep(4000)
        bot:wear(2204)
        sleep(3000)
    end
end

function startGeiger(bot, index)

    if bot.status ~= 1 then return end

    if bot:getWorld().name ~= geiger_worlds[index]:upper() then
        sleep(500)
        bot:warp(geiger_worlds[index])
        sleep(warp_interval)
    end

    if not bot:getWorld():getLocal() then
        sleep(200)
        return
    end

    if bot:getInventory():getItemCount(2204) == 0 then
        return
    end

    if not bot:getInventory():getItem(2204).isActive then
        bot:wear(2204)
        sleep(3000)
    end

    if bot:getWorld().name == geiger_worlds[index]:upper() and bot:getInventory():getItemCount(2204) > 0 then
        bot.auto_geiger.enabled = true
    end

end



function checkInventory(bot, index)

    if bot.status ~= 1 then return end

    if trash_enable then
        for _, trash_item in pairs(trash) do
            if bot:getInventory():getItemCount(trash_item) > 0 then
                bot.auto_geiger.enabled = false
                if trash_webhook then
                webHookEmbed(whMsData,bot.name, "Trashes "..getInfo(bot:getInventory():getItem(trash_item).id).name)
                end
                sleep(4000)
                bot:trash(trash_item, bot:getInventory():getItemCount(trash_item))
                sleep(4000)

            end
        end
    end

    for _, item in pairs(geiger_items) do
        if bot:getInventory():getItemCount(item) > 0 then
            bot.auto_geiger.enabled = false
            sleep(500)
            getBot().auto_collect = false
            sleep(500)
            Drop(item, index)
            bot:findPath(drop_location_X, drop_location_Y)
            sleep(4300)
        end
    end
end

function storeDatabase(rwrd, rwrdCnt)
    local client = HttpClient.new()
    local wordlName = getBot():getWorld().name
    client.method = Method.post
    client.url = "https://izz.biz.id/gt/data/geiger_data.php?botName="..tostring(getBot().name).."&reward="..tostring(rwrd).."&rewardCount="..tostring(rwrdCnt).."&worldName="..tostring(worldName).."&key="..izz_key
    response = client:request()
    print(response.body)
end

function Drop(item, index)


    if getBot():getWorld().name ~= storage_world[index]:match("(.+)|"):upper() then
        sleep(500)
        getBot():warp(storage_world[index])
        sleep(warp_interval)
    end

    if not getBot():getWorld():getLocal() then
        sleep(200)
        return
    end

    if getBot():getWorld():getTile(math.floor(getposx()/32), math.floor(getposy()/32)).fg == 6 then
        sleep(500)
        getBot():warp(storage_world[index])
        sleep(warp_interval)
    end

    sleep(5000)

    local stuff_items = {8274, 2806, 2804, 1500, 1498, 8270, 8272, 6416, 3196}
    local crystal_items = {2242,2244,2246,2248,2250,4654,2204}
    local notbad_items = {6416,3196,3306,2206}

    local item_found = false
    for _, item_id in pairs(crystal_items) do
        if item == item_id then
            for i = 1,1 do
                getBot():moveLeft()
                sleep(300)
            end
            item_found = true
            break
        end
    end
    if not item_found then
        for _, item_id in pairs(notbad_items) do
            if item == item_id then
                for i = 1,4 do
                    getBot():moveLeft()
                    sleep(300)
                end
                item_found = true
                break
            end
        end
    end
    if not item_found then
        for _, item_id in pairs(stuff_items) do
            if item == item_id then
                for i = 1,7 do
                    getBot():moveLeft()
                    sleep(300)
                end
                item_found = true
                break
            end
        end
    end
    if not item_found then
        for i = 1,10 do
            getBot():moveLeft()
            sleep(300)
        end
    end
    sleep(5000)
    getBot():drop(item, getBot():getInventory():getItemCount(item))

    storeDatabase(item, getBot():getInventory():getItemCount(item))
    sleep(4000)

    green_crystal  = 0
    blue_crystal   = 0
    red_crystal    = 0
    white_crystal  = 0
    black_crystal  = 0
    geiger_charger = 0
    geiger_counter = 0
    radioact_chem  = 0
    black_stuff    = 0
    blue_stuff     = 0
    green_stuff    = 0
    orange_stuff   = 0
    purple_stuff   = 0
    red_stuff      = 0
    white_stuff    = 0
    star_fuel      = 0
    nuclear_fuel   = 0


    for id, count in pairs(getBot():getWorld().growscan:getObjects()) do

        if id == 2244 then green_crystal  = count end
        if id == 2246 then blue_crystal   = count end
        if id == 2242 then red_crystal    = count end
        if id == 2248 then white_crystal  = count end
        if id == 2250 then black_crystal  = count end
        if id == 4654 then geiger_charger = count end
        if id == 2204 then geiger_counter = count end
        if id == 2206 then radioact_chem  = count end
        --
        if id == 8274 then black_stuff    = count end
        if id == 2806 then blue_stuff     = count end
        if id == 2804 then green_stuff    = count end
        if id == 1500 then orange_stuff   = count end
        if id == 1498 then purple_stuff   = count end
        if id == 8270 then red_stuff      = count end
        if id == 8272 then white_stuff    = count end
        if id == 6416 then star_fuel      = count end
        if id == 3196 then nuclear_fuel   = count end


    end

    function countValue()
        price = {
            red_crystal = 2,
            green_crystal = 0.33,
            blue_crystal = 2,
            white_crystal = 83,
            black_crystal = 70,
            geiger_charger = 135,
            --
            radioact_chem = 0.33,
        }
    
        local total_value = 0
        total_value = total_value + (red_crystal * price.red_crystal)
        total_value = total_value + (green_crystal * price.green_crystal)
        total_value = total_value + (blue_crystal * price.blue_crystal)
        total_value = total_value + (white_crystal * price.white_crystal)
        total_value = total_value + (black_crystal * price.black_crystal)
        total_value = total_value + (geiger_charger * price.geiger_charger)
        total_value = total_value + (radioact_chem * price.radioact_chem)

        return total_value
    end
    
    local total_value = math.floor( countValue() )

    --print("Total Value : "..total_value)

    gs_text = (string.format("**%s : %s\n", rad_chem, radioact_chem)..string.format("%s : %s\n",greenC, green_crystal)..string.format("%s : %s\n",blueC, blue_crystal)..string.format("%s : %s\n",redC, red_crystal)..string.format("%s : %s\n",whiteC, white_crystal)..string.format("%s : %s\n",blackC, black_crystal)..string.format("%s : %s**\n", geigerC, geiger_charger).."\n.\n**=== [ Random Stuff ] === **\n"..string.format("**%s : %s\n", redS, red_stuff)..string.format("%s : %s\n", purpleS, purple_stuff)..string.format("%s : %s\n", orangeS, orange_stuff)..string.format("%s : %s\n", blueS, blue_stuff)..string.format("%s : %s\n", greenS, green_stuff)..string.format("%s : %s\n", whiteS, white_stuff)..string.format("%s : %s\n", blackS, black_stuff)..string.format("%s : %s\n", starF, star_fuel)..string.format("%s : %s**\n", nuclearF, nuclear_fuel).."\n.\n**[ Total Value : "..total_value..wls.." ]**".."\n**Uptime** : "..SecondTT(os.difftime(os.time(), startT)))

    webHookEmbed(whMsData, "IzzDevs", gs_text)

end



function main()

    --if script_id == 1 then
      --  webHookEmbed("AUTO GEIGER", "running..")
    --end

    if afk_on_main then
        getBot().auto_geiger.afk = true
    end

    save_index = 1
    if script_id % #storage_world == 0 then
        save_index = #storage_world
    else
        save_index = script_id % #storage_world
    end

    getGeiger(getBot(), save_index)
    
    botOnlineSir = false
    while true do
        
        local bot = getBot()

        index = 1
        if script_id % #geiger_worlds == 0 then
            index = #geiger_worlds
        else
            index = script_id % #geiger_worlds
        end

        save_index = 1
        if script_id % #storage_world == 0 then
            save_index = #storage_world
        else
            save_index = script_id % #storage_world
        end
        
        checkInventory(bot, save_index)
        startGeiger(bot, index)

        sleep(30000)
    end
end

main()
