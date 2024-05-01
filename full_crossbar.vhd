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

      isempty1  : in std_logic;
      isempty2  : in std_logic;
      isempty3  : in std_logic;
  
      outfifo1  : out std_logic;
      outfifo2  : out std_logic;
      outfifo3  : out std_logic
    );
  end component;

  signal data_out1_next, data_out2_next, data_out3_next, data_out4_next : std_logic_vector (7 downto 0) := (others => '0');
  signal data_out1_read, data_out2_read, data_out3_read, data_out4_read : std_logic_vector (7 downto 0) := (others => '0');
  
  
  signal fullfifo : std_logic;
  signal read12, read13, read14, read21, read23, read24, read31, read32, read34, read41, read42, read43 : std_logic := '0';
  signal full12, full13, full14, full21, full23, full24, full31, full32, full34, full41, full42, full43 : std_logic;
  
  signal usedw12, usedw13, usedw14 : std_logic_vector (12 downto 0);
  signal usedw21, usedw23, usedw24 : std_logic_vector (12 downto 0);
  signal usedw31, usedw32, usedw34 : std_logic_vector (12 downto 0);
  signal usedw41, usedw42, usedw43 : std_logic_vector (12 downto 0);

  signal empty12, empty13, empty14, empty21, empty23, empty24, empty31, empty32, empty34, empty41, empty42, empty43 : std_logic;
  signal write12, write13, write14, write21, write23, write24, write31, write32, write34, write41, write42, write43 : std_logic := '0';
  signal data_out12, data_out13, data_out14, data_out21, data_out23, data_out24, data_out31, data_out32, data_out34, data_out41, data_out42, data_out43 : std_logic_vector (7 downto 0) := (others => '0');
  signal holdsel1, holdsel2, holdsel3, holdsel4 : std_logic_vector (3 downto 0);
  signal holdsel1_next, holdsel2_next, holdsel3_next, holdsel4_next : std_logic_vector (3 downto 0);
  signal write12_next, write13_next, write14_next, write21_next, write23_next, write24_next, write31_next, write32_next, write34_next, write41_next, write42_next, write43_next : std_logic := '0';

