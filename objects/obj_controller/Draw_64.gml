draw_set_font(fnt_main); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var mx = device_mouse_x_to_gui(0); 
var my = device_mouse_y_to_gui(0);
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var col_text = make_color_rgb(100, 70, 50);
var col_green = make_color_rgb(100, 180, 100);
var col_red = make_color_rgb(200, 80, 80);

var margin = 20;

// Красная рамка
if (global.used_energy > global.total_energy && global.game_state == "playing" && !global.tech_menu_open && !global.is_paused && !global.quest_journal_open && !global.build_menu_open) {
    var pulse = (sin(current_time / 150) + 1) / 2; 
    draw_set_color(col_red); draw_set_alpha(pulse * 0.6); 
    var thickness = 10; 
    draw_rectangle(0, 0, gui_w, thickness, false); draw_rectangle(0, gui_h - thickness, gui_w, gui_h, false); 
    draw_rectangle(0, 0, thickness, gui_h, false); draw_rectangle(gui_w - thickness, 0, gui_w, gui_h, false); 
    draw_set_alpha(1); 
}

var draw_panel = function(_bg, _x, _y, _w, _h, _title) {
    draw_sprite_ext(_bg, 0, _x, _y, _w / sprite_get_width(_bg), _h / sprite_get_height(_bg), 0, c_white, 1);
}

var draw_ui_button = function(_x, _y, _w, _h, _text, _active = false) {
    var cur_mx = device_mouse_x_to_gui(0); var cur_my = device_mouse_y_to_gui(0);
    var hov = (cur_mx > _x && cur_mx < _x + _w && cur_my > _y && cur_my < _y + _h);
    var dy = hov ? _y - 3 : _y; 
    var blend = c_white;
    if (_active) blend = make_color_rgb(200, 255, 200); else if (hov) blend = make_color_rgb(255, 245, 235); 
    
    draw_sprite_ext(spr_ui_btn, 0, _x, dy, _w / sprite_get_width(spr_ui_btn), _h / sprite_get_height(spr_ui_btn), 0, blend, 1);
    draw_set_color(c_white); draw_set_alpha(0.4); draw_line(_x + 20, dy + 10, _x + _w - 20, dy + 10); draw_set_alpha(1);
    draw_set_color(make_color_rgb(100, 70, 50)); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_x + _w/2, dy + _h/2, _text);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}

// ЛЕВАЯ ПАНЕЛЬ
var l_panel_w = 260; var l_panel_h = 200; 
draw_panel(spr_ui_left_stats, margin, margin, l_panel_w, l_panel_h, "");

draw_set_halign(fa_center); draw_set_color(col_text);
draw_text(margin + l_panel_w/2, margin + 40, "Бюджет: $" + string(floor(global.money)));
draw_text(margin + l_panel_w/2, margin + 70, "Выработка: " + string(global.total_energy) + " МВт");
draw_text(margin + l_panel_w/2, margin + 100, "Потребление: " + string(global.used_energy) + " МВт");
if (global.used_energy > global.total_energy) { draw_set_color(col_red); draw_text(margin + l_panel_w/2, margin + 130, "ПЕРЕГРУЗКА!"); } else { draw_set_color(col_green); draw_text(margin + l_panel_w/2, margin + 130, "Сеть стабильна"); }
draw_set_color(col_text); draw_text(margin + l_panel_w/2, margin + 160, "Экология: " + string(round(global.eco_score)) + "%");

// ПАНЕЛЬ СОВЕТОВ
var tip_y = margin + l_panel_h + 20; 
if (global.tip_display_timer > 0 && global.current_tip != "") {
    var max_w = 350; 
    var text_h = string_height_ext(global.current_tip, 22, max_w - 60); 
    var panel_h = text_h + 50; 
    var panel_w = min(max_w, string_width(global.current_tip) + 80);
    
    draw_panel(spr_ui_left_tips, margin, tip_y, panel_w, panel_h, "");
    
    draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(col_text);
    draw_text_ext(margin + panel_w/2, tip_y + panel_h/2, global.current_tip, 22, panel_w - 40);
}

// ПРАВАЯ ПАНЕЛЬ
var r_panel_w = 220; var r_panel_h = 100;
draw_panel(spr_ui_right_weather, gui_w - r_panel_w - margin, margin, r_panel_w, r_panel_h, "");

