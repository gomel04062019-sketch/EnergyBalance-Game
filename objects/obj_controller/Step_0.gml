// === 1. ПАУЗА И МЕНЮ ===
if (keyboard_check_pressed(vk_escape)) global.is_paused = !global.is_paused;
if (global.is_paused) exit;
if (global.game_state != "playing") exit;

if (keyboard_check_pressed(ord("T"))) global.tech_menu_open = !global.tech_menu_open;
if (global.tech_menu_open || global.quest_journal_open) exit;

// === 2. ЛОГИКА КВЕСТОВ ===
switch (global.quest_stage) {
    case 1:
        global.quest_text = "Задание 1: Постройте 3 дома";
        if (instance_number(obj_house) >= 3) global.quest_stage = 2;
        break;
    case 2:
        global.quest_text = "Задание 2: Выработайте 50 МВт энергии";
        if (global.total_energy >= 50) global.quest_stage = 3;
        break;
    case 3:
        global.quest_text = "Задание 3: Накопите 500$";
        if (global.money >= 500) global.quest_stage = 4;
        break;
    case 4:
        global.quest_text = "Задание 4: Откройте Технологии (T) и купите Утепление домов";
        if (global.upg_insulation) global.quest_stage = 5;
        break;
    case 5:
        global.quest_text = "Задание 5: Достигните экологии 80% и накопите 1000$";
        if (global.eco_score >= 80 && global.money >= 1000) global.game_state = "win";
        break;
}

if (global.quest_stage != prev_quest_stage) {
    prev_quest_stage = global.quest_stage;
    global.quest_timer = 15 * 60; 
}
if (global.quest_timer > 0) global.quest_timer -= 1;

// === 4. ВЫБОР ЗДАНИЯ И СТРОИТЕЛЬСТВО ===
var mx = device_mouse_x_to_gui(0); 
var my = device_mouse_y_to_gui(0);
var ui_y = display_get_gui_height() - 95; 

if (mouse_check_button_pressed(mb_left)) {
    // 1. КЛИК ПО НИЖНИМ КНОПКАМ
    if (my > ui_y) {
        if (mx > 20 && mx < 170)  { global.build_menu_open = !global.build_menu_open; global.build_category = "house"; }
        else if (mx > 190 && mx < 340) { global.build_menu_open = !global.build_menu_open; global.build_category = "stations"; }
        else if (mx > 360 && mx < 510) { global.build_menu_open = !global.build_menu_open; global.build_category = "decor"; }
        
        if (instance_exists(obj_ghost)) instance_destroy(obj_ghost);
        exit; 
    }

        // 2. КЛИК ПО ОТКРЫТОМУ МЕНЮ (по клеточкам)
    if (global.build_menu_open) {
        var menu_x = display_get_gui_width()/2 - 350;
        var menu_y = ui_y - 260; // Подняли выше
        var menu_w = 700;
        var menu_h = 240; // Увеличили высоту меню
        
        // Параметры клеточек (должны совпадать с Draw GUI)
        var cell_w = 210;
        var cell_h = 200; // Увеличили высоту клеточки
        var cell_y = menu_y + 20;
        var start_x = menu_x + 20;
        var gap = 15;
        
        if (my < menu_y || my > menu_y + menu_h || mx < menu_x || mx > menu_x + menu_w) {
            global.build_menu_open = false; 
        } else {
            if (my > cell_y && my < cell_y + cell_h) {
                if (global.build_category == "house") {
                    if (mx > start_x + cell_w + gap && mx < start_x + cell_w*2 + gap) { build_mode = "house"; global.build_menu_open = false; }
                } else if (global.build_category == "stations") {
                    if (mx > start_x && mx < start_x + cell_w) { build_mode = "tec"; global.build_menu_open = false; }
                    else if (mx > start_x + cell_w + gap && mx < start_x + cell_w*2 + gap) { build_mode = "solar"; global.build_menu_open = false; }
                    else if (mx > start_x + (cell_w + gap)*2 && mx < start_x + cell_w*3 + gap*2) { build_mode = "wind"; global.build_menu_open = false; }
                }
            }
        }
        exit;
    }

    // 3. КЛИК ПО МИРУ (ПОСТРОЙКА)
    if (!global.build_menu_open && my < ui_y) {
        if (instance_exists(obj_ghost)) {
            if (obj_ghost.can_build) {
                instance_create_depth(obj_ghost.x, obj_ghost.y, 0, obj_ghost.spawn_obj);
                global.money -= obj_ghost.cost;
                instance_destroy(obj_ghost);
            }
        } else {
            var g = instance_create_depth(0, 0, 10, obj_ghost);
            switch (build_mode) {
                case "house": g.sprite_index = spr_house_1; g.spawn_obj = obj_house; g.cost = 50; break;
                case "tec":   g.sprite_index = spr_tec;   g.spawn_obj = obj_tec;   g.cost = 150; break;
                case "solar": g.sprite_index = spr_solar; g.spawn_obj = obj_solar; g.cost = 200; break;
                case "wind":  g.sprite_index = spr_wind;  g.spawn_obj = obj_wind;  g.cost = 250; break;
            }
        }
    }
}

