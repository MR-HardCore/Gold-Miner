module project2(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      KEY,
      SW,
		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];

	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire writeEn;
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			// Signals for the DAC to drive the monitor. 
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
			
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "start.mif";
		
wire [7:0]hook_x,hook_x_position;
wire [6:0]hook_y,hook_y_position;
wire [2:0]hook_color;
wire hook_plot;

wire [3:0]delay_cnt;
wire [5:0]pixel_cnt;
wire [3:0]delay_Time;

wire ini_x ,ini_y;
wire load_x,load_y;
wire load_hook,load_black;
wire pixel_count_en,delay_count_en;
wire delay_reset,	en_reset;
wire right,left,ver;
wire stop_x,stop_y;
wire draw_hook;
		
wire [15:0] count;
wire [5:0] gcount;
wire [2:0] gcolor;
wire [2:0] select;
wire [15:0] gposition;

wire g1t, g2t, g3t, g4t, g5t, touch;
wire reset, enable, GRegEnable, GRegEnable1, GRegEnable2, GRegEnable3, GRegEnable4, GRegEnable5, CntStart, drawg;
wire bresetn, benable, drawb;
wire finish;
wire [15:0]bcount;
wire [7:0]bx;
wire [7:0]by; 
wire [2:0]bcolor;
	 
wire drawf;
wire [15:0]fcount;
wire [2:0]fcolor;
wire [7:0]fx;
wire [7:0]fy;
wire plot_gold;

wire [3:0]score;

//Control path

control_path cp(CLOCK_50, KEY[1], KEY[2], count[15:0],
							g1t, g2t, g3t, g4t, g5t, finish,
							touch, hook_x, hook_y, 
							~SW[9], ~SW[8], KEY[3],
							pixel_cnt, delay_cnt,
							delay_Time,
							reset, enable, select[2:0], bresetn, benable,GRegEnable1, GRegEnable2, GRegEnable3, GRegEnable4, GRegEnable5,
							CntStart, drawg, drawb, drawf, writeEn,
							ini_x ,ini_y,load_x,load_hook,load_black,pixel_count_en,delay_count_en,
							delay_reset,en_reset,right,left,stop_x,draw_hook,load_y,ver,stop_y);		

//Gold data path
golddata datapath(CLOCK_50, reset, enable, select[2:0],
							GRegEnable1, GRegEnable2, GRegEnable3, GRegEnable4, GRegEnable5, CntStart,
							hook_x_position[7:0], hook_y_position[6:0], 
							gposition[15:0], gcolor[2:0], gcount[5:0], 
							g1t, g2t, g3t, g4t, g5t, touch);
							
//Hook data path	
hook_datapath hd(CLOCK_50,
							~en_reset,
							ini_x, ini_y,
							load_x,load_y,
							pixel_count_en ,delay_count_en,
							delay_reset,
							right,left,
							ver,
							stop_x, stop_y,
							load_black, load_hook,
							hook_x,hook_y,
							hook_x_position, hook_y_position,
							delay_cnt,pixel_cnt,
							hook_color);
		
//Drawing select
drawing drawmod (drawg, gcount[5:0], gposition[15:0], gcolor[2:0], 
							drawb,bcount[15:0], bx[7:0], by[7:0], bcolor[2:0], 
							drawf, fcount[15:0], fx[7:0], fy[7:0], fcolor[2:0],
							draw_hook, pixel_cnt[5:0], hook_x[7:0], hook_y[6:0], hook_color[2:0],
							x[7:0], y[7:0], colour[2:0], count[15:0]);		
		
		
		
//Basic background ram invoked			
backgrounddata backgrounddatapath(CLOCK_50, bresetn, benable, bx[7:0], by[7:0], bcolor[2:0], bcount[15:0]);
//Ending background ram invoked	
finalbackgrounddata gameover(CLOCK_50, bresetn, benable, fx[7:0], fy[7:0], fcolor[2:0], fcount[15:0]);	 

//Score control and HEX display
Cscore countscore(CLOCK_50, touch, KEY[2], score, finish);
	
hex7segment hex0(0, HEX0);
hex7segment hex1(score, HEX1);
hex7segment hex2(0, HEX2);
hex7segment hex3(0, HEX3);
hex7segment hex4(0, HEX4);
hex7segment hex5(0, HEX5);
							
endmodule
//Top module end


