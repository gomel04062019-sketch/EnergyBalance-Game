// === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ===
global.money = 300;             
global.eco_score = 100;         
global.is_night = false;        
global.weather = "sunny";       
global.day_timer = 0;           
build_mode = "house";           

global.game_state = "playing";  

// === СИСТЕМА КВЕСТОВ ===
global.quest_stage = 1; 
global.quest_text = "Задание 1: Постройте 3 дома";
prev_quest_stage = global.quest_stage; 
global.quest_timer = 15 * 60; 
global.quest_journal_open = false;

// === УЛУЧШЕНИЯ (ТЕХ ДЕРЕВО) ===
global.tech_menu_open = false;
global.active_tab = "houses";   
global.upg_insulation = false;  
global.upg_filter = false;      

// === МЕНЮ СТРОИТЕЛЬСТВА ===
global.build_menu_open = false;
global.build_category = "house"; 

// === СИСТЕМА СОВЕТОВ ===
global.tips = [
    "Знаете ли вы? Замена ламп накаливания на LED экономит до 80% электроэнергии.",
    "Совет: Выключайте компьютер, когда уходите. Он тратит энергию даже в спящем режиме.",
    "Знаете ли вы? Солнечные панели ночью не вырабатывают энергию. Нужны накопители!",
    "Совет: Утепление окон помогает сэкономить до 30% энергии на отопление.",
    "Знаете ли вы? Ветряки работают только при достаточной силе ветра.",
    "Совет: Не оставляйте зарядные устройства в розетке без надобности.",
    "Знаете ли вы? ТЭЦ вырабатывают много энергии, но сильно загрязняют воздух."
];
global.current_tip = "";         
global.tip_timer = 0;            
global.tip_display_timer = 0;    
global.is_paused = false; 

// Включаем резкие пиксели
gpu_set_tex_filter(false); 

// === ГЕНЕРАЦИЯ КАРТЫ ===
instance_destroy(obj_grass);
instance_destroy(obj_water);
instance_destroy(obj_sand);

var tile_w = 64; 
var tile_h = 16; 

global.grass_x1 = 256; 
global.grass_y1 = 256;
global.grass_x2 = room_width - 256;
global.grass_y2 = room_height - 256;

var sand_padding = 64; 

// 1. Вода
for (var j = 0; j < room_height; j += tile_h) {
    for (var i = 0; i < room_width; i += tile_w) {
        var w = instance_create_depth(i, j, 1001, obj_water);
        if ((j div tile_h) mod 2 == 1) w.x += tile_w / 2;
    }
}
// 2. Песок
for (var j = global.grass_y1 - sand_padding; j < global.grass_y2 + sand_padding; j += tile_h) {
    for (var i = global.grass_x1 - sand_padding; i < global.grass_x2 + sand_padding; i += tile_w) {
        var s = instance_create_depth(i, j, 1000, obj_sand);
        if ((j div tile_h) mod 2 == 1) s.x += tile_w / 2;
    }
}
// 3. Трава
for (var j = global.grass_y1; j < global.grass_y2; j += tile_h) {
    for (var i = global.grass_x1; i < global.grass_x2; i += tile_w) {
        var g = instance_create_depth(i, j, 999, obj_grass);
        if ((j div tile_h) mod 2 == 1) g.x += tile_w / 2;
    }
}