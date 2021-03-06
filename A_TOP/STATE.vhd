library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.STRUCT.all;
entity STATE is
port(
			clk: in std_logic;
			clk_1hz: in std_logic;
			data_key:in std_logic_vector(4 downto 0);
			data_menuled: out std_logic_vector(5 downto 0);                                       --ismenu
			data_beep: out std_logic;										--isbeep
			data_dz: out std_logic_vector(1 downto 0);                   --islock
			data_smg:out smg_eight;                                       --issmg
			data_lcd:out moment;                                           --now_time
			data_lcd0:out moment;                                         --rec_time
			data_lcd0ready:out std_logic                                  --islcd
);
end STATE;
architecture behavioral of STATE is
signal  state:all_state :=MENU;                                                                          --当前状态机状态

signal  four_cipher:four_cipher_six:=((1,1,1,1,1,1),(2,2,2,2,2,2),(3,3,3,3,3,3),(4,4,4,4,4,4));	--存储4个用户的密码nine_cipher(1)(1)<=1；
signal  four_cipher_lenth:four_cipher_len:=(6,6,6,6);											 --存储4个用户的密码长度
signal  three_recording:three_moment;--:=((1,9,3),(1,6,8),(0,3,4));																 --存储3个记录   ten_recording(1)<=(0,0,1);

signal  num_recording:INTEGER RANGE 0 TO 3 :=0;                                                        --当前记录总数
signal  num_user:INTEGER RANGE 0 TO 4 :=2;                                                              --当前用户总数
signal  num_input:INTEGER RANGE 0 TO 6 :=0;                                                             --当前输入数字总数
signal  now_user:INTEGER RANGE 0 TO 4 :=1;                                                              --记录当前用户名称
signal  now_recording:INTEGER RANGE 0 TO 3 :=0;                                                         --记录当前显示记录序号
signal  now_input:cipher_six;	   --当前用户输入的六个数
signal  now_time: moment:=(0,0,0);																	    --记录当前时刻   now_time<=(0,0,1);
signal  rec_time: moment:=(0,0,0);
signal  issmg:smg_eight:=(10,10,10,10,10,10,10,10);                                                          --当前数码管的显示内容
signal  ismenu:std_logic_vector(5 downto 0):= "100000";                                                   --当前是否在menu状态
signal  islock:std_logic_vector(1 downto 0) := "01";                                                     --当前锁的状态       给dz的信号
signal  isbeep:std_logic := '0';                                                           --当前蜂鸣器的状态    给蜂鸣器的信号
signal  islcd:std_logic := '0';																	     --当前lcd状态

