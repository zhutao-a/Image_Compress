/* Compress and Decompress image data
*/
#include <cstring>
#include <iostream>
#include <fstream>
#include <math.h>
#include "defines.h"
#include "rgbTileProc.h"

#define APP_VERSION     "1.0.0"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


typedef struct _TileCompressionInfo {
    int tilePosition;
    int tileSize;
} TileCompressionInfo;

int main() {
    int      ret        = ERROR_OK;
    int      width      = 2496, height = 1600, nrChannels = 4;
    unsigned char *data = (unsigned char *)malloc(width*height*nrChannels*sizeof(unsigned char));
    
    FILE* fp = fopen("./res/sdk_data.v", "r");
    fread(data, sizeof(unsigned char), width * height * nrChannels * sizeof(unsigned char), fp);  // + (H-1-i) * W * NRCHANNELS
    fclose(fp);


    const int TILE_WIDTH = 8;
    const int TILE_HEIGHT = 8;
    int numRows = height / TILE_HEIGHT;
    int numColumns = width / TILE_WIDTH;
    const int BYTES_PER_PIXEL = 4;
    int rowStride = width * BYTES_PER_PIXEL; // 4 bytes per pixel
    unsigned char pARGB[TILE_WIDTH * TILE_HEIGHT * BYTES_PER_PIXEL] = { 0u };
    unsigned char pCompressed[TILE_WIDTH * TILE_HEIGHT * BYTES_PER_PIXEL] = { 0u };

    tileSetSize(TILE_WIDTH, TILE_HEIGHT);

    unsigned char * pCompressionBuffer = new unsigned char [numRows * numColumns * TILE_WIDTH * TILE_HEIGHT * BYTES_PER_PIXEL];
    if (NULL == pCompressionBuffer) {
        return ERROR_CUSTOM;
    }
    TileCompressionInfo *pTCInfos = new TileCompressionInfo [numRows * numColumns];
    if (NULL == pTCInfos) {
        delete[] pCompressionBuffer;
        return ERROR_CUSTOM;
    }

    int* tile_bytecount =(int*) malloc(numRows* numColumns*sizeof(int));

    int tileRowIndex = 0;
    int tileColumnIndex = 0;
    int totalBitsAfterCompression = 0;
    int posInCompressionBuffer = 0;
    unsigned char* pClr = NULL;
    for (tileRowIndex = 0; tileRowIndex < numRows; tileRowIndex++) {
        for (tileColumnIndex = 0; tileColumnIndex < numColumns; tileColumnIndex++) {
            int tileIndex = tileRowIndex * numColumns + tileColumnIndex;
            pClr = pARGB;
            for (int i = 0; i < TILE_HEIGHT; i++) {
                for (int j = 0; j < TILE_WIDTH; j++) {
                    int row = tileRowIndex * TILE_HEIGHT + i;
                    int col = tileColumnIndex * TILE_WIDTH + j;
                    int pixelDataOffset = rowStride * row + col * BYTES_PER_PIXEL;
                    pClr[0] = data[pixelDataOffset + 0]; // b
                    pClr[1] = data[pixelDataOffset + 1]; // g
                    pClr[2] = data[pixelDataOffset + 2]; // r
                    pClr[3] = data[pixelDataOffset + 3]; // a
                    pClr += 4;
                }
            }
            pTCInfos[tileIndex].tilePosition = posInCompressionBuffer;
            // compress
            argb2tile(pARGB, pCompressionBuffer + posInCompressionBuffer, &pTCInfos[tileIndex].tileSize,tileRowIndex,tileColumnIndex);
            posInCompressionBuffer += pTCInfos[tileIndex].tileSize;

            // if(tileRowIndex==156&&tileColumnIndex==235){
            //     for(int i=0;i<8;i++){
            //         for(int j=0;j<8;j++){
            //             printf("%02x",pARGB[i*8*4+j*4+3]);
            //             printf("%02x",pARGB[i*8*4+j*4+2]);
            //             printf("%02x",pARGB[i*8*4+j*4+1]);
            //             printf("%02x",pARGB[i*8*4+j*4+0]);
            //             printf("\t");
            //         }
            //         printf("\r\n");
            //     }
            //     printf("tile=%02x\r\n", pTCInfos[tileIndex].tileSize);
            // }


            tile_bytecount[tileRowIndex* numColumns+ tileColumnIndex] = pTCInfos[tileIndex].tileSize;
        }
    }
    std::cout << "compression ratio = " << (float)posInCompressionBuffer / (float)(width * height * BYTES_PER_PIXEL) * 100 << "%" << std::endl;

    FILE* fp1 = fopen("./res/data.v", "w");
    fwrite(data, sizeof(unsigned char), width*height*nrChannels, fp1);
    fclose(fp1);
    FILE* fp2 = fopen("./res/tile.v", "w");
    fwrite(tile_bytecount, sizeof(int), numRows * numColumns, fp2);
    fclose(fp2);



    printf("total byte=%d\r\n",posInCompressionBuffer);
    free(tile_bytecount);
    free(data);

    delete [] pCompressionBuffer;
    delete [] pTCInfos;
    return 0;
}
