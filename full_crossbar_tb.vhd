library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity full_crossbar_tb is
end;

architecture bench of full_crossbar_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal inport1 : std_logic_vector (7 downto 0);
  signal inport2 : std_logic_vector (7 downto 0);
  signal inport3 : std_logic_vector (7 downto 0);
  signal inport4 : std_logic_vector (7 downto 0);
  signal port_sel_in1 : std_logic_vector (3 downto 0);
  signal port_sel_in2 : std_logic_vector (3 downto 0);
  signal port_sel_in3 : std_logic_vector (3 downto 0);
  signal port_sel_in4 : std_logic_vector (3 downto 0);
  signal data_out1 : std_logic_vector (7 downto 0);
  signal data_out2 : std_logic_vector (7 downto 0);
  signal data_out3 : std_logic_vector (7 downto 0);
  signal data_out4 : std_logic_vector (7 downto 0);
begin

  dut : full_crossbar
  port map (
    clk => clk,
    reset => reset,
    inport1 => inport1,
    inport2 => inport2,
    inport3 => inport3,
    inport4 => inport4,
    port_sel_in1 => port_sel_in1,
    port_sel_in2 => port_sel_in2,
    port_sel_in3 => port_sel_in3,
    port_sel_in4 => port_sel_in4,
    data_out1 => data_out1,
    data_out2 => data_out2,
    data_out3 => data_out3,
    data_out4 => data_out4
  );
-- clk <= not clk after clk_period/2;

end;