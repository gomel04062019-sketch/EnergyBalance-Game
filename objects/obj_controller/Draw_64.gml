// Включаем шрифт и стандартное выравнивание
draw_set_font(fnt_main); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var mx = device_mouse_x_to_gui(0); 
var my = device_mouse_y_to_gui(0);
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// ЦВЕТА (Коричневый для текста, чтобы сочеталось с деревом)
var col_text = make_color_rgb(100, 70, 50);
var col_white = make_color_rgb(255, 255, 255);
var col_green = make_color_rgb(100, 180, 100);
var col_red = make_color_rgb(200, 80, 80);

// Функция для рисования растянутой панели (чтобы не писать одно и то же)
// (В GML нет локальных функций в старых версиях, поэтому просто дублируем код отрисовки)

// ==========================================
// ЛЕВАЯ ПАНЕЛЬ (РЕСУРСЫ)
// ==========================================
var l_panel_w = 260;
var l_panel_h = 200;
draw_sprite_ext(spr_ui_panel, 0, 0, 0, l_panel_w / sprite_get_width(spr_ui_panel), l_panel_h / sprite_get_height(spr_ui_panel), 0, c_white, 0.95);

draw_set_color(col_text);
draw_text(25, 25, "Бюджет: $" + string(floor(global.money)));
draw_text(25, 55, "Выработка: " + string(global.total_energy) + " МВт");
draw_text(25, 85, "Потребление: " + string(global.used_energy) + " МВт");

if (global.used_energy > global.total_energy) {
    draw_set_color(col_red);
    draw_text(25, 115, "ВНИМАНИЕ: ПЕРЕГРУЗКА!");
} else {
    draw_set_color(col_green);
    draw_text(25, 115, "Сеть стабильна");
}

draw_set_color(col_text);
draw_text(25, 145, "Экология: " + string(round(global.eco_score)) + "%");

if (global.eco_score < 50) {
    draw_set_color(col_red);
    draw_text(25, 170, "ШТРАФЫ!");
}

// ==========================================
// ПРАВАЯ ПАНЕЛЬ (ПОГОДА И ВРЕМЯ)
// ==========================================
var r_panel_w = 220;
var r_panel_h = 100;
draw_sprite_ext(spr_ui_panel, 0, gui_w - r_panel_w, 0, r_panel_w / sprite_get_width(spr_ui_panel), r_panel_h / sprite_get_height(spr_ui_panel), 0, c_white, 0.95);

draw_set_color(col_text);
var time_str = global.is_night ? "Ночь" : "День";
draw_text(gui_w - r_panel_w + 20, 20, "Время: " + time_str);

var weather_str = "";
if (global.weather == "sunny") weather_str = "Солнечно";
if (global.weather == "cloudy") weather_str = "Облачно";
if (global.weather == "windy") weather_str = "Ветрено";
draw_text(gui_w - r_panel_w + 20, 50, "Погода: " + weather_str);

// ==========================================
// ВЕРХНИЙ ЦЕНТР (КВЕСТ)
// ==========================================
draw_set_halign(fa_center);
var quest_w = string_width(global.quest_text) + 40;
var quest_h = 45;
draw_sprite_ext(spr_ui_panel, 0, gui_w/2 - quest_w/2, 10, quest_w / sprite_get_width(spr_ui_panel), quest_h / sprite_get_height(spr_ui_panel), 0, c_white, 0.95);

draw_set_color(col_text);
draw_text(gui_w/2, 20, global.quest_text);
draw_set_halign(fa_left);

// ==========================================
// НИЖНЯЯ ПАНЕЛЬ (СТРОИТЕЛЬСТВО)
// ==========================================
var btn_w = 120;
var btn_h = 55;
var btn_y = gui_h - 65; 
var start_x = 20;

// Рисуем фон нижней панели
draw_sprite_ext(spr_ui_panel, 0, 0, gui_h - 80, gui_w / sprite_get_width(spr_ui_panel), 80 / sprite_get_height(spr_ui_panel), 0, c_white, 0.95);

