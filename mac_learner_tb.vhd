library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use std.textio.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mac_learner_tb is
end;
-- HEJ hej
architecture bench of mac_learner_tb is
  -- Clock period
  constant clk_period : time := 4 ns; 
 -- HEJ
  -- Generics
  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal saddress : std_logic_vector (47 downto 0);
  signal daddress : std_logic_vector (47 downto 0);
  signal portnum : std_logic_vector (2 downto 0);
  signal sel : std_logic_vector (2 downto 0);

  component mac_learner is
    port (
        clk             : in std_logic;
        reset           : in std_logic;
        saddress        : in std_logic_vector (47 downto 0);
        daddress        : in std_logic_vector (47 downto 0);
        portnum         : in std_logic_vector (2 downto 0);

        sel             : out std_logic_vector (2 downto 0)
        --rrobin          : out std_logic_vector (2 downto 0)
        
    );
  end component;

begin

  DUT : mac_learner
  port map (
    clk => clk,
    reset => reset,
    saddress => saddress,
    daddress => daddress,
    portnum => portnum,
    sel => sel
  );

  rclk_process : process
  begin
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
  end process;



   -- Stimulus generation process
   stimulus_process : process
    constant saddr    : std_logic_vector(47 downto 0) := X"1122334455FF";
    constant port1    : std_logic_vector(2 downto 0) := "0001";
    
    constant daddr : std_logic_vector(47 downto 0) := X"123123123200";
    
    --000000000001000100100010001100110100010001010101
  begin
    --reset <= '0';

    if rising_edge(clk) then
        saddress    <= saddr;
        daddress    <= daddr;
        portnum     <= port1;
    end if;

    -- Wait for some time after sending the message (optional)
    wait for 10 ns; -- Adjust based on your simulation needs

  end process;




end;