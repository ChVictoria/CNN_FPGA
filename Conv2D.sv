`define OUTPUT_SIZE(is, ks) ((is) - (ks) + 1)

`include "fpu.sv"

 module Filter  #(parameter KERNEL_WIDTH, KERNEL_HEIGHT, INPUT_DEPTH, VALUE_BITS=32)
  (
  input [VALUE_BITS-1:0] weights [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH-1:0],
  input [VALUE_BITS-1:0] bias,
  input [VALUE_BITS-1:0] input_window [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH-1:0],
  input clk,
  output [VALUE_BITS-1:0] result
  );
  
  wire [VALUE_BITS-1:0] mul_array [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH - 1:0];
  
  
  genvar i, j, k;
  generate
      for(i=0; i<KERNEL_HEIGHT; i++) begin
        for (j=0; j<KERNEL_WIDTH; j++) begin
          for (k=0; k<INPUT_DEPTH; k++) begin
            fpu multiplier (clk, weights[i*KERNEL_WIDTH*INPUT_DEPTH + j * INPUT_DEPTH + k], input_window[i*KERNEL_WIDTH*INPUT_DEPTH + j * INPUT_DEPTH + k], 2'b11, mul_array[i*KERNEL_WIDTH*INPUT_DEPTH + j * INPUT_DEPTH + k]);
          end
        end
      end
  endgenerate
  
  wire [VALUE_BITS-1:0] adder_wires [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH - 1:0];
  assign adder_wires[0] =  mul_array[0];
  wire [VALUE_BITS-1:0] array_sum;
  assign array_sum = adder_wires[KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH - 1];
  fpu bias_adder (clk, array_sum, bias, 2'b0, result);
  
  genvar l;
  generate
    for(l=1; l<KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH; l++) begin
      fpu adder (clk, mul_array[l], adder_wires[l-1], 2'b0, adder_wires[l]);
    end
  endgenerate
endmodule
  
module ReLU #(VALUE_BITS=32)
    (
    inout [VALUE_BITS-1:0] value
    );
    
    assign value = (value < 0) ? 0 : value;
    
endmodule
  
  
module ConvLayer #(parameter KERNEL_WIDTH, KERNEL_HEIGHT, FILTERS_NUMBER,
                             INPUT_WIDTH, INPUT_HEIGHT, INPUT_DEPTH,
                             VALUE_BITS=32)
 (
  input [VALUE_BITS-1:0] input_data [INPUT_HEIGHT * INPUT_WIDTH * INPUT_DEPTH-1:0],
  input [VALUE_BITS-1:0] weights [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH * FILTERS_NUMBER - 1:0] ,
  input [VALUE_BITS-1:0] biases [FILTERS_NUMBER - 1:0],
  input clk,
  output [VALUE_BITS-1:0] output_data [`OUTPUT_SIZE(INPUT_HEIGHT, KERNEL_HEIGHT) * `OUTPUT_SIZE(INPUT_WIDTH, KERNEL_WIDTH)* FILTERS_NUMBER - 1:0]

 );  

  genvar h, w, f;
  genvar t, m, n;
  generate
    for (h=0; h < `OUTPUT_SIZE(INPUT_HEIGHT, KERNEL_HEIGHT); h++) begin
      for (w=0; w < `OUTPUT_SIZE(INPUT_WIDTH, KERNEL_WIDTH); w++) begin
        for (f=0; f < FILTERS_NUMBER; f++) begin
          
            wire [VALUE_BITS-1:0] filter_weights [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH-1:0];
            wire [VALUE_BITS-1:0] input_window [KERNEL_HEIGHT * KERNEL_WIDTH * INPUT_DEPTH-1:0];
              
            
              for(t=0; t<KERNEL_HEIGHT; t++) begin
                for (m=0; m<KERNEL_WIDTH; m++) begin
                  for (n=0; n<INPUT_DEPTH; n++) begin
                    assign input_window[t*KERNEL_WIDTH*INPUT_DEPTH + m * INPUT_DEPTH + n] = input_data[(h+t)* INPUT_WIDTH*INPUT_DEPTH +(w+m)*INPUT_DEPTH + n];
                    assign filter_weights[t*KERNEL_WIDTH*INPUT_DEPTH + m * INPUT_DEPTH + n] = weights[t*KERNEL_WIDTH*INPUT_DEPTH*FILTERS_NUMBER + m*INPUT_DEPTH*FILTERS_NUMBER + n*FILTERS_NUMBER + f];
                  end
                end
              end
              
              Filter #(.KERNEL_HEIGHT(KERNEL_HEIGHT),.KERNEL_WIDTH(KERNEL_WIDTH),.INPUT_DEPTH(INPUT_DEPTH)) filter (filter_weights, biases[f], input_window, clk, output_data[h*`OUTPUT_SIZE(INPUT_WIDTH, KERNEL_WIDTH)* FILTERS_NUMBER+ w* FILTERS_NUMBER + f]);
              ReLU relu(output_data[h*`OUTPUT_SIZE(INPUT_WIDTH, KERNEL_WIDTH)* FILTERS_NUMBER+ w* FILTERS_NUMBER + f]);
          end
        end
      end
  endgenerate

endmodule

