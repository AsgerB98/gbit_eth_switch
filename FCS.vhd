library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- Entity defines input and output of our design
entity fcs_check_par is
    port (
        clk : in std_logic;
        reset : in std_logic;
        start_of_frame : in std_logic;
        end_of_frame : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        fcs_error : out std_logic
    );
end fcs_check_par;


architecture rtl of fcs_check_par is
    constant POLYNOMIUM : std_logic_vector(32 downto 0) := "100000100110000010001110110110111"; -- G(x)
    -- constant POLYNOMIUM : std_logic_vector(32 downto 0) := "111011011011100010000011001000001"; -- G(x)
    signal count : integer range -1 to 32 := -1;
    signal count2 : integer range 0 to 500 := 0;
    signal frameend : integer range 0 to 1 := 0;
    signal status : std_logic := '0';
    signal R : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
begin

process(clk, end_of_frame, start_of_frame, frameend, count, reset)
begin

if (reset = '1') then
    R <= (others => '0'); 
    frameend <= 0;
    count <= -1;
    count2 <= 0;
    status <= '0';
    reset <= '0';

elsif rising_edge(clk) then


if (start_of_frame = '1' or end_of_frame = '1') then
count <= 0;
end if;
if (count < 4) then
count <= count + 1;
end if;


-- Check to determine when the frame ends
if (end_of_frame = '1') then
frameend <= 1;
end if;

if count = -1 then 
  --R(0) <= not data_in xor (R(31) and POLYNOMIUM(0)); --g0
elsif ((count < 4 or start_of_frame = '1' or end_of_frame = '1')) then 

  R(0) <= not data_in(7) xor R(24) xor R(30); --g0
  R(1) <= not data_in(6) xor R(24) xor R(25) xor R(30) xor R(31);
  R(2) <= not data_in(5) xor R(24) xor R(25) xor R(26) xor R(30) xor R(31);
  R(3) <= not data_in(4) xor R(25) xor R(26) xor R(27) xor R(31);
  R(4) <= not data_in(3) xor R(24) xor R(26) xor R(27) xor R(28) xor R(30);
  R(5) <= not data_in(2) xor R(24) xor R(25) xor R(27) xor R(28) xor R(29) xor R(30) xor R(31);
  R(6) <= not data_in(1) xor R(25) xor R(26) xor R(28) xor R(29) xor R(30) xor R(31);
  R(7) <= not data_in(0) xor R(24) xor R(26) xor R(27) xor R(29) xor R(31);
  status <= '0';
else
  R(0) <= data_in(7) xor R(24) xor R(30); --g0
  R(1) <= data_in(6) xor R(24) xor R(25) xor R(30) xor R(31);
  R(2) <= data_in(5) xor R(24) xor R(25) xor R(26) xor R(30) xor R(31);
  R(3) <= data_in(4) xor R(25) xor R(26) xor R(27) xor R(31);
  R(4) <= data_in(3) xor R(24) xor R(26) xor R(27) xor R(28) xor R(30);
  R(5) <= data_in(2) xor R(24) xor R(25) xor R(27) xor R(28) xor R(29) xor R(30) xor R(31);
  R(6) <= data_in(1) xor R(25) xor R(26) xor R(28) xor R(29) xor R(30) xor R(31);
  R(7) <= data_in(0) xor R(24) xor R(26) xor R(27) xor R(29) xor R(31);
  status <= '1';
  count2 <= count2+1;
end if; 


R(8) <= R(0) xor R(24) xor R(25) xor R(27) xor R(28);
R(9) <= R(1) xor R(25) xor R(26) xor R(28) xor R(29);
R(10) <= R(2) xor R(24) xor R(26) xor R(27) xor R(29);
R(11) <= R(3) xor R(24) xor R(25) xor R(27) xor R(28);
R(12) <= R(4) xor R(24) xor R(25) xor R(26) xor R(28) xor R(29) xor R(30);
R(13) <= R(5) xor R(25) xor R(26) xor R(27) xor R(29) xor R(30) xor R(31);
R(14) <= R(6) xor R(26) xor R(27) xor R(28) xor R(30) xor R(31);
R(15) <= R(7) xor R(27) xor R(28) xor R(29) xor R(31);
R(16) <= R(8) xor R(24) xor R(28) xor R(29);
R(17) <= R(9) xor R(25) xor R(29) xor R(30);
R(18) <= R(10) xor R(26) xor R(30) xor R(31);
R(19) <= R(11) xor R(27) xor R(31);
R(20) <= R(12) xor R(28);
R(21) <= R(13) xor R(29);
R(22) <= R(14) xor R(24);
R(23) <= R(15) xor R(24) xor R(25) xor R(30);
R(24) <= R(16) xor R(25) xor R(26) xor R(31);
R(25) <= R(17) xor R(26) xor R(27);
R(26) <= R(18) xor R(24) xor R(27) xor R(28) xor R(30);
R(27) <= R(19) xor R(25) xor R(28) xor R(29) xor R(31);
R(28) <= R(20) xor R(26) xor R(29) xor R(30);
R(29) <= R(21) xor R(27) xor R(30) xor R(31);
R(30) <= R(22) xor R(28) xor R(31);
R(31) <= R(23) xor R(29);


if (frameend = 1 and count = 3) then
if (R="00000000000000000000000000000000") then
fcs_error <= '0';
else
fcs_error <= '1';
end if;
end if;

end if;
end process;
end architecture;