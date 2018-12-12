library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.hamming_pack.all;


entity Decoder is generic (
        godel          :integer:=8
	);

	port(
		clk            : in std_logic;
		rst            : in std_logic;
		en             : in std_logic;
		codeword       : in std_logic_vector(get_codeword_size(godel) downto 1);
		valid          : out std_logic;
		data           : out std_logic_vector(godel downto 1);
		error 		   : out std_logic
	);


end Decoder;


architecture arc_Decoder of Decoder is 

 

begin

    process (clk, rst) is
	 
	  alias codeword_alias                          : std_logic_vector(codeword'range) is codeword;
	 
	 
	 variable codeword1                            : std_logic_vector((codeword'length-data'length)-1 downto 0);
	 variable data1                                : std_logic_vector(data'length downto 1);
	 variable fixed                                : std_logic_vector(codeword'length downto 1);-- array of fixed code
	 variable temp                                 : std_logic_vector(codeword1'length-1 downto 0); -- to_check_bits_position
	 variable counter                              : integer;
	 variable bit_error_pos                        : std_logic_vector((2**codeword1'length)-1 downto 0);
	 variable error_v							   : std_logic;
	 begin
	    
		
	    if rst='1' then
			data<=(others=>'0');
			valid<='0';
		 elsif rising_edge(clk) then		 
		    codeword1 := (others => '0');
			error_v:= '0';
			-- Now we check the bits position of the codeword1 (c-vector) and find out if they are '0' or '1'
			for i in codeword1'range loop
			    for j in codeword_alias'range loop
				    temp := conv_std_logic_vector(j, temp'length);
					if (temp(i) = '1') then
                       codeword1(i) := codeword1(i) xor codeword_alias(j);
                    end if;
			    end loop;
         end loop;
			
	     if (CONV_INTEGER(codeword1))>godel then 
		 error_v:= '1';
		 end if;
		 
		 
		-- In the next action we will fix the error in the codeword data (if thhe error was found at the previous step) by using XOR betweeen the bit-error and the codeword_data
		 bit_error_pos:= (others => '0');
         bit_error_pos(CONV_INTEGER(codeword1))  := '1';    
		 fixed                                   := codeword_alias xor bit_error_pos(fixed'range);
			
			counter :=1;
			
			--Here we put the fixed data to the output
			for i in 1 to codeword1'high loop
                for j in ((2**i)+1) to ((2**(i+1))-1) loop
                    if counter <= data'length then
                        data1(counter) := fixed(j);
                        counter                       := counter+1;
                    end if;
                end loop;
            end loop;
            
           
			
			valid <= en;
			if (en = '1') then
             data <= data1;
			 error<= error_v;
         end if;
			
        end if;
    end process;
			
			
			

end architecture arc_Decoder;			