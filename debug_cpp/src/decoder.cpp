/* JPEG_LS.cpp
 * implementation of JPEG LS compression and decompression
*/
#include "encoder.h"

static decoder dec;
static uint8_t current_read_byte;
static int8_t read_position;
static int32_t byte_count;
static uint8_t current_component;
static int tilesizes;
static int num = 0;

static void Initializations(const uint8_t* data, uint16_t w, uint16_t h, int size, int coding_mode)
{
	uint32_t i = 0;
	dec.coding_mode = coding_mode;	
	dec.w = w;
	dec.h = h;
	// dec.bitstream = (uint8_t*)calloc(size, sizeof(uint8_t));
	memcpy(dec.bitstream, data, size);
	// dec.extended_data = (uint8_t*)calloc((dec.w + 2) * (dec.h + 1) * nrchannel, sizeof(uint8_t));
	current_read_byte = 0;
	read_position = -1;
	byte_count = -1;
	current_component = 0;
	dec.RANGE = 256;
	dec.MAXVAL = 255;
	dec.qbpp = 8;
	dec.bpp = 8;
	dec.LIMIT = 32; 
	for(i = 0; i < 365; i++)
	{
    	dec.A[i] = 4;
      	dec.N[i] = 1;
      	dec.B[i] = 0;
      	dec.C[i] = 0;
      	dec.Nn[i] = 0;
	}	
	dec.A[365] = 4;
    dec.A[366] = 4;
    dec.N[365] = 1;
    dec.N[366] = 1;
    dec.Nn[365] = 0;
    dec.Nn[366] = 0;

	for(i = 0; i < 3; i++)
	{
		dec.D[i] = 0;
		dec.Q[i] = 0;
	}
	for(i = 0; i < nrchannel; i++)
	{
	   	dec.p[i].x = 0;
    	dec.p[i].y = 1;	
	}
    dec.Ra = 0;
	dec.Rb = 0;
	dec.Rc = 0;
	dec.Rd = 0;
	dec.Px = 0;
	dec.Rx = 0;
	dec.RItype = 0;  	
	dec.SIGN = 0;
	dec.TEMP = 0;
	dec.Errval = 0;
	dec.EMErrval = 0;
	dec.MErrval = 0;
	dec.q = 0;
	dec.k = 0;
	dec.map = 0;	
    dec.RESET = 64;
    dec.T1 = 3;
    dec.T2 = 7;
    dec.T3 = 21;    
    dec.MAX_C = 127;
    dec.MIN_C = -128;
}

// static void Close()
// {	
// 	free(dec.bitstream);
// 	free(dec.extended_data);
// }

static void GetNextSample()
{
	if (dec.p[current_component].x == dec.w)
	{
		current_component++;			
		if (current_component == nrchannel)
		{
			current_component = 0;
		}
	}		
	if(dec.p[current_component].x == dec.w)
	{
    	dec.p[current_component].y++;
    	dec.p[current_component].x = 1;
	}
 	else
 	{
 		dec.p[current_component].x++;
	}
	dec.Rb = dec.extended_data[((dec.p[current_component].y - 1) * (dec.w + 2) * nrchannel) + (dec.p[current_component].x * nrchannel) + current_component];
	if(dec.p[current_component].x == 1 && dec.p[current_component].y > 1)
	{
	    dec.Ra = dec.Rb;
	    dec.Rc = dec.extended_data[((dec.p[current_component].y - 2) * (dec.w + 2) * nrchannel) + (dec.p[current_component].x * nrchannel) + current_component];
	    if (dec.w == 1)
	    {
	    	dec.Rd = dec.Rb;
		}
		else
		{
			dec.Rd = dec.extended_data[((dec.p[current_component].y - 1) * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x + 1) * nrchannel) + current_component];
		}   
	}
 	else if(dec.p[current_component].x == dec.w)
 	{
 		dec.Ra = dec.extended_data[(dec.p[current_component].y * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x - 1) * nrchannel) + current_component];
 		dec.Rc = dec.extended_data[((dec.p[current_component].y - 1) * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x - 1) * nrchannel) + current_component];
	    dec.Rd = dec.Rb;
	}
 	else
	{ 
	 	dec.Ra = dec.extended_data[(dec.p[current_component].y * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x - 1) * nrchannel) + current_component];
	 	dec.Rc = dec.extended_data[((dec.p[current_component].y - 1) * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x - 1) * nrchannel) + current_component];
	 	dec.Rd = dec.extended_data[((dec.p[current_component].y - 1) * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x + 1) * nrchannel) + current_component];
	}
}

