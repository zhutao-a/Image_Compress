/* compress.h
 *
*/

#ifndef _ENCODER_H_  
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
	int16_t B[365];
	int16_t C[365];
	uint16_t N[367];
	uint16_t Nn[367];							
	int16_t D[3];
	int8_t Q[3];
	uint8_t Ra;
	uint8_t Rb;
	uint8_t Rc;
	uint8_t Rd;
	uint8_t Ix;
	int16_t Px;
	uint8_t RUNval;
	uint16_t RUNcnt;
	uint8_t RItype;
	int8_t SIGN;
	uint16_t TEMP;
	int16_t Errval;
	uint16_t EMErrval;
	uint16_t MErrval;
	uint16_t q;
	uint8_t k;
	uint8_t map;
	uint8_t EOline[nrchannel];		
	point p[nrchannel];
	int8_t MAX_C;
	int8_t MIN_C;
	uint8_t RESET;	
	uint8_t T1;
	uint8_t T2;
	uint8_t T3;		
	uint8_t coding_mode;		
} 
encoder;

uint8_t* Encode(const uint8_t* data, uint16_t w, uint16_t h, int* size, int coding_mode,int tileRowIndex,int tileColumnIndex);


typedef struct DECODER
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
	int16_t B[365];
	int16_t C[365];
	uint16_t N[367];
	uint16_t Nn[367];							
	int16_t D[3];
	int8_t Q[3];	
	uint8_t Ra;
	uint8_t Rb;
	uint8_t Rc;
	uint8_t Rd;
	int16_t Rx;
	int16_t Px;
	uint8_t RItype;	
	int8_t SIGN;
	uint16_t TEMP;
	int16_t Errval;
	uint16_t EMErrval;
	uint16_t MErrval;	
	uint16_t q;
	uint8_t k;
	uint8_t map;	
	point p[nrchannel];
	int8_t MAX_C;
	int8_t MIN_C;
	uint8_t RESET;	
	uint8_t T1;
	uint8_t T2;
	uint8_t T3;			
	uint8_t coding_mode;
} 
decoder;




uint8_t* Decode(const uint8_t* data, uint16_t w, uint16_t h, int size, int coding_mode);


#endif