draw_set_halign(fa_center); draw_set_color(col_text);
var time_str = global.is_night ? "Ночь" : "День";
draw_text(gui_w - r_panel_w/2 - margin, margin + 35, "Время: " + time_str);
var weather_str = "";
if (global.weather == "sunny") weather_str = "Солнечно"; if (global.weather == "cloudy") weather_str = "Облачно"; if (global.weather == "windy") weather_str = "Ветрено";
draw_text(gui_w - r_panel_w/2 - margin, margin + 65, "Погода: " + weather_str);

// КНОПКА ЖУРНАЛА
var btn_size = 45; var btn_x = gui_w - 65; var btn_y = margin + 115;        
var j_hover = (mx > btn_x && mx < btn_x + btn_size && my > btn_y && my < btn_y + btn_size);
var j_blend = (j_hover || global.quest_journal_open) ? make_color_rgb(255, 230, 200) : c_white;
draw_sprite_ext(spr_ui_btn, 0, btn_x, btn_y, btn_size / sprite_get_width(spr_ui_btn), btn_size / sprite_get_height(spr_ui_btn), 0, j_blend, 1);
draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(col_red); draw_set_font(-1); 
draw_text(btn_x + btn_size/2, btn_y + btn_size/2 + 2, "!");
draw_set_font(fnt_main);
if (mouse_check_button_pressed(mb_left) && j_hover) global.quest_journal_open = !global.quest_journal_open;

// ВСПЛЫВАЮЩИЙ КВЕСТ
if (global.quest_timer > 0) {
    var q_w = string_width(global.quest_text) + 80; 
    var q_x = gui_w/2 - q_w/2;
    var q_h = 60; 
    
    draw_panel(spr_ui_center_menu, q_x, margin, q_w, q_h, "");
    
    draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(col_text);
    draw_text(gui_w/2, margin + q_h/2, global.quest_text);
}
draw_set_halign(fa_left); draw_set_valign(fa_top);

// ==========================================
// НИЖНЯЯ ПАНЕЛЬ (ВЫСОТА 150)
// ==========================================
var ui_h = 150; // ИСПРАВЛЕНО: панель стала высотой 150
var ui_y = gui_h - ui_h;
draw_sprite_ext(spr_ui_bottom_bar, 0, 0, ui_y, gui_w / sprite_get_width(spr_ui_bottom_bar), ui_h / sprite_get_height(spr_ui_bottom_bar), 0, c_white, 1);

var btn_w = 160; var btn_h = 65; 
var btn_y = ui_y + (ui_h / 2) - (btn_h / 2) + 10; // Центрируем кнопки с небольшим сдвигом вниз
var gap = 15;
var total_w = (3 * btn_w) + (2 * gap);
var start_x = (gui_w - total_w) / 2;

for (var i = 0; i < 3; i++) {
    var bx = start_x + (i * (btn_w + gap)); 
    var is_active = false;
    if (i == 0 && global.build_category == "house" && global.build_menu_open) is_active = true;
    if (i == 1 && global.build_category == "stations" && global.build_menu_open) is_active = true;
    if (i == 2 && global.build_category == "decor" && global.build_menu_open) is_active = true;

    var txt = ""; if (i == 0) txt = "Дом"; if (i == 1) txt = "Станции"; if (i == 2) txt = "Украшения";
    draw_ui_button(bx, btn_y, btn_w, btn_h, txt, is_active);
}

