library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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
        
    dst_mac : out std_logic_vector (47 downto 0);
    src_mac : out std_logic_vector (47 downto 0);

    data_out1 : out std_logic_vector (7 downto 0);
    data_out2 : out std_logic_vector (7 downto 0);
    data_out3 : out std_logic_vector (7 downto 0);
    data_out4 : out std_logic_vector (7 downto 0)
        
    );
end entity;

architecture controlUnit_arch of controlUnit is
    signal inc_port : std_logic_vector(2 downto 0);
    signal fcs_error : std_logic;
    signal src_mac_addr : std_logic_vector (47 downto 0);
    signal dst_mac_addr : std_logic_vector (47 downto 0);
    signal mac_inc_temp : std_logic;
    signal port_sel_temp : std_logic_vector (3 downto 0);

  component inputport is
    port (
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

  

begin
    
    Mac : mac_learner
    port map (
      clk  => clk,
      reset => reset,
      sMAC => src_mac_addr,
      dMAC => dst_mac_addr,
      portnum => inc_port,
      MAC_inc => mac_inc_temp, -- a mac address is coming
      sel => port_sel_temp
    );
    
    input_ports1 : inputport
    port map (
        clk  => clk,  
        reset  => reset,
        data_in => inport1,
        valid => valid1,
    
        srcMac => src_mac_addr,
        dstMac => dst_mac_addr,
        FCS_error => fcs_error,
        data_out => data_out1
    );
    
    input_ports2 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport2,
      valid => valid2,
  
      srcMac => src_mac_addr,
      dstMac => dst_mac_addr,
      FCS_error => fcs_error,
      data_out => data_out2
    );
    
    input_ports3 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport3,
      valid => valid3,
  
      srcMac => src_mac_addr,
      dstMac => dst_mac_addr,
      FCS_error => fcs_error,
      data_out => data_out3
    
    );
        
    input_ports4 : inputport
    port map (
      clk  => clk,  
      reset  => reset,
      data_in => inport4,
      valid => valid4,
  
      srcMac => src_mac_addr,
      dstMac => dst_mac_addr,
      FCS_error => fcs_error,
      data_out => data_out4

    );

    
    

end architecture;