draw_set_font(fnt_main); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// === РИСУЕМ ФОН (ОСТРОВ) ===
var bg_w = sprite_get_width(spr_menu_bg);
var bg_h = sprite_get_height(spr_menu_bg);
var scale = min(gui_w / bg_w, gui_h / bg_h);

var draw_w = bg_w * scale;
var draw_h = bg_h * scale;
var draw_x = (gui_w - draw_w) / 2;
var draw_y = (gui_h - draw_h) / 2;

draw_sprite_ext(spr_menu_bg, 0, draw_x, draw_y, scale, scale, 0, c_white, 1);

// Затемнение по центру для читаемости
draw_set_color(c_black); draw_set_alpha(0.4);
draw_rectangle(gui_w/2 - 200, 0, gui_w/2 + 200, gui_h, false);
draw_set_alpha(1);

// ЗАГОЛОВОК
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(60, 40, 20)); 
draw_text_transformed(gui_w/2, gui_h * 0.15, "ЭНЕРГОБАЛАНС", 2, 2, 0);

// ==========================================
// КНОПКИ (БЕЗ ДВОЙНЫХ ТЕНЕЙ)
// ==========================================
var btn_w = 280; 
var btn_h = 65;  
var btn_x = gui_w/2 - btn_w/2;

var spacing = 85; // Идеальное расстояние
var total_buttons_height = (4 * btn_h) + (3 * 20); 
var start_y = (gui_h - total_buttons_height) / 2 + 40; 

var btn_texts = ["Играть", "Настройки", "Разработчики", "Выход"];

for (var i = 0; i < 4; i++) {
    var by = start_y + (i * spacing);
    var is_hover = (mx > btn_x && mx < btn_x + btn_w && my > by && my < by + btn_h);
    
    // Рисуем ТОЛЬКО одну кнопку (тень встроена в спрайт)
    var btn_blend = is_hover ? make_color_rgb(255, 245, 235) : c_white; 
    var draw_y = is_hover ? by - 3 : by; 
    
    draw_sprite_ext(spr_ui_btn, 0, btn_x, draw_y, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, btn_blend, 1);
    
    // Легкий блик сверху
    draw_set_color(c_white); draw_set_alpha(0.4);
    draw_line(btn_x + 20, draw_y + 10, btn_x + btn_w - 20, draw_y + 10);
    draw_set_alpha(1);

    // Текст
    draw_set_color(make_color_rgb(60, 40, 20)); 
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(btn_x + btn_w/2, draw_y + btn_h/2, btn_texts[i]);
}

// ФУТЕР
draw_set_valign(fa_top);
draw_set_color(c_white); 
draw_set_halign(fa_left);
draw_text(40, gui_h - 40, "VER 1.1.0");

var text_str = "ВЫБОР";
var text_w = string_width(text_str);
var text_x = gui_w - 40 - text_w;
var text_y = gui_h - 40;

draw_text(text_x, text_y, text_str);

var spr_size = 50; 
var spr_x = text_x - 10 - spr_size; 
var spr_y = text_y + (string_height(text_str) - spr_size) / 2; 

draw_sprite_ext(Enter, 0, spr_x, spr_y, spr_size / sprite_get_width(Enter), spr_size / sprite_get_height(Enter), 0, c_white, 1);

// ЛОГИКА КЛИКОВ
if (mouse_check_button_pressed(mb_left)) {
    for (var i = 0; i < 4; i++) {
        var by = start_y + (i * spacing);
        if (mx > btn_x && mx < btn_x + btn_w && my > by && my < by + btn_h) {
            switch(i) {
                case 0: room_goto(Room1); break;
                case 1: break; 
                case 2: break; 
                case 3: game_end(); break; 
            }
        }
    }
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);