//-------------------------------------------------ͷ�ļ�----------------------------------------------------------------------------
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"
#include "xscugic.h"

#include "ff.h"
#include "stdio.h"
#include "sleep.h"
//-------------------------------------------------�궨��----------------------------------------------------------------------------

#define NAME_LEN_MAX 		50
#define FILE_NUM_MAX 		100
#define DMA_DEV_ID			XPAR_AXIDMA_0_DEVICE_ID
//BD��������,�������ҵ�1λ256M,��2λ16M,��3λ1M,��4λ64K,��5λ1K
#define TX_BD_SPACE_BASE	0x02000000
#define TX_BD_SPACE_HIGH	0x02FFFFFF
#define RX_BD_SPACE_BASE	0x03000000
#define RX_BD_SPACE_HIGH	0x03FFFFFF
#define TX_BUFFER_BASE		0x10000000
#define RX_BUFFER_BASE		0x14000000
//�ж�
#define TX_INTR_ID          XPAR_FABRIC_AXIDMA_0_MM2S_INTROUT_VEC_ID
#define RX_INTR_ID          XPAR_FABRIC_AXIDMA_0_S2MM_INTROUT_VEC_ID
#define INTC_DEVICE_ID      XPAR_SCUGIC_SINGLE_DEVICE_ID
#define INTC				XScuGic
#define INTC_HANDLER		XScuGic_InterruptHandler
#define DELAY_TIMER_COUNT	100
//APB
//control_reg[0]�ж��Ǳ��뻹�ǽ���,1b
//control_reg[1]�жϱ��������������Ƿ�д��ɹ�,1b
//control_reg[13:2]Ϊ��������������,12b
//control_reg[22:14]Ϊtile_height,9b
//control_reg[31:23]Ϊtile_width,9b
#define APB_BASE_ADDR		XPAR_APB_REG_0_BASEADDR

//-------------------------------------------------ȫ�ֱ���----------------------------------------------------------------------------

const  char ROOT_PATH[] = "0:/samples";//SD�������ļ���Ŀ¼
const  int  NRCHANNELS = 4;
const  int  TILE_WIDTH = 8;
const  int  TILE_HEIGHT = 8;
const  int  COALESCING_COUNT = 1;

XAxiDma 		AxiDma;
XAxiDma_BdRing 	*TxRingPtr = XAxiDma_GetTxRing(&AxiDma);
XAxiDma_BdRing 	*RxRingPtr = XAxiDma_GetRxRing(&AxiDma);
XAxiDma_Bd 		*TxBdPtr;
XAxiDma_Bd 		*RxBdPtr;
static INTC Intc;
int	WIDTH;
int	HEIGHT;
volatile int TxDone = 0;
volatile int RxDone = 0;

//-------------------------------------------------��������----------------------------------------------------------------------------

static void TxIntrHandler();
static int 	SetupTxIntrSystem();
static void DisableTxIntrSystem();
static int  TxSetup();
static int  BdPerSendTile(int Buffer_Offset_Addr);
static int  SendTile(int Buffer_Offset_Addr);

static void RxIntrHandler();
static int 	SetupRxIntrSystem();
static void DisableRxIntrSystem();
static int  RxSetup();
static int 	BdPerReceiveTile(int Buffer_Offset_Addr,int byte_count);
static int  ReceiveTile(int Buffer_Offset_Addr,int byte_count);


static int  ScanFile(char File_Name[][NAME_LEN_MAX]);
static int  StbiLoad(char const* InFileName, int* Width, int* Height, char* DATA_BASE_ADDR);

