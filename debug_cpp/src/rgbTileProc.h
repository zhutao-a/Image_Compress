/* rgbTileProc.h
*  implementation of TILE COMPRESSION
*/
#ifndef _RGBTILEPROC_H_
#define _RGBTILEPROC_H_

void tileSetSize(int nTileWidth, int nTileHeight);

int argb2tile(const unsigned char *pClrBlk, unsigned char *pTile, int *pTileSize);

#endif
