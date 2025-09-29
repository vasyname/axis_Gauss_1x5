`timescale 1ns / 1ps

package axis_video_gen_raw_file_pkg;

class axis_video_gen #(
  //string INPUT_RAW_FILENAME = "F:/projects_modelsim/test_1440/tb/input_raw/lynx_gray_512x768.raw",
  parameter IMAGE_WIDTH = 512,
  parameter IMAGE_HEIGHT = 768,

  parameter OUTPUT_DATA_WIDTH = 8,
  parameter USER_WIDTH = 10,
  parameter KEEP_WIDTH = ((OUTPUT_DATA_WIDTH + 7) / 8),
  parameter PIXELS_PER_WORD = 1,
  parameter WORDS_PER_LINE = (IMAGE_WIDTH + PIXELS_PER_WORD - 1) / PIXELS_PER_WORD,

  parameter AXIS_MAX_DELAY = 0 // Максимальное значение псевдослучайной задержки при передаче.
);

  int seed = 1;
  string INPUT_RAW_FILENAME = "F:/projects_modelsim/test_1440/tb/input_raw/lynx_gray_512x768.raw";
  int USER_VALUE = 0;
  int line;
  bit [OUTPUT_DATA_WIDTH - 1:0] output_data [IMAGE_HEIGHT][WORDS_PER_LINE];

  function new(string filename);
    //bit [7:0] lum_data [IMAGE_HEIGHT][IMAGE_WIDTH];
    INPUT_RAW_FILENAME = filename;
    read_frame(output_data);
  endfunction

  task send(ref clk, ref [OUTPUT_DATA_WIDTH - 1:0] tdata, ref [USER_WIDTH - 1:0] tuser, ref tvalid, ref tlast, ref tready);
    for (line = 0; line < IMAGE_HEIGHT; line++) begin
      for (int i = 0; i < WORDS_PER_LINE; i++) begin
        tvalid = 1'b0;
        if (AXIS_MAX_DELAY > 0) repeat($unsigned($random(seed)) % (AXIS_MAX_DELAY + 1)) @(posedge clk);
        tdata = output_data[line][i];
        tuser = USER_VALUE;//output_user[line][i];
        tvalid = 1'b1;
        tlast = (i == (WORDS_PER_LINE - 1));
        @(posedge clk);
        while (!tready) @(posedge clk);
      end
	  tvalid = 1'b0;
      tlast = 1'b0;
	  repeat(10) @(posedge clk);//after transmit every line 10 ticks 
    end
    tvalid = 1'b0;
    tlast = 1'b0;
	if (line == (IMAGE_HEIGHT - 1)) begin
      $display("End of data transfer.");
    end
  endtask

  function int get_status();
    return $size(output_data) - line;
  endfunction

  function void read_frame(ref bit [7:0] lum_data [IMAGE_HEIGHT][IMAGE_WIDTH]);
    int byte_cnt = 0;
    int fd = $fopen(INPUT_RAW_FILENAME, "rb");
    int f;
    bit [7:0] tmp;
    $display(INPUT_RAW_FILENAME);
	//$fclose(fd);
	//$display("raw file read");
	//$stop;
    for (int i = 0; i < IMAGE_HEIGHT; i++) begin
      for (int j = 0; j < IMAGE_WIDTH; j++) begin
        lum_data[i][j] = 8'b0;
        f = $fread(tmp, fd);
        lum_data[i][j] = tmp;
      end
    end
    $fclose(fd);
	$display("raw file read");
  endfunction

endclass

endpackage
