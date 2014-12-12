module ObjectManager.IBlockDevice;


interface IBlockDevice {
	@property long Blocks();
	@property int BlockSize();

	ulong Read(long offset, byte[] data);
	ulong Write(long offset, byte[] data);
}