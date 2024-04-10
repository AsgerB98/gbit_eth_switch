library IEEE;
library std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;
use std.textio.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity inputport_tb is
end;

architecture bench of inputport_tb is
  constant clk_period : time := 5 ns;

  signal clk : std_logic;
  signal reset : std_logic := '1';
  signal data_in : std_logic_vector (7 downto 0);
  signal valid : std_logic;

  signal srcMac : std_logic_vector(47 downto 0);
  signal dstMac : std_logic_vector(47 downto 0);
  signal FCS_error : std_logic;
  signal data_out : std_logic_vector (7 downto 0);

  component inputport is
    port(
      clk     : in std_logic;
      reset   : in std_logic;
      data_in : in std_logic_vector (7 downto 0);
      valid   : in std_logic;

      srcMac : out std_logic_vector(47 downto 0);
      dstMac : out std_logic_vector(47 downto 0);
      FCS_error : out std_logic;
      data_out: out std_logic_vector (7 downto 0)
    );
  end component;
begin

  dut : inputport
    port map (
      clk => clk,
      reset => reset,
      data_in => data_in,
      valid => valid,
      srcMac => srcMac,
      dstMac => dstMac,
      FCS_error => FCS_error,
      data_out => data_out
    );

  clk_process : process
  begin
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;

  end process clk_process;

  rst : process
  begin
    wait for clk_period;
    reset <= '0';
  end process;

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


      data_in <= current_read_field;
      valid <= current_write_line;
    end if;
  end process;

  -- start : process
  -- begin
  --   --valid <= '0';
  --   wait for 10 ns;
  --   valid <= '1';    
  -- end process;

end;

