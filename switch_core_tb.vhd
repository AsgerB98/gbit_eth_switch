library IEEE;
library std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;
use std.textio.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity switch_core_tb is
end;

architecture bench of switch_core_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk : std_logic;
  signal reset : std_logic;
  signal inport1 : std_logic_vector (7 downto 0);
  signal valid1 : std_logic;
  signal inport2 : std_logic_vector (7 downto 0);
  signal valid2 : std_logic;
  signal inport3 : std_logic_vector (7 downto 0);
  signal valid3 : std_logic;
  signal inport4 : std_logic_vector (7 downto 0);
  signal valid4 : std_logic;
  signal outport1 : std_logic_vector (7 downto 0);
  signal outport2 : std_logic_vector (7 downto 0);
  signal outport3 : std_logic_vector (7 downto 0);
  signal outport4 : std_logic_vector (7 downto 0);


  component switch_core is
    port (
      clk   : in std_logic;
      reset : in std_logic;
      
      inport1 : in std_logic_vector (7 downto 0);
      valid1  : in std_logic;

      inport2 : in std_logic_vector (7 downto 0);
      valid2  : in std_logic;

      inport3 : in std_logic_vector (7 downto 0);
      valid3  : in std_logic;

      inport4 : in std_logic_vector (7 downto 0);
      valid4  : in std_logic;

      outport1 : out std_logic_vector (7 downto 0);
      outport2 : out std_logic_vector (7 downto 0);
      outport3 : out std_logic_vector (7 downto 0);
      outport4 : out std_logic_vector (7 downto 0)
      
    );
  end component;
begin

  dut : switch_core
  port map (
    clk => clk,
    reset => reset,
    inport1 => inport1,
    valid1 => valid1,
    inport2 => inport2,
    valid2 => valid2,
    inport3 => inport3,
    valid3 => valid3,
    inport4 => inport4,
    valid4 => valid4,
    outport1 => outport1,
    outport2 => outport2,
    outport3 => outport3,
    outport4 => outport4
  );
  -- clk <= not clk after clk_period/2;
  reading_proc : process (clk, reset)
    file input : TEXT open READ_MODE is "Input_packet.txt"; 
  
    variable current_read_line	: line;
    variable current_read_field	: std_logic_vector (7 downto 0);
    --variable current_write_line : std_logic_vector (0 downto 0);
    variable current_write_line : std_logic;
    --variable start_of_data_Reader : std_logic;

  begin

    if reset = '1' then
    
  
    elsif rising_edge(clk) then
      readline(input, current_read_line);
      hread(current_read_line, current_read_field);
      read(current_read_line, current_write_line);


      inport1 <= current_read_field;
      valid1 <= current_write_line;
      -- done1 <= current_write_line;
      -- --port_sel_in1 <= "0010";

      -- inport2 <= current_read_field;
      -- done2 <= current_write_line;

      -- inport3 <= current_read_field;
      -- done3 <= current_write_line;

      -- inport4 <= current_read_field;
      -- done4 <= current_write_line;
    end if;
  end process;


  reset_proc : process
    begin
      reset <= '1'; wait for clk_period;
      reset <= '0'; wait;
    end process;

  clk_process : process
  begin
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;

  end process;

end;