//-------------------------------------------------main����----------------------------------------------------------------------------
int main(void)
{
	//����SD��
	FATFS fatfs;
	char sd_Path[] = "0:/";
	f_mount(&fatfs, sd_Path, 1);
	Xil_DCacheDisable();//���ݻ��岻ʹ��

	//ɨ���ļ�
	int FileCnt;
	char File_Name[FILE_NUM_MAX][NAME_LEN_MAX];
	FileCnt=ScanFile(File_Name);
	xil_printf("\r\n file count is %d\r\n",FileCnt);

	//��ȡ���ش���DDR
	StbiLoad(File_Name[0],&WIDTH,&HEIGHT, (char*)TX_BUFFER_BASE);//File_Name[0]->sample04,File_Name[23]->sample27
	xil_printf("WIDTH = %d, HEIGHT = %d\r\n",WIDTH,HEIGHT);

    int numRows = HEIGHT / TILE_HEIGHT;
    int numColumns = WIDTH / TILE_WIDTH;
    int TileCompleteState = 0;
    int TotalByteCount = 0;
    UINTPTR  TX_OFFEST_ADDR = 0;
    UINTPTR  RX_OFFEST_ADDR = 0;

	//APB����
	u32 wdata;
	wdata=(TILE_WIDTH<<23)+(TILE_HEIGHT<<14)+(0<<2)+(0<<1)+(1<<0);
	Xil_Out32(APB_BASE_ADDR,wdata);

	//AXI DMA����
	XAxiDma_Config *Config;
	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	XAxiDma_CfgInitialize(&AxiDma, Config);

	//Tx����
	TxSetup();
	SetupTxIntrSystem();
//	XAxiDma_BdRingAlloc(TxRingPtr, TILE_HEIGHT, &TxBdPtr);
	//Rx����
	RxSetup();
	SetupRxIntrSystem();
//	XAxiDma_BdRingAlloc(RxRingPtr, 1, &RxBdPtr);

	int tile_bytecount[numRows*numColumns];

    u32 rdata;
    u32 bytecount,wordcount;
    int tileRowIndex = 0;
    int tileColumnIndex = 0;
    //ֱ������Tile��ɱ���
    for (tileRowIndex = 0; tileRowIndex < numRows; tileRowIndex++) {
//    	xil_printf("tileRowIndex = %d\r\n",tileRowIndex);
        for (tileColumnIndex = 0; tileColumnIndex < numColumns; tileColumnIndex++) {
			//�ı���һ��Tile��ƫ�Ƶ�ַ
			RX_OFFEST_ADDR=RX_OFFEST_ADDR+bytecount;
			TX_OFFEST_ADDR=tileRowIndex*TILE_HEIGHT*WIDTH*NRCHANNELS+tileColumnIndex*TILE_WIDTH*NRCHANNELS;
        	//����һ��Tile����
//        	xil_printf("tileColumnIndex = %d\r\n",tileColumnIndex);
        	SendTile(TX_OFFEST_ADDR);
        	rdata=Xil_In32(APB_BASE_ADDR);
        	TileCompleteState=((rdata&0x00000002)>>1);
        	while(TileCompleteState==0){//�ȴ��������
            	rdata=Xil_In32(APB_BASE_ADDR);
            	TileCompleteState=((rdata&0x00000002)>>1);
        	}
        	bytecount=((rdata&0x00003ffc)>>2);
        	tile_bytecount[tileRowIndex*numColumns+tileColumnIndex]=bytecount;
//        	xil_printf("bytecount%d = %d\r\n",tileColumnIndex,bytecount);
        	if(bytecount&0x00000003){
        		wordcount=(bytecount>>2)+1;
        	}
        	else{
        		wordcount=(bytecount>>2);
        	}
        	TotalByteCount=TotalByteCount+bytecount;
			wdata=(TILE_WIDTH<<23)+(TILE_HEIGHT<<14)+(0<<2)+(0<<1)+(1<<0);
			Xil_Out32(APB_BASE_ADDR,wdata);
        	//����һ��Tile����
			ReceiveTile(RX_OFFEST_ADDR,wordcount*4);
			//�ȴ��������
			while(TxDone==0||RxDone==0){}
			TxDone=0;
			RxDone=0;
        }
    }


    UINT bw;
    FIL pfile1,pfile2;
    FRESULT status;
    status=f_open(&pfile1,"0:/sdk_data.v",FA_WRITE| FA_CREATE_ALWAYS);
    if (status != FR_OK){
        printf("open fail\n");
        return 1;
    }
    else{
    	f_write(&pfile1, (unsigned char*)TX_BUFFER_BASE, WIDTH*HEIGHT*NRCHANNELS, &bw);
    	f_close(&pfile1);
    }
    status=f_open(&pfile2,"0:/sdk_tile.v",FA_WRITE| FA_CREATE_ALWAYS);
    if (status != FR_OK){
        printf("open fail\n");
        return 1;
    }
    else{
        f_write(&pfile2, (int*)tile_bytecount, numRows*numColumns*sizeof(int), &bw);
        f_close(&pfile2);
    }


//    for(int i=0;i<8;i++){
//    	for(int j=0;j<8;j++){
//    		xil_printf("%02x",Xil_In8(TX_BUFFER_BASE+123*8*4+i*WIDTH*4+j*4+0));
//    		xil_printf("%02x",Xil_In8(TX_BUFFER_BASE+123*8*4+i*WIDTH*4+j*4+1));
//    		xil_printf("%02x",Xil_In8(TX_BUFFER_BASE+123*8*4+i*WIDTH*4+j*4+2));
//    		xil_printf("%02x",Xil_In8(TX_BUFFER_BASE+123*8*4+i*WIDTH*4+j*4+3));
//    		xil_printf("\t");
//    	}
//    	xil_printf("\n");
//    }

    xil_printf("TotalByteCount = %d\r\n",TotalByteCount);

    printf("compression ratio = %.4f%%\r\n",(float)(100*TotalByteCount)/(float)(HEIGHT*WIDTH*NRCHANNELS));
	DisableTxIntrSystem();
	DisableRxIntrSystem();

	return 0;
}

