
library IEEE;
library std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;
use std.textio.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity controlUnit_tb is
end;

architecture bench of controlUnit_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal inport1 : std_logic_vector (7 downto 0);
  signal inport2 : std_logic_vector (7 downto 0);
  -- signal inport3 : std_logic_vector (7 downto 0);
  -- signal inport4 : std_logic_vector (7 downto 0);
  signal valid1 : std_logic;
  signal valid2 : std_logic;
  -- signal valid3 : std_logic;
  -- signal valid4 : std_logic;

  signal port_sel : std_logic_vector (3 downto 0);


  signal port_sel_out1 : std_logic_vector (3 downto 0);
  signal port_sel_out2 : std_logic_vector (3 downto 0);
  signal port_sel_out3 : std_logic_vector (3 downto 0);
  signal port_sel_out4 : std_logic_vector (3 downto 0);

  signal dst_mac : std_logic_vector (47 downto 0);
  signal src_mac : std_logic_vector (47 downto 0);

  signal data_out1 : std_logic_vector (7 downto 0);
  signal data_out2 : std_logic_vector (7 downto 0);
  -- signal data_out3 : std_logic_vector (7 downto 0);
  -- signal data_out4 : std_logic_vector (7 downto 0);

  component controlUnit is
    port (
    clk   : in std_logic;
    reset : in std_logic;
        
    inport1 : in std_logic_vector (7 downto 0);
    inport2 : in std_logic_vector (7 downto 0);
    -- inport3 : in std_logic_vector (7 downto 0);
    -- inport4 : in std_logic_vector (7 downto 0);

    valid1  : in std_logic;
    valid2  : in std_logic;
    -- valid3  : in std_logic;
    -- valid4  : in std_logic;

    port_sel : in std_logic_vector (3 downto 0);

    port_sel_out1 : out std_logic_vector (3 downto 0); --??
    port_sel_out2 : out std_logic_vector (3 downto 0); --??
    port_sel_out3 : out std_logic_vector (3 downto 0); --??
    port_sel_out4 : out std_logic_vector (3 downto 0); --??
        
    dst_mac : out std_logic_vector (47 downto 0);
    src_mac : out std_logic_vector (47 downto 0);

    data_out1 : out std_logic_vector (7 downto 0);
    data_out2 : out std_logic_vector (7 downto 0)
    -- data_out3 : out std_logic_vector (7 downto 0);
    -- data_out4 : out std_logic_vector (7 downto 0)
        
    );
  end component;

begin

  dut : controlUnit
  port map (
    clk => clk,
    reset => reset,
    inport1 => inport1,
    inport2 => inport2,
    -- inport3 => inport3,
    -- inport4 => inport4,
    valid1 => valid1,
    valid2 => valid2,
    -- valid3 => valid3,
    -- valid4 => valid4,
    port_sel => port_sel,

    port_sel_out1 => port_sel_out1,
    port_sel_out2 => port_sel_out2,
    port_sel_out3 => port_sel_out3,
    port_sel_out4 => port_sel_out4,

    dst_mac => dst_mac,
    src_mac => src_mac,

    data_out1 => data_out1,
    data_out2 => data_out2
    -- data_out3 => data_out3,
    -- data_out4 => data_out4
  );
-- clk <= not clk after clk_period/2;


reading_proc : process (clk)
  file input : TEXT open READ_MODE is "Input_packet.txt"; 
  
  variable current_read_line	: line;
  variable current_read_field	: std_logic_vector (7 downto 0);
  --variable current_write_line : std_logic_vector (0 downto 0);
  variable current_write_line : std_logic;
  --variable start_of_data_Reader : std_logic;

begin

  if rising_edge(clk) then
    readline(input, current_read_line);
    hread(current_read_line, current_read_field);
    read(current_read_line, current_write_line);


    inport1 <= current_read_field;
    valid1 <= current_write_line;

    inport2 <= current_read_field;
    valid2 <= current_write_line;

    -- inport3 <= current_read_field;
    -- valid3 <= current_write_line;

    -- inport4 <= current_read_field;
    -- valid4 <= current_write_line;
  end if;
end process;

clk_process : process
begin
  clk <= '1'; wait for clk_period/2;
  clk <= '0'; wait for clk_period/2;

end process clk_process;

end;