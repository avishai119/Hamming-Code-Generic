--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:55:28 11/22/2018
-- Design Name:   
-- Module Name:   C:/Users/Admin/Desktop/ttt/transmiter/tb.vhd
-- Project Name:  transmiter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transmiter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
library work;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.hamming_pack.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS 
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
 constant  data_bus:integer :=4;
 constant  godel :integer :=4;
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transmiter generic(
	data_bus : integer := 4 );  
	PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         din : IN  std_logic_vector(data_bus downto 1);
         en : IN  std_logic;
         data_out : OUT  std_logic_vector(Num_of_data_out(data_bus) downto 1);
         valid : OUT  std_logic
        );
    END COMPONENT;
    
	 COMPONENT decoder 
	  generic(
		godel	 : integer := 4  );
	   PORT(
		clk            : in std_logic;
		rst            : in std_logic;
		en             : in std_logic;
		codeword       : in std_logic_vector(get_codeword_size(godel) downto 1);
		valid          : out std_logic;
		data           : out std_logic_vector(godel downto 1);
		error  	       : out std_logic
		);
	 END COMPONENT;
	 
	 
   --Inputs transmiter
	signal rst_transmiter_s : std_logic;
	signal clk 				:std_logic;
	signal din_s 			: std_logic_vector(data_bus downto 1);
	signal en_transmiter_s  : std_logic;
	
	--Outputs transmiter and inputs decoder
	signal  data_out_data_in_decoder_s : std_logic_vector(Num_of_data_out(data_bus)  downto 1);
	signal  data_out_data_in_decoder_s_2 : std_logic_vector(Num_of_data_out(data_bus)  downto 1);
	signal valid_1_en_2_s 			   :std_logic;
 	
	
	--Other inputs decoder
		signal rst_decoder_s : std_logic;
	
	--Outputs decoder
	signal 	valid_2_decoder_s : std_logic;  
	signal 	data_s	 : std_logic_vector(godel downto 1);
	 signal  in_decoder_s : std_logic_vector(Num_of_data_out(data_bus)  downto 1);
	signal error_s 	:std_logic;
   -- Clock period 
   constant clk_period : time := 100 ps;
 
BEGIN
 
	
   uut1: transmiter generic map(
	 data_bus =>4
	)
	PORT MAP (
          rst => rst_transmiter_s,
          clk => clk,
          din => din_s,
          en => en_transmiter_s,
          data_out => data_out_data_in_decoder_s,
          valid => valid_1_en_2_s
        
		);

    uut2: decoder generic map(
	 godel =>4
	)
	 PORT MAP (
          rst => rst_decoder_s,
          clk => clk,
          en  => valid_1_en_2_s,
          codeword => data_out_data_in_decoder_s_2,
          valid => valid_2_decoder_s,
	  data => data_s,
	  error => error_s  
        );

		
		
   -- Clock process
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   	 process 
	 variable location : integer ;
	 begin		
		rst_transmiter_s <= '1';
		rst_decoder_s <= '1';
	 wait for 10 ps;	-- wait for how match time you want.
		
		en_transmiter_s <= '1'; -- start
		rst_transmiter_s <= '0';
		data_out_data_in_decoder_s_2 <= (others => '0');
		rst_decoder_s <= '0';

-----------------look if the data in  from transmiter is like data out from decooder -----------------
		
		for i in 1 to 2**(din_s'length)-1 loop -- put random value into transmiter and see what we got.
			din_s <=std_logic_vector(to_unsigned(i, din_s'length));
		wait for clk_period ; 
			data_out_data_in_decoder_s_2 <= data_out_data_in_decoder_s;
			wait for clk_period ; 
    
		end loop;
		
		wait for clk_period ; 
------------ look if we have a error in the bits ------------------------
		
		for i in 1 to din_s'length-1 loop -- look were is the first data_bit in the vector.
			if Num_Pow_of_2(i) /= 1 then
				location := i;
			end if;
		end loop;		
			
			
		
		for i in 1 to 2**(din_s'length)-1 loop 
			din_s <=std_logic_vector(to_unsigned(i, din_s'length));
		wait for clk_period ; 
			data_out_data_in_decoder_s_2 <= data_out_data_in_decoder_s; 
			data_out_data_in_decoder_s_2(location) <= not(data_out_data_in_decoder_s(location)); -- put a error in the first data_bit.
		end loop;

      wait;
   end process;

END;