//Controlpath
module control_path (clock, go, start,CNT, g1t,g2t, g3t, g4t, g5t, finish, touch, X, Y, left_signal, right_signal, vertical_signal,
						pixel_count, delay_count, delay_time, resetn, enable, select,bresetn, benable,
						GRegEnable1,GRegEnable2,GRegEnable3, GRegEnable4, GRegEnable5, CntStart, drawg, drawb, drawf, 
						plot, ini_x ,ini_y,loadX,load_hook,load_black,pixel_count_en,delay_count_en,delay_reset,en_reset,
						right,left,stop_x,draw_hook,loadY,ver,stop_y);
	
	
	input clock;
	input go;
	input start;
	input [15:0]CNT;
	input g1t;
	input g2t;
	input g3t;
	input g4t;
	input g5t;
	input finish;
	input touch;
	
	input [7:0]X;
	input [6:0]Y;
	input left_signal, right_signal, vertical_signal;
	input[5:0] pixel_count;
	input[3:0] delay_count;
	input delay_time;
	
	output reg resetn,enable;
	output reg [2:0]select;
	output reg bresetn,benable, GRegEnable1,GRegEnable2,GRegEnable3,GRegEnable4, GRegEnable5; 
	output reg CntStart,drawg, drawb, drawf, plot;
	output reg ini_x ,ini_y,loadX,load_hook,load_black,pixel_count_en,delay_count_en,delay_reset,en_reset,right,left,stop_x,draw_hook;
	output reg loadY,ver,stop_y;
	
	reg done_ver;
	reg [5:0] curr;
	reg [5:0] next;
	
	parameter down = 1;
	parameter up = 0;
	
	//Background drawing and generating golds
	parameter [5:0]START = 0;
	parameter [5:0]INI = 1;
	parameter [5:0]LOAD = 2;
	parameter [5:0]DRAW_1 = 3;
	parameter [5:0]DRAW_2 = 4;
	parameter [5:0]DRAW_3 = 5;
	parameter [5:0]DRAW_4 = 6;
	parameter [5:0]DRAW_5 = 7;
	parameter [5:0]FINISH = 8;
	//Hook control
	parameter [5:0]INI_1 = 9;
	parameter [5:0]DRAW = 10;
	parameter [5:0]DONE = 11;
	parameter [5:0]ERASE_L = 12;
	parameter [5:0]LEFT = 13; 
	parameter [5:0]HOR_DRAW = 14; 
	parameter [5:0]HOR_CTRL = 15;
	parameter [5:0]ERASE_R = 16;
	parameter [5:0]RIGHT =17;
	parameter [5:0]HOR_LIMIT = 18;
	//After collide, re-draw a new gold
	parameter [5:0]VER =19;
	parameter [5:0]VER_DRAW = 20;
	parameter [5:0]VER_CTRL = 21;	
	parameter [5:0]KEEP = 22;
	parameter [5:0]VER_LIMIT = 23;
	parameter [5:0]LOAD_REVERSE = 24;
	parameter [5:0]DRAW_REVERSE = 25;
	parameter [5:0]WAIT = 26;
	parameter [5:0]ERASE_V = 27;
	parameter [5:0]GOLD = 28;
	parameter [5:0]BACK = 29;
	
	parameter [5:0]LOAD_1 = 30; 
	parameter [5:0]LOAD_2 = 31;
	parameter [5:0]LOAD_3 = 32; 
	parameter [5:0]LOAD_4 = 33;
	parameter [5:0]LOAD_5 = 34;
	parameter [5:0]DRAW_B = 35;
	parameter [5:0]DRAW_F = 36;
	parameter [5:0]NOMORE = 37;
	
	
	always@(*)
		begin: state_table
			case (curr)
				START:
					next = INI;
				
				INI:
					begin
					if (start)
						next = INI;
					else 
						next = LOAD;
					end
				
				LOAD:
					next = DRAW_B;
					
				DRAW_B: // Background display
					begin 
					if (CNT < 19119)
						next = DRAW_B;
					else 
						next = DRAW_1;
					end
					
				DRAW_1:
					begin
					if (CNT < 63)
						next = DRAW_1;
					else 
						next = DRAW_2;
					end
					
				DRAW_2:
					begin
					if (CNT < 63)
						next = DRAW_2;
					else 
						next = DRAW_3;
					end
					
				DRAW_3:
					begin
					if (CNT < 63)
						next = DRAW_3;
					else 
						next = DRAW_4;
					end
				
				DRAW_4:
					begin
					if (CNT < 63)
						next = DRAW_4;
					else 
						next = DRAW_5;
					end
					
				DRAW_5:
					begin
					if (CNT < 63)
						next = DRAW_5;
					else 
						next = FINISH;
					end
				
				FINISH:
					next = INI_1;
					
	//Gold drawing end
	//Start for hook move control
				
				INI_1:
					next = DRAW;
				DRAW:
					begin
					if(pixel_count < 63)
						next = DRAW;
					else
						next = DONE;
					end
				DONE:
					begin
					if(left_signal == 0 && X > 1)
						next = ERASE_L;
					else if(right_signal == 0 && X < 151)
						next = ERASE_R;
					else if(vertical_signal == 0)
						next = VER;
					else if(finish == 1)
						next = DRAW_F;
					else
						next = DONE;	
					end
				ERASE_L:
					begin
					if(pixel_count < 63)
						next = ERASE_L;
					else 
						next = LEFT;
					end
				LEFT:
					next = HOR_DRAW;
				HOR_DRAW:
					begin
					if(pixel_count < 63)
						next = HOR_DRAW;
					else
						next = HOR_CTRL;
					end
				HOR_CTRL:		
					begin
					if(delay_count < 5)
						next = HOR_CTRL;
					else
						next = HOR_LIMIT;
					end
				ERASE_R:
					begin
					if(pixel_count < 63)
						next = ERASE_R;
					else 
						next = RIGHT;
					end
				RIGHT:
					next = HOR_DRAW;
				HOR_LIMIT:
						next = DONE;
				VER:
					next = VER_DRAW;
				VER_DRAW:
					begin
					if(pixel_count < 63)
						next = VER_DRAW;
					else
						next = VER_CTRL;					
					end
				VER_CTRL:
					begin
					if(delay_count < 5)
						next = VER_CTRL;
					else
						next = VER_LIMIT;
					end
				KEEP:
					begin
					if(pixel_count < 63)
						next = KEEP;
					else
						next = VER_LIMIT;
					end
				VER_LIMIT:
					begin
					if(Y == 111)
						next = LOAD_REVERSE;
					else if( touch == 1) 
						next = GOLD;
					else
						next = VER;
					end
				LOAD_REVERSE:
					next = DRAW_REVERSE;
				DRAW_REVERSE:
					begin
					if(pixel_count < 63)
						next = DRAW_REVERSE;
					else
						next = WAIT;
					end
				WAIT:
					begin
					if(delay_count < 5)
						next = WAIT;
					else
						next = ERASE_V;
					end
				ERASE_V:
					begin
					if(pixel_count < 63)
						next = ERASE_V;
					else 
						next = BACK;
					end
				GOLD:
						begin
						if (g1t)
						next = LOAD_1;			
									
					else if (g2t)
						next = LOAD_2;
									
					else if (g3t)
						next = LOAD_3;
									
					else if (g4t)
						next = LOAD_4;
									
					else if (g5t)
						next = LOAD_5;
					end
				
				BACK:
					begin
					if(done_ver == 1)
						next = DRAW;
					else	
						next = LOAD_REVERSE;		
					end
				LOAD_1:
					next = DRAW_B;
							
				LOAD_2:
					next = DRAW_B;
							
				LOAD_3:
					next = DRAW_B;
							
				LOAD_4:
					next = DRAW_B;
							
				LOAD_5:
					next = DRAW_B;
					
				DRAW_F:
					begin 
					if (CNT < 19119)
					next = DRAW_F;
					else 
					next = NOMORE;
					end 
					
				NOMORE:
					next = NOMORE;
								
				default:
					next = START;
