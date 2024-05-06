library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switchcore is

	port
			(
				clk:			in	std_logic;
				reset:			in	std_logic;
				
				--Activity indicators
				link_sync:		in	std_logic_vector(3 downto 0);	--High indicates a peer connection at the physical layer. 
				
				--Four GMII interfaces
				tx_data:			out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
				tx_ctrl:			out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
				rx_data:			in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
				rx_ctrl:			in	std_logic_vector(3 downto 0)	--(0)=RXC0...(3=RXC3)
			);

end switchcore;

architecture arch of switchcore is

	component switch_core is
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

			outport1 : out std_logic_vector (7 downto 0);
			outport2 : out std_logic_vector (7 downto 0);
			outport3 : out std_logic_vector (7 downto 0);
			outport4 : out std_logic_vector (7 downto 0);

			outvalid1 : out std_logic;
			outvalid2 : out std_logic;
			outvalid3 : out std_logic;
			outvalid4 : out std_logic
			
		);
	end component;

	signal indata1, indata2, indata3, indata4 : std_logic_vector (7 downto 0);
	signal invalid1, invalid2, invalid3, invalid4 : std_logic;
	signal outdata1, outdata2, outdata3, outdata4 : std_logic_vector (7 downto 0);
	
	signal ovalid1, ovalid2, ovalid3, ovalid4 : std_logic;
	

BEGIN

	indata1 <= rx_data (7 downto 0);
	indata2 <= rx_data (15 downto 8);
	indata3 <= rx_data (23 downto 16);
	indata4 <= rx_data (31 downto 24);

	invalid1 <= rx_ctrl(0);
	invalid2 <= rx_ctrl(1);
	invalid3 <= rx_ctrl(2);
	invalid4 <= rx_ctrl(3);
	
	tx_ctrl(0) <= ovalid1;
	tx_ctrl(1) <= ovalid2;
	tx_ctrl(2) <= ovalid3;
	tx_ctrl(3) <= ovalid4;

	tx_data (7 downto 0) <= outdata1;
	tx_data (15 downto 8) <= outdata2;
	tx_data (23 downto 16) <= outdata3;
	tx_data (31 downto 24) <= outdata4;


ourswitch_core : switch_core
	port map (
		clk   => clk,
		reset => reset,

		inport1 => indata1,
		inport2 => indata2,
		inport3 => indata3,
		inport4 => indata4,

		valid1 => invalid1,
		valid2 => invalid2,
		valid3 => invalid3,
		valid4 => invalid4,

		outport1 => outdata1,
		outport2 => outdata2,
		outport3 => outdata3,
		outport4 => outdata4,

		outvalid1 => ovalid1,
		outvalid2 => ovalid2,
		outvalid3 => ovalid3,
		outvalid4 => ovalid4
	);


-- internalloop:	process(clk, reset)
-- begin

	-- if(reset='0') then
	-- 	tx_data(7 downto 0)<=(others=>'0');
	-- 	tx_data(15 downto 8)<=(others=>'0');
	-- 	tx_ctrl(0)<='0';
	-- 	tx_ctrl(1)<='0';
	
	-- elsif(rising_edge(clk)) then

	-- 	tx_data(7 downto 0)<=rx_data(15 downto 8);
	-- 	tx_data(15 downto 8)<=rx_data(7 downto 0);
	-- 	tx_ctrl(0)<=rx_ctrl(1);
	-- 	tx_ctrl(1)<=rx_ctrl(0);
	-- end if;
	
-- end process;






END arch;

```
