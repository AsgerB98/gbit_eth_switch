library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use IEEE.std_logic_textio.all;


entity ram is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        
        address : in std_logic_vector(8 downto 0);
        data_in : in std_logic_vector(50 downto 0);
        RW      : in std_logic;
        
        sel_out : out std_logic_vector(2 downto 0);
        memory  : out std_logic_vector(47 downto 0)

    );
end entity;


architecture ram_arch of ram is
    type WE_type is array (0 to 8191) of std_logic_vector(50 downto 0); --occupied and key  
    signal WE : WE_type := (others => (others => '0'));

begin
 
    ram_func : process (clk, reset)
  
    begin 
      if reset = '1' then
        --WE <= (others => (others => '0')); --flush
      elsif rising_edge(clk) then
        if RW = '1' then
          WE(to_integer(unsigned(address))) <= data_in;
        else
          sel_out <= WE(to_integer(unsigned(address)))(2 downto 0);
          memory <= WE(to_integer(unsigned(address)))(50 downto 3);
        end if;
      end if;
    end process;
    
  end architecture; -- SRAM_arch

  