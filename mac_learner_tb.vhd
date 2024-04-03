
library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mac_learner_tb is
end;

architecture bench of mac_learner_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal sMAC : std_logic_vector (47 downto 0);
  signal dMAC : std_logic_vector (47 downto 0);
  signal portnum : std_logic_vector (2 downto 0);
  signal MAC_inc : std_logic;
  
  signal sel : std_logic_vector (3 downto 0);

  component mac_learner is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        sMAC    : in std_logic_vector (47 downto 0);
        dMAC    : in std_logic_vector (47 downto 0);
        portnum : in std_logic_vector (2 downto 0);
        MAC_inc : in std_logic;
    
        sel     : out std_logic_vector (3 downto 0)
        
    );
  end component;

begin

  dut : mac_learner
  port map (
    clk => clk,
    reset => reset,
    sMAC => sMAC,
    dMAC => dMAC,
    portnum => portnum,
    MAC_inc => MAC_inc,
    sel => sel
  );

  
  clk_process : process
  begin
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
  end process clk_process;

  mac_inc_proc : process
  begin
    --wait for 4ns;
    MAC_inc <= '1';
    wait for 5 ns;
    MAC_inc <= '0';
  end process;

  input : process
    variable msg_index : integer := 0;
    constant srcmsg : std_logic_vector(47 downto 0) := X"02C3E4333DEF"; --02C3E4333DEF 793
    constant dstmsg : std_logic_vector(47 downto 0) := X"312343333333"; -- 312343333333 7!
    constant ports  : std_logic_vector(2 downto 0)  := "000";
  begin
    
    while msg_index < dstmsg'length loop
      wait until rising_edge(clk);
      --dMAC <= dstmsg(msg_index);
        dMAC(0) <= dstmsg(msg_index);
        dMAC(1) <= dstmsg(msg_index +1);
        dMAC(2) <= dstmsg(msg_index +2);
        dMAC(3) <= dstmsg(msg_index +3);
        dMAC(4) <= dstmsg(msg_index +4);
        dMAC(5) <= dstmsg(msg_index +5);
        dMAC(6) <= dstmsg(msg_index +6);
        dMAC(7) <= dstmsg(msg_index +7);
        dMAC(8) <= dstmsg(msg_index +8);
        dMAC(9) <= dstmsg(msg_index +9);
        dMAC(10) <= dstmsg(msg_index +10);
        dMAC(11) <= dstmsg(msg_index +11);
        dMAC(12) <= dstmsg(msg_index +12);
        dMAC(13) <= dstmsg(msg_index +13);
        dMAC(14) <= dstmsg(msg_index +14);
        dMAC(15) <= dstmsg(msg_index +15);
        dMAC(16) <= dstmsg(msg_index +16);
        dMAC(17) <= dstmsg(msg_index +17);
        dMAC(18) <= dstmsg(msg_index +18);
        dMAC(19) <= dstmsg(msg_index +19);
        dMAC(20) <= dstmsg(msg_index +20);
        dMAC(21) <= dstmsg(msg_index +21);
        dMAC(22) <= dstmsg(msg_index +22);
        dMAC(23) <= dstmsg(msg_index +23);
        dMAC(24) <= dstmsg(msg_index +24);
        dMAC(25) <= dstmsg(msg_index +25);
        dMAC(26) <= dstmsg(msg_index +26);
        dMAC(27) <= dstmsg(msg_index +27);
        dMAC(28) <= dstmsg(msg_index +28);
        dMAC(29) <= dstmsg(msg_index +29);
        dMAC(30) <= dstmsg(msg_index +30);
        dMAC(31) <= dstmsg(msg_index +31);
        dMAC(32) <= dstmsg(msg_index +32);
        dMAC(33) <= dstmsg(msg_index +33);
        dMAC(34) <= dstmsg(msg_index +34);
        dMAC(35) <= dstmsg(msg_index +35);
        dMAC(36) <= dstmsg(msg_index +36);
        dMAC(37) <= dstmsg(msg_index +37);
        dMAC(38) <= dstmsg(msg_index +38);
        dMAC(39) <= dstmsg(msg_index +39);
        dMAC(40) <= dstmsg(msg_index +40);
        dMAC(41) <= dstmsg(msg_index +41);
        dMAC(42) <= dstmsg(msg_index +42);
        dMAC(43) <= dstmsg(msg_index +43);
        dMAC(44) <= dstmsg(msg_index +44);
        dMAC(45) <= dstmsg(msg_index +45);
        dMAC(46) <= dstmsg(msg_index +46);
        dMAC(47) <= dstmsg(msg_index +47);


        sMAC(0) <= srcmsg(msg_index);
        sMAC(1) <= srcmsg(msg_index +1);
        sMAC(2) <= srcmsg(msg_index +2);
        sMAC(3) <= srcmsg(msg_index +3);
        sMAC(4) <= srcmsg(msg_index +4);
        sMAC(5) <= srcmsg(msg_index +5);
        sMAC(6) <= srcmsg(msg_index +6);
        sMAC(7) <= srcmsg(msg_index +7);
        sMAC(8) <= srcmsg(msg_index +8);
        sMAC(9) <= srcmsg(msg_index +9);
        sMAC(10) <= srcmsg(msg_index +10);
        sMAC(11) <= srcmsg(msg_index +11);
        sMAC(12) <= srcmsg(msg_index +12);
        sMAC(13) <= srcmsg(msg_index +13);
        sMAC(14) <= srcmsg(msg_index +14);
        sMAC(15) <= srcmsg(msg_index +15);
        sMAC(16) <= srcmsg(msg_index +16);
        sMAC(17) <= srcmsg(msg_index +17);
        sMAC(18) <= srcmsg(msg_index +18);
        sMAC(19) <= srcmsg(msg_index +19);
        sMAC(20) <= srcmsg(msg_index +20);
        sMAC(21) <= srcmsg(msg_index +21);
        sMAC(22) <= srcmsg(msg_index +22);
        sMAC(23) <= srcmsg(msg_index +23);
        sMAC(24) <= srcmsg(msg_index +24);
        sMAC(25) <= srcmsg(msg_index +25);
        sMAC(26) <= srcmsg(msg_index +26);
        sMAC(27) <= srcmsg(msg_index +27);
        sMAC(28) <= srcmsg(msg_index +28);
        sMAC(29) <= srcmsg(msg_index +29);
        sMAC(30) <= srcmsg(msg_index +30);
        sMAC(31) <= srcmsg(msg_index +31);
        sMAC(32) <= srcmsg(msg_index +32);
        sMAC(33) <= srcmsg(msg_index +33);
        sMAC(34) <= srcmsg(msg_index +34);
        sMAC(35) <= srcmsg(msg_index +35);
        sMAC(36) <= srcmsg(msg_index +36);
        sMAC(37) <= srcmsg(msg_index +37);
        sMAC(38) <= srcmsg(msg_index +38);
        sMAC(39) <= srcmsg(msg_index +39);
        sMAC(40) <= srcmsg(msg_index +40);
        sMAC(41) <= srcmsg(msg_index +41);
        sMAC(42) <= srcmsg(msg_index +42);
        sMAC(43) <= srcmsg(msg_index +43);
        sMAC(44) <= srcmsg(msg_index +44);
        sMAC(45) <= srcmsg(msg_index +45);
        sMAC(46) <= srcmsg(msg_index +46);
        sMAC(47) <= srcmsg(msg_index +47);

      --dMAC <= dstmsg(msg_index);
      portnum <= "011";

      msg_index := msg_index +48;


      wait for 100 ns;
    end loop;
  end process;



end;