// === 4. ПОГОДА И ЭНЕРГИЯ ===
global.day_timer += 1;
if (global.day_timer >= 300) { 
    global.day_timer = 0;
    global.is_night = !global.is_night;
    var rand_weather = irandom(2);
    if (rand_weather == 0) global.weather = "sunny";
    if (rand_weather == 1) global.weather = "cloudy";
    if (rand_weather == 2) global.weather = "windy";
}

global.total_energy = 0;
global.used_energy = 0;
global.total_pollution = 0;

with (obj_tec) { 
    global.total_energy += energy_gen; 
    if (global.upg_filter) global.total_pollution += (pollution / 2); 
    else global.total_pollution += pollution; 
}
with (obj_wind) { 
    if (global.weather == "windy") global.total_energy += energy_gen * 2;
    else global.total_energy += energy_gen;
}
with (obj_solar) {
    if (global.is_night) global.total_energy += 0;
    else if (global.weather == "cloudy") global.total_energy += energy_gen / 2;
    else global.total_energy += energy_gen;
}
with (obj_house) { 
    if (global.upg_insulation) global.used_energy += 5; 
    else global.used_energy += 10; 
}

// === 5. ЭКОНОМИКА И ЭКОЛОГИЯ ===
if (global.total_energy >= global.used_energy) {
    with (obj_house) { global.money += 0.15; } 
}
if (global.total_pollution > 0) {
    global.eco_score -= (global.total_pollution / 4000); 
} else {
    if (global.eco_score < 100) global.eco_score += 0.01; 
}
global.eco_score = clamp(global.eco_score, 0, 100);
if (global.eco_score < 50) global.money -= 0.1; 

// === 6. КАМЕРА ===
var cam = view_camera[0];
var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);
var cam_speed = 10; 

if (keyboard_check(vk_left) || keyboard_check(ord("A")))  cam_x -= cam_speed;
if (keyboard_check(vk_right) || keyboard_check(ord("D"))) cam_x += cam_speed;
if (keyboard_check(vk_up) || keyboard_check(ord("W")))    cam_y -= cam_speed;
if (keyboard_check(vk_down) || keyboard_check(ord("S")))  cam_y += cam_speed;

cam_x = clamp(cam_x, 0, room_width - camera_get_view_width(cam));
cam_y = clamp(cam_y, 0, room_height - camera_get_view_height(cam));
camera_set_view_pos(cam, cam_x, cam_y);

// === 7. СОВЕТЫ ===
global.tip_timer += 1;
if (global.tip_timer >= 900) {
    global.tip_timer = 0;
    var random_index = irandom(array_length(global.tips) - 1);
    global.current_tip = global.tips[random_index];
    global.tip_display_timer = 360; 
}
if (global.tip_display_timer > 0) global.tip_display_timer -= 1;