-- Загрузка библиотеки интерфейса (например, Orion Library)
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создание главного окна с новым названием
local Window = OrionLib:MakeWindow({
    Name = "NekoHub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "NekoHubConfig"
})

-- Создаем только нужные вкладки (без Troll Fun, Free anims и Fling Players)
local MainTab = Window:MakeTab({
    Name = "Анимации",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Пример секции и кнопки во вкладке
MainTab:AddSection({
    Name = "Основные анимации"
})

MainTab:AddButton({
    Name = "Включить танец",
    Callback = function()
        print("Анимация активирована!")
    end	
})

-- Инициализация интерфейса
OrionLib:Init()
