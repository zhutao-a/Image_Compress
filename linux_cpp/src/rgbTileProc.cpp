/* rgbTileProc.cpp
*  implementation of TILE COMPRESSION
*/
#include <stdio.h>
#include <math.h>
#include <memory.h>
#include <assert.h>
#include "rgbTileProc.h"

#include "encoder.h"

static int g_nTileWidth = 0;
static int g_nTileHeight = 0;

void tileSetSize(int nTileWidth, int nTileHeight)
{
	g_nTileWidth = nTileWidth;
	g_nTileHeight = nTileHeight;
}

/* compress ARGB data to tile
*  param:
*    pClrBlk      -- IN, pixel's ARGB data
*    pTile        -- OUT, tile data
*    pTileSize    -- OUT, tile's bytes
*  return:
*    0  -- succeed
*   -1  -- failed
*/
int argb2tile(const unsigned char* pClrBlk, unsigned char* pTile, int* pTileSize,int tileRowIndex,int tileColumnIndex)
{
	assert(g_nTileWidth > 0 && g_nTileHeight > 0);
	//*pTileSize = g_nTileWidth * g_nTileHeight * 4;
	//memcpy(pTile, pClrBlk, *pTileSize);
	unsigned char* p;
	p = Encode(pClrBlk, g_nTileWidth, g_nTileHeight, pTileSize, 1, tileRowIndex,tileColumnIndex);
	memcpy(pTile,p,*pTileSize);
	free(p);
	return 0;
}

/* decompress tile data to ARGB
*  param:
*    pTile        -- IN, tile data
*    pTileSize    -- IN, tile's bytes
*    pClrBlk      -- OUT, pixel's ARGB data
*  return:
*    0  -- succeed
*   -1  -- failed
*/
int tile2argb(const unsigned char* pTile, int nTileSize, unsigned char* pClrBlk)
{
	//memcpy(pClrBlk, pTile, nTileSize);
	unsigned char* p;
	p = Decode(pTile,g_nTileWidth,g_nTileHeight,nTileSize,1);
	memcpy(pClrBlk,p,g_nTileWidth*g_nTileHeight*4);
	free(p);
	return 0;
}
