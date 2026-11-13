if (keyboard_check_pressed(vk_up)) {
    menu_index -= 1;
    if (menu_index < 0) menu_index = 3;
}
if (keyboard_check_pressed(vk_down)) {
    menu_index += 1;
    if (menu_index > 3) menu_index = 0;
}
if (keyboard_check_pressed(vk_enter)) {
    switch(menu_index) {
        case 0: room_goto(Room1); break;
        case 1: break; 
        case 2: break; 
        case 3: game_end(); break; 
    }
}