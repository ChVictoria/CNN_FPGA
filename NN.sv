`include "Conv2D.sv"
`include "MaxPool2D.sv"
`include "Dense.sv"


`define KERNEL_HEIGHT 3
`define KERNEL_WIDTH 3
`define CONV2D_1_FILTERS_NUMBER 2
`define CONV2D_2_FILTERS_NUMBER 32
`define CONV2D_3_FILTERS_NUMBER 64


`define DENSE_NEURONS 512


module NN #(parameter INPUT_HEIGHT, INPUT_WIDTH, INPUT_DEPTH, VALUE_BITS=32)
  (
  input [VALUE_BITS-1:0] input_image [INPUT_HEIGHT * INPUT_WIDTH * INPUT_DEPTH-1:0],
  input [VALUE_BITS-1:0] conv2d_1_weights [`KERNEL_HEIGHT * `KERNEL_WIDTH * INPUT_DEPTH * `CONV2D_1_FILTERS_NUMBER - 1:0] ,
  input [VALUE_BITS-1:0] conv2d_1_biases [`CONV2D_1_FILTERS_NUMBER - 1:0],
  input clk,
  output [VALUE_BITS-1:0] prediction 
  );
  
  wire [VALUE_BITS-1:0] con2d_1_output_data [`OUTPUT_SIZE(INPUT_HEIGHT, `KERNEL_HEIGHT) * `OUTPUT_SIZE(INPUT_WIDTH, `KERNEL_WIDTH)* `CONV2D_1_FILTERS_NUMBER - 1:0];
  
  ConvLayer #(.KERNEL_WIDTH(`KERNEL_WIDTH), .KERNEL_HEIGHT(`KERNEL_HEIGHT), .FILTERS_NUMBER(`CONV2D_1_FILTERS_NUMBER),
              .INPUT_WIDTH(INPUT_WIDTH), .INPUT_HEIGHT(INPUT_HEIGHT), .INPUT_DEPTH(INPUT_DEPTH)
              ) cov2d_1 
                  (.input_data(input_image), 
                  .weights(conv2d_1_weights), 
                  .biases(conv2d_1_biases), 
                  .clk(clk), 
                  .output_data(con2d_1_output_data));
  
endmodule
  
