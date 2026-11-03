energy_use = 10;
money_gain = 2;
cost = 50;

// Выбираем случайный домик из 4-х вариантов
var rand = irandom(3); 

switch(rand) {
    case 0: sprite_index = spr_house_1; break;
    case 1: sprite_index = spr_house_2; break;
    case 2: sprite_index = spr_house_3; break;
    case 3: sprite_index = spr_house_4; break;
}