endcase
		end
	
	always@(*)
	begin: state_logic
	case (curr)
		START:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 0;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=1; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		INI:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0;
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		LOAD:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 1;
			GRegEnable2 = 1;
			GRegEnable3 = 1;
			GRegEnable4 = 1;
			GRegEnable5 = 1;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;			
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		
		DRAW_B:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 1;
			benable = 1;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 1;
			draw_hook = 0;
			plot = 1;			
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;			
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		DRAW_1:
			begin
			resetn = 1;
			enable = 1;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 1;
			drawb = 0;
			draw_hook = 0;
			plot = 1;		
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		DRAW_2:
			begin
			resetn = 1;
			enable = 1;
			bresetn = 0;
			benable = 0;
			select = 3'b001;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 1;
			drawb = 0;
			draw_hook = 0;
			plot = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		DRAW_3:
			begin
			resetn = 1;
			enable = 1;
			bresetn = 0;
			benable = 0;
			select = 3'b010;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 1;
			drawb = 0;
			draw_hook = 0;
			plot = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		DRAW_4:
			begin
			resetn = 1;
			enable = 1;
			bresetn = 0;
			benable = 0;
			select = 3'b011;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 1;
			drawb = 0;
			draw_hook = 0;
			plot = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0;
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		DRAW_5:
			begin
			resetn = 1;
			enable = 1;
			bresetn = 0;
			benable = 0;
			select = 3'b100;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 1;
			drawb = 0;
			draw_hook = 0;
			plot = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
	
		FINISH:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;

			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end	
			
		INI_1:
		begin
		
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 1;
			ini_y = 1;
			loadX = 0;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x= 1;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end

	DRAW:
		begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
	DONE:
		begin 
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 0;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end	
		ERASE_L:
		begin 
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 0; 
			load_hook = 0; 
			load_black = 1; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end	
	LEFT:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 1;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			en_reset=0; 
			right = 0;
			left = 1;
			stop_x = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
	HOR_DRAW:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 0;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
	HOR_CTRL:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 0; 
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 1;
			delay_reset = 1;
			plot = 0; 
			en_reset=0; 
			right = 0;
			left = 0;
	   	stop_x= 0; 
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		ERASE_R:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 0;
			load_hook = 0;
			load_black = 1; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end		
	RIGHT: 
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 1;
			load_hook = 1;
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			en_reset=0; 
			right = 1;
			left = 0;
			stop_x = 0; 
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end

	HOR_LIMIT: 
		begin
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;
			loadX = 1; 
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0;
			right = 0;
			left = 0;
			if(X == 7 | X == 151)
				stop_x = 1;
			else 
			stop_x = 0;
			en_reset=0; 
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
	VER:
	begin 
	resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			loadY = 1; 
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			en_reset=0; 
			ver = down;
			right = 0;
			left = 0;
			stop_x = 1;
			stop_y = 0;
			done_ver = 0;	
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end

	VER_DRAW:
	begin 
	resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1;
			ver = down;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	VER_CTRL:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 1;
			delay_reset = 1;
			plot = 0; 
			ver = down;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	KEEP:
	begin 
	resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			ver = down;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end		
	VER_LIMIT:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 1; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			ver = down;	
			stop_y = 1;	
			done_ver = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	LOAD_REVERSE:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 1;
			load_hook = 1; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			ver = up;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	DRAW_REVERSE:
		begin
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			ver = up;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	WAIT:
		begin 
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0;
			pixel_count_en = 0; 
			delay_count_en = 1;
			delay_reset = 1;
			plot = 0;
			ver = up;
			stop_y = 0;	
			done_ver = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
	ERASE_V:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0;
			load_black = 1;
			pixel_count_en = 1; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 1; 
			ver = up;
			stop_y = 0;
			done_ver = 0;
			draw_hook = 1;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end	
	GOLD:
	begin 
	resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0; 
			ver = up;
			stop_y = 0;
			done_ver = 1;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			end
			
	BACK:
		begin 
		resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			plot = 0;
			draw_hook = 0;
			drawg = 0;
			drawb = 0;
			drawf = 0;
			if(Y == 25)
			begin
				stop_y = 1;
				ver = down;
				done_ver = 1;
			end
			else 
			begin
				ver = up;
				stop_y = 0;	
				done_ver = 0;
			end
			end
			
		LOAD_1:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 1;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		
		LOAD_2:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 1;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;	
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		
		LOAD_3:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 1;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		LOAD_4:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 1;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0;
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
			
		LOAD_5:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 1;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0;
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		
		DRAW_F:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 1;
			benable = 1;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 1;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 1;
			end	
		
		NOMORE:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end	
		
		default:
			begin
			resetn = 0;
			enable = 0;
			bresetn = 0;
			benable = 0;
			select = 3'b000;
			GRegEnable1 = 0;
			GRegEnable2 = 0;
			GRegEnable3 = 0;
			GRegEnable4 = 0;
			GRegEnable5 = 0;
			CntStart = 1;
			drawg = 0;
			drawb = 0;
			draw_hook = 0;
			plot = 0;
			ini_x = 0;
			ini_y = 0;	
			loadX = 0;
			load_hook = 0; 
			load_black = 0; 
			pixel_count_en = 0; 
			delay_count_en = 0;
			delay_reset = 0;
			en_reset=0; 
			right = 0;
			left = 0;
			stop_x = 0;
			loadY = 0; 
			ver = down;
			stop_y = 0;
			done_ver = 0;
			drawf = 0;
			end
		
	
	endcase
	end
	
	always @(posedge clock)
	begin 
	if (!go)
		curr <= START;
	else 
		curr <= next;
	end
	