// ==========================================
// ВЫПАДАЮЩЕЕ МЕНЮ ВЫБОРА ЗДАНИЙ
// ==========================================
if (global.build_menu_open) {
    var m_x = gui_w/2 - 350; 
    var m_y = ui_y - 270; 
    var m_w = 700; var m_h = 260;
    
    draw_panel(spr_ui_center_menu, m_x, m_y, m_w, m_h, "");
    
    var cell_w = 210; var cell_h = 200; var cell_y = m_y + 25; var start_x = m_x + 20; var gap = 15;
    draw_set_halign(fa_center);
    
    var draw_preview = function(_spr, _cx, _cy, _w) {
        var max_size = 56; 
        var scale = min(max_size / sprite_get_width(_spr), max_size / sprite_get_height(_spr));
        var img_w = sprite_get_width(_spr) * scale;
        var img_h = sprite_get_height(_spr) * scale;
        var img_x = _cx + (_w / 2);
        var img_y = _cy + 20 + (img_h / 2); 
        draw_sprite_ext(_spr, 0, img_x, img_y, scale, scale, 0, c_white, 1);
    }
    
    if (global.build_category == "house") {
        var cx1 = start_x;
        draw_preview(spr_good_house_1, cx1, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx1 + cell_w/2, cell_y + 90, "Обычный дом");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx1 + cell_w/2, cell_y + 115, "Цена: $50");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx1 + cell_w/2, cell_y + 135, "10 МВт.\nПриносит мало денег.", 16, cell_w - 20);
        
        var cx2 = start_x + cell_w + gap;
        draw_preview(spr_medium_house_1, cx2, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx2 + cell_w/2, cell_y + 90, "Средний дом");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx2 + cell_w/2, cell_y + 115, "Цена: $150");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx2 + cell_w/2, cell_y + 135, "25 МВт.\nХороший доход.", 16, cell_w - 20);
        
        var cx3 = start_x + (cell_w + gap)*2;
        draw_preview(spr_Lux_house_1, cx3, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx3 + cell_w/2, cell_y + 90, "Люкс дом");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx3 + cell_w/2, cell_y + 115, "Цена: $400");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx3 + cell_w/2, cell_y + 135, "50 МВт.\nОгромный доход.", 16, cell_w - 20);
    } 
    else if (global.build_category == "stations") {
        var cx1 = start_x;
        draw_preview(spr_tec, cx1, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx1 + cell_w/2, cell_y + 90, "ТЭЦ");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx1 + cell_w/2, cell_y + 115, "Цена: $150");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx1 + cell_w/2, cell_y + 135, "Дает 100 МВт.\nСильно загрязняет.", 16, cell_w - 20);
        
        var cx2 = start_x + cell_w + gap;
        draw_preview(spr_solar, cx2, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx2 + cell_w/2, cell_y + 90, "Солнце");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx2 + cell_w/2, cell_y + 115, "Цена: $200");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx2 + cell_w/2, cell_y + 135, "Дает 30 МВт.\nНе работает ночью.", 16, cell_w - 20);
        
        var cx3 = start_x + (cell_w + gap)*2;
        draw_preview(spr_wind, cx3, cell_y, cell_w);
        draw_set_color(col_text); draw_text(cx3 + cell_w/2, cell_y + 90, "Ветер");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(cx3 + cell_w/2, cell_y + 115, "Цена: $250");
        draw_set_color(make_color_rgb(100, 70, 50)); draw_text_ext(cx3 + cell_w/2, cell_y + 135, "Дает 50 МВт.\nЗависит от погоды.", 16, cell_w - 20);
    }
    else if (global.build_category == "decor") {
        draw_set_color(col_text); draw_text(m_x + m_w/2, m_y + 80, "В разработке...");
    }
    draw_set_halign(fa_left);
}

// ==========================================
// ЖУРНАЛ КВЕСТОВ
// ==========================================
if (global.quest_journal_open) {
    draw_set_color(c_black); draw_set_alpha(0.7); draw_rectangle(0, 0, gui_w, gui_h, false); draw_set_alpha(1);
    var j_w = 640; var j_h = 520; var j_x = gui_w/2 - j_w/2; var j_y = gui_h/2 - j_h/2;
    
    draw_panel(spr_ui_center_menu, j_x, j_y, j_w, j_h, "");
    
    var quests = ["Постройте 3 жилых дома", "Выработайте 50 МВт энергии", "Накопите 500$ в бюджете", "Откройте Технологии (T) и купите Утепление", "Достигните экологии 80% и накопите 1000$"];
    var start_y = j_y + 100; var line_spacing = 65; 
    
    draw_set_halign(fa_left); draw_set_valign(fa_middle);
    for (var i = 0; i < 5; i++) {
        var q_y = start_y + i * line_spacing; var q_num = i + 1;
        if (global.quest_stage == q_num) { draw_set_color(c_white); draw_set_alpha(0.4); draw_rectangle(j_x + 30, q_y - 20, j_x + j_w - 30, q_y + 20, false); draw_set_alpha(1); }
        
        draw_set_halign(fa_center);
        if (global.quest_stage > q_num) { draw_set_color(col_green); draw_text(j_x + 60, q_y, "✓"); }
        else if (global.quest_stage == q_num) { draw_set_color(make_color_rgb(200, 100, 50)); draw_text(j_x + 60, q_y, "▶"); }
        else { draw_set_color(c_gray); draw_text(j_x + 60, q_y, "-"); }
        
        draw_set_halign(fa_left);
        if (global.quest_stage > q_num) { draw_set_color(c_dkgray); draw_set_alpha(0.5); draw_text(j_x + 90, q_y, string(q_num) + ". " + quests[i]); draw_set_alpha(1); }
        else if (global.quest_stage == q_num) { draw_set_color(col_text); draw_text(j_x + 90, q_y, string(q_num) + ". " + quests[i]); }
        else { draw_set_color(make_color_rgb(150, 120, 100)); draw_text(j_x + 90, q_y, string(q_num) + ". " + quests[i]); }
    }
    
    var close_w = 220; var close_h = 65; 
    var close_x = gui_w/2 - close_w/2; 
    var close_y = j_y + j_h - 120; 
    
    draw_ui_button(close_x, close_y, close_w, close_h, "Закрыть");
    if (mouse_check_button_pressed(mb_left) && mx > close_x && mx < close_x + close_w && my > close_y && my < close_y + close_h) global.quest_journal_open = false;
}

