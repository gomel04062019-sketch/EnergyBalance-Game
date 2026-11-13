cost = 150;
energy_use = 40; // Потребляет больше
money_gain = 0.20; // Приносит больше
// Рандомный спрайт
var r = irandom(3);
switch(r) {
    case 0: sprite_index = spr_medium_house_1; break;
    case 1: sprite_index = spr_medium_house_2; break;
    case 2: sprite_index = spr_medium_house_3; break;
    case 3: sprite_index = spr_medium_house_4; break;
}