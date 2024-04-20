library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


entity controlUnit is
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

    port_sel : in std_logic_vector (3 downto 0); --??

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
end entity;

architecture controlUnit_arch of controlUnit is
  component inputport is
    port (
      clk     : in std_logic;
      reset   : in std_logic;
      data_in : in std_logic_vector (7 downto 0);
      valid   : in std_logic;
      send_data : in std_logic;

      srcMac : out std_logic_vector(47 downto 0);
      dstMac : out std_logic_vector(47 downto 0);
      FCS_error_IP : out std_logic;
      packet_size  : out integer;
      data_out: out std_logic_vector (7 downto 0)    
    );
  end component;

  component mac_learner is
    port (
      clk     : in std_logic;
      reset   : in std_logic;
      sMAC    : in std_logic_vector (47 downto 0);
      dMAC    : in std_logic_vector (47 downto 0);
      portnum : in std_logic_vector (2 downto 0);
      MAC_inc : in std_logic; -- a mac address is coming

      sel     : out std_logic_vector (3 downto 0)
            
    );
  end component;

  signal inc_port : std_logic_vector(2 downto 0);
  signal FCS_error_CU1, FCS_error_CU2, FCS_error_CU3, FCS_error_CU4 : std_logic;

  signal src_mac_addr : std_logic_vector (47 downto 0);
  signal dst_mac_addr : std_logic_vector (47 downto 0);
  
  signal src_mac_addr1, src_mac_addr2, src_mac_addr3, src_mac_addr4: std_logic_vector (47 downto 0);

  signal dst_mac_addr1, dst_mac_addr2, dst_mac_addr3, dst_mac_addr4: std_logic_vector (47 downto 0);

  signal mac_inc_temp : std_logic;
  signal port_sel_temp : std_logic_vector (3 downto 0) := (others => '0');
  signal size_of_packet1, size_of_packet2, size_of_packet3, size_of_packet4 : integer;
  signal sending_packet1, sending_packet2, sending_packet3, sending_packet4 : integer := 0;

  signal send_pkt1, send_pkt2, send_pkt3, send_pkt4 : std_logic := '0';
  signal send_pkt1_next, send_pkt2_next, send_pkt3_next, send_pkt4_next : std_logic := '0';
  
  signal send1, send2, send3, send4 : std_logic := '0';

  type State_type is (idle, port1, port2, port3, port4, wait_answer);
  signal current_state, next_state : State_type;
  
  --signal round_robin : std_logic_vector(1 downto 0) := (others => '0');
  signal round_robin, round_robin_next : integer := 1;

  signal data_out_CU_fcs1, data_out_CU_fcs2 : std_logic_vector(7 downto 0) := (others => '0');

  signal prog_start1, prog_start2, prog_start3, prog_start4 : std_logic := '0';
  signal delayclock1, delayclock2, delayclock3, delayclock4 : integer := 0;
  
