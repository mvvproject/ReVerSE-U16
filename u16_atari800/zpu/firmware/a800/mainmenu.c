static const int main_ram_size=65536;
#include "main.h" //!!!
#include "atari_drive_emulator.h"
#include "log.h"

unsigned char freezer_rom_present;

#ifdef USB
#include "usb.h"
#endif

void loadosrom()
{
	if (file_size(files[5]) == 0x4000)
	{
		loadromfile(files[5],0x4000, ROM_OFS + 0x4000);
	}
	else if (file_size(files[5]) ==0x2800)
	{
		loadromfile(files[5],0x2800, ROM_OFS + 0x5800);
	}
}

#ifdef USB
struct usb_host usb_porta;
#endif
#ifdef USB2
struct usb_host usb_portb;
#endif

void mainmenu()
{
#ifdef USB
	usb_init(&usb_porta,0);
#endif
#ifdef USB2
	usb_init(&usb_portb,1);
#endif
	freezer_rom_present = 0;
	if (SimpleFile_OK == dir_init((void *)DIR_INIT_MEM, DIR_INIT_MEMSIZE))
	{
		init_drive_emulator();
		
		struct SimpleDirEntry * entries = dir_entries(ROM_DIR);
		
		//loadrom_indir(entries,"atarixl.rom",0x4000, (void *)0x704000);

		/*loadrom_indir(entries,"xlhias.rom",0x4000, (void *)0x708000);
		loadrom_indir(entries,"ultimon.rom",0x4000, (void *)0x70c000);
		loadrom_indir(entries,"osbhias.rom",0x4000, (void *)0x710000);
		loadrom_indir(entries,"osborig.rom",0x2800, (void *)0x715800);
		loadrom_indir(entries,"osaorig.rom",0x2800, (void *)0x719800);*/

		loadrom_indir(entries,"ataribas.rom",0x2000,ROM_OFS);
		if (SimpleFile_OK == file_open_name_in_dir(entries, "atarixl.rom", files[5]))
		{
			loadosrom();
		}

#ifdef HAVE_FREEZER_ROM_MEM
		if (SimpleFile_OK == file_open_name_in_dir(entries, "freezer.rom", files[6]))
		{
			enum SimpleFileStatus ok;
			int len;
			ok = file_read(files[6], FREEZER_ROM_MEM, 0x10000, &len);
			if (ok == SimpleFile_OK && len == 0x10000) {
				LOG("freezer rom loaded\n");
				freezer_rom_present = 1;
			} else {
				LOG("loading freezer rom failed\n");
				freezer_rom_present = 0;
			}
		} else {
			LOG("freezer.rom not found\n");
		}
#endif
		set_freezer_enable(freezer_rom_present);

		//ROM = xlorig.rom,0x4000, (void *)0x704000
		//ROM = xlhias.rom,0x4000, (void *)0x708000
		//ROM = ultimon.rom,0x4000, (void *)0x70c000
		//ROM = osbhias.rom,0x4000, (void *)0x710000
		//ROM = osborig.rom,0x2800, (void *)0x715800
		//ROM = osaorig.rom,0x2800, (void *)0x719800
		//
		//ROM = ataribas.rom,0x2000,(void *)0x700000

		//--SDRAM_BASIC_ROM_ADDR <= "111"&"000000"   &"00000000000000";
		//--SDRAM_OS_ROM_ADDR    <= "111"&rom_select &"00000000000000";
		reboot(1);
		run_drive_emulator();
	}
	else
	{
		//printf("DIR init failed\n");
	}
	reboot(1);
	for (;;) actions(1);
}

char const * get_ram()
{
	static char const * ram[] = 
	{
		"64K",
		"128K",
		"320K(Compy)",
		"320K(Rambo)",
		"576K(Compy)",
		"576K(Rambo)",
		"1MB",
		"4MB"
	};
	return ram[get_ram_select()];
	/*switch(get_ram_select())
	{
	case 0:
		return "64K";
	case 1:
		return "128K";
	case 2:
		return "320K(Compy)";
	case 3:
		return "320K(Rambo)";
	case 4:
		return "576K(Compy)";
	case 5:
		return "576K(Rambo)";
	case 6:
		return "1MB";
	case 7:
		return "4MB";
	}*/
}

