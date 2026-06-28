Config = {}

Config.Debug = false

-- Bucket formula
Config.BucketBase = 200000

-- Interaction distance
Config.TargetDistance = 2.0

Config.PropertyShells = {
    [1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,
    [9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[21]=true,[22]=true
}

-- Money
Config.MoneyType = 'cash'

-- Admin perms
Config.AdminGroups = { 'god', 'admin' }

-- Defaults when creating
Config.DefaultLabelHome = 'Ev'
Config.DefaultLabelBusiness = 'İş Yeri'
Config.DefaultLocked = false
Config.DefaultEntryFeeHome = 0

-- Permissions stored per property
Config.DefaultPermissions = {
  employeesCanEnterFree = false,
  employeesCanBuild = true,
  employeesCanControlMusic = true,
}

-- Building props catalog (expand)
Config.BuildCatalog = {

{
  category = 'Duvar / Panel / Çit',
  items = {
    { label = 'Barrier Wall 01', model = 'prop_barrier_work01a' },
    { label = 'Barrier Wall 02', model = 'prop_barrier_work02a' },
    { label = 'Barrier Wall 03', model = 'prop_barrier_work04a' },
    { label = 'Barrier Wall 04', model = 'prop_barrier_work05' },
    { label = 'Barrier Wall 05', model = 'prop_barrier_work06a' },
    { label = 'Fence Wood 01', model = 'prop_fncwood_01a' },
    { label = 'Fence Wood 02', model = 'prop_fncwood_02a' },
    { label = 'Fence Wood 03', model = 'prop_fncwood_03a' },
    { label = 'Fence Wood 04', model = 'prop_fncwood_06a' },
    { label = 'Fence Wood 05', model = 'prop_fncwood_07a' },
    { label = 'Fence Wood 06', model = 'prop_fncwood_08a' },
    { label = 'Fence Wood 07', model = 'prop_fncwood_09a' },
    { label = 'Fence Wood 08', model = 'prop_fncwood_11a' },
    { label = 'Fence Wood 09', model = 'prop_fncwood_12a' },
    { label = 'Fence Wood 10', model = 'prop_fncwood_13a' },
    { label = 'Fence Wood 11', model = 'prop_fncwood_14a' },
    { label = 'Fence Wood 12', model = 'prop_fncwood_15a' },
    { label = 'Fence Wood 13', model = 'prop_fncwood_16a' },
    { label = 'Fence Wood 14', model = 'prop_fncwood_16c' },
    { label = 'Fence Wood 15', model = 'prop_fncwood_16d' },
    { label = 'Fence Wood 16', model = 'prop_fncwood_16e' },
    { label = 'Fence Iron 01', model = 'prop_fnclink_01a' },
    { label = 'Fence Iron 02', model = 'prop_fnclink_02a' },
    { label = 'Fence Iron 03', model = 'prop_fnclink_03a' },
    { label = 'Fence Iron 04', model = 'prop_fnclink_04a' },
    { label = 'Fence Iron 05', model = 'prop_fnclink_05crnr1' },
    { label = 'Fence Iron 06', model = 'prop_fnclink_05crnr2' },
    { label = 'Fence Iron 07', model = 'prop_fnclink_05h' },
    { label = 'Fence Iron 08', model = 'prop_fnclink_05i' },
    { label = 'Fence Iron 09', model = 'prop_fnclink_06gate2' },
    { label = 'Fence Iron 10', model = 'prop_fnclink_07gate1' },
    { label = 'Fence Iron 11', model = 'prop_fnclink_09gate1' },
    { label = 'Wall Brick 01', model = 'prop_wallbrick_01' },
    { label = 'Wall Light Panel', model = 'prop_ind_walllight02' },
    { label = 'Metal Sheeting 01', model = 'prop_sheeting01' },
    { label = 'Metal Sheeting 02', model = 'prop_sheeting02' },
    { label = 'Metal Sheeting 03', model = 'prop_sheeting03' },
    { label = 'Scaffolding 01', model = 'prop_scaffolding_01' },
    { label = 'Scaffolding 02', model = 'prop_scaffolding_02a' },
    { label = 'Scaffolding 03', model = 'prop_scaffolding_03c' },
    { label = 'Military Gate', model = 'prop_gate_military_01' },
    { label = 'Gate Prison 01', model = 'prop_gate_prison_01' },
    { label = 'Gate Frame 01', model = 'prop_gate_frame_01' },
    { label = 'Railing 01', model = 'prop_railing_paddock' },
    { label = 'Railing 02', model = 'prop_mb_craig_02a' },
    { label = 'Concrete Barrier 01', model = 'prop_mp_barrier_01' },
    { label = 'Concrete Barrier 02', model = 'prop_mp_barrier_02b' },
    { label = 'Road Barrier 01', model = 'prop_mp_arrow_barrier_01' },
    { label = 'Road Barrier 02', model = 'prop_barier_conc_01a' },
  }
},

{
  category = 'Zemin / Platform / Tavan',
  items = {
    { label = 'Platform 01', model = 'prop_ld_dstplane' },
    { label = 'Platform 02', model = 'prop_ld_dstplane_02' },
    { label = 'Platform 03', model = 'prop_ld_toilet_01' },
    { label = 'Stage Floor 01', model = 'prop_stage_floor_01' },
    { label = 'Stage Floor 02', model = 'prop_stage_floor_02' },
    { label = 'Stage Floor 03', model = 'prop_stage_floor_03' },
    { label = 'Stage Floor 04', model = 'prop_stage_floor_04' },
    { label = 'Floor Diamond 01', model = 'prop_floor_diamond_01' },
    { label = 'Floor Diamond 02', model = 'prop_floor_diamond_02' },
    { label = 'Wood Ramp 01', model = 'prop_woodpile_01a' },
    { label = 'Wood Ramp 02', model = 'prop_woodpile_02a' },
    { label = 'Dock Ramp 01', model = 'prop_dock_rtg_ld' },
    { label = 'Dock Ramp 02', model = 'prop_dock_rtg_01' },
    { label = 'Concrete Base 01', model = 'prop_conslift_base' },
    { label = 'Concrete Base 02', model = 'prop_cons_ply01' },
    { label = 'Concrete Base 03', model = 'prop_cons_ply02' },
    { label = 'Container Floor 01', model = 'prop_container_01a' },
    { label = 'Container Floor 02', model = 'prop_container_03b' },
    { label = 'Container Floor 03', model = 'prop_container_05a' },
    { label = 'Pallet Base 01', model = 'prop_pallet_01a' },
    { label = 'Pallet Base 02', model = 'prop_pallet_02a' },
    { label = 'Pallet Base 03', model = 'prop_pallet_03a' },
    { label = 'Pallet Base 04', model = 'prop_pallet_04a' },
    { label = 'Roof Bit 01', model = 'prop_roofpipe_01' },
    { label = 'Roof Bit 02', model = 'prop_roofpipe_02' },
    { label = 'Metal Frame 01', model = 'prop_byard_float_01' },
    { label = 'Metal Frame 02', model = 'prop_byard_float_02' },
    { label = 'Metal Frame 03', model = 'prop_byard_float_03' },
    { label = 'Boat Platform', model = 'prop_byard_rampold_cr' },
    { label = 'Wood Board 01', model = 'prop_rub_planks_01' },
    { label = 'Wood Board 02', model = 'prop_rub_planks_02' },
    { label = 'Wood Board 03', model = 'prop_rub_planks_03' },
    { label = 'Wood Board 04', model = 'prop_rub_planks_04' },
    { label = 'Mat 01', model = 'prop_yoga_mat_01' },
    { label = 'Mat 02', model = 'prop_yoga_mat_02' },
    { label = 'Mat 03', model = 'prop_yoga_mat_03' },
  }
},

{
  category = 'Masa',
  items = {
    { label = 'Table 01', model = 'prop_table_01' },
    { label = 'Table 02', model = 'prop_table_02' },
    { label = 'Table 03', model = 'prop_table_03' },
    { label = 'Table 04', model = 'prop_table_04' },
    { label = 'Desk 01', model = 'prop_office_desk_01' },
    { label = 'Desk 02', model = 'prop_office_desk_02' },
    { label = 'Dining Table 01', model = 'prop_dining_table_01' },
    { label = 'Dining Table 02', model = 'prop_dining_table_02' },
    { label = 'Farm Table', model = 'prop_rub_table_01' },
    { label = 'Bar Table 01', model = 'prop_bar_table_01' },
    { label = 'Coffee Table 01', model = 'prop_t_coffe_table' },
    { label = 'Coffee Table 02', model = 'prop_t_coffe_table_02' },
    { label = 'Poker Table', model = 'prop_poker_table_01' },
    { label = 'Workbench 01', model = 'prop_tool_bench02' },
    { label = 'Workbench 02', model = 'prop_worklight_03b' },
    { label = 'Side Table', model = 'v_res_tre_sideboard' },
  }
},

{
  category = 'Sandalye / Koltuk / Oturma',
  items = {
    { label = 'Chair 01', model = 'prop_chair_01a' },
    { label = 'Chair 02', model = 'prop_chair_03' },
    { label = 'Chair 03', model = 'prop_chair_04a' },
    { label = 'Chair 04', model = 'prop_chair_05' },
    { label = 'Chair 05', model = 'prop_chair_06' },
    { label = 'Chair 06', model = 'prop_chair_07' },
    { label = 'Chair 07', model = 'prop_chair_08' },
    { label = 'Chair 08', model = 'prop_chair_pile_01' },
    { label = 'Plastic Chair 01', model = 'prop_chair_plastic' },
    { label = 'Plastic Chair 02', model = 'prop_chair_bin_01' },
    { label = 'Office Chair 01', model = 'prop_off_chair_01' },
    { label = 'Office Chair 02', model = 'prop_off_chair_03' },
    { label = 'Office Chair 03', model = 'prop_off_chair_04' },
    { label = 'Stool 01', model = 'prop_bar_stool_01' },
    { label = 'Stool 02', model = 'prop_bar_stool_02' },
    { label = 'Bench 01', model = 'prop_bench_01a' },
    { label = 'Bench 02', model = 'prop_bench_01b' },
    { label = 'Bench 03', model = 'prop_bench_01c' },
    { label = 'Bench 04', model = 'prop_bench_02' },
    { label = 'Bench 05', model = 'prop_bench_03' },
    { label = 'Bench 06', model = 'prop_bench_04' },
    { label = 'Couch 01', model = 'prop_couch_01' },
    { label = 'Couch 02', model = 'prop_couch_02' },
    { label = 'Couch 03', model = 'prop_couch_03' },
    { label = 'Couch 04', model = 'prop_couch_04' },
    { label = 'Couch Large 01', model = 'prop_couch_lg_02' },
    { label = 'Armchair 01', model = 'prop_armchair_01' },
    { label = 'Armchair 02', model = 'prop_cs_folding_chair_01' },
    { label = 'Bean Bag', model = 'prop_bean_bag_01' },
    { label = 'Sun Lounger 01', model = 'prop_ld_farm_chair01' },
  }
},

{
  category = 'Dekor',
  items = {
    { label = 'Plant 01', model = 'prop_plant_int_01a' },
    { label = 'Plant 02', model = 'prop_plant_int_01b' },
    { label = 'Plant 03', model = 'prop_plant_int_02a' },
    { label = 'Plant 04', model = 'prop_plant_int_02b' },
    { label = 'Plant 05', model = 'prop_plant_int_03a' },
    { label = 'Plant 06', model = 'prop_plant_int_03b' },
    { label = 'Plant 07', model = 'prop_plant_int_04a' },
    { label = 'Plant 08', model = 'prop_plant_int_04b' },
    { label = 'Plant 09', model = 'prop_pot_plant_01a' },
    { label = 'Plant 10', model = 'prop_pot_plant_01b' },
    { label = 'Plant 11', model = 'prop_pot_plant_01c' },
    { label = 'Plant 12', model = 'prop_pot_plant_01d' },
    { label = 'Mirror 01', model = 'prop_mirror_01' },
    { label = 'Mirror 02', model = 'prop_mirror_wal_02' },
    { label = 'Clock', model = 'prop_wall_clock' },
    { label = 'Painting 01', model = 'prop_painting_01a' },
    { label = 'Painting 02', model = 'prop_painting_01b' },
    { label = 'Painting 03', model = 'prop_painting_02a' },
    { label = 'Painting 04', model = 'prop_painting_03' },
    { label = 'Painting 05', model = 'prop_painting_04' },
    { label = 'Statue 01', model = 'prop_statue_horse' },
    { label = 'Statue 02', model = 'prop_statue_bird_01' },
    { label = 'Statue 03', model = 'prop_statue_horse_01' },
    { label = 'Rug 01', model = 'prop_rug_01' },
    { label = 'Rug 02', model = 'prop_rug_01b' },
    { label = 'Rug 03', model = 'prop_rug_01c' },
    { label = 'Rug 04', model = 'prop_rug_10' },
    { label = 'Rug 05', model = 'prop_rug_11' },
    { label = 'Candles 01', model = 'prop_cs_candle_01' },
    { label = 'Candles 02', model = 'prop_cs_candle_02' },
    { label = 'Vase 01', model = 'v_res_m_vasefresh' },
    { label = 'Vase 02', model = 'v_res_desktidy' },
    { label = 'Books 01', model = 'prop_books_01' },
    { label = 'Books 02', model = 'prop_books_02' },
    { label = 'Books 03', model = 'prop_books_03' },
    { label = 'Books 04', model = 'prop_books_04' },
    { label = 'Books 05', model = 'prop_books_05' },
    { label = 'Books 06', model = 'prop_books_06' },
    { label = 'Magazine Rack', model = 'prop_magenta_door' },
    { label = 'Bin 01', model = 'prop_bin_01a' },
    { label = 'Bin 02', model = 'prop_bin_02a' },
    { label = 'Bin 03', model = 'prop_bin_05a' },
    { label = 'Ashtray', model = 'prop_cs_ashtray' },
    { label = 'Cigarette Tray', model = 'prop_cs_ciggy_01' },
    { label = 'Umbrella Stand', model = 'prop_parasol_01' },
  }
},

{
  category = 'Aydınlatma',
  items = {
    { label = 'Floor Lamp 01', model = 'prop_floorlamp_01' },
    { label = 'Floor Lamp 02', model = 'prop_floorlamp_02' },
    { label = 'Floor Lamp 03', model = 'v_res_fh_floorlamp' },
    { label = 'Desk Lamp 01', model = 'prop_table_lamp_01' },
    { label = 'Desk Lamp 02', model = 'prop_table_lamp_02' },
    { label = 'Desk Lamp 03', model = 'v_res_d_lampa' },
    { label = 'Ceiling Light 01', model = 'prop_ceiling_light_01' },
    { label = 'Ceiling Light 02', model = 'prop_ceiling_light_02' },
    { label = 'Ceiling Light 03', model = 'prop_ceiling_light_09' },
    { label = 'Wall Light 01', model = 'prop_wall_light_02a' },
    { label = 'Wall Light 02', model = 'prop_wall_light_03a' },
    { label = 'Wall Light 03', model = 'prop_wall_light_04a' },
    { label = 'Industrial Light 01', model = 'prop_ind_light_02a' },
    { label = 'Industrial Light 02', model = 'prop_worklight_01a' },
    { label = 'Industrial Light 03', model = 'prop_worklight_03a' },
    { label = 'Industrial Light 04', model = 'prop_worklight_04a' },
    { label = 'Industrial Light 05', model = 'prop_worklight_04b' },
    { label = 'Neon Tube 01', model = 'prop_neon_tube_01' },
    { label = 'Neon Tube 02', model = 'prop_neon_tube_02' },
    { label = 'Neon Tube 03', model = 'prop_neon_tube_03' },
    { label = 'Lantern 01', model = 'prop_oldlight_01c' },
    { label = 'Lantern 02', model = 'prop_oldlight_01b' },
    { label = 'Street Light Small', model = 'prop_streetlight_01' },
    { label = 'Street Light Medium', model = 'prop_streetlight_03' },
    { label = 'Street Light Big', model = 'prop_streetlight_11b' },
  }
},

{
  category = 'Bar / Kafe / Restoran',
  items = {
    { label = 'Bar Counter 01', model = 'prop_bar_counter_01' },
    { label = 'Bar Counter 02', model = 'prop_bar_counter_02' },
    { label = 'Bar Counter 03', model = 'prop_bar_counter_07' },
    { label = 'Bar Beer Tap 01', model = 'prop_beer_tap_01' },
    { label = 'Bar Beer Tap 02', model = 'prop_beer_tap_02' },
    { label = 'Bar Pump 01', model = 'prop_bar_pump_01' },
    { label = 'Bar Pump 02', model = 'prop_bar_pump_06' },
    { label = 'Bar Pump 03', model = 'prop_bar_pump_07' },
    { label = 'Bar Fridge 01', model = 'prop_bar_fridge_01' },
    { label = 'Bar Fridge 02', model = 'prop_bar_fridge_02' },
    { label = 'Bottle Shelf 01', model = 'prop_bar_beans' },
    { label = 'Bottle Shelf 02', model = 'prop_bar_measr_01' },
    { label = 'Bottle Shelf 03', model = 'prop_bar_measr_02' },
    { label = 'Bottle Shelf 04', model = 'prop_bar_measr_03' },
    { label = 'Cash Register 01', model = 'prop_till_01' },
    { label = 'Cash Register 02', model = 'prop_till_02' },
    { label = 'Cash Register 03', model = 'prop_till_03' },
    { label = 'Coffee Machine 01', model = 'prop_coffee_mac_01' },
    { label = 'Coffee Machine 02', model = 'prop_coffee_mac_02' },
    { label = 'Coffee Machine 03', model = 'p_ld_coffee_vend_01' },
    { label = 'Cup Stack', model = 'prop_cups_01' },
    { label = 'Menu Board 01', model = 'prop_menu_board_01' },
    { label = 'Menu Board 02', model = 'prop_menu_board_02' },
    { label = 'Menu Board 03', model = 'prop_menu_board_03' },
    { label = 'Neon Sign 01', model = 'prop_neon_sign_01' },
    { label = 'Neon Sign 02', model = 'prop_neon_sign_02' },
    { label = 'Neon Sign 03', model = 'prop_neon_sign_03' },
    { label = 'Neon Sign 04', model = 'prop_neon_sign_04' },
    { label = 'Neon Sign 05', model = 'prop_neon_sign_05' },
    { label = 'Drink Machine 01', model = 'prop_vend_soda_01' },
    { label = 'Drink Machine 02', model = 'prop_vend_soda_02' },
    { label = 'Snack Machine 01', model = 'prop_vend_snak_01' },
    { label = 'Snack Machine 02', model = 'prop_vend_snak_01_tu' },
    { label = 'Popcorn Machine', model = 'prop_popcorn_01' },
    { label = 'Microwave Cafe', model = 'prop_micro_01' },
    { label = 'Display Fridge', model = 'prop_vend_fridge01' },
    { label = 'Ice Box', model = 'prop_ice_box_01' },
    { label = 'Pizza Box', model = 'prop_pizza_box_02' },
    { label = 'Table Tray', model = 'prop_food_tray_01' },
    { label = 'Table Tray 02', model = 'prop_food_bs_tray_03' },
    { label = 'Food Bag', model = 'prop_food_bs_bag_01' },
    { label = 'Napkin Holder', model = 'prop_food_bs_soda_01' },
    { label = 'Bottle Rack', model = 'prop_wine_red' },
  }
},

{
  category = 'Mutfak',
  items = {
    { label = 'Fridge 01', model = 'prop_fridge_01' },
    { label = 'Fridge 02', model = 'prop_fridge_03' },
    { label = 'Fridge 03', model = 'prop_fridge_04' },
    { label = 'Fridge 04', model = 'prop_fridge_05' },
    { label = 'Oven 01', model = 'prop_oven_01' },
    { label = 'Oven 02', model = 'prop_range_hood_01' },
    { label = 'Microwave 01', model = 'prop_micro_01' },
    { label = 'Microwave 02', model = 'prop_microwave_1' },
    { label = 'Sink 01', model = 'prop_sink_02' },
    { label = 'Sink 02', model = 'prop_sink_03' },
    { label = 'Counter 01', model = 'prop_kitch_counter_01' },
    { label = 'Counter 02', model = 'prop_kitch_juicer' },
    { label = 'Counter 03', model = 'prop_kitch_pot_fry' },
    { label = 'Counter 04', model = 'prop_kitch_pot_huge' },
    { label = 'Toaster', model = 'prop_toaster_01' },
    { label = 'Blender', model = 'prop_blender_01' },
    { label = 'Cutting Board', model = 'prop_cs_kitchen_cab_l' },
    { label = 'Knife Block', model = 'v_res_knifeblock' },
    { label = 'Mug Rack', model = 'prop_mug_01' },
    { label = 'Mug Rack 02', model = 'prop_mug_02' },
    { label = 'Plate Rack', model = 'prop_plate_01' },
    { label = 'Pan', model = 'prop_pot_03' },
    { label = 'Pot', model = 'prop_pot_02' },
    { label = 'Gas Bottle', model = 'prop_gascyl_01a' },
    { label = 'Gas Bottle 02', model = 'prop_gascyl_04a' },
  }
},

{
  category = 'Elektronik / Müzik / Oyun',
  items = {
    { label = 'TV Flat 01', model = 'prop_tv_flat_01' },
    { label = 'TV Flat 02', model = 'prop_tv_flat_02' },
    { label = 'TV Flat 03', model = 'prop_tv_flat_03' },
    { label = 'TV Small 01', model = 'prop_tv_03' },
    { label = 'TV Small 02', model = 'prop_tv_05' },
    { label = 'TV Small 03', model = 'prop_tv_06' },
    { label = 'Laptop 01', model = 'prop_laptop_01a' },
    { label = 'Laptop 02', model = 'prop_laptop_lester2' },
    { label = 'Laptop 03', model = 'p_amb_lap_top_02' },
    { label = 'Monitor 01', model = 'prop_monitor_01a' },
    { label = 'Monitor 02', model = 'prop_monitor_01b' },
    { label = 'Monitor 03', model = 'prop_monitor_02' },
    { label = 'PC Tower', model = 'prop_pc_01a' },
    { label = 'Keyboard', model = 'prop_keyboard_01a' },
    { label = 'Mouse', model = 'prop_cs_mouse_01' },
    { label = 'Printer 01', model = 'prop_printer_01' },
    { label = 'Printer 02', model = 'prop_printer_02' },
    { label = 'Speaker 01', model = 'prop_speaker_01' },
    { label = 'Speaker 02', model = 'prop_speaker_02' },
    { label = 'Speaker 03', model = 'prop_speaker_03' },
    { label = 'Speaker 04', model = 'prop_speaker_05' },
    { label = 'Boom Box 01', model = 'prop_boombox_01' },
    { label = 'Boom Box 02', model = 'prop_cs_cctv' },
    { label = 'DJ Deck 01', model = 'prop_dj_deck_01' },
    { label = 'DJ Deck 02', model = 'prop_dj_deck_02' },
    { label = 'Arcade Machine 01', model = 'prop_arcade_01' },
    { label = 'Arcade Machine 02', model = 'prop_arcade_02' },
    { label = 'Arcade Machine 03', model = 'prop_arcade_03' },
    { label = 'Arcade Machine 04', model = 'prop_arcade_04' },
    { label = 'Phone 01', model = 'prop_phone_ing' },
    { label = 'Phone 02', model = 'prop_phone_cs_frank' },
    { label = 'Radio', model = 'prop_radio_01' },
    { label = 'Camera', model = 'prop_cctv_cam_01a' },
    { label = 'Camera 02', model = 'prop_cctv_cam_04a' },
  }
},

{
  category = 'Ev / Yatak Odası / Banyo',
  items = {
    { label = 'Bed 01', model = 'prop_bed_01' },
    { label = 'Bed 02', model = 'prop_bed_02' },
    { label = 'Bed 03', model = 'prop_bed_03' },
    { label = 'Bed 04', model = 'prop_bed_04' },
    { label = 'Wardrobe 01', model = 'p_cs_locker_01' },
    { label = 'Wardrobe 02', model = 'prop_ld_int_safe_01' },
    { label = 'Drawer 01', model = 'prop_devin_box_closed' },
    { label = 'Drawer 02', model = 'v_res_d_dressingtable' },
    { label = 'Nightstand 01', model = 'v_res_mdbedtable' },
    { label = 'Nightstand 02', model = 'v_res_tre_sideboard' },
    { label = 'Laundry Basket', model = 'prop_ld_laundry_basket' },
    { label = 'Toilet 01', model = 'prop_ld_toilet_01' },
    { label = 'Toilet 02', model = 'prop_toilet_01' },
    { label = 'Sink Bathroom 01', model = 'prop_sink_04' },
    { label = 'Sink Bathroom 02', model = 'prop_sink_05' },
    { label = 'Bath 01', model = 'prop_bath_01' },
    { label = 'Shower 01', model = 'prop_shower_rack_01' },
    { label = 'Towel Rail', model = 'prop_towel_rail_01' },
    { label = 'Towel Set', model = 'prop_towel_01' },
    { label = 'Hair Dryer', model = 'prop_cs_hairdryer' },
    { label = 'Iron Board', model = 'prop_iron_01' },
    { label = 'Iron', model = 'prop_iron_03' },
    { label = 'Laundry Machine', model = 'prop_washer_01' },
    { label = 'Dryer', model = 'prop_washer_02' },
  }
},

{
  category = 'Ofis / İş Yeri',
  items = {
    { label = 'Desk Office 01', model = 'prop_office_desk_01' },
    { label = 'Desk Office 02', model = 'prop_office_desk_02' },
    { label = 'Chair Office 01', model = 'prop_off_chair_01' },
    { label = 'Chair Office 02', model = 'prop_off_chair_03' },
    { label = 'Chair Office 03', model = 'prop_off_chair_04' },
    { label = 'Chair Office 04', model = 'prop_off_chair_04_s' },
    { label = 'Cabinet 01', model = 'prop_fib_3b_bench' },
    { label = 'Cabinet 02', model = 'prop_fib_cabinet_01' },
    { label = 'Cabinet 03', model = 'prop_fib_cabinet_02' },
    { label = 'Filing Cabinet 01', model = 'prop_fbibombfile' },
    { label = 'Whiteboard', model = 'prop_whiteboard' },
    { label = 'Projector', model = 'prop_projector_overlay' },
    { label = 'Desk Fan', model = 'prop_fan_01' },
    { label = 'Wall Fan', model = 'prop_fan_palm_01a' },
    { label = 'Safe 01', model = 'prop_ld_int_safe_01' },
    { label = 'Safe 02', model = 'p_v_43_safe_s' },
    { label = 'Briefcase', model = 'prop_ld_case_01' },
    { label = 'Clipboard', model = 'p_amb_clipboard_01' },
    { label = 'Paper Box', model = 'prop_boxpaper_01a' },
    { label = 'Paper Box 02', model = 'prop_boxpaper_02a' },
    { label = 'Paper Box 03', model = 'prop_boxpaper_03a' },
  }
},

{
  category = 'Fight Club / Spor',
  items = {
    { label = 'Boxing Bag 01', model = 'prop_boxing_bag_01' },
    { label = 'Boxing Bag 02', model = 'prop_boxing_bag_01b' },
    { label = 'Weight Rack 01', model = 'prop_weight_rack_01' },
    { label = 'Weight Bench', model = 'prop_weight_bench_02' },
    { label = 'Punching Bench', model = 'prop_bench_press_01' },
    { label = 'Gym Bench 01', model = 'prop_muscle_bench_03' },
    { label = 'Gym Bench 02', model = 'prop_muscle_bench_04' },
    { label = 'Gym Bench 03', model = 'prop_muscle_bench_05' },
    { label = 'Dumbbell Set', model = 'prop_weight_squat' },
    { label = 'Barbell', model = 'prop_barbell_01' },
    { label = 'Gym Bike', model = 'prop_exercisebike' },
    { label = 'Treadmill', model = 'prop_treadmill_01' },
    { label = 'Yoga Mat 01', model = 'prop_yoga_mat_01' },
    { label = 'Yoga Mat 02', model = 'prop_yoga_mat_02' },
    { label = 'Yoga Mat 03', model = 'prop_yoga_mat_03' },
    { label = 'Locker 01', model = 'p_cs_locker_01' },
    { label = 'Locker 02', model = 'prop_ld_int_safe_01' },
    { label = 'Bench Crowd 01', model = 'prop_bench_01a' },
    { label = 'Bench Crowd 02', model = 'prop_bench_03' },
    { label = 'Ring Bell Table', model = 'prop_table_03b' },
    { label = 'Industrial Light Gym', model = 'prop_ind_light_02a' },
  }
},

{
  category = 'Depo / Industrial / Tamirhane',
  items = {
    { label = 'Crate 01', model = 'prop_box_wood01a' },
    { label = 'Crate 02', model = 'prop_box_wood02a' },
    { label = 'Crate 03', model = 'prop_box_wood03a' },
    { label = 'Crate 04', model = 'prop_box_wood04a' },
    { label = 'Crate 05', model = 'prop_box_wood05a' },
    { label = 'Crate 06', model = 'prop_box_wood06a' },
    { label = 'Crate 07', model = 'prop_box_wood07a' },
    { label = 'Pallet 01', model = 'prop_pallet_01a' },
    { label = 'Pallet 02', model = 'prop_pallet_02a' },
    { label = 'Pallet 03', model = 'prop_pallet_03a' },
    { label = 'Pallet 04', model = 'prop_pallet_04a' },
    { label = 'Barrel 01', model = 'prop_barrel_01a' },
    { label = 'Barrel 02', model = 'prop_barrel_02a' },
    { label = 'Barrel 03', model = 'prop_barrel_03a' },
    { label = 'Gas Canister 01', model = 'prop_gascyl_01a' },
    { label = 'Gas Canister 02', model = 'prop_gascyl_02a' },
    { label = 'Gas Canister 03', model = 'prop_gascyl_03a' },
    { label = 'Gas Canister 04', model = 'prop_gascyl_04a' },
    { label = 'Tool Chest 01', model = 'prop_toolchest_01' },
    { label = 'Tool Chest 02', model = 'prop_toolchest_02' },
    { label = 'Tool Box 01', model = 'prop_tool_box_04' },
    { label = 'Tool Box 02', model = 'prop_tool_box_05' },
    { label = 'Work Light 01', model = 'prop_worklight_01a' },
    { label = 'Work Light 02', model = 'prop_worklight_02a' },
    { label = 'Work Light 03', model = 'prop_worklight_03a' },
    { label = 'Work Light 04', model = 'prop_worklight_04a' },
    { label = 'Generator 01', model = 'prop_generator_01a' },
    { label = 'Generator 02', model = 'prop_generator_02a' },
    { label = 'Air Con 01', model = 'prop_aircon_m_02' },
    { label = 'Air Con 02', model = 'prop_aircon_l_03' },
    { label = 'Compressor', model = 'prop_compressor_03' },
    { label = 'Engine Hoist', model = 'prop_engine_hoist' },
    { label = 'Hydraulic Lift', model = 'prop_carjack' },
    { label = 'Mechanic Creeper', model = 'prop_cs_cardbox_01' },
    { label = 'Forklift', model = 'prop_forklift_01' },
    { label = 'Pump 01', model = 'prop_waterpump' },
    { label = 'Pump 02', model = 'prop_pump_1a' },
    { label = 'Welding Tank', model = 'prop_welding_mask_01' },
    { label = 'Scrap Metal 01', model = 'prop_rub_scrap_02' },
    { label = 'Scrap Metal 02', model = 'prop_rub_scrap_03' },
    { label = 'Scrap Metal 03', model = 'prop_rub_scrap_04' },
  }
},

{
  category = 'Dış Mekan / Sokak / Kulüp',
  items = {
    { label = 'Street Bench 01', model = 'prop_bench_01a' },
    { label = 'Street Bench 02', model = 'prop_bench_01b' },
    { label = 'Street Bench 03', model = 'prop_bench_01c' },
    { label = 'Street Bench 04', model = 'prop_bench_02' },
    { label = 'Street Bench 05', model = 'prop_bench_03' },
    { label = 'Street Bench 06', model = 'prop_bench_04' },
    { label = 'Parasol 01', model = 'prop_parasol_01' },
    { label = 'Parasol 02', model = 'prop_parasol_02' },
    { label = 'Parasol 03', model = 'prop_parasol_03' },
    { label = 'Patio Heater', model = 'prop_patio_heater_01' },
    { label = 'Ash Bin', model = 'prop_bin_07a' },
    { label = 'Wheelie Bin 01', model = 'prop_bin_08a' },
    { label = 'Wheelie Bin 02', model = 'prop_bin_10a' },
    { label = 'Dumpster 01', model = 'prop_dumpster_01a' },
    { label = 'Dumpster 02', model = 'prop_dumpster_02a' },
    { label = 'Dumpster 03', model = 'prop_dumpster_02b' },
    { label = 'Dumpster 04', model = 'prop_dumpster_3a' },
    { label = 'Cone 01', model = 'prop_roadcone01a' },
    { label = 'Cone 02', model = 'prop_roadcone02a' },
    { label = 'Cone 03', model = 'prop_mp_cone_01' },
    { label = 'Traffic Barrier', model = 'prop_mp_barrier_01' },
    { label = 'Arrow Barrier', model = 'prop_mp_arrow_barrier_01' },
    { label = 'Queue Barrier 01', model = 'prop_barrier_wat_03a' },
    { label = 'Queue Barrier 02', model = 'prop_barier_conc_05c' },
    { label = 'Speaker Stack 01', model = 'prop_speaker_06' },
    { label = 'Speaker Stack 02', model = 'prop_speaker_07' },
    { label = 'Speaker Stack 03', model = 'prop_speaker_08' },
    { label = 'Speaker Stack 04', model = 'prop_clubset' },
    { label = 'Disco Ball', model = 'prop_ld_greenscreen_01' },
    { label = 'Club Light 01', model = 'prop_wall_light_05a' },
    { label = 'Club Light 02', model = 'prop_wall_light_05c' },
    { label = 'Club Light 03', model = 'prop_wall_light_05a' },
    { label = 'Rope Barrier 01', model = 'p_gold_hoops' },
    { label = 'Stage Speaker', model = 'prop_speaker_05' },
  }
},

}
-- ============================================================
-- lr_properties parity additions
-- ============================================================
Config.Locale = Config.Locale or 'tr'
Config.MaxObjects = Config.MaxObjects or 300
Config.RenderDistance = Config.RenderDistance or 80.0
Config.CacheExpire = Config.CacheExpire or 30000
Config.Currency = Config.Currency or Config.MoneyType or 'cash'
Config.CommandRealtor = Config.CommandRealtor or 'realtor'
Config.AdminAce = Config.AdminAce or 'command.admin'

Config.Bucket = Config.Bucket or {
  enabled = true,
  base = Config.BucketBase or 200000,
  lockdown = 'strict',
  populationEnabled = false,
}
Config.Bucket.base = Config.Bucket.base or Config.BucketBase or 200000

Config.ShellBase = Config.ShellBase or vector3(-1700.0, -1150.0, 100.0)
Config.ShellFallbackModel = Config.ShellFallbackModel or 'imp_prop_impexp_intintnceil'

Config.Thumbnails = Config.Thumbnails or {
  enabled = true,
  localPack = true,
  cdn = '',
}

Config.AccessPoint = Config.AccessPoint or {
  ghostModel = 'prop_cs_cardbox_01',
  openKey = 38,
  drawDist = 6.0,
  interactDist = 1.6,
  targetZoneSize = vector3(1.2, 1.2, 2.0),
  targetZoneDistExtra = 0.4,
  markers = {
    storage = { label = 'Depo', color = { r = 255, g = 159, b = 10 } },
    wardrobe = { label = 'Dolap', color = { r = 90, g = 200, b = 250 } },
    safe = { label = 'Kasa', color = { r = 120, g = 220, b = 140 } },
  }
}

Config.Editor = Config.Editor or {
  camSpeed = 0.35,
  camSpeedFast = 1.1,
  camSpeedSlow = 0.12,
  lookSens = 6.0,
  rotateStep = 2.0,
  rotateStepFast = 15.0,
  surfaceSnap = true,
  gridSize = 0.1,
  placeDistance = 6.0,
}

Config.Interaction = Config.Interaction or {
  mode = 'target',
  markerType = 36,
  markerSize = vector3(0.3, 0.3, 0.3),
  markerColor = { r = 120, g = 170, b = 255, a = 180 },
  drawDist = 8.0,
  interactDist = 1.6,
  interactKey = 38,
  command = 'property',
  targetLabel = 'Mülk',
  targetIcon = 'fas fa-house',
  menuCommand = 'propmenu',
  menuKey = 'F6',
}

Config.Ownership = Config.Ownership or {
  allowBuy = true,
  allowRent = true,
  rentInterval = 7 * 24 * 60 * 60,
  rentGraceMisses = 1,
}

Config.Commission = Config.Commission or {
  enabled = true,
  percent = 5.0,
  fromBuyer = false,
}

Config.Tax = Config.Tax or {
  enabled = true,
  interval = 7 * 24 * 60 * 60,
  houseRate = 0.01,
  businessRate = 0.02,
  minTax = 100,
  graceMisses = 2,
}

Config.Business = Config.Business or {
  entryFeeMax = 5000,
  payrollInterval = 7 * 24 * 60 * 60,
  maxEmployees = 15,
  grades = {
    [0] = { label = 'Çalışan', canManageStash = true, canLock = false, canDecorate = false, canManageStaff = false },
    [1] = { label = 'Müdür', canManageStash = true, canLock = true, canDecorate = true, canManageStaff = false },
    [2] = { label = 'Ortak', canManageStash = true, canLock = true, canDecorate = true, canManageStaff = true },
  },
}

Config.Keys = Config.Keys or {
  maxHolders = 20,
  doorbell = true,
  knockKey = 38,
}

Config.Storage = Config.Storage or {
  house = { slots = 50, weight = 100000 },
  business = { slots = 80, weight = 200000 },
}
Config.StashSize = Config.StashSize or Config.Storage.house.slots
Config.StashWeight = Config.StashWeight or Config.Storage.house.weight

Config.Wardrobe = Config.Wardrobe or {
  openEvent = 'yg_properties:client:openWardrobe',
}

Config.Gizmo = Config.Gizmo or {
  moveStep = 0.01,
  moveStepFast = 0.10,
  rotStep = 1.0,
  rotStepFast = 15.0,
  gridSize = 0.25,
  raycastDist = 10.0,
  keys = {
    confirm = 191,
    cancel = 194,
    toggleMode = 19,
    snapGrid = 47,
    snapSurf = 29,
    undo = 20,
    redo = 21,
    copy = 55,
    fast = 21,
    xPlus = 174, xMinus = 175,
    yPlus = 172, yMinus = 173,
    zPlus = 10, zMinus = 11,
  }
}

Config.Notify = Config.Notify or {
  duration = 4500,
  position = 'top-right',
}

Config.InteriorCatalog = Config.InteriorCatalog or {
  -- ---------- IPL Daireler ----------
  {
    id    = 'eclipse_1',
    kind  = 'ipl',
    label = 'Eclipse Towers - Tip 1',
    cat   = 'apartment',
    thumb = 'eclipse_1.png',
    ipl   = { 'apa_v_mp_h_01_a' },
    spawn = vector4(-773.07, 341.49, 213.39, 175.0),
    exit  = vector3(-773.5, 332.4, 213.0),
  },
  {
    id    = 'eclipse_2',
    kind  = 'ipl',
    label = 'Eclipse Towers - Tip 2',
    cat   = 'apartment',
    thumb = 'eclipse_2.png',
    ipl   = { 'apa_v_mp_h_01_c' },
    spawn = vector4(-786.87, 315.75, 217.64, 180.0),
    exit  = vector3(-786.9, 315.6, 216.0),
  },
  {
    id    = 'eclipse_3',
    kind  = 'ipl',
    label = 'Eclipse Towers - Tip 3',
    cat   = 'apartment',
    thumb = 'eclipse_3.png',
    ipl   = { 'apa_v_mp_h_02_a' },
    spawn = vector4(-781.41, 334.32, 207.63, 270.0),
    exit  = vector3(-783.5, 334.3, 206.5),
  },
  {
    id    = 'tinsel_1',
    kind  = 'ipl',
    label = 'Tinsel Towers',
    cat   = 'apartment',
    thumb = 'tinsel_1.png',
    ipl   = { 'apa_v_mp_h_08_a' },
    spawn = vector4(-614.86, 40.65, 97.6, 0.0),
    exit  = vector3(-614.8, 39.5, 96.5),
  },
  {
    id    = 'stilt_apartment',
    kind  = 'ipl',
    label = 'Vinewood Villa (Kazık Ev)',
    cat   = 'apartment',
    thumb = 'stilt_apartment.png',
    ipl   = { 'apa_v_mp_h_04_c' },
    spawn = vector4(-174.19, 497.62, 137.66, 115.0),
    exit  = vector3(-173.0, 496.0, 136.5),
  },
  -- ---------- IPL Ofisler ----------
  {
    id    = 'office_1',
    kind  = 'ipl',
    label = 'Yönetici Ofisi',
    cat   = 'office',
    thumb = 'office_1.png',
    ipl   = { 'ex_dt1_02_office_01a' },
    spawn = vector4(-141.23, -620.74, 168.82, 95.0),
    exit  = vector3(-138.0, -621.0, 168.8),
  },
  {
    id    = 'office_maze',
    kind  = 'ipl',
    label = 'Maze Bank Ofisi',
    cat   = 'office',
    thumb = 'office_maze.png',
    ipl   = { 'ex_dt1_11_office_01a' },
    spawn = vector4(-75.85, -826.95, 243.39, 0.0),
    exit  = vector3(-75.8, -825.0, 242.0),
  },
  {
    id    = 'office_lomback',
    kind  = 'ipl',
    label = 'Lombank Ofisi',
    cat   = 'office',
    thumb = 'office_lomback.png',
    ipl   = { 'ex_sm_13_office_01a' },
    spawn = vector4(-1579.76, -565.07, 108.52, 90.0),
    exit  = vector3(-1579.0, -565.0, 107.5),
  },
  {
    id    = 'office_arcadius',
    kind  = 'ipl',
    label = 'Arcadius Business Center',
    cat   = 'office',
    thumb = 'office_arcadius.png',
    ipl   = { 'ex_dt1_02_office_02b' },
    spawn = vector4(-139.24, -593.11, 168.81, 100.0),
    exit  = vector3(-138.0, -591.0, 167.5),
  },
  {
    id    = 'lifeinvader',
    kind  = 'ipl',
    label = 'Lifeinvader Ofisi',
    cat   = 'office',
    thumb = 'lifeinvader.png',
    ipl   = { 'facelobby' },
    spawn = vector4(-1082.9, -251.27, 37.76, 30.0),
    exit  = vector3(-1085.0, -249.0, 36.5),
  },
  -- ---------- IPL Garajlar ----------
  {
    id    = 'garage_m',
    kind  = 'ipl',
    label = 'Orta Garaj',
    cat   = 'garage',
    thumb = 'garage_m.png',
    ipl   = { 'imp_dt1_02_cargarage_a' },
    spawn = vector4(-126.5, -636.0, 168.5, 90.0),
    exit  = vector3(-123.0, -636.0, 168.5),
  },
  -- ---------- IPL Kulüpler ----------
  {
    id    = 'biker_club',
    kind  = 'ipl',
    label = 'Motosiklet Kulübü (MC)',
    cat   = 'clubhouse',
    thumb = 'biker_club.png',
    ipl   = { 'bkr_biker_interior_placement_interior_0_biker_dlc_int_01_milo_' },
    spawn = vector4(1107.04, -3157.4, -37.52, 0.0),
    exit  = vector3(1107.0, -3156.0, -38.5),
  },
  -- ---------- IPL Yasadışı ----------
  {
    id    = 'cocaine_lockup',
    kind  = 'ipl',
    label = 'Kokain Deposu',
    cat   = 'illegal',
    thumb = 'cocaine_lockup.png',
    ipl   = { 'bkr_biker_interior_placement_interior_1_biker_dlc_int_02_milo_' },
    spawn = vector4(1093.5, -3194.88, -38.99, 180.0),
    exit  = vector3(1088.7, -3187.5, -39.9),
  },
  {
    id    = 'meth_lab',
    kind  = 'ipl',
    label = 'Meth Laboratuvarı',
    cat   = 'illegal',
    thumb = 'meth_lab.png',
    ipl   = { 'bkr_biker_interior_placement_interior_2_biker_dlc_int_03_milo_' },
    spawn = vector4(1005.65, -3200.36, -38.51, 180.0),
    exit  = vector3(997.0, -3200.7, -39.0),
  },
  {
    id    = 'weed_farm',
    kind  = 'ipl',
    label = 'Esrar Serası',
    cat   = 'illegal',
    thumb = 'weed_farm.png',
    ipl   = { 'bkr_biker_interior_placement_interior_3_biker_dlc_int_04_milo_' },
    spawn = vector4(1051.49, -3196.53, -39.14, 90.0),
    exit  = vector3(1066.0, -3183.4, -40.0),
  },
  {
    id    = 'counterfeit_cash',
    kind  = 'ipl',
    label = 'Sahte Para Matbaası',
    cat   = 'illegal',
    thumb = 'counterfeit_cash.png',
    ipl   = { 'bkr_biker_interior_placement_interior_4_biker_dlc_int_05_milo_' },
    spawn = vector4(1121.2, -3194.52, -40.39, 270.0),
    exit  = vector3(1114.3, -3193.3, -41.0),
  },
  {
    id    = 'document_forgery',
    kind  = 'ipl',
    label = 'Sahte Evrak Ofisi',
    cat   = 'illegal',
    thumb = 'document_forgery.png',
    ipl   = { 'bkr_biker_interior_placement_interior_5_biker_dlc_int_06_milo_' },
    spawn = vector4(1163.84, -3192.83, -39.01, 0.0),
    exit  = vector3(1167.3, -3190.0, -40.0),
  },
  {
    id    = 'bunker',
    kind  = 'ipl',
    label = 'Yeraltı Sığınağı (Bunker)',
    cat   = 'illegal',
    thumb = 'bunker.png',
    ipl   = { 'gr_case6_bunker_interior_placement_bunker_interior_0_gr_bunker_milo_' },
    spawn = vector4(892.63, -3245.86, -98.26, 0.0),
    exit  = vector3(889.0, -3244.0, -99.0),
  },
  {
    id    = 'facility_doomsday',
    kind  = 'ipl',
    label = 'Doomsday Tesisi',
    cat   = 'illegal',
    thumb = 'facility_doomsday.png',
    ipl   = { 'xm_bunker_interior_placement_interior_0_xm_bunker_milo_' },
    spawn = vector4(483.51, -3200.04, -98.85, 180.0),
    exit  = vector3(484.0, -3190.0, -100.0),
  },
  -- ---------- IPL Eğlence ----------
  {
    id    = 'nightclub',
    kind  = 'ipl',
    label = 'Gece Kulübü',
    cat   = 'entertainment',
    thumb = 'nightclub.png',
    ipl   = { 'ba_case1_nightclub_interior_placement_interior_0_dlc_int_01_milo_' },
    spawn = vector4(-1604.66, -3012.58, -78.0, 0.0),
    exit  = vector3(-1601.0, -3010.0, -79.0),
  },
  {
    id    = 'arcade',
    kind  = 'ipl',
    label = 'Atari Salonu (Arcade)',
    cat   = 'entertainment',
    thumb = 'arcade.png',
    ipl   = { 'ch_chint01_ba_milo_' },
    spawn = vector4(2730.0, -373.0, -48.0, 4.0),
    exit  = vector3(2727.0, -365.0, -49.0),
  },
  {
    id    = 'strip_club',
    kind  = 'ipl',
    label = 'Vanilla Unicorn',
    cat   = 'entertainment',
    thumb = 'strip_club.png',
    ipl   = { 'v_stripclub' },
    spawn = vector4(108.31, -1289.47, 29.25, 290.0),
    exit  = vector3(106.0, -1294.0, 28.0),
  },
  {
    id    = 'comedy_club',
    kind  = 'ipl',
    label = 'Split Sides Comedy Club',
    cat   = 'entertainment',
    thumb = 'comedy_club.png',
    ipl   = { 'v_comedy' },
    spawn = vector4(-430.0, 261.0, 83.0, 0.0),
    exit  = vector3(-428.0, 263.0, 82.0),
  },
  -- ---------- IPL Depolar ----------
  {
    id    = 'vehicle_warehouse',
    kind  = 'ipl',
    label = 'Araç İthalat/İhracat Deposu',
    cat   = 'warehouse',
    thumb = 'vehicle_warehouse.png',
    ipl   = { 'imp_impexp_interior_placement_interior_1_impexp_int_02_milo_' },
    spawn = vector4(994.59, -3002.59, -39.64, 270.0),
    exit  = vector3(971.0, -2990.0, -40.0),
  },
  -- ---------- IPL Atölyeler ----------
  {
    id    = 'arena_workshop',
    kind  = 'ipl',
    label = 'Arena Workshop',
    cat   = 'workshop',
    thumb = 'arena_workshop.png',
    ipl   = { 'xs_arena_interior_vip' },
    spawn = vector4(-281.76, -2028.98, 29.15, 0.0),
    exit  = vector3(-282.0, -2025.0, 28.0),
  },
  {
    id    = 'autoshop_tuners',
    kind  = 'ipl',
    label = 'LS Tuners - Auto Shop',
    cat   = 'workshop',
    thumb = 'autoshop_tuners.png',
    ipl   = { 'tr_tuner_shop_interior_placement_interior_0_tr_tuner_shop_milo_' },
    spawn = vector4(2690.0, -370.0, -55.0, 0.0),
    exit  = vector3(2700.0, -360.0, -56.0),
  },
}

Config.InteriorCategories = Config.InteriorCategories or {
  { id = 'apartment',     label = 'Daireler'   },
  { id = 'office',        label = 'Ofisler'    },
  { id = 'garage',        label = 'Garajlar'   },
  { id = 'clubhouse',     label = 'Kulüpler'   },
  { id = 'illegal',       label = 'Yasadışı'   },
  { id = 'entertainment', label = 'Eğlence'    },
  { id = 'warehouse',     label = 'Depolar'    },
  { id = 'workshop',      label = 'Atölyeler'  },
  { id = 'shell',         label = 'Shell\'ler' },
  { id = 'custom',        label = 'Custom'     },
}

Config.InteriorById = Config.InteriorById or {}
for _, it in ipairs(Config.InteriorCatalog) do
  Config.InteriorById[it.id] = it
end

Config.CatalogCategories = Config.CatalogCategories or {}
Config.Catalog = Config.Catalog or {}
Config.CatalogByModel = Config.CatalogByModel or {}

if #Config.Catalog == 0 and type(Config.BuildCatalog) == 'table' then
  for _, category in ipairs(Config.BuildCatalog) do
    Config.CatalogCategories[#Config.CatalogCategories + 1] = {
      id = tostring(category.category or ('cat_' .. tostring(#Config.CatalogCategories + 1))):gsub('%s+', '_'):lower(),
      label = category.category or 'Kategori',
    }

    local catId = Config.CatalogCategories[#Config.CatalogCategories].id
    for _, item in ipairs(category.items or {}) do
      local entry = {
        name = item.label,
        model = item.model,
        cat = catId,
        thumb = ('%s.png'):format(item.model),
      }
      Config.Catalog[#Config.Catalog + 1] = entry
      Config.CatalogByModel[item.model] = entry
    end
  end
end

Config.DefaultPermissions.employeesCanEnter = Config.DefaultPermissions.employeesCanEnter == true
Config.DefaultPermissions.employeesCanManage = Config.DefaultPermissions.employeesCanManage == true
Config.DefaultPermissions.employeesCanManageDoor = Config.DefaultPermissions.employeesCanManageDoor == true
Config.DefaultPermissions.employeesCanSetEntryFee = Config.DefaultPermissions.employeesCanSetEntryFee == true
Config.DefaultPermissions.employeesCanEditDescription = Config.DefaultPermissions.employeesCanEditDescription == true
Config.DefaultPermissions.employeesCanBuild = Config.DefaultPermissions.employeesCanBuild ~= false
Config.DefaultPermissions.employeesCanDeposit = Config.DefaultPermissions.employeesCanDeposit == true
Config.DefaultPermissions.employeesCanWithdraw = Config.DefaultPermissions.employeesCanWithdraw == true
Config.DefaultPermissions.employeesCanManageEmployees = Config.DefaultPermissions.employeesCanManageEmployees == true
