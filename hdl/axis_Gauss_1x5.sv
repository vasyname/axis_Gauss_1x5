`timescale 1ns/1ns

module mult_coeff #(parameter COEFF_WIDTH = 10
                    )
				    (input  logic [3:0] a,
                     input  logic [COEFF_WIDTH - 1:0] coeff,
				     output logic [COEFF_WIDTH + 4 - 1:0] result);

//4-input lut
always_comb begin
  result = a * coeff;
end
endmodule

module axis_Gauss_1x5 #(
                parameter DATA_WIDTH = 8,
                parameter COEFF_WIDTH = 10//,
                )(
				  input  logic s_axis_aclk,
				  input  logic s_axis_arstn,
				  input  logic [DATA_WIDTH - 1:0] s_axis_tdata,
				  input  logic s_axis_tvalid,
				  input  logic s_axis_tlast,
				  //output  logic s_axis_tready,
				  output logic [DATA_WIDTH - 1:0] m_axis_tdata,
				  output logic m_axis_tvalid,
				  //input  logic m_axis_tready,
				  output logic m_axis_tlast
				);

//29        11101
//240    11110000
//487   111100111

//logic [COEFF_WIDTH - 1:0] Gauss_norm_1x5 = {29, 240, 486, 240, 29};//1024, 10 bit
//delayed data in
logic [DATA_WIDTH - 1:0] s_axis_tdata_delayed [3:0];
logic s_axis_tvalid_delayed [3:0];
logic s_axis_tlast_delayed [3:0];

always @(posedge s_axis_aclk) begin
s_axis_tdata_delayed[0] <= s_axis_tdata;
s_axis_tvalid_delayed[0] <= s_axis_tvalid;
s_axis_tlast_delayed[0] <= s_axis_tlast;
  for (int i = 0; i < 3; i++) begin
    s_axis_tdata_delayed[i + 1] <= s_axis_tdata_delayed[i];
    s_axis_tvalid_delayed[i + 1] <= s_axis_tvalid_delayed[i];
    s_axis_tlast_delayed[i + 1] <= s_axis_tlast_delayed[i];
  end
end

logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s5_low_d29;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s5_high_d29;
logic [DATA_WIDTH + COEFF_WIDTH - 1:0] s5_d29;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s4_low_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s4_high_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 1:0] s4_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s3_low_d486;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s3_high_d486;
logic [DATA_WIDTH + COEFF_WIDTH - 1:0] s3_d486;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s2_low_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s2_high_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 1:0] s2_d240;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s1_low_d29;
logic [DATA_WIDTH + COEFF_WIDTH - 4 - 1:0] s1_high_d29;
logic [DATA_WIDTH + COEFF_WIDTH - 1:0] s1_d29;

logic [13:0] byte_cnt;//up to 8192 image width

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s5_low_d29(
			  .a(s_axis_tdata[DATA_WIDTH - 4 - 1:0]),
			  .coeff(10'd29),
			  .result(s5_low_d29)
			  );

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s5_high_d29(
			  .a(s_axis_tdata[DATA_WIDTH - 1:DATA_WIDTH - 4]),
			  .coeff(10'd29),
			  .result(s5_high_d29)
			  );

assign s5_d29 = (s5_high_d29 << 4) + s5_low_d29;

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s4_low_d240(
			  .a(s_axis_tdata_delayed[0][DATA_WIDTH - 4 - 1:0]),
			  .coeff(10'd240),
			  .result(s4_low_d240)
			  );

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s4_high_d240(
			  .a(s_axis_tdata_delayed[0][DATA_WIDTH - 1:DATA_WIDTH - 4]),
			  .coeff(10'd240),
			  .result(s4_high_d240)
			  );

assign s4_d240 = (s4_high_d240 << 4) + s4_low_d240;

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s3_low_d486(
			  .a(s_axis_tdata_delayed[1][DATA_WIDTH - 4 - 1:0]),
			  .coeff(10'd486),
			  .result(s3_low_d486)
			  );

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s3_high_d486(
			  .a(s_axis_tdata_delayed[1][DATA_WIDTH - 1:DATA_WIDTH - 4]),
			  .coeff(10'd486),
			  .result(s3_high_d486)
			  );

assign s3_d486 = (s3_high_d486 << 4) + s3_low_d486;

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s2_low_d240(
			  .a(s_axis_tdata_delayed[2][DATA_WIDTH - 4 - 1:0]),
			  .coeff(10'd240),
			  .result(s2_low_d240)
			  );

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s2_high_d240(
			  .a(s_axis_tdata_delayed[2][DATA_WIDTH - 1:DATA_WIDTH - 4]),
			  .coeff(10'd240),
			  .result(s2_high_d240)
			  );

assign s2_d240 = (s2_high_d240 << 4) + s2_low_d240;

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s1_low_d29(
			  .a(s_axis_tdata_delayed[3][DATA_WIDTH - 4 - 1:0]),
			  .coeff(10'd29),
			  .result(s1_low_d29)
			  );

 mult_coeff #(.COEFF_WIDTH(COEFF_WIDTH)
              ) mult_coeff_s1_high_d29(
			  .a(s_axis_tdata_delayed[3][DATA_WIDTH - 1:DATA_WIDTH - 4]),
			  .coeff(10'd29),
			  .result(s1_high_d29)
			  );

assign s1_d29 = (s1_high_d29 << 4) + s1_low_d29;

always @(posedge s_axis_aclk) begin
  if (!s_axis_arstn) begin
    byte_cnt <= 0;
  end else begin
    if (!s_axis_tlast) begin
	  if (s_axis_tvalid) begin
	    byte_cnt <= byte_cnt + 1;
	  end
	end else begin
	  byte_cnt <= 0;
	end
    if ((byte_cnt == 2) || (byte_cnt == 3)) begin
	  m_axis_tdata <= s_axis_tdata_delayed[1];//first two pixels in line transmit without filtering
	  m_axis_tvalid <= s_axis_tvalid_delayed[1];//edge effect
	  m_axis_tlast  <= 1'b0;
	end else begin
	  m_axis_tdata <= (s5_d29 + s4_d240 + s3_d486 + s2_d240 + s1_d29) >> 10;//1/1024
	  m_axis_tvalid <= s_axis_tvalid_delayed[1];//last two pixels transmit with slight wrong values
	  m_axis_tlast  <= s_axis_tlast_delayed[1];
	end
  end
end

endmodule