endmodule

//Hook datapath
module hook_datapath(clock,
							en_resetn,
							ini_x, ini_y,
							loadX,loadY,
							pixel_count_en ,delay_count_en,
							delay_reset,
							right,left,
							ver,
							stop_x, stop_y,
							load_black, load_hook,
							x_output,y_output,
							x_position,y_position,
							delay_cnt,pixel_cnt,
							colour);
							
input clock,
		en_resetn,
		ini_x, ini_y;
input loadX,loadY,
		pixel_count_en ,delay_count_en,
		delay_reset,
		right,left,
		ver, 
		stop_x, stop_y;
input load_black, load_hook;
	
output [7:0]x_output;
output [6:0]y_output;
output [3:0]delay_cnt;
output [5:0]pixel_cnt;
output [2:0]colour;
output [7:0]x_position;
output [6:0]y_position;

wire [2:0]h_colour;
wire time_output;
wire [5:0]address;	
		
//register for x 
register_X r1(clock,en_resetn,ini_x,loadX,right,left,stop_x,x_position);

//register for y
register_Y r2(clock,en_resetn,ini_y,loadY,ver,stop_y,y_position);

//counter for time
time_counter t1(clock,en_resetn,delay_count_en,time_output);
delay_counter d1(clock,delay_reset,time_output,delay_cnt);

