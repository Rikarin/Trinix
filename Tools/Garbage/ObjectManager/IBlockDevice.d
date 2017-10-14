/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module ObjectManager.IBlockDevice;


/**
 * This interface is inherted by every block device/driver and provide a common
 * method to communicate.
 * 
 */
interface IBlockDevice {
    /**
     * Getter
     * 
     * Returns:
     *      number of block in block device
     */
    @property long Blocks();

    /**
     * Getter
     * 
     * Returns:
     *      size of block in bytes
     */
    @property int BlockSize();

    /**
     * Read from block device
     * 
     * Params:
     *      offset  =       where start reading
     *      data    =       initialized array where length detemine how many
     *                      bytes will be red
     * 
     * Returns:
     *      length of red data. Will be less or equals to data.length
     */
    ulong Read(long offset, byte[] data);

    /**
     * Write to block device
     * 
     * Params:
     *      offset  =       where to write
     *      data    =       source array with data.
     * 
     * Returns:
     *      length of written data. Will be less or equals to data.length
     */
    ulong Write(long offset, byte[] data);
}