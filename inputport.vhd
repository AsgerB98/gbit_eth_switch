library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity inputport is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    data_in : in std_logic_vector (7 downto 0);
    valid   : in std_logic;
    send_data : in std_logic;

    srcMac : out std_logic_vector(47 downto 0);
    dstMac : out std_logic_vector(47 downto 0);
    fcs_error_IP : out std_logic;
    packet_size  : out integer;
    data_out: out std_logic_vector (7 downto 0)
  );
end entity;

architecture inputport_arch of inputport is
  component FIFOSwitch is
    port (
      clock		: IN STD_LOGIC ;
      data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdreq		: IN STD_LOGIC ;
      wrreq		: IN STD_LOGIC ;
      empty		: OUT STD_LOGIC ;
      full		: OUT STD_LOGIC ;
      q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      usedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
    );
  end component;
  
  component FCS is
    port (
      clk : in std_logic;
      reset : in std_logic;
      start_of_frame : in std_logic;
      data_in : in std_logic_vector(7 downto 0);
      fcs_error : out std_logic
    );
  end component;


  signal fcs_fromfcs : std_logic;
  
  signal empty_fifo : std_logic := '0';
  signal full_fifo : std_logic := '0';
  signal status_fifo : std_logic_vector (10 downto 0) := (others => '0');

  signal SoF  : std_logic := '0';
  signal counter : integer := 0;

  signal tempsrc : std_logic_vector (47 downto 0) := (others => '1');
  signal tempdst : std_logic_vector (47 downto 0) := (others => '0');

  signal read_fifo : std_logic := '0';
  signal started : std_logic := '0';
  signal numbytes : integer := 0;
  signal curr_byte : integer := 0;
  signal send_pkt : std_logic := '0';

  signal delay_sig, delay_sig_after : std_logic := '0';  
  signal test : std_logic := '0';
  
  
begin
  fcs_error_IP <= fcs_fromfcs;
  clk_proc : process (clk, reset, counter, valid, SoF, send_data, send_pkt, fcs_fromfcs, delay_sig)
  begin
    if reset = '1' then

    elsif rising_edge(clk) then
      if valid = '1' then
        counter <= counter +1;
        started <= '1';
        --SoF <= '1';
      end if;
      
      -- Prepping the MAC addrs:
      case counter is
        when 0 => SoF <= '0';
        when 1 => tempsrc(47 downto 40) <= data_in;
        when 2 => tempsrc(39 downto 32) <= data_in;
        when 3 => tempsrc(31 downto 24) <= data_in;
        when 4 => tempsrc(23 downto 16) <= data_in;
        when 5 => tempsrc(15 downto 8) <= data_in;
        when 6 => srcMac(47 downto 8) <= tempsrc(47 downto 8);
                    srcMac(7 downto 0) <= data_in;
        when 7 => tempdst(47 downto 40) <= data_in;
        when 8 => tempdst(39 downto 32) <= data_in;
        when 9 => tempdst(31 downto 24) <= data_in;
        when 10 => tempdst(23 downto 16) <= data_in;
        when 11 => tempdst(15 downto 8) <= data_in;
        when 12 => dstMac(47 downto 8) <= tempdst(47 downto 8);
                    dstMac(7 downto 0) <= data_in;
        when others =>
          null;
      end case;

      if send_pkt = '1' then
        read_fifo <= '1';
        curr_byte <= curr_byte +1;
        if curr_byte = numbytes +1 then -- pkt done
          read_fifo <= '0';
          delay_sig <= '0';
          curr_byte <= 0;
          send_pkt <= '0';
        end if;
      end if;

      if send_data = '1' then
        read_fifo <= '1';
        curr_byte <= curr_byte +1;
        if curr_byte = numbytes then -- pkt done
          read_fifo <= '0';
          delay_sig <= '0';
          curr_byte <= 0;
          send_pkt <= '0';
         end if;
      end if;

      if valid = '0' and started = '1' then
        delay_sig <= '1';
        if fcs_fromfcs = '1' and delay_sig = '1' then
          send_pkt <= '1';
        end if;
        numbytes <= counter;
        packet_size <= counter;
      end if;


    end if;

    if rising_edge(valid) then
      counter <= 0;
      SoF <= '1';
    end if;

  end process;


  fifo_ports : FIFOSwitch
    port map (
      clock => clk,
      data => data_in,
      rdreq => read_fifo,
      wrreq => valid,
      empty => empty_fifo,
      full => full_fifo,
      q => data_out,
      usedw => status_fifo
    );

  fcs_ports : FCS
    port map (
      clk => clk,
      reset => reset,
      start_of_frame => SoF, 
      data_in => data_in,
      fcs_error => fcs_fromfcs
    );

end architecture;