library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
  port (
    signal wr_clk_i : in std_ulogic;
    signal wr_rst_i : in std_ulogic;
    signal wr_stb_i : in std_ulogic;
    signal wr_full_o : out std_ulogic;
    signal wr_dat_i : in std_ulogic_vector(7 downto 0);
    signal rd_clk_i : in std_ulogic;
    signal rd_rst_i : in std_ulogic;
    signal rd_stb_i : in std_ulogic;
    signal rd_empty_o : out std_ulogic;
    signal rd_dat_o : out std_ulogic_vector(7 downto 0)
  );
end entity;

architecture fpga of fifo is
  /* Counters and addresses */
  constant address_size : natural := 10;
  constant counter_size : natural := address_size + 1;
  subtype counter_type is std_ulogic_vector(counter_size - 1 downto 0);
  subtype address_type is std_ulogic_vector(address_size - 1 downto 0);
  signal wr_counter : counter_type;
  alias wr_address : address_type is wr_counter(address_size - 1 downto 0);
  signal wr_gray : counter_type;
  signal wr_rdgray_m1 : counter_type;
  signal wr_rdgray : counter_type;
  signal rd_counter : counter_type;
  alias rd_address : address_type is rd_counter(address_size - 1 downto 0);
  signal rd_gray : counter_type;
  signal rd_wrgray_m1 : counter_type;
  signal rd_wrgray : counter_type;

  pure function binary_to_grey(bin : std_ulogic_vector)
    return std_ulogic_vector is
  begin
    return bin xor std_ulogic_vector(shift_right(unsigned(bin), 1));
  end function;

  pure function grey_full(g1 : std_logic_vector; g2 : std_ulogic_vector)
    return boolean is
    constant left : integer := g1'left;
    constant right : integer := g1'right;
  begin
    return g1(left downto left - 1) = not g2(left downto left - 1)
      and g1(left - 2 downto right) = g2(left - 2 downto right);
  end function;
begin
  /* Write side */
  wr_counter <= (others => '0')
      when rising_edge(wr_clk_i) and (??wr_rst_i)
    else std_ulogic_vector(unsigned(wr_counter) + 1)
      when rising_edge(wr_clk_i) and (??wr_stb_i);
  wr_gray <= binary_to_grey(wr_counter);
  wr_rdgray_m1 <= rd_gray when rising_edge(wr_clk_i); -- rd to wr clock
  wr_rdgray <= wr_rdgray_m1 when rising_edge(wr_clk_i); -- metastability sync
  wr_full_o <= '1' when grey_full(wr_gray, wr_rdgray) else '0';

  /* Read side */
  rd_counter <= (others => '0')
      when rising_edge(rd_clk_i) and (??rd_rst_i)
    else std_ulogic_vector(unsigned(rd_counter) + 1)
      when rising_edge(rd_clk_i) and (??rd_stb_i);
  rd_gray <= binary_to_grey(rd_counter);
  rd_wrgray_m1 <= wr_gray when rising_edge(rd_clk_i); -- wr to rd clock
  rd_wrgray <= rd_wrgray_m1 when rising_edge(rd_clk_i); -- metastability sync
  rd_empty_o <= '1' when rd_gray = rd_wrgray else '0'; -- empty if equal

  /* The dual port memory */
  U0_MEM: entity work.fifo_mem port map (
    WrAddress => wr_address,
    RdAddress => rd_address,
    Data => wr_dat_i,
    WE => wr_stb_i,
    RdClock => rd_clk_i,
    RdClockEn => '1',
    Reset => '0',
    WrClock => wr_clk_i,
    WrClockEn => '1',
    Q => rd_dat_o
  );
end architecture;
