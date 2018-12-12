library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
package hamming_pack is
function Num_Pow_of_2(X : integer) return integer;
function Num_of_data_out(n : integer)return integer;
function get_codeword_size (constant data_width : integer) return integer;
end;

package body hamming_pack is
function Num_Pow_of_2(X : integer) return integer is
	
	variable sum:  real;
	variable sum1: real;
	variable sum2: real;
	variable sum3: real;
	
	begin
	
	sum1:=log2(real(X));
	sum2:=sum1+0.0001;
	sum3:=floor(sum2);
	sum:=sum1 - sum3;
	
	if sum<=0.0 then
		return 1;
	else
		return 0;
	end if;
	end Num_Pow_of_2;

function Num_of_data_out(n : integer)return integer is

	variable k: integer:=1;
	
	begin
	
	for i in 0 to n loop
		if 2**k<n+k+1 then
			k:=k+1;
		end if;
	end loop;
	
	return k+n;

end Num_of_data_out;

function get_codeword_size (constant data_width : integer) return integer is
   
   begin
      for i in 1 to data_width loop
         if ((2**i) >= (data_width+i+1)) then
            return (data_width+i);
         end if;
      end loop;
      return 0;
	  
   end function get_codeword_size;

end package body hamming_pack;
