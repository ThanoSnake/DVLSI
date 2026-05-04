#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#define MY_IP_ADDR XPAR_PART3_0_S00_AXI_BASEADDR

const u32 x_values[] ={107, 90, 224, 153, 54, 132, 130,
					78, 48, 145, 151, 222, 164, 168,
					155, 209, 160, 243, 158, 102, 0,
					0, 0, 0, 0, 0, 0}; //28 elements

int main() {
	u32 A, B;
	u32 validout_mask = (1 << 19);
	u32 y_mask = 0x0007FFFF;

	A = (1 << 9); //reset fir
	Xil_Out32(MY_IP_ADDR + 0x00, A);

	usleep(1);
	A = 0x00000000; //stop reset
	Xil_Out32(MY_IP_ADDR + 0x00, A);

	for (int i=0; i<27; i++){
		A = x_values[i] | (1 << 8); //validin enabled
		Xil_Out32(MY_IP_ADDR + 0x00, A);
		Xil_Out32(MY_IP_ADDR + 0x00, 0x00000000); //validin disabled

		while(1) {
			B = Xil_In32(MY_IP_ADDR + 0x04);
			if (B & validout_mask) {
				xil_printf("y[%d]: %lu\r\n", i, B&y_mask);
				break;
			}
		}
	}
	xil_printf("Convolution just ended\r\n");
}
