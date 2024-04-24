library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;



entity schedulerCB is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    sendfifo1 : in std_logic;
    sendfifo2 : in std_logic;
    sendfifo3 : in std_logic;

    outfifo1  : out std_logic;
    outfifo2  : out std_logic;
    outfifo3  : out std_logic
  );
end entity;

  architecture schedulerCB_arch of schedulerCB is
    
    type State_type is (idle, port1, port2, port3);
    signal current_state, next_state : State_type;
  
  begin
  
    STATE_MEMORY_LOGIC : process (clk, reset, sendfifo1, sendfifo2, sendfifo3)
    begin
      if reset = '1' then
        current_state <= idle;
      elsif rising_edge(clk) then
        current_state <= next_state;
      end if;
    end process;

    NEXT_STATE_LOGIC : process (current_state)
    begin
      next_state <= current_state;

      case current_state is
        when idle => next_state <= port1;

        when port1 =>
          if sendfifo1 = '1' then
            next_state <= port2;
          end if;

        when port2 =>
          if sendfifo2 = '1' then
            next_state <= port3;
          end if;
          
        when port3 =>
        if sendfifo3 = '1' then
            next_state <= port1;
        end if;
    

        when others =>
          null;
      end case;
    end process;

    OUTPUT_LOGIC : process (current_state)
    begin
      case current_state is
        when port1 =>
          outfifo1 <= '1';
          outfifo2 <= '0';
          outfifo3 <= '0';

        when port2 =>
          outfifo1 <= '0';
          outfifo2 <= '1';
          outfifo3 <= '0';
        
        when port3 =>
          outfifo1 <= '0';
          outfifo2 <= '0';
          outfifo3 <= '1';

        when others => null;
      end case;
    end process;
  
  end architecture;