//counter for pixel
pixel_counter p1(clock,en_resetn,pixel_count_en,pixel_cnt);

assign x_output = x_position[7:0] + {5'b0,pixel_cnt[2:0]};
assign y_output = y_position[6:0] + {4'b0,pixel_cnt[5:3]};

//hook ram 					
assign address = 8*pixel_cnt[5:3] + pixel_cnt[2:0];

hook8x8 hc(
	address,
	clock,
	3'b000,
	0,
	h_colour);
	
assign colour = load_black? 3'b0:h_colour;

endmodule 

module register_X(clock,resetn,ini,load,right,left, stop_x,Q);
	input clock;
	input resetn;
	input ini;
	input load;
	input right,left, stop_x;
	output reg [7:0] Q;
			
	always@(posedge clock)
	begin
		if(resetn == 1'b0 | ini == 1)
			Q <= 8'd75;
		else if (load == 1)
		begin 
		if(stop_x == 1) //move = 1, right
			Q <= Q;
		else if(right == 1) // move =0, left
				Q <= Q + 1;
		else if(left == 1) 
				Q <= Q - 1;
		else
			Q <= Q ;
		end
		else Q <= Q ;
	end
endmodule 

module register_Y(clock,resetn,ini,load,move, stop_y,Q);
	input clock;
	input resetn;
	input ini;
	input load;
	input move;
	input stop_y;
	output reg [6:0] Q;
	
	always@(posedge clock)
	begin
		if(resetn == 1'b0 | ini == 1)
			Q <= 7'd25;
		else if (load == 1)
		begin 
		if(stop_y == 1) 
			Q <= Q;
		else if(move == 1) // up = 1
				Q <= Q+1;
		else if(move ==0) //down = 0
				Q <= Q - 1; 
		else 
			  Q <=Q;
		end
		else Q <=Q;
	end	
endmodule 

module pixel_counter (clock,resetn,enable,Q);
	input clock;
	input resetn;
	input enable;
	output reg [5:0] Q;
	always @(posedge clock)
	begin
		if(resetn == 1'b0)
			Q <= 6'b0;
		else if(enable == 1'b1)
		begin 
		if(Q == 6'b111111)
			Q <= 6'b0;
		else 
			Q <= Q + 1'b1;
		end
	end	
endmodule 

module delay_counter (clock,resetn,enable,Q);
	input clock;
	input resetn;
	input enable;
	output reg [3:0] Q;
	always @(posedge clock)
		if(resetn == 1'b0)
			Q <= 4'b0;
		else if(enable == 1'b1)
		begin 
		if(Q == 4'b1111)
			Q <= 4'b0;
		else 
			Q <= Q + 1'b1;
		end
endmodule 

module time_counter(clock,resetn,load,Enable);
	input clock;
	input resetn;
	input load;
	reg [19:0] Q;
	output Enable;
	always @(posedge clock)
	begin 
		if(resetn == 1'b0)
			Q <= 24999999;
		else if(load == 1)
		begin
			if(Q == 0)
				Q <= 24999999;
			else 
				Q <= Q - 1;
		end
	end
	assign Enable = (Q == 0)?1:0;
endmodule 


//Gold datapath
module golddata (input clock, input resetn, input enable, input [2:0]select, 
	input GRegEnable1, input GRegEnable2, input GRegEnable3, input GRegEnable4, input GRegEnable5, 
	input CntStart, input [7:0]hx, input [7:0]hy,
	output [15:0]gposition, output [2:0]gcolor, output [5:0]gcnt,
	output g1t, output g2t, output g3t, output g4t, output g5t, output touch);


	wire [5:0]gaddress;

	assign gaddress[5:0] = 8 * gcnt[5:3] + gcnt[2:0];

	wire [15:0] gp1;
	wire [15:0] gp2;
	wire [15:0] gp3;
	wire [15:0] gp4;
	wire [15:0] gp5;
	
	
	GoldGenerate goldPostion (clock, CntStart, select, GRegEnable1, GRegEnable2, GRegEnable3, GRegEnable4, GRegEnable5,
										gposition, gp1, gp2, gp3, gp4, gp5);
	
	Gcounter countthenumber (clock, resetn, enable, gcnt);

	gold8x8 goldBlock (gaddress, clock, 0, 0, gcolor);

	collide touchmodule (hx, hy, gp1, gp2, gp3, gp4, gp5, g1t, g2t, g3t, g4t, g5t, touch);
	
endmodule

//decide which one is collide
module collide (input [7:0]hx, input [7:0]hy, input [15:0]gp1, input [15:0]gp2, input [15:0]gp3, input [15:0]gp4, input [15:0]gp5, 
	output reg g1t, output reg g2t, output reg g3t, output reg g4t, output reg g5t, output reg touch);
	
	always @(*)
	begin 
	if (hy[7:0] == gp1[15:8])
		begin 
		if ((hx[7:0]+4) > (gp1[7:0] - 1'b1))
			begin
			if((hx[7:0]+4) < (gp1[7:0] + 8))
				begin
				g1t = 1;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 1;
				end
			else 
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 0;
				end
			end
		else 
			begin
			g1t = 0;
			g2t = 0;
			g3t = 0;
			g4t = 0;
			g5t = 0;
			touch = 0;
			end
		end
	
	else if (hy[7:0] == gp2[15:8])
		begin 
		if ((hx[7:0]+4) > (gp2[7:0] - 1'b1))
			begin
			if((hx[7:0]+4) < (gp2[7:0] + 8))
				begin
				g1t = 0;
				g2t = 1;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 1;
				end
			else 
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 0;
				end
			end
		else 
			begin
			g1t = 0;
			g2t = 0;
			g3t = 0;
			g4t = 0;
			g5t = 0;
			touch = 0;
			end
		end
		
	else if (hy[7:0] == gp3[15:8])
		begin 
		if ((hx[7:0]+4) > (gp3[7:0] - 1'b1))
			begin
			if((hx[7:0]+4) < (gp3[7:0] + 8))
				begin
				g1t = 0;
				g2t = 0;
				g3t = 1;
				g4t = 0;
				g5t = 0;
				touch = 1;
				end
			else 
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 0;
				end
			end
		else 
			begin
			g1t = 0;
			g2t = 0;
			g3t = 0;
			g4t = 0;
			g5t = 0;
			touch = 0;
			end
		end		
	
	else if (hy[7:0] == gp4[15:8])
		begin 
		if ((hx[7:0]+4) > (gp4[7:0] - 1'b1))
			begin
			if((hx[7:0]+4) < (gp4[7:0] + 8))
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 1;
				g5t = 0;
				touch = 1;
				end
			else 
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 0;
				end
			end
		else 
			begin
			g1t = 0;
			g2t = 0;
			g3t = 0;
			g4t = 0;
			g5t = 0;
			touch = 0;
			end
		end	
	
	else if (hy[7:0] == gp5[15:8])
		begin 
		if ((hx[7:0]+4) > (gp5[7:0] - 1'b1))
			begin
			if((hx[7:0]+4) < (gp5[7:0] + 8))
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 1;
				touch = 1;
				end
			else 
				begin
				g1t = 0;
				g2t = 0;
				g3t = 0;
				g4t = 0;
				g5t = 0;
				touch = 0;
				end
			end
		else 
			begin
			g1t = 0;
			g2t = 0;
			g3t = 0;
			g4t = 0;
			g5t = 0;
			touch = 0;
			end
		end
	
	else 
		begin 
		g1t = 0;
		g2t = 0;
		g3t = 0;
		g4t = 0;
		g5t = 0;
		touch = 0;
		end
	end

endmodule

//Decide which staff to draw 
module drawing(input drawg, input [5:0]gcnt, input [15:0]goldposition, input [2:0]gcolor, 
	input drawb, input [15:0]bcnt, input [7:0]bx, input [7:0]by, input [2:0]bcolor,
	input drawf, input [15:0]fcnt, input [7:0]fx, input [7:0]fy, input [2:0]fcolor,
	input drawh, input [5:0]hcnt, input [7:0]hx, input [7:0]hy, input [2:0]hcolor,
	output reg [7:0]x, output reg [7:0]y, output reg [2:0]color, output reg [15:0] count);

	always @(*)
	begin 
	if (drawf)
		begin 
		x[7:0] = fx[7:0];
		y[7:0] = fy[7:0];
		color[2:0] = fcolor[2:0]; 
		count[15:0] = fcnt[15:0];
		end 
	
	else if (drawg)
		begin
		x[7:0] = goldposition[7:0] + gcnt[2:0];
		y[7:0] = goldposition[15:8] + gcnt[5:3];
		color[2:0] = gcolor[2:0]; 
		count[15:0] = 16'b0000000000000000 + gcnt[5:0];
		end
	
	else if (drawb)
		begin
		x[7:0] = bx[7:0];
		y[7:0] = by[7:0];
		color[2:0] = bcolor[2:0]; 
		count[15:0] = bcnt[15:0];
		end
		
	else if (drawh)
		begin
		x[7:0] = hx[7:0];
		y[7:0] = hy[7:0];
	   color[2:0] = hcolor[2:0]; 
		count[15:0] = 16'b0000000000000000 + hcnt[5:0];
		end
		
	else 
		begin
		x[7:0] = 8'b00000000;
		y[7:0] = 8'b00000000;
		color[2:0] = 3'b000;
		count[15:0] = 16'b0000000000000000;
		end
	end

endmodule


//Background generate
module backgrounddata (input clock, input bresetn, input benable, output [7:0]bx, output [7:0]by, output [2:0]bcolor, 
	output [15:0]bcount);

	wire [15:0]baddress;
	
	assign bcount = baddress;

	BGcounter backgroundcounter(clock, bresetn, benable, bx, by, baddress);

	background memoryblock(baddress, clock, 0, 0, bcolor);

endmodule


module finalbackgrounddata (input clock, input fresetn, input fenable, output [7:0]fx, output [7:0]fy, 	
	output [2:0]fcolor, output [15:0]fcount);

	wire [15:0]faddress;
	
	assign fcount = faddress;

	BGcounter finalbackgroundcounter(clock, fresetn, fenable, fx, fy, faddress);

	ending_background memoryblock(faddress, clock, 0, 0, fcolor);

endmodule


//Gold's Position Generator
module GoldGenerate (input clock, input CntStart, input [2:0]select, 
	input GRegEnable1, input GRegEnable2, input GRegEnable3, input GRegEnable4, input GRegEnable5, 
	output [15:0]position, output [15:0]gp1, output [15:0]gp2, output [15:0]gp3, output [15:0]gp4, output [15:0]gp5);

	wire [15:0] RanP1;
	wire [15:0] RanP2;
	wire [15:0] RanP3;
	wire [15:0] RanP4;
	wire [15:0] RanP5;

	wire [15:0] position1;
	wire [15:0] position2;
	wire [15:0] position3;
	wire [15:0] position4;
	wire [15:0] position5;

	RanCnt1 randomCounter1 (clock, CntStart, RanP1);

	RanCnt2 randomCounter2 (clock, CntStart, RanP2);
	
	RanCnt3 randomCounter3 (clock, CntStart, RanP3);
	
	RanCnt4 randomCounter4 (clock, CntStart, RanP4);
	
	RanCnt5 randomCounter5 (clock, CntStart, RanP5);
	
	
	GoldP gold1 (RanP1, clock, GRegEnable1, position1);

	GoldP gold2 (RanP2, clock, GRegEnable2, position2);
	
	GoldP gold3 (RanP3, clock, GRegEnable3, position3);
	
	GoldP gold4 (RanP4, clock, GRegEnable4, position4);
	
	GoldP gold5 (RanP5, clock, GRegEnable5, position5);
	
	assign gp1 = position1;
	assign gp2 = position2;
	assign gp3 = position3;
	assign gp4 = position4;
	assign gp5 = position5;

	mux8to1 muxer (position1, position2, position3, position4, position5, select, position);
	
endmodule 

//gold select
module mux8to1(input [15:0]posi1, input [15:0]posi2, input [15:0]posi3, input [15:0]posi4, input [15:0]posi5, input [2:0]select, output reg [15:0]posi);

	always @(*)
		begin
		case (select)
		3'b000: posi = posi1;
		3'b001: posi = posi2;
		3'b010: posi = posi3;
		3'b011: posi = posi4;
		3'b100: posi = posi5;
		3'b101: posi = 0;
		3'b110: posi = 0;
		3'b111: posi = 0;
		endcase
		end

endmodule

//random counter 1
module RanCnt1(input clock, input rcenable, output [15:0]GoldPosi);

	reg [7:0]x;
	reg [7:0]y;

	always @(posedge clock)
	begin 
	if (rcenable == 0)
		begin
		x <= 8'd123;
		y <= 8'd80;
		end
	else if (rcenable == 1)
		begin
			if (x != 8'd0)
				begin
				x <= x - 8'd1;
				y <= y;
				end
			else if (x == 8'd0)
				begin
					if (y != 8'd30)
						begin
						x <= 8'd150;
						y <= y - 8'd1;
						end
					else 
						begin
						x <= 8'd150;
						y <= 8'd110;
						end
				end
				
		end	
	end
	

	assign GoldPosi = {y,x};
endmodule

//random counter 2
module RanCnt2(input clock, input rcenable, output [15:0]GoldPosi);

	reg [7:0]x;
	reg [7:0]y;

	always @(posedge clock)
	begin 
	if (rcenable == 0)
		begin
		x <= 8'd59;
		y <= 8'd95;
		end
	else if (rcenable == 1)
		begin
			if (x != 8'd0)
				begin
				x <= x - 8'd1;
				y <= y;
				end
			else if (x == 8'd0)
				begin
					if (y != 8'd30)
						begin
						x <= 8'd150;
						y <= y - 8'd1;
						end
					else 
						begin
						x <= 8'd150;
						y <= 8'd110;
						end
				end
				
		end	
	end
	

	assign GoldPosi = {y,x};
endmodule

//random counter 3
module RanCnt3(input clock, input rcenable, output [15:0]GoldPosi);

	reg [7:0]x;
	reg [7:0]y;

	always @(posedge clock)
	begin 
	if (rcenable == 0)
		begin
		x <= 8'd101;
		y <= 8'd5;
		end
	else if (rcenable == 1)
		begin
			if (x != 8'd0)
				begin
				x <= x - 8'd1;
				y <= y;
				end
			else if (x == 8'd0)
				begin
					if (y != 8'd30)
						begin
						x <= 8'd150;
						y <= y - 8'd1;
						end
					else 
						begin
						x <= 8'd150;
						y <= 8'd110;
						end
				end
				
		end	
	end
	

	assign GoldPosi = {y,x};
endmodule

//random counter 4
module RanCnt4(input clock, input rcenable, output [15:0]GoldPosi);

	reg [7:0]x;
	reg [7:0]y;

	always @(posedge clock)
	begin 
	if (rcenable == 0)
		begin
		x <= 8'd89;
		y <= 8'd64;
		end
	else if (rcenable == 1)
		begin
			if (x != 8'd0)
				begin
				x <= x - 8'd1;
				y <= y;
				end
			else if (x == 8'd0)
				begin
					if (y != 8'd30)
						begin
						x <= 8'd150;
						y <= y - 8'd1;
						end
					else 
						begin
						x <= 8'd150;
						y <= 8'd110;
						end
				end
				
		end	
	end
	

	assign GoldPosi = {y,x};
endmodule

//random counter 5
module RanCnt5(input clock, input rcenable, output [15:0]GoldPosi);

	reg [7:0]x;
	reg [7:0]y;

	always @(posedge clock)
	begin 
	if (rcenable == 0)
		begin
		x <= 8'd19;
		y <= 8'd88;
		end
	else if (rcenable == 1)
		begin
			if (x != 8'd0)
				begin
				x <= x - 8'd1;
				y <= y;
				end
			else if (x == 8'd0)
				begin
					if (y != 8'd30)
						begin
						x <= 8'd150;
						y <= y - 8'd1;
						end
					else 
						begin
						x <= 8'd150;
						y <= 8'd110;
						end
				end
				
		end	
	end
	

	assign GoldPosi = {y,x};
endmodule

//Gold drawing counter
module Gcounter (input clock, input resetn, input enable, output reg [5:0] Q);

	always @(posedge clock)
		if(resetn == 1'b0)
			Q <= 6'b0;
		else if(enable == 1'b1)
		begin 
		if(Q == 6'b111111)
			Q <= 6'b0;
		else 
			Q <= Q + 1'b1;
		end
		
endmodule 

//gold registor
module GoldP(input [15:0]RanPosi, input clock, input En, output reg [15:0]GoldPosi);

	always @(posedge clock)
	begin
	if (En)
		GoldPosi <= RanPosi;
	else 
		GoldPosi <= GoldPosi;
	end

endmodule

//Background drawing counter
module BGcounter (input clock, input resetn, input enable,
	 output reg [7:0] x, output reg [7:0] y, output reg [15:0]Q);

	always @(posedge clock)
	begin
		if(resetn == 1'b0)
			begin
				x <= 8'b00000000;
				y <= 8'b00000000;
			end
		else if(enable == 1'b1)	
		begin 
			if(x == 159)
				begin
					if(y == 119)
						begin
						y <= 0;
						end
					else 
						begin
						y <= y + 1;
						x <= 0;
						end
				end
			else
				begin
				y <= y;
				x <= x + 1;
				end
		end
	end
	
	always @(posedge clock)
		if(resetn == 1'b0)
			Q <= 16'b0;
		else if(enable == 1'b1)
		begin 
		if(Q == 16'd19119)
			Q <= 16'd0;
		else 
			Q <= Q + 1'b1;
		end
		
endmodule 

//Score counter
module Cscore (input clock, input touch, input start, output reg [3:0]score, output reg finish);
	
	always@(posedge clock)
	begin 
	if (!start)
		score <= 0;
	else 
		begin
		if (touch)
			score <= score + 1;
		else 
			score <= score;
		end
	end
	
	always @ (*)
	begin 
	if (score > 12)
		finish = 1;
	else 
		finish = 0;
	end 


endmodule

module hex7segment(input [3:0]signal, output reg [6:0]HEX);	
	always@(*)
	case(signal)
		0: HEX = 7'b1000000;
		1: HEX = 7'b1111001;
		2: HEX = 7'b0100100;
		3: HEX = 7'b0110000;
		4: HEX = 7'b0011001;
		5: HEX = 7'b0010010;
		6: HEX = 7'b0000010;
		7: HEX = 7'b1111000;
		8: HEX = 7'b0000000; 
		10: HEX = 7'b0001000;
		11: HEX = 7'b0000011;
		12: HEX = 7'b1000110;
		13: HEX = 7'b0100001;
		14: HEX = 7'b0000110;
		15: HEX = 7'b0001110;
		default: HEX = 7'bx;
	endcase
endmodule	