for (var i = 0; i < 4; i++) {
    var bx = start_x + (i * (btn_w + 10));
    var is_hover = (mx > bx && mx < bx + btn_w && my > btn_y && my < btn_y + btn_h);
    var is_active = false;
    
    if (i == 0 && build_mode == "house") is_active = true;
    if (i == 1 && build_mode == "tec") is_active = true;
    if (i == 2 && build_mode == "solar") is_active = true;
    if (i == 3 && build_mode == "wind") is_active = true;

    // Красим кнопку (подсвечиваем, если активна)
    var btn_blend = c_white;
    if (is_active) btn_blend = make_color_rgb(200, 255, 200); // Зеленоватый оттенок
    else if (is_hover) btn_blend = make_color_rgb(255, 240, 220); // Светло-желтый
    
    // Рисуем кнопку
    draw_sprite_ext(spr_ui_btn, 0, bx, btn_y, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, btn_blend, 1);
    
    // Текст
    draw_set_color(col_text);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var txt = "";
    if (i == 0) txt = "1: Дом";
    if (i == 1) txt = "2: ТЭЦ";
    if (i == 2) txt = "3: Солнце";
    if (i == 3) txt = "4: Ветер";
    draw_text(bx + btn_w/2, btn_y + btn_h/2, txt);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ==========================================
// КРАСНАЯ РАМКА (ТРЕВОГА)
// ==========================================
if (global.used_energy > global.total_energy && global.game_state == "playing" && !global.tech_menu_open && !global.is_paused) {
    var pulse = (sin(current_time / 150) + 1) / 2; 
    draw_set_color(col_red);
    draw_set_alpha(pulse * 0.6); 
    var thickness = 10; 
    draw_rectangle(0, 0, gui_w, thickness, false); 
    draw_rectangle(0, gui_h - thickness, gui_w, gui_h, false); 
    draw_rectangle(0, 0, thickness, gui_h, false); 
    draw_rectangle(gui_w - thickness, 0, gui_w, gui_h, false); 
    draw_set_alpha(1); 
}

// ==========================================
// СОВЕТЫ (ПОДСКАЗКИ)
// ==========================================
if (global.tip_display_timer > 0 && global.current_tip != "") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    
    var text_w = string_width(global.current_tip) + 40;
    draw_sprite_ext(spr_ui_panel, 0, gui_w/2 - text_w/2, 60, text_w / sprite_get_width(spr_ui_panel), 45 / sprite_get_height(spr_ui_panel), 0, c_white, 0.95);
    
    draw_set_color(col_text);
    draw_text(gui_w/2, 70, global.current_tip);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ==========================================
// МЕНЮ ТЕХНОЛОГИЙ
// ==========================================
if (global.tech_menu_open) {
    // Затемнение
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);
    
    var win_w = 700; 
    var win_h = 450;
    var win_x = gui_w/2 - win_w/2;
    var win_y = gui_h/2 - win_h/2;
    
    // Окно
    draw_sprite_ext(spr_ui_panel, 0, win_x, win_y, win_w / sprite_get_width(spr_ui_panel), win_h / sprite_get_height(spr_ui_panel), 0, c_white, 1);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text);
    draw_text(gui_w/2, win_y + 30, "ЦЕНТР РАЗРАБОТОК");
    draw_set_valign(fa_top);
    
    // Вкладки (рисуем кнопками)
    var tab_w = 200;
    var tab_h = 45;
    var tab_y = win_y + 60;
    
    // Вкладка ДОМА
    var tab1_blend = (global.active_tab == "houses") ? make_color_rgb(200, 255, 200) : c_white;
    draw_sprite_ext(spr_ui_btn1, 0, win_x + 20, tab_y, tab_w / sprite_get_width(spr_ui_btn1), tab_h / sprite_get_height(spr_ui_btn1), 0, tab1_blend, 1);
    draw_set_color(col_text); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(win_x + 20 + tab_w/2, tab_y + tab_h/2, "ЖИЛЫЕ ДОМА");
    
    // Вкладка СТАНЦИИ
    var tab2_blend = (global.active_tab == "stations") ? make_color_rgb(200, 255, 200) : c_white;
    draw_sprite_ext(spr_ui_btn1, 0, win_x + 240, tab_y, tab_w / sprite_get_width(spr_ui_btn1), tab_h / sprite_get_height(spr_ui_btn1), 0, tab2_blend, 1);
    draw_set_color(col_text);
    draw_text(win_x + 240 + tab_w/2, tab_y + tab_h/2, "ЭЛЕКТРОСТАНЦИИ");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var content_y = tab_y + 70;
    var buy_btn_x = win_x + 520; 
    var buy_btn_w = 150; 
    var buy_btn_h = 50;
    
    if (global.active_tab == "houses") {
        draw_set_color(col_text);
        draw_text(win_x + 30, content_y, "Утепление домов");
        draw_set_color(make_color_rgb(120, 90, 70));
        draw_text(win_x + 30, content_y + 30, "Снижает потребление энергии на 50%");
        draw_set_color(make_color_rgb(180, 120, 50));
        draw_text(win_x + 30, content_y + 60, "Стоимость: 300$");
        
        if (global.upg_insulation) {
            draw_set_color(col_green); 
            draw_text(win_x + 30, content_y + 100, "УЛУЧШЕНИЕ КУПЛЕНО");
        } else {
            var btn_y = content_y - 5;
            var can_afford = (global.money >= 300);
            var hover = (mx > buy_btn_x && mx < buy_btn_x + buy_btn_w && my > btn_y && my < btn_y + buy_btn_h);
            
            var b_blend = can_afford ? (hover ? make_color_rgb(200, 255, 200) : c_white) : make_color_rgb(200, 150, 150);
            draw_sprite_ext(spr_ui_btn1, 0, buy_btn_x, btn_y, buy_btn_w / sprite_get_width(spr_ui_btn1), buy_btn_h / sprite_get_height(spr_ui_btn1), 0, b_blend, 1);
            
            draw_set_color(col_text); draw_set_halign(fa_center); draw_set_valign(fa_middle);
            draw_text(buy_btn_x + buy_btn_w/2, btn_y + buy_btn_h/2, "Купить");
            draw_set_halign(fa_left); draw_set_valign(fa_top);
            
            if (mouse_check_button_pressed(mb_left) && hover) {
                if (can_afford) { global.money -= 300; global.upg_insulation = true; }
            }
        }
    }
    
    if (global.active_tab == "stations") {
        draw_set_color(col_text);
        draw_text(win_x + 30, content_y, "Фильтры для ТЭЦ");
        draw_set_color(make_color_rgb(120, 90, 70));
        draw_text(win_x + 30, content_y + 30, "Снижает загрязнение среды на 50%");
        draw_set_color(make_color_rgb(180, 120, 50));
        draw_text(win_x + 30, content_y + 60, "Стоимость: 400$");
        
        if (global.upg_filter) {
            draw_set_color(col_green); 
            draw_text(win_x + 30, content_y + 100, "УЛУЧШЕНИЕ КУПЛЕНО");
        } else {
            var btn_y = content_y - 5;
            var can_afford = (global.money >= 400);
            var hover = (mx > buy_btn_x && mx < buy_btn_x + buy_btn_w && my > btn_y && my < btn_y + buy_btn_h);
            
            var b_blend = can_afford ? (hover ? make_color_rgb(200, 255, 200) : c_white) : make_color_rgb(200, 150, 150);
            draw_sprite_ext(spr_ui_btn1, 0, buy_btn_x, btn_y, buy_btn_w / sprite_get_width(spr_ui_btn1), buy_btn_h / sprite_get_height(spr_ui_btn1), 0, b_blend, 1);
            
            draw_set_color(col_text); draw_set_halign(fa_center); draw_set_valign(fa_middle);
            draw_text(buy_btn_x + buy_btn_w/2, btn_y + buy_btn_h/2, "Купить");
            draw_set_halign(fa_left); draw_set_valign(fa_top);
            
            if (mouse_check_button_pressed(mb_left) && hover) {
                if (can_afford) { global.money -= 400; global.upg_filter = true; }
            }
        }
    }
    
    // Клики по вкладкам
    if (mouse_check_button_pressed(mb_left)) {
        if (mx > win_x + 20 && mx < win_x + 20 + tab_w && my > tab_y && my < tab_y + tab_h) global.active_tab = "houses";
        if (mx > win_x + 240 && mx < win_x + 240 + tab_w && my > tab_y && my < tab_y + tab_h) global.active_tab = "stations";
    }
}

