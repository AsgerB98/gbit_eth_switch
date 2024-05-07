library IEEE;
library std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;
use std.textio.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

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

  signal done1 : std_logic;
  signal done2 : std_logic;
  signal done3 : std_logic;
  signal done4 : std_logic;

  signal port_sel_in1 : std_logic_vector (3 downto 0);
  signal port_sel_in2 : std_logic_vector (3 downto 0);
  signal port_sel_in3 : std_logic_vector (3 downto 0);
  signal port_sel_in4 : std_logic_vector (3 downto 0);

  signal data_out1 : std_logic_vector (7 downto 0);
  signal data_out2 : std_logic_vector (7 downto 0);
  signal data_out3 : std_logic_vector (7 downto 0);
  signal data_out4 : std_logic_vector (7 downto 0);


  component full_crossbar is
    port (
      clk   : in std_logic;
    reset : in std_logic;
    
    inport1 : in std_logic_vector (7 downto 0);
    inport2 : in std_logic_vector (7 downto 0);
    inport3 : in std_logic_vector (7 downto 0);
    inport4 : in std_logic_vector (7 downto 0);

    done1 : in std_logic;
    done2 : in std_logic;
    done3 : in std_logic;
    done4 : in std_logic;

    port_sel_in1 : in std_logic_vector (3 downto 0);
    port_sel_in2 : in std_logic_vector (3 downto 0);
    port_sel_in3 : in std_logic_vector (3 downto 0);
    port_sel_in4 : in std_logic_vector (3 downto 0);

    data_out1 : out std_logic_vector (7 downto 0);
    data_out2 : out std_logic_vector (7 downto 0);
    data_out3 : out std_logic_vector (7 downto 0);
    data_out4 : out std_logic_vector (7 downto 0)
      
    );
  end component;
begin

  dut : full_crossbar
  port map (
    clk => clk,
    reset => reset,

    inport1 => inport1,
    inport2 => inport2,
    inport3 => inport3,
    inport4 => inport4,

    done1 => done1,
    done2 => done2,
    done3 => done3,
    done4 => done4,

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
reading_proc : process (clk, reset)
  file input : TEXT open READ_MODE is "Input_packet_CB.txt"; 
  
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
    done1 <= current_write_line;
    --port_sel_in1 <= "0010";

    inport2 <= current_read_field;
    done2 <= current_write_line;

    inport3 <= current_read_field;
    done3 <= current_write_line;

    inport4 <= current_read_field;
    done4 <= current_write_line;
  end if;
end process;

portin : process
begin
  wait for clk_period;
  port_sel_in1 <= "1111";
  port_sel_in2 <= "0001";
  port_sel_in3 <= "0001";
  port_sel_in4 <= "0001";
  
  wait for 320 ns; -- Use 'wait for' instead of 'wait'
  port_sel_in1 <= "0011";
  port_sel_in2 <= "0011";
  port_sel_in3 <= "0100";
  port_sel_in4 <= "0001";
  wait for 320 ns;
  port_sel_in1 <= "0100";

  wait for 320 ns;
  port_sel_in4 <= "0011";

  wait for 320 ns;
  port_sel_in1 <= "1111";
  
  wait for 320 ns;
  port_sel_in1 <= "0011";
  wait; -- Add a wait statement to prevent the process from terminating immediately
end process portin;


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