`timescale 1ns / 100ps

module axis_save_raw_video #(
  parameter OUTPUT_RAW_FILENAME = "output_img_%0d.raw",
  parameter IMAGE_WIDTH = 512,
  parameter IMAGE_HEIGHT = 768,
  parameter INPUT_DATA_WIDTH = 8
)(
  input logic clk,
  input logic nrst,

  input logic [INPUT_DATA_WIDTH - 1:0] axis_tdata,
  input logic axis_tvalid,
  input logic axis_tready,
  input logic axis_tlast
);

localparam REQUIRED_PACKET_LENGTH = IMAGE_WIDTH;

bit [INPUT_DATA_WIDTH - 1:0] input_data_line [$];
bit [INPUT_DATA_WIDTH - 1:0] input_data [$][$];

int line_cnt = 0;

task automatic save_frame(string filename,
                          ref bit [INPUT_DATA_WIDTH - 1:0] input_data [$][$]);
  int fd;
  string out_filename;

  int height;
  int width;

  bit [7:0] lum_data [IMAGE_HEIGHT][IMAGE_WIDTH];

  height = $size(input_data);
  width = $size(input_data[0]);

  for (int line = 0; line < $size(input_data); line++) begin
    for (int i = 0; i < $size(input_data[line]); i++) begin
      lum_data[line][i] = input_data[line][i];
    end
  end
  
  out_filename = OUTPUT_RAW_FILENAME;

  $display("Save: %s", out_filename);
  fd = $fopen(out_filename, "wb");

  for (int i = 0; i < height; i++) begin
    for (int j = 0; j < width; j++) begin
      $fwrite(fd, "%c", lum_data [i][j]);
      lum_data[i][j] = 8'b0;
    end
  end

  $fclose(fd);

endtask

always @(posedge clk) begin
  if (!nrst) begin
    input_data_line = {};
    input_data = {};
	line_cnt = 0;
  end else if (axis_tvalid && axis_tready) begin
    input_data_line.push_back(axis_tdata);
    if (axis_tlast) begin
      if ($size(input_data_line) != REQUIRED_PACKET_LENGTH) begin
        $display("Invalid packet length: %d", $size(input_data_line));
        $finish;
      end
      input_data.push_back(input_data_line);
      input_data_line = {};
	  line_cnt++;
    end
	if (line_cnt == IMAGE_HEIGHT) begin
	  save_frame(OUTPUT_RAW_FILENAME, input_data);
	  input_data = {};
	  $finish;
	end
  end
end

endmodule
