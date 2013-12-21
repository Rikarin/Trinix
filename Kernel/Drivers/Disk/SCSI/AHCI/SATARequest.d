module Disk.SCSI.AHCI.SATARequest;


class SATARequest {
private:
	//scsi_ccb* ccb;
	ubyte fis[20];
	bool isATAPI;
	//sem_id completionSem;
	int completionStatus;
	void* data;
	ulong dataSize;


public:
	//bool IsTestUnitReady() { return isATAPI && ccb && ccb.cdb[0] == SCSI_OP_TEST_UNIT_READY; }
	bool IsATAPI() { return isATAPI; }
	@property void* Data() { return data; }
	@property ulong Length() { return dataSize; }
	//@property void* FIS() { return fis; }
}