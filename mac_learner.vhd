library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use std.textio.all;



entity mac_learner is
    port (
        clk             : in std_logic;
        reset           : in std_logic;
        sMAC            : in std_logic_vector (47 downto 0);
        dMAC            : in std_logic_vector (47 downto 0);
        portnum         : in std_logic_vector (2 downto 0);

        sel             : out std_logic_vector (2 downto 0)
        --rrobin          : out std_logic_vector (2 downto 0)
        
    );
end entity mac_learner;

architecture arch of mac_learner is



    component SRAM
        port (
          clk : in std_logic;
          reset : in std_logic;
          address : in std_logic_vector(8 downto 0);
          data_in : in std_logic_vector(50 downto 0);
          data_out : out std_logic_vector(3 downto 0)
        );
      end component;




begin

    SRAM_inst : SRAM
    port map(
      clk => clk,
      reset => reset,
      RW => RW,
      address => address,
      data_in => data_in,
      data_out => data_out
    );

    

end architecture;
