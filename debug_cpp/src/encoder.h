/* compress.h
 *
*/

#ifndef _ENCODER_H__  
#define _ENCODER_H_

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX(x,y) ((x > y) ? x:y)
#define MIN(x,y) ((x > y) ? y:x)
#define ABS(x) ((x < 0) ? -x:x)	
#define nrchannel 4

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

//typedef char int8_t;
//typedef short int16_t;
//typedef int int32_t;

typedef struct POINT
{
	uint16_t x;
	uint16_t y;
}
point;

typedef struct ENCODER
{				
	uint8_t bitstream[100*100*4];		
	uint8_t extended_data[100*100*4];
	uint16_t w;
	uint16_t h;
	uint16_t RANGE;
	uint8_t MAXVAL;
	uint8_t qbpp;
	uint8_t bpp;
	uint8_t LIMIT;
	uint16_t A[367];
	int   B[365];
	int C[365];
	uint16_t N[367];
	uint16_t Nn[367];							
	int D[3];
	int Q[3];
	uint8_t Ra;
	uint8_t Rb;
	uint8_t Rc;
	uint8_t Rd;
	uint8_t Ix;
	int Px;
	uint8_t RUNval;
	uint16_t RUNcnt;
	uint8_t RItype;
	int SIGN;
	uint16_t TEMP;
	int Errval;
	uint16_t EMErrval;
	uint16_t MErrval;
	uint16_t q;
	uint8_t k;
	uint8_t map;
	uint8_t EOline[nrchannel];		
	point p[nrchannel];
	int MAX_C;
	int MIN_C;
	uint8_t RESET;	
	uint8_t T1;
	uint8_t T2;
	uint8_t T3;		
	uint8_t coding_mode;		
} 
encoder;

uint8_t* Encode(const uint8_t* data, uint16_t w, uint16_t h, int* size, int coding_mode);

#endif

