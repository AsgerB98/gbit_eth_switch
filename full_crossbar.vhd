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
end entity;


architecture full_crossbar_arch of full_crossbar is
  component fifoCB is
    port(
      clock		: IN STD_LOGIC ;
      data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdreq		: IN STD_LOGIC ;
      wrreq		: IN STD_LOGIC ;
      empty		: OUT STD_LOGIC ;
      full		: OUT STD_LOGIC ;
      q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      usedw		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
    );
    end component;
  
  component schedulerCB is
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
  end component;

  signal fullfifo : std_logic;

  signal read12 : std_logic;
  signal read13 : std_logic;
  signal read14 : std_logic;
  signal read21 : std_logic;
  signal read23 : std_logic;
  signal read24 : std_logic;
  signal read31 : std_logic;
  signal read32 : std_logic;
  signal read34 : std_logic;
  signal read41 : std_logic;
  signal read42 : std_logic;
  signal read43 : std_logic;
  
  
  
  signal full12 : std_logic;
  signal full13 : std_logic;
  signal full14 : std_logic;
  signal full21 : std_logic;
  signal full23 : std_logic;
  signal full24 : std_logic;
  signal full31 : std_logic;
  signal full32 : std_logic;
  signal full34 : std_logic;
  signal full41 : std_logic;
  signal full42 : std_logic;
  signal full43 : std_logic;
  
  signal usedw12 : std_logic_vector (12 downto 0);
  signal usedw13 : std_logic_vector (12 downto 0);
  signal usedw14 : std_logic_vector (12 downto 0);
  signal usedw21 : std_logic_vector (12 downto 0);
  signal usedw23 : std_logic_vector (12 downto 0);
  signal usedw24 : std_logic_vector (12 downto 0);
  signal usedw31 : std_logic_vector (12 downto 0);
  signal usedw32 : std_logic_vector (12 downto 0);
  signal usedw34 : std_logic_vector (12 downto 0);
  signal usedw41 : std_logic_vector (12 downto 0);
  signal usedw42 : std_logic_vector (12 downto 0);
  signal usedw43 : std_logic_vector (12 downto 0);
  
  signal empty12 : std_logic;
  signal empty13 : std_logic;
  signal empty14 : std_logic;
  signal empty21 : std_logic;
  signal empty23 : std_logic;
  signal empty24 : std_logic;
  signal empty31 : std_logic;
  signal empty32 : std_logic;
  signal empty34 : std_logic;
  signal empty41 : std_logic;
  signal empty42 : std_logic;
  signal empty43 : std_logic;
  
  type State_type is (idle, port1, port2, port3, port4, wait_answer);
  signal current_state, next_state : State_type;
  

begin

  scheduler1 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => empty12,
      sendfifo2 => empty13,
      sendfifo3 => empty14,
  
      outfifo1  => read12,
      outfifo2  => read13,
      outfifo3  => read14
    );


    scheduler2 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => empty21,
      sendfifo2 => empty23,
      sendfifo3 => empty24,
  
      outfifo1  => read21,
      outfifo2  => read23,
      outfifo3  => read24
    );
  
    scheduler3 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => empty31,
      sendfifo2 => empty32,
      sendfifo3 => empty34,
  
      outfifo1  => read31,
      outfifo2  => read32,
      outfifo3  => read34
    );

    scheduler4 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => empty41,
      sendfifo2 => empty42,
      sendfifo3 => empty43,
  
      outfifo1  => read41,
      outfifo2  => read42,
      outfifo3  => read43
    );

  fifo12 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read12,
      wrreq	 => done1,
      empty	 => empty12,
      full	 => full12,
      q	 => data_out2,
      usedw	 => usedw12
    );
  fifo13 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read13,
      wrreq	 => done1,
      empty	 => empty13,
      full	 => full13,
      q	 => data_out3,
      usedw	 => usedw13
    );
  fifo14 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read14,
      wrreq	 => done1,
      empty	 => empty14,
      full	 => full14,
      q	 => data_out4,
      usedw	 => usedw14 
    );

  fifo21 : fifoCB
    port map
     (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read21,
      wrreq	 => done2,
      empty	 => empty21,
      full	 => full21,
      q	 => data_out1,
      usedw	 => usedw21
    );

  fifo23 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read23,
      wrreq	 => done2,
      empty	 => empty23,
      full	 => full23,
      q	 => data_out3,
      usedw	 => usedw23
    );
  fifo24 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read24,
      wrreq	 => done2,
      empty	 => empty24,
      full	 => full24,
      q	 => data_out4,
      usedw	 => usedw24
    );

  fifo31 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read31,
      wrreq	 => done2,
      empty	 => empty31,
      full	 => full31,
      q	 => data_out1,
      usedw	 => usedw31
    );
  fifo32 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read32,
      wrreq	 => done3,
      empty	 => empty32,
      full	 => full32,
      q	 => data_out2,
      usedw	 => usedw32
    );
  fifo34 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read34,
      wrreq	 => done3,
      empty	 => empty34,
      full	 => full34,
      q	 => data_out4,
      usedw	 => usedw34
    );

  fifo41 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read41,
      wrreq	 => done4,
      empty	 => empty41,
      full	 => full41,
      q	 => data_out1,
      usedw	 => usedw41
    );
  fifo42 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read42,
      wrreq	 => done4,
      empty	 => empty42,
      full	 => full42,
      q	 => data_out2,
      usedw	 => usedw42
    );
  fifo43 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read43,
      wrreq	 => done4,
      empty	 => empty43,
      full	 => full43,
      q	 => data_out3,
      usedw	 => usedw43
    );


end architecture;


