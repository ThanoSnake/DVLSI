#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xaxidma.h"
#include "xtime_l.h"

#include "pixels.h" //Input pixels file

#define N 32
#define IMG_SIZE (N * N)

#define TX_DMA_ID                 XPAR_PS2PL_DMA_DEVICE_ID
#define TX_DMA_MM2S_LENGTH_ADDR  (XPAR_PS2PL_DMA_BASEADDR + 0x28) // Reports actual number of bytes transferred from PS->PL (use Xil_In32 for report)

#define RX_DMA_ID                 XPAR_PL2PS_DMA_DEVICE_ID
#define RX_DMA_S2MM_LENGTH_ADDR  (XPAR_PL2PS_DMA_BASEADDR + 0x58) // Reports actual number of bytes transferred from PL->PS (use Xil_In32 for report)

#define TX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x08000000) // 0 + 128MByte
#define RX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x10000000) // 0 + 256MByte
#define SW_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x12000000)

//DMA Structures
XAxiDma AxiDmaTx;
XAxiDma AxiDmaRx;

// Placeholder για την SW υλοποίηση (πρέπει να την συμπληρώσεις)
void debayer_sw(const uint8_t *input, uint32_t *output) {
    for (int i = 0; i < N; i++) {
        for (int j =0 ; j < N; j++) {

            uint8_t state1, state2;

            if (i % 2 == 0) state1 = 1;
            else state1 = 0;
            if (j % 2 == 0) state2 = 1;
            else state2 = 0;

            uint8_t P11, P12, P13;
            uint8_t P21, P22, P23; 
            uint8_t P31, P32, P33;

            uint16_t sum_vert, sum_hor, sum_cross, sum_diag;

            uint32_t red, green, blue;

            P11 = (i > 0 && j > 0) ? input[N*(i-1) + (j-1)] : 0;
            P12 = (i > 0) ? input[N*(i-1) + j] : 0;
            P13 = (i > 0 && j < (N-1)) ? input[N*(i-1) + (j+1)] : 0;
            P21 = (j > 0) ? input[N*i + (j-1)] : 0;
            P22 = input[N*i + j];
            P23 = (j < (N-1)) ? input[N*i + (j+1)] : 0;
            P31 = (i < (N-1) && j > 0) ? input[N*(i+1) + (j-1)] : 0;
            P32 = (i < (N-1)) ? input[N*(i+1) + j] : 0;
            P33 = (i < (N-1) && j < (N-1)) ? input[N*(i+1) + (j+1)] : 0;

            sum_vert = P12 + P32;
            sum_hor = P21 + P23;

            sum_cross = P12 + P21 + P23 + P32;
            sum_diag = P11 + P13 + P31 + P33;

            if (state1 == 1 && state2 == 1) {
                red = sum_vert >> 1;
                green = P22;
                blue = sum_hor >> 1;
            }
            
            else if (state1 == 0 && state2 == 0) {
                red = sum_hor >> 1;
                green = P22;
                blue = sum_vert >> 1;
            }

            else if (state1 == 1 && state2 == 0) {
                red = sum_diag >> 2;
                green = sum_cross >> 2;
                blue = P22;
            }

            else {
                red = P22;
                green = sum_cross >> 2;
                blue = sum_diag >> 2;
            }

            output[N*i + j] = (red << 16 | green << 8 | blue);
        }
    }
}


/* User application global variables & defines */

int main()
{
	Xil_DCacheDisable();

	XTime preExecCyclesFPGA = 0;
	XTime postExecCyclesFPGA = 0;
	XTime preExecCyclesSW = 0;
	XTime postExecCyclesSW = 0;

    int Status;

	print("HELLO 1\r\n");
	// User application local variables

	init_platform();

    // Step 1: Initialize TX-DMA Device (PS->PL)
    // Step 2: Initialize RX-DMA Device (PL->PS)
    XAxiDma_Config *CfgPtr;

    // Initialize TX DMA
    CfgPtr = XAxiDma_LookupConfig(TX_DMA_ID);
    Status = XAxiDma_CfgInitialize(&AxiDmaTx, CfgPtr);
    if (Status != XST_SUCCESS) { printf("TX DMA Init Failed\n"); return XST_FAILURE; }

    // Initialize RX DMA
    CfgPtr = XAxiDma_LookupConfig(RX_DMA_ID);
    Status = XAxiDma_CfgInitialize(&AxiDmaRx, CfgPtr);
    if (Status != XST_SUCCESS) { printf("RX DMA Init Failed\n"); return XST_FAILURE; }


    //prepare input pixels. load pixels to TX BUFFER from pixels.h 
    uint8_t *tx_ptr = (uint8_t *)TX_BUFFER;
    for (int i = 0; i < IMG_SIZE; i++) {
        tx_ptr[i] = raw_pixels[i];
    }


    XTime_GetTime(&preExecCyclesFPGA);
    // Step 3 : Perform FPGA processing
    //      3a: Setup RX-DMA transaction
    Status = XAxiDma_SimpleTransfer(&AxiDmaRx, (UINTPTR)RX_BUFFER, (IMG_SIZE * 4), XAXIDMA_DEVICE_TO_DMA);
    //      3b: Setup TX transaction
    Status = XAxiDma_SimpleTransfer(&AxiDmaTx, (UINTPTR)TX_BUFFER, IMG_SIZE, XAXIDMA_DMA_TO_DEVICE);
    //      3c: Wait for TX-DMA & RX-DMA to finish
    while (XAxiDma_Busy(&AxiDmaTx, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&AxiDmaRx, XAXIDMA_DEVICE_TO_DMA));
    XTime_GetTime(&postExecCyclesFPGA);

    XTime_GetTime(&preExecCyclesSW);
    // Step 5: Perform SW processing
    debayer_sw(raw_pixels, (uint32_t *)SW_BUFFER);
    XTime_GetTime(&postExecCyclesSW);

    // Step 6: Compare FPGA and SW results
    //     6a: Report total percentage error
    int errors = 0;
    uint32_t *fpga_res = (uint32_t *)RX_BUFFER;
    uint32_t *sw_res = (uint32_t *)SW_BUFFER;
    
    for(int i = 0; i < IMG_SIZE; i++) {
        if (fpga_res[i] != sw_res[i]) {
            errors++; 
        }
    }
    //     6b: Report FPGA execution time in cycles (use preExecCyclesFPGA and postExecCyclesFPGA)
    //     6c: Report SW execution time in cycles (use preExecCyclesSW and postExecCyclesSW)
    //     6d: Report speedup (SW_execution_time / FPGA_exection_time)
    printf("\n--- Performance Stats ---\n");
    printf("FPGA Cycles: %llu\n", (postExecCyclesFPGA - preExecCyclesFPGA));
    printf("SW Cycles:   %llu\n", (postExecCyclesSW - preExecCyclesSW));
    printf("Speedup:     %.2f x\n", (double)(postExecCyclesSW - preExecCyclesSW) / (postExecCyclesFPGA - preExecCyclesFPGA));
    printf("Validation Errors: %d\n", errors);

    cleanup_platform();
    return 0;
}
