library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity inputport is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    data_in : in std_logic_vector (7 downto 0);
    valid   : in std_logic;
    read_en : in std_logic;

    srcMac : out std_logic_vector(47 downto 0);
    dstMac : out std_logic_vector(47 downto 0);
    FCS_error : out std_logic;
    data_out: out std_logic_vector (7 downto 0)
  );
end entity;


architecture inputport_arch of inputport is
  signal empty_fifo : std_logic := '0';
  signal full_fifo : std_logic := '0';
  signal status_fifo : std_logic_vector (10 downto 0) := (others => '0');

  signal SoF  : std_logic := '1';
  signal counter : integer := 0;

  signal tempsrc : std_logic_vector (47 downto 0) := (others => '0');
  signal tempdst : std_logic_vector (47 downto 0) := (others => '0');
  
  
  component FIFOSwitch is
    port (
      clock		: IN STD_LOGIC ;
      data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdreq		: IN STD_LOGIC ;
      wrreq		: IN STD_LOGIC ;
      empty		: OUT STD_LOGIC ;
      full		: OUT STD_LOGIC ;
      q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      usedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
    );
  end component;
  
  component FCS is
    port (
      clk : in std_logic;
      reset : in std_logic;
      start_of_frame : in std_logic;
      data_in : in std_logic_vector(7 downto 0);
      fcs_error : out std_logic
    );
  end component;
  
  
begin


  clk_proc : process (clk, counter)
  begin

    if reset = '1' then

    elsif rising_edge(clk) then
      counter <= counter +1;

      if counter = 1 then
        tempsrc(47 downto 40) <= data_in;
        SoF <= '0';
      end if;
      
      if counter = 2 then
        tempsrc(39 downto 32) <= data_in;
      end if;
      
      if counter = 3 then
        tempsrc(31 downto 24) <= data_in;
      end if;
      if counter = 4 then
        tempsrc(23 downto 16) <= data_in;
      end if;
      if counter = 5 then
        tempsrc(15 downto 8) <= data_in;
      end if;

      if counter = 6 then
        --tempsrc(7 downto 0) <= data_in;
        srcMac(47 downto 8) <= tempsrc(47 downto 8);
        srcMac(7 downto 0) <= data_in;
      end if;

      if counter = 7 then
        tempdst(47 downto 40) <= data_in;
        SoF <= '0';
      end if;
      
      if counter = 8 then
        tempdst(39 downto 32) <= data_in;
      end if;
      
      if counter = 9 then
        tempdst(31 downto 24) <= data_in;
      end if;
      if counter = 10 then
        tempdst(23 downto 16) <= data_in;
      end if;
      if counter = 11 then
        tempdst(15 downto 8) <= data_in;
      end if;

      if counter = 12 then
        --tempdst(7 downto 0) <= data_in;
        dstMac(47 downto 8) <= tempdst(47 downto 8);
        dstMac(7 downto 0) <= data_in;
      end if;

    end if;
  end process;

  fifo_ports : FIFOSwitch
    port map (
      clock => clk,
      data => data_in,
      rdreq => read_en,
      wrreq => valid,
      empty => empty_fifo,
      full => full_fifo,
      q => data_out,
      usedw => status_fifo
    );


fcs_ports : FCS
  port map (
    clk  =>clk,
    reset  =>reset,
    start_of_frame  => SoF, 
    data_in  => data_in,
    fcs_error => FCS_error
  );


  -- logic : process (SoF)
  -- begin
  --   if SoF = '1' then
  --     SoF <= '0';
  --   end if;
  -- end process;

end architecture;