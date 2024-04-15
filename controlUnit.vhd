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
    --inport2 : in std_logic_vector (7 downto 0);
    -- inport3 : in std_logic_vector (7 downto 0);
    -- inport4 : in std_logic_vector (7 downto 0);

    valid1  : in std_logic;
    --valid2  : in std_logic;
    -- valid3  : in std_logic;
    -- valid4  : in std_logic;

    port_sel : in std_logic_vector (3 downto 0); --??
    port_sel_out : out std_logic_vector (3 downto 0); --??
        
    dst_mac : out std_logic_vector (47 downto 0);
    src_mac : out std_logic_vector (47 downto 0);

    data_out1 : out std_logic_vector (7 downto 0)
    --data_out2 : out std_logic_vector (7 downto 0)
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
  signal FCS_error_CU1 : std_logic;
  signal FCS_error_CU2 : std_logic;
  signal FCS_error_CU3 : std_logic;
  signal FCS_error_CU4 : std_logic;

  signal src_mac_addr : std_logic_vector (47 downto 0);
  signal dst_mac_addr : std_logic_vector (47 downto 0);
  
  signal src_mac_addr1 : std_logic_vector (47 downto 0);
  signal src_mac_addr2 : std_logic_vector (47 downto 0);
  signal src_mac_addr3 : std_logic_vector (47 downto 0);
  signal src_mac_addr4 : std_logic_vector (47 downto 0);

  signal dst_mac_addr1 : std_logic_vector (47 downto 0);
  signal dst_mac_addr2 : std_logic_vector (47 downto 0);
  signal dst_mac_addr3 : std_logic_vector (47 downto 0);
  signal dst_mac_addr4 : std_logic_vector (47 downto 0);

  signal mac_inc_temp : std_logic;
  signal port_sel_temp : std_logic_vector (3 downto 0) := (others => '0');
  signal size_of_packet : integer;
  signal legit_packet : std_logic := '0';
  signal sending_packet : integer := 0;
  
  
  

  type State_type is (idle, port1, port2, wait_answer);
  signal current_state, next_state : State_type;
  
  --signal round_robin : std_logic_vector(1 downto 0) := (others => '0');
  signal round_robin, round_robin_next : integer := 1;

  signal data_out_CU_fcs1 : std_logic_vector(7 downto 0) := (others => '0');
  signal wait_3_clock : integer := 0;
  
  
begin
--port_sel_temp <= port_sel;
  STATE_MEMORY_LOGIC : process (clk, reset)
  begin
    if reset = '1' then
      current_state <= idle;
    elsif rising_edge(clk) then
      current_state <= next_state;
      round_robin <= round_robin_next;
      --port_sel <= port_sel_temp;
      -- if legit_packet = '1' then
         if sending_packet <= size_of_packet and legit_packet = '1' then
           data_out1 <= data_out_CU_fcs1;
           sending_packet <= sending_packet +1;
           if sending_packet = size_of_packet then
            legit_packet <= '0';
            sending_packet <= 0;
           end if;
         end if;

         if FCS_error_CU1 = '0' then
          wait_3_clock <= wait_3_clock +1;
        end if;
        if wait_3_clock >= 1 then
          wait_3_clock <= wait_3_clock +1;
        end if;
        if wait_3_clock = 3 then
          legit_packet <= '1';
          wait_3_clock <= 0;
        end if;

      -- end if;
    end if;
  end process;

  NEXT_STATE_LOGIC : process (current_state, FCS_error_CU1, port_sel_temp, round_robin_next)
  begin
    next_state <= current_state;

    case current_state is
      when idle =>
      if FCS_error_CU1 = '0' then
        next_state <= port1;
      end if;

        when port1 =>
          next_state <= wait_answer;
          
        when wait_answer =>
        if port_sel_temp /= "0000" then
          if round_robin_next = 2 then
            next_state <= port2;
          end if;
          
        end if;
    
      when others =>
        null;
    end case;
  end process;
  
  OUTPUT_LOGIC : process (current_state, round_robin)
  begin
    round_robin_next <= round_robin;
    
    case current_state is
      when idle =>
        --port_sel_temp <= "0000";

      when port1 =>
      dst_mac <= dst_mac_addr1;
      src_mac <= src_mac_addr1;

      dst_mac_addr <= dst_mac_addr1;
      src_mac_addr <= src_mac_addr1;

      inc_port <= "001";
      mac_inc_temp <= '1';

      round_robin_next <= round_robin +1;

      when wait_answer =>
        mac_inc_temp <= '0';

      when port2 =>
        port_sel_out <= port_sel_temp;
    
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
    
        srcMac => src_mac_addr1,
        dstMac => dst_mac_addr1,
        fcs_error_IP => FCS_error_CU1,
        --data_out => data_out1
        packet_size => size_of_packet,
        data_out => data_out_CU_fcs1
    );
    
    -- input_port2 : inputport
    -- port map (
    --   clk  => clk,  
    --   reset  => reset,
    --   data_in => inport2,
    --   valid => valid2,
  
    --   srcMac => src_mac_addr2,
    --   dstMac => dst_mac_addr2,
    --   fcs_error_IP => FCS_error_CU2,
    --   data_out => data_out2
    -- );
    
    -- input_port3 : inputport
    -- port map (
    --   clk  => clk,  
    --   reset  => reset,
    --   data_in => inport3,
    --   valid => valid3,
  
    --   srcMac => src_mac_addr3,
    --   dstMac => dst_mac_addr3,
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
    --   fcs_error_IP => FCS_error_CU,
    --   data_out => data_out4

    -- );

    
    

end architecture;