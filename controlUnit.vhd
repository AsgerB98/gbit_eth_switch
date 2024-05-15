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
    inport3 : in std_logic_vector (7 downto 0);
    inport4 : in std_logic_vector (7 downto 0);

    valid1  : in std_logic;
    valid2  : in std_logic;
    valid3  : in std_logic;
    valid4  : in std_logic;

    port_sel : in std_logic_vector (3 downto 0);
    inc_port : out std_logic_vector(2 downto 0);
    send_mac : out std_logic;

    port_sel_out1 : out std_logic_vector (3 downto 0);
    port_sel_out2 : out std_logic_vector (3 downto 0);
    port_sel_out3 : out std_logic_vector (3 downto 0);
    port_sel_out4 : out std_logic_vector (3 downto 0);
        
    src_mac : out std_logic_vector (47 downto 0);
    dst_mac : out std_logic_vector (47 downto 0);

    data_out1 : out std_logic_vector (7 downto 0);
    data_out2 : out std_logic_vector (7 downto 0);
    data_out3 : out std_logic_vector (7 downto 0);
    data_out4 : out std_logic_vector (7 downto 0);

    done_send1 : out std_logic;
    done_send2 : out std_logic;
    done_send3 : out std_logic;
    done_send4 : out std_logic
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

  signal dst_mac_next, src_mac_next : std_logic_vector (47 downto 0) := (others => '0');
  signal dst_mac_read, src_mac_read : std_logic_vector (47 downto 0) := (others => '0');

  signal inc_port_next, inc_port_read : std_logic_vector (2 downto 0) := (others => '0');
  signal send_mac_next, send_mac_read : std_logic := '0';
  
  signal FCS_error_CU1, FCS_error_CU2, FCS_error_CU3, FCS_error_CU4 : std_logic;

  signal src_mac_addr1, src_mac_addr2, src_mac_addr3, src_mac_addr4: std_logic_vector (47 downto 0);
  signal dst_mac_addr1, dst_mac_addr2, dst_mac_addr3, dst_mac_addr4: std_logic_vector (47 downto 0);

  signal size_of_packet1, size_of_packet2, size_of_packet3, size_of_packet4 : integer;
  signal sending_packet1, sending_packet2, sending_packet3, sending_packet4 : integer range 0 to 2000 := 0;

  signal send_pkt1, send_pkt2, send_pkt3, send_pkt4 : std_logic := '0';
  signal send_pkt1_next, send_pkt2_next, send_pkt3_next, send_pkt4_next : std_logic := '0';
  
  signal send1, send2, send3, send4 : std_logic := '0';

  type State_type is (idle, port1, port2, port3, port4, wait_answer);
  signal current_state, next_state : State_type;
  
  signal round_robin, round_robin_next : integer := 1;

  signal data_out_CU_fcs1, data_out_CU_fcs2, data_out_CU_fcs3, data_out_CU_fcs4 : std_logic_vector(7 downto 0) := (others => '0');

  signal delayclock1, delayclock2, delayclock3, delayclock4 : integer range 0 to 3 := 0;
  signal checkedp1, checkedp2, checkedp3, checkedp4 : std_logic := '0';
  signal checkedp1_next, checkedp2_next, checkedp3_next, checkedp4_next : std_logic := '0';

  -- signal holdsel1, holdsel2, holdsel3, holdsel4 : std_logic_vector (3 downto 0);
  signal delaydone1, delaydone2, delaydone3, delaydone4 : std_logic := '0';
  signal rddone1, rddone2, rddone3, rddone4 : std_logic;
  signal keepsel1, keepsel2, keepsel3, keepsel4 : std_logic_vector (3 downto 0);
  signal keepsel1_next, keepsel2_next, keepsel3_next, keepsel4_next : std_logic_vector (3 downto 0);  
  
