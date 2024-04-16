library ieee;
use ieee.std_logic_1164.all;

entity fcs_tb is
end entity fcs_tb;

architecture test of fcs_tb is

  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal start_of_frame : std_logic := '0';
  signal data_in      : std_logic_vector(7 downto 0);
  signal fcs_error   : std_logic := '0';

  component fcs is
    port (
      clk        : in std_logic;
      reset      : in std_logic;
      start_of_frame : in std_logic;
      data_in      : in std_logic_vector(7 downto 0);
      fcs_error   : out std_logic
    );
  end component;

  -- Clock period
  constant clk_period : time := 2 ns;

begin

  dut : fcs
    port map (
      clk         => clk,
      reset       => reset,
      start_of_frame => start_of_frame,
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
    -- err msg:
    --constant message    : std_logic_vector(0 to 2047) := X"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20011A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    --correct msg:
    --constant message  : std_logic_vector(0 to 2047) := X"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB20010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    --constant message    : std_logic_vector(0 to 431) := X"001122334455AABBCCDDEEFF080045000028000100004006F97BC0A80002C0A8000104D20050000000000000000050022000096D0000"; -- Use hexadecimal notation
    --constant message  : std_logic_vector(0 to 743) := X"001b21cda37000e04d6d31aa08004500004f120440008006000052d3dc2c12ad0558ff0201bb5fcaf1623e89eec6501804034746000017030300221ac04aca3e5f46c3a84318c7bcc1fd97bbc44a4e9730acdee2d156df25f6a5cdccb9";
    --constant message  : std_logic_vector(0 to 431) := X"001b21cda37000e04d6d31aa0800450000287e9540008006000052d3dc2c3448363eff0501bb34888ec2077163485011040299a00000";
    --constant message  : std_logic_vector(0 to 575) := X"00464400555555d50e2b7cffd4b212555500012d0806000108000604000212555500012dc0a807040e2b7cffd4b2c0a80701000000000000000000000000000000000000e60b7d1e";
    constant message  : std_logic_vector(0 to 943) := X"aaaaaaaaaaaaaaabf0def12cc22bf45c89bd332d0800450000600000000008066862867e8ddd5dd8d82213880050000000170000002a50101000cf330000474554202f20485454502f312e310d0a486f73743a206578616d706c652e636f6d0d0a436f6e6e656374696f6e3a20636c6f73650d0a0d0a";
  begin
    reset <= '0';
    while message_index < message'length loop
      wait until rising_edge(clk);
      data_in(7) <= message(message_index);
      data_in(6) <= message(message_index +1);
      data_in(5) <= message(message_index +2);
      data_in(4) <= message(message_index +3);
      data_in(3) <= message(message_index +4);
      data_in(2) <= message(message_index +5);
      data_in(1) <= message(message_index +6);
      data_in(0) <= message(message_index +7);

      if message_index = 0 or message_index = 512 or message_index = 1024 or message_index = 1536 then
        start_of_frame <= '1';
      else
        start_of_frame <= '0';
      end if;

      message_index := message_index + 8;
    end loop;

    wait for 100 ns;

  end process;
end architecture test;