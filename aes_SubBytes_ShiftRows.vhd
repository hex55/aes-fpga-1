library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aes_types.all;

entity aes_SubBytes_ShiftRows is
	port(
		data_in  : in  matrix(3 downto 0, 3 downto 0);
		data_out : out matrix(3 downto 0, 3 downto 0);

		start    : in  std_logic;
		done     : out std_logic;

		clk      : in  std_logic;
		rst      : in  std_logic
	);
end entity aes_SubBytes_ShiftRows;

architecture RTL of aes_SubBytes_ShiftRows is
	type state is (IDLE, PROCESSING);
	signal current_state : state := IDLE;

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				for i in 0 to 3 loop
					for j in 0 to 3 loop
						data_out(i, j) <= (others => '0');
					end loop;
				end loop;
			else
				case current_state is
					when IDLE =>
						if (start = '1') then
							current_state <= PROCESSING;
						else
							current_state <= current_state;
						end if;
						done <= '0';
					when PROCESSING =>
						current_state <= IDLE;
						done          <= '1';
				end case;

				--Substitute
				for J in 0 to 3 loop
					data_out(J, 0) <= Sbox(to_integer(unsigned(data_in(J, 0))));
				end loop;

				for J in 1 to 3 loop
					data_out(J, 1) <= Sbox(to_integer(unsigned(data_in(J - 1, 1))));
				end loop;
				data_out(0, 1) <= Sbox(to_integer(unsigned(data_in(3, 1))));

				for J in 2 to 3 loop
					data_out(J, 2) <= Sbox(to_integer(unsigned(data_in(J - 2, 2))));
				end loop;
				data_out(0, 2) <= Sbox(to_integer(unsigned(data_in(2, 2))));
				data_out(1, 2) <= Sbox(to_integer(unsigned(data_in(3, 2))));

				data_out(0, 3) <= Sbox(to_integer(unsigned(data_in(3, 3))));
				data_out(1, 3) <= Sbox(to_integer(unsigned(data_in(2, 3))));
				data_out(2, 3) <= Sbox(to_integer(unsigned(data_in(1, 3))));
				data_out(3, 3) <= Sbox(to_integer(unsigned(data_in(0, 3))));

			end if;
		end if;
	end process;

end architecture RTL;