//-------------------------------------------------��������----------------------------------------------------------------------------

//Tx�жϷ�����
static void TxIntrHandler()
{
    u32 IrqStatus;
    IrqStatus = XAxiDma_IntrGetIrq(&AxiDma, XAXIDMA_DMA_TO_DEVICE);
    XAxiDma_IntrAckIrq(&AxiDma, IrqStatus, XAXIDMA_DMA_TO_DEVICE);
    if (IrqStatus & XAXIDMA_IRQ_ALL_MASK){
    	TxDone=1;
    }
}

//����Tx�жϴ���ϵͳ
static int SetupTxIntrSystem()
{
	XScuGic_Config *IntcConfig;

	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);									//�鿴�豸
	XScuGic_CfgInitialize(&Intc, IntcConfig, IntcConfig->CpuBaseAddress);				//��ʼ��
	XScuGic_SetPriorityTriggerType(&Intc, TX_INTR_ID, 0x20, 0x1);						//���õ�ƽ����
	XScuGic_Connect(&Intc, TX_INTR_ID, (Xil_InterruptHandler)TxIntrHandler, TxRingPtr);	//�����жϷ�����
	XScuGic_Enable(&Intc, TX_INTR_ID);													//�ж�ʹ��

	//ʹ������Ӳ���������ж�
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)INTC_HANDLER, (void *)&Intc);
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

//�ر�Tx�жϴ���ϵͳ
static void DisableTxIntrSystem()
{
	XScuGic_Disconnect(&Intc, TX_INTR_ID);
}

//Tx׼��
static int TxSetup()
{
	XAxiDma_BdRingIntDisable(TxRingPtr, XAXIDMA_IRQ_ALL_MASK);//����������е��ж�
	XAxiDma_BdRingCreate(TxRingPtr, TX_BD_SPACE_BASE, TX_BD_SPACE_BASE, XAXIDMA_BD_MINIMUM_ALIGNMENT, TILE_HEIGHT);//����BD ring
	//��ʼ��TxRingPtr
	XAxiDma_Bd BdTemplate;
	XAxiDma_BdClear(&BdTemplate);
	XAxiDma_BdRingClone(TxRingPtr, &BdTemplate);

	XAxiDma_BdRingSetCoalesce(TxRingPtr, COALESCING_COUNT, DELAY_TIMER_COUNT);//���ö��ٸ�Tile����һ���ж�
	XAxiDma_BdRingIntEnable(TxRingPtr, XAXIDMA_IRQ_ALL_MASK);//ʹ�������ж�

	return XST_SUCCESS;
}

