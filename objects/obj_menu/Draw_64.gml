draw_set_font(fnt_main); 

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Цвета (на случай, если нет спрайтов)
var col_text = make_color_rgb(100, 70, 50); // Коричневый текст

// 1. ФОН (Кремовый)
draw_set_color(make_color_rgb(245, 240, 230));
draw_rectangle(0, 0, gui_w, gui_h, false);

// 2. ЗАГОЛОВОК
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(col_text);
draw_text_transformed(gui_w/2, gui_h * 0.2, "ЭНЕРГОБАЛАНС", 2, 2, 0);

// 3. ПАНЕЛЬ ПО ЦЕНТРУ (если вырезал spr_ui_panel)
// Рассчитываем размеры панели
var panel_w = 500; 
var panel_h = 400;
var panel_x = gui_w/2 - panel_w/2;
var panel_y = gui_h/2 - panel_h/2 + 50;

// Рисуем панель (растягиваем спрайт)
draw_sprite_ext(spr_ui_panel, 0, panel_x, panel_y, panel_w / sprite_get_width(spr_ui_panel), panel_h / sprite_get_height(spr_ui_panel), 0, c_white, 1);

// 4. КНОПКИ
var btn_w = 300;
var btn_h = 60;
var btn_x = gui_w/2 - btn_w/2;
var start_y = panel_y + 60; // Начинаем рисовать кнопки внутри панели
var spacing = 80; 

var btn_texts = ["Играть", "Настройки", "Разработчики", "Выход"];

for (var i = 0; i < 4; i++) {
    var by = start_y + (i * spacing);
    var is_hover = (mx > btn_x && mx < btn_x + btn_w && my > by && my < by + btn_h);
    
    // Выбираем цвет для текста (красный для выхода)
    var txt_color = (i == 3) ? make_color_rgb(180, 70, 70) : col_text;
    
    // Рисуем кнопку (растягиваем спрайт)
    // Если мышь наведена, делаем кнопку чуть светлее (используя blend)
    var btn_blend = is_hover ? make_color_rgb(220, 220, 220) : c_white;
    
    // Если у тебя есть отдельный спрайт spr_ui_btn_hover, используй его в тернарном операторе
    draw_sprite_ext(spr_ui_btn, 0, btn_x, by, btn_w / sprite_get_width(spr_ui_btn), btn_h / sprite_get_height(spr_ui_btn), 0, btn_blend, 1);
    
    // Текст
    draw_set_color(txt_color);
    draw_text(btn_x + btn_w/2, by + btn_h/2, btn_texts[i]);
}

// 5. ЛОГИКА КЛИКОВ
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