library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


entity full_crossbar is
  port (
    clk   : in std_logic;
    reset : in std_logic;
    
    inport1 : in std_logic_vector (7 downto 0);
    inport2 : in std_logic_vector (7 downto 0);
    inport3 : in std_logic_vector (7 downto 0);
    inport4 : in std_logic_vector (7 downto 0);

    port_sel_in1 : in std_logic_vector (3 downto 0);
    port_sel_in2 : in std_logic_vector (3 downto 0);
    port_sel_in3 : in std_logic_vector (3 downto 0);
    port_sel_in4 : in std_logic_vector (3 downto 0);

    data_out1 : out std_logic_vector (7 downto 0);
    data_out2 : out std_logic_vector (7 downto 0);
    data_out3 : out std_logic_vector (7 downto 0);
    data_out4 : out std_logic_vector (7 downto 0)
       
  );
end entity;


architecture full_crossbar_arch of full_crossbar is
  component controlUnit is
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
  
      port_sel_out1 : out std_logic_vector (3 downto 0); --??
      port_sel_out2 : out std_logic_vector (3 downto 0); --??
      port_sel_out3 : out std_logic_vector (3 downto 0); --??
      port_sel_out4 : out std_logic_vector (3 downto 0); --??
          
      dst_mac : out std_logic_vector (47 downto 0);
      src_mac : out std_logic_vector (47 downto 0);
  
      data_out1 : out std_logic_vector (7 downto 0);
      data_out2 : out std_logic_vector (7 downto 0);
      data_out3 : out std_logic_vector (7 downto 0);
      data_out4 : out std_logic_vector (7 downto 0)
          
      );
  end component;
begin

  control_unitCU : controlUnit
    port map (
      
    );


end architecture;


