`timescale 1ns / 1ps

import axis_video_gen_raw_file_pkg::*;

module axis_Gauss_1x5_tb;

localparam AXIS_DATA_WIDTH = 8;
localparam AXIS_KEEP_WIDTH = AXIS_DATA_WIDTH / 8;
localparam AXIS_USER_WIDTH = 10;
localparam COEFF_WIDTH = 10;

localparam S_AXIS_MAX_DELAY = 3;
localparam M_AXIS_MAX_DELAY = 0;

typedef struct {
  string name;

  int image_width;
  int image_height;

  string output_raw_filename;
  string input_raw_filename;
} tb_param_typedef;

tb_param_typedef tb_param [] = '{
  '{
    name: "Test 1",
	
    image_width: 512,
    image_height: 768,

    output_raw_filename: "F:/projects_modelsim/test_1440/tb/output_raw/output_%0d.raw",
    input_raw_filename: "F:/projects_modelsim/test_1440/tb/input_raw/lynx_gray_512x768.raw"
  }/*,
  '{
    name: "Test 1080I50",
    channel: 10'h01,
    user_video: 10'h10,
    user_vbi: 10'h11,
    user_audio: 10'h12,
    enable_video: 1'b1,
    enable_vbi: 1'b1,
    enable_audio: 1'b1,
    scan_format: 1'b0,
    frame_rate: 4'h9,
    frame_format: 4'h0,
    image_width: 1920,
    image_height: 1080,
    interlaced: 1,
    output_filename: "../tb/yuv_output/output_img_1080i50_packet_loss_%0d.yuv",
    input_pcap_filename: "../tb/pcap_input/2022_6_1080i50_packet_loss.pcapng"
  }*/
};

logic [AXIS_DATA_WIDTH - 1:0] s_axis_tdata;
logic [AXIS_KEEP_WIDTH - 1:0] s_axis_tkeep;
logic [AXIS_USER_WIDTH - 1:0] s_axis_tuser = {AXIS_USER_WIDTH{1'b0}};
logic s_axis_tready = 1'b1;
logic s_axis_tvalid;
logic s_axis_tlast;

logic [AXIS_DATA_WIDTH - 1:0] m_axis_tdata;
logic [AXIS_KEEP_WIDTH - 1:0] m_axis_tkeep;
logic [AXIS_USER_WIDTH - 1:0] m_axis_tuser;
logic m_axis_tready;
logic m_axis_tvalid;
logic m_axis_tlast;

logic clk = 0;
logic nrst = 1'b0;

int seed = 1;

always #2.5 clk = !clk;

initial begin
  int number_of_generators;
  int status;

  axis_video_gen #(
      .IMAGE_WIDTH(512),
      .IMAGE_HEIGHT(768),
      .OUTPUT_DATA_WIDTH(AXIS_DATA_WIDTH),
	  .USER_WIDTH(AXIS_USER_WIDTH),
	  .PIXELS_PER_WORD(1),
      .AXIS_MAX_DELAY(S_AXIS_MAX_DELAY)
  ) test_gen [];

  number_of_generators = $size(tb_param);
  test_gen = new[number_of_generators];

  for (int i = 0; i < number_of_generators; i++) begin
    test_gen[i] = new(tb_param[i].input_raw_filename);
  end
  
  repeat(10) @(posedge clk);
  nrst = 1'b1;
  repeat(10) @(posedge clk);
  
    for (;;) begin
    status = 0;
    for (int i = 0; i < number_of_generators; i++) begin
      test_gen[i].send(clk, s_axis_tdata, s_axis_tuser, s_axis_tvalid, s_axis_tlast, s_axis_tready);
      status += test_gen[i].get_status();
    end
    if (status == 0) break;
  end
  $finish;
  
end

initial begin
  @(posedge nrst);
  m_axis_tready <= 1'b1;
  if (M_AXIS_MAX_DELAY == 0) begin
    m_axis_tready <= 1'b1;
  end else for (;;) begin
    repeat(1 + $unsigned($random(seed)) % (M_AXIS_MAX_DELAY + 1)) @(posedge clk);
    m_axis_tready <= 1'b1;
    repeat(1 + $unsigned($random(seed)) % (M_AXIS_MAX_DELAY + 1)) @(posedge clk);
    m_axis_tready <= 1'b0;
  end
end

 axis_save_raw_video #(
  .OUTPUT_RAW_FILENAME("output_img.raw"),
  .IMAGE_WIDTH(512),
  .IMAGE_HEIGHT(768),
  .INPUT_DATA_WIDTH(AXIS_DATA_WIDTH)
) axis_save_raw_video_inst (
  .clk(clk),
  .nrst(nrst),

  .axis_tdata(m_axis_tdata),
  .axis_tvalid(m_axis_tvalid),
  .axis_tready(m_axis_tready),
  .axis_tlast(m_axis_tlast)
);

 axis_Gauss_1x5 #(
                .DATA_WIDTH(AXIS_DATA_WIDTH),
                .COEFF_WIDTH(COEFF_WIDTH)
                )
				axis_Gauss_1x5_inst (
					       .s_axis_aclk(clk),
					       .s_axis_arstn(nrst),
					       .s_axis_tdata(s_axis_tdata),
						   .s_axis_tvalid(s_axis_tvalid),
						   .s_axis_tlast(s_axis_tlast),
						   //.s_axis_tready(s_axis_tready),
					       .m_axis_tdata(m_axis_tdata),
						   .m_axis_tvalid(m_axis_tvalid),
						   //.m_axis_tready(m_axis_tready),
						   .m_axis_tlast(m_axis_tlast)
					  );

endmodule