static int ContextModeling()
{
    dec.D[0] = dec.Rd - dec.Rb;
    dec.D[1] = dec.Rb - dec.Rc;
    dec.D[2] = dec.Rc - dec.Ra;
 	if (dec.D[0] == 0 && dec.D[1] == 0 && dec.D[2] == 0)
 	{
  		return 1;
	}
	else
	{			
  		return 0;
	}
}

static uint8_t GetFromBitStream()
{
  	uint8_t bit_set_mask[] = 
	{	
		0x01, 0x02, 0x04, 0x08,	0x10, 0x20, 0x40, 0x80
	};
  	if (read_position < 0)
    { 	
		byte_count = byte_count + 1;	
      	current_read_byte = dec.bitstream[byte_count];	    
    	if(dec.bitstream[byte_count - 1] == 255)
      	{
    		read_position = 7;
	  	}        
      	else
      	{
      		read_position = 7;	
		}      
    }
  	if (current_read_byte & bit_set_mask[read_position--])
	{
    	return(1);
    }
  	return(0);
}

static uint16_t GolombDecoding(uint8_t l, uint8_t limit)
{
	uint16_t val1 = 0;
 	uint16_t val2 = 0;
 	uint8_t val3 = 0;
 	uint8_t i = 0;
  	val3 = limit - dec.qbpp - 1;
 	while(GetFromBitStream() != 1)
 	{
 		val1 += 1;
	}
   	if(val1 < val3)
	{
   		val2 = val1 << l;
   		for(i = 1; i <= l; i++)
   		{
   			val2 += (GetFromBitStream() << (l - i)); 
		}     		
 	}
 	else 
	{
    	for(i = 1; i <= dec.qbpp; i++)
    	{
    		val2 += (GetFromBitStream() << (dec.qbpp - i));
		}     		
    	val2 += 1;
 	}
 	if (val2 == dec.RANGE)
 	{
 		return dec.RANGE;
	} 		
 	else
 	{
 		return (uint8_t)val2;		
	} 		
}

static void RunModeProcessing()
{
	uint8_t R = 0;
	uint16_t cnt = 0;
	uint16_t i = 0;
	uint8_t run_flag = 0;
	do
	{
		cnt = GolombDecoding(2, dec.LIMIT);
		for(i = 0; i < cnt; i++)
		{
			dec.extended_data[(dec.p[current_component].y * (dec.w + 2) * nrchannel) + ((dec.p[current_component].x + i) * nrchannel) + current_component] = dec.Ra;	
		}
		dec.p[current_component].x += cnt;
	} 
	while (cnt == dec.MAXVAL);
	if (dec.p[current_component].x > dec.w)
	{
		dec.p[current_component].x = dec.w;
		run_flag = 0;
	}
	else
	{
		run_flag = 1;
	}
	if (run_flag)
	{
		dec.p[current_component].x--;
		GetNextSample(); 
		if(dec.Ra == dec.Rb)
		{
			dec.RItype = 1;
		}
		else
		{    		
			dec.RItype = 0;
		}
		if (dec.RItype == 0)
		{			
			dec.TEMP = dec.A[365];
		}
		else
		{
			dec.TEMP = dec.A[366] + (dec.N[366] >> 1);
		}
		dec.q = dec.RItype + 365; 
		for(dec.k = 0; (dec.N[dec.q] << dec.k) < dec.TEMP; dec.k++);
		dec.EMErrval = GolombDecoding(dec.k, dec.LIMIT);
		if(dec.EMErrval & 1)
		{
			if(dec.RItype == 1)	
			{
				dec.map = 0;	
			}
			else
			{
				dec.map = 1;	
			}
			dec.Errval = (dec.EMErrval + 1) >> 1;
	   	}
		else
		{
			if(dec.RItype == 1)
			{
	  			dec.Errval = (dec.EMErrval + 2) >> 1;
	  			dec.map = 1;
			}
			else
			{
	 	 		dec.Errval = dec.EMErrval >> 1;
	  			dec.map = 0;
	  		}
		}
		if((dec.k == 0) && (dec.map == 0) && (2 * dec.Nn[dec.q] < dec.N[dec.q]))
		{
			dec.Errval = -dec.Errval;
		}
		else if((dec.map == 1) && (2 * dec.Nn[dec.q] >= dec.N[dec.q]))
		{
			dec.Errval = -dec.Errval;
		}		    
		else if((dec.map == 1) && (dec.k != 0))
		{
			dec.Errval = -dec.Errval;
		}
		if(dec.Errval < 0)
		{  			
			dec.Nn[dec.q] = dec.Nn[dec.q] + 1;
		}
		if((dec.RItype == 0) && (dec.Rb < dec.Ra))
		{
			dec.Errval = -dec.Errval;
		}
		if(dec.RItype == 1)
		{
			dec.Rx = (dec.Errval + dec.Ra) % (dec.RANGE);
		}
		else
		{
			dec.Rx = (dec.Errval + dec.Rb) % (dec.RANGE);
		}
		if(dec.Rx < 0)
		{
			dec.Rx = dec.Rx + dec.RANGE;
		}    	
	  	else if (dec.Rx > dec.MAXVAL)
	  	{
	  		dec.Rx = dec.Rx - dec.RANGE;
		}
	  	if(dec.Rx < 0)
	  	{
	  		dec.Rx = 0;
		}    	
	  	else if(dec.Rx > dec.MAXVAL)
	  	{
	  		dec.Rx = dec.MAXVAL;	
		}	
		dec.extended_data[(dec.p[current_component].y * (dec.w + 2) * nrchannel) + (dec.p[current_component].x * nrchannel) + current_component] = (uint8_t)dec.Rx;		
	 	dec.A[dec.q] = dec.A[dec.q] + ((dec.EMErrval + 1 - dec.RItype) >> 1);
		if(dec.N[dec.q] == dec.RESET)
		{
	   		dec.A[dec.q] = dec.A[dec.q] >> 1;
	   		dec.N[dec.q] = dec.N[dec.q] >> 1;
	   		dec.Nn[dec.q] = dec.Nn[dec.q] >> 1;
		}
		dec.N[dec.q] = dec.N[dec.q] + 1;
	}
}

