draw_set_font(fnt_main); 

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var col_bg = make_color_rgb(245, 242, 235);      
var col_text = make_color_rgb(60, 60, 60);       
var col_brown = make_color_rgb(160, 120, 90);    
var col_shadow = make_color_rgb(100, 70, 50);    

draw_set_color(col_bg);
draw_rectangle(0, 0, gui_w, gui_h, false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(col_text);
draw_text_transformed(gui_w/2, gui_h * 0.25, "ЭНЕРГОБАЛАНС", 2, 2, 0);

var btn_w = 280; 
var btn_h = 70;  
var btn_x = gui_w/2 - btn_w/2;

var total_buttons_height = (4 * btn_h) + (3 * 25); 
var start_y = (gui_h - total_buttons_height) / 2 + 40; 
var spacing = btn_h + 25; 

var btn_texts = ["Играть", "Настройки", "Разработчики", "Выход"];

for (var i = 0; i < 4; i++) {
    var by = start_y + (i * spacing);
    var is_hover = (mx > btn_x && mx < btn_x + btn_w && my > by && my < by + btn_h);
    var is_selected = (menu_index == i);
    var is_active = is_hover || is_selected;
    
    var sh_col = (i == 3) ? make_color_rgb(120, 50, 50) : col_shadow;
    
    draw_set_alpha(0.6); 
    draw_sprite_ext(spr_ui_btn, 0, btn_x + 6, by + 6, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, sh_col, 1);
    draw_set_alpha(1); 

    var btn_blend = is_active ? make_color_rgb(255, 245, 235) : c_white; 
    var draw_y = is_active ? by - 3 : by; 
    
    draw_sprite_ext(spr_ui_btn, 0, btn_x, draw_y, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, btn_blend, 1);
    
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    draw_line(btn_x + 20, draw_y + 8, btn_x + btn_w - 20, draw_y + 8);
    draw_set_alpha(1);

    draw_set_color(col_text);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(btn_x + btn_w/2, draw_y + btn_h/2, btn_texts[i]);
}

draw_set_valign(fa_top);
draw_set_color(col_brown);

draw_set_halign(fa_left);
draw_text(40, gui_h - 40, "VER 1.0.6");

var text_str = "ВЫБОР";
var text_w = string_width(text_str);
var text_h = string_height(text_str);

var text_x = gui_w - 40 - text_w;
var text_y = gui_h - 40;

draw_text(text_x, text_y, text_str);

var spr_size = 64; 
var spr_x = text_x - 10 - spr_size; 
var spr_y = text_y + (text_h - spr_size) / 2; 

draw_sprite_ext(Enter, 0, spr_x, spr_y, spr_size / sprite_get_width(Enter), spr_size / sprite_get_height(Enter), 0, col_brown, 1);

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