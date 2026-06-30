module response_arbiter (
    input  wire        clk,
    input  wire        rst,        
    input  wire        rx_done,
    input  wire [7:0]  rx_data,

    input  wire        tx_done,      
    output reg         tx_start,  
    output reg  [7:0]  tx_data,      

    input  wire        adc_done,     
    input  wire [11:0] adc_value,    
    output reg         adc_start     
);

    reg [11:0] resp_adc_val_latched;
    wire [3:0] resp_d_thou = (resp_adc_val_latched / 1000) % 10;
    wire [3:0] resp_d_hund = (resp_adc_val_latched / 100)  % 10;
    wire [3:0] resp_d_tens = (resp_adc_val_latched / 10)   % 10;
    wire [3:0] resp_d_ones =  resp_adc_val_latched         % 10;

    localparam RESP_IDLE      = 3'd0,
               RESP_ECHO_WAIT = 3'd1,
               RESP_ADC_WAIT  = 3'd2,
               RESP_ADC_SEND  = 3'd3,
               RESP_ADC_WAIT2 = 3'd4;

    reg [2:0] resp_state;
    reg [2:0] resp_msg_idx; // 0..5 -> thousands,hundreds,tens,ones,CR,LF

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            resp_state           <= RESP_IDLE;
            tx_start             <= 1'b0;
            tx_data              <= 8'h00;
            adc_start            <= 1'b0;
            resp_msg_idx         <= 0;
            resp_adc_val_latched <= 12'h000;
        end else begin
            tx_start  <= 1'b0;
            adc_start <= 1'b0;

            case (resp_state)
                RESP_IDLE: begin
                    if (rx_done) begin
                        if (rx_data == "S" || rx_data == "s") begin
                            adc_start  <= 1'b1;
                            resp_state <= RESP_ADC_WAIT;
                        end else begin
                            tx_data    <= rx_data;
                            tx_start   <= 1'b1;
                            resp_state <= RESP_ECHO_WAIT;
                        end
                    end
                end
                RESP_ECHO_WAIT: begin
                    if (tx_done)
                        resp_state <= RESP_IDLE;
                end
                RESP_ADC_WAIT: begin
                    if (adc_done) begin
                        resp_adc_val_latched <= adc_value;
                        resp_msg_idx         <= 0;
                        resp_state           <= RESP_ADC_SEND;
                    end
                end
                RESP_ADC_SEND: begin
                    case (resp_msg_idx)
                        3'd0: tx_data <= 8'h30 + resp_d_thou;
                        3'd1: tx_data <= 8'h30 + resp_d_hund;
                        3'd2: tx_data <= 8'h30 + resp_d_tens;
                        3'd3: tx_data <= 8'h30 + resp_d_ones;
                        3'd4: tx_data <= 8'h0D; // CR
                        default: tx_data <= 8'h0A; // LF
                    endcase
                    tx_start   <= 1'b1;
                    resp_state <= RESP_ADC_WAIT2;
                end
                RESP_ADC_WAIT2: begin
                    if (tx_done) begin
                        if (resp_msg_idx == 3'd5) begin
                            resp_state <= RESP_IDLE;
                        end else begin
                            resp_msg_idx <= resp_msg_idx + 1;
                            resp_state   <= RESP_ADC_SEND;
                        end
                    end
                end
                default: resp_state <= RESP_IDLE;
            endcase
        end
    end

endmodule