int settings()
{
	struct joystick_status joy;
	joy.x_ = joy.y_ = joy.fire_ = joy.escape_ = 0;

	int row = 0;

	int done = 0;
	for (;!done;)
	{
		// Render
		clearscreen();
		debug_pos = 0;
		debug_adjust = 0;
		printf("Se");
		debug_adjust = 128;
		printf("ttings");
		debug_pos = 80;
		debug_adjust = row==0 ? 128 : 0;
		printf("CPU Turbo:%dx", get_turbo_6502());
		debug_pos = 120;
		debug_adjust = row==1 ? 128 : 0;
		printf("Drive Turbo:%s", get_turbo_drive_str());
		debug_pos = 160;
		debug_adjust = row==2 ? 128 : 0;
		printf("Ram:%s", get_ram());
		debug_pos = 200;
		debug_adjust = row==3 ? 128 : 0;
		{
			printf("Rom:%s", file_name(files[5]));
		}
		debug_pos = 280;
		int i;
		for (i=1;i!=5;++i)
		{
			int temp = debug_pos;
			debug_adjust = row==i+3 ? 128 : 0;
			char buffer[20];
			describe_disk(i-1,&buffer[0]);
			printf("Drive %d:%s %s", i, file_name(files[i-1]), &buffer[0]);
			debug_pos = temp+40;
		}

		debug_pos = 440;
		debug_adjust = row==8 ? 128 : 0;
		printf("Cart: %s", get_cart_select() ? file_name(files[4]) : "NONE");

		debug_pos = 520;
		debug_adjust = row==9 ? 128 : 0;
		printf("Load memory");

		debug_pos = 560;
		debug_adjust = row==10 ? 128 : 0;
		printf("Save memory (for debugging)");

		debug_pos = 640;
		debug_adjust = row==11 ? 128 : 0;
		printf("Exit");

		debug_pos = 720;
		debug_adjust = 128;
		printf("=== Reverse-U16 ===");


		// Slow it down a bit
		wait_us(100000);

		// move
		joystick_wait(&joy,WAIT_QUIET);
		joystick_wait(&joy,WAIT_EITHER);
		if (joy.escape_) break;

		row+=joy.y_;
		if (row<0) row = 0;
		if (row>11) row = 11;
		switch (row)
		{
		case 0:
			{
				int turbo = get_turbo_6502();
				if (joy.x_==1) turbo<<=1;
				if (joy.x_==-1) turbo>>=1;
				if (turbo>16) turbo = 16;
				if (turbo<1) turbo = 1;
				set_turbo_6502(turbo);
			}
			break;
		case 1:
			{
				int turbo = get_turbo_drive();
				turbo+=joy.x_;
				if (turbo<0) turbo = 0;
				if (turbo>7) turbo = 7;
				set_turbo_drive(turbo);
			}
			break;
		case 2:
			{
				int ram_select = get_ram_select();
				ram_select+=joy.x_;
				if (ram_select<0) ram_select = 0;
				if (ram_select>MAX_RAM_SELECT) ram_select = MAX_RAM_SELECT;
				set_ram_select(ram_select);
			}
			break;
		case 3:
			{
				if (joy.x_ || joy.fire_)
				{
					fil_type = fil_type_rom;
					filter = filter_specified;
					file_selector(files[5]);
					loadosrom();
				}
			}
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			{
				if (joy.x_>0)
				{
					// Choose new disk
					filter = filter_disks;
					file_selector(files[row-4]);
					set_drive_status(row-4,files[row-4]);
				}
				else if(joy.x_<0)
				{
					// Remove disk
					file_init(files[row-4]);
					set_drive_status(row-4,0);
				}
				else if (joy.fire_)
				{
					{
						// Swap files
						struct SimpleFile * temp = files[row-4];
						files[row-4] = files[0];
						files[0] = temp;
					}

					{
						// Swap disks
						struct SimpleFile * temp = get_drive_status(row-4);
						set_drive_status(row-4, get_drive_status(0));
						set_drive_status(0,temp);
					}
				}
			}
			break;
		case 8:
			{
				if (joy.x_>0) {
					fil_type = fil_type_car;
					filter = filter_specified;
					file_selector(files[4]);
					unsigned char mode = load_car(files[4]);
					set_cart_select(mode);
					if (mode) {
						return 1;
					}
				}
				else if (joy.x_<0) {
					file_init(files[4]);
					set_cart_select(0);
				}
			}
			break;
		case 9:
		case 10:
			{
				if (joy.fire_)
				{
					fil_type = fil_type_mem;
					filter = filter_specified;
					file_selector(files[6]);
					if (row == 9)
					{
						freeze_load(files[6]);
					}
					else if (row == 10)
					{
						freeze_save(files[6]);
					}
				}
			}
			break;
		case 11:
			if (joy.fire_)
			{
				done = 1;
			}
			break;
		}
	}

	return 0;
}

void actions()
{
#ifdef LINUX_BUILD
	check_keys();
#endif
#ifdef USB
	usb_poll(&usb_porta);
#endif
#ifdef USB2
	usb_poll(&usb_portb);
#endif

	// Show some activity!
	//*atari_colbk = *atari_random;
	
	// Hot keys
	if (get_hotkey_softboot())
	{
		reboot(0);	
	}
	else if (get_hotkey_coldboot())
	{
		reboot(1);	
	}
	else if (get_hotkey_settings())
	{
		set_pause_6502(1);
		set_freezer_enable(0);
		freeze();
		debug_pos = 0;	
		int do_reboot = settings();
		debug_pos = -1;
		restore();
		if (do_reboot)
			reboot(1);
		else {
			set_freezer_enable(freezer_rom_present);
			set_pause_6502(0);
		}
	}
	else if (get_hotkey_fileselect())
	{
/*#ifdef USB
		set_pause_6502(1);
		set_freezer_enable(0);
		freeze();

		debug_pos = 0;	
		printf("Hello USB");
		debug_pos = 80;
		usb_init();
		while (1)
		{
			usb_poll();
			if (debug_pos>1000)
			{
				debug_pos = 80;
			}
		}

		debug_pos = -1;
		restore();
		set_freezer_enable(freezer_rom_present);
		set_pause_6502(0);
#else*/
		set_pause_6502(1);
		set_freezer_enable(0);
		freeze();
		filter = filter_disks;
		file_selector(files[0]);
		debug_pos = -1;
		restore();
		set_drive_status(0,files[0]);
		reboot(1);
	}
}


