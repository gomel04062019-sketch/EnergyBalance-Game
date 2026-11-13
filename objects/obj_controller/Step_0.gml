// === 1. ПАУЗА И F11 ===
if (keyboard_check_pressed(vk_f11)) window_set_fullscreen(!window_get_fullscreen());
if (keyboard_check_pressed(vk_escape)) global.is_paused = !global.is_paused;
if (global.is_paused) exit;
if (global.game_state != "playing") exit;

if (keyboard_check_pressed(ord("T"))) global.tech_menu_open = !global.tech_menu_open;
if (global.tech_menu_open || global.quest_journal_open) exit;

// === 2. ЛОГИКА КВЕСТОВ ===
var total_houses = instance_number(obj_house) + instance_number(obj_medium_house) + instance_number(obj_lux_house);

switch (global.quest_stage) {
    case 1: global.quest_text = "Задание 1: Постройте 3 дома"; if (total_houses >= 3) global.quest_stage = 2; break;
    case 2: global.quest_text = "Задание 2: Выработайте 50 МВт энергии"; if (global.total_energy >= 50) global.quest_stage = 3; break;
    case 3: global.quest_text = "Задание 3: Накопите 500$"; if (global.money >= 500) global.quest_stage = 4; break;
    case 4: global.quest_text = "Задание 4: Откройте Технологии (T) и купите Утепление домов"; if (global.upg_insulation) global.quest_stage = 5; break;
    case 5: global.quest_text = "Задание 5: Достигните экологии 80% и накопите 1000$"; if (global.eco_score >= 80 && global.money >= 1000) global.game_state = "win"; break;
}

if (global.quest_stage != prev_quest_stage) {
    prev_quest_stage = global.quest_stage;
    global.quest_timer = 15 * 60; 
}
if (global.quest_timer > 0) global.quest_timer -= 1;

// === 3. УПРАВЛЕНИЕ СТРОИТЕЛЬСТВОМ ===
var mx = device_mouse_x_to_gui(0); 
var my = device_mouse_y_to_gui(0);
var gui_w = display_get_gui_width();
var ui_y = display_get_gui_height() - 150; // ИСПРАВЛЕНО: панель теперь высотой 150

var btn_w = 160;
var gap = 15;
var total_w = (3 * btn_w) + (2 * gap);
var start_x = (gui_w - total_w) / 2;

// СНОС ЗДАНИЯ (ПКМ)
if (mouse_check_button_pressed(mb_right)) {
    if (instance_exists(obj_ghost)) {
        instance_destroy(obj_ghost); 
    } else if (!global.build_menu_open) {
        if (my <= ui_y) { 
            var building_to_delete = instance_position(mouse_x, mouse_y, obj_building);
            if (building_to_delete != noone) {
                global.money += floor(building_to_delete.cost / 2);
                instance_destroy(building_to_delete);
            }
        }
    }
}

// ЛЕВЫЙ КЛИК (ПОСТРОЙКА)
if (mouse_check_button_pressed(mb_left)) {
    if (my > ui_y) {
        if (mx > start_x && mx < start_x + btn_w) { global.build_menu_open = !global.build_menu_open; global.build_category = "house"; }
        else if (mx > start_x + btn_w + gap && mx < start_x + btn_w*2 + gap) { global.build_menu_open = !global.build_menu_open; global.build_category = "stations"; }
        else if (mx > start_x + (btn_w + gap)*2 && mx < start_x + btn_w*3 + gap*2) { global.build_menu_open = !global.build_menu_open; global.build_category = "decor"; }
        
        if (instance_exists(obj_ghost)) instance_destroy(obj_ghost);
        exit; 
    }

    if (global.build_menu_open) {
        var menu_x = gui_w/2 - 350;
        var menu_y = ui_y - 270; // Подняли меню строительства под новую высоту панели
        var menu_w = 700;
        var menu_h = 260; 
        
        var cell_w = 210;
        var cell_h = 210; 
        var cell_y = menu_y + 25;
        var cell_start_x = menu_x + 20;
        
        if (my < menu_y || my > menu_y + menu_h || mx < menu_x || mx > menu_x + menu_w) {
            global.build_menu_open = false; 
        } else {
            if (my > cell_y && my < cell_y + cell_h) {
                if (global.build_category == "house") {
                    if (mx > cell_start_x && mx < cell_start_x + cell_w) { build_mode = "house"; global.build_menu_open = false; }
                    else if (mx > cell_start_x + cell_w + gap && mx < cell_start_x + cell_w*2 + gap) { build_mode = "medium_house"; global.build_menu_open = false; }
                    else if (mx > cell_start_x + (cell_w + gap)*2 && mx < cell_start_x + cell_w*3 + gap*2) { build_mode = "lux_house"; global.build_menu_open = false; }
                } else if (global.build_category == "stations") {
                    if (mx > cell_start_x && mx < cell_start_x + cell_w) { build_mode = "tec"; global.build_menu_open = false; }
                    else if (mx > cell_start_x + cell_w + gap && mx < cell_start_x + cell_w*2 + gap) { build_mode = "solar"; global.build_menu_open = false; }
                    else if (mx > cell_start_x + (cell_w + gap)*2 && mx < cell_start_x + cell_w*3 + gap*2) { build_mode = "wind"; global.build_menu_open = false; }
                }
            }
        }
        exit;
    }

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
                case "house": g.sprite_index = spr_good_house_1; g.spawn_obj = obj_house; g.cost = 50; break;
                case "medium_house": g.sprite_index = spr_medium_house_1; g.spawn_obj = obj_medium_house; g.cost = 150; break;
                case "lux_house": g.sprite_index = spr_Lux_house_1; g.spawn_obj = obj_lux_house; g.cost = 400; break;
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
with (obj_residential) { 
    if (global.upg_insulation) global.used_energy += (energy_use / 2); 
    else global.used_energy += energy_use; 
}

// === 5. ЭКОНОМИКА И ЭКОЛОГИЯ ===
if (global.total_energy >= global.used_energy) {
    with (obj_residential) { global.money += money_gain; } 
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
if (global.tip_timer >= 600) { 
    global.tip_timer = 0;
    var new_tip = global.current_tip;
    while (new_tip == global.current_tip) {
        var random_index = irandom(array_length(global.tips) - 1);
        new_tip = global.tips[random_index];
    }
    global.current_tip = new_tip;
    global.tip_display_timer = 480; 
}
if (global.tip_display_timer > 0) global.tip_display_timer -= 1;