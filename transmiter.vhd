library ieee;	
library work;						
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hamming_pack.all;
entity transmiter is generic 
	( 
		data_bus : integer := 4
	);
	port
	(
		rst 		:in std_logic; 
		clk 		:in std_logic;
		din 		:in std_logic_vector(data_bus downto 1);  --The left is MSB, and the right is LSB.
		en  		:in std_logic;
		data_out 	:out std_logic_vector(Num_of_data_out(data_bus) downto 1);  --The left is MSB, and the right is LSB.
		valid		:out std_logic -- Need to go to the enable in the Decoder.
	);
	end entity transmiter;
	
	architecture arc_transmiter of transmiter is 
	
	constant num_of_parity	:integer :=	data_out'length-din'length;  -- Number of parity -> Must always be = dataout_bits - datain_bits.
	
	type num_of_code is array (1 to num_of_parity,1 to data_out'length) of std_logic; -- Matrix of the data and the parity.
	
	begin
	
	process(clk,rst) is
	variable parity_bit : std_logic;
	variable data_input : std_logic_vector(data_out'length  downto 1);
	variable zeros 		: std_logic_vector(num_of_parity downto 1) := (others => '0');
	variable counter2   : integer;
	variable hamming : num_of_code;
	variable counter3  : integer;
	variable flag :std_logic :='0';
	begin
		if rst = '1' then 
			data_out<= (others => '0');
			valid <= '0';
		
		elsif rising_edge(clk) then
			
			if en = '1'	then
		
				counter2:=1;  				--start value for all the variables.
				counter3:=0;
				flag:='0';
				parity_bit:='0';
				zeros:=(others => '0');
				data_input := zeros & din(data_bus downto 1);
				
				for i in 1 to num_of_parity loop -- Passing on the coloums and row and put's in paritiy that we are use in the coloum 1.
					for k in 1 to data_out'length loop --and all the other parity put 0, and the data in the right place in the matrix.	
	                        if k=2**(i-1)  then
								hamming(i,k):='1';
							elsif num_pow_of_2(k)=1 and k/=2**(i-1) then
								hamming(i,k):='0';
							else 
							hamming(i,k) := data_input(counter2);
							counter2 := counter2+1;
							end if;
					end loop;
					counter2 :=1;
				end loop;
				
				counter2:=0;

			for i in 1  to num_of_parity loop -- rows loop. -- Passing on on the coloums and the rows and put's in the paritiy in the right place if xor '1' or '0'
				for k in 2**(i-1) to data_out'length loop  -- coloums loop.
							
							if counter2 < 2**(i-1) then -- do xor 
								counter2:=counter2+1;	
								if flag='1' then 
									parity_bit  := parity_bit xor hamming(i,k);
								end if;
								flag :='1';
							
						
							elsif counter3 < 2**(i-1) then -- Passing on the bits that not need in the xor with paritiy bit
								counter3 :=counter3 +1;
							
							end if;

							if (( 2**(i-1) <= counter2) and (2**(i-1) <= counter3)) then -- counters = 0 ,because the next coloum need start counting again.
								counter2:=0;
								counter3:=0;
							end if;
				end loop;
	
				for j in 1 to data_out'length-1 loop -- put the parity bit in the right place
						if j=2**(i-1) then 
							hamming(i,j):= parity_bit;
						end if;
				end loop;
				parity_bit  :='0'; -- for the next coloum, again do everithing.
				flag:='0';
				counter3:=0; 
				counter2:=0;
			end loop;

----------------------->now we have the marix with the paritiy bits after xor and the data<-----------------------------
				 
				
				for i in 1  to num_of_parity loop -- rows -- output for hamming to output in the right place.
					for k in 1 to data_out'length loop
							if k=2**(i-1) then 
								data_out((2**(i-1)))<= hamming(i,2**(i-1)); -- put the parity bit in the right place
							end if;
					end loop;
				end loop;

---------------------->now we put out the paritiy bits into data_out<-------------------------------------------				
				counter2:=1;
				
				for i in 1 to data_out'length loop
					if (num_pow_of_2(i)/=1) then
						data_out(i)<= din(counter2);
						counter2:=counter2+1;
					 end if;
				end loop;
	---------------------->now we put out the paritiy bits + the data into data_out<-------------------------------------------					 
			valid<='1'; 	--------- output the valid value to 1-------------------
		  end if;
		end if;
	end process;
	
	end arc_transmiter;