static void Prediction()
{
	uint8_t i = 0;
	for(i = 0; i < 3; i++)
	{
		if(dec.D[i] <= -dec.T3)
		{
			dec.Q[i] = -4;	
		} 
		else if(dec.D[i] <= -dec.T2) 
		{
			dec.Q[i] = -3;	
		}
		else if(dec.D[i] <= -dec.T1) 
		{
			dec.Q[i] = -2;	
		}
		else if(dec.D[i] < -0 )
		{
			dec.Q[i] = -1;	
		} 
		else if(dec.D[i] <= 0) 
		{
			dec.Q[i] = 0;	
		}
		else if(dec.D[i] < dec.T1)
		{
			dec.Q[i] = 1;	
		} 
		else if(dec.D[i] < dec.T2) 
		{
			dec.Q[i] = 2;	
		}
		else if(dec.D[i] < dec.T3)
		{
			dec.Q[i] = 3;
		} 
		else
		{
			dec.Q[i] = 4;
		} 
	}
	if(dec.Q[0] < 0)
	{
	    dec.Q[0] = -dec.Q[0];
	    dec.Q[1] = -dec.Q[1];
	    dec.Q[2] = -dec.Q[2];
	   	dec.SIGN = -1;
	}
  	else if(dec.Q[0] == 0)
	{
        if(dec.Q[1] < 0)
		{
            dec.Q[1] = -dec.Q[1];
        	dec.Q[2] = -dec.Q[2];
        	dec.SIGN = -1;
		}
        else if(dec.Q[1] == 0 && dec.Q[2] < 0)
		{
        	dec.Q[2] = -dec.Q[2];
            dec.SIGN = -1;
		}
        else
		{
			dec.SIGN = 1;	
		} 
	}
  	else 
	{
		dec.SIGN = 1;	
	}
	dec.q = 81 * dec.Q[0] + 9 * dec.Q[1] + dec.Q[2];
	if(dec.Rc >= MAX(dec.Ra, dec.Rb))
	{
		dec.Px = MIN(dec.Ra, dec.Rb);	
	}   		
 	else 
	{
   		if(dec.Rc <= MIN(dec.Ra, dec.Rb))
   		{   			
     		dec.Px = MAX(dec.Ra, dec.Rb);
		}
   		else
   		{   			
     		dec.Px = dec.Ra + dec.Rb - dec.Rc;
		}
  	}
  	if(dec.SIGN == 1)
  	{
  		dec.Px = dec.Px + dec.C[dec.q];	
	}   		
 	else
 	{
		dec.Px = dec.Px - dec.C[dec.q];
	}
 	if(dec.Px > dec.MAXVAL)
 	{
 		dec.Px = dec.MAXVAL;
	}   		
 	else if(dec.Px < 0)
 	{
 		dec.Px = 0;
	}	
}

