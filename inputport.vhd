library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity inputport is
  port
  (
    clk       : in std_logic;
    reset     : in std_logic;
    data_in   : in std_logic_vector (7 downto 0);
    valid     : in std_logic;
    send_data : in std_logic;

    srcMac       : out std_logic_vector(47 downto 0);
    dstMac       : out std_logic_vector(47 downto 0);
    fcs_error_IP : out std_logic;
    packet_size  : out integer;
    data_out     : out std_logic_vector (7 downto 0)
  );
end entity;

architecture inputport_arch of inputport is
  component FIFOSwitch is
    port
    (
      clock : in std_logic;
      data  : in std_logic_vector (7 downto 0);
      rdreq : in std_logic;
      wrreq : in std_logic;
      empty : out std_logic;
      full  : out std_logic;
      q     : out std_logic_vector (7 downto 0);
      usedw : out std_logic_vector (10 downto 0)
    );
  end component;

  component FCS is
    port
    (
      clk            : in std_logic;
      reset          : in std_logic;
      start_of_frame : in std_logic;
      data_in        : in std_logic_vector(7 downto 0);
      fcs_error      : out std_logic
    );
  end component;

  signal fcs_fromfcs : std_logic;
  signal empty_fifo  : std_logic                      := '0';
  signal full_fifo   : std_logic                      := '0';
  signal status_fifo : std_logic_vector (10 downto 0) := (others => '0');

  signal SoF     : std_logic               := '0';
  signal counter : integer range 0 to 2000 := 7;

  signal read_fifo             : std_logic               := '0';
  signal started, started_next : std_logic               := '0';
  signal curr_byte             : integer range 0 to 2000 := 0;
  signal send_pkt              : std_logic               := '0';

  signal delay_sig                          : std_logic                     := '0';
  signal preamble                           : std_logic_vector (6 downto 0) := (others => '0');
  signal writefifo, writefifo_next          : std_logic                     := '0';
  signal wait_start, wait_start_next        : std_logic                     := '0';
  signal packet_size_next, packet_size_read : integer range 0 to 2000;
  signal sendto_sig : std_logic_vector(7 downto 0) := (others => '0');
  signal delay_sig_send : std_logic := '0';
  signal delay_sig_send_extra : std_logic := '0';
  
  


