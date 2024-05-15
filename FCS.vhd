library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity FCS is
  port (
    clk : in std_logic;
    reset : in std_logic;
    start_of_frame : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    fcs_error : out std_logic
  );
end;

architecture FCS_arch of FCS is
  constant POLYNOMIUM : std_logic_vector(32 downto 0) := "100000100110000010001110110110111"; -- G(x)
  signal count : integer range 0 to 4;
  signal R : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
  signal wait_start : std_logic := '0';
    
begin
  process(clk)
    begin
    if rising_edge(clk) then
      if reset = '1' then
        count <= 0;
        R <= (others => '0');
      end if;
      
      if wait_start = '1' then 
        if count < 4 then
          count <= count + 1;
        end if;

        if count < 4 then 
          R(0) <= not data_in(0) xor R(24) xor R(30);
          R(1) <= not data_in(1) xor R(24) xor R(25) xor R(30) xor R(31);
          R(2) <= not data_in(2) xor R(24) xor R(25) xor R(26) xor R(30) xor R(31);
          R(3) <= not data_in(3) xor R(25) xor R(26) xor R(27) xor R(31);
          R(4) <= not data_in(4) xor R(24) xor R(26) xor R(27) xor R(28) xor R(30);
          R(5) <= not data_in(5) xor R(24) xor R(25) xor R(27) xor R(28) xor R(29) xor R(30) xor R(31);
          R(6) <= not data_in(6) xor R(25) xor R(26) xor R(28) xor R(29) xor R(30) xor R(31);
          R(7) <= not data_in(7) xor R(24) xor R(26) xor R(27) xor R(29) xor R(31);
        else
          R(0) <= data_in(0) xor R(24) xor R(30);
          R(1) <= data_in(1) xor R(24) xor R(25) xor R(30) xor R(31);
          R(2) <= data_in(2) xor R(24) xor R(25) xor R(26) xor R(30) xor R(31);
          R(3) <= data_in(3) xor R(25) xor R(26) xor R(27) xor R(31);
          R(4) <= data_in(4) xor R(24) xor R(26) xor R(27) xor R(28) xor R(30);
          R(5) <= data_in(5) xor R(24) xor R(25) xor R(27) xor R(28) xor R(29) xor R(30) xor R(31);
          R(6) <= data_in(6) xor R(25) xor R(26) xor R(28) xor R(29) xor R(30) xor R(31);
          R(7) <= data_in(7) xor R(24) xor R(26) xor R(27) xor R(29) xor R(31);
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


        if  R /= X"FFFFFFFF" then -- CHANGE HERE HOW U WANT FCS_ERROR
          --fcs_error <= '1';
        elsif R=X"FFFFFFFF" then
          fcs_error <= '0';
        end if;
      end if;
    
      if start_of_frame = '1' then
        R <= (others => '0');
        count <= 0;
        fcs_error <= '1';
        wait_start <= '1';
      end if;

    end if;

  end process;
end architecture;