static void PredictionErrorDecoding()
{
    for(dec.k = 0; (dec.N[dec.q] << dec.k) < dec.A[dec.q]; dec.k++);
	dec.MErrval = GolombDecoding(dec.k, dec.LIMIT);
    if((dec.k == 0) && (2 * dec.B[dec.q] <= -dec.N[dec.q])) 
	{
    	if((dec.MErrval & 1))
    	{
    		dec.Errval = (dec.MErrval - 1) >> 1;	
		}      
    	else
    	{
    		dec.Errval = -(dec.MErrval >> 1) - 1;
		}      
  	}
  	else
	{
    	if((dec.MErrval & 1))
   		{
    		dec.Errval = -((dec.MErrval + 1) >> 1);
		}      
    	else
    	{
    		dec.Errval = dec.MErrval >> 1;
		}
  	}
}

static void VariablesUpdate()
{	
  	dec.B[dec.q] = dec.B[dec.q] + dec.Errval;
	dec.A[dec.q] = dec.A[dec.q] + ABS(dec.Errval);
	if (dec.N[dec.q] == dec.RESET) 
	{
		dec.A[dec.q] = dec.A[dec.q] >> 1;
		if (dec.B[dec.q] >= 0)
		{
			dec.B[dec.q] = dec.B[dec.q] >> 1;
		}			
		else
		{
			dec.B[dec.q] = -((1 - dec.B[dec.q]) >> 1);
		}			
		dec.N[dec.q] = dec.N[dec.q] >> 1;
	}
	dec.N[dec.q] = dec.N[dec.q] + 1;
	if(dec.SIGN == -1)
	{
		dec.Errval = -dec.Errval;
	}
	dec.Rx = (dec.Errval + dec.Px) % (dec.RANGE);
	if(dec.Rx < 0)
	{
		dec.Rx = dec.Rx + dec.RANGE;
	}    	
  	else if (dec.Rx > dec.MAXVAL)
  	{
  		dec.Rx = dec.Rx - dec.RANGE;
	}
  	if(dec.Rx < 0)
  	{
  		dec.Rx = 0;
	}    	
  	else if(dec.Rx > dec.MAXVAL)
  	{
  		dec.Rx = dec.MAXVAL;	
	}	
	if(dec.B[dec.q] <= -dec.N[dec.q])
	{
  		dec.B[dec.q] = dec.B[dec.q] + dec.N[dec.q];
   		if(dec.C[dec.q] > dec.MIN_C)
   		{
   			dec.C[dec.q] = dec.C[dec.q] - 1;
		}     		
   		if(dec.B[dec.q] <= -dec.N[dec.q])
   		{   			
     		dec.B[dec.q] = -dec.N[dec.q] + 1;
		}
 	}
 	else if(dec.B[dec.q] > 0) 
	{
   		dec.B[dec.q] = dec.B[dec.q] - dec.N[dec.q];
   		if(dec.C[dec.q] < dec.MAX_C)
   		{
     		dec.C[dec.q] = dec.C[dec.q] + 1;
		}
   		if(dec.B[dec.q] > 0)
   		{   			
    		dec.B[dec.q] = 0;
		}
 	}
 	dec.extended_data[(dec.p[current_component].y * (dec.w + 2) * nrchannel) + (dec.p[current_component].x * nrchannel) + current_component] = dec.Rx;
}

static void RegularModeProcessing()
{
	Prediction();
	PredictionErrorDecoding();
	VariablesUpdate();
}

uint8_t* Decode(const uint8_t* data, uint16_t w, uint16_t h, int size, int coding_mode)
{	
	uint8_t* dout;
	uint32_t i = 0;
	uint32_t j = 0;
	uint8_t k = 0;
  	tilesizes = size;
	dout = (uint8_t*)calloc(nrchannel * w * h, sizeof(uint8_t));
	Initializations(data, w, h, size, coding_mode);
	for(;;)
	{
		if(dec.p[nrchannel-1].x == w && dec.p[nrchannel-1].y == h)
    	{    			    	
        	break;
		} 			
		GetNextSample();
		if (ContextModeling())
		{
			if (dec.coding_mode == 1)
			{
				RunModeProcessing();
			}
			else
			{
				RegularModeProcessing();
			}			
		}
		else
		{
			RegularModeProcessing();
		}	
	}
	for (k = 0; k < nrchannel; k++)
	{
		for (i = 0; i < h; i++)
		{
			for (j = 0; j < w; j++)
			{
				dout[(i * w * nrchannel) + (j * nrchannel) + k] = dec.extended_data[((i + 1) * (w + 2) * nrchannel) + ((j + 1) * nrchannel) + k];
			}
		}
	}
	// Close();	
	return dout;
}



