// Выходим из события, если открыто любое меню или игра на паузе
if (global.is_paused || global.tech_menu_open || global.quest_journal_open || global.build_menu_open) exit;

var snap_x = round(mouse_x / 64) * 64;
var snap_y = round(mouse_y / 32) * 32;

x = snap_x;
y = snap_y;

var fits_in_grass = (bbox_left >= global.grass_x1 && 
                     bbox_right <= global.grass_x2 && 
                     bbox_top >= global.grass_y1 && 
                     bbox_bottom <= global.grass_y2);

var collision = place_meeting(x, y, obj_building);
var enough_money = (global.money >= cost);

if (fits_in_grass && !collision && enough_money) {
    image_blend = c_green; 
    can_build = true;
} else {
    image_blend = c_red;   
    can_build = false;
}