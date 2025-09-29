`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2025 19:52:56
// Design Name: 
// Module Name: axis_Gauss_1x5_verilog_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axis_Gauss_1x5_verilog_wrapper #(
                                        parameter DATA_WIDTH = 8,
                                        parameter COEFF_WIDTH = 10//,
                                        )(
                                          input wire s_axis_aclk,
                                          input wire s_axis_arstn,
                                          input wire [DATA_WIDTH - 1:0] s_axis_tdata,
                                          input wire s_axis_tvalid,
                                          input wire s_axis_tlast,
                                          output wire [DATA_WIDTH - 1:0] m_axis_tdata,
                                          output wire m_axis_tvalid,
                                          output wire m_axis_tlast
                                        );
    
      axis_Gauss_1x5 #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .COEFF_WIDTH(COEFF_WIDTH)
                    ) axis_Gauss_1x5_inst (
    				  .s_axis_aclk(s_axis_aclk),
    				  .s_axis_arstn(s_axis_arstn),
    				  .s_axis_tdata(s_axis_tdata),
    				  .s_axis_tvalid(s_axis_tvalid),
    				  .s_axis_tlast(s_axis_tlast),
    				  .m_axis_tdata(m_axis_tdata),
    				  .m_axis_tvalid(m_axis_tvalid),
    				  .m_axis_tlast(m_axis_tlast)
    				);
    				  
endmodule
