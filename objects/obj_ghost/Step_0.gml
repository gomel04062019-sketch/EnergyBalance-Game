if (global.is_paused) exit;
// Привязка к сетке
var snap_x = round(mouse_x / 64) * 64;
var snap_y = round(mouse_y / 32) * 32;

x = snap_x;
y = snap_y;

// 1. Проверяем, помещается ли ВСЁ здание (весь его спрайт) внутри зеленой зоны
var fits_in_grass = (bbox_left >= global.grass_x1 && 
                     bbox_right <= global.grass_x2 && 
                     bbox_top >= global.grass_y1 && 
                     bbox_bottom <= global.grass_y2);

// 2. Проверяем, не налезает ли на другое здание
var collision = place_meeting(x, y, obj_building);

// 3. Проверяем, хватает ли денег
var enough_money = (global.money >= cost);

// Если ВСЕ условия выполнены (здание целиком на траве, нет коллизий, есть деньги)
if (fits_in_grass && !collision && enough_money) {
    image_blend = c_green; // Зеленый - можно строить
    can_build = true;
} else {
    image_blend = c_red;   // Красный - нельзя
    can_build = false;
}