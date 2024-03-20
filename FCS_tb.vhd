library ieee;
use ieee.std_logic_1164.all;

entity fcs_check_par_tb is
end entity fcs_check_par_tb;

architecture test of fcs_check_par_tb is

  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal start_of_frame : std_logic := '0';
  signal end_of_frame   : std_logic := '0';
  signal data_in      : std_logic_vector(7 downto 0);
  signal fcs_error   : std_logic := '0';

  component fcs_check_par is
    port (
      clk        : in std_logic;
      reset      : in std_logic;
      start_of_frame : in std_logic;
      end_of_frame   : in std_logic;
      data_in      : in std_logic_vector(7 downto 0);
      fcs_error   : out std_logic
    );
  end component;

  -- Clock period
  constant clk_period : time := 2 ns;

begin

  dut : fcs_check_par
    port map (
      clk         => clk,
      reset       => reset,
      start_of_frame => start_of_frame,
      end_of_frame   => end_of_frame,
      data_in       => data_in,
      fcs_error    => fcs_error
    );

  clk_process : process
  begin
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
  end process clk_process;

  -- Stimulus generation process
  stimulus_process : process
    variable message_index : integer := 0;
    constant message    : std_logic_vector(0 t o 1023) := X"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2"; -- Use hexadecimal notation
    --constant message    : std_logic_vector(0 to 511) := X"af10A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0Fff00ffC53DB2"; -- Use hexadecimal notation

  begin
    reset <= '0';
    while message_index < message'length loop
      wait until rising_edge(clk);
      data_in(0) <= message(message_index);
      data_in(1) <= message(message_index +1);
      data_in(2) <= message(message_index +2);
      data_in(3) <= message(message_index +3);
      data_in(4) <= message(message_index +4);
      data_in(5) <= message(message_index +5);
      data_in(6) <= message(message_index +6);
      data_in(7) <= message(message_index +7);

      -- Assert start_of_frame for one clock cycle when data begins
      if message_index = 0 or message_index = 512 then
        start_of_frame <= '1';
        --wait for 2*clk_period; -- Hold start_of_frame high for one clock cycle
      else
        start_of_frame <= '0';
      end if;
      
      -- Assert end_of_frame for one clock cycle when 32 bits remain
      if message_index = message'length - 32 or message_index = message'length -(512+32) then
        end_of_frame <= '1';
        --wait for 2*clk_period; -- Hold end_of_frame high for one clock cycle
      else
        end_of_frame <= '0';
      end if;

      message_index := message_index + 8;
    end loop;

    -- Wait for some time after sending the message (optional)
    wait for 100 ns; -- Adjust based on your simulation needs

  end process;

end architecture test;