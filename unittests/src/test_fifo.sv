// TEST_DATA_LENGTH and TEST_DATA macro definitions
`include "test_fifo_testdata.sv"

module test_fifo;
  timeunit 1ns;
  timeprecision 100ps;

  reg wr_clk_i = 0;
  reg wr_rst_i;
  reg wr_stb_i;
  wire wr_full_o;
  reg [7:0] wr_dat_i;
  reg rd_clk_i = 0;
  reg rd_rst_i;
  reg rd_stb_i;
  wire rd_empty_o;
  wire [7:0] rd_dat_o;
  fifo dut (.*);

  // Test different clock ratios
  integer test_count = 4;
  integer wr_test_index = 0;
  integer rd_test_index = 0;
  realtime wr_clk_periods [0:3] = '{8ns, 36ns, 12ns, 4ns};
  realtime rd_clk_periods [0:3] = '{12ns, 4ns, 24ns, 36ns};

  realtime wr_clk_period;
  always
    begin
      wr_clk_period = wr_test_index < test_count ? wr_clk_periods[wr_test_index]/2 : 10ns;
      #(wr_clk_period/2) wr_clk_i = ~wr_clk_i;
    end

  realtime rd_clk_period;
  always
    begin
      rd_clk_period = rd_test_index < test_count ? rd_clk_periods[rd_test_index]/2 : 10ns;
      #(rd_clk_period/2) rd_clk_i = ~rd_clk_i;
    end

  reg [7:0] test_data [0:`TEST_DATA_LENGTH - 1] = `TEST_DATA;

  initial
    begin
      for (wr_test_index = 0; wr_test_index < test_count; wr_test_index = wr_test_index + 1) begin
        integer i;

        // Sync with the clock + 90 degrees lag
        #wr_clk_period;
        @(posedge wr_clk_i);
        #(wr_clk_period/4);
        // Synchronize with the read process
        while (rd_test_index < wr_test_index) #wr_clk_period;
        wr_rst_i = 1;
        wr_stb_i = 0;
        wr_dat_i = 0;
        #(7*wr_clk_period);
        wr_rst_i = 0;
        for (i = 0; i < `TEST_DATA_LENGTH; i = i + 1) begin
          while (wr_full_o) #wr_clk_period;
          wr_dat_i = test_data[i];
          wr_stb_i = 1;
          #wr_clk_period;
          wr_stb_i = 0;
        end
      end

      // Wait for the read process to finish
      while (rd_test_index < wr_test_index) #wr_clk_period;
      $finish;
    end

  initial
    begin
      for (rd_test_index = 0; rd_test_index < test_count; rd_test_index = rd_test_index + 1) begin
        integer i;

        // Sync with the clock + 90 degrees lag
        #rd_clk_period;
        @(posedge rd_clk_i);
        #(rd_clk_period/4);

        // Wait for the write process
        while (wr_test_index < rd_test_index) #rd_clk_period;

        rd_rst_i = 1;
        rd_stb_i = 0;
        #(7*rd_clk_period);
        rd_rst_i = 0;
        while (!wr_full_o) #rd_clk_period;
        #(5*rd_clk_period);
        for (i = 0; i < `TEST_DATA_LENGTH; i = i + 1) begin
          while (rd_empty_o) #rd_clk_period;
          rd_stb_i = 1;
          #rd_clk_period;
          rd_stb_i = 0;
          #rd_clk_period;
          assert (rd_dat_o == test_data[i])
            else $fatal(0, "Test data mismatch");
        end
      end
    end
endmodule