begin

  data_out1 <= data_out1_next;
  data_out2 <= data_out2_next;
  data_out3 <= data_out3_next;
  data_out4 <= data_out4_next;
  
  process (clk, reset)
  begin
    if reset = '1' then

    elsif rising_edge(clk) then
      holdsel1 <= holdsel1_next;
      holdsel2 <= holdsel2_next;
      holdsel3 <= holdsel3_next;
      holdsel4 <= holdsel4_next;
      
      data_out1_read <= data_out1_next;
      data_out2_read <= data_out2_next;
      data_out3_read <= data_out3_next;
      data_out4_read <= data_out4_next;

      write12 <= write12_next;
      write13 <= write13_next;
      write14 <= write14_next;
      write21 <= write21_next;
      write23 <= write23_next;
      write24 <= write24_next;
      write31 <= write31_next;
      write32 <= write32_next;
      write34 <= write34_next;
      write41 <= write41_next;
      write42 <= write42_next;
      write43 <= write43_next;
      
      end if;


  end process;


  process (done1, done2, done3, done4, port_sel_in1, port_sel_in2, port_sel_in3, port_sel_in4, inport1, inport2, inport3, inport4, holdsel1, holdsel2, holdsel3, holdsel4,
    data_out1_read, data_out2_read, data_out3_read, data_out4_read, write12, write13, write14, write21, write23, write24, write31, write32, write34, write41, write42, write43 )
  begin
    holdsel1_next <= holdsel1;
    holdsel2_next <= holdsel2;
    holdsel3_next <= holdsel3;
    holdsel4_next <= holdsel4;

    write12_next <= write12;
    write13_next <= write13;
    write14_next <= write14;
    write21_next <= write21;
    write23_next <= write23;
    write24_next <= write24;
    write31_next <= write31;
    write32_next <= write32;
    write34_next <= write34;
    write41_next <= write41;
    write42_next <= write42;
    write43_next <= write43;

    if port_sel_in1 /= "0000" then
      holdsel1_next <= port_sel_in1;
    end if;

    if port_sel_in2 /= "0000" then
      holdsel2_next <= port_sel_in2;
    end if;
    
    if port_sel_in3 /= "0000" then
      holdsel3_next <= port_sel_in3;
    end if;
    
    if port_sel_in4 /= "0000" then
      holdsel4_next <= port_sel_in4;
    end if;
    

    if done1 = '1' then
      holdsel1_next <= "0000";
    end if;

    if done2 = '1' then
      holdsel2_next <= "0000";
    end if;

    if done3 = '1' then
      holdsel3_next <= "0000";
    end if;

    if done4 = '1' then
      holdsel4_next <= "0000";
    end if;
  

    case holdsel1 is
    when "0010" =>
        write12_next <= '1';
        write13_next <= '0';
        write14_next <= '0';

        if done1 = '1' then
          write12_next <= '0';
          write13_next <= '0';
          write14_next <= '0';
      end if;

    when "0011" =>
      write12_next <= '0';
      write13_next <= '1';
      write14_next <= '0';
      
      if done1 = '1' then
        write12_next <= '0';
        write13_next <= '0';
        write14_next <= '0';
    end if;

    when "0100" =>
      write12_next <= '0';
      write13_next <= '0';
      write14_next <= '1';

      if done1 = '1' then
        write12_next <= '0';
        write13_next <= '0';
        write14_next <= '0';
    end if;

    when "1111" =>
        write12_next <= '1';
        write13_next <= '1';
        write14_next <= '1';

        if done1 = '1' then
          write12_next <= '0';
          write13_next <= '0';
          write14_next <= '0';
      end if;
  
    when others =>
      null;
  end case;

  case holdsel2 is
    when "0001" =>
      write21_next <= '1';
      write23_next <= '0';
      write24_next <= '0';
      if done2 = '1' then
        write21_next <= '0';
        write23_next <= '0';
        write24_next <= '0';
    end if;

    when "0011" =>
      write21_next <= '0';
      write23_next <= '1';
      write24_next <= '0';
      if done2 = '1' then
        write21_next <= '0';
        write23_next <= '0';
        write24_next <= '0';
    end if;

    when "0100" =>
      write21_next <= '0';
      write23_next <= '0';
      write24_next <= '1';
      if done2 = '1' then
        write21_next <= '0';
        write23_next <= '0';
        write24_next <= '0';
    end if;

    when "1111" =>
        write21_next <= '1';
        write23_next <= '1';
        write24_next <= '1';

        if done2 = '1' then
          write21_next <= '0';
          write23_next <= '0';
          write24_next <= '0';
      end if;

    when others =>
      null;
  end case;

  case holdsel3 is
    when "0001" =>
      write31_next <= '1';
      write32_next <= '0';
      write34_next <= '0';
      if done3 = '1' then
        write31_next <= '0';
        write32_next <= '0';
        write34_next <= '0';
      end if;

    when "0010" =>
      write31_next <= '0';
      write32_next <= '1';
      write34_next <= '0';
      if done3 = '1' then
        write31_next <= '0';
        write32_next <= '0';
        write34_next <= '0';
      end if;

    when "0100" =>
      write31_next <= '0';
      write32_next <= '0';
      write34_next <= '1';
      if done3 = '1' then
        write31_next <= '0';
        write32_next <= '0';
        write34_next <= '0';
      end if;
    
    when "1111" =>
        write31_next <= '1';
        write32_next <= '1';
        write34_next <= '1';
      if done3 = '1' then
        write31_next <= '0';
        write32_next <= '0';
        write34_next <= '0';
      end if;
    when others =>
      null;
  end case;

  case holdsel4 is
    when "0001" =>
      write41_next <= '1';
      write42_next <= '0';
      write43_next <= '0';
      if done4 = '1' then
        write41_next <= '0';
        write42_next <= '0';
        write43_next <= '0';
      end if;

    when "0010" =>
      write41_next <= '0';
      write42_next <= '1';
      write43_next <= '0';
      if done4 = '1' then
        write41_next <= '0';
        write42_next <= '0';
        write43_next <= '0';
      end if;

    when "0011" =>
      write41_next <= '0';
      write42_next <= '0';
      write43_next <= '1';
      if done4 = '1' then
        write41_next <= '0';
        write42_next <= '0';
        write43_next <= '0';
      end if;

    when "1111" =>
        write41_next <= '1';
        write42_next <= '1';
        write43_next <= '1';
      if done4 = '1' then
        write41_next <= '0';
        write42_next <= '0';
        write43_next <= '0';
      end if;
    when others =>
      null;
  end case;
  
end process;

process (read12, read13, read14, read21, read23, read24, read31, read32, read34, read41, read42, read43,
  data_out12, data_out13, data_out14, data_out21, data_out23, data_out24, data_out31, data_out32, data_out34, data_out41, data_out42, data_out43,
  data_out1_read, data_out2_read, data_out3_read, data_out4_read)