// МЕНЮ ТЕХНОЛОГИЙ
if (global.tech_menu_open) {
    draw_set_color(c_black); draw_set_alpha(0.7); draw_rectangle(0, 0, gui_w, gui_h, false); draw_set_alpha(1);
    var win_w = 700; var win_h = 450; var win_x = gui_w/2 - win_w/2; var win_y = gui_h/2 - win_h/2;
    
    draw_panel(spr_ui_center_menu, win_x, win_y, win_w, win_h, "");
    
    var cross_size = 40; var cross_x = win_x + win_w - cross_size - 15; var cross_y = win_y + 20;
    var cross_hover = (mx > cross_x && mx < cross_x + cross_size && my > cross_y && my < cross_y + cross_size);
    draw_set_color(cross_hover ? make_color_rgb(200, 100, 100) : make_color_rgb(150, 100, 80));
    draw_rectangle(cross_x, cross_y, cross_x + cross_size, cross_y + cross_size, false);
    draw_set_color(c_white); var pad = 12;
    draw_line_width(cross_x + pad, cross_y + pad, cross_x + cross_size - pad, cross_y + cross_size - pad, 3);
    draw_line_width(cross_x + cross_size - pad, cross_y + pad, cross_x + pad, cross_y + cross_size - pad, 3);
    if (mouse_check_button_pressed(mb_left) && cross_hover) global.tech_menu_open = false;
    
    var tab_w = 200; var tab_h = 45; var tab_y = win_y + 60;
    var tab1_hover = (mx > win_x + 30 && mx < win_x + 30 + tab_w && my > tab_y && my < tab_y + tab_h);
    draw_set_color((global.active_tab == "houses") ? make_color_rgb(150, 200, 150) : (tab1_hover ? make_color_rgb(200, 180, 160) : make_color_rgb(180, 150, 130)));
    draw_rectangle(win_x + 30, tab_y, win_x + 30 + tab_w, tab_y + tab_h, false);
    draw_set_color(make_color_rgb(120, 80, 60)); draw_rectangle(win_x + 30, tab_y, win_x + 30 + tab_w, tab_y + tab_h, true);
    draw_set_color(col_text); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(win_x + 30 + tab_w/2, tab_y + tab_h/2, "ЖИЛЫЕ ДОМА");
    
    var tab2_hover = (mx > win_x + 250 && mx < win_x + 250 + tab_w && my > tab_y && my < tab_y + tab_h);
    draw_set_color((global.active_tab == "stations") ? make_color_rgb(150, 200, 150) : (tab2_hover ? make_color_rgb(200, 180, 160) : make_color_rgb(180, 150, 130)));
    draw_rectangle(win_x + 250, tab_y, win_x + 250 + tab_w, tab_y + tab_h, false);
    draw_set_color(make_color_rgb(120, 80, 60)); draw_rectangle(win_x + 250, tab_y, win_x + 250 + tab_w, tab_y + tab_h, true);
    draw_set_color(col_text); draw_text(win_x + 250 + tab_w/2, tab_y + tab_h/2, "ЭЛЕКТРОСТАНЦИИ");
    
    if (mouse_check_button_pressed(mb_left)) {
        if (tab1_hover) global.active_tab = "houses";
        if (tab2_hover) global.active_tab = "stations";
    }
    
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    var content_y = tab_y + 80; var buy_btn_x = win_x + win_w - 200; var buy_btn_w = 160; var buy_btn_h = 65; 
    
    if (global.active_tab == "houses") {
        draw_set_color(col_text); draw_text(win_x + 40, content_y, "Утепление домов");
        draw_set_color(make_color_rgb(120, 90, 70)); draw_text(win_x + 40, content_y + 30, "Снижает потребление энергии домов на 50%");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(win_x + 40, content_y + 60, "Стоимость: 300$");
        if (global.upg_insulation) { draw_set_color(col_green); draw_text(win_x + 40, content_y + 100, "УЛУЧШЕНИЕ КУПЛЕНО"); }
        else {
            draw_ui_button(buy_btn_x, content_y, buy_btn_w, buy_btn_h, "Купить");
            if (mouse_check_button_pressed(mb_left) && mx > buy_btn_x && mx < buy_btn_x + buy_btn_w && my > content_y && my < content_y + buy_btn_h) {
                if (global.money >= 300) { global.money -= 300; global.upg_insulation = true; }
            }
        }
    }
    
    if (global.active_tab == "stations") {
        draw_set_color(col_text); draw_text(win_x + 40, content_y, "Фильтры для ТЭЦ");
        draw_set_color(make_color_rgb(120, 90, 70)); draw_text(win_x + 40, content_y + 30, "Снижает загрязнение окружающей среды на 50%");
        draw_set_color(make_color_rgb(180, 120, 50)); draw_text(win_x + 40, content_y + 60, "Стоимость: 400$");
        if (global.upg_filter) { draw_set_color(col_green); draw_text(win_x + 40, content_y + 100, "УЛУЧШЕНИЕ КУПЛЕНО"); }
        else {
            draw_ui_button(buy_btn_x, content_y, buy_btn_w, buy_btn_h, "Купить");
            if (mouse_check_button_pressed(mb_left) && mx > buy_btn_x && mx < buy_btn_x + buy_btn_w && my > content_y && my < content_y + buy_btn_h) {
                if (global.money >= 400) { global.money -= 400; global.upg_filter = true; }
            }
        }
    }
}

