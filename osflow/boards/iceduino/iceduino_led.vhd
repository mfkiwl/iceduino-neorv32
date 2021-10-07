library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity iceduino_led is
  generic (
    addr : std_ulogic_vector(31 downto 0)
  );
  port (
    clk_i  : in  std_ulogic; -- global clock line
    rstn_i 	: in  std_ulogic; -- global reset line, low-active
    --wishbone-
    adr_i 	: in  std_ulogic_vector(31 downto 0); 
    dat_i	: in  std_ulogic_vector(31 downto 0); --write to slave
    dat_o	: out std_ulogic_vector(31 downto 0);       
    we_i  	: in  std_ulogic;
    stb_i  	: in  std_ulogic;
    cyc_i  	: in  std_ulogic;
    ack_o  	: out  std_ulogic;
    err_o  	: out  std_ulogic;
    -- parallel io --
    led_o : out std_ulogic_vector(7 downto 0)
  );
end entity;

architecture iceduino_led_rtl of iceduino_led  is

  
-- access control --
  signal acc_en : std_ulogic; -- module access enable

  -- accessible regs --
 
  signal dout : std_ulogic_vector(31 downto 0); -- r/w

begin

  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  acc_en <= '1' when (adr_i = addr and (cyc_i = '1' and stb_i = '1')) else '0';

  -- Read/Write Access ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  rw_access: process(clk_i)
  begin
    if rising_edge(clk_i) then
      -- bus handshake --
      ack_o <= acc_en;
      

      -- write access --
      if (acc_en = '1' and we_i = '1') then
          dout <= dat_i;
      end if;

     

      -- read access --
      dat_o <= (others => '0');
      if ((acc_en and (not we_i)) = '1') then
        dat_o <= dout;       
      end if;

    end if;
  end process rw_access;

  -- output --
  led_o <= dout(7 downto 0);
  err_o <= '0';
  
end architecture ;
