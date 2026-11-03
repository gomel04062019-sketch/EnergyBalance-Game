// === 1. СИСТЕМА ПАУЗЫ ===
if (keyboard_check_pressed(vk_escape)) {
    global.is_paused = !global.is_paused;
}

// Если игра на паузе, останавливаем логику
if (global.is_paused) exit;

// Если игра окончена, останавливаем логику
if (global.game_state != "playing") exit;

// === 2. УПРАВЛЕНИЕ ТЕХНОЛОГИЯМИ ===
if (keyboard_check_pressed(ord("T")) && global.game_state == "playing") {
    global.tech_menu_open = !global.tech_menu_open;
}

// Если открыто меню технологий, блокируем управление миром (камеру, стройку)
if (global.tech_menu_open) exit;

// === 3. ЛОГИКА КВЕСТОВ ===
switch (global.quest_stage) {
    case 1:
        global.quest_text = "Задание 1: Постройте 3 дома";
        if (instance_number(obj_house) >= 3) { global.quest_stage = 2; }
        break;
    case 2:
        global.quest_text = "Задание 2: Выработайте 50 МВт энергии";
        if (global.total_energy >= 50) { global.quest_stage = 3; }
        break;
    case 3:
        global.quest_text = "Задание 3: Накопите 500$";
        if (global.money >= 500) { global.quest_stage = 4; }
        break;
    case 4:
        global.quest_text = "Задание 4: Откройте Технологии (T) и купите Утепление домов";
        if (global.upg_insulation) { global.quest_stage = 5; }
        break;
    case 5:
        global.quest_text = "Задание 5: Достигните экологии 80% и накопите 1000$";
        if (global.eco_score >= 80 && global.money >= 1000) { 
            global.game_state = "win"; 
        }
        break;
}

// === 4. ВЫБОР ЗДАНИЯ И СТРОИТЕЛЬСТВО ===
if (keyboard_check_pressed(ord("1"))) build_mode = "house";
if (keyboard_check_pressed(ord("2"))) build_mode = "tec";
if (keyboard_check_pressed(ord("3"))) build_mode = "solar";
if (keyboard_check_pressed(ord("4"))) build_mode = "wind";

var mx = device_mouse_x_to_gui(0); 
var my = device_mouse_y_to_gui(0);
var ui_y = display_get_gui_height() - 60; 

if (mouse_check_button_pressed(mb_left)) {
    // Клик по UI
    if (my > ui_y) {
        if (!instance_exists(obj_ghost)) {
            var selected = "none";
            if (mx > 20 && mx < 140)   selected = "house";
            if (mx > 150 && mx < 270)  selected = "tec";
            if (mx > 280 && mx < 400)  selected = "solar";
            if (mx > 410 && mx < 530)  selected = "wind";
            
            if (selected != "none") {
                var g = instance_create_depth(0, 0, 10, obj_ghost);
                switch (selected) {
                    case "house": g.sprite_index = spr_house_1; g.spawn_obj = obj_house; g.cost = 50; break;
                    case "tec":   g.sprite_index = spr_tec;   g.spawn_obj = obj_tec;   g.cost = 150; break;
                    case "solar": g.sprite_index = spr_solar; g.spawn_obj = obj_solar; g.cost = 200; break;
                    case "wind":  g.sprite_index = spr_wind;  g.spawn_obj = obj_wind;  g.cost = 250; break;
                }
            }
        }
    } 
    // Клик по миру
    else {
        if (instance_exists(obj_ghost) && obj_ghost.can_build) {
            instance_create_depth(obj_ghost.x, obj_ghost.y, 0, obj_ghost.spawn_obj);
            global.money -= obj_ghost.cost;
            instance_destroy(obj_ghost);
        }
    }
}

if (mouse_check_button_pressed(mb_right)) {
    if (instance_exists(obj_ghost)) {
        instance_destroy(obj_ghost); 
    } else {
        if (my <= ui_y) {
            var building_to_delete = instance_position(mouse_x, mouse_y, obj_building);
            if (building_to_delete != noone) {
                global.money += (building_to_delete.cost / 2);
                instance_destroy(building_to_delete);
            }
        }
    }
}

// === 5. СМЕНА ПОГОДЫ ===
global.day_timer += 1;
if (global.day_timer >= 300) { 
    global.day_timer = 0;
    global.is_night = !global.is_night;
    
    var rand_weather = irandom(2);
    if (rand_weather == 0) global.weather = "sunny";
    if (rand_weather == 1) global.weather = "cloudy";
    if (rand_weather == 2) global.weather = "windy";
}

// === 6. ПОДСЧЕТ ЭНЕРГИИ (С УЧЕТОМ УЛУЧШЕНИЙ) ===
global.total_energy = 0;
global.used_energy = 0;
global.total_pollution = 0;

with (obj_tec) { 
    global.total_energy += energy_gen; 
    // Фильтры снижают выбросы
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
    // Утепление снижает потребление
    if (global.upg_insulation) global.used_energy += 5; 
    else global.used_energy += 10; 
}

// === 7. ЭКОНОМИКА И ЭКОЛОГИЯ ===
if (global.total_energy >= global.used_energy) {
    with (obj_house) { global.money += 0.02; } 
}

// ИЗМЕНЕНО ЗДЕСЬ: замедлили падение экологии и ускорили восстановление
if (global.total_pollution > 0) {
    global.eco_score -= (global.total_pollution / 4000); 
} else {
    if (global.eco_score < 100) global.eco_score += 0.01; 
}
global.eco_score = clamp(global.eco_score, 0, 100);

if (global.eco_score < 50) {
    global.money -= 0.1; 
}

// === 8. КАМЕРА И F11 ===
if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}

var cam = view_camera[0];
var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);
var cam_speed = 10; 

if (keyboard_check(vk_left) || keyboard_check(ord("A")))  cam_x -= cam_speed;
if (keyboard_check(vk_right) || keyboard_check(ord("D"))) cam_x += cam_speed;
if (keyboard_check(vk_up) || keyboard_check(ord("W")))    cam_y -= cam_speed;
if (keyboard_check(vk_down) || keyboard_check(ord("S")))  cam_y += cam_speed;

var cam_w = camera_get_view_width(cam);
var cam_h = camera_get_view_height(cam);
cam_x = clamp(cam_x, 0, room_width - cam_w);
cam_y = clamp(cam_y, 0, room_height - cam_h);

camera_set_view_pos(cam, cam_x, cam_y);

// === 9. СОВЕТЫ ===
global.tip_timer += 1;
if (global.tip_timer >= 900) {
    global.tip_timer = 0;
    var random_index = irandom(array_length(global.tips) - 1);
    global.current_tip = global.tips[random_index];
    global.tip_display_timer = 360; 
}
if (global.tip_display_timer > 0) {
    global.tip_display_timer -= 1;
}