begin
  fcs_error_IP <= fcs_fromfcs;
  packet_size  <= packet_size_next;
  clk_proc : process (clk)
  begin

    if rising_edge(clk) then
      if reset = '1' then
      end if;
      started          <= started_next;
      writefifo        <= writefifo_next;
      packet_size_read <= packet_size_next;
      wait_start       <= wait_start_next;

      delay_sig_send <= send_data;
      delay_sig_send_extra <= delay_sig_send;

      if valid = '1' then
        if preamble = "1111111" then
          preamble <= (others => '0');
        end if;
        if data_in = X"AA" then
          preamble <= '1' & preamble(preamble'high downto 1);
        end if;
      end if;

      if started_next = '1' then
        counter <= counter + 1;

        case counter is
          when 0  => srcMac(47 downto 40) <= data_in;
          when 1  => srcMac(39 downto 32) <= data_in;
          when 2  => srcMac(31 downto 24) <= data_in;
          when 3  => srcMac(23 downto 16) <= data_in;
          when 4  => srcMac(15 downto 8)  <= data_in;
          when 5  => srcMac(7 downto 0)   <= data_in;
          when 6  => dstMac(47 downto 40) <= data_in;
          when 7  => dstMac(39 downto 32) <= data_in;
          when 8  => dstMac(31 downto 24) <= data_in;
          when 9  => dstMac(23 downto 16) <= data_in;
          when 10 => dstMac(15 downto 8) <= data_in;
          when 11 => dstMac(7 downto 0)  <= data_in;
          when others =>
            null;
        end case;
      end if;

      if SoF = '1' then
        counter   <= 0;
        delay_sig <= '0';
      end if;

      if send_data = '0' then
        read_fifo <= '0';
        
        if delay_sig_send_extra = '1' then
        end if;

        if send_pkt = '1' then
          send_pkt  <= '1';
          read_fifo <= '1';
          curr_byte <= curr_byte + 1;
          if curr_byte = packet_size_read +1 then -- pkt done
            read_fifo <= '0';
            --delay_sig <= '0';
            curr_byte <= 0;
            send_pkt  <= '0';
          end if;
        end if;

      elsif send_data = '1' then

        --data_out <= sendto_sig;
        read_fifo <= '1';


      end if;

      if valid = '0' and wait_start = '1' then --pkt failed so get it out of fifo
        delay_sig <= '1';
        if fcs_fromfcs = '1' and delay_sig = '1' then
          send_pkt <= '1';
        end if;
      end if;
    end if;

  end process;

  process (delay_sig_send, sendto_sig)
  begin
    if delay_sig_send = '1' then
      data_out <= sendto_sig;
    end if;
  end process;



  process (data_in, preamble, valid, counter, started, writefifo, packet_size_read, wait_start)
  begin

    started_next     <= started;
    writefifo_next   <= writefifo;
    packet_size_next <= packet_size_read;
    wait_start_next  <= wait_start;

    if preamble = "1111111" and data_in = X"AB" then
      SoF             <= '1';
      started_next    <= '1';
      wait_start_next <= '1';
    else
      SoF <= '0';
    end if;

    if valid = '0' then
      started_next     <= '0';
      packet_size_next <= counter;
      writefifo_next   <= '0';
    end if;

    if counter = 0 then
      writefifo_next <= '1';
    end if;

  end process;
  fifo_ports : FIFOSwitch
  port map
  (
    clock => clk,
    data  => data_in,
    rdreq => read_fifo,
    wrreq => writefifo_next,
    empty => empty_fifo,
    full  => full_fifo,
    q     => sendto_sig,
    usedw => status_fifo
  );

  fcs_ports : FCS
  port
  map (
  clk            => clk,
  reset          => reset,
  start_of_frame => SoF,
  data_in        => data_in,
  fcs_error      => fcs_fromfcs
  );

end architecture;
-- if data_in = X"AA" then
--   preamble(0) <= '1';
-- if preamble(0) = '1' and preamble(1) = '1' and preamble(2) = '1' and preamble(3) = '1' and preamble(4) = '1' and preamble(5) = '1' then
--   preamble(6) <= '1';
-- elsif preamble(0) = '1' and preamble(1) = '1' and preamble(2) = '1' and preamble(3) = '1' and preamble(4) = '1' then
--   preamble(5) <= '1';
-- elsif preamble(0) = '1' and preamble(1) = '1' and preamble(2) = '1' and preamble(3) = '1' then
--   preamble(4) <= '1';
-- elsif preamble(0) = '1' and preamble(1) = '1' and preamble(2) = '1' then
--   preamble(3) <= '1';
-- elsif preamble(0) = '1' and preamble(1) = '1' then
--   preamble(2) <= '1';
-- elsif preamble(0) = '1' then
--   preamble(1) <= '1';
-- end if;

-- end if;

-- case counter is
--   when 0 => tempsrc(47 downto 40) <= data_in;
--   when 1 => tempsrc(39 downto 32) <= data_in;
--   when 2 => tempsrc(31 downto 24) <= data_in;
--   when 3 => tempsrc(23 downto 16) <= data_in;
--   when 4 => tempsrc(15 downto 8) <= data_in;
--   when 5 => srcMac(47 downto 8) <= tempsrc(47 downto 8);
--               srcMac(7 downto 0) <= data_in;
--   when 6 => tempdst(47 downto 40) <= data_in;
--   when 7 => tempdst(39 downto 32) <= data_in;
--   when 8 => tempdst(31 downto 24) <= data_in;
--   when 9 => tempdst(23 downto 16) <= data_in;
--   when 10 => tempdst(15 downto 8) <= data_in;
--   when 11 => dstMac(47 downto 8) <= tempdst(47 downto 8);
--                 dstMac(7 downto 0) <= data_in;
--   when others =>
--     null;
-- end case;