static int BdPerSendTile(int Buffer_Offset_Addr)
{
	XAxiDma_Bd *BdCurPtr;
	UINTPTR BufferAddr;
	int i;
	BufferAddr = TX_BUFFER_BASE + Buffer_Offset_Addr;
	BdCurPtr = TxBdPtr;
	for( i=0; i< TILE_HEIGHT;i++) {
		u32 CrBits = 0;
		XAxiDma_BdSetBufAddr(BdCurPtr, BufferAddr);
		XAxiDma_BdSetLength(BdCurPtr, TILE_WIDTH*NRCHANNELS, TxRingPtr->MaxTransferLen);
		if (i == 0) {
			CrBits |= XAXIDMA_BD_CTRL_TXSOF_MASK;//The first BD has SOF set
		}
		if(i == (TILE_HEIGHT - 1)) {
			CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;//The last BD should have EOF and IOC set
		}
		XAxiDma_BdSetCtrl(BdCurPtr, CrBits);
		XAxiDma_BdSetId(BdCurPtr, BufferAddr);
		BufferAddr = BufferAddr+WIDTH*NRCHANNELS;
		BdCurPtr = (XAxiDma_Bd *)XAxiDma_BdRingNext(TxRingPtr, BdCurPtr);
	}
	return XST_SUCCESS;
}

static int SendTile(int Buffer_Offset_Addr)
{
	XAxiDma_BdRingCreate(TxRingPtr, TX_BD_SPACE_BASE, TX_BD_SPACE_BASE, XAXIDMA_BD_MINIMUM_ALIGNMENT, TILE_HEIGHT);//����BD ring
	XAxiDma_BdRingAlloc(TxRingPtr, TILE_HEIGHT, &TxBdPtr);

//	TxRingPtr->HwTail=(XAxiDma_Bd *)TX_BD_SPACE_BASE;
//	TxRingPtr->PreCnt=TILE_HEIGHT;
//	TxRingPtr->HwCnt=0;

	BdPerSendTile(Buffer_Offset_Addr);
	XAxiDma_BdRingToHw(TxRingPtr, TILE_HEIGHT, TxBdPtr);//Give the BD to hardware
    XAxiDma_BdRingStart(TxRingPtr);
	return XST_SUCCESS;
}


//Rx�жϷ�����
static void RxIntrHandler()
{
    u32 IrqStatus;
    IrqStatus = XAxiDma_IntrGetIrq(&AxiDma, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrAckIrq(&AxiDma, IrqStatus, XAXIDMA_DEVICE_TO_DMA);
    if (IrqStatus & XAXIDMA_IRQ_ALL_MASK){
    	RxDone=1;
    }
}

//����Rx�жϴ���ϵͳ
static int SetupRxIntrSystem()
{
	XScuGic_Config *IntcConfig;

	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);									//�鿴�豸
	XScuGic_CfgInitialize(&Intc, IntcConfig, IntcConfig->CpuBaseAddress);				//��ʼ��
	XScuGic_SetPriorityTriggerType(&Intc, RX_INTR_ID, 0x28, 0x1);						//���õ�ƽ����
	XScuGic_Connect(&Intc, RX_INTR_ID, (Xil_InterruptHandler)RxIntrHandler, RxRingPtr);	//�����жϷ�����
	XScuGic_Enable(&Intc, RX_INTR_ID);													//�ж�ʹ��

	//ʹ������Ӳ���������ж�
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)INTC_HANDLER, (void *)&Intc);
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

//�ر�Rx�жϴ���ϵͳ
static void DisableRxIntrSystem()
{
	XScuGic_Disconnect(&Intc, RX_INTR_ID);
}

