cost = 400;
energy_use = 65; // Огромное потребление
money_gain = 0.50; // Огромный доход
// Рандомный спрайт
var r = irandom(3);
switch(r) {
    case 0: sprite_index = spr_Lux_house_1; break;
    case 1: sprite_index = spr_Lux_house_2; break;
    case 2: sprite_index = spr_Lux_house_3; break;
    case 3: sprite_index = spr_Lux_house_4; break;
}