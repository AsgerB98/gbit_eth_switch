library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


entity switch_core is
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
end entity switch_core;

architecture switch_core_arch of switch_core is
    
  component ControlUnit is
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
  
      port_sel : in std_logic_vector (3 downto 0); --??
      inc_port : out std_logic_vector(2 downto 0);
  
      port_sel_out1 : out std_logic_vector (3 downto 0); --??
      port_sel_out2 : out std_logic_vector (3 downto 0); --??
      port_sel_out3 : out std_logic_vector (3 downto 0); --??
      port_sel_out4 : out std_logic_vector (3 downto 0); --??
          
      dst_mac : out std_logic_vector (47 downto 0);
      src_mac : out std_logic_vector (47 downto 0);
      send_mac : out std_logic;
  
      data_out1 : out std_logic_vector (7 downto 0);
      data_out2 : out std_logic_vector (7 downto 0);
      data_out3 : out std_logic_vector (7 downto 0);
      data_out4 : out std_logic_vector (7 downto 0);

      done_send1 : out std_logic;
      done_send2 : out std_logic;
      done_send3 : out std_logic;
      done_send4 : out std_logic
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

  
  signal sel_from_ML : std_logic_vector (3 downto 0);
  signal port_sel_CUCB1 : std_logic_vector (3 downto 0);
  signal port_sel_CUCB2 : std_logic_vector (3 downto 0);
  signal port_sel_CUCB3 : std_logic_vector (3 downto 0);
  signal port_sel_CUCB4 : std_logic_vector (3 downto 0);
  
  signal dst_mac_ML : std_logic_vector (47 downto 0);
  signal src_mac_ML : std_logic_vector (47 downto 0);
  
  signal data_out1_CUCB : std_logic_vector (7 downto 0);
  signal data_out2_CUCB : std_logic_vector (7 downto 0);
  signal data_out3_CUCB : std_logic_vector (7 downto 0);
  signal data_out4_CUCB : std_logic_vector (7 downto 0);

  signal done_send_wire1, done_send_wire2, done_send_wire3, done_send_wire4 : std_logic;
  
  
  signal fromport : std_logic_vector (2 downto 0);
  signal MAC_inc_toML : std_logic;  

begin


  controlUnitCU : controlUnit
    port map (
      clk   => clk,
      reset => reset,

      inport1 => inport1,
      inport2 => inport2,
      inport3 => inport3,
      inport4 => inport4,

      valid1 => valid1,
      valid2 => valid2,
      valid3 => valid3,
      valid4 => valid4,

      port_sel => sel_from_ML,
      inc_port => fromport,
      send_mac => MAC_inc_toML,

      port_sel_out1 => port_sel_CUCB1,
      port_sel_out2 => port_sel_CUCB2,
      port_sel_out3 => port_sel_CUCB3,
      port_sel_out4 => port_sel_CUCB4,

      src_mac => src_mac_ML,
      dst_mac => dst_mac_ML,

      data_out1 => data_out1_CUCB,
      data_out2 => data_out2_CUCB,
      data_out3 => data_out3_CUCB,
      data_out4 => data_out4_CUCB,

      done_send1 => done_send_wire1,
      done_send2 => done_send_wire2,
      done_send3 => done_send_wire3,
      done_send4 => done_send_wire4
    );

  mac_learnerML : mac_learner
    port map(
      clk   => clk,
      reset => reset,

      sMAC => src_mac_ML,
      dMAC => dst_mac_ML,
      portnum => fromport,
      MAC_inc => MAC_inc_toML, -- MAC INC SKAL FIXES
      sel => sel_from_ML
      );

  
  full_crossbarCB : full_crossbar
    port map(
      clk   => clk,
      reset => reset,

      inport1 => data_out1_CUCB,
      inport2 => data_out2_CUCB,
      inport3 => data_out3_CUCB,
      inport4 => data_out4_CUCB,

      done1 => done_send_wire1,
      done2 => done_send_wire2,
      done3 => done_send_wire3,
      done4 => done_send_wire4,

      port_sel_in1 => port_sel_CUCB1,
      port_sel_in2 => port_sel_CUCB2,
      port_sel_in3 => port_sel_CUCB3,
      port_sel_in4 => port_sel_CUCB4,

      data_out1 => outport1,
      data_out2 => outport2,
      data_out3 => outport3,
      data_out4 => outport4
    );



end architecture;