begin
  dst_mac <= dst_mac_next;
  src_mac <= src_mac_next;
  inc_port <= inc_port_next;
  send_mac <= send_mac_next;
  data_out1 <= data_out_CU_fcs1;
  data_out2 <= data_out_CU_fcs2;
  data_out3 <= data_out_CU_fcs3;
  data_out4 <= data_out_CU_fcs4;

  STATE_MEMORY_LOGIC : process (clk, reset)
  begin
    if reset = '1' then
      current_state <= idle;
    elsif rising_edge(clk) then
      current_state <= next_state;
      round_robin <= round_robin_next;
      dst_mac_read <= dst_mac_next;
      src_mac_read <= src_mac_next;
      inc_port_read <= inc_port_next;
      send_mac_read <= send_mac_next;
      checkedp1 <= checkedp1_next;
      checkedp2 <= checkedp2_next;
      checkedp3 <= checkedp3_next;
      checkedp4 <= checkedp4_next;
      keepsel1 <= keepsel1_next;
      keepsel2 <= keepsel2_next;
      keepsel3 <= keepsel3_next;
      keepsel4 <= keepsel4_next;

      if send_pkt1_next = '1' then
        send1 <= '1';
        port_sel_out1 <= keepsel1;
        delayclock1 <= delayclock1 + 1; -- Start delay and increment delay clock
      end if;
      if delayclock1 > 0 and delayclock1 < 3 then
        delayclock1 <= delayclock1 + 1; -- Increment delay clock if within the delay period
      end if;

        if delayclock1 = 3 then
          --port_sel_out1 <= keepsel1;
          sending_packet1 <= sending_packet1 +1;
          if sending_packet1 = size_of_packet1 -3 then -- End of pkt
            send_pkt1 <= '0';
            sending_packet1 <= 0;
            delayclock1 <= 0;
            send1 <= '0';
            delaydone1 <= '1';
          end if;
        end if;


      if delaydone1 = '1' then
          rddone1 <= '1';
          done_send1 <= '1';
          delaydone1 <= '0';
          port_sel_out1 <= "0000";
      end if;
      if rddone1 = '1' then
        done_send1 <= '0';
        rddone1 <= '0';
      end if;

      if send_pkt2_next = '1' then
        send2 <= '1';
        port_sel_out2 <= keepsel2;
        delayclock2 <= delayclock2 + 1; -- Start delay and increment delay clock
      end if;
      if delayclock2 > 0 and delayclock2 < 3 then
        delayclock2 <= delayclock2 + 1; -- Increment delay clock if within the delay period
      end if;

        if  delayclock2 = 3 then
          --port_sel_out2 <= keepsel2;
          sending_packet2 <= sending_packet2 +1;
          if sending_packet2 = size_of_packet2 -3 then
            send_pkt2 <= '0';
            sending_packet2 <= 0;
            delayclock2 <= 0;
            send2 <= '0';
            delaydone2 <= '1';
          end if;
        end if;

      if delaydone2 = '1' then
          rddone2 <= '1';
          done_send2 <= '1';
          delaydone2 <= '0';
          port_sel_out2 <= "0000";
      end if;
      if rddone2 = '1' then
        done_send2 <= '0';
        rddone2 <= '0';
      end if;

      if send_pkt3_next = '1' then
        send3 <= '1';
        port_sel_out3 <= keepsel3;
        delayclock3 <= delayclock3 + 1; -- Start delay and increment delay clock
      end if;
      if delayclock3 > 0 and delayclock3 < 3 then
        delayclock3 <= delayclock3 + 1; -- Increment delay clock if within the delay period
      end if;


        if delayclock3 = 3 then
          --port_sel_out3 <= keepsel3;
          sending_packet3 <= sending_packet3 +1;
          if sending_packet3 = size_of_packet3 -3 then
            send_pkt3 <= '0';
            sending_packet3 <= 0;
            delayclock3 <= 0;
            send3 <= '0';
            delaydone3 <= '1';
          end if;
        end if;


      if delaydone3 ='1' then
          rddone3 <= '1';
          done_send3 <= '1';
          delaydone3 <= '0';
          port_sel_out3 <= "0000";
      end if;
      if rddone3 = '1' then
        done_send3 <= '0';
        rddone3 <= '0';
      end if;

      if send_pkt4_next = '1' then
        send4 <= '1';
        port_sel_out4 <= keepsel4;

        delayclock4 <= delayclock4 + 1; -- Start delay and increment delay clock
      end if;
      if delayclock4 > 0 and delayclock4 < 3 then
        delayclock4 <= delayclock4 + 1; -- Increment delay clock if within the delay period
      end if;

        if  delayclock4 = 3 then
          --data_out4 <= data_out_CU_fcs4;
          --port_sel_out4 <= keepsel4;
          sending_packet4 <= sending_packet4 +1;
          if sending_packet4 = size_of_packet4 -3 then
            send_pkt4 <= '0';
            sending_packet4 <= 0;
            delayclock4 <= 0;
            send4 <= '0';
            delaydone4 <= '1';
          end if;
        end if;

      if delaydone4 = '1' then
          rddone4 <= '1';
          done_send4 <= '1';
          delaydone4 <= '0';
          port_sel_out4 <= "0000";
      end if;
        if rddone4 = '1' then
          done_send4 <= '0';
          rddone4 <= '0';
        end if;

    end if;
  end process;
  

  NEXT_STATE_LOGIC : process (current_state, FCS_error_CU1, FCS_error_CU2, FCS_error_CU3, FCS_error_CU4, port_sel, round_robin_next,
    valid1, valid2, valid3, valid4,checkedp1_next, checkedp2_next, checkedp3_next, checkedp4_next)
  begin
    next_state <= current_state;

    case current_state is
      when idle => next_state <= port1;

        when port1 =>
        if FCS_error_CU1 = '0' and checkedp1_next = '0' then
          next_state <= wait_answer;
        else
          next_state <= port2;
        end if;
          
        when port2 =>
        if FCS_error_CU2 = '0' and checkedp2_next = '0'then
          next_state <= wait_answer;
        else
          next_state <= port3;
        end if;

        when port3 =>
        if FCS_error_CU3 = '0' and checkedp3_next = '0' then
          next_state <= wait_answer;
        else
          next_state <= port4;
        end if;

        when port4 =>
        if FCS_error_CU4 = '0' and checkedp4_next = '0' then
          next_state <= wait_answer;
        else
          next_state <= port1;
        end if;

        when wait_answer =>
        if port_sel /= "0000" then
          case round_robin_next is
            when 1 => next_state <= port2;
            when 2 => next_state <= port3;
            when 3 => next_state <= port4;
            when 4 => next_state <= port1;
            when others =>
              null;
          end case;
        end if;
    
      when others =>
        null;
    end case;
  end process;
  
  OUTPUT_LOGIC : process (current_state, round_robin, FCS_error_CU1, FCS_error_CU2, FCS_error_CU3, FCS_error_CU4, checkedp1, checkedp2, checkedp3, checkedp4, valid1, valid2, valid3, valid4, port_sel,
    send_pkt1, send_pkt2, send_pkt3, send_pkt4, dst_mac_addr1, src_mac_addr1, dst_mac_addr2, src_mac_addr2, dst_mac_addr3, src_mac_addr3, dst_mac_addr4, src_mac_addr4, dst_mac_read, src_mac_read,
    send_mac_read, inc_port_read, keepsel1, keepsel2, keepsel3, keepsel4)
  begin
    round_robin_next <= round_robin;
    send_pkt1_next <= send_pkt1;
    send_pkt2_next <= send_pkt2;
    send_pkt3_next <= send_pkt3;
    send_pkt4_next <= send_pkt4;

    src_mac_next <= src_mac_read;
    dst_mac_next <= dst_mac_read;
    send_mac_next <= send_mac_read;
    inc_port_next <= inc_port_read;
    checkedp1_next <= checkedp1;
    checkedp2_next <= checkedp2;
    checkedp3_next <= checkedp3;
    checkedp4_next <= checkedp4;
    keepsel1_next <= keepsel1;
    keepsel2_next <= keepsel2;
    keepsel3_next <= keepsel3;
    keepsel4_next <= keepsel4;
    
    case current_state is
      when idle =>
        --port_sel <= "0000";
      when port1 =>
        dst_mac_next <= dst_mac_addr1;
        src_mac_next <= src_mac_addr1;

        inc_port_next <= "001";
        if FCS_error_CU1 = '0' and checkedp1 = '0' then
          send_mac_next <= '1';
        end if;
        round_robin_next <= 1;
        if FCS_error_CU1 = '1' then
          checkedp1_next <= '0';
        end if;

      when port2 =>
        dst_mac_next <= dst_mac_addr2;
        src_mac_next <= src_mac_addr2;
        
        inc_port_next <= "010";
        if FCS_error_CU2 = '0' and checkedp2 = '0' then
          send_mac_next <= '1';
        end if;  
        round_robin_next <= 2;

        if FCS_error_CU2 = '1' then
          checkedp2_next <= '0';
        end if;

      when port3 =>
        dst_mac_next <= dst_mac_addr3;
        src_mac_next <= src_mac_addr3;
        
        inc_port_next <= "011";
        if FCS_error_CU3 = '0' and checkedp3 = '0' then
          send_mac_next <= '1';
        end if;  
        round_robin_next <= 3;

        if FCS_error_CU3 = '1' then
          checkedp3_next <= '0';
        end if;

      when port4 =>
        dst_mac_next <= dst_mac_addr4;
        src_mac_next <= src_mac_addr4;
        
        inc_port_next <= "100";
        if FCS_error_CU4 = '0' and checkedp4 = '0' then
          send_mac_next <= '1';
        end if;  
        round_robin_next <= 4;
        
        if FCS_error_CU4 = '1' then
          checkedp4_next <= '0';
        end if;

      when wait_answer =>
      send_mac_next <= '0';
      if port_sel /= "0000" then
        case round_robin is
          when 1 =>
            send_pkt1_next <= '1';
            keepsel1_next <= port_sel;
            checkedp1_next <= '1';
          when 2 =>
            send_pkt2_next <= '1';
            keepsel2_next <= port_sel;
            checkedp2_next <= '1';
          when 3 =>
            send_pkt3_next <= '1';
            keepsel3_next <= port_sel;
            checkedp3_next <= '1';
          when 4 =>
            send_pkt4_next <= '1';
            keepsel4_next <= port_sel;
            checkedp4_next <= '1';
          when others => null;
        end case;
      end if;

      when others =>
        null;
    end case;
  end process;
    
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
    
    input_port3 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport3,
      valid => valid3,
      send_data => send3,
  
      srcMac => src_mac_addr3,
      dstMac => dst_mac_addr3,
      packet_size => size_of_packet3,
      fcs_error_IP => FCS_error_CU3,
      data_out => data_out_CU_fcs3
    );
        
    input_port4 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport4,
      valid => valid4,
      send_data => send4,
  
      srcMac => src_mac_addr4,
      dstMac => dst_mac_addr4,
      packet_size => size_of_packet4,
      fcs_error_IP => FCS_error_CU4,
      data_out => data_out_CU_fcs4
    );     
    
end architecture;
