
library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mac_learner is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    sMAC    : in std_logic_vector (47 downto 0);
    dMAC    : in std_logic_vector (47 downto 0);
    portnum : in std_logic_vector (2 downto 0);
    MAC_inc : in std_logic; -- a mac address is coming

    sel     : out std_logic_vector (3 downto 0)
  );
end entity;



architecture mac_learner_arch of mac_learner is

  signal RW : std_logic := '0';
  signal address : std_logic_vector(12 downto 0) := (others => '0');
  constant g : std_logic_vector(12 downto 0) := "1100000001111";
  signal SMACport : std_logic_vector(50 downto 0) := (others => '0');
  signal count : integer := 0;
  signal  memory : std_logic_vector (47 downto 0) := (others => '0');
  signal sel_from_mem : std_logic_vector(2 downto 0) := "000";
  
  
  type state_type is (idle, insert_key, lookup_key, answer, conclude);
    
  signal current_state, next_state : state_type;  

  
  component ram is
    port (
      clk     : in std_logic;
      reset   : in std_logic;
      address : in std_logic_vector (12 downto 0);
      data_in : in std_logic_vector (50 downto 0);
      RW      : in std_logic;

      sel_out : out std_logic_vector (2 downto 0);
      memory  : out std_logic_vector(47 downto 0)
      );
  end component;
  
  function hash_src (M : std_logic_vector; g : std_logic_vector) return std_logic_vector is
    variable crc : std_logic_vector(12 downto 0) := (others => '0');
    type R_array is array (0 to 12) of std_logic;
    variable R : R_array := (others => '0');
    variable connect : std_logic;
  
  begin
    REST : for i in 0 to 47 loop
      if i > 47 then
        connect := R(12);
      else
        connect := M(i) xor R(12);
      end if;
      for j in 12 downto 1 loop
        if g(j) = '1' then
          R(j) := connect xor R(j-1);
        else
          R(j) := R(j-1);
        end if;
      end loop;
        R(0) := connect;
    end loop;

    crc := R(12) & R(11) & R(10) & R(9) & R(8) & R(7) & R(6) & R(5) & R(4) & R(3) & R(2) & R(1) & R(0);
    return std_logic_vector(crc);    
  end function;
  

begin

  ram_inst : ram
  port map (
    clk => clk,
    reset => reset,
    RW => RW,
    address => address,
    data_in => SMACport,
    sel_out => sel_from_mem,
    memory => memory
  );

  state_memory_logic : process (clk, reset)
  begin
    if reset = '1' then
      current_state <= idle;
      elsif rising_edge(clk) then
        current_state <= next_state;
      end if;
  end process;

  next_state_logic : process (current_state, count, MAC_inc)
  begin
    next_state <= current_state;

    case current_state is
      when idle =>
      if MAC_inc = '1' then
        next_state <= insert_key;
      end if;

       when insert_key =>
          next_state <= lookup_key;

      when lookup_key =>
        next_state <= answer;

      when answer =>
        next_state <= idle;

    
      when others =>
        null;
    end case;
  end process;

  output_logic : process (current_state, memory)
  begin
    case current_state is
      when idle =>
        sel <= "0000";
      when insert_key =>
      SMACport <= sMAC & portnum;
      address <= hash_src(sMAC, g);
      RW <= '1';

      when lookup_key =>
      RW <= '0';
      address <= hash_src(dMAC, g);

      when answer =>
      if memory = X"000000000000" then
        sel <= "1111";
      else
        sel <= "0" & sel_from_mem;
      end if;

    
      when others =>
      --address <= hash_src(dMAC, g);
        null;
    end case;
  end process;



end architecture;