begin

	data_menuled<=ismenu;
	data_beep <= isbeep;
	data_dz<=islock;
	data_smg<=issmg;
	data_lcd<=now_time;
	data_lcd0 <= rec_time;
	data_lcd0ready<=islcd;

	ptime:process(clk_1hz)
	variable h:INTEGER RANGE 0 TO 1;
	variable m:INTEGER RANGE 0 TO 59;
	variable s:INTEGER RANGE 0 TO 59;
	begin
		if clk_1hz'event and clk_1hz='1'then
				if s=59 then 
					s := 0;
					if m=59 then 
						m:=0;
						if h=1 then
							h:=0;
						else
							h:=h+1;
						end if;
					else
						m:= m+1;
					end if;
				else
					s := s+1;
				end if;				
		end if;
		now_time<=(h,m,s);				
	end process ;
	pmenu:process(clk,state)
	begin
		CASE state IS 
		WHEN MENU=> ismenu<="100000";
		WHEN CHOOSE_USER=> ismenu<="010000";
		WHEN ADD_CIPHER=> ismenu<="001000";
		WHEN CHANGE_CIPHER=> ismenu<="000100";
		WHEN INPUT_CIPHER=> ismenu<="000010";
		WHEN SHOW_RECORD=> ismenu<="000001";
		end case;
	end process ;
	psmg:process(clk,num_input,num_user,now_input,now_user,state)
	begin
		CASE state IS
		WHEN MENU => 
			issmg(1)<=10;issmg(2)<=10;issmg(3)<=10;issmg(4)<=10;
			issmg(5)<=10;issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
		WHEN SHOW_RECORD => 
			issmg(1)<=num_recording;issmg(2)<=now_recording;issmg(3)<=10;issmg(4)<=10;
			issmg(5)<=10;issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
		WHEN CHOOSE_USER => 
			issmg(1)<=num_user;issmg(2)<=10;issmg(3)<=10;issmg(4)<=10;
			issmg(5)<=10;issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
		WHEN INPUT_CIPHER =>
			issmg(1)<=num_user;issmg(2)<=now_user;
			case num_input is
				when 0 =>
					issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
					issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
				when 1 =>
					issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
					issmg(6)<=10;issmg(7)<=10;issmg(8)<=11;
				when 2 =>
					issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
					issmg(6)<=10;issmg(7)<=11;issmg(8)<=11;
				when 3 =>
					issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
					issmg(6)<=11;issmg(7)<=11;issmg(8)<=11;
				when 4 =>
					issmg(3)<=10;issmg(4)<=10;issmg(5)<=11;
					issmg(6)<=11;issmg(7)<=11;issmg(8)<=11;
				when 5 =>
					issmg(3)<=10;issmg(4)<=11;issmg(5)<=11;
					issmg(6)<=11;issmg(7)<=11;issmg(8)<=11;
				when 6 =>
					issmg(3)<=11;issmg(4)<=11;issmg(5)<=11;
					issmg(6)<=11;issmg(7)<=11;issmg(8)<=11;
				when others => NULL;
			END case;
		WHEN ADD_CIPHER =>
			issmg(1)<=num_user;issmg(2)<=10;
			case num_input is
			when 0 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
			when 1 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=10;issmg(8)<=now_input(1);
			when 2 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=now_input(1);issmg(8)<=now_input(2);
			when 3 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=now_input(1);issmg(7)<=now_input(2);issmg(8)<=now_input(3);
			when 4 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=now_input(1);
				issmg(6)<=now_input(2);issmg(7)<=now_input(3);issmg(8)<=now_input(4);
			when 5 =>
				issmg(3)<=10;issmg(4)<=now_input(1);issmg(5)<=now_input(2);
				issmg(6)<=now_input(3);issmg(7)<=now_input(4);issmg(8)<=now_input(5);
			when 6 =>
				issmg(3)<=now_input(1);issmg(4)<=now_input(2);issmg(5)<=now_input(3);
				issmg(6)<=now_input(4);issmg(7)<=now_input(5);issmg(8)<=now_input(6);
			when others => NULL;
			END case;
		WHEN CHANGE_CIPHER =>
			issmg(1)<=num_user;issmg(2)<=now_user;
			case num_input is
			when 0 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=10;issmg(8)<=10;
			when 1 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=10;issmg(8)<=now_input(1);
			when 2 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=10;issmg(7)<=now_input(1);issmg(8)<=now_input(2);
			when 3 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=10;
				issmg(6)<=now_input(1);issmg(7)<=now_input(2);issmg(8)<=now_input(3);
			when 4 =>
				issmg(3)<=10;issmg(4)<=10;issmg(5)<=now_input(1);
				issmg(6)<=now_input(2);issmg(7)<=now_input(3);issmg(8)<=now_input(4);
			when 5 =>
				issmg(3)<=10;issmg(4)<=now_input(1);issmg(5)<=now_input(2);
				issmg(6)<=now_input(3);issmg(7)<=now_input(4);issmg(8)<=now_input(5);
			when 6 =>
				issmg(3)<=now_input(1);issmg(4)<=now_input(2);issmg(5)<=now_input(3);
				issmg(6)<=now_input(4);issmg(7)<=now_input(5);issmg(8)<=now_input(6);
			when others => NULL;
			END case;	
		WHEN OTHERS =>NULL;
		END CASE;
	end process;

	pstate:process(data_key)
	variable  number_recording:INTEGER RANGE 0 TO 10 :=0;                                                        --当前记录总数
	variable  number_user:INTEGER RANGE 0 TO 9 :=2;                                                              --当前用户总数
	variable  number_input:INTEGER RANGE 0 TO 6 :=0; 															 --当前输入总数
	variable  current_user:INTEGER RANGE 0 TO 9 :=1;                                                              --记录当前用户名称
	variable  current_recording:INTEGER RANGE 0 TO 9 :=0;                                                         --记录当前显示记录序号
	variable  current_input:cipher_six;	                                                                          --当前用户输入的六个数
	variable  cnt:INTEGER RANGE 0 TO 199 ;
    variable  key_value:key:=nothing;																					 --当前按键的名称
	begin	
	if clk'event and clk='1' then
	key_value := return_keyvalue(data_key);
		---------beep模块------------------
		if isbeep='1' then
			if cnt=199 then 
				cnt := 0;isbeep <= '0';
			else
				cnt := cnt+1;
			end if;
		end if;
		---------beep模块------------------
		num_input<=number_input;
		num_user<=number_user;
		num_recording<=number_recording;
		now_input<=current_input;
		now_user<=current_user;
		now_recording<=current_recording;
	CASE state IS
		WHEN MENU => 
			CASE key_value IS
				WHEN choose => 
					state<=CHOOSE_USER;
				WHEN add => 
					if number_user=4 then 
					isbeep<='1';
					else 
					number_user:=number_user+1;
					current_user:=number_user;
					state<=ADD_CIPHER;
					end if;
				WHEN recording => 
					if number_recording=0 then 
					isbeep<='1';
					else 
					current_recording:=1;
					rec_time<=three_recording(current_recording);
					islcd<='1';
					state<=SHOW_RECORD;
					end if;				
				WHEN modify => 
					if islock="10" then 
					state<=CHANGE_CIPHER;
					else 
					isbeep<='1';
					end if;
				WHEN enter => 
					if islock="10" then 
						islock<="01";	                                 --锁已开的情况下 enter上锁	
					else isbeep <= '1';
					end if;	
				when nothing => null;
				WHEN OTHERS    => isbeep <= '1';
			END CASE;
		WHEN CHOOSE_USER => 
			CASE key_value IS
			WHEN del => state<=MENU;
			WHEN one => 
				current_user := 1;
				state<=INPUT_CIPHER; 
			WHEN two => 
				current_user := 2;
				state<=INPUT_CIPHER; 
			WHEN three => 
				if number_user>2 then			
				current_user := 3;
				state<=INPUT_CIPHER;
				else 
				isbeep <= '1';
				state<=CHOOSE_USER;
				end if;
			WHEN four =>
				if number_user>3 then			
				current_user := 4;
				state<=INPUT_CIPHER;
				else 
				isbeep <= '1';
				state<=CHOOSE_USER;
				end if;
			when nothing|choose=> null;
			WHEN OTHERS => 
				isbeep <= '1';
				state<=CHOOSE_USER;
			END CASE;
		
		WHEN INPUT_CIPHER|CHANGE_CIPHER|ADD_CIPHER =>
			CASE key_value IS 
			WHEN del => 
				if number_input=0 then
					if state = ADD_CIPHER then 
						number_user:=number_user-1;
						current_user:=number_user;
					end if;
					state<=MENU;
				else				
					number_input := number_input - 1;
					
				end if;	                  

			WHEN one => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
					current_input(number_input+1):=1;
					number_input:=number_input+1;
				end if;

			WHEN two => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1) :=2;
				number_input:=number_input+1;
				end if;
					
			WHEN three => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=3;
				number_input:=number_input+1;
				end if;
			WHEN four =>
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=4;
				number_input:=number_input+1;
				end if;
			WHEN five =>
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=5;
				number_input:=number_input+1;
				end if;
			WHEN six => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=6;
				number_input:=number_input+1;
				end if;
			WHEN seven => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=7;
				number_input:=number_input+1;
				end if;
			WHEN eight => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=8;
				number_input:=number_input+1;
				end if;
			WHEN nine => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=9;
				number_input:=number_input+1;
				end if;
			WHEN zero => 
				if number_input=6 then
					number_input:= 0;
					isbeep <= '1';
				else 
				current_input(number_input+1):=0;
				number_input:=number_input+1;
				end if;
			WHEN enter => 
					if state=INPUT_CIPHER then									
								--input
					if current_input=four_cipher(current_user) and number_input=four_cipher_lenth(current_user)then               ------?????bug
						islock<="10";					
						if number_recording<10 then
							three_recording(number_recording+1)<=now_time;
							number_recording:=number_recording+1;						
						end if;
						number_input:=0;
						state<=MENU;
					else 
						isbeep<='1';
						number_input:=0;
					end if;
					
					else 
					    if number_input /= 0 then
						four_cipher_lenth(current_user)<=number_input;
						four_cipher(current_user)<=current_input;				
						end if;
						state<=MENU;
					end if;
			WHEN nothing => null; 
			WHEN OTHERS => 
				isbeep<='1';
				number_input:=0;
			END CASE;

		WHEN SHOW_RECORD => 
			CASE key_value IS
			WHEN del => state<=MENU;islcd<='0';                               --??????????????
			WHEN recording =>
				if current_recording<number_recording then
					current_recording := current_recording+1;
				else
					current_recording:=1;
				end if;
				rec_time<=three_recording(current_recording);
			when nothing => null;
			WHEN OTHERS =>
				isbeep<='1';--beep
			END CASE;

		WHEN OTHERS    => null;
		END CASE;
	end if;
	end process ;
end behavioral;