// ==========================================
// МЕНЮ ПАУЗЫ
// ==========================================
if (global.is_paused) {
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);

    var p_win_w = 400;
    var p_win_h = 300;
    var p_win_x = gui_w/2 - p_win_w/2;
    var p_win_y = gui_h/2 - p_win_h/2;
    
    draw_sprite_ext(spr_ui_panel, 0, p_win_x, p_win_y, p_win_w / sprite_get_width(spr_ui_panel), p_win_h / sprite_get_height(spr_ui_panel), 0, c_white, 1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text);
    draw_text(gui_w/2, p_win_y + 40, "ПАУЗА");

    var btn_w = 250;
    var btn_h = 55;
    var btn_x = gui_w/2 - btn_w/2;

    // Кнопка "Продолжить"
    var resume_y = p_win_y + 90;
    var r_hover = (mx > btn_x && mx < btn_x + btn_w && my > resume_y && my < resume_y + btn_h);
    var r_blend = r_hover ? make_color_rgb(200, 255, 200) : c_white;
    draw_sprite_ext(spr_ui_btn, 0, btn_x, resume_y, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, r_blend, 1);
    
    draw_set_color(col_text);
    draw_text(gui_w/2, resume_y + btn_h/2, "Продолжить");

    // Кнопка "В меню"
    var menu_y = resume_y + 70;
    var m_hover = (mx > btn_x && mx < btn_x + btn_w && my > menu_y && my < menu_y + btn_h);
    var m_blend = m_hover ? make_color_rgb(255, 200, 200) : c_white; // Красноватый при наведении
    draw_sprite_ext(spr_ui_btn, 0, btn_x, menu_y, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, m_blend, 1);
    
    draw_set_color(col_text);
    draw_text(gui_w/2, menu_y + btn_h/2, "В главное меню");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    if (mouse_check_button_pressed(mb_left)) {
        if (r_hover) global.is_paused = false;
        if (m_hover) {
            global.is_paused = false;
            room_goto(rm_menu); 
        }
    }
}

