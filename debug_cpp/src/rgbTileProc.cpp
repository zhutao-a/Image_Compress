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

int argb2tile(const unsigned char* pClrBlk, unsigned char* pTile, int* pTileSize)
{
	assert(g_nTileWidth > 0 && g_nTileHeight > 0);
	//*pTileSize = g_nTileWidth * g_nTileHeight * 4;
	//memcpy(pTile, pClrBlk, *pTileSize);
	unsigned char* p;
	p = Encode(pClrBlk, g_nTileWidth, g_nTileHeight, pTileSize,1);
	memcpy(pTile,p,*pTileSize);
	free(p);
	return 0;
}