//Rx׼��
static int RxSetup()
{
	XAxiDma_BdRingIntDisable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);//����������е��ж�
	XAxiDma_BdRingCreate(RxRingPtr, RX_BD_SPACE_BASE, RX_BD_SPACE_BASE, XAXIDMA_BD_MINIMUM_ALIGNMENT, 1);//����BD ring
	//��ʼ��RxRingPtr
	XAxiDma_Bd BdTemplate;
	XAxiDma_BdClear(&BdTemplate);
	XAxiDma_BdRingClone(RxRingPtr, &BdTemplate);

	XAxiDma_BdRingSetCoalesce(RxRingPtr, COALESCING_COUNT, DELAY_TIMER_COUNT);//���ö��ٸ�Tile����һ���ж�
	XAxiDma_BdRingIntEnable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);//ʹ�������ж�

	return XST_SUCCESS;
}

static int BdPerReceiveTile(int Buffer_Offset_Addr,int byte_count)
{
	XAxiDma_Bd *BdCurPtr;
	UINTPTR BufferAddr;
	BufferAddr = RX_BUFFER_BASE + Buffer_Offset_Addr;
	BdCurPtr = RxBdPtr;

	XAxiDma_BdSetBufAddr(BdCurPtr, BufferAddr);
	XAxiDma_BdSetLength(BdCurPtr, byte_count, RxRingPtr->MaxTransferLen);
	XAxiDma_BdSetCtrl(BdCurPtr, 0);
	XAxiDma_BdSetId(BdCurPtr, BufferAddr);

	return XST_SUCCESS;
}

static int ReceiveTile(int Buffer_Offset_Addr,int byte_count)
{
	XAxiDma_BdRingCreate(RxRingPtr, RX_BD_SPACE_BASE, RX_BD_SPACE_BASE, XAXIDMA_BD_MINIMUM_ALIGNMENT, 1);//����BD ring
	XAxiDma_BdRingAlloc(RxRingPtr, 1, &RxBdPtr);

//	RxRingPtr->HwTail=(XAxiDma_Bd *)RX_BD_SPACE_BASE;
//	RxRingPtr->PreCnt=1;
//	RxRingPtr->HwCnt=0;

	BdPerReceiveTile(Buffer_Offset_Addr,byte_count);
	XAxiDma_BdRingToHw(RxRingPtr, 1, RxBdPtr);//Give the BD to hardware
    XAxiDma_BdRingStart(RxRingPtr);
	return XST_SUCCESS;
}


//��ȡ��Ŀ¼�ļ����������ļ�����
static int ScanFile(char File_Name[][NAME_LEN_MAX])
{
    FRESULT res;
    FILINFO finfo;
    DIR dir;
    TCHAR *fn;
    int FileCnt=0;
    char name[NAME_LEN_MAX];
	res = f_opendir(&dir,ROOT_PATH);
	if(res == FR_OK){
		while (f_readdir(&dir, &finfo) == FR_OK){
			fn = finfo.fname;
			strcpy(name, ROOT_PATH);
			strcat(name, "/");
			strcat(name, fn);
			strcpy(File_Name[FileCnt],name);
			if(!fn[0])break;
			FileCnt++; //ͼƬ������ȫ�ֱ�����
		}
	}
	f_closedir(&dir);
	return FileCnt;
}

//��ȡInFileName���������ݴ���DDR�е�ַbuf_addr
static int StbiLoad(char const* InFileName, int* Width, int* Height, char* DATA_BASE_ADDR)
{
    FIL pfile;
    UINT br;
    FRESULT status;
    printf("InFileName: %s\n", InFileName);
    status=f_open(&pfile,InFileName,FA_READ);
    char useless_segment1[18];
    char useless_segment2[96];
    int W,H;
    if (status != FR_OK){
        printf("open fail\n");
        return 1;
    }
    else{
    	f_read(&pfile,useless_segment1,sizeof(useless_segment1),&br);
    	f_read(&pfile,&W,4,&br);
    	f_read(&pfile,&H,4,&br);
    	f_read(&pfile,useless_segment2,sizeof(useless_segment2),&br);
    	*Width=W;
    	*Height=H;
    	for(int i=0;i<H;i++){
    		f_read(&pfile,DATA_BASE_ADDR+(H-1-i) * W * NRCHANNELS*sizeof(char),W * NRCHANNELS*sizeof(char),&br);
    	}
    	return 0;
    }
}






