cost = 50;
energy_use = 20;
money_gain = 0.15;

// Выбираем случайный домик из 4-х вариантов
var rand = irandom(3); 

switch(rand) {
    case 0: sprite_index = spr_good_house_1; break;
    case 1: sprite_index = spr_good_house_2; break;
    case 2: sprite_index = spr_good_house_3; break;
    case 3: sprite_index = spr_good_house_4; break;
}

