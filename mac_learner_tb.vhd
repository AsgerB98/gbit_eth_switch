
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
  signal countMsg : integer := 0;
  signal countClk : std_logic_vector (1 downto 0) := (others => '0') ;
  
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

  -- mac_inc_proc : process
  -- begin
  --   --wait for 4ns;
  --   MAC_inc <= '1';
  --   wait for 5 ns;
  --   MAC_inc <= '0';
  -- end process;

  input : process
    variable msg_index : integer := 0;
    --constant srcmsg : std_logic_vector(47 downto 0) := X"02C3E4333DEF"; --02C3E4333DEF 793
    --constant dstmsg : std_logic_vector(47 downto 0) := X"312343333333"; -- 312343333333 7!
    constant srcmsg : std_logic_vector(191 downto 0) := X"32C3E4333DEF02C3E4333DEF02C3E4333DEF312343333332"; --02C3E4333DEF 793
    constant dstmsg : std_logic_vector(191 downto 0) := X"12C3E4333DEF02C3E4333DEF31234333333202C3E4333DEF"; -- 312343333333 7!
    constant ports  : std_logic_vector(2 downto 0)  := "000";
  begin

    if countMsg = 0 or countMsg = 96 then
      MAC_inc <= '1';
    else
      MAC_inc <= '0';
    end if;
    
    while countMsg < dstmsg'length loop
      wait until rising_edge(clk);
      --dMAC <= dstmsg(msg_index);
        dMAC(0) <= dstmsg(countMsg);
        dMAC(1) <= dstmsg(countMsg +1);
        dMAC(2) <= dstmsg(countMsg +2);
        dMAC(3) <= dstmsg(countMsg +3);
        dMAC(4) <= dstmsg(countMsg +4);
        dMAC(5) <= dstmsg(countMsg +5);
        dMAC(6) <= dstmsg(countMsg +6);
        dMAC(7) <= dstmsg(countMsg +7);
        dMAC(8) <= dstmsg(countMsg +8);
        dMAC(9) <= dstmsg(countMsg +9);
        dMAC(10) <= dstmsg(countMsg +10);
        dMAC(11) <= dstmsg(countMsg +11);
        dMAC(12) <= dstmsg(countMsg +12);
        dMAC(13) <= dstmsg(countMsg +13);
        dMAC(14) <= dstmsg(countMsg +14);
        dMAC(15) <= dstmsg(countMsg +15);
        dMAC(16) <= dstmsg(countMsg +16);
        dMAC(17) <= dstmsg(countMsg +17);
        dMAC(18) <= dstmsg(countMsg +18);
        dMAC(19) <= dstmsg(countMsg +19);
        dMAC(20) <= dstmsg(countMsg +20);
        dMAC(21) <= dstmsg(countMsg +21);
        dMAC(22) <= dstmsg(countMsg +22);
        dMAC(23) <= dstmsg(countMsg +23);
        dMAC(24) <= dstmsg(countMsg +24);
        dMAC(25) <= dstmsg(countMsg +25);
        dMAC(26) <= dstmsg(countMsg +26);
        dMAC(27) <= dstmsg(countMsg +27);
        dMAC(28) <= dstmsg(countMsg +28);
        dMAC(29) <= dstmsg(countMsg +29);
        dMAC(30) <= dstmsg(countMsg +30);
        dMAC(31) <= dstmsg(countMsg +31);
        dMAC(32) <= dstmsg(countMsg +32);
        dMAC(33) <= dstmsg(countMsg +33);
        dMAC(34) <= dstmsg(countMsg +34);
        dMAC(35) <= dstmsg(countMsg +35);
        dMAC(36) <= dstmsg(countMsg +36);
        dMAC(37) <= dstmsg(countMsg +37);
        dMAC(38) <= dstmsg(countMsg +38);
        dMAC(39) <= dstmsg(countMsg +39);
        dMAC(40) <= dstmsg(countMsg +40);
        dMAC(41) <= dstmsg(countMsg +41);
        dMAC(42) <= dstmsg(countMsg +42);
        dMAC(43) <= dstmsg(countMsg +43);
        dMAC(44) <= dstmsg(countMsg +44);
        dMAC(45) <= dstmsg(countMsg +45);
        dMAC(46) <= dstmsg(countMsg +46);
        dMAC(47) <= dstmsg(countMsg +47);


        sMAC(0) <= srcmsg(countMsg);
        sMAC(1) <= srcmsg(countMsg +1);
        sMAC(2) <= srcmsg(countMsg +2);
        sMAC(3) <= srcmsg(countMsg +3);
        sMAC(4) <= srcmsg(countMsg +4);
        sMAC(5) <= srcmsg(countMsg +5);
        sMAC(6) <= srcmsg(countMsg +6);
        sMAC(7) <= srcmsg(countMsg +7);
        sMAC(8) <= srcmsg(countMsg +8);
        sMAC(9) <= srcmsg(countMsg +9);
        sMAC(10) <= srcmsg(countMsg +10);
        sMAC(11) <= srcmsg(countMsg +11);
        sMAC(12) <= srcmsg(countMsg +12);
        sMAC(13) <= srcmsg(countMsg +13);
        sMAC(14) <= srcmsg(countMsg +14);
        sMAC(15) <= srcmsg(countMsg +15);
        sMAC(16) <= srcmsg(countMsg +16);
        sMAC(17) <= srcmsg(countMsg +17);
        sMAC(18) <= srcmsg(countMsg +18);
        sMAC(19) <= srcmsg(countMsg +19);
        sMAC(20) <= srcmsg(countMsg +20);
        sMAC(21) <= srcmsg(countMsg +21);
        sMAC(22) <= srcmsg(countMsg +22);
        sMAC(23) <= srcmsg(countMsg +23);
        sMAC(24) <= srcmsg(countMsg +24);
        sMAC(25) <= srcmsg(countMsg +25);
        sMAC(26) <= srcmsg(countMsg +26);
        sMAC(27) <= srcmsg(countMsg +27);
        sMAC(28) <= srcmsg(countMsg +28);
        sMAC(29) <= srcmsg(countMsg +29);
        sMAC(30) <= srcmsg(countMsg +30);
        sMAC(31) <= srcmsg(countMsg +31);
        sMAC(32) <= srcmsg(countMsg +32);
        sMAC(33) <= srcmsg(countMsg +33);
        sMAC(34) <= srcmsg(countMsg +34);
        sMAC(35) <= srcmsg(countMsg +35);
        sMAC(36) <= srcmsg(countMsg +36);
        sMAC(37) <= srcmsg(countMsg +37);
        sMAC(38) <= srcmsg(countMsg +38);
        sMAC(39) <= srcmsg(countMsg +39);
        sMAC(40) <= srcmsg(countMsg +40);
        sMAC(41) <= srcmsg(countMsg +41);
        sMAC(42) <= srcmsg(countMsg +42);
        sMAC(43) <= srcmsg(countMsg +43);
        sMAC(44) <= srcmsg(countMsg +44);
        sMAC(45) <= srcmsg(countMsg +45);
        sMAC(46) <= srcmsg(countMsg +46);
        sMAC(47) <= srcmsg(countMsg +47);

      --dMAC <= dstmsg(msg_index);
      if (countMsg = 0) then
        portnum <= "011";
      else
        portnum <= "001";
      end if;
      if (countClk = "11") then
        countMsg <= countMsg +48;
      end if;
      countClk <= std_logic_vector(unsigned(countClk) + 1);
    end loop;
    wait for 50 ns;
  end process;


end architecture;