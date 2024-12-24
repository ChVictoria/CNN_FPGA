`include "NN.sv"
`define INPUT_HEIGHT 28
`define INPUT_WIDTH 28
`define INPUT_DEPTH 3
`define VALUE_BITS 32

module tb;
  reg [`VALUE_BITS-1:0] input_image [`INPUT_HEIGHT * `INPUT_WIDTH * `INPUT_DEPTH-1:0];
  wire [`VALUE_BITS-1:0] prediction;
  
  reg clk;
  
  reg [`VALUE_BITS-1:0] conv2d_1_weights [54:0];
  reg [`VALUE_BITS-1:0] conv2d_1_biases [1:0];
 
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  int img_num = 0;
  string file;
  int fp;
  initial begin
    fp = $fopen("weights_conv2D0.csv", "r");
    for(int i=0; i<54; i++) begin
      $fscanf(fp,"%f", conv2d_1_weights[i]);
    end
    fp = $fopen("biases_conv2D0.csv", "r");
    for(int i=0; i<2; i++) begin
      $fscanf(fp,"%f", conv2d_1_biases[i]);
    end
    
  forever begin
    file = $sformatf("test_data/%0d.csv", img_num);
    fp = $fopen(file, "r");
    for(int i=0; i<`INPUT_HEIGHT * `INPUT_WIDTH * `INPUT_DEPTH; i++) begin
      $fscanf(fp,"%f", input_image[i]);
    end
    $display($time, " Send image %d", img_num);
    @(prediction);
    $display($time, " Model prediction for image %d: %f", img_num, prediction);
  end
end
  
  NN #(.INPUT_HEIGHT(`INPUT_HEIGHT),
       .INPUT_WIDTH(`INPUT_WIDTH),
       .INPUT_DEPTH(`INPUT_DEPTH)) 
        my_nn
       (.input_image(input_image),
        .conv2d_1_weights(conv2d_1_weights),
        .conv2d_1_biases(conv2d_1_biases),
        .clk(clk),
        .prediction(prediction));
  
endmodule
  