begin
  STATE_MEMORY_LOGIC : process (clk, reset)
  begin
    if reset = '1' then
      current_state <= idle;
    elsif rising_edge(clk) then
      current_state <= next_state;
      round_robin <= round_robin_next;
      if valid1 = '1' then
        prog_start1 <= '1';
      end if;
      if valid2 = '1' then
        prog_start2 <= '1';
      end if;

      if send_pkt1_next = '1' then
        send1 <= '1';
        delayclock1 <= delayclock1 +1;
      end if;
      if delayclock1 > 0 then
        if delayclock1 = 2 then
          delayclock1 <= 2;
        else
          delayclock1 <= delayclock1 +1;
        end if;
      end if;

      if send1 = '1' or send_pkt1_next = '1' then
        if sending_packet1 <= size_of_packet1 and delayclock1 = 2 then
            data_out1 <= data_out_CU_fcs1;
            sending_packet1 <= sending_packet1 +1;
          if sending_packet1 = size_of_packet1 -1 then
            send_pkt1 <= '0';
            sending_packet1 <= 0;
            send1 <= '0';
            delayclock1 <= 0;
          end if;
        end if;
      end if;

      if send_pkt2_next = '1' then
        send2 <= '1';
        delayclock2 <= delayclock2 +1;
      end if;
      if delayclock2 > 0 then
        if delayclock2 = 2 then
          delayclock2 <= 2;
        else
          delayclock2 <= delayclock2 +1;
        end if;
      end if;

      if send2 = '1' or send_pkt2_next = '1' then
          if sending_packet2 <= size_of_packet2 and delayclock2 =2 then
              data_out2 <= data_out_CU_fcs2;
              sending_packet2 <= sending_packet2 +1;
            if sending_packet2 = size_of_packet2 -1 then
              send_pkt2 <= '0';
              sending_packet2 <= 0;
              send2 <= '0';
              delayclock2 <= 0;
            end if;
          end if;
      end if;


    end if;
  end process;

  NEXT_STATE_LOGIC : process (current_state, FCS_error_CU1, FCS_error_CU2, port_sel_temp, round_robin_next, valid1, prog_start1, prog_start2)
  begin
    next_state <= current_state;

    case current_state is
      when idle => next_state <= port1;

        when port1 =>
        if valid1 = '0' and prog_start1 = '1' and FCS_error_CU1 = '0' then
          next_state <= wait_answer;
        else
          next_state <= port2;
        end if;
          
        when port2 =>
        if valid2 = '0' and prog_start2 = '1' and FCS_error_CU2 = '0' then
          next_state <= wait_answer;
          -- round_robin_next <= 3;
        else
          next_state <= port3;
        end if;

        when wait_answer =>
        if port_sel_temp /= "0000" then
          if round_robin_next = 1 then
            next_state <= port2;
          elsif round_robin_next = 2 then
            next_state <= port1;
          elsif round_robin_next = 3 then
            next_state <= port4;
          elsif round_robin_next = 4 then
            next_state <= port1;
          end if;
          
        end if;

    
      when others =>
        null;
    end case;
  end process;
  
  OUTPUT_LOGIC : process (current_state, round_robin, mac_inc_temp, FCS_error_CU1, port_sel_temp)
  begin
    round_robin_next <= round_robin;
    send_pkt1_next <= send_pkt1;
    send_pkt2_next <= send_pkt2;
    
    case current_state is
      when idle =>
        --port_sel_temp <= "0000";

      when port1 =>
      dst_mac <= dst_mac_addr1;
      src_mac <= src_mac_addr1;

      dst_mac_addr <= dst_mac_addr1;
      src_mac_addr <= src_mac_addr1;

      inc_port <= "001";
      if FCS_error_CU1 = '0' then
        mac_inc_temp <= '1';
      end if;

      round_robin_next <= 1;

      when wait_answer =>
        if round_robin = 2 and port_sel_temp /= "0000" then
          send_pkt2_next <= '1';
          port_sel_out1 <= port_sel_temp;
        end if;
        if round_robin = 1 and port_sel_temp /= "0000" then
          send_pkt1_next <= '1';
        end if;
        mac_inc_temp <= '0';

      when port2 =>
        --port_sel_out <= port_sel_temp;
        dst_mac <= dst_mac_addr2;
        src_mac <= src_mac_addr2;
  
        dst_mac_addr <= dst_mac_addr2;
        src_mac_addr <= src_mac_addr2;
  
        inc_port <= "010";
        if FCS_error_CU2 = '0' then
          mac_inc_temp <= '1';
        end if;  
        round_robin_next <= 2;
    
      when others =>
        null;
    end case;

  end process;

  MAC : mac_learner
    port map (
      clk  => clk,
      reset => reset,
      sMAC => src_mac_addr,
      dMAC => dst_mac_addr,
      portnum => inc_port,
      MAC_inc => mac_inc_temp, -- a mac address is coming
      sel => port_sel_temp
    );
    
  input_port1 : inputport
    port map (
        clk  => clk,  
        reset  => reset,
        data_in => inport1,
        valid => valid1,
        send_data => send1,
    
        srcMac => src_mac_addr1,
        dstMac => dst_mac_addr1,
        fcs_error_IP => FCS_error_CU1,
        packet_size => size_of_packet1,
        data_out => data_out_CU_fcs1
    );
    
    input_port2 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport2,
      valid => valid2,
      send_data => send2,
  
      srcMac => src_mac_addr2,
      dstMac => dst_mac_addr2,
      packet_size => size_of_packet2,
      fcs_error_IP => FCS_error_CU2,
      data_out => data_out_CU_fcs2
    );
    
    -- input_port3 : inputport
    -- port map (
    --   clk  => clk,  
    --   reset  => reset,
    --   data_in => inport3,
    --   valid => valid3,
  
    --   srcMac => src_mac_addr3,
    --   dstMac => dst_mac_addr3,
    --   packet_size => size_of_packet3,
    --   fcs_error_IP => FCS_error_CU,
    --   data_out => data_out3
    
    -- );
        
    -- input_port4 : inputport
    -- port map (
    --   clk  => clk,  
    --   reset  => reset,
    --   data_in => inport4,
    --   valid => valid4,
  
    --   srcMac => src_mac_addr4,
    --   dstMac => dst_mac_addr4,
    --   packet_size => size_of_packet4,
    --   fcs_error_IP => FCS_error_CU,
    --   data_out => data_out4

    -- );

    
    

end architecture;