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

    isempty1  : in std_logic;
    isempty2  : in std_logic;
    isempty3  : in std_logic;

    outfifo1  : out std_logic;
    outfifo2  : out std_logic;
    outfifo3  : out std_logic
  );
end entity;

  architecture schedulerCB_arch of schedulerCB is
    
    signal outfifo1_next, outfifo2_next, outfifo3_next : std_logic := '0';
    signal outfifo1_read, outfifo2_read, outfifo3_read : std_logic := '0';
    
    type State_type is (idle, port1, port2, port3, wait_pkt);
    signal current_state, next_state : State_type;
    signal delaydone1, delaydone2 : std_logic := '0';
    signal delayread1, delayread2, delayread3, delayread4 : std_logic;
    

  begin
    outfifo1 <= outfifo1_next;
    outfifo2 <= outfifo2_next;
    outfifo3 <= outfifo3_next;
  
    STATE_MEMORY_LOGIC : process (clk, reset, sendfifo1, sendfifo2, sendfifo3)
    begin
      if reset = '1' then
        current_state <= idle;
      elsif rising_edge(clk) then
        current_state <= next_state;
        
        outfifo1_read <= outfifo1_next;
        outfifo2_read <= outfifo2_next;
        outfifo3_read <= outfifo3_next;
        
      end if;
    end process;

    NEXT_STATE_LOGIC : process (current_state, delaydone1, delaydone2, isempty1, isempty2, isempty3, sendfifo1, sendfifo2, sendfifo3)
    begin
      next_state <= current_state;

      case current_state is
        when idle => next_state <= port1;
        -- if reset = '0' then
        -- next_state <= port1;
        -- end if;
        when port1 =>
          if isempty1 = '1' and isempty2 = '0' then
            next_state <= port2;
          elsif isempty1 = '1' and isempty3 = '0'  then
            next_state <= port3;
          elsif isempty1 = '1' and isempty2 = '1' and isempty3 = '1' then
            next_state <= wait_pkt;
          end if;

        when port2 =>
          if isempty2 = '1' and isempty1 = '0' then
            next_state <= port1;
          elsif isempty2 = '1' and isempty3 = '0'  then
            next_state <= port3;
          elsif isempty1 = '1' and isempty2 = '1' and isempty3 = '1' then
            next_state <= wait_pkt;
          end if;
          
        when port3 =>
          if isempty3 = '1' and isempty1 = '0' then
            next_state <= port1;
          elsif isempty3 = '1' and isempty2 = '0'  then
            next_state <= port2;
          elsif isempty1 = '1' and isempty2 = '1' and isempty3 = '1' then
            next_state <= wait_pkt;
          end if;

        when wait_pkt =>
          if sendfifo1 = '1' then
            next_state <= port1;
          elsif sendfifo2 = '1' then
            next_state <= port2;
          elsif sendfifo3 = '1' then
            next_state <= port3;
          end if;
    

        when others =>
          null;
      end case;
    end process;

    OUTPUT_LOGIC : process (current_state, outfifo1_read, outfifo2_read, outfifo3_read)
    begin
      outfifo1_next <= outfifo1_read;
      outfifo2_next <= outfifo2_read;
      outfifo3_next <= outfifo3_read;
      
      case current_state is
        when port1 =>
          outfifo1_next <= '1';
          outfifo2_next <= '0';
          outfifo3_next <= '0';

        when port2 =>
          outfifo1_next <= '0';
          outfifo2_next <= '1';
          outfifo3_next <= '0';
        
        when port3 =>
          outfifo1_next <= '0';
          outfifo2_next <= '0';
          outfifo3_next <= '1';
        
        when wait_pkt =>
          outfifo1_next <= '0';
          outfifo2_next <= '0';
          outfifo3_next <= '0';

        when others => null;
      end case;
    end process;
  
  end architecture;