// МЕНЮ ПАУЗЫ
if (global.is_paused) {
    draw_set_color(c_black); draw_set_alpha(0.7); draw_rectangle(0, 0, gui_w, gui_h, false); draw_set_alpha(1);
    var p_win_w = 400; var p_win_h = 300; var p_win_x = gui_w/2 - p_win_w/2; var p_win_y = gui_h/2 - p_win_h/2;
    
    draw_panel(spr_ui_center_menu, p_win_x, p_win_y, p_win_w, p_win_h, "");
    
    var p_btn_w = 280; var p_btn_h = 65; var p_btn_x = gui_w/2 - p_btn_w/2;
    var resume_y = p_win_y + 80; var menu_y = resume_y + 85; 
    draw_ui_button(p_btn_x, resume_y, p_btn_w, p_btn_h, "Продолжить");
    draw_ui_button(p_btn_x, menu_y, p_btn_w, p_btn_h, "В главное меню");
    if (mouse_check_button_pressed(mb_left)) {
        if (mx > p_btn_x && mx < p_btn_x + p_btn_w && my > resume_y && my < resume_y + p_btn_h) global.is_paused = false;
        if (mx > p_btn_x && mx < p_btn_x + p_btn_w && my > menu_y && my < menu_y + p_btn_h) { global.is_paused = false; room_goto(rm_menu); }
    }
}

// ФИНАЛЬНЫЙ ЭКРАН
if (global.game_state != "playing") {
    draw_set_color(c_black); draw_set_alpha(0.8); draw_rectangle(0, 0, gui_w, gui_h, false); draw_set_alpha(1); 
    var e_win_w = 600; var e_win_h = 300; var e_win_x = gui_w/2 - e_win_w/2; var e_win_y = gui_h/2 - e_win_h/2;
    
    draw_panel(spr_ui_center_menu, e_win_x, e_win_y, e_win_w, e_win_h, "");
    
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    if (global.game_state == "win") {
        draw_set_color(col_green); draw_text(gui_w/2, e_win_y + 80, "ПОБЕДА!"); 
        draw_set_color(col_text); draw_text(gui_w/2, e_win_y + 130, "Вы построили идеальный экологичный город!"); 
    } else if (global.game_state == "lose") {
        draw_set_color(col_red); draw_text(gui_w/2, e_win_y + 80, "ПОРАЖЕНИЕ"); 
        draw_set_color(col_text); draw_text(gui_w/2, e_win_y + 130, "Город обанкротился из-за штрафов!"); 
    }
    draw_set_color(make_color_rgb(180, 120, 50)); draw_text(gui_w/2, e_win_y + 200, "Нажмите 'R', чтобы начать заново"); 
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    if (keyboard_check_pressed(ord("R"))) room_restart(); 
}