begin
  data_out1_next <= data_out1_read;
  data_out2_next <= data_out2_read;
  data_out3_next <= data_out3_read;
  data_out4_next <= data_out4_read;

  if read21 = '1' then
    data_out1_next <= data_out21;
  elsif read31 = '1' then
    data_out1_next <= data_out31;
  elsif read41 = '1' then
    data_out1_next <= data_out41;
  end if;

  if read12 = '1' then
    data_out2_next <= data_out12;
  elsif read32 = '1' then
    data_out2_next <= data_out32;
  elsif read42 = '1' then
    data_out2_next <= data_out42;
  end if;

  if read13 = '1' then
    data_out3_next <= data_out13;
  elsif read23 = '1' then
    data_out3_next <= data_out23;
  elsif read43 = '1' then
    data_out3_next <= data_out43;
  end if;

  if read14 = '1' then
    data_out4_next <= data_out14;
  elsif read24 = '1' then
    data_out4_next <= data_out24;
  elsif read34 = '1' then
    data_out4_next <= data_out34;
  end if;

end process;

  scheduler1 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => write21,
      sendfifo2 => write31,
      sendfifo3 => write41,

      isempty1  => empty21,
      isempty2  => empty31,
      isempty3  => empty41,
  
      outfifo1  => read21,
      outfifo2  => read31,
      outfifo3  => read41
    );

    scheduler2 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => write12,
      sendfifo2 => write32,
      sendfifo3 => write42,

      isempty1  => empty12,
      isempty2  => empty32,
      isempty3  => empty42,
  
      outfifo1  => read12,
      outfifo2  => read32,
      outfifo3  => read42
    );
  
    scheduler3 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => write13,
      sendfifo2 => write23,
      sendfifo3 => write43,

      isempty1  => empty13,
      isempty2  => empty23,
      isempty3  => empty43,
  
      outfifo1  => read13,
      outfifo2  => read23,
      outfifo3  => read43
    );

    scheduler4 : schedulerCB
    port map (
      clk   => clk,
      reset => reset,
  
      sendfifo1 => write14,
      sendfifo2 => write24,
      sendfifo3 => write34,

      isempty1  => empty14,
      isempty2  => empty24,
      isempty3  => empty34,
  
      outfifo1  => read14,
      outfifo2  => read24,
      outfifo3  => read34
    );

  fifo12 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read12,
      wrreq	 => write12,
      empty	 => empty12,
      full	 => full12,
      q	 => data_out12,
      usedw	 => usedw12 
    );
  fifo13 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read13,
      wrreq	 => write13,
      empty	 => empty13,
      full	 => full13,
      q	 => data_out13,
      usedw	 => usedw13
    );
  fifo14 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport1,
      rdreq	 => read14,
      wrreq	 => write14,
      empty	 => empty14,
      full	 => full14,
      q	 => data_out14,
      usedw	 => usedw14 
    );
  fifo21 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read21,
      wrreq	 => write21,
      empty	 => empty21,
      full	 => full21,
      q	 => data_out21,
      usedw	 => usedw21
    );
  fifo23 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read23,
      wrreq	 => write23,
      empty	 => empty23,
      full	 => full23,
      q	 => data_out23,
      usedw	 => usedw23
    );
  fifo24 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport2,
      rdreq	 => read24,
      wrreq	 => write24,
      empty	 => empty24,
      full	 => full24,
      q	 => data_out24,
      usedw	 => usedw24
    );
  fifo31 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read31,
      wrreq	 => write31,
      empty	 => empty31,
      full	 => full31,
      q	 => data_out31,
      usedw	 => usedw31
    );
  fifo32 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read32,
      wrreq	 => write32,
      empty	 => empty32,
      full	 => full32,
      q	 => data_out32,
      usedw	 => usedw32
    );
  fifo34 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport3,
      rdreq	 => read34,
      wrreq	 => write34,
      empty	 => empty34,
      full	 => full34,
      q	 => data_out34,
      usedw	 => usedw34
    );

  fifo41 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read41,
      wrreq	 => write41,
      empty	 => empty41,
      full	 => full41,
      q	 => data_out41,
      usedw	 => usedw41
    );
  fifo42 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read42,
      wrreq	 => write42,
      empty	 => empty42,
      full	 => full42,
      q	 => data_out42,
      usedw	 => usedw42
    );
  fifo43 : fifoCB
    port map (
      clock	 => clk,
      data	 => inport4,
      rdreq	 => read43,
      wrreq	 => write43,
      empty	 => empty43,
      full	 => full43,
      q	 => data_out43,
      usedw	 => usedw43
    );


end architecture;


