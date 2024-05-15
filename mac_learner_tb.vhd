
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
  component mac_learner is
    port
    (
      clk     : in std_logic;
      reset   : in std_logic;
      sMAC    : in std_logic_vector (47 downto 0);
      dMAC    : in std_logic_vector (47 downto 0);
      portnum : in std_logic_vector (2 downto 0);
      MAC_inc : in std_logic;

      sel : out std_logic_vector (3 downto 0)

    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk      : std_logic;
  signal reset    : std_logic;
  signal sMAC     : std_logic_vector (47 downto 0);
  signal dMAC     : std_logic_vector (47 downto 0);
  signal portnum  : std_logic_vector (2 downto 0);
  signal MAC_inc  : std_logic;
  signal countMsg : integer                       := 0;
  signal countClk : std_logic_vector (1 downto 0) := (others => '0');

  signal sel : std_logic_vector (3 downto 0);
begin

  dut : mac_learner
  port map
  (
    clk     => clk,
    reset   => reset,
    sMAC    => sMAC,
    dMAC    => dMAC,
    portnum => portnum,
    MAC_inc => MAC_inc,
    sel     => sel
  );
  clk_process : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process clk_process;

  reset_process : process
  begin
    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    wait;
  end process;

  input : process
    variable msg_index : integer := 0;
    --constant srcmsg : std_logic_vector(47 downto 0) := X"02C3E4333DEF"; --02C3E4333DEF 793
    --constant dstmsg : std_logic_vector(47 downto 0) := X"312343333333"; -- 312343333333 7!
    constant srcmsg : std_logic_vector(191 downto 0) := X"32C3E4333DEF02C3E4333DEF02C3E4333DEF312343333332"; --02C3E4333DEF 793
    constant dstmsg : std_logic_vector(191 downto 0) := X"12C3E4333DEF02C3E4333DEF31234333333202C3E4333DEF"; -- 312343333333 7!
    constant ports  : std_logic_vector(2 downto 0)   := "000";

  begin

    while countMsg < dstmsg'length loop
      wait until rising_edge(clk);
      for i in 0 to 47 loop
        dMAC(i) <= dstmsg(countMsg + i);
        sMAC(i) <= srcmsg(countMsg + i);
      end loop;

      --dMAC <= dstmsg(msg_index);
      if (countMsg = 0) then
        portnum <= "011";
      else
        portnum <= "001";
      end if;
      if (countClk = "11") then
        countMsg <= countMsg + 48;
      end if;
      countClk <= std_logic_vector(unsigned(countClk) + 1);
    end loop;
    wait for 50 ns;
  end process;


  mac_inc_process : process
  begin
    wait for 5 ns;
    MAC_inc <= '1';
    wait for 5 ns;
    MAC_inc <= '0';
    while true loop
      wait for 15 ns;
      MAC_inc <= '1';
      wait for 5 ns;
      MAC_inc <= '0';
    end loop;
  end process;

end architecture;