// ==========================================
// ФИНАЛЬНЫЙ ЭКРАН (ПОБЕДА / ПОРАЖЕНИЕ)
// ==========================================
if (global.game_state != "playing") {
    draw_set_color(c_black);
    draw_set_alpha(0.6); 
    draw_rectangle(0, 0, gui_w, gui_h, false); 
    draw_set_alpha(1); 

    var e_win_w = 600;
    var e_win_h = 300;
    var e_win_x = gui_w/2 - e_win_w/2;
    var e_win_y = gui_h/2 - e_win_h/2;
    
    draw_sprite_ext(spr_ui_panel, 0, e_win_x, e_win_y, e_win_w / sprite_get_width(spr_ui_panel), e_win_h / sprite_get_height(spr_ui_panel), 0, c_white, 1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (global.game_state == "win") {
        draw_set_color(col_green);
        draw_text(gui_w/2, e_win_y + 80, "ПОБЕДА!"); 
        draw_set_color(col_text);
        draw_text(gui_w/2, e_win_y + 130, "Вы построили идеальный экологичный город!"); 
    } 
    else if (global.game_state == "lose") {
        draw_set_color(col_red);
        draw_text(gui_w/2, e_win_y + 80, "ПОРАЖЕНИЕ"); 
        draw_set_color(col_text);
        draw_text(gui_w/2, e_win_y + 130, "Город обанкротился из-за штрафов за загрязнение!"); 
    }

    draw_set_color(col_text);
    draw_text(gui_w/2, e_win_y + 200, "Нажмите 'R', чтобы начать заново"); 
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    if (keyboard_check_pressed(ord("R"))) {
        room_restart(); 
    }
}