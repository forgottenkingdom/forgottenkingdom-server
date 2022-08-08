return {
    Character = {
        "Position", -- { x, y }
        "Orientation", -- { orientation }
        "Dimension", -- { width, height }
        "Hand", -- { hand = Item = { onActivate } }
        "Eye", -- { viewDistance }
        "Brain", -- Task evenement / action 
        "Intelligence", -- { intelligence }
        "Force", -- { force }
        "Speed", -- { speed, maxSpeed }
        "Agility", -- { agility }
        "Energy", -- { energy }
        "Life", -- { life }
        "Fame", -- { fame }
        "Wallet", -- { wallet = number }
        "Clan", -- { clan = string }
        "Quest", -- { quests = Quest }
        "Name", -- { name }
    },
    Projectile = {
        "Position",
        "Orientation",
        "Dimension",
        "Speed",
        "Force",
        "Distance",
        "Owner"
    },
    Player = {
        "Position", -- { x, y }
        "Orientation", -- { orientation }
        "Dimension", -- { width, height }
        "Hand", -- { hand = Item = { onActivate } }
        "Eye", -- { viewDistance }
        "Intelligence", -- { intelligence }
        "Force", -- { force }
        "Speed", -- { speed, maxSpeed }
        "Agility", -- { agility }
        -- "Energy", -- { energy }
        "Life", -- { life }
        "Fame", -- { fame }
        "Wallet", -- { wallet = number }
        "Clan", -- { clan = string }
        "Quest", -- { quests = Quest }
        "Shield", -- { activated }
        "Name", -- { name }
    }
}