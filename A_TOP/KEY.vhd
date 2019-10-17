library ieee;
use ieee.std_logic_1164.all;

entity KEY is 
	port(
	inclk:in std_logic;                               --1M
	inrow:in std_logic_vector(3 downto 0);--3dao0,���ϵ���
	incol:out std_logic_vector(3 downto 0);--3dao0,��������
	outshumaguan:out std_logic_vector(4 downto 0)
	);
end ;

architecture a of KEY is 
signal cnt:integer range 0 to 4;
signal coltmp:std_logic_vector(3 downto 0);
signal keykey:std_logic_vector(4 downto 0);

begin 
	p1:process(inclk)
	begin
		if inclk'event and inclk='1' then
			if cnt=4 then
				cnt<=0;
			else cnt<=cnt+1;
			end if;
		end if;
	end process p1;
	p2:process(cnt)
	begin
		case cnt is
			when 0=> coltmp<="0111";--�������ҵ�һ��
			when 1=> coltmp<="1011";--�ڶ���
			when 2=> coltmp<="1101";--������
			when 3=> coltmp<="1110";--������
			when 4=> coltmp<="0000";--������
		end case;
		incol<=coltmp;--����дֵ���ж����ź�
	end process p2;
	p3:process(coltmp)
	begin
		if inclk'event and inclk='1' then 
			case coltmp is
				when "1110" => --�������ҵ�һ��
					case inrow is
						when "0111" => keykey<="00000";--���ϵ��µ�һ��
						when "1011" => keykey<="00100";--���ϵ��µڶ���
						when "1101" => keykey<="01000";--���ϵ��µ�����
						when "1110" => keykey<="01100";--���ϵ��µ�����
						when others => null;--keykey<="11111";
					end case;
				when "1101" => --�������ҵڶ���		
					case inrow is
						when "0111" => keykey<="00001";--���ϵ��µ�һ��
						when "1011" => keykey<="00101";--���ϵ��µڶ���
						when "1101" => keykey<="01001";--���ϵ��µ�����
						when "1110" => keykey<="01101";--���ϵ��µ�����
						when others => null;--keykey<="11111";
					end case;
				when "1011" => --�������ҵ�����
					case inrow is
						when "0111" => keykey<="00010";--���ϵ��µ�һ��
						when "1011" => keykey<="00110";--���ϵ��µڶ���
						when "1101" => keykey<="01010";--���ϵ��µ�����
						when "1110" => keykey<="01110";--���ϵ��µ�����
						when others => null;--keykey<="11111";
					end case;
				when "0111" => --�������ҵ�����
					case inrow is
						when "0111" => keykey<="00011";--���ϵ��µ�һ��
						when "1011" => keykey<="00111";--���ϵ��µڶ���
						when "1101" => keykey<="01011";--���ϵ��µ�����
						when "1110" => keykey<="01111";--���ϵ��µ�����
						when others => null;--keykey<="11111";
					end case;
				when "0000" => --�������ҵ�����
					if inrow ="1111" then
						keykey<="11111";
					end if;
				when others => null;--keykey<="11111";
			end case;
		end if;			
	end process p3;	
	
	p4:process(inclk,keykey)
	variable c:integer range 0 to 1 :=0;
	variable b:integer range 0 to 1000 :=0;

	variable lastkey:std_logic_vector(4 downto 0):="11111";

	begin
		if inclk'event and inclk='1' then
			if c=0 then
				c:=1;
				outshumaguan<="11111";
			end if;

			if lastkey /=keykey  then
				outshumaguan <=keykey;
				c:=0;
			else 
				outshumaguan<="11111";
			end if;
			lastkey:=keykey;
		